#!/bin/bash

# LLM Launch - Universal AI Models Management Hub
# A comprehensive launcher for Ollama, OpenWebUI, and LM Studio
# GitHub: https://github.com/[your-username]/llm-launch-kit
# License: MIT

# ============================================================================
# CONFIGURATION - EDIT THESE VARIABLES FOR YOUR SETUP
# ============================================================================

# External drive configuration (change these to match your setup)
EXTERNAL_DRIVE_NAME="YOUR-EXTERNAL-DRIVE"  # e.g., "ROCKET-nano", "AI-Models-SSD", etc.
EXTERNAL_DRIVE="/Volumes/$EXTERNAL_DRIVE_NAME"
MODELS_DIR="$EXTERNAL_DRIVE/AI-Models"
OLLAMA_MODELS_DIR="$MODELS_DIR/ollama-models"
LMSTUDIO_MODELS_DIR="$MODELS_DIR/lm-studio-models"

# OpenWebUI configuration
OPENWEBUI_PORT="8080"  # Change if you prefer different port
OPENWEBUI_CONTAINER_NAME="open-webui"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ============================================================================
# FUNCTIONS - DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU'RE DOING
# ============================================================================

# Function to print colored output
print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print header
print_header() {
    clear
    print_colored $CYAN "╔════════════════════════════════════════╗"
    print_colored $CYAN "║           🚀 LLM LAUNCHER 🚀           ║"
    print_colored $CYAN "║    Universal AI Models Manager        ║"
    print_colored $CYAN "╚════════════════════════════════════════╝"
    echo ""
}

# Function to check external drive
check_external_drive() {
    print_colored $BLUE "🔍 Checking external drive ($EXTERNAL_DRIVE_NAME)..."
    
    if [ ! -d "$EXTERNAL_DRIVE" ]; then
        print_colored $RED "❌ External drive ($EXTERNAL_DRIVE_NAME) not found!"
        print_colored $YELLOW "📋 Please:"
        echo "   1. Connect your $EXTERNAL_DRIVE_NAME external drive"
        echo "   2. Wait for it to mount"
        echo "   3. Run this script again"
        echo ""
        print_colored $CYAN "💡 If your drive has a different name:"
        print_colored $CYAN "   Edit this script and change EXTERNAL_DRIVE_NAME at the top"
        echo ""
        read -p "Press Enter to exit..." 
        exit 1
    fi
    
    if [ ! -d "$MODELS_DIR" ]; then
        print_colored $YELLOW "⚠️  Models directory not found on drive!"
        print_colored $CYAN "🔧 Creating directory structure..."
        mkdir -p "$OLLAMA_MODELS_DIR"
        mkdir -p "$LMSTUDIO_MODELS_DIR"
        mkdir -p "$MODELS_DIR/shared-converted"
        print_colored $GREEN "✅ Created: $MODELS_DIR"
    fi
    
    print_colored $GREEN "✅ External drive connected and models accessible"
    
    # Show drive space
    local space_info=$(df -h "$EXTERNAL_DRIVE" | tail -1 | awk '{print $4 " available (" $5 " used)"}')
    print_colored $CYAN "💾 Drive space: $space_info"
    echo ""
}

# Function to check model updates
check_model_updates() {
    print_colored $BLUE "📡 Checking for model updates..."
    
    # Check if ollama is available
    if ! command -v ollama >/dev/null 2>&1; then
        print_colored $YELLOW "⚠️  Ollama not in PATH - skipping update check"
        print_colored $CYAN "💡 Install Ollama from: https://ollama.com"
        return
    fi
    
    # Start ollama temporarily to check updates
    local ollama_was_running=false
    if pgrep -x ollama >/dev/null; then
        ollama_was_running=true
    else
        print_colored $CYAN "🔄 Starting Ollama temporarily for update check..."
        export OLLAMA_MODELS="$OLLAMA_MODELS_DIR"
        ollama serve >/dev/null 2>&1 &
        local ollama_pid=$!
        sleep 3
    fi
    
    # List current models and their dates
    print_colored $GREEN "📋 Current Ollama Models:"
    local models_info=$(ollama list 2>/dev/null | tail -n +2)
    if [ -n "$models_info" ]; then
        echo "$models_info" | while read -r line; do
            local name=$(echo "$line" | awk '{print $1}')
            local size=$(echo "$line" | awk '{print $3}')
            local modified=$(echo "$line" | awk '{print $4" "$5" "$6}')
            print_colored $WHITE "   • $name ($size) - Modified: $modified"
        done
        
        # Check for models older than 30 days
        local old_models=$(echo "$models_info" | awk '$5 ~ /months?/ && $4 > 1 {print $1}' 2>/dev/null || true)
        if [ -n "$old_models" ]; then
            echo ""
            print_colored $YELLOW "⏰ Models that might need updates (>1 month old):"
            echo "$old_models" | while read -r model; do
                if [ -n "$model" ]; then
                    print_colored $YELLOW "   • $model"
                fi
            done
        else
            print_colored $GREEN "✅ All models appear recent"
        fi
    else
        print_colored $YELLOW "⚠️  No models found or Ollama not responding"
    fi
    
    # Stop temporary ollama if we started it
    if [ "$ollama_was_running" = false ] && [ -n "$ollama_pid" ]; then
        kill $ollama_pid 2>/dev/null || true
        sleep 1
    fi
    
    echo ""
}

# Function to show launch menu
show_launch_menu() {
    print_colored $PURPLE "🎯 What would you like to launch?"
    echo ""
    print_colored $WHITE "1️⃣  Ollama Only"
    print_colored $CYAN   "   • Start Ollama server"
    print_colored $CYAN   "   • Available for CLI use"
    print_colored $CYAN   "   • Uses: ~/.ollama/models → external drive"
    echo ""
    print_colored $WHITE "2️⃣  Ollama + OpenWebUI"
    print_colored $CYAN   "   • Start Ollama server"
    print_colored $CYAN   "   • Launch OpenWebUI Docker container"
    print_colored $CYAN   "   • Full web interface at http://localhost:$OPENWEBUI_PORT"
    echo ""
    print_colored $WHITE "3️⃣  LM Studio"
    print_colored $CYAN   "   • Launch LM Studio app"
    print_colored $CYAN   "   • GUI model management"
    print_colored $CYAN   "   • Uses: ~/.cache/lm-studio/models → external drive"
    echo ""
    print_colored $WHITE "4️⃣  Update Models"
    print_colored $CYAN   "   • Interactive model update menu"
    print_colored $CYAN   "   • Update specific or all models"
    echo ""
    print_colored $WHITE "5️⃣  System Status"
    print_colored $CYAN   "   • Show running processes"
    print_colored $CYAN   "   • Check model locations and sizes"
    echo ""
    print_colored $WHITE "6️⃣  Kill All Apps"
    print_colored $CYAN   "   • Stop Ollama, Docker, and LM Studio"
    print_colored $CYAN   "   • Completely shut down all AI services"
    echo ""
    print_colored $WHITE "0️⃣  Exit"
    echo ""
}

# Function to launch Ollama only
launch_ollama_only() {
    print_colored $GREEN "🦙 Launching Ollama..."
    
    # Check if already running
    if pgrep -x ollama >/dev/null; then
        print_colored $YELLOW "⚠️  Ollama is already running"
        local pid=$(pgrep -x ollama)
        print_colored $CYAN "   PID: $pid"
        return 0
    fi
    
    # Set environment and start
    export OLLAMA_MODELS="$OLLAMA_MODELS_DIR"
    print_colored $CYAN "🔧 Using models from: $OLLAMA_MODELS"
    
    ollama serve &
    local ollama_pid=$!
    
    sleep 2
    print_colored $GREEN "✅ Ollama started (PID: $ollama_pid)"
    print_colored $CYAN "💡 Available commands:"
    echo "   • ollama list"
    echo "   • ollama run <model-name>"
    echo "   • ollama pull <model-name>"
    echo ""
    print_colored $CYAN "🛑 To stop: pkill ollama"
}

# Function to launch Ollama + OpenWebUI
launch_ollama_openwebui() {
    print_colored $GREEN "🦙🌐 Launching Ollama + OpenWebUI..."
    
    # First start Ollama
    if ! pgrep -x ollama >/dev/null; then
        launch_ollama_only
        print_colored $CYAN "⏳ Waiting for Ollama to initialize..."
        sleep 3
    else
        print_colored $GREEN "✅ Ollama already running"
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        print_colored $YELLOW "🐳 Docker not running, starting Docker Desktop..."
        open -a Docker
        print_colored $CYAN "⏳ Waiting for Docker to start..."
        
        # Wait for Docker to be ready
        local timeout=60
        while [ $timeout -gt 0 ] && ! docker info >/dev/null 2>&1; do
            sleep 2
            timeout=$((timeout - 2))
            echo -n "."
        done
        echo ""
        
        if ! docker info >/dev/null 2>&1; then
            print_colored $RED "❌ Docker failed to start within 60 seconds"
            print_colored $YELLOW "Please start Docker manually and try again"
            return 1
        fi
        print_colored $GREEN "✅ Docker is ready"
    fi
    
    # Check if OpenWebUI container exists
    print_colored $CYAN "🔍 Checking for OpenWebUI container..."
    
    if docker ps -a --format "{{.Names}}" | grep -q "^${OPENWEBUI_CONTAINER_NAME}$"; then
        print_colored $CYAN "📦 Found existing OpenWebUI container"
        if docker ps --format "{{.Names}}" | grep -q "^${OPENWEBUI_CONTAINER_NAME}$"; then
            print_colored $GREEN "✅ OpenWebUI is already running"
            print_colored $CYAN "🌐 Access at: http://localhost:$OPENWEBUI_PORT"
        else
            print_colored $CYAN "🔄 Starting existing OpenWebUI container..."
            docker start $OPENWEBUI_CONTAINER_NAME
            print_colored $GREEN "✅ OpenWebUI started"
            print_colored $CYAN "🌐 Access at: http://localhost:$OPENWEBUI_PORT"
        fi
    else
        print_colored $CYAN "🚀 Creating new OpenWebUI container..."
        docker run -d \
            --name $OPENWEBUI_CONTAINER_NAME \
            -p $OPENWEBUI_PORT:8080 \
            -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
            -v open-webui:/app/backend/data \
            --restart unless-stopped \
            ghcr.io/open-webui/open-webui:main
        
        if [ $? -eq 0 ]; then
            print_colored $GREEN "✅ OpenWebUI container created and started"
            print_colored $CYAN "🌐 Access at: http://localhost:$OPENWEBUI_PORT"
            print_colored $CYAN "⏳ Give it ~30 seconds to fully initialize"
        else
            print_colored $RED "❌ Failed to create OpenWebUI container"
            return 1
        fi
    fi
    
    # Open browser
    read -p "Open OpenWebUI in browser? (Y/n): " open_browser
    if [ "$open_browser" != "n" ] && [ "$open_browser" != "N" ]; then
        print_colored $CYAN "🌐 Opening OpenWebUI in browser..."
        sleep 2
        open "http://localhost:$OPENWEBUI_PORT"
    fi
    
    print_colored $GREEN "🎉 Ollama + OpenWebUI launched successfully!"
}

# Function to launch LM Studio
launch_lmstudio() {
    print_colored $GREEN "🖥️  Launching LM Studio..."
    
    # Check if already running
    if pgrep -f "LM Studio" >/dev/null; then
        print_colored $YELLOW "⚠️  LM Studio is already running"
        return 0
    fi
    
    # Check if LM Studio app exists
    if [ ! -d "/Applications/LM Studio.app" ]; then
        print_colored $RED "❌ LM Studio not found in Applications"
        print_colored $YELLOW "Please install LM Studio from: https://lmstudio.ai"
        return 1
    fi
    
    print_colored $CYAN "🔧 Models will be loaded from: $LMSTUDIO_MODELS_DIR"
    print_colored $CYAN "🚀 Starting LM Studio..."
    
    open -a "LM Studio"
    
    sleep 2
    print_colored $GREEN "✅ LM Studio launched"
    print_colored $CYAN "💡 Your models are accessible via the symbolic link"
}

# Function to check for model updates
check_for_updates() {
    print_colored $BLUE "📡 Checking for available updates..."
    
    # Get current models and their info
    local models_info=$(ollama list 2>/dev/null | tail -n +2)
    if [ -z "$models_info" ]; then
        print_colored $YELLOW "⚠️  No models found"
        return 1
    fi
    
    local updates_available=""
    local old_models=""
    
    # Check each model for age
    echo "$models_info" | while read -r line; do
        local name=$(echo "$line" | awk '{print $1}')
        local modified_num=$(echo "$line" | awk '{print $4}')
        local modified_unit=$(echo "$line" | awk '{print $5}')
        
        # Check if model is old (>1 month)
        if [[ "$modified_unit" == "month"* ]] && [[ "$modified_num" =~ ^[0-9]+$ ]] && [ "$modified_num" -gt 1 ]; then
            echo "$name"
        fi
    done > /tmp/old_models_list
    
    if [ -s /tmp/old_models_list ]; then
        print_colored $YELLOW "⏰ Models that may have updates available:"
        while read -r model; do
            if [ -n "$model" ]; then
                print_colored $YELLOW "   • $model"
            fi
        done < /tmp/old_models_list
        rm /tmp/old_models_list
        return 0
    else
        print_colored $GREEN "✅ All models appear to be recent"
        rm /tmp/old_models_list 2>/dev/null
        return 1
    fi
}

# Function to update models menu (simplified version)
update_models_menu() {
    print_header
    print_colored $PURPLE "🔄 Model Update Menu"
    echo ""
    
    # Always check external drive first
    if [ ! -d "$EXTERNAL_DRIVE" ]; then
        print_colored $RED "❌ External drive ($EXTERNAL_DRIVE_NAME) not connected!"
        print_colored $YELLOW "📋 Please connect your external drive before updating models."
        echo ""
        read -p "Press Enter to return to main menu..."
        return 1
    fi
    
    print_colored $GREEN "✅ External drive connected, proceeding with update check..."
    echo ""
    
    # Start Ollama if not running
    if ! pgrep -x ollama >/dev/null; then
        print_colored $CYAN "🦙 Starting Ollama for updates..."
        export OLLAMA_MODELS="$OLLAMA_MODELS_DIR"
        ollama serve >/dev/null 2>&1 &
        sleep 3
    fi
    
    # Show current models
    print_colored $GREEN "📋 Current Models:"
    ollama list 2>/dev/null | tail -n +2 | while read -r line; do
        local name=$(echo "$line" | awk '{print $1}')
        local size=$(echo "$line" | awk '{print $3}')
        local modified=$(echo "$line" | awk '{print $4" "$5" "$6}')
        print_colored $WHITE "   • $name ($size) - $modified"
    done
    
    echo ""
    print_colored $CYAN "🚀 Update Options:"
    echo "1. Update specific model"
    echo "2. Pull new model"
    echo "3. Remove old model"
    echo "4. Back to main menu"
    echo ""
    
    read -p "Choose option (1-4): " update_choice
    
    case $update_choice in
        1)
            echo ""
            read -p "Enter model name to update: " model_name
            if [ -n "$model_name" ]; then
                print_colored $CYAN "🔄 Updating $model_name..."
                ollama pull "$model_name"
                if [ $? -eq 0 ]; then
                    print_colored $GREEN "✅ Update completed for $model_name"
                else
                    print_colored $RED "❌ Update failed for $model_name"
                fi
            fi
            ;;
        2)
            echo ""
            print_colored $CYAN "💡 Popular models to try:"
            echo "   • llama3.2:latest (newest Llama)"
            echo "   • qwen2.5:latest (excellent general model)"
            echo "   • deepseek-r1:latest (great for reasoning)"
            echo "   • gemma2:latest (Google's model)"
            echo "   • codellama:latest (coding specialist)"
            echo ""
            read -p "Enter new model name to pull: " new_model
            if [ -n "$new_model" ]; then
                print_colored $CYAN "📥 Pulling $new_model..."
                print_colored $YELLOW "⏳ Large models may take several minutes..."
                ollama pull "$new_model"
                if [ $? -eq 0 ]; then
                    print_colored $GREEN "✅ Successfully pulled $new_model"
                else
                    print_colored $RED "❌ Failed to pull $new_model"
                fi
            fi
            ;;
        3)
            echo ""
            read -p "Enter model name to remove: " remove_model
            if [ -n "$remove_model" ]; then
                print_colored $YELLOW "⚠️  This will permanently delete $remove_model from your external drive"
                read -p "Are you sure? (y/N): " confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    ollama rm "$remove_model"
                    if [ $? -eq 0 ]; then
                        print_colored $GREEN "✅ Successfully removed $remove_model"
                    else
                        print_colored $RED "❌ Failed to remove $remove_model"
                    fi
                else
                    print_colored $CYAN "Removal cancelled"
                fi
            fi
            ;;
        4)
            return 0
            ;;
        *)
            print_colored $RED "❌ Invalid option. Please choose 1-4."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

# Function to show system status
show_system_status() {
    print_header
    print_colored $PURPLE "📊 System Status"
    echo ""
    
    # Show running processes
    print_colored $BLUE "🔍 Running AI Processes:"
    
    if pgrep -x ollama >/dev/null; then
        local ollama_pid=$(pgrep -x ollama)
        print_colored $GREEN "✅ Ollama: Running (PID: $ollama_pid)"
        print_colored $CYAN "   Models: $(ollama list 2>/dev/null | tail -n +2 | wc -l | tr -d ' ') available"
    else
        print_colored $RED "❌ Ollama: Not running"
    fi
    
    if docker info >/dev/null 2>&1; then
        print_colored $GREEN "✅ Docker: Running"
        
        # Check OpenWebUI specifically
        if docker ps --format "{{.Names}}" | grep -q "$OPENWEBUI_CONTAINER_NAME"; then
            print_colored $GREEN "✅ OpenWebUI: Running → http://localhost:$OPENWEBUI_PORT"
        else
            print_colored $YELLOW "⚠️  OpenWebUI: Not running"
        fi
    else
        print_colored $RED "❌ Docker: Not running"
    fi
    
    if pgrep -f "LM Studio" >/dev/null; then
        print_colored $GREEN "✅ LM Studio: Running"
    else
        print_colored $RED "❌ LM Studio: Not running"
    fi
    
    echo ""
    
    # Show model statistics
    print_colored $BLUE "📊 Model Statistics:"
    
    if [ -d "$OLLAMA_MODELS_DIR" ]; then
        local ollama_size=$(du -sh "$OLLAMA_MODELS_DIR" 2>/dev/null | awk '{print $1}')
        local ollama_files=$(find "$OLLAMA_MODELS_DIR/blobs" -name "sha256-*" 2>/dev/null | wc -l | tr -d ' ')
        print_colored $WHITE "🦙 Ollama: $ollama_files model files, $ollama_size total"
    fi
    
    if [ -d "$LMSTUDIO_MODELS_DIR" ]; then
        local lmstudio_size=$(du -sh "$LMSTUDIO_MODELS_DIR" 2>/dev/null | awk '{print $1}')
        local lmstudio_files=$(find "$LMSTUDIO_MODELS_DIR" -name "*.gguf" -o -name "*.safetensors" 2>/dev/null | wc -l | tr -d ' ')
        print_colored $WHITE "🖥️  LM Studio: $lmstudio_files model files, $lmstudio_size total"
    fi
    
    echo ""
    
    # Show drive space
    print_colored $BLUE "💾 Storage Information:"
    if [ -d "$EXTERNAL_DRIVE" ]; then
        df -h "$EXTERNAL_DRIVE" | tail -1 | awk '{printf "   External Drive: %s available (%s used of %s)\n", $4, $5, $2}'
    fi
    df -h / | tail -1 | awk '{printf "   Internal drive: %s available (%s used of %s)\n", $4, $5, $2}'
    
    echo ""
    read -p "Press Enter to continue..."
}

# Function to kill all AI applications
kill_all_apps() {
    print_colored $RED "🛑 Shutting Down All AI Applications"
    echo ""
    
    print_colored $YELLOW "⚠️  This will completely stop:"
    echo "   • Ollama server"
    echo "   • Docker Desktop (and all containers)"
    echo "   • LM Studio application"
    echo ""
    
    read -p "Continue with shutdown? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        print_colored $CYAN "Shutdown cancelled"
        return 0
    fi
    
    echo ""
    print_colored $BLUE "🔄 Stopping services..."
    
    # Stop Ollama
    if pgrep -x ollama >/dev/null; then
        print_colored $CYAN "🦙 Stopping Ollama..."
        pkill -x ollama
        sleep 2
        if pgrep -x ollama >/dev/null; then
            print_colored $YELLOW "   Force killing Ollama..."
            pkill -9 -x ollama
        fi
        print_colored $GREEN "   ✅ Ollama stopped"
    else
        print_colored $GREEN "   ✅ Ollama was not running"
    fi
    
    # Stop LM Studio
    if pgrep -f "LM Studio" >/dev/null; then
        print_colored $CYAN "🖥️  Stopping LM Studio..."
        osascript -e 'quit app "LM Studio"' 2>/dev/null || true
        sleep 3
        if pgrep -f "LM Studio" >/dev/null; then
            print_colored $YELLOW "   Force killing LM Studio..."
            pkill -f "LM Studio"
        fi
        print_colored $GREEN "   ✅ LM Studio stopped"
    else
        print_colored $GREEN "   ✅ LM Studio was not running"
    fi
    
    # Stop Docker completely
    if docker info >/dev/null 2>&1; then
        print_colored $CYAN "🐳 Stopping Docker containers and services..."
        
        # Stop all containers first (with timeout)
        local containers=$(docker ps -q)
        if [ -n "$containers" ]; then
            print_colored $CYAN "   Stopping running containers..."
            timeout 10 docker stop $containers >/dev/null 2>&1 || {
                print_colored $YELLOW "   Containers taking too long, force killing..."
                docker kill $containers >/dev/null 2>&1 || true
            }
            print_colored $GREEN "   ✅ Containers stopped"
        fi
        
        # Multiple approaches to quit Docker Desktop
        print_colored $CYAN "   Shutting down Docker Desktop..."
        
        # Method 1: AppleScript quit (most graceful)
        osascript -e 'quit app "Docker"' 2>/dev/null &
        local applescript_pid=$!
        
        # Method 2: Kill Docker processes directly (parallel)
        (
            sleep 5  # Give AppleScript a chance first
            print_colored $CYAN "   Trying direct process termination..."
            pkill -TERM -f "Docker Desktop" 2>/dev/null || true
            sleep 2
            pkill -TERM -f "com.docker.desktop" 2>/dev/null || true
            pkill -TERM -f "com.docker.backend" 2>/dev/null || true
        ) &
        local direct_kill_pid=$!
        
        # Wait with progress indicator and user escape option
        print_colored $CYAN "   Waiting for shutdown (max 15 seconds, press 's' to skip)..."
        local timeout=15
        local dot_count=0
        local skip_docker=false
        
        while [ $timeout -gt 0 ] && docker info >/dev/null 2>&1; do
            # Check if user wants to skip (non-blocking)
            if read -t 1 -n 1 input 2>/dev/null; then
                if [ "$input" = "s" ] || [ "$input" = "S" ]; then
                    echo ""
                    print_colored $YELLOW "   Skipping Docker shutdown - will force kill..."
                    skip_docker=true
                    break
                fi
            fi
            
            timeout=$((timeout - 1))
            dot_count=$((dot_count + 1))
            
            # Show progress every 3 seconds
            if [ $((dot_count % 3)) -eq 0 ]; then
                echo -n "⏳"
            else
                echo -n "."
            fi
            
            # Early exit if Docker is gone
            if ! docker info >/dev/null 2>&1; then
                break
            fi
        done
        
        if [ "$skip_docker" = false ]; then
            echo ""
        fi
        
        # Clean up background processes
        kill $applescript_pid $direct_kill_pid 2>/dev/null || true
        wait $applescript_pid $direct_kill_pid 2>/dev/null || true
        
        # Final force kill if still running or user skipped
        if docker info >/dev/null 2>&1 || [ "$skip_docker" = true ]; then
            if [ "$skip_docker" = true ]; then
                print_colored $YELLOW "   User requested skip - force killing Docker..."
            else
                print_colored $YELLOW "   Docker timeout reached - using force kill..."
            fi
            
            # Nuclear option - kill all Docker-related processes
            pkill -9 -f "Docker" 2>/dev/null || true
            pkill -9 -f "com.docker" 2>/dev/null || true
            pkill -9 -f "hyperkit" 2>/dev/null || true
            pkill -9 -f "vpnkit" 2>/dev/null || true
            pkill -9 -f "com.docker.vmnetd" 2>/dev/null || true
            
            # Give it a moment to clean up
            sleep 2
            
            # Final verification
            if docker info >/dev/null 2>&1; then
                print_colored $RED "   ⚠️  Docker may still be running - check Activity Monitor"
                print_colored $CYAN "   💡 You can manually quit Docker from menu bar icon"
            else
                print_colored $GREEN "   ✅ Docker force-stopped successfully"
            fi
        else
            print_colored $GREEN "   ✅ Docker shut down gracefully"
        fi
        
    elif pgrep -f "Docker" >/dev/null 2>&1; then
        # Docker daemon not responding but processes exist
        print_colored $YELLOW "🐳 Docker processes found but daemon not responding..."
        print_colored $CYAN "   Force killing Docker processes..."
        
        pkill -TERM -f "Docker" 2>/dev/null || true
        sleep 3
        pkill -9 -f "Docker" 2>/dev/null || true
        pkill -9 -f "com.docker" 2>/dev/null || true
        
        print_colored $GREEN "   ✅ Docker processes cleaned up"
    else
        print_colored $GREEN "   ✅ Docker was not running"
    fi
    
    echo ""
    print_colored $GREEN "🎆 All AI applications have been shut down!"
    print_colored $CYAN "💡 Benefits:"
    echo "   • Freed up system resources"
    echo "   • Stopped background processes"
    echo "   • Clean system state"
    echo ""
    print_colored $CYAN "🚀 To restart: Use options 1-3 from main menu"
}

# Main execution function
main() {
    # Handle double-click execution by opening in Terminal
    if [ ! -t 0 ]; then
        # Not running in terminal, launch in Terminal app
        osascript <<EOF
tell application "Terminal"
    activate
    do script "$0"
end tell
EOF
        exit 0
    fi
    
    # Check if configuration is needed
    if [ "$EXTERNAL_DRIVE_NAME" = "YOUR-EXTERNAL-DRIVE" ]; then
        print_header
        print_colored $YELLOW "⚙️  First-time setup required!"
        print_colored $CYAN "Please edit this script and configure:"
        echo "   1. EXTERNAL_DRIVE_NAME (line ~10)"
        echo "   2. Other settings as needed"
        echo ""
        print_colored $CYAN "Example: Change 'YOUR-EXTERNAL-DRIVE' to 'AI-Models-SSD'"
        echo ""
        read -p "Press Enter to exit and edit configuration..."
        exit 1
    fi
    
    while true; do
        print_header
        
        # Always check drive first
        check_external_drive
        
        # Check for updates
        check_model_updates
        
        # Show menu
        show_launch_menu
        
        read -p "Choose an option (0-6): " choice
        
        case $choice in
            1)
                print_header
                launch_ollama_only
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                print_header
                launch_ollama_openwebui
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                print_header
                launch_lmstudio
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                update_models_menu
                ;;
            5)
                show_system_status
                ;;
            6)
                print_header
                kill_all_apps
                echo ""
                read -p "Press Enter to continue..."
                ;;
            0)
                print_colored $GREEN "👋 Goodbye!"
                exit 0
                ;;
            *)
                print_colored $RED "❌ Invalid option. Please choose 0-6."
                sleep 2
                ;;
        esac
    done
}

# Run main function
main "$@"