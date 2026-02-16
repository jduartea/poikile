# Poikile Theme — Ruby Test File
#
# Scopes to verify:
#   keyword.control.ruby                       → #c2788e  (if, elsif, else, unless, while, until, for, do, end, begin, rescue, ensure, raise, return, yield, case, when, then, class, module, def)
#   storage.type.ruby                          → #c2788e  (def, class, module)
#   entity.name.function.ruby                  → #d4a55c  (method names)
#   entity.name.type.class.ruby                → #7db89e  (class names)
#   entity.name.type.module.ruby               → #7db89e  (module names)
#   support.function.kernel.ruby               → #d4a55c  (puts, gets, require, raise, attr_accessor, attr_reader, attr_writer)
#   variable.language.ruby                     → #c2788e  italic (self)
#   variable.other.readwrite.instance.ruby     → #d4d0c8  (@instance)
#   variable.other.readwrite.class.ruby        → #d4d0c8  (@@class)
#   variable.other.readwrite.global.ruby       → #d4d0c8  ($global)
#   punctuation.definition.variable.ruby       → #d4d0c8
#   constant.other.symbol.ruby                 → #c8ba5e  (:symbol)
#   string.interpolated.ruby                   → #d08a6e  (#{interpolation})
#   constant.language.ruby                     → #c9905a  (true, false, nil)
#   keyword.operator.ruby                      → #9b9baa
#   string                                     → #a3b87c
#   constant.numeric                           → #c9905a
#   comment                                    → #8a8784  italic

require 'json'
require 'net/http'
require 'uri'
require 'logger'
require 'securerandom'
require 'date'

# ── Module for shared behavior ───────────────────────────────────────────

module Serializable
  def to_json(*args)
    to_h.to_json(*args)
  end

  def to_h
    raise NotImplementedError, "#{self.class} must implement #to_h"
  end
end

module Describable
  def describe
    raise NotImplementedError, "#{self.class} must implement #describe"
  end

  def summary
    desc = describe
    desc.length > 80 ? "#{desc[0..76]}..." : desc
  end
end

# ── Enum-like module ─────────────────────────────────────────────────────

module Priority
  LOW = :low
  MEDIUM = :medium
  HIGH = :high
  CRITICAL = :critical

  ALL = [LOW, MEDIUM, HIGH, CRITICAL].freeze

  def self.valid?(value)
    ALL.include?(value)
  end

  def self.from_string(str)
    sym = str.to_s.downcase.to_sym
    raise ArgumentError, "Invalid priority: #{str}" unless valid?(sym)
    sym
  end
end

# ── Configuration with class variables ───────────────────────────────────

class Config
  @@instances = 0

  attr_accessor :base_url, :timeout, :max_retries, :verify_ssl
  attr_reader :created_at

  DEFAULT_TIMEOUT = 30
  MAX_RETRY_COUNT = 5

  def initialize(base_url:, timeout: DEFAULT_TIMEOUT, max_retries: 3, verify_ssl: true)
    @base_url = base_url.chomp('/')
    @timeout = timeout
    @max_retries = [max_retries, MAX_RETRY_COUNT].min
    @verify_ssl = verify_ssl
    @created_at = Time.now
    @@instances += 1
  end

  def self.instance_count
    @@instances
  end

  def to_s
    "#<Config url=#{@base_url} timeout=#{@timeout}s retries=#{@max_retries}>"
  end
end

# ── Task class with full Ruby features ───────────────────────────────────

class Task
  include Serializable
  include Describable
  include Comparable

  attr_accessor :title, :description, :status, :priority
  attr_reader :id, :created_at, :metadata

  STATUSES = %i[pending running completed failed cancelled].freeze

  def initialize(id: nil, title:, description: nil, priority: Priority::MEDIUM)
    @id = id || SecureRandom.uuid
    @title = title
    @description = description
    @priority = priority
    @status = :pending
    @metadata = {}
    @created_at = Time.now
    @completed_at = nil

    yield self if block_given?
  end

  def complete!
    raise "Task already terminal" if terminal?
    @status = :completed
    @completed_at = Time.now
    self
  end

  def fail!(reason = nil)
    raise "Task already terminal" if terminal?
    @status = :failed
    @metadata[:failure_reason] = reason if reason
    self
  end

  def terminal?
    %i[completed failed cancelled].include?(@status)
  end

  def duration
    return nil unless @completed_at
    @completed_at - @created_at
  end

  def add_metadata(key, value)
    @metadata[key.to_sym] = value
    self
  end

  def <=>(other)
    return nil unless other.is_a?(Task)
    Priority::ALL.index(priority) <=> Priority::ALL.index(other.priority)
  end

  def to_h
    {
      id: @id,
      title: @title,
      description: @description,
      status: @status,
      priority: @priority,
      created_at: @created_at.iso8601,
      metadata: @metadata
    }
  end

  def describe
    "[#{@id[0..7]}] #{@title} (#{@priority}, #{@status})"
  end

  def to_s
    "Task(#{@id[0..7]}, \"#{@title}\")"
  end

  def inspect
    "#<Task id=#{@id[0..7]} title=#{@title.inspect} status=#{@status}>"
  end
end

# ── Repository with error handling ───────────────────────────────────────

class TaskRepository
  class NotFoundError < StandardError; end
  class ValidationError < StandardError; end

  def initialize
    @store = {}
    @logger = Logger.new($stdout)
    @logger.level = Logger::INFO
  end

  def save(task)
    raise ValidationError, "Title cannot be blank" if task.title.nil? || task.title.strip.empty?
    @store[task.id] = task
    @logger.info("Saved task: #{task.id}")
    task
  end

  def find(id)
    @store[id] or raise NotFoundError, "Task not found: #{id}"
  end

  def find_by_status(status)
    @store.values.select { |t| t.status == status }
  end

  def find_by_priority(*priorities)
    @store.values.select { |t| priorities.include?(t.priority) }
  end

  def all
    @store.values.sort
  end

  def delete(id)
    task = @store.delete(id)
    raise NotFoundError, "Task not found: #{id}" unless task
    @logger.info("Deleted task: #{id}")
    task
  end

  def count
    @store.size
  end

  def each(&block)
    @store.values.each(&block)
  end

  def map(&block)
    @store.values.map(&block)
  end
end

# ── HTTP client with retry logic ─────────────────────────────────────────

class HttpClient
  MAX_REDIRECTS = 5

  def initialize(config)
    @config = config
    @logger = Logger.new($stdout)
  end

  def get(path, headers: {})
    request(:get, path, headers: headers)
  end

  def post(path, body:, headers: {})
    request(:post, path, body: body, headers: headers)
  end

  private

  def request(method, path, body: nil, headers: {})
    url = URI.parse("#{@config.base_url}#{path}")
    attempts = 0

    begin
      attempts += 1
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = url.scheme == 'https'
      http.verify_mode = @config.verify_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = @config.timeout

      req = case method
            when :get then Net::HTTP::Get.new(url)
            when :post
              r = Net::HTTP::Post.new(url)
              r.body = body.to_json if body
              r
            else
              raise ArgumentError, "Unsupported method: #{method}"
            end

      headers.each { |k, v| req[k.to_s] = v.to_s }
      req['Content-Type'] = 'application/json'
      req['Accept'] = 'application/json'

      response = http.request(req)

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body, symbolize_names: true)
      when Net::HTTPRedirection
        raise "Too many redirects" if attempts > MAX_REDIRECTS
        url = URI.parse(response['location'])
        retry
      else
        raise "HTTP #{response.code}: #{response.message}"
      end
    rescue StandardError => e
      if attempts < @config.max_retries
        delay = 2**attempts
        @logger.warn("Attempt #{attempts} failed: #{e.message}. Retrying in #{delay}s...")
        sleep(delay)
        retry
      end
      raise
    end
  end
end

# ── Blocks, procs, lambdas ───────────────────────────────────────────────

def with_timing(label = "operation")
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  result = yield
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
  puts "#{label} took #{elapsed.round(4)}s"
  result
end

def transform_tasks(tasks, &block)
  tasks.map(&block)
end

square = ->(x) { x * x }
double = proc { |x| x * 2 }

# ── String operations ────────────────────────────────────────────────────

def format_report(tasks)
  header = <<~HEREDOC
    ╔═══════════════════════════════════╗
    ║       Task Pipeline Report        ║
    ╚═══════════════════════════════════╝
  HEREDOC

  rows = tasks.map do |task|
    status_icon = case task.status
                  when :completed then '✓'
                  when :failed then '✗'
                  when :running then '⟳'
                  else '○'
                  end
    "  #{status_icon} #{task.describe}"
  end

  "#{header}\n#{rows.join("\n")}\n\nTotal: #{tasks.size} tasks"
end

# ── Numeric literals ─────────────────────────────────────────────────────

PI = 3.14159_26535
HEX_COLOR = 0xFF_AA_00
OCTAL_PERMS = 0o755
BINARY_FLAGS = 0b1010_0101
BIG_NUMBER = 1_000_000_000
RATIONAL = 1/3r
COMPLEX = 3 + 4i

# ── Main execution ───────────────────────────────────────────────────────

if __FILE__ == $PROGRAM_NAME
  repo = TaskRepository.new

  tasks = [
    Task.new(title: "Deploy service", priority: Priority::HIGH),
    Task.new(title: "Run migrations", priority: Priority::CRITICAL),
    Task.new(title: "Update docs", priority: Priority::LOW),
    Task.new(title: "Send notifications") { |t| t.add_metadata(:channel, "slack") },
  ]

  tasks.each { |task| repo.save(task) }

  with_timing("task processing") do
    repo.each do |task|
      begin
        task.complete!
        puts "Completed: #{task}"
      rescue => e
        puts "Error: #{e.message}"
        task.fail!(e.message)
      ensure
        puts "  Status: #{task.status}"
      end
    end
  end

  # Enumerable operations
  high_priority = repo.find_by_priority(Priority::HIGH, Priority::CRITICAL)
  completed = repo.find_by_status(:completed)
  titles = repo.map(&:title)
  descriptions = transform_tasks(repo.all) { |t| t.summary }

  puts "\nHigh priority: #{high_priority.size}"
  puts "Completed: #{completed.size}"
  puts "Titles: #{titles.inspect}"
  puts "Report:\n#{format_report(repo.all)}"

  # Demonstrate lambdas
  numbers = [1, 2, 3, 4, 5]
  puts "Squares: #{numbers.map(&square).inspect}"
  puts "Doubles: #{numbers.map(&double).inspect}"

  # Numeric operations
  puts "PI: #{PI}, hex: #{HEX_COLOR}, rational: #{RATIONAL.to_f}"

  # Regex
  version = "v2.1.0-beta.1"
  if version =~ /^v?(\d+)\.(\d+)\.(\d+)/
    puts "Version: #{$1}.#{$2}.#{$3}"
  end

  # Global variable
  $exit_code = 0
  exit($exit_code)
end
