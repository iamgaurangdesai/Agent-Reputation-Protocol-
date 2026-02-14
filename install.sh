#!/bin/bash
# ARP One-Line Installer
# Usage: curl -fsSL .../install.sh | bash && arp setup

set -e

INSTALL_DIR="$HOME/.arp"
BIN_DIR="$INSTALL_DIR/bin"

echo "Installing ARP..."

# Create dirs
mkdir -p "$BIN_DIR"

# Create main arp CLI
cat > "$BIN_DIR/arp" << 'EOF'
#!/bin/bash

ARP_CONTRACT="0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd"

show_help() {
    echo "ARP - Agent Reputation Protocol"
    echo ""
    echo "Commands:"
    echo "  arp setup     - Setup and register your agent"
    echo "  arp status    - Check your reputation"
    echo "  arp help      - Show this help"
}

cmd_setup() {
    echo "🚀 ARP Agent Setup"
    echo ""
    echo "Step 1: Opening registration page..."
    echo "   Please connect your MetaMask wallet on Base Mainnet"
    echo ""
    
    # Open browser
    if command -v open &> /dev/null; then
        open "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/"
    else
        echo "   Open: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/"
    fi
    
    echo ""
    echo "Step 2: Follow the on-screen steps:"
    echo "   • Connect wallet"
    echo "   • Enter agent name"
    echo "   • Pay 0.001 ETH (Base Mainnet)"
    echo "   • Enable skills"
    echo ""
    echo "✓ Done! Your agent is now live."
}

cmd_status() {
    echo "📊 Opening dashboard..."
    if command -v open &> /dev/null; then
        open "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html"
    else
        echo "Open: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html"
    fi
}

case "${1:-help}" in
    setup|s)
        cmd_setup
        ;;
    status|st)
        cmd_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac
EOF

chmod +x "$BIN_DIR/arp"

# Add to PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    if [ -f "$HOME/.bashrc" ]; then
        echo 'export PATH="$HOME/.arp/bin:$PATH"' >> "$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        echo 'export PATH="$HOME/.arp/bin:$PATH"' >> "$HOME/.zshrc"
    fi
fi

# Export for current session
export PATH="$BIN_DIR:$PATH"

echo ""
echo "✅ ARP installed!"
echo ""
echo "Next: Run 'arp setup' to register your agent"
EOF

chmod +x install.sh

git add skill.md install.sh && git commit -m "Simplify to ONE LINE: curl ... | bash && arp setup" && git push origin main 2>&1 | tail -5