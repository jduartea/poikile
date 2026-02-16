#!/bin/bash
# Poikile Theme — Shell / Bash Test File
#
# Colors vary by variant — see PALETTE.md for hex values per theme.
#
# Scopes to verify:
#   keyword.control.shell              → keyword  (if, then, else, elif, fi, for, in, do, done, while, until, case, esac, function, return, exit)
#   entity.name.function.shell         → function  (function names)
#   support.function.builtin.shell     → function  (echo, cd, export, source, test, read, eval, exec, trap, set, unset, shift, wait)
#   variable.other.shell               → fg.default  ($VAR)
#   variable.other.bracket.shell       → fg.default  (${VAR})
#   variable.other.special.shell       → fg.default  ($0, $1, $@, $#, $?, $$)
#   punctuation.definition.variable    → fg.default
#   string.quoted.double.shell         → string  (double-quoted strings)
#   string.quoted.single.shell         → string  (single-quoted strings)
#   string.interpolated.dollar.shell   → regex  (command substitution)
#   keyword.operator.pipe.shell        → fg.subtle  (|)
#   keyword.operator.redirect.shell    → fg.subtle  (>, >>, <, 2>, &>)
#   keyword.operator.logical.shell     → fg.subtle  (&&, ||)
#   keyword.operator.glob.shell        → fg.subtle  (*, ?)
#   meta.scope.subshell.shell          → fg.default  ($())
#   constant.other.option.shell        → fg.subtle  (command flags)
#   comment                            → fg.muted  italic

set -euo pipefail
IFS=$'\n\t'

# ── Constants ──────────────────────────────────────────────────────────

readonly APP_NAME="poikile"
readonly APP_VERSION="2.1.0"
readonly CONFIG_DIR="${HOME}/.config/${APP_NAME}"
readonly LOG_FILE="/var/log/${APP_NAME}/deploy.log"
readonly MAX_RETRIES=3
readonly TIMEOUT=30

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# ── Utility Functions ──────────────────────────────────────────────────

log_info() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[INFO]${NC} ${timestamp} - ${message}"
    echo "[INFO] ${timestamp} - ${message}" >> "${LOG_FILE}" 2>/dev/null || true
}

log_error() {
    local message="$1"
    echo -e "${RED}[ERROR]${NC} $(date '+%H:%M:%S') - ${message}" >&2
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

die() {
    log_error "$1"
    exit "${2:-1}"
}

# ── Validation Functions ───────────────────────────────────────────────

check_dependencies() {
    local deps=("docker" "git" "curl" "jq" "openssl")
    local missing=()

    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing dependencies: ${missing[*]}"
    fi

    log_success "All dependencies satisfied"
}

validate_environment() {
    local required_vars=("DEPLOY_ENV" "API_KEY" "DATABASE_URL")

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            die "Required environment variable not set: ${var}"
        fi
    done

    case "${DEPLOY_ENV}" in
        production|staging|development)
            log_info "Environment: ${DEPLOY_ENV}"
            ;;
        *)
            die "Invalid DEPLOY_ENV: ${DEPLOY_ENV}. Must be production, staging, or development."
            ;;
    esac
}

# ── Configuration ──────────────────────────────────────────────────────

init_config() {
    if [[ ! -d "${CONFIG_DIR}" ]]; then
        mkdir -p "${CONFIG_DIR}"
        log_info "Created config directory: ${CONFIG_DIR}"
    fi

    local config_file="${CONFIG_DIR}/config.env"

    if [[ ! -f "${config_file}" ]]; then
        cat > "${config_file}" <<-EOF
# ${APP_NAME} configuration
# Generated on $(date -u '+%Y-%m-%dT%H:%M:%SZ')

APP_PORT=8080
WORKERS=4
LOG_LEVEL=info
ENABLE_CACHE=true
RATE_LIMIT=100
EOF
        log_info "Generated default config: ${config_file}"
    fi

    # shellcheck source=/dev/null
    source "${config_file}"
}

# ── Build & Deploy ─────────────────────────────────────────────────────

build_image() {
    local tag="${1:-latest}"
    local dockerfile="${2:-Dockerfile}"
    local build_args=""

    if [[ -n "${BUILD_DATE:-}" ]]; then
        build_args="--build-arg BUILD_DATE=${BUILD_DATE}"
    fi

    log_info "Building image: ${APP_NAME}:${tag}"

    docker build \
        --file "${dockerfile}" \
        --tag "${APP_NAME}:${tag}" \
        --label "version=${APP_VERSION}" \
        --label "build-date=$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
        ${build_args} \
        --no-cache \
        . 2>&1 | tee -a "${LOG_FILE}"

    local exit_code=${PIPESTATUS[0]}

    if [[ ${exit_code} -ne 0 ]]; then
        die "Build failed with exit code ${exit_code}"
    fi

    log_success "Built ${APP_NAME}:${tag}"
}

deploy_service() {
    local env="${1}"
    local version="${2:-${APP_VERSION}}"
    local attempts=0

    log_info "Deploying ${APP_NAME} v${version} to ${env}"

    while [[ ${attempts} -lt ${MAX_RETRIES} ]]; do
        attempts=$((attempts + 1))

        if docker service update \
            --image "${APP_NAME}:${version}" \
            --update-parallelism 1 \
            --update-delay 10s \
            --update-failure-action rollback \
            "${APP_NAME}-${env}" 2>/dev/null; then

            log_success "Deployed to ${env} (attempt ${attempts}/${MAX_RETRIES})"
            return 0
        fi

        log_warning "Attempt ${attempts}/${MAX_RETRIES} failed"
        sleep $((2 ** attempts))
    done

    die "Deployment failed after ${MAX_RETRIES} attempts"
}

# ── Health Check ───────────────────────────────────────────────────────

wait_for_healthy() {
    local url="${1}"
    local max_wait="${2:-60}"
    local interval=5
    local elapsed=0

    log_info "Waiting for ${url} to become healthy..."

    while [[ ${elapsed} -lt ${max_wait} ]]; do
        local status
        status=$(curl -s -o /dev/null -w '%{http_code}' \
            --connect-timeout 5 \
            --max-time 10 \
            "${url}/health" 2>/dev/null) || true

        if [[ "${status}" == "200" ]]; then
            log_success "Service healthy after ${elapsed}s"
            return 0
        fi

        echo -n "."
        sleep ${interval}
        elapsed=$((elapsed + interval))
    done

    echo ""
    die "Service not healthy after ${max_wait}s (last status: ${status:-unknown})"
}

# ── Cleanup ────────────────────────────────────────────────────────────

cleanup() {
    local exit_code=$?

    if [[ ${exit_code} -ne 0 ]]; then
        log_error "Script failed with exit code ${exit_code}"
    fi

    # Remove temp files
    if [[ -d "${TMPDIR:-/tmp}/${APP_NAME}-*" ]]; then
        rm -rf "${TMPDIR:-/tmp}/${APP_NAME}-"*
    fi

    # Remove dangling images
    docker image prune -f --filter "label=app=${APP_NAME}" 2>/dev/null || true

    log_info "Cleanup completed"
}

trap cleanup EXIT
trap 'die "Interrupted"' INT TERM

# ── Argument Parsing ───────────────────────────────────────────────────

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS] COMMAND

Commands:
    build       Build the Docker image
    deploy      Deploy to the specified environment
    health      Check service health
    rollback    Rollback to previous version

Options:
    -e, --env ENV       Target environment (production|staging|development)
    -v, --version VER   Version tag (default: ${APP_VERSION})
    -t, --tag TAG       Docker image tag
    -d, --dry-run       Show what would be done
    -h, --help          Show this help message
    --verbose           Enable verbose output

Examples:
    $(basename "$0") build --tag latest
    $(basename "$0") deploy --env production --version 2.1.0
    $(basename "$0") health --env staging
USAGE
}

parse_args() {
    local env=""
    local version="${APP_VERSION}"
    local tag="latest"
    local dry_run=false
    local verbose=false
    local command=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            build|deploy|health|rollback)
                command="$1"
                shift
                ;;
            -e|--env)
                env="$2"
                shift 2
                ;;
            -v|--version)
                version="$2"
                shift 2
                ;;
            -t|--tag)
                tag="$2"
                shift 2
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            --verbose)
                verbose=true
                set -x
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                die "Unknown option: $1. Use --help for usage."
                ;;
        esac
    done

    if [[ -z "${command}" ]]; then
        usage
        exit 1
    fi

    # Export for subcommands
    export DEPLOY_ENV="${env}"

    if ${verbose}; then
        log_info "Command: ${command}, Env: ${env}, Version: ${version}, Tag: ${tag}"
    fi

    if ${dry_run}; then
        log_warning "Dry run mode — no changes will be made"
        return 0
    fi

    # Execute command
    case "${command}" in
        build)
            build_image "${tag}"
            ;;
        deploy)
            [[ -z "${env}" ]] && die "Environment required for deploy"
            validate_environment
            deploy_service "${env}" "${version}"
            wait_for_healthy "https://${APP_NAME}-${env}.example.com"
            ;;
        health)
            [[ -z "${env}" ]] && die "Environment required for health check"
            wait_for_healthy "https://${APP_NAME}-${env}.example.com"
            ;;
        rollback)
            [[ -z "${env}" ]] && die "Environment required for rollback"
            log_info "Rolling back ${env}..."
            docker service rollback "${APP_NAME}-${env}"
            ;;
    esac
}

# ── Subshell & pipes ───────────────────────────────────────────────────

gather_stats() {
    local container_count
    container_count=$(docker ps --filter "label=app=${APP_NAME}" --format '{{.ID}}' | wc -l)

    local total_memory
    total_memory=$(docker stats --no-stream --format '{{.MemUsage}}' \
        $(docker ps -q --filter "label=app=${APP_NAME}") 2>/dev/null \
        | awk -F'/' '{print $1}' \
        | tr -d ' MiB' \
        | paste -sd+ - \
        | bc 2>/dev/null || echo "0")

    local git_hash
    git_hash=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

    echo "Containers: ${container_count}, Memory: ${total_memory}MiB, Commit: ${git_hash}"
}

# ── Main ───────────────────────────────────────────────────────────────

main() {
    log_info "Starting ${APP_NAME} v${APP_VERSION} (PID: $$)"
    log_info "Args: $# — $*"
    log_info "User: $(whoami)@$(hostname)"
    log_info "Working dir: $(pwd)"

    check_dependencies
    init_config
    parse_args "$@"

    log_success "Done!"
}

main "$@"
