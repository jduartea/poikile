// Poikile Theme — Go Test File
//
// Colors vary by variant — see PALETTE.md for hex values per theme.
//
// Scopes to verify:
//   keyword.go               → keyword  (func, type, go, select, defer, range, package, import, return, var, const)
//   keyword.map.go           → type     (map)
//   keyword.channel.go       → decorator  (chan, <-)
//   keyword.struct.go        → type     (struct)
//   keyword.interface.go     → type     (interface)
//   keyword.function.go      → keyword  (func)
//   entity.name.function.go  → function  italic (function declarations and calls)
//   entity.name.type.go      → type     italic (custom types like Pipeline, Job, Result)
//   storage.type.go          → number   italic (int, string, bool, byte, error, float64, etc.)
//   variable.other.go        → fg.default  (local variables)
//   [semantic] property      → attribute  (field access: resp.Body, job.ID — needs gopls)
//   support.function.builtin.go → function (make, len, cap, append, copy, delete, close, panic, recover, new, print, println)
//   string.quoted.double.go  → string  (regular strings)
//   string.quoted.raw.go     → regex   (backtick strings)
//   constant.other.placeholder.go → regex (fmt verbs: %s, %d, %v)
//   entity.name.package.go   → namespace  (package name)
//   entity.alias.import.go   → namespace  (import aliases)
//   comment                  → fg.muted  (italic)
//   constant.numeric         → number   (numbers)
//   constant.language         → number   (true, false, nil, iota)
//   keyword.operator          → fg.subtle  (operators)
//   meta.definition.method.go → function (method receivers)

package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"sync"
	"time"

	log "github.com/sirupsen/logrus"
)

// Status represents the current state of a job in the pipeline.
type Status int

const (
	StatusPending   Status = iota // 0
	StatusRunning                 // 1
	StatusCompleted               // 2
	StatusFailed                  // 3
)

const maxRetries = 3
const defaultTimeout = 30 * time.Second

// Job holds the configuration and state for a single unit of work.
type Job struct {
	ID        string                 `json:"id"`
	Name      string                 `json:"name"`
	Status    Status                 `json:"status"`
	Retries   int                    `json:"retries"`
	Payload   map[string]interface{} `json:"payload,omitempty"`
	CreatedAt time.Time              `json:"created_at"`
	tags      []string
}

// Pipeline orchestrates job execution with concurrency controls.
type Pipeline struct {
	mu          sync.RWMutex
	jobs        []*Job
	workerCount int
	results     chan *Result
	errors      chan error
	done        chan struct{}
}

// Result captures the output of a completed job.
type Result struct {
	JobID    string
	Duration time.Duration
	Output   []byte
	Err      error
}

// Processor defines the interface for job processing strategies.
type Processor interface {
	Process(ctx context.Context, job *Job) (*Result, error)
	Validate(job *Job) bool
}

// NewPipeline creates a pipeline with the given worker count.
func NewPipeline(workers int) *Pipeline {
	if workers <= 0 {
		workers = 1
	}
	return &Pipeline{
		workerCount: workers,
		results:     make(chan *Result, workers*2),
		errors:      make(chan error, workers),
		done:        make(chan struct{}),
	}
}

// AddJob appends a job to the pipeline queue.
func (p *Pipeline) AddJob(job *Job) {
	p.mu.Lock()
	defer p.mu.Unlock()
	job.Status = StatusPending
	job.CreatedAt = time.Now()
	p.jobs = append(p.jobs, job)
}

// Run starts all workers and waits for completion.
func (p *Pipeline) Run(ctx context.Context, proc Processor) error {
	var wg sync.WaitGroup

	jobCh := make(chan *Job, len(p.jobs))
	for _, j := range p.jobs {
		if proc.Validate(j) {
			jobCh <- j
		}
	}
	close(jobCh)

	for i := 0; i < p.workerCount; i++ {
		wg.Add(1)
		go func(workerID int) {
			defer wg.Done()
			for job := range jobCh {
				p.executeJob(ctx, proc, job, workerID)
			}
		}(i)
	}

	go func() {
		wg.Wait()
		close(p.done)
	}()

	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-p.done:
		return nil
	}
}

func (p *Pipeline) executeJob(ctx context.Context, proc Processor, job *Job, workerID int) {
	p.mu.Lock()
	job.Status = StatusRunning
	p.mu.Unlock()

	log.WithFields(log.Fields{
		"worker": workerID,
		"job":    job.ID,
	}).Info("starting job execution")

	var result *Result
	var err error

	for attempt := 0; attempt <= maxRetries; attempt++ {
		if attempt > 0 {
			backoff := time.Duration(math.Pow(2, float64(attempt))) * time.Second
			fmt.Printf("worker %d: retrying job %s (attempt %d/%d) after %v\n",
				workerID, job.ID, attempt, maxRetries, backoff)
			time.Sleep(backoff)
		}

		childCtx, cancel := context.WithTimeout(ctx, defaultTimeout)
		result, err = proc.Process(childCtx, job)
		cancel()

		if err == nil {
			break
		}
	}

	p.mu.Lock()
	defer p.mu.Unlock()

	if err != nil {
		job.Status = StatusFailed
		job.Retries = maxRetries
		p.errors <- fmt.Errorf("job %s failed after %d attempts: %w", job.ID, maxRetries, err)
		return
	}

	job.Status = StatusCompleted
	p.results <- result
}

// Stats returns a summary of pipeline state.
func (p *Pipeline) Stats() map[string]int {
	p.mu.RLock()
	defer p.mu.RUnlock()

	stats := map[string]int{
		"total":     len(p.jobs),
		"pending":   0,
		"running":   0,
		"completed": 0,
		"failed":    0,
	}

	for _, j := range p.jobs {
		switch j.Status {
		case StatusPending:
			stats["pending"]++
		case StatusRunning:
			stats["running"]++
		case StatusCompleted:
			stats["completed"]++
		case StatusFailed:
			stats["failed"]++
		default:
			// unknown status, skip
		}
	}
	return stats
}

// fetchJSON makes an HTTP GET request and decodes the JSON response.
func fetchJSON(ctx context.Context, url string, target interface{}) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return fmt.Errorf("creating request: %w", err)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("executing request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("unexpected status %d: %s", resp.StatusCode, string(body))
	}

	return json.NewDecoder(resp.Body).Decode(target)
}

// Generic-style function using type constraints (Go 1.18+)
type Number interface {
	~int | ~int64 | ~float64
}

func Sum[T Number](values []T) T {
	var total T
	for _, v := range values {
		total += v
	}
	return total
}

func Map[T any, U any](slice []T, fn func(T) U) []U {
	result := make([]U, len(slice))
	for i, v := range slice {
		result[i] = fn(v)
	}
	return result
}

// Raw string literal and format verbs
var queryTemplate = `
SELECT id, name, status
FROM jobs
WHERE status = $1
  AND created_at > $2
ORDER BY created_at DESC
LIMIT %d
`

func main() {
	pipe := NewPipeline(4)

	tags := []string{"urgent", "batch"}
	job := &Job{
		ID:   "job-001",
		Name: "data-export",
		Payload: map[string]interface{}{
			"format":  "csv",
			"limit":   1000,
			"enabled": true,
		},
		tags: tags,
	}
	pipe.AddJob(job)

	nums := []int{10, 20, 30, 40, 50}
	total := Sum(nums)

	doubled := Map(nums, func(n int) int { return n * 2 })

	cap := cap(nums)
	length := len(doubled)

	fmt.Printf("total=%d, cap=%d, length=%d\n", total, cap, length)
	fmt.Printf(queryTemplate, 100)

	data := make(map[string][]byte)
	data["key"] = []byte("value")
	delete(data, "key")

	ch := make(chan int, 10)
	go func() {
		for i := 0; i < 5; i++ {
			ch <- i
		}
		close(ch)
	}()

	for val := range ch {
		if val%2 == 0 {
			println(val)
		}
	}

	var x interface{} = 42
	if n, ok := x.(int); ok {
		fmt.Printf("type assertion succeeded: %d\n", n)
	}

	pi := 3.14159
	hex := 0xFF
	octal := 0o77
	binary := 0b1010
	_ = pi + float64(hex) + float64(octal) + float64(binary)

	isReady := true
	isNil := false
	var nothing *int = nil
	_, _, _ = isReady, isNil, nothing
}
