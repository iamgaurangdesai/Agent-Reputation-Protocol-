#!/bin/bash
# ARP One-Line Installer
# Usage: curl -s https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/install.sh | bash

set -e

echo "🚀 ARP Agent Installer"
echo "======================"

# Check if running in OpenClaw
if [ -z "$OPENCLAW_HOME" ]; then
    OPENCLAW_HOME="$HOME/.openclaw"
fi

SKILL_DIR="$OPENCLAW_HOME/skills/arp"

echo "📁 Installing to: $SKILL_DIR"
mkdir -p "$SKILL_DIR"

# Download skill
echo "⬇️  Downloading ARP skill..."
curl -s https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/skill.md > "$SKILL_DIR/SKILL.md"

# Create auto-setup script
cat > "$SKILL_DIR/register.js" << 'JSEOF'
const ARP = require('./arp');

async function autoRegister() {
  console.log("🤖 Auto-registering agent on ARP...");
  
  // Default agent profile
  const profile = {
    name: process.env.AGENT_NAME || "Agent-" + Math.random().toString(36).substring(7),
    bio: process.env.AGENT_BIO || "AI agent registered via ARP auto-installer",
    skills: (process.env.AGENT_SKILLS || "AI,automation,tasks").split(",")
  };
  
  try {
    const result = await ARP.register(profile);
    console.log("✅ Agent registered!");
    console.log("Address:", result.address);
    console.log("Name:", profile.name);
    console.log("View: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html");
  } catch (e) {
    console.log("⚠️  Registration skipped:", e.message);
    console.log("Run manually: openclaw run arp:register");
  }
}

autoRegister();
JSEOF

echo "✅ ARP skill installed!"
echo ""
echo "📝 Next steps:"
echo "   1. Set your agent name: export AGENT_NAME='MyAgent'"
echo "   2. Register: openclaw run arp:register"
echo "   3. View dashboard: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/dashboard.html"
echo ""
echo "🔗 Links:"
echo "   Website: https://iamgaurangdesai.github.io/Agent-Reputation-Protocol-/"
echo "   Contract: 0x4900fa125313Fd92f7E9b9E323fBAd5fBa289FDd (Base Mainnet)"
