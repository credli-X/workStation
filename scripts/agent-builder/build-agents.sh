#!/bin/bash
#
# Generalized Agent Builder - Entry Point
#
# Usage:
#   ./build-agents.sh --agent <id>       # Build specific agent
#   ./build-agents.sh --all              # Build all agents 2-20
#   ./build-agents.sh --deploy <id>      # Build and deploy agent
#   ./build-agents.sh --deploy-all       # Build and deploy all
#   ./build-agents.sh --rollback <id>    # Rollback agent

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$ROOT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print banner
print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         Generalized Coding Agent Builder v1.0.0             ║"
    echo "║              Autonomous Agent Development System             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print usage
print_usage() {
    echo "Usage:"
    echo "  $0 --agent <id>         Build specific agent (2-20)"
    echo "  $0 --all                Build all agents (2-20)"
    echo "  $0 --deploy <id>        Build and deploy agent"
    echo "  $0 --deploy-all         Build and deploy all agents"
    echo "  $0 --rollback <id>      Rollback agent to previous version"
    echo "  $0 --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --agent 2            # Build agent 2"
    echo "  $0 --deploy 3           # Build and deploy agent 3"
    echo "  $0 --all                # Build all agents"
    echo "  $0 --rollback 2         # Rollback agent 2"
}

# Check if npm and ts-node are available
check_dependencies() {
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}Error: npm not found. Please install Node.js and npm.${NC}"
        exit 1
    fi

    if ! command -v npx &> /dev/null; then
        echo -e "${RED}Error: npx not found. Please install Node.js and npm.${NC}"
        exit 1
    fi
}

# Build single agent
build_agent() {
    local agent_id=$1
    
    echo -e "${GREEN}Building Agent ${agent_id}...${NC}"
    npx ts-node scripts/agent-builder/agent-builder.ts --agent "$agent_id"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Agent ${agent_id} built successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Agent ${agent_id} build failed${NC}"
        return 1
    fi
}

# Build all agents
build_all_agents() {
    echo -e "${GREEN}Building all agents (2-20)...${NC}"
    npx ts-node scripts/agent-builder/agent-builder.ts --all
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ All agents built successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Some agents failed to build${NC}"
        return 1
    fi
}

# Deploy agent (build + validation + deployment)
deploy_agent() {
    local agent_id=$1
    
    echo -e "${GREEN}Deploying Agent ${agent_id}...${NC}"
    npx ts-node scripts/agent-builder/orchestrator.ts --agent "$agent_id"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Agent ${agent_id} deployed successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Agent ${agent_id} deployment failed${NC}"
        return 1
    fi
}

# Deploy all agents
deploy_all_agents() {
    echo -e "${GREEN}Deploying all agents (2-20)...${NC}"
    npx ts-node scripts/agent-builder/orchestrator.ts --all
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ All agents deployed successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Some agents failed to deploy${NC}"
        return 1
    fi
}

# Rollback agent
rollback_agent() {
    local agent_id=$1
    
    echo -e "${YELLOW}Rolling back Agent ${agent_id}...${NC}"
    npx ts-node scripts/agent-builder/orchestrator.ts --rollback "$agent_id"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Agent ${agent_id} rolled back successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Agent ${agent_id} rollback failed${NC}"
        return 1
    fi
}

# Main execution
main() {
    print_banner
    check_dependencies
    
    if [ $# -eq 0 ]; then
        print_usage
        exit 1
    fi
    
    case "$1" in
        --agent)
            if [ -z "$2" ]; then
                echo -e "${RED}Error: Agent ID required${NC}"
                print_usage
                exit 1
            fi
            
            if [ "$2" -lt 2 ] || [ "$2" -gt 20 ]; then
                echo -e "${RED}Error: Agent ID must be between 2 and 20${NC}"
                exit 1
            fi
            
            build_agent "$2"
            ;;
            
        --all)
            build_all_agents
            ;;
            
        --deploy)
            if [ -z "$2" ]; then
                echo -e "${RED}Error: Agent ID required${NC}"
                print_usage
                exit 1
            fi
            
            if [ "$2" -lt 2 ] || [ "$2" -gt 20 ]; then
                echo -e "${RED}Error: Agent ID must be between 2 and 20${NC}"
                exit 1
            fi
            
            deploy_agent "$2"
            ;;
            
        --deploy-all)
            deploy_all_agents
            ;;
            
        --rollback)
            if [ -z "$2" ]; then
                echo -e "${RED}Error: Agent ID required${NC}"
                print_usage
                exit 1
            fi
            
            if [ "$2" -lt 2 ] || [ "$2" -gt 20 ]; then
                echo -e "${RED}Error: Agent ID must be between 2 and 20${NC}"
                exit 1
            fi
            
            rollback_agent "$2"
            ;;
            
        --help|-h)
            print_usage
            ;;
            
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
}

main "$@"
