#!/bin/bash

# Package Information Cache System - V2 Architecture
# Optimizes package manager operations through intelligent caching

# Package cache configuration
PACKAGE_CACHE_ENABLED=${PACKAGE_CACHE_ENABLED:-true}
PACKAGE_CACHE_TTL=${PACKAGE_CACHE_TTL:-1800}  # 30 minutes for package info
PACKAGE_SEARCH_CACHE_TTL=${PACKAGE_SEARCH_CACHE_TTL:-600}  # 10 minutes for searches
PACKAGE_UPDATE_CACHE_TTL=${PACKAGE_UPDATE_CACHE_TTL:-3600}  # 1 hour for update info

# Package manager detection cache
declare -A PACKAGE_MANAGER_CACHE=()

# Initialize package cache system
init_package_cache() {
    if [[ "$PACKAGE_CACHE_ENABLED" != "true" ]]; then
        return 0
    fi
    
    log_debug "PACKAGE_CACHE" "Initializing package cache system..."
    
    # Detect and cache package managers
    detect_package_managers
    
    log_info "PACKAGE_CACHE" "Package cache system initialized"
}

# Detect available package managers and cache results
detect_package_managers() {
    local cache_key="package_managers_available"
    
    # Try to get from cache first
    if cache_exists "$cache_key"; then
        local cached_result
        cached_result=$(cache_get "$cache_key")
        
        # Parse cached result back into array
        IFS=' ' read -ra PACKAGE_MANAGER_CACHE <<< "$cached_result"
        log_debug "PACKAGE_CACHE" "Loaded package managers from cache: ${PACKAGE_MANAGER_CACHE[*]}"
        return 0
    fi
    
    log_debug "PACKAGE_CACHE" "Detecting package managers..."
    PACKAGE_MANAGER_CACHE=()
    
    # Check for Pacman (official Arch repository)
    if command -v pacman >/dev/null 2>&1; then
        PACKAGE_MANAGER_CACHE+=("pacman")
    fi
    
    # Check for AUR helpers
    for aur_helper in yay paru trizen pikaur pakku; do
        if command -v "$aur_helper" >/dev/null 2>&1; then
            PACKAGE_MANAGER_CACHE+=("$aur_helper")
            break  # Only cache the first available AUR helper
        fi
    done
    
    # Check for Flatpak
    if command -v flatpak >/dev/null 2>&1; then
        PACKAGE_MANAGER_CACHE+=("flatpak")
    fi
    
    # Check for Snap
    if command -v snap >/dev/null 2>&1; then
        PACKAGE_MANAGER_CACHE+=("snap")
    fi
    
    # Cache the results
    cache_set "$cache_key" "${PACKAGE_MANAGER_CACHE[*]}" "$PACKAGE_CACHE_TTL"
    
    log_info "PACKAGE_CACHE" "Detected package managers: ${PACKAGE_MANAGER_CACHE[*]}"
}

# Get cached package managers
get_available_package_managers() {
    if [[ ${#PACKAGE_MANAGER_CACHE[@]} -eq 0 ]]; then
        detect_package_managers
    fi
    
    printf '%s\n' "${PACKAGE_MANAGER_CACHE[@]}"
}

# Check if specific package manager is available
has_package_manager() {
    local pm_name="$1"
    
    if [[ ${#PACKAGE_MANAGER_CACHE[@]} -eq 0 ]]; then
        detect_package_managers
    fi
    
    for pm in "${PACKAGE_MANAGER_CACHE[@]}"; do
        if [[ "$pm" == "$pm_name" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Cached package search
cached_package_search() {
    local package_manager="$1"
    local search_term="$2"
    local cache_key="search_${package_manager}_${search_term}"
    
    # Try cache first
    if cache_exists "$cache_key"; then
        cache_get "$cache_key"
        perf_increment_counter "package_search_cache_hits"
        return 0
    fi
    
    perf_start_timer "package_search_${package_manager}"
    
    local search_result exit_code
    case "$package_manager" in
        "pacman")
            search_result=$(pacman -Ss "$search_term" 2>/dev/null || echo "")
            exit_code=$?
            ;;
        "yay"|"paru")
            search_result=$($package_manager -Ss "$search_term" 2>/dev/null || echo "")
            exit_code=$?
            ;;
        "flatpak")
            search_result=$(flatpak search "$search_term" 2>/dev/null || echo "")
            exit_code=$?
            ;;
        *)
            log_error "PACKAGE_CACHE" "Unsupported package manager: $package_manager"
            return 1
            ;;
    esac
    
    local duration
    duration=$(perf_end_timer "package_search_${package_manager}" "Package search: $search_term")
    
    if [[ $exit_code -eq 0 && -n "$search_result" ]]; then
        cache_set "$cache_key" "$search_result" "$PACKAGE_SEARCH_CACHE_TTL"
        log_debug "PACKAGE_CACHE" "Cached search results for: $search_term (${#search_result} chars)"
    fi
    
    perf_increment_counter "package_search_cache_misses"
    echo "$search_result"
    return $exit_code
}

# Cached package information
cached_package_info() {
    local package_manager="$1"
    local package_name="$2"
    local cache_key="info_${package_manager}_${package_name}"
    
    # Try cache first
    if cache_exists "$cache_key"; then
        cache_get "$cache_key"
        perf_increment_counter "package_info_cache_hits"
        return 0
    fi
    
    perf_start_timer "package_info_${package_manager}"
    
    local info_result exit_code
    case "$package_manager" in
        "pacman")
            info_result=$(pacman -Qi "$package_name" 2>/dev/null || pacman -Si "$package_name" 2>/dev/null || echo "")
            exit_code=$?
            ;;
        "yay"|"paru")
            info_result=$($package_manager -Si "$package_name" 2>/dev/null || echo "")
            exit_code=$?
            ;;
        "flatpak")
            info_result=$(flatpak info "$package_name" 2>/dev/null || echo "")
            exit_code=$?
            ;;
        *)
            log_error "PACKAGE_CACHE" "Unsupported package manager: $package_manager"
            return 1
            ;;
    esac
    
    local duration
    duration=$(perf_end_timer "package_info_${package_manager}" "Package info: $package_name")
    
    if [[ $exit_code -eq 0 && -n "$info_result" ]]; then
        cache_set "$cache_key" "$info_result" "$PACKAGE_CACHE_TTL"
        log_debug "PACKAGE_CACHE" "Cached package info for: $package_name"
    fi
    
    perf_increment_counter "package_info_cache_misses"
    echo "$info_result"
    return $exit_code
}

# Cached installed packages list
cached_installed_packages() {
    local package_manager="$1"
    local cache_key="installed_${package_manager}"
    
    # Try cache first  
    if cache_exists "$cache_key"; then
        cache_get "$cache_key"
        perf_increment_counter "installed_packages_cache_hits"
        return 0
    fi
    
    perf_start_timer "installed_packages_${package_manager}"
    
    local packages_result exit_code
    case "$package_manager" in
        "pacman")
            packages_result=$(pacman -Q 2>/dev/null || echo "")
            exit_code=$?
            ;;
        "flatpak")
            packages_result=$(flatpak list --app 2>/dev/null || echo "")
            exit_code=$?
            ;;
        *)
            log_error "PACKAGE_CACHE" "Unsupported package manager for installed list: $package_manager"
            return 1
            ;;
    esac
    
    local duration
    duration=$(perf_end_timer "installed_packages_${package_manager}" "Installed packages list")
    
    if [[ $exit_code -eq 0 ]]; then
        cache_set "$cache_key" "$packages_result" "$PACKAGE_CACHE_TTL"
        log_debug "PACKAGE_CACHE" "Cached installed packages for: $package_manager"
    fi
    
    perf_increment_counter "installed_packages_cache_misses"
    echo "$packages_result"
    return $exit_code
}

# Cached orphaned packages detection
cached_orphaned_packages() {
    local cache_key="orphaned_packages_pacman"
    
    # Try cache first
    if cache_exists "$cache_key"; then
        cache_get "$cache_key"
        perf_increment_counter "orphaned_packages_cache_hits"
        return 0
    fi
    
    perf_start_timer "orphaned_packages_detection"
    
    local orphaned_result exit_code
    orphaned_result=$(pacman -Qtdq 2>/dev/null || echo "")
    exit_code=$?
    
    local duration
    duration=$(perf_end_timer "orphaned_packages_detection" "Orphaned packages detection")
    
    if [[ $exit_code -eq 0 ]]; then
        # Use shorter TTL for dynamic data like orphaned packages
        cache_set "$cache_key" "$orphaned_result" "$PACKAGE_SEARCH_CACHE_TTL"
        log_debug "PACKAGE_CACHE" "Cached orphaned packages list"
    fi
    
    perf_increment_counter "orphaned_packages_cache_misses"
    echo "$orphaned_result"
    return $exit_code
}

# Cached foreign packages (AUR) detection
cached_foreign_packages() {
    local cache_key="foreign_packages_pacman"
    
    # Try cache first
    if cache_exists "$cache_key"; then
        cache_get "$cache_key"
        perf_increment_counter "foreign_packages_cache_hits"
        return 0
    fi
    
    perf_start_timer "foreign_packages_detection"
    
    local foreign_result exit_code
    foreign_result=$(pacman -Qmq 2>/dev/null || echo "")
    exit_code=$?
    
    local duration
    duration=$(perf_end_timer "foreign_packages_detection" "Foreign packages detection")
    
    if [[ $exit_code -eq 0 ]]; then
        cache_set "$cache_key" "$foreign_result" "$PACKAGE_CACHE_TTL"
        log_debug "PACKAGE_CACHE" "Cached foreign packages list"
    fi
    
    perf_increment_counter "foreign_packages_cache_misses"
    echo "$foreign_result"
    return $exit_code
}

# Cached system updates check
cached_system_updates() {
    local package_manager="$1"
    local cache_key="system_updates_${package_manager}"
    
    # Try cache first
    if cache_exists "$cache_key"; then
        cache_get "$cache_key"
        perf_increment_counter "system_updates_cache_hits"
        return 0
    fi
    
    perf_start_timer "system_updates_${package_manager}"
    
    local updates_result exit_code
    case "$package_manager" in
        "pacman")
            updates_result=$(checkupdates 2>/dev/null || echo "")
            exit_code=$?
            ;;
        "yay"|"paru")
            updates_result=$($package_manager -Qua 2>/dev/null || echo "")
            exit_code=$?
            ;;
        *)
            log_error "PACKAGE_CACHE" "Unsupported package manager for updates: $package_manager"
            return 1
            ;;
    esac
    
    local duration
    duration=$(perf_end_timer "system_updates_${package_manager}" "System updates check")
    
    if [[ $exit_code -eq 0 ]]; then
        cache_set "$cache_key" "$updates_result" "$PACKAGE_UPDATE_CACHE_TTL"
        log_debug "PACKAGE_CACHE" "Cached system updates for: $package_manager"
    fi
    
    perf_increment_counter "system_updates_cache_misses"
    echo "$updates_result"
    return $exit_code
}

# Get package installation size (cached)
cached_package_size() {
    local package_manager="$1"
    local package_name="$2"
    local cache_key="size_${package_manager}_${package_name}"
    
    # Try cache first
    if cache_exists "$cache_key"; then
        cache_get "$cache_key"
        return 0
    fi
    
    local size_result
    case "$package_manager" in
        "pacman")
            size_result=$(pacman -Si "$package_name" 2>/dev/null | grep -E "^(Download|Installed) Size" | head -1 | awk '{print $4 " " $5}' || echo "Unknown")
            ;;
        *)
            size_result="Unknown"
            ;;
    esac
    
    cache_set "$cache_key" "$size_result" "$PACKAGE_CACHE_TTL"
    echo "$size_result"
}

# Invalidate package cache on installation/removal
invalidate_package_cache() {
    local package_name="${1:-}"
    local operation="${2:-install}"  # install, remove, upgrade
    
    if [[ "$PACKAGE_CACHE_ENABLED" != "true" ]]; then
        return 0
    fi
    
    log_debug "PACKAGE_CACHE" "Invalidating cache for operation: $operation"
    
    # Clear installed packages cache
    cache_clear "installed_pacman"
    cache_clear "installed_flatpak"
    
    # Clear orphaned and foreign packages cache
    cache_clear "orphaned_packages_pacman"
    cache_clear "foreign_packages_pacman"
    
    # Clear system updates cache
    cache_clear "system_updates_pacman"
    cache_clear "system_updates_yay"
    cache_clear "system_updates_paru"
    
    # Clear specific package info if provided
    if [[ -n "$package_name" ]]; then
        cache_clear "info_pacman_${package_name}"
        cache_clear "info_yay_${package_name}"
        cache_clear "info_flatpak_${package_name}"
        cache_clear "size_pacman_${package_name}"
    fi
    
    log_info "PACKAGE_CACHE" "Package cache invalidated for operation: $operation"
}

# Clear all package-related cache
clear_package_cache() {
    if [[ "$PACKAGE_CACHE_ENABLED" != "true" ]]; then
        return 0
    fi
    
    log_info "PACKAGE_CACHE" "Clearing all package cache..."
    
    # Clear package manager detection cache
    cache_clear "package_managers_available"
    PACKAGE_MANAGER_CACHE=()
    
    # Clear all cached package information
    if [[ -d "$CACHE_DIR" ]]; then
        find "$CACHE_DIR" -name "*search_*" -o -name "*info_*" -o -name "*installed_*" -o -name "*orphaned_*" -o -name "*foreign_*" -o -name "*updates_*" -o -name "*size_*" | while read -r cache_file; do
            rm -f "$cache_file" 2>/dev/null
        done
    fi
    
    log_info "PACKAGE_CACHE" "Package cache cleared"
}

# Package cache statistics
show_package_cache_stats() {
    if [[ "$PACKAGE_CACHE_ENABLED" != "true" ]]; then
        echo "Package cache is disabled"
        return 0
    fi
    
    echo
    create_separator "─" "$UI_WIDTH" "$LIGHT_CYAN"
    create_centered_text "$(get_icon INFO) PACKAGE CACHE STATISTICS" "$UI_WIDTH" "$LIGHT_CYAN$BOLD"
    create_separator "─" "$UI_WIDTH" "$LIGHT_CYAN"
    
    echo -e "${WHITE}${BOLD}Available Package Managers:${NC} ${LIGHT_GREEN}${PACKAGE_MANAGER_CACHE[*]}${NC}"
    echo
    
    # Cache hit statistics
    echo -e "${WHITE}${BOLD}Cache Performance:${NC}"
    echo -e "  Search hits: ${LIGHT_GREEN}$(perf_get_counter package_search_cache_hits)${NC}"
    echo -e "  Search misses: ${LIGHT_YELLOW}$(perf_get_counter package_search_cache_misses)${NC}"
    echo -e "  Info hits: ${LIGHT_GREEN}$(perf_get_counter package_info_cache_hits)${NC}"
    echo -e "  Info misses: ${LIGHT_YELLOW}$(perf_get_counter package_info_cache_misses)${NC}"
    echo -e "  Installed lists hits: ${LIGHT_GREEN}$(perf_get_counter installed_packages_cache_hits)${NC}"
    echo -e "  Installed lists misses: ${LIGHT_YELLOW}$(perf_get_counter installed_packages_cache_misses)${NC}"
    
    echo
    create_separator "─" "$UI_WIDTH" "$LIGHT_CYAN"
}

# Export package cache functions
export -f init_package_cache detect_package_managers get_available_package_managers
export -f has_package_manager cached_package_search cached_package_info
export -f cached_installed_packages cached_orphaned_packages cached_foreign_packages
export -f cached_system_updates cached_package_size invalidate_package_cache
export -f clear_package_cache show_package_cache_stats
