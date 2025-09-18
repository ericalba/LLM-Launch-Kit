#!/bin/bash

# LLM Launch Kit - Symbolic Links Setup Helper
# This script helps create the necessary symbolic links for external drive model storage

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_colored $CYAN "🔗 LLM Launch Kit - Symbolic Links Setup"
echo ""

# Check if main script exists and extract drive name
if [ ! -f "llm-launch.sh" ]; then
    print_colored $RED "❌ llm-launch.sh not found in current directory"
    print_colored $YELLOW "Please run this script from the LLM Launch Kit directory"
    exit 1
fi

# Extract drive name from main script
EXTERNAL_DRIVE_NAME=$(grep "^EXTERNAL_DRIVE_NAME=" llm-launch.sh | cut -d'"' -f2)

if [ "$EXTERNAL_DRIVE_NAME" = "YOUR-EXTERNAL-DRIVE" ]; then
    print_colored $YELLOW "⚠️  Please configure your external drive name in llm-launch.sh first"
    print_colored $CYAN "Edit line 13 in llm-launch.sh to match your external drive name"
    exit 1
fi

EXTERNAL_DRIVE="/Volumes/$EXTERNAL_DRIVE_NAME"
MODELS_DIR="$EXTERNAL_DRIVE/AI-Models"
OLLAMA_MODELS_DIR="$MODELS_DIR/ollama-models"
LMSTUDIO_MODELS_DIR="$MODELS_DIR/lm-studio-models"

print_colored $BLUE "🔍 Configuration:"
echo "   External Drive: $EXTERNAL_DRIVE_NAME"
echo "   Models Directory: $MODELS_DIR"
echo ""

# Check if external drive is connected
if [ ! -d "$EXTERNAL_DRIVE" ]; then
    print_colored $RED "❌ External drive ($EXTERNAL_DRIVE_NAME) not found!"
    print_colored $YELLOW "Please connect your external drive and try again"
    exit 1
fi

print_colored $GREEN "✅ External drive found"

# Create directories on external drive if they don't exist
print_colored $BLUE "📁 Creating directory structure on external drive..."

mkdir -p "$OLLAMA_MODELS_DIR"
mkdir -p "$LMSTUDIO_MODELS_DIR"
mkdir -p "$MODELS_DIR/shared-converted"

print_colored $GREEN "✅ Directory structure created"
echo ""

# Function to create symbolic link safely
create_symlink() {
    local source=$1
    local target=$2
    local description=$3
    
    print_colored $BLUE "🔗 Setting up $description..."
    
    # Check if target already exists
    if [ -L "$target" ]; then
        # It's already a symlink
        local current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            print_colored $GREEN "   ✅ Correct symlink already exists"
            return 0
        else
            print_colored $YELLOW "   ⚠️  Existing symlink points to: $current_target"
            read -p "   Replace with new link? (y/N): " replace
            if [ "$replace" = "y" ] || [ "$replace" = "Y" ]; then
                rm "$target"
            else
                print_colored $CYAN "   Skipping $description"
                return 1
            fi
        fi
    elif [ -e "$target" ]; then
        # It exists but isn't a symlink (regular directory/file)
        print_colored $YELLOW "   ⚠️  $target exists but is not a symlink"
        print_colored $YELLOW "   This might contain existing models"
        
        read -p "   Backup existing directory and create symlink? (y/N): " backup
        if [ "$backup" = "y" ] || [ "$backup" = "Y" ]; then
            local backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$target" "$backup_name"
            print_colored $CYAN "   📦 Backed up to: $backup_name"
        else
            print_colored $CYAN "   Skipping $description"
            return 1
        fi
    fi
    
    # Create parent directory if needed
    local parent_dir=$(dirname "$target")
    if [ ! -d "$parent_dir" ]; then
        mkdir -p "$parent_dir"
        print_colored $CYAN "   📁 Created parent directory: $parent_dir"
    fi
    
    # Create the symbolic link
    if ln -sf "$source" "$target"; then
        print_colored $GREEN "   ✅ Successfully created symlink"
        print_colored $CYAN "   $target → $source"
        return 0
    else
        print_colored $RED "   ❌ Failed to create symlink"
        return 1
    fi
}

# Create Ollama symlink
create_symlink "$OLLAMA_MODELS_DIR" "$HOME/.ollama/models" "Ollama models link"
echo ""

# Create LM Studio symlink
create_symlink "$LMSTUDIO_MODELS_DIR" "$HOME/.cache/lm-studio/models" "LM Studio models link"
echo ""

# Verify the links
print_colored $BLUE "🔍 Verifying symbolic links..."
echo ""

if [ -L "$HOME/.ollama/models" ]; then
    local ollama_target=$(readlink "$HOME/.ollama/models")
    if [ "$ollama_target" = "$OLLAMA_MODELS_DIR" ]; then
        print_colored $GREEN "✅ Ollama link: CORRECT"
    else
        print_colored $RED "❌ Ollama link: Points to wrong location"
    fi
    echo "   $HOME/.ollama/models → $ollama_target"
else
    print_colored $YELLOW "⚠️  Ollama link: NOT SET"
fi

if [ -L "$HOME/.cache/lm-studio/models" ]; then
    local lmstudio_target=$(readlink "$HOME/.cache/lm-studio/models")
    if [ "$lmstudio_target" = "$LMSTUDIO_MODELS_DIR" ]; then
        print_colored $GREEN "✅ LM Studio link: CORRECT"
    else
        print_colored $RED "❌ LM Studio link: Points to wrong location"
    fi
    echo "   $HOME/.cache/lm-studio/models → $lmstudio_target"
else
    print_colored $YELLOW "⚠️  LM Studio link: NOT SET"
fi

echo ""
print_colored $GREEN "🎉 Symbolic links setup complete!"
print_colored $CYAN "💡 You can now run ./llm-launch.sh to start using your AI models"
print_colored $CYAN "   from external storage while keeping your internal drive free!"

echo ""
print_colored $BLUE "📊 Next steps:"
echo "   1. Run ./llm-launch.sh"
echo "   2. Choose option 4 to pull some AI models"
echo "   3. Try option 2 for full web interface experience"
echo ""