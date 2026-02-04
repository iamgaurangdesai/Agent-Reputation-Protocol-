#!/bin/bash

# ARP Production Deployment Script
# Usage: ./deploy.sh [backend|frontend|all]

set -e

echo "🚀 ARP Production Deployment"
echo "============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

deploy_backend() {
    echo -e "${YELLOW}📦 Deploying Backend to Railway...${NC}"
    cd fullstack/backend
    
    # Check if railway CLI is installed
    if ! command -v railway &> /dev/null; then
        echo -e "${RED}❌ Railway CLI not found. Installing...${NC}"
        npm install -g @railway/cli
    fi
    
    # Login if not already
    railway login
    
    # Link to project
    railway link
    
    # Deploy
    railway up
    
    echo -e "${GREEN}✅ Backend deployed!${NC}"
    cd ../..
}

deploy_frontend() {
    echo -e "${YELLOW}🌐 Deploying Frontend to Vercel...${NC}"
    cd fullstack/frontend
    
    # Check if vercel CLI is installed
    if ! command -v vercel &> /dev/null; then
        echo -e "${RED}❌ Vercel CLI not found. Installing...${NC}"
        npm install -g vercel
    fi
    
    # Deploy
    vercel --prod
    
    echo -e "${GREEN}✅ Frontend deployed!${NC}"
    cd ../..
}

# Main
case "${1:-all}" in
    backend)
        deploy_backend
        ;;
    frontend)
        deploy_frontend
        ;;
    all)
        deploy_backend
        deploy_frontend
        echo ""
        echo -e "${GREEN}🎉 Full stack deployed!${NC}"
        ;;
    *)
        echo "Usage: ./deploy.sh [backend|frontend|all]"
        exit 1
        ;;
esac

echo ""
echo "📋 Next steps:"
echo "1. Update Privy dashboard with new URLs"
echo "2. Test the deployment"
echo "3. Share the frontend URL!"