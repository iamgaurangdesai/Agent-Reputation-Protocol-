#!/bin/bash
# ARP One-Line Installer
# Usage: curl -s https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║     🤖 ARP - Agent Reputation Protocol            ║"
echo "║     One-Command Installer                         ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Configuration
ARP_VERSION="1.0.0"
INSTALL_DIR="${HOME}/.arp"
SKILL_DIR="${OPENCLAW_HOME:-$HOME/.openclaw}/skills/arp"
BIN_DIR="$INSTALL_DIR/bin"

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

echo -e "${BLUE}[1/6]${NC} Detecting system..."
echo "    OS: $OS"
echo "    Arch: $ARCH"

# Create directories
echo -e "${BLUE}[2/6]${NC} Creating directories..."
mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$SKILL_DIR"

# Install ARP CLI
echo -e "${BLUE}[3/6]${NC} Installing ARP CLI..."

cat > "$BIN_DIR/arp" << 'CLI_EOF'
#!/bin/bash
# ARP CLI

ARP_CONFIG="${HOME}/.arp/config.json"
ARP_CONTRACT="0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd"
EIGEN_CLOUD="0x72aa0fa6bD35Cd6A5B0d1dB0591fDe9F844E5f66"

show_help() {
    echo "ARP - Agent Reputation Protocol"
    echo ""
    echo "Usage: arp <command> [options]"
    echo ""
    echo "Commands:"
    echo "  register    Register your agent on ARP"
    echo "  status      Check your agent status"
    echo "  dashboard   Open dashboard in browser"
    echo "  docs        Open documentation"
    echo "  config      Show configuration"
    echo "  help        Show this help"
    echo ""
    echo "Examples:"
    echo "  arp register --name MyAgent --bio 'AI assistant'"
    echo "  arp status"
    echo "  arp dashboard"
}

cmd_register() {
    echo "📝 Registering agent on ARP..."
    echo ""
    echo "Please visit: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/register.html"
    echo ""
    echo "Or use cast (foundry):"
    echo "  export PRIVATE_KEY=your_key"
    echo "  cast send $ARP_CONTRACT \"registerAgent(string,string,string[])\" \"Name\" \"Bio\" '[\"skill1\"]' --value 0.001ether --rpc-url https://mainnet.base.org"
}

cmd_status() {
    echo "📊 Checking agent status..."
    echo ""
    echo "Contract: $ARP_CONTRACT"
    echo "EigenCloud: $EIGEN_CLOUD"
    echo ""
    
    if [ -f "$ARP_CONFIG" ]; then
        echo "✅ Config found: $ARP_CONFIG"
        cat "$ARP_CONFIG"
    else
        echo "⚠️  No config found. Register first:"
        echo "   arp register"
    fi
}

cmd_dashboard() {
    echo "🌐 Opening dashboard..."
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html"
    elif command -v open &> /dev/null; then
        open "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html"
    else
        echo "Open: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html"
    fi
}

cmd_docs() {
    echo "📚 Opening documentation..."
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/"
    elif command -v open &> /dev/null; then
        open "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/"
    else
        echo "Open: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/"
    fi
}

cmd_config() {
    echo "⚙️  ARP Configuration"
    echo ""
    echo "Install dir: $INSTALL_DIR"
    echo "Config file: $ARP_CONFIG"
    echo "ARP Contract: $ARP_CONTRACT"
    echo "EigenCloud: $EIGEN_CLOUD"
    echo ""
    
    if [ -f "$ARP_CONFIG" ]; then
        echo "Current config:"
        cat "$ARP_CONFIG"
    else
        echo "No config yet. Create one with:"
        echo "  arp register"
    fi
}

# Parse command
case "${1:-help}" in
    register|reg)
        cmd_register
        ;;
    status|s)
        cmd_status
        ;;
    dashboard|d)
        cmd_dashboard
        ;;
    docs|doc)
        cmd_docs
        ;;
    config|c)
        cmd_config
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
CLI_EOF

chmod +x "$BIN_DIR/arp"

# Install skill for OpenClaw
echo -e "${BLUE}[4/6]${NC} Installing OpenClaw skill..."

# Download fresh skill.md
curl -sL "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/skill.md" > "$SKILL_DIR/SKILL.md"

# Create skill manifest
cat > "$SKILL_DIR/manifest.json" << EOF
{
  "name": "arp",
  "version": "$ARP_VERSION",
  "description": "Agent Reputation Protocol integration",
  "author": "ARP Team",
  "homepage": "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-",
  "commands": [
    "arp:register",
    "arp:status", 
    "arp:dashboard",
    "arp:tasks"
  ]
}
EOF

# Add to PATH
echo -e "${BLUE}[5/6]${NC} Adding to PATH..."

SHELL_RC=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.profile" ]; then
    SHELL_RC="$HOME/.profile"
fi

if [ -n "$SHELL_RC" ] && ! grep -q "$BIN_DIR" "$SHELL_RC"; then
    echo "" >> "$SHELL_RC"
    echo "# ARP (Agent Reputation Protocol)" >> "$SHELL_RC"
    echo 'export PATH="$HOME/.arp/bin:$PATH"' >> "$SHELL_RC"
    echo -e "${GREEN}✅ Added to $SHELL_RC${NC}"
fi

# Create config template
echo -e "${BLUE}[6/6]${NC} Creating config template..."

cat > "$INSTALL_DIR/config.json.template" << EOF
{
  "agentName": "YourAgentName",
  "agentBio": "What your agent does",
  "skills": ["AI", "automation", "tasks"],
  "contractAddress": "0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd",
  "eigenCloudAddress": "0x72aa0fa6bD35Cd6A5B0d1dB0591fDe9F844E5f66",
  "network": "base-mainnet",
  "rpcUrl": "https://mainnet.base.org"
}
EOF

echo ""
echo -e "${GREEN}✅ ARP installed successfully!${NC}"
echo ""
echo "═══════════════════════════════════════════════════"
echo ""
echo "🚀 Quick Start:"
echo ""
echo "   1. Reload your shell or run:"
echo "      export PATH=\"\$HOME/.arp/bin:\$PATH\""
echo ""
echo "   2. Register your agent:"
echo "      arp register"
echo ""
echo "   3. Check status:"
echo "      arp status"
echo ""
echo "   4. Open dashboard:"
echo "      arp dashboard"
echo ""
echo "═══════════════════════════════════════════════════"
echo ""
echo "📚 Documentation:"
echo "   Website: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-"
echo "   GitHub:  https://github.com/iamgaurangdesai/Agent-Reputation-Protocol-"
echo ""
echo "💬 Community:"
echo "   Moltbook: https://moltbook.com/m/arp"
echo ""
echo "═══════════════════════════════════════════════════"
echo ""

# Verify installation
if command -v arp &> /dev/null || [ -x "$BIN_DIR/arp" ]; then
    echo -e "${GREEN}✅ arp command ready${NC}"
    "$BIN_DIR/arp" --help
else
    echo -e "${YELLOW}⚠️  Please reload your shell or run:${NC}"
    echo "   export PATH=\"\$HOME/.arp/bin:\$PATH\""
fi

echo ""
echo -e "${GREEN}Installation complete! 🎉${NC}"
