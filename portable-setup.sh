#!/bin/bash

# LLM Launch Kit - Portable Setup
# Run this script directly from your external drive on any Mac!

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_colored $CYAN "🚀 LLM Launch Kit - Portable Setup"
print_colored $CYAN "Running from external drive - Setting up on this Mac..."
echo ""

# Get the directory where this script is located (on the external drive)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRIVE_PATH="$(dirname "$SCRIPT_DIR")"  # Go up one level from the script location

# Extract drive name from the path
DRIVE_NAME="$(basename "$DRIVE_PATH")"

print_colored $BLUE "🔍 Detected Configuration:"
echo "   External Drive: $DRIVE_NAME"
echo "   Drive Path: $DRIVE_PATH"
echo "   Script Location: $SCRIPT_DIR"
echo ""

# Check if we're actually on an external drive
if [[ "$DRIVE_PATH" != "/Volumes/"* ]]; then
    print_colored $YELLOW "⚠️  Warning: This doesn't appear to be running from /Volumes/"
    print_colored $YELLOW "   Current location: $DRIVE_PATH"
    read -p "Continue anyway? (y/N): " continue_anyway
    if [ "$continue_anyway" != "y" ] && [ "$continue_anyway" != "Y" ]; then
        exit 1
    fi
fi

# Check for required applications
print_colored $BLUE "🔍 Checking for required applications..."

missing_apps=()

if ! command -v ollama >/dev/null 2>&1; then
    missing_apps+=("Ollama")
fi

if ! docker info >/dev/null 2>&1 && ! pgrep -f "Docker" >/dev/null; then
    missing_apps+=("Docker Desktop")
fi

if [ ! -d "/Applications/LM Studio.app" ]; then
    missing_apps+=("LM Studio (optional)")
fi

if [ ${#missing_apps[@]} -gt 0 ]; then
    print_colored $YELLOW "⚠️  Missing applications on this Mac:"
    for app in "${missing_apps[@]}"; do
        echo "   • $app"
    done
    echo ""
    print_colored $CYAN "📥 Quick install commands:"
    echo "   • Ollama: brew install ollama  (or download from https://ollama.com)"
    echo "   • Docker: Download from https://docker.com"
    echo "   • LM Studio: Download from https://lmstudio.ai"
    echo ""
    read -p "Continue with setup anyway? (y/N): " continue_setup
    if [ "$continue_setup" != "y" ] && [ "$continue_setup" != "Y" ]; then
        print_colored $CYAN "Setup cancelled. Install the missing apps and try again."
        exit 1
    fi
fi

# Create a temporary launcher script with the correct drive name
print_colored $BLUE "🔧 Creating temporary launcher for this Mac..."

TEMP_LAUNCHER="/tmp/llm-launch-${DRIVE_NAME}.sh"
cp "$SCRIPT_DIR/llm-launch.sh" "$TEMP_LAUNCHER"

# Update the drive name in the temporary script
sed -i '' "s/EXTERNAL_DRIVE_NAME=\"YOUR-EXTERNAL-DRIVE\"/EXTERNAL_DRIVE_NAME=\"$DRIVE_NAME\"/" "$TEMP_LAUNCHER"

chmod +x "$TEMP_LAUNCHER"

print_colored $GREEN "✅ Temporary launcher created: $TEMP_LAUNCHER"

# Set up symbolic links
print_colored $BLUE "🔗 Setting up symbolic links to your external drive models..."

MODELS_DIR="$DRIVE_PATH/AI-Models"
OLLAMA_MODELS_DIR="$MODELS_DIR/ollama-models"
LMSTUDIO_MODELS_DIR="$MODELS_DIR/lm-studio-models"

# Create directories if they don't exist
mkdir -p "$OLLAMA_MODELS_DIR"
mkdir -p "$LMSTUDIO_MODELS_DIR"

# Function to create symbolic link safely
create_symlink() {
    local source=$1
    local target=$2
    local description=$3
    
    print_colored $CYAN "   Setting up $description..."
    
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        local backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$target" "$backup_name"
        print_colored $YELLOW "   Backed up existing to: $backup_name"
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    if ln -sf "$source" "$target"; then
        print_colored $GREEN "   ✅ $description linked successfully"
    else
        print_colored $RED "   ❌ Failed to link $description"
        return 1
    fi
}

# Create the symbolic links
create_symlink "$OLLAMA_MODELS_DIR" "$HOME/.ollama/models" "Ollama models"
create_symlink "$LMSTUDIO_MODELS_DIR" "$HOME/.cache/lm-studio/models" "LM Studio models"

echo ""
print_colored $GREEN "🎉 Portable setup complete!"
print_colored $CYAN "🚀 Your external drive models are now accessible on this Mac"
echo ""

# Show what models are available
if [ -d "$OLLAMA_MODELS_DIR/blobs" ]; then
    local model_count=$(find "$OLLAMA_MODELS_DIR/blobs" -name "sha256-*" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$model_count" -gt 0 ]; then
        print_colored $BLUE "📋 Found $model_count Ollama model files on your drive"
    fi
fi

print_colored $CYAN "💡 Next steps:"
echo "   1. Run: $TEMP_LAUNCHER"
echo "   2. Choose option 1 or 2 to start using your models"
echo "   3. All your models from the external drive are ready to use!"
echo ""

print_colored $YELLOW "🔄 When you're done on this Mac:"
echo "   • Your models stay on the external drive"
echo "   • Just unplug and take your drive anywhere"
echo "   • The symbolic links will break (that's normal)"
echo "   • Run this script again on the next Mac"
echo ""

# Ask if they want to launch immediately
read -p "Launch the AI manager now? (Y/n): " launch_now
if [ "$launch_now" != "n" ] && [ "$launch_now" != "N" ]; then
    print_colored $CYAN "🚀 Launching LLM Manager..."
    exec "$TEMP_LAUNCHER"
fi