# 🚀 Quick Start Guide

Get up and running with LLM Launch Kit in just a few minutes!

## Prerequisites Checklist

Before starting, make sure you have:
- ✅ **macOS** (12.0 or later recommended)
- ✅ **External SSD/Drive** connected to your Mac
- ✅ **[Ollama](https://ollama.com)** installed
- ✅ **[Docker Desktop](https://www.docker.com/products/docker-desktop)** installed
- ✅ **[LM Studio](https://lmstudio.ai)** (optional, for GUI interface)

## 5-Minute Setup

### Step 1: Configure Your Drive Name
```bash
# Edit the main script
nano llm-launch.sh

# Find line 13 and change YOUR-EXTERNAL-DRIVE to your drive name:
EXTERNAL_DRIVE_NAME="AI-Models-SSD"  # ← Change this!
```

**How to find your drive name:**
```bash
ls /Volumes/
# Your external drive will be listed here
```

### Step 2: Make Scripts Executable
```bash
chmod +x llm-launch.sh
chmod +x setup-links.sh
```

### Step 3: Set Up Symbolic Links
```bash
./setup-links.sh
```
This creates the necessary symbolic links to redirect model storage to your external drive.

### Step 4: Launch!
```bash
./llm-launch.sh
```

## First Usage

When you run the script for the first time:

1. **Choose Option 4** - Update Models
2. **Pull your first model** - Try `llama3.2:latest`
3. **Choose Option 2** - Launch Ollama + OpenWebUI
4. **Access the web interface** at http://localhost:8080

## Popular First Models to Try

Start with these smaller models to test your setup:

```bash
# In the "Update Models" menu, try:
llama3.2:latest       # ~2GB - Latest Meta Llama
qwen2.5:7b           # ~4GB - Excellent general model  
deepseek-r1:1.5b     # ~1GB - Great for reasoning
codellama:7b         # ~4GB - Coding specialist
```

## Common Issues & Quick Fixes

### ❌ "External drive not found"
```bash
# Check your drive is connected:
ls /Volumes/
# Make sure EXTERNAL_DRIVE_NAME matches exactly
```

### ❌ "Docker failed to start"
```bash
# Start Docker Desktop manually first:
open -a Docker
# Wait for it to fully start, then try again
```

### ❌ "Ollama not found"
```bash
# Install Ollama:
# Visit https://ollama.com and download
# Or use Homebrew:
brew install ollama
```

### ❌ "Permission denied"
```bash
# Make sure scripts are executable:
chmod +x llm-launch.sh setup-links.sh
```

## What Each Menu Option Does

- **1️⃣ Ollama Only** - Basic CLI access to AI models
- **2️⃣ Ollama + OpenWebUI** - Full web interface (recommended for beginners)
- **3️⃣ LM Studio** - GUI application for model management
- **4️⃣ Update Models** - Download, update, or remove models
- **5️⃣ System Status** - Check what's running and storage usage
- **6️⃣ Kill All Apps** - Clean shutdown of all AI services

## Pro Tips

- Start with **Option 2** (Ollama + OpenWebUI) for the best experience
- Use **Option 5** to monitor your storage usage
- **Option 6** is great before restarting your Mac
- Keep your external drive connected when using AI models
- Smaller models (7B parameters) are great for testing
- Larger models (70B+) need more RAM and time to load

## Need Help?

- Check the main [README.md](README.md) for detailed documentation
- Look at the troubleshooting section for common issues
- Make sure all prerequisites are properly installed

---

**Ready to launch? Run `./llm-launch.sh` and enjoy! 🎉**