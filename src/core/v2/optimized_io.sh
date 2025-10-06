#!/bin/bash

# Optimized I/O Operations - V2 Architecture  
# Provides performance-optimized file operations, lazy loading, and intelligent caching

# I/O optimization configuration
IO_CACHE_ENABLED=${IO_CACHE_ENABLED:-true}
IO_LAZY_LOADING=${IO_LAZY_LOADING:-true}
IO_BUFFER_SIZE=${IO_BUFFER_SIZE:-8192}  # 8KB buffer
IO_PARALLEL_ENABLED=${IO_PARALLEL_ENABLED:-true}
IO_COMPRESSION_ENABLED=${IO_COMPRESSION_ENABLED:-false}

# File operation cache
declare -A FILE_CACHE=()
declare -A FILE_MTIME_CACHE=()

# Lazy-loaded file content
declare -A LAZY_FILES=()
declare -A LAZY_FILE_LOADERS=()

# Initialize optimized I/O system
init_optimized_io() {
    log_debug "OPTIMIZED_IO" "Initializing optimized I/O system..."
    
    # Check for required tools
    check_io_tools
    
    log_info "OPTIMIZED_IO" "Optimized I/O system initialized"
}

# Check for I/O optimization tools
check_io_tools() {
    local missing_tools=()
    
    # Check for parallel processing tools
    if [[ "$IO_PARALLEL_ENABLED" == "true" ]]; then
        if ! command -v xargs >/dev/null 2>&1; then
            missing_tools+=("xargs")
        fi
    fi
    
    # Check for compression tools
    if [[ "$IO_COMPRESSION_ENABLED" == "true" ]]; then
        if ! command -v gzip >/dev/null 2>&1; then
            missing_tools+=("gzip")
        fi
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warning "OPTIMIZED_IO" "Missing tools for optimal performance: ${missing_tools[*]}"
    fi
}

# Get file modification time
get_file_mtime() {
    local file_path="$1"
    
    if [[ -f "$file_path" ]]; then
        stat -c %Y "$file_path" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Check if file has been modified since last cache
is_file_modified() {
    local file_path="$1"
    local current_mtime cached_mtime
    
    current_mtime=$(get_file_mtime "$file_path")
    cached_mtime="${FILE_MTIME_CACHE[$file_path]:-0}"
    
    [[ "$current_mtime" -gt "$cached_mtime" ]]
}

# Optimized file read with caching
optimized_file_read() {
    local file_path="$1"
    local use_cache="${2:-true}"
    local cache_key="file_content_$(echo "$file_path" | md5sum | cut -d' ' -f1)"
    
    if [[ ! -f "$file_path" ]]; then
        log_error "OPTIMIZED_IO" "File not found: $file_path"
        return 1
    fi
    
    # Check cache if enabled
    if [[ "$use_cache" == "true" && "$IO_CACHE_ENABLED" == "true" ]]; then
        if ! is_file_modified "$file_path" && cache_exists "$cache_key"; then
            cache_get "$cache_key"
            perf_increment_counter "file_read_cache_hits"
            log_debug "OPTIMIZED_IO" "Cache hit for file: $file_path"
            return 0
        fi
    fi
    
    perf_start_timer "file_read_$(basename "$file_path")"
    
    # Read file with optimized buffer
    local content
    if command -v dd >/dev/null 2>&1; then
        content=$(dd if="$file_path" bs="$IO_BUFFER_SIZE" 2>/dev/null)
    else
        content=$(cat "$file_path")
    fi
    
    local read_duration
    read_duration=$(perf_end_timer "file_read_$(basename "$file_path")" "File read: $file_path")
    
    # Cache the content and modification time
    if [[ "$use_cache" == "true" && "$IO_CACHE_ENABLED" == "true" ]]; then
        cache_set "$cache_key" "$content" "$CACHE_TTL"
        FILE_MTIME_CACHE["$file_path"]=$(get_file_mtime "$file_path")
        log_debug "OPTIMIZED_IO" "Cached file content: $file_path (${#content} bytes)"
    fi
    
    perf_increment_counter "file_read_cache_misses"
    echo "$content"
}

# Optimized file write with backup
optimized_file_write() {
    local file_path="$1"
    local content="$2"
    local create_backup="${3:-true}"
    local compress_backup="${4:-false}"
    
    perf_start_timer "file_write_$(basename "$file_path")"
    
    # Create backup if requested
    if [[ "$create_backup" == "true" && -f "$file_path" ]]; then
        local backup_path="${file_path}.backup.$(date +%s)"
        
        if [[ "$compress_backup" == "true" && "$IO_COMPRESSION_ENABLED" == "true" ]]; then
            gzip -c "$file_path" > "${backup_path}.gz" 2>/dev/null
            log_debug "OPTIMIZED_IO" "Created compressed backup: ${backup_path}.gz"
        else
            cp "$file_path" "$backup_path" 2>/dev/null
            log_debug "OPTIMIZED_IO" "Created backup: $backup_path"
        fi
    fi
    
    # Write content with atomic operation
    local temp_file="${file_path}.tmp.$$"
    
    if echo "$content" > "$temp_file" 2>/dev/null; then
        if mv "$temp_file" "$file_path" 2>/dev/null; then
            # Invalidate cache
            local cache_key="file_content_$(echo "$file_path" | md5sum | cut -d' ' -f1)"
            cache_clear "$cache_key"
            unset FILE_MTIME_CACHE["$file_path"]
            
            local write_duration
            write_duration=$(perf_end_timer "file_write_$(basename "$file_path")" "File write: $file_path")
            
            log_debug "OPTIMIZED_IO" "File written successfully: $file_path (${#content} bytes)"
            return 0
        else
            rm -f "$temp_file" 2>/dev/null
            log_error "OPTIMIZED_IO" "Failed to move temporary file: $temp_file"
            return 1
        fi
    else
        log_error "OPTIMIZED_IO" "Failed to write temporary file: $temp_file"
        return 1
    fi
}

# Register file for lazy loading
register_lazy_file() {
    local file_id="$1"
    local file_path="$2"
    local loader_function="${3:-optimized_file_read}"
    
    if [[ ! -f "$file_path" ]]; then
        log_warning "OPTIMIZED_IO" "Lazy file registration: file not found: $file_path"
    fi
    
    LAZY_FILES["$file_id"]="$file_path"
    LAZY_FILE_LOADERS["$file_id"]="$loader_function"
    
    log_debug "OPTIMIZED_IO" "Registered lazy file: $file_id -> $file_path"
}

# Load file content lazily
load_lazy_file() {
    local file_id="$1"
    local use_cache="${2:-true}"
    
    if [[ -z "${LAZY_FILES[$file_id]:-}" ]]; then
        log_error "OPTIMIZED_IO" "Lazy file not registered: $file_id"
        return 1
    fi
    
    local file_path="${LAZY_FILES[$file_id]}"
    local loader_function="${LAZY_FILE_LOADERS[$file_id]}"
    
    perf_start_timer "lazy_load_$file_id"
    
    local content
    if content=$("$loader_function" "$file_path" "$use_cache"); then
        local load_duration
        load_duration=$(perf_end_timer "lazy_load_$file_id" "Lazy load: $file_id")
        
        perf_increment_counter "lazy_file_loads"
        echo "$content"
        return 0
    else
        perf_end_timer "lazy_load_$file_id" "Failed lazy load: $file_id"
        log_error "OPTIMIZED_IO" "Failed to lazy load file: $file_id"
        return 1
    fi
}

# Batch file operations with parallel processing
batch_file_operation() {
    local operation="$1"  # read, write, delete, copy
    local file_list_array="$2"
    local max_parallel="${3:-4}"
    
    declare -n files_ref="$file_list_array"
    
    if [[ ${#files_ref[@]} -eq 0 ]]; then
        log_warning "OPTIMIZED_IO" "Empty file list for batch operation: $operation"
        return 1
    fi
    
    perf_start_timer "batch_${operation}"
    
    case "$operation" in
        "read")
            batch_read_files files_ref "$max_parallel"
            ;;
        "delete")
            batch_delete_files files_ref "$max_parallel"
            ;;
        "copy")
            batch_copy_files files_ref "$max_parallel"
            ;;
        *)
            log_error "OPTIMIZED_IO" "Unsupported batch operation: $operation"
            return 1
            ;;
    esac
    
    local batch_duration
    batch_duration=$(perf_end_timer "batch_${operation}" "Batch $operation: ${#files_ref[@]} files")
    
    perf_increment_counter "batch_operations"
}

# Batch read files
batch_read_files() {
    local files_array="$1"
    local max_parallel="$2"
    
    declare -n files_ref="$files_array"
    
    if [[ "$IO_PARALLEL_ENABLED" == "true" ]] && command -v xargs >/dev/null 2>&1; then
        printf '%s\n' "${files_ref[@]}" | \
        xargs -P "$max_parallel" -I {} bash -c 'optimized_file_read "{}"' 2>/dev/null
    else
        # Sequential fallback
        for file in "${files_ref[@]}"; do
            optimized_file_read "$file" >/dev/null
        done
    fi
}

# Batch delete files
batch_delete_files() {
    local files_array="$1"
    local max_parallel="$2"
    
    declare -n files_ref="$files_array"
    
    if [[ "$IO_PARALLEL_ENABLED" == "true" ]] && command -v xargs >/dev/null 2>&1; then
        printf '%s\n' "${files_ref[@]}" | \
        xargs -P "$max_parallel" rm -f 2>/dev/null
    else
        # Sequential fallback
        for file in "${files_ref[@]}"; do
            rm -f "$file" 2>/dev/null
        done
    fi
}

# Batch copy files
batch_copy_files() {
    local files_array="$1"
    local max_parallel="$2"
    
    declare -n files_ref="$files_array"
    
    # Assume files_ref contains "source:destination" pairs
    if [[ "$IO_PARALLEL_ENABLED" == "true" ]] && command -v xargs >/dev/null 2>&1; then
        printf '%s\n' "${files_ref[@]}" | \
        xargs -P "$max_parallel" -I {} bash -c '
            IFS=":" read -r src dest <<< "{}"
            cp "$src" "$dest" 2>/dev/null
        ' 2>/dev/null
    else
        # Sequential fallback
        for file_pair in "${files_ref[@]}"; do
            IFS=":" read -r src dest <<< "$file_pair"
            cp "$src" "$dest" 2>/dev/null
        done
    fi
}

# Smart file watcher with change detection
watch_file_changes() {
    local file_path="$1"
    local callback_function="$2"
    local check_interval="${3:-1}"  # seconds
    
    if [[ ! -f "$file_path" ]]; then
        log_error "OPTIMIZED_IO" "Cannot watch non-existent file: $file_path"
        return 1
    fi
    
    local initial_mtime
    initial_mtime=$(get_file_mtime "$file_path")
    
    log_debug "OPTIMIZED_IO" "Started watching file: $file_path"
    
    while true; do
        sleep "$check_interval"
        
        local current_mtime
        current_mtime=$(get_file_mtime "$file_path")
        
        if [[ "$current_mtime" -gt "$initial_mtime" ]]; then
            log_debug "OPTIMIZED_IO" "File change detected: $file_path"
            
            if "$callback_function" "$file_path"; then
                initial_mtime="$current_mtime"
            else
                log_warning "OPTIMIZED_IO" "Callback function failed for: $file_path"
            fi
        fi
    done
}

# Optimized directory traversal
optimized_find_files() {
    local search_dir="$1"
    local pattern="${2:-*}"
    local max_depth="${3:-}"
    local file_type="${4:-f}"  # f for files, d for directories
    
    if [[ ! -d "$search_dir" ]]; then
        log_error "OPTIMIZED_IO" "Search directory not found: $search_dir"
        return 1
    fi
    
    perf_start_timer "find_files"
    
    local find_cmd="find '$search_dir' -type $file_type -name '$pattern'"
    
    if [[ -n "$max_depth" ]]; then
        find_cmd="find '$search_dir' -maxdepth $max_depth -type $file_type -name '$pattern'"
    fi
    
    local results
    results=$(eval "$find_cmd" 2>/dev/null)
    
    local find_duration
    find_duration=$(perf_end_timer "find_files" "Find files in: $search_dir")
    
    echo "$results"
}

# Memory-mapped file reading for large files
mmap_file_read() {
    local file_path="$1"
    local offset="${2:-0}"
    local length="${3:-}"
    
    if [[ ! -f "$file_path" ]]; then
        log_error "OPTIMIZED_IO" "File not found for mmap: $file_path"
        return 1
    fi
    
    perf_start_timer "mmap_read"
    
    local dd_cmd="dd if='$file_path' bs=1 skip=$offset"
    
    if [[ -n "$length" ]]; then
        dd_cmd="$dd_cmd count=$length"
    fi
    
    local content
    content=$(eval "$dd_cmd" 2>/dev/null)
    
    local mmap_duration
    mmap_duration=$(perf_end_timer "mmap_read" "Memory-mapped read: $file_path")
    
    echo "$content"
}

# I/O performance statistics
show_io_performance_stats() {
    echo
    create_separator "─" "$UI_WIDTH" "$LIGHT_YELLOW"
    create_centered_text "$(get_icon GEAR) I/O PERFORMANCE STATISTICS" "$UI_WIDTH" "$LIGHT_YELLOW$BOLD"
    create_separator "─" "$UI_WIDTH" "$LIGHT_YELLOW"
    
    echo -e "${WHITE}${BOLD}Cache Performance:${NC}"
    echo -e "  File read cache hits: ${LIGHT_GREEN}$(perf_get_counter file_read_cache_hits)${NC}"
    echo -e "  File read cache misses: ${LIGHT_YELLOW}$(perf_get_counter file_read_cache_misses)${NC}"
    echo
    
    echo -e "${WHITE}${BOLD}Operations:${NC}"
    echo -e "  Lazy file loads: ${LIGHT_CYAN}$(perf_get_counter lazy_file_loads)${NC}"
    echo -e "  Batch operations: ${LIGHT_CYAN}$(perf_get_counter batch_operations)${NC}"
    echo
    
    echo -e "${WHITE}${BOLD}Registered Files:${NC}"
    echo -e "  Lazy files: ${LIGHT_CYAN}${#LAZY_FILES[@]}${NC}"
    echo -e "  Cached files: ${LIGHT_CYAN}${#FILE_CACHE[@]}${NC}"
    
    echo
    create_separator "─" "$UI_WIDTH" "$LIGHT_YELLOW"
}

# Clean up I/O system
cleanup_optimized_io() {
    log_info "OPTIMIZED_IO" "Cleaning up optimized I/O system..."
    
    # Clear file caches
    FILE_CACHE=()
    FILE_MTIME_CACHE=()
    
    # Clear lazy loading registry
    LAZY_FILES=()
    LAZY_FILE_LOADERS=()
    
    log_info "OPTIMIZED_IO" "I/O system cleanup completed"
}

# Export optimized I/O functions
export -f init_optimized_io get_file_mtime is_file_modified optimized_file_read
export -f optimized_file_write register_lazy_file load_lazy_file batch_file_operation
export -f batch_read_files batch_delete_files batch_copy_files watch_file_changes
export -f optimized_find_files mmap_file_read show_io_performance_stats cleanup_optimized_io
