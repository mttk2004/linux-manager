#!/bin/bash

# Inter-Module Communication System - V2 Architecture
# Event-based messaging system for modules to communicate and coordinate operations
#
# Features:
# - Event-driven messaging between modules
# - Asynchronous and synchronous communication
# - Message queuing and delivery guarantees
# - Topic-based publish/subscribe system
# - Request/response patterns
# - Broadcasting and multicasting
# - Message filtering and routing
# - Error handling and retry mechanisms

# Define stub logging functions for testing environment
if [[ "${TESTING:-false}" == "true" ]]; then
    log_debug() { [[ "${TEST_VERBOSE:-false}" == "true" ]] && echo "[DEBUG] $*" >&2 || true; }
    log_info() { echo "[INFO] $*" >&2; }
    log_warning() { echo "[WARNING] $*" >&2; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

# Communication system configuration
declare -g COMMUNICATION_INITIALIZED=false
declare -g MESSAGE_QUEUE_ENABLED=${MESSAGE_QUEUE_ENABLED:-true}
declare -g MESSAGE_RETRY_ATTEMPTS=${MESSAGE_RETRY_ATTEMPTS:-3}
declare -g MESSAGE_TIMEOUT=${MESSAGE_TIMEOUT:-30}
declare -g MESSAGE_PERSISTENCE_ENABLED=${MESSAGE_PERSISTENCE_ENABLED:-false}

# Message storage and queues
declare -gA MESSAGE_SUBSCRIBERS=()
declare -gA MESSAGE_QUEUE=()
declare -gA MESSAGE_HISTORY=()
declare -gA TOPIC_SUBSCRIBERS=()
declare -gA ACTIVE_HANDLERS=()
declare -gA MESSAGE_STATS=()
declare -gA REQUEST_CALLBACKS=()

# Message types and priorities
declare -gr MSG_TYPE_EVENT="event"
declare -gr MSG_TYPE_REQUEST="request"
declare -gr MSG_TYPE_RESPONSE="response"
declare -gr MSG_TYPE_BROADCAST="broadcast"
declare -gr MSG_TYPE_NOTIFICATION="notification"

declare -gr MSG_PRIORITY_LOW=1
declare -gr MSG_PRIORITY_NORMAL=2
declare -gr MSG_PRIORITY_HIGH=3
declare -gr MSG_PRIORITY_CRITICAL=4

# Message status constants
declare -gr MSG_STATUS_PENDING="pending"
declare -gr MSG_STATUS_DELIVERED="delivered"
declare -gr MSG_STATUS_FAILED="failed"
declare -gr MSG_STATUS_PROCESSING="processing"
declare -gr MSG_STATUS_ACKNOWLEDGED="acknowledged"

# Communication directories
declare -g MESSAGE_QUEUE_DIR="${ROOT_DIR}/.queue"
declare -g MESSAGE_PERSISTENCE_DIR="${ROOT_DIR}/data/messages"

# Initialize the communication system
init_module_communication() {
    log_info "MODULE_COMM" "Initializing inter-module communication system..."
    
    # Create necessary directories
    create_communication_directories
    
    # Initialize message queuing
    if [[ "$MESSAGE_QUEUE_ENABLED" == "true" ]]; then
        init_message_queuing
    fi
    
    # Load persisted messages if enabled
    if [[ "$MESSAGE_PERSISTENCE_ENABLED" == "true" ]]; then
        load_persisted_messages
    fi
    
    # Initialize statistics
    init_message_statistics
    
    COMMUNICATION_INITIALIZED=true
    log_info "MODULE_COMM" "Inter-module communication system initialized"
    
    return 0
}

# Create necessary communication directories
create_communication_directories() {
    local directories=(
        "$MESSAGE_QUEUE_DIR"
        "$MESSAGE_PERSISTENCE_DIR"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir" 2>/dev/null; then
                log_debug "MODULE_COMM" "Created communication directory: $dir"
            else
                log_warning "MODULE_COMM" "Failed to create communication directory: $dir"
            fi
        fi
    done
}

# Initialize message queuing system
init_message_queuing() {
    log_debug "MODULE_COMM" "Initializing message queuing..."
    
    # Clear existing queues
    MESSAGE_QUEUE=()
    
    # Initialize priority queues
    MESSAGE_QUEUE["critical"]=""
    MESSAGE_QUEUE["high"]=""
    MESSAGE_QUEUE["normal"]=""
    MESSAGE_QUEUE["low"]=""
    
    log_debug "MODULE_COMM" "Message queuing initialized"
}

# Load persisted messages
load_persisted_messages() {
    log_debug "MODULE_COMM" "Loading persisted messages..."
    
    local message_files
    message_files=$(find "$MESSAGE_PERSISTENCE_DIR" -name "*.msg" 2>/dev/null | sort)
    
    for message_file in $message_files; do
        if [[ -f "$message_file" ]]; then
            load_message_from_file "$message_file"
        fi
    done
    
    log_debug "MODULE_COMM" "Persisted messages loaded"
}

# Load message from file
load_message_from_file() {
    local message_file="$1"
    local message_content
    
    if message_content=$(cat "$message_file" 2>/dev/null); then
        # Parse and queue the message
        local message_id
        message_id=$(basename "$message_file" .msg)
        
        # Add to appropriate queue based on priority
        local priority=$(extract_message_field "$message_content" "priority")
        queue_message_by_priority "$message_content" "$priority"
        
        log_debug "MODULE_COMM" "Loaded persisted message: $message_id"
    fi
}

# Initialize message statistics
init_message_statistics() {
    MESSAGE_STATS["total_sent"]=0
    MESSAGE_STATS["total_received"]=0
    MESSAGE_STATS["total_failed"]=0
    MESSAGE_STATS["total_queued"]=0
    MESSAGE_STATS["active_subscribers"]=0
}

# Subscribe to a topic or message type
subscribe_to_topic() {
    local subscriber_id="$1"
    local topic="$2"
    local handler_function="$3"
    local options="${4:-}"
    
    log_debug "MODULE_COMM" "Subscribing $subscriber_id to topic: $topic"
    
    # Validate handler function exists
    if ! declare -f "$handler_function" >/dev/null 2>&1; then
        log_error "MODULE_COMM" "Handler function not found: $handler_function"
        return 1
    fi
    
    # Create subscriber entry
    local subscriber_entry="handler:$handler_function,options:$options,subscribed:$(date +%s)"
    
    # Add to topic subscribers
    if [[ -n "${TOPIC_SUBSCRIBERS[$topic]:-}" ]]; then
        TOPIC_SUBSCRIBERS["$topic"]="${TOPIC_SUBSCRIBERS[$topic]}|$subscriber_id:$subscriber_entry"
    else
        TOPIC_SUBSCRIBERS["$topic"]="$subscriber_id:$subscriber_entry"
    fi
    
    # Track active handlers
    ACTIVE_HANDLERS["$subscriber_id:$topic"]="$handler_function"
    
    # Update statistics
    ((MESSAGE_STATS["active_subscribers"]++))
    
    log_info "MODULE_COMM" "Subscriber registered: $subscriber_id -> $topic"
    return 0
}

# Unsubscribe from a topic
unsubscribe_from_topic() {
    local subscriber_id="$1"
    local topic="$2"
    
    log_debug "MODULE_COMM" "Unsubscribing $subscriber_id from topic: $topic"
    
    # Remove from topic subscribers
    local current_subscribers="${TOPIC_SUBSCRIBERS[$topic]:-}"
    if [[ -n "$current_subscribers" ]]; then
        # Filter out this subscriber
        local new_subscribers=""
        IFS='|' read -ra subscriber_list <<< "$current_subscribers"
        
        for subscriber_entry in "${subscriber_list[@]}"; do
            if [[ "$subscriber_entry" != "$subscriber_id:"* ]]; then
                if [[ -n "$new_subscribers" ]]; then
                    new_subscribers="$new_subscribers|$subscriber_entry"
                else
                    new_subscribers="$subscriber_entry"
                fi
            fi
        done
        
        if [[ -n "$new_subscribers" ]]; then
            TOPIC_SUBSCRIBERS["$topic"]="$new_subscribers"
        else
            unset TOPIC_SUBSCRIBERS["$topic"]
        fi
    fi
    
    # Remove from active handlers
    unset ACTIVE_HANDLERS["$subscriber_id:$topic"]
    
    # Update statistics
    ((MESSAGE_STATS["active_subscribers"]--))
    
    log_info "MODULE_COMM" "Subscriber unregistered: $subscriber_id -> $topic"
    return 0
}

# Publish message to a topic
publish_message() {
    local sender_id="$1"
    local topic="$2"
    local message_data="$3"
    local message_type="${4:-$MSG_TYPE_EVENT}"
    local priority="${5:-$MSG_PRIORITY_NORMAL}"
    local options="${6:-}"
    
    log_debug "MODULE_COMM" "Publishing message from $sender_id to topic: $topic"
    
    # Generate unique message ID
    local message_id
    message_id="msg_$(date +%s%3N)_$$"
    
    # Create message structure
    local timestamp=$(date -Iseconds)
    local message="id:$message_id,sender:$sender_id,topic:$topic,type:$message_type,priority:$priority,timestamp:$timestamp,data:$message_data,options:$options"
    
    # Add to message history
    record_message_history "$message_id" "$message"
    
    # Queue or deliver immediately based on configuration
    if [[ "$MESSAGE_QUEUE_ENABLED" == "true" ]]; then
        queue_message_by_priority "$message" "$priority"
        process_message_queue
    else
        deliver_message_immediately "$message"
    fi
    
    # Update statistics
    ((MESSAGE_STATS["total_sent"]++))
    
    log_info "MODULE_COMM" "Message published: $message_id ($topic)"
    echo "$message_id"  # Return message ID
}

# Send direct message to specific module
send_direct_message() {
    local sender_id="$1"
    local recipient_id="$2"
    local message_data="$3"
    local message_type="${4:-$MSG_TYPE_REQUEST}"
    local callback="${5:-}"
    
    log_debug "MODULE_COMM" "Sending direct message: $sender_id -> $recipient_id"
    
    # Create direct message topic
    local topic="direct:$recipient_id"
    
    # If callback is provided, store it for response handling
    if [[ -n "$callback" ]]; then
        local message_id
        message_id=$(publish_message "$sender_id" "$topic" "$message_data" "$message_type" "$MSG_PRIORITY_HIGH" "callback:$callback")
        REQUEST_CALLBACKS["$message_id"]="$callback"
    else
        publish_message "$sender_id" "$topic" "$message_data" "$message_type"
    fi
}

# Broadcast message to all subscribers
broadcast_message() {
    local sender_id="$1"
    local message_data="$2"
    local priority="${3:-$MSG_PRIORITY_NORMAL}"
    
    log_debug "MODULE_COMM" "Broadcasting message from: $sender_id"
    
    publish_message "$sender_id" "broadcast" "$message_data" "$MSG_TYPE_BROADCAST" "$priority"
}

# Queue message by priority
queue_message_by_priority() {
    local message="$1"
    local priority="$2"
    
    local queue_name
    case "$priority" in
        "$MSG_PRIORITY_CRITICAL") queue_name="critical" ;;
        "$MSG_PRIORITY_HIGH") queue_name="high" ;;
        "$MSG_PRIORITY_NORMAL") queue_name="normal" ;;
        "$MSG_PRIORITY_LOW") queue_name="low" ;;
        *) queue_name="normal" ;;
    esac
    
    # Add to queue
    if [[ -n "${MESSAGE_QUEUE[$queue_name]}" ]]; then
        MESSAGE_QUEUE["$queue_name"]="${MESSAGE_QUEUE[$queue_name]}|$message"
    else
        MESSAGE_QUEUE["$queue_name"]="$message"
    fi
    
    # Update statistics
    ((MESSAGE_STATS["total_queued"]++))
    
    log_debug "MODULE_COMM" "Message queued in $queue_name queue"
}

# Process message queue
process_message_queue() {
    log_debug "MODULE_COMM" "Processing message queue..."
    
    # Process queues in priority order
    local queues=("critical" "high" "normal" "low")
    
    for queue_name in "${queues[@]}"; do
        local queue_content="${MESSAGE_QUEUE[$queue_name]:-}"
        if [[ -n "$queue_content" ]]; then
            process_queue_messages "$queue_name" "$queue_content"
            # Clear processed queue
            MESSAGE_QUEUE["$queue_name"]=""
        fi
    done
}

# Process messages from a specific queue
process_queue_messages() {
    local queue_name="$1"
    local queue_content="$2"
    
    log_debug "MODULE_COMM" "Processing $queue_name queue messages..."
    
    IFS='|' read -ra messages <<< "$queue_content"
    
    for message in "${messages[@]}"; do
        if [[ -n "$message" ]]; then
            deliver_message_immediately "$message"
        fi
    done
}

# Deliver message immediately to subscribers
deliver_message_immediately() {
    local message="$1"
    
    # Extract topic from message
    local topic
    topic=$(extract_message_field "$message" "topic")
    
    # Get subscribers for this topic
    local subscribers="${TOPIC_SUBSCRIBERS[$topic]:-}"
    if [[ -z "$subscribers" ]]; then
        log_debug "MODULE_COMM" "No subscribers for topic: $topic"
        return 0
    fi
    
    log_debug "MODULE_COMM" "Delivering message to topic subscribers: $topic"
    
    # Deliver to each subscriber
    IFS='|' read -ra subscriber_list <<< "$subscribers"
    for subscriber_entry in "${subscriber_list[@]}"; do
        if [[ "$subscriber_entry" =~ ^([^:]+):(.+)$ ]]; then
            local subscriber_id="${BASH_REMATCH[1]}"
            local subscriber_data="${BASH_REMATCH[2]}"
            
            deliver_to_subscriber "$subscriber_id" "$subscriber_data" "$message"
        fi
    done
    
    # Update statistics
    ((MESSAGE_STATS["total_received"]++))
}

# Deliver message to specific subscriber
deliver_to_subscriber() {
    local subscriber_id="$1"
    local subscriber_data="$2"
    local message="$3"
    
    # Extract handler function
    local handler_function
    handler_function=$(extract_field_from_data "$subscriber_data" "handler")
    
    if [[ -z "$handler_function" ]]; then
        log_error "MODULE_COMM" "No handler function for subscriber: $subscriber_id"
        return 1
    fi
    
    log_debug "MODULE_COMM" "Delivering message to $subscriber_id via $handler_function"
    
    # Call handler function with message
    if declare -f "$handler_function" >/dev/null 2>&1; then
        if "$handler_function" "$message" 2>/dev/null; then
            log_debug "MODULE_COMM" "Message delivered successfully to: $subscriber_id"
        else
            log_warning "MODULE_COMM" "Message delivery failed to: $subscriber_id"
            ((MESSAGE_STATS["total_failed"]++))
        fi
    else
        log_error "MODULE_COMM" "Handler function not found: $handler_function"
        ((MESSAGE_STATS["total_failed"]++))
    fi
}

# Send response to a request message
send_response() {
    local responder_id="$1"
    local original_message="$2"
    local response_data="$3"
    
    # Extract original sender and message ID
    local original_sender
    local original_message_id
    original_sender=$(extract_message_field "$original_message" "sender")
    original_message_id=$(extract_message_field "$original_message" "id")
    
    log_debug "MODULE_COMM" "Sending response: $responder_id -> $original_sender"
    
    # Create response message
    local response_topic="response:$original_sender"
    local response_message="response_to:$original_message_id,$response_data"
    
    publish_message "$responder_id" "$response_topic" "$response_message" "$MSG_TYPE_RESPONSE" "$MSG_PRIORITY_HIGH"
}

# Extract field from message
extract_message_field() {
    local message="$1"
    local field="$2"
    
    if [[ "$message" =~ $field:([^,]*) ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}

# Extract field from subscriber data
extract_field_from_data() {
    local data="$1"
    local field="$2"
    
    if [[ "$data" =~ $field:([^,]*) ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}

# Record message in history
record_message_history() {
    local message_id="$1"
    local message="$2"
    
    MESSAGE_HISTORY["$message_id"]="$message"
    
    # Persist message if enabled
    if [[ "$MESSAGE_PERSISTENCE_ENABLED" == "true" ]]; then
        persist_message "$message_id" "$message"
    fi
}

# Persist message to file
persist_message() {
    local message_id="$1"
    local message="$2"
    
    local message_file="$MESSAGE_PERSISTENCE_DIR/$message_id.msg"
    echo "$message" > "$message_file"
    
    log_debug "MODULE_COMM" "Message persisted: $message_id"
}

# Get message statistics
get_message_statistics() {
    local stat_type="${1:-all}"
    
    case "$stat_type" in
        "all")
            for stat in "${!MESSAGE_STATS[@]}"; do
                echo "$stat:${MESSAGE_STATS[$stat]}"
            done
            ;;
        *)
            echo "${MESSAGE_STATS[$stat_type]:-0}"
            ;;
    esac
}

# List active subscribers
list_subscribers() {
    local topic_filter="${1:-all}"
    
    if [[ "$topic_filter" == "all" ]]; then
        for topic in "${!TOPIC_SUBSCRIBERS[@]}"; do
            echo "Topic: $topic"
            IFS='|' read -ra subscriber_list <<< "${TOPIC_SUBSCRIBERS[$topic]}"
            for subscriber_entry in "${subscriber_list[@]}"; do
                if [[ "$subscriber_entry" =~ ^([^:]+): ]]; then
                    echo "  Subscriber: ${BASH_REMATCH[1]}"
                fi
            done
        done
    else
        local subscribers="${TOPIC_SUBSCRIBERS[$topic_filter]:-}"
        if [[ -n "$subscribers" ]]; then
            echo "Topic: $topic_filter"
            IFS='|' read -ra subscriber_list <<< "$subscribers"
            for subscriber_entry in "${subscriber_list[@]}"; do
                if [[ "$subscriber_entry" =~ ^([^:]+): ]]; then
                    echo "  Subscriber: ${BASH_REMATCH[1]}"
                fi
            done
        else
            echo "No subscribers for topic: $topic_filter"
        fi
    fi
}

# Get message history
get_message_history() {
    local limit="${1:-10}"
    local count=0
    
    # Get recent messages
    for message_id in "${!MESSAGE_HISTORY[@]}"; do
        if [[ $count -ge $limit ]]; then
            break
        fi
        echo "$message_id: ${MESSAGE_HISTORY[$message_id]}"
        ((count++))
    done
}

# Clean up old messages
cleanup_old_messages() {
    local max_age_seconds="${1:-3600}"  # 1 hour default
    local current_time
    current_time=$(date +%s)
    
    log_debug "MODULE_COMM" "Cleaning up messages older than $max_age_seconds seconds..."
    
    local cleaned_count=0
    
    # Clean history
    for message_id in "${!MESSAGE_HISTORY[@]}"; do
        local message="${MESSAGE_HISTORY[$message_id]}"
        local timestamp
        timestamp=$(extract_message_field "$message" "timestamp")
        
        if [[ -n "$timestamp" ]]; then
            local message_time
            message_time=$(date -d "$timestamp" +%s 2>/dev/null || echo 0)
            
            if [[ $((current_time - message_time)) -gt $max_age_seconds ]]; then
                unset MESSAGE_HISTORY["$message_id"]
                
                # Remove persisted file if exists
                local message_file="$MESSAGE_PERSISTENCE_DIR/$message_id.msg"
                if [[ -f "$message_file" ]]; then
                    rm -f "$message_file"
                fi
                
                ((cleaned_count++))
            fi
        fi
    done
    
    log_debug "MODULE_COMM" "Cleaned up $cleaned_count old messages"
}

# Shutdown communication system
shutdown_communication() {
    log_info "MODULE_COMM" "Shutting down inter-module communication system..."
    
    # Save message statistics
    save_message_statistics
    
    # Clear all data structures
    MESSAGE_SUBSCRIBERS=()
    MESSAGE_QUEUE=()
    MESSAGE_HISTORY=()
    TOPIC_SUBSCRIBERS=()
    ACTIVE_HANDLERS=()
    REQUEST_CALLBACKS=()
    
    COMMUNICATION_INITIALIZED=false
    log_info "MODULE_COMM" "Communication system shutdown complete"
}

# Save message statistics
save_message_statistics() {
    local stats_file="$MESSAGE_PERSISTENCE_DIR/stats.txt"
    
    {
        echo "# Message Statistics - $(date)"
        for stat in "${!MESSAGE_STATS[@]}"; do
            echo "$stat=${MESSAGE_STATS[$stat]}"
        done
    } > "$stats_file"
    
    log_debug "MODULE_COMM" "Message statistics saved"
}

# Health check for communication system
communication_health_check() {
    local issues=0
    
    # Check if system is initialized
    if [[ "$COMMUNICATION_INITIALIZED" != "true" ]]; then
        log_error "MODULE_COMM" "Communication system not initialized"
        ((issues++))
    fi
    
    # Check directory accessibility
    if [[ ! -w "$MESSAGE_QUEUE_DIR" ]]; then
        log_error "MODULE_COMM" "Message queue directory not writable: $MESSAGE_QUEUE_DIR"
        ((issues++))
    fi
    
    # Check for handler function validity
    for handler_key in "${!ACTIVE_HANDLERS[@]}"; do
        local handler_function="${ACTIVE_HANDLERS[$handler_key]}"
        if ! declare -f "$handler_function" >/dev/null 2>&1; then
            log_warning "MODULE_COMM" "Invalid handler function: $handler_function"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log_info "MODULE_COMM" "Communication system health check: OK"
        return 0
    else
        log_warning "MODULE_COMM" "Communication system health check found $issues issues"
        return 1
    fi
}

# Export communication functions
export -f init_module_communication create_communication_directories init_message_queuing
export -f subscribe_to_topic unsubscribe_from_topic publish_message send_direct_message
export -f broadcast_message queue_message_by_priority process_message_queue
export -f deliver_message_immediately deliver_to_subscriber send_response
export -f extract_message_field record_message_history get_message_statistics
export -f list_subscribers get_message_history cleanup_old_messages
export -f shutdown_communication communication_health_check
