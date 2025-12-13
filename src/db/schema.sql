-- Workstation SaaS Platform Database Schema
-- PostgreSQL 12+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  full_name VARCHAR(255),
  access_level VARCHAR(50) DEFAULT 'free' CHECK (access_level IN ('free', 'founding', 'enterprise')),
  license_key VARCHAR(100) UNIQUE,
  github_id VARCHAR(100) UNIQUE,
  github_username VARCHAR(255),
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- User sessions
CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(500) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT,
  is_valid BOOLEAN DEFAULT true
);

-- Saved workflows
CREATE TABLE IF NOT EXISTS saved_workflows (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  workflow_definition JSONB NOT NULL,
  category VARCHAR(100),
  tags TEXT[],
  is_public BOOLEAN DEFAULT false,
  is_template BOOLEAN DEFAULT false,
  execution_count INTEGER DEFAULT 0,
  success_count INTEGER DEFAULT 0,
  failure_count INTEGER DEFAULT 0,
  success_rate DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE 
      WHEN execution_count > 0 THEN (success_count::decimal / execution_count::decimal * 100)
      ELSE 0
    END
  ) STORED,
  average_execution_time INTEGER, -- milliseconds
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Workflow executions
CREATE TABLE IF NOT EXISTS workflow_executions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  workflow_id UUID REFERENCES saved_workflows(id) ON DELETE SET NULL,
  status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'running', 'completed', 'failed', 'cancelled')),
  started_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  execution_time INTEGER, -- milliseconds
  result JSONB,
  error_message TEXT,
  steps_completed INTEGER DEFAULT 0,
  total_steps INTEGER DEFAULT 0,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Usage analytics (daily aggregates)
CREATE TABLE IF NOT EXISTS usage_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  executions_count INTEGER DEFAULT 0,
  success_count INTEGER DEFAULT 0,
  failure_count INTEGER DEFAULT 0,
  total_execution_time INTEGER DEFAULT 0, -- milliseconds
  workflows_created INTEGER DEFAULT 0,
  templates_used INTEGER DEFAULT 0,
  UNIQUE(user_id, date)
);

-- Subscriptions/Licenses
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL CHECK (type IN ('one_time', 'subscription')),
  plan VARCHAR(100) NOT NULL,
  status VARCHAR(50) NOT NULL CHECK (status IN ('active', 'expired', 'cancelled', 'pending')),
  payment_provider VARCHAR(50),
  payment_id VARCHAR(255),
  amount_paid DECIMAL(10,2),
  currency VARCHAR(3) DEFAULT 'USD',
  purchased_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Agent registry
CREATE TABLE IF NOT EXISTS agents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  agent_number INTEGER UNIQUE NOT NULL,
  type VARCHAR(100) NOT NULL,
  description TEXT,
  status VARCHAR(50) DEFAULT 'inactive' CHECK (status IN ('active', 'inactive', 'error', 'starting')),
  container_id VARCHAR(255),
  port INTEGER,
  health_check_url TEXT,
  last_health_check TIMESTAMP,
  is_healthy BOOLEAN DEFAULT false,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Agent tasks queue
CREATE TABLE IF NOT EXISTS agent_tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
  workflow_execution_id UUID REFERENCES workflow_executions(id) ON DELETE CASCADE,
  task_type VARCHAR(100) NOT NULL,
  payload JSONB NOT NULL,
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'assigned', 'running', 'completed', 'failed')),
  priority INTEGER DEFAULT 0,
  assigned_at TIMESTAMP,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  result JSONB,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_license ON users(license_key);
CREATE INDEX IF NOT EXISTS idx_users_github ON users(github_id);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON user_sessions(token);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_valid ON user_sessions(is_valid, expires_at);
CREATE INDEX IF NOT EXISTS idx_workflows_user ON saved_workflows(user_id);
CREATE INDEX IF NOT EXISTS idx_workflows_public ON saved_workflows(is_public, is_template);
CREATE INDEX IF NOT EXISTS idx_workflows_category ON saved_workflows(category);
CREATE INDEX IF NOT EXISTS idx_executions_user ON workflow_executions(user_id);
CREATE INDEX IF NOT EXISTS idx_executions_workflow ON workflow_executions(workflow_id);
CREATE INDEX IF NOT EXISTS idx_executions_status ON workflow_executions(status);
CREATE INDEX IF NOT EXISTS idx_executions_started ON workflow_executions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_usage_user_date ON usage_stats(user_id, date);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_agents_number ON agents(agent_number);
CREATE INDEX IF NOT EXISTS idx_agents_status ON agents(status);
CREATE INDEX IF NOT EXISTS idx_agent_tasks_agent ON agent_tasks(agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_tasks_status ON agent_tasks(status, priority DESC);
CREATE INDEX IF NOT EXISTS idx_agent_tasks_workflow ON agent_tasks(workflow_execution_id);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflows_updated_at BEFORE UPDATE ON saved_workflows
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agents_updated_at BEFORE UPDATE ON agents
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update workflow statistics
CREATE OR REPLACE FUNCTION update_workflow_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' THEN
    UPDATE saved_workflows
    SET 
      execution_count = execution_count + 1,
      success_count = success_count + 1,
      average_execution_time = (
        COALESCE(average_execution_time * execution_count, 0) + NEW.execution_time
      ) / (execution_count + 1)
    WHERE id = NEW.workflow_id;
  ELSIF NEW.status = 'failed' THEN
    UPDATE saved_workflows
    SET 
      execution_count = execution_count + 1,
      failure_count = failure_count + 1
    WHERE id = NEW.workflow_id;
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_workflow_stats_trigger
  AFTER UPDATE ON workflow_executions
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status AND NEW.status IN ('completed', 'failed'))
  EXECUTE FUNCTION update_workflow_stats();

-- Insert default agents
INSERT INTO agents (agent_number, name, type, description, status) VALUES
  (1, 'TypeScript API Architect', 'build-setup', 'Builds production-ready TypeScript APIs', 'inactive'),
  (2, 'Navigation Helper', 'build-setup', 'Browser automation and navigation', 'inactive'),
  (3, 'Data Extraction Specialist', 'build-setup', 'Extracts and processes data from web pages', 'inactive'),
  (4, 'Error Handling Expert', 'build-setup', 'Implements robust error handling', 'inactive'),
  (5, 'DevOps & Containerization', 'build-setup', 'Docker and deployment automation', 'inactive'),
  (6, 'Project Builder', 'build-setup', 'Scaffolds new projects', 'inactive'),
  (7, 'Code Quality Monitor', 'weekly-cycle', 'Analyzes code quality', 'inactive'),
  (8, 'Performance Monitor', 'weekly-cycle', 'Tracks performance metrics', 'inactive'),
  (9, 'Error Tracker', 'weekly-cycle', 'Monitors and tracks errors', 'inactive'),
  (10, 'Security Scanner', 'weekly-cycle', 'Scans for security vulnerabilities', 'inactive'),
  (11, 'Accessibility Checker', 'weekly-cycle', 'Validates accessibility compliance', 'inactive'),
  (12, 'Integration Hub', 'weekly-cycle', 'Manages third-party integrations', 'inactive'),
  (13, 'Docs Auditor', 'weekly-cycle', 'Audits documentation quality', 'inactive'),
  (14, 'Advanced Automation', 'advanced', 'Complex automation workflows', 'inactive'),
  (15, 'API Integrator', 'advanced', 'Integrates with external APIs', 'inactive'),
  (16, 'Data Processor', 'advanced', 'Processes and transforms data', 'inactive'),
  (17, 'Learning Platform', 'advanced', 'Educational content delivery', 'inactive'),
  (18, 'Community Hub', 'advanced', 'Manages community features', 'inactive'),
  (19, 'Deployment Manager', 'advanced', 'Handles deployments', 'inactive'),
  (20, 'Master Orchestrator', 'advanced', 'Coordinates all agents', 'inactive'),
  (21, 'MCP Generator', 'advanced', 'Generates MCP configurations', 'inactive')
ON CONFLICT (agent_number) DO NOTHING;
