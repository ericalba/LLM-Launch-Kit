# LLM Launch Kit - Universal AI Models Management Hub

## 🎯 The Problem This Solves

Running AI models locally is amazing, but there's a big problem: **AI models are HUGE** and will quickly fill up your internal storage!

- **Single models** can be 4GB-70GB+ each
- **Multiple models** easily consume 100-500GB of space
- **Your MacBook's SSD** is expensive and limited
- **Managing multiple AI apps** (Ollama, OpenWebUI, LM Studio) becomes tedious

## 💡 The Solution

This kit provides a **single command-line interface** to manage all your AI applications while keeping models on **external storage**. Think of it as a "control center" for your local AI setup.

### Why You Need This:
- 🏠 **Keep your internal drive free** - Models live on external SSD
- 🚀 **One launcher for everything** - Ollama, OpenWebUI, LM Studio
- 🔄 **Easy model management** - Update, download, remove models
- 🧳 **Portable setup** - Take your models anywhere
- 🛑 **Clean shutdowns** - Stop all AI services properly
- 📊 **Monitor everything** - See what's running and storage usage

## 🌟 What This Script Does

A comprehensive command-line launcher and management system for AI models on macOS, designed to work seamlessly with external SSD storage. This script provides an elegant interface to launch and manage **Ollama**, **OpenWebUI**, and **LM Studio** applications while keeping your valuable AI models on external storage to save internal disk space.

## 👥 Who Should Use This

**Perfect for you if:**
- ✅ You run AI models locally (Ollama, LM Studio, etc.)
- ✅ You're tired of AI models filling up your MacBook's storage
- ✅ You want a single interface to manage multiple AI applications
- ✅ You need to use models across multiple Mac computers
- ✅ You like clean, organized terminal interfaces
- ✅ You want to easily share models with others

**Use cases:**
- **Developers** building AI-powered applications
- **Researchers** experimenting with different models
- **Students** learning about AI and machine learning
- **Content creators** using AI for writing, coding, or analysis
- **Teams** sharing curated model collections
- **Anyone** who wants to keep their expensive MacBook SSD free!

## 🌟 Features

- **🚀 Universal Launcher**: Single interface for all your AI applications
- **💾 External Storage**: Keep models on external SSD to preserve internal storage
- **🔄 Model Management**: Update, pull, and remove models interactively
- **📊 System Monitoring**: View running processes and storage usage
- **🛑 Complete Shutdown**: Kill all AI applications cleanly
- **🎨 Colorful Interface**: Beautiful terminal UI with emojis and colors
- **🔗 Symbolic Links**: Automatic model directory linking
- **🐳 Docker Integration**: Seamless OpenWebUI container management
- **⚡ Performance Optimized**: Smart process detection and management

## 📋 Prerequisites

### Required Applications
- **macOS** (tested on macOS 12+)
- **[Ollama](https://ollama.com)** - AI model runtime
- **[Docker Desktop](https://www.docker.com/products/docker-desktop)** - For OpenWebUI
- **[LM Studio](https://lmstudio.ai)** (optional) - GUI model interface

### Hardware Requirements
- **External SSD/Drive** - For AI model storage (recommended: USB 3.0+ or Thunderbolt)
- **8GB+ RAM** - For running AI models efficiently
- **100GB+ External Storage** - AI models can be large (1GB-70GB+ each)

## ⚠️ IMPORTANT - System Modifications Warning

**READ THIS BEFORE RUNNING THE SCRIPT!** This tool makes several changes to your system:

### 🔗 Symbolic Links Created:
```bash
~/.ollama/models            → /Volumes/[YOUR-DRIVE]/AI-Models/ollama-models
~/.cache/lm-studio/models   → /Volumes/[YOUR-DRIVE]/AI-Models/lm-studio-models
```
**Impact**: These replace your existing model directories. Any existing models will be backed up with timestamp.

### 📁 Directories Created:
```bash
# On your external drive:
/Volumes/[YOUR-DRIVE]/AI-Models/
├── ollama-models/
├── lm-studio-models/
└── shared-converted/

# Backup directories (if existing models found):
~/.ollama/models.backup.[TIMESTAMP]
~/.cache/lm-studio/models.backup.[TIMESTAMP]
```

### 🐳 Docker Modifications:
- **Creates container**: `open-webui` (persists after script ends)
- **Downloads image**: `ghcr.io/open-webui/open-webui:main` (~500MB)
- **Creates volume**: `open-webui` for data persistence
- **Port binding**: 8080 → container port 8080

### 🔧 System Requirements:
- **Administrator access**: May be required for Docker operations
- **External drive**: Must remain connected during AI operations
- **Homebrew**: Will be installed if missing (with your permission)
- **Applications**: Ollama, Docker Desktop, LM Studio must be installed

### 🧹 What Happens When You Stop:
- **Symbolic links**: Remain until manually removed
- **Docker containers**: Continue running in background
- **External drive**: Can be disconnected, but breaks functionality
- **Models**: Stay on external drive (safe)

### 🛑 Clean Uninstall (Manual Steps):
```bash
# Remove symbolic links:
rm ~/.ollama/models
rm ~/.cache/lm-studio/models

# Restore original directories (if backups exist):
mv ~/.ollama/models.backup.[TIMESTAMP] ~/.ollama/models
mv ~/.cache/lm-studio/models.backup.[TIMESTAMP] ~/.cache/lm-studio/models

# Remove Docker container:
docker stop open-webui
docker rm open-webui
docker rmi ghcr.io/open-webui/open-webui:main

# Stop AI processes:
pkill ollama
```

### 🔐 Security & Privacy Considerations:

**What this script accesses:**
- 📁 **File system**: Creates/modifies directories in your home folder
- 🔗 **Symbolic links**: Redirects model storage to external drive
- 🌐 **Network**: Downloads Docker images and AI models from internet
- 💻 **System processes**: Starts/stops Ollama, Docker, and LM Studio
- 🐳 **Docker daemon**: Creates containers and manages images

**What this script does NOT do:**
- ❌ **No data collection**: Doesn't send usage data anywhere
- ❌ **No internet monitoring**: Only downloads when you request models
- ❌ **No credential storage**: Doesn't save passwords or tokens
- ❌ **No system modifications**: Beyond documented changes above
- ❌ **No background telemetry**: All operations are local

**Recommended security practices:**
- ✅ **Review the script** before running (it's open source!)
- ✅ **Use trusted external drives** for model storage
- ✅ **Keep Docker updated** for security patches
- ✅ **Monitor disk usage** - AI models are large
- ✅ **Regular backups** of your model collections

---

## 🛠️ Installation

### Step 1: Clone or Download
```bash
git clone https://github.com/[your-username]/llm-launch-kit.git
cd llm-launch-kit
```

### Step 2: Configure Your External Drive
Edit the script to match your setup:

1. Open `llm-launch.sh` in your favorite text editor
2. Find the configuration section (around line 13):
   ```bash
   # External drive configuration (change these to match your setup)
   EXTERNAL_DRIVE_NAME="YOUR-EXTERNAL-DRIVE"  # ← CHANGE THIS
   ```
3. Change `YOUR-EXTERNAL-DRIVE` to your actual external drive name:
   ```bash
   EXTERNAL_DRIVE_NAME="AI-Models-SSD"        # Example
   EXTERNAL_DRIVE_NAME="Samsung-T7"           # Example
   EXTERNAL_DRIVE_NAME="ROCKET-nano"          # Example
   ```

### Step 3: Make Executable
```bash
chmod +x llm-launch.sh
```

### Step 4: Optional - Add to PATH
For system-wide access, create a symlink:
```bash
sudo ln -sf "$(pwd)/llm-launch.sh" /usr/local/bin/llm-launch
```

Then you can run `llm-launch` from anywhere in your terminal.

## 🚀 Usage

### Basic Usage
```bash
./llm-launch.sh
```

The script will:
1. ✅ Check if your external drive is connected
2. 📋 Show current model status and any available updates
3. 🎯 Present a menu with launch options

### Menu Options

**1️⃣ Ollama Only**
- Starts just the Ollama server
- Perfect for CLI usage and API access
- Uses models from your external drive

**2️⃣ Ollama + OpenWebUI**  
- Starts Ollama server
- Launches OpenWebUI web interface
- Auto-opens browser to http://localhost:8080
- Full ChatGPT-like web interface

**3️⃣ LM Studio**
- Launches LM Studio application
- GUI-based model management
- Uses models from your external drive

**4️⃣ Update Models**
- Interactive model update menu
- Update existing models
- Pull new models
- Remove old models

**5️⃣ System Status**
- Show all running AI processes
- Display model statistics and storage usage
- Check system health

**6️⃣ Kill All Apps**
- Safely stop Ollama, Docker, and LM Studio
- Clean shutdown of all AI services
- Frees system resources

## 📁 Directory Structure

The script creates this structure on your external drive:

```
/Volumes/[YOUR-DRIVE]/AI-Models/
├── ollama-models/          # Ollama model storage
├── lm-studio-models/       # LM Studio model storage
└── shared-converted/       # For shared/converted models
```

And creates these symbolic links on your system:
```
~/.ollama/models            → /Volumes/[YOUR-DRIVE]/AI-Models/ollama-models
~/.cache/lm-studio/models   → /Volumes/[YOUR-DRIVE]/AI-Models/lm-studio-models
```

## 🔧 Configuration Options

### External Drive Settings
```bash
EXTERNAL_DRIVE_NAME="YOUR-DRIVE"               # Drive name as shown in /Volumes/
EXTERNAL_DRIVE="/Volumes/$EXTERNAL_DRIVE_NAME" # Full path to drive
MODELS_DIR="$EXTERNAL_DRIVE/AI-Models"         # Models directory
```

### OpenWebUI Settings
```bash
OPENWEBUI_PORT="8080"                          # Web interface port
OPENWEBUI_CONTAINER_NAME="open-webui"         # Docker container name
```

## 🧳 Portable AI Models - Take Your Models Anywhere!

**Yes! Your models are now completely portable!** This is one of the best features of this setup.

### How Portability Works:
1. **All models live on your external drive** (e.g., Samsung T7, ROCKET nano)
2. **The script creates symbolic links** that redirect apps to the external drive
3. **Take your drive to any Mac** and run the setup scripts
4. **Instantly access all your models** on the new machine

### Real-World Portability Examples:
- **Work & Home**: Use the same models on your work MacBook and home iMac
- **Travel**: Take your AI setup anywhere with just your laptop + external drive
- **Collaboration**: Share your curated model collection with teammates
- **Backup**: Your models are separate from your system - safe from OS reinstalls

### Setting Up on a New Mac:
```bash
# 1. Connect your external drive
# 2. Clone this repo on the new Mac
# 3. Edit the drive name in llm-launch.sh
# 4. Run setup:
./setup-links.sh
./llm-launch.sh
# 5. All your models are instantly available!
```

**Note**: You'll need to install Ollama/Docker/LM Studio on each new Mac, but your **models and configurations** travel with your drive.

## 💡 Tips and Best Practices

### Drive Naming
- Use simple, consistent drive names
- Avoid spaces and special characters
- Examples: `AI-Models-SSD`, `Samsung-T7`, `ROCKET-nano`

### Model Management
- Start with smaller models (7B parameters) to test setup
- Popular models to try:
  - `llama3.2:latest` - Latest Meta Llama model
  - `qwen2.5:latest` - Excellent general-purpose model
  - `deepseek-r1:latest` - Great for reasoning tasks
  - `codellama:latest` - Specialized for coding

### Storage Planning
- **7B models**: ~4-8GB each
- **13B models**: ~8-16GB each  
- **34B models**: ~20-40GB each
- **70B models**: ~40-80GB each

### Performance Tips
- Use USB 3.0+ or Thunderbolt external drives
- SSD performs much better than HDD for AI models
- Keep external drive connected when using AI apps
- Monitor available space before downloading large models

## 🚨 Troubleshooting

### Drive Not Found
```
❌ External drive (YOUR-DRIVE) not found!
```
**Solutions:**
- Ensure external drive is connected and mounted
- Check drive name matches configuration
- Try `ls /Volumes/` to see available drives

### Docker Issues
```
❌ Docker failed to start within 60 seconds
```
**Solutions:**
- Start Docker Desktop manually first
- Check Docker Desktop settings
- Ensure sufficient system resources

### Ollama Not Found
```
⚠️ Ollama not in PATH - skipping update check
```
**Solutions:**
- Install Ollama from https://ollama.com
- Restart terminal after installation
- Check `which ollama` works

### Permission Issues
```
❌ Failed to create symbolic link
```
**Solutions:**
- Run with appropriate permissions
- Check external drive is not read-only
- Ensure destination directories exist
- If existing models directory: `mv ~/.ollama/models ~/.ollama/models.backup`

### Symbolic Link Issues
```
❌ Models not found after setup
```
**Check symbolic links:**
```bash
# Verify links are correct:
ls -la ~/.ollama/models
ls -la ~/.cache/lm-studio/models

# Should show: ~/.ollama/models -> /Volumes/[YOUR-DRIVE]/AI-Models/ollama-models
```
**Solutions:**
- Ensure external drive is connected
- Verify drive name matches configuration
- Check external drive has proper permissions

### Docker Container Issues
```
❌ OpenWebUI not accessible at localhost:8080
```
**Diagnostic steps:**
```bash
# Check if container is running:
docker ps | grep open-webui

# Check container logs:
docker logs open-webui

# Restart container if needed:
docker restart open-webui
```

### External Drive Disconnected
```
❌ Models suddenly unavailable
```
**What happens:**
- Symbolic links become broken (normal)
- Ollama will show "no models found"
- OpenWebUI may show connection errors

**Solution:**
- Reconnect external drive
- Models become available immediately
- No need to restart applications

## 🔒 Security Notes

- The script only manages local AI applications
- No internet connections except for model downloads
- All data stays on your local machine and external drive
- Docker containers use local networking only

## 🙏 Acknowledgments

This project builds upon the incredible work of the open-source AI community:

- **[Ollama](https://ollama.com)** - For making AI models accessible and easy to run locally
- **[Open WebUI](https://github.com/open-webui/open-webui)** - For the beautiful web interface
- **[LM Studio](https://lmstudio.ai)** - For the excellent GUI model management
- **Docker Community** - For containerization that makes deployment seamless

Special thanks to the AI/ML community for sharing knowledge about local model management and the challenges of storage optimization.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Ideas for Contributions:
- Support for Linux distributions
- Integration with more AI applications
- Model conversion utilities
- Performance optimization features
- Better error handling and recovery

## 📝 License

MIT License - feel free to use and modify as needed.

## 🆘 Support

Having issues? Check:

1. **Requirements**: Ensure all prerequisite applications are installed
2. **Configuration**: Verify drive name and paths are correct
3. **Permissions**: Make sure script is executable
4. **Resources**: Ensure sufficient disk space and memory

## 📈 Changelog

### v1.0.0 - Initial Release
- ✅ Multi-application launcher
- ✅ External drive support
- ✅ Model management
- ✅ System monitoring
- ✅ Complete shutdown functionality
- ✅ Colorful terminal interface

---

## ⭐ Star this repo if it helps you manage your AI models efficiently!

**Made with ❤️ for the AI community**