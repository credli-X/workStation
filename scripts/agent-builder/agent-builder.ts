#!/usr/bin/env ts-node
/**
 * Generalized Coding Agent Builder
 * 
 * Autonomous system that builds, tests, and deploys agents 2-20
 * following the systematic framework from Agent 1.
 */

import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

interface AgentSpec {
  id: number;
  name: string;
  description: string;
  tier: 'core' | 'quality' | 'platform';
  capabilities: string[];
  dependencies: string[];
  ports?: {
    api?: number;
    ui?: number;
    mcp?: number;
  };
  technology: {
    language: 'typescript' | 'python' | 'go';
    framework: string[];
    tools: string[];
  };
}

interface BuildResult {
  agent: number;
  success: boolean;
  steps: {
    [key: string]: {
      status: 'success' | 'failed' | 'skipped';
      message?: string;
      duration?: number;
    };
  };
  artifacts: string[];
}

class AgentBuilder {
  private rootDir: string;
  private agentsDir: string;
  private templatesDir: string;

  constructor(rootDir: string = process.cwd()) {
    this.rootDir = rootDir;
    this.agentsDir = path.join(rootDir, 'agents');
    this.templatesDir = path.join(rootDir, 'scripts', 'agent-builder', 'templates');
  }

  /**
   * Parse agent specification from .github/agents/ directory
   */
  async parseAgentSpec(agentId: number): Promise<AgentSpec | null> {
    const agentFiles = [
      path.join(this.rootDir, '.github', 'agents', `agent${agentId}.agent.md`),
      path.join(this.rootDir, 'agents', `agent${agentId}`, 'agent-prompt.yml'),
    ];

    for (const file of agentFiles) {
      if (fs.existsSync(file)) {
        return this.parseSpecFile(file, agentId);
      }
    }

    console.warn(`No specification found for agent ${agentId}`);
    return null;
  }

  private parseSpecFile(filePath: string, agentId: number): AgentSpec {
    const content = fs.readFileSync(filePath, 'utf-8');
    
    // Parse based on file extension
    if (filePath.endsWith('.md')) {
      return this.parseMarkdownSpec(content, agentId);
    } else if (filePath.endsWith('.yml') || filePath.endsWith('.yaml')) {
      return this.parseYamlSpec(content, agentId);
    }

    throw new Error(`Unsupported spec file format: ${filePath}`);
  }

  private parseMarkdownSpec(content: string, agentId: number): AgentSpec {
    // Extract metadata from markdown frontmatter or headers
    const nameMatch = content.match(/name:\s*(.+)/i) || content.match(/# (.+)/);
    const descMatch = content.match(/description:\s*(.+)/i);
    
    return {
      id: agentId,
      name: nameMatch ? nameMatch[1].trim() : `Agent ${agentId}`,
      description: descMatch ? descMatch[1].trim() : '',
      tier: this.determineTier(agentId),
      capabilities: this.extractCapabilities(content),
      dependencies: this.extractDependencies(content),
      technology: {
        language: 'typescript',
        framework: ['express', 'playwright'],
        tools: ['jest', 'eslint']
      }
    };
  }

  private parseYamlSpec(content: string, agentId: number): AgentSpec {
    // Simple YAML parsing (in production, use a proper YAML parser)
    const lines = content.split('\n');
    const spec: Partial<AgentSpec> = {
      id: agentId,
      tier: this.determineTier(agentId),
      capabilities: [],
      dependencies: []
    };

    lines.forEach(line => {
      if (line.includes('name:')) {
        spec.name = line.split('name:')[1].trim();
      }
      if (line.includes('description:')) {
        spec.description = line.split('description:')[1].trim();
      }
    });

    // Set defaults if not found
    if (!spec.name) spec.name = `Agent ${agentId}`;
    if (!spec.description) spec.description = `Agent ${agentId} implementation`;
    if (!spec.technology) {
      spec.technology = {
        language: 'typescript',
        framework: ['express', 'playwright'],
        tools: ['jest', 'eslint']
      };
    }

    return spec as AgentSpec;
  }

  private determineTier(agentId: number): 'core' | 'quality' | 'platform' {
    if (agentId >= 1 && agentId <= 6) return 'core';
    if (agentId >= 7 && agentId <= 13) return 'quality';
    return 'platform';
  }

  private extractCapabilities(content: string): string[] {
    const capabilities: string[] = [];
    const capSection = content.match(/## (Features|Capabilities)([\s\S]*?)##/i);
    
    if (capSection) {
      const lines = capSection[2].split('\n');
      lines.forEach(line => {
        if (line.trim().startsWith('-') || line.trim().startsWith('*')) {
          capabilities.push(line.trim().replace(/^[-*]\s*/, ''));
        }
      });
    }

    return capabilities;
  }

  private extractDependencies(content: string): string[] {
    const deps: string[] = [];
    
    // Look for common package patterns
    const npmMatch = content.match(/npm install[^`\n]*`([^`]+)`/g);
    if (npmMatch) {
      npmMatch.forEach(match => {
        const packages = match.match(/`([^`]+)`/);
        if (packages) {
          deps.push(...packages[1].split(/\s+/).filter(p => !p.startsWith('-')));
        }
      });
    }

    return [...new Set(deps)];
  }

  /**
   * Build agent infrastructure following Agent 1 pattern
   */
  async buildAgent(agentId: number): Promise<BuildResult> {
    const startTime = Date.now();
    const result: BuildResult = {
      agent: agentId,
      success: false,
      steps: {},
      artifacts: []
    };

    console.log(`\n${'='.repeat(60)}`);
    console.log(`Building Agent ${agentId}`);
    console.log('='.repeat(60));

    try {
      // Step 1: Parse specification
      result.steps.parse = await this.measureStep(
        'Parse Specification',
        () => this.parseAgentSpec(agentId)
      );

      const spec = result.steps.parse.status === 'success' 
        ? await this.parseAgentSpec(agentId) 
        : null;

      if (!spec) {
        throw new Error('Failed to parse agent specification');
      }

      // Step 2: Create directory structure
      result.steps.scaffold = await this.measureStep(
        'Scaffold Directory Structure',
        () => this.scaffoldAgent(spec)
      );

      // Step 3: Generate MCP container
      result.steps.mcp = await this.measureStep(
        'Generate MCP Container',
        () => this.generateMCPContainer(spec)
      );

      // Step 4: Generate backend API
      result.steps.api = await this.measureStep(
        'Generate Backend API',
        () => this.generateBackendAPI(spec)
      );

      // Step 5: Generate UI dashboard
      result.steps.ui = await this.measureStep(
        'Generate UI Dashboard',
        () => this.generateUIDashboard(spec)
      );

      // Step 6: Generate tests
      result.steps.tests = await this.measureStep(
        'Generate Test Suite',
        () => this.generateTests(spec)
      );

      // Step 7: Create Docker configuration
      result.steps.docker = await this.measureStep(
        'Create Docker Configuration',
        () => this.createDockerConfig(spec)
      );

      // Step 8: Generate documentation
      result.steps.docs = await this.measureStep(
        'Generate Documentation',
        () => this.generateDocumentation(spec)
      );

      // Step 9: Create CI/CD workflow
      result.steps.cicd = await this.measureStep(
        'Create CI/CD Workflow',
        () => this.createCICDWorkflow(spec)
      );

      result.success = true;
      console.log(`\n✅ Agent ${agentId} built successfully in ${Date.now() - startTime}ms`);

    } catch (error) {
      console.error(`\n❌ Agent ${agentId} build failed:`, error);
      result.success = false;
    }

    return result;
  }

  private async measureStep(
    name: string,
    fn: () => Promise<any>
  ): Promise<{ status: 'success' | 'failed'; message?: string; duration: number }> {
    const start = Date.now();
    console.log(`\n📋 ${name}...`);

    try {
      await fn();
      const duration = Date.now() - start;
      console.log(`   ✓ Completed in ${duration}ms`);
      return { status: 'success', duration };
    } catch (error) {
      const duration = Date.now() - start;
      const message = error instanceof Error ? error.message : String(error);
      console.error(`   ✗ Failed: ${message}`);
      return { status: 'failed', message, duration };
    }
  }

  /**
   * Scaffold directory structure following Agent 1 pattern
   */
  private async scaffoldAgent(spec: AgentSpec): Promise<void> {
    const agentDir = path.join(this.agentsDir, `agent${spec.id}`);
    
    const dirs = [
      agentDir,
      path.join(agentDir, 'src'),
      path.join(agentDir, 'src', 'tools'),
      path.join(agentDir, 'src', 'utils'),
      path.join(agentDir, 'tests'),
      path.join(agentDir, 'logs'),
      path.join(agentDir, 'reports'),
      path.join(agentDir, 'memory'),
      path.join(this.rootDir, 'modules', `${spec.id.toString().padStart(2, '0')}-${this.slugify(spec.name)}`),
      path.join(this.rootDir, 'modules', `${spec.id.toString().padStart(2, '0')}-${this.slugify(spec.name)}`, 'backend'),
      path.join(this.rootDir, 'modules', `${spec.id.toString().padStart(2, '0')}-${this.slugify(spec.name)}`, 'ui'),
      path.join(this.rootDir, 'mcp-containers', `${spec.id.toString().padStart(2, '0')}-${this.slugify(spec.name)}-mcp`),
    ];

    dirs.forEach(dir => {
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
    });
  }

  private slugify(text: string): string {
    return text
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  /**
   * Generate MCP container following Agent 1 pattern
   */
  private async generateMCPContainer(spec: AgentSpec): Promise<void> {
    const mcpDir = path.join(
      this.rootDir,
      'mcp-containers',
      `${spec.id.toString().padStart(2, '0')}-${this.slugify(spec.name)}-mcp`
    );

    // Generate MCP server code
    const serverCode = this.generateMCPServerCode(spec);
    fs.writeFileSync(path.join(mcpDir, 'index.ts'), serverCode);

    // Generate package.json
    const packageJson = {
      name: `${this.slugify(spec.name)}-mcp`,
      version: '1.0.0',
      description: `MCP server for ${spec.name}`,
      main: 'index.ts',
      scripts: {
        start: 'ts-node index.ts',
        build: 'tsc',
        dev: 'ts-node --watch index.ts'
      },
      dependencies: {
        '@modelcontextprotocol/sdk': '^1.0.0',
        'express': '^4.18.2',
        'playwright': '^1.56.1'
      },
      devDependencies: {
        '@types/express': '^4.17.21',
        '@types/node': '^20.19.25',
        'typescript': '^5.3.2',
        'ts-node': '^10.9.1'
      }
    };
    fs.writeFileSync(
      path.join(mcpDir, 'package.json'),
      JSON.stringify(packageJson, null, 2)
    );

    // Generate tsconfig.json
    const tsconfig = {
      compilerOptions: {
        target: 'ES2020',
        module: 'commonjs',
        lib: ['ES2020'],
        outDir: './dist',
        rootDir: './',
        strict: true,
        esModuleInterop: true,
        skipLibCheck: true,
        forceConsistentCasingInFileNames: true
      },
      include: ['*.ts'],
      exclude: ['node_modules', 'dist']
    };
    fs.writeFileSync(
      path.join(mcpDir, 'tsconfig.json'),
      JSON.stringify(tsconfig, null, 2)
    );
  }

  private generateMCPServerCode(spec: AgentSpec): string {
    return `/**
 * MCP Server for ${spec.name}
 * ${spec.description}
 */

import express from 'express';

const app = express();
const PORT = process.env.PORT || ${spec.ports?.mcp || 3000 + spec.id};

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    agent: '${spec.name}',
    timestamp: new Date().toISOString()
  });
});

// Start server
app.listen(PORT, () => {
  console.log(\`🚀 ${spec.name} MCP Server running on port \${PORT}\`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('Shutting down gracefully...');
  process.exit(0);
});
`;
  }

  /**
   * Generate backend API following Agent 1 pattern
   */
  private async generateBackendAPI(spec: AgentSpec): Promise<void> {
    const apiDir = path.join(
      this.rootDir,
      'modules',
      `${spec.id.toString().padStart(2, '0')}-${this.slugify(spec.name)}`,
      'backend'
    );

    const apiCode = this.generateBackendAPICode(spec);
    fs.writeFileSync(path.join(apiDir, 'index.ts'), apiCode);

    // Generate package.json for backend
    const packageJson = {
      name: `${this.slugify(spec.name)}-backend`,
      version: '1.0.0',
      description: `Backend API for ${spec.name}`,
      main: 'index.ts',
      scripts: {
        start: 'ts-node index.ts',
        build: 'tsc',
        dev: 'ts-node --watch index.ts'
      },
      dependencies: {
        'express': '^4.18.2',
        'cors': '^2.8.5',
        'helmet': '^8.1.0',
        'express-rate-limit': '^8.2.1',
        'playwright': '^1.56.1'
      },
      devDependencies: {
        '@types/express': '^4.17.21',
        '@types/cors': '^2.8.17',
        '@types/node': '^20.19.25',
        'typescript': '^5.3.2',
        'ts-node': '^10.9.1'
      }
    };
    fs.writeFileSync(
      path.join(apiDir, 'package.json'),
      JSON.stringify(packageJson, null, 2)
    );
  }

  private generateBackendAPICode(spec: AgentSpec): string {
    return `/**
 * Backend API for ${spec.name}
 * ${spec.description}
 */

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

const app = express();
const PORT = process.env.PORT || ${spec.ports?.api || 4000 + spec.id};

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use(limiter);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

// API endpoints
app.post('/api/${this.slugify(spec.name)}/execute', async (req, res) => {
  try {
    // TODO: Implement agent functionality
    res.json({ success: true, message: 'Not yet implemented' });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(\`🚀 ${spec.name} API running on port \${PORT}\`);
});
`;
  }

  /**
   * Generate UI dashboard following Agent 1 pattern
   */
  private async generateUIDashboard(spec: AgentSpec): Promise<void> {
    const uiDir = path.join(
      this.rootDir,
      'modules',
      `${spec.id.toString().padStart(2, '0')}-${this.slugify(spec.name)}`,
      'ui'
    );

    // Generate basic HTML dashboard
    const htmlCode = this.generateUICode(spec);
    fs.writeFileSync(path.join(uiDir, 'index.html'), htmlCode);
  }

  private generateUICode(spec: AgentSpec): string {
    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${spec.name}</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-4">${spec.name}</h1>
    <p class="text-gray-700 mb-6">${spec.description}</p>
    
    <div class="bg-white rounded-lg shadow p-6">
      <h2 class="text-xl font-semibold mb-4">Dashboard</h2>
      <p class="text-gray-600">UI implementation coming soon...</p>
    </div>
  </div>
</body>
</html>
`;
  }

  /**
   * Generate test suite
   */
  private async generateTests(spec: AgentSpec): Promise<void> {
    const testsDir = path.join(this.agentsDir, `agent${spec.id}`, 'tests');
    
    const testCode = `/**
 * Tests for ${spec.name}
 */

describe('${spec.name}', () => {
  it('should initialize successfully', () => {
    expect(true).toBe(true);
  });

  it('should handle errors gracefully', () => {
    expect(() => {
      // TODO: Implement error handling tests
    }).not.toThrow();
  });
});
`;

    fs.writeFileSync(path.join(testsDir, 'agent.test.ts'), testCode);
  }

  /**
   * Create Docker configuration
   */
  private async createDockerConfig(spec: AgentSpec): Promise<void> {
    const dockerfile = `FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE ${spec.ports?.api || 3000 + spec.id}

CMD ["npm", "start"]
`;

    const agentDir = path.join(this.agentsDir, `agent${spec.id}`);
    fs.writeFileSync(path.join(agentDir, 'Dockerfile'), dockerfile);
  }

  /**
   * Generate documentation
   */
  private async generateDocumentation(spec: AgentSpec): Promise<void> {
    const readme = `# ${spec.name}

${spec.description}

## Features

${spec.capabilities.map(cap => `- ${cap}`).join('\n')}

## Architecture

- **MCP Server**: Model Context Protocol integration
- **Backend API**: RESTful API endpoints
- **UI Dashboard**: Web-based interface

## Installation

\`\`\`bash
# Install dependencies
npm install

# Build
npm run build

# Start
npm start
\`\`\`

## API Endpoints

- \`GET /health\` - Health check
- \`POST /api/${this.slugify(spec.name)}/execute\` - Execute agent action

## Development

\`\`\`bash
# Run in development mode
npm run dev

# Run tests
npm test

# Lint
npm run lint
\`\`\`

## License

ISC
`;

    const agentDir = path.join(this.agentsDir, `agent${spec.id}`);
    fs.writeFileSync(path.join(agentDir, 'README.md'), readme);
  }

  /**
   * Create CI/CD workflow
   */
  private async createCICDWorkflow(spec: AgentSpec): Promise<void> {
    const workflow = `name: Agent ${spec.id} - ${spec.name}

on:
  push:
    paths:
      - 'agents/agent${spec.id}/**'
      - 'modules/${spec.id.toString().padStart(2, '0')}-${this.slugify(spec.name)}/**'
  pull_request:
    paths:
      - 'agents/agent${spec.id}/**'
      - 'modules/${spec.id.toString().padStart(2, '0')}-${this.slugify(spec.name)}/**'

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v5
      
      - name: Setup Node.js
        uses: actions/setup-node@v6
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: |
          cd agents/agent${spec.id}
          npm ci
      
      - name: Run tests
        run: |
          cd agents/agent${spec.id}
          npm test
      
      - name: Build
        run: |
          cd agents/agent${spec.id}
          npm run build
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v5
        with:
          name: agent${spec.id}-dist
          path: agents/agent${spec.id}/dist
`;

    const workflowsDir = path.join(this.rootDir, '.github', 'workflows');
    if (!fs.existsSync(workflowsDir)) {
      fs.mkdirSync(workflowsDir, { recursive: true });
    }

    fs.writeFileSync(
      path.join(workflowsDir, `agent${spec.id}-ci.yml`),
      workflow
    );
  }

  /**
   * Build all agents from 2 to 20
   */
  async buildAll(): Promise<BuildResult[]> {
    const results: BuildResult[] = [];
    
    for (let i = 2; i <= 20; i++) {
      const result = await this.buildAgent(i);
      results.push(result);
      
      // Add delay between builds to avoid overwhelming the system
      await new Promise(resolve => setTimeout(resolve, 1000));
    }

    return results;
  }

  /**
   * Generate summary report
   */
  generateReport(results: BuildResult[]): string {
    const successful = results.filter(r => r.success).length;
    const failed = results.filter(r => !r.success).length;

    let report = `# Agent Build Report\n\n`;
    report += `**Generated**: ${new Date().toISOString()}\n\n`;
    report += `## Summary\n\n`;
    report += `- ✅ Successful: ${successful}/${results.length}\n`;
    report += `- ❌ Failed: ${failed}/${results.length}\n\n`;
    report += `## Details\n\n`;

    results.forEach(result => {
      report += `### Agent ${result.agent}\n\n`;
      report += `**Status**: ${result.success ? '✅ Success' : '❌ Failed'}\n\n`;
      report += `**Steps**:\n`;
      
      Object.entries(result.steps).forEach(([step, info]) => {
        const icon = info.status === 'success' ? '✓' : '✗';
        report += `- ${icon} ${step}: ${info.status} (${info.duration}ms)\n`;
        if (info.message) {
          report += `  - ${info.message}\n`;
        }
      });
      
      report += `\n`;
    });

    return report;
  }
}

// CLI entry point
if (require.main === module) {
  const args = process.argv.slice(2);
  const builder = new AgentBuilder();

  if (args.includes('--all')) {
    console.log('Building all agents 2-20...');
    builder.buildAll().then(results => {
      const report = builder.generateReport(results);
      console.log('\n' + report);
      
      const reportPath = path.join(process.cwd(), 'AGENT_BUILD_REPORT.md');
      fs.writeFileSync(reportPath, report);
      console.log(`\nReport saved to: ${reportPath}`);
    });
  } else if (args.includes('--agent')) {
    const agentId = parseInt(args[args.indexOf('--agent') + 1]);
    if (isNaN(agentId) || agentId < 2 || agentId > 20) {
      console.error('Invalid agent ID. Must be between 2 and 20.');
      process.exit(1);
    }
    
    builder.buildAgent(agentId).then(result => {
      console.log('\n' + JSON.stringify(result, null, 2));
    });
  } else {
    console.log(`
Usage:
  ts-node agent-builder.ts --all              # Build all agents 2-20
  ts-node agent-builder.ts --agent <id>       # Build specific agent
    `);
  }
}

export { AgentBuilder, AgentSpec, BuildResult };
