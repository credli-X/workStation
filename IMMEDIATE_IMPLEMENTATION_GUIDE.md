# Immediate Implementation Guide
## Quick Start for Next Development Phase

**Based on**: Feature extraction from landing page analysis
**Priority**: High-impact features for MVP completion

---

## Phase 1A: SaaS Platform Foundation (THIS WEEK)

### Day 1-2: Database Schema Setup

**PostgreSQL Schema for SaaS Platform:**

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  full_name VARCHAR(255),
  access_level VARCHAR(50) DEFAULT 'free', -- free, founding, enterprise
  license_key VARCHAR(100) UNIQUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_login TIMESTAMP,
  is_active BOOLEAN DEFAULT true
);

-- User sessions
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(500) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);

-- Saved workflows
CREATE TABLE saved_workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  workflow_definition JSONB NOT NULL,
  category VARCHAR(100),
  is_public BOOLEAN DEFAULT false,
  is_template BOOLEAN DEFAULT false,
  execution_count INTEGER DEFAULT 0,
  success_rate DECIMAL(5,2),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Workflow executions
CREATE TABLE workflow_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  workflow_id UUID REFERENCES saved_workflows(id),
  status VARCHAR(50) NOT NULL, -- pending, running, completed, failed
  started_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  execution_time INTEGER, -- milliseconds
  result JSONB,
  error_message TEXT,
  metadata JSONB
);

-- Usage analytics
CREATE TABLE usage_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  date DATE NOT NULL,
  executions_count INTEGER DEFAULT 0,
  success_count INTEGER DEFAULT 0,
  failure_count INTEGER DEFAULT 0,
  total_execution_time INTEGER DEFAULT 0,
  workflows_created INTEGER DEFAULT 0,
  templates_used INTEGER DEFAULT 0,
  UNIQUE(user_id, date)
);

-- Subscriptions/Licenses
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL, -- one_time, subscription
  plan VARCHAR(100) NOT NULL, -- founding_cohort, enterprise
  status VARCHAR(50) NOT NULL, -- active, expired, cancelled
  payment_provider VARCHAR(50), -- stripe, paddle
  payment_id VARCHAR(255),
  amount_paid DECIMAL(10,2),
  currency VARCHAR(3) DEFAULT 'USD',
  purchased_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP,
  metadata JSONB
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_license ON users(license_key);
CREATE INDEX idx_sessions_token ON user_sessions(token);
CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_workflows_user ON saved_workflows(user_id);
CREATE INDEX idx_workflows_public ON saved_workflows(is_public, is_template);
CREATE INDEX idx_executions_user ON workflow_executions(user_id);
CREATE INDEX idx_executions_workflow ON workflow_executions(workflow_id);
CREATE INDEX idx_executions_status ON workflow_executions(status);
CREATE INDEX idx_usage_user_date ON usage_stats(user_id, date);
```

### Day 3: User Authentication API

**File**: `src/routes/auth.ts`

```typescript
import { Router, Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { generateToken, verifyToken } from '../auth/jwt';
import { db } from '../db/connection';
import { logger } from '../utils/logger';

const router = Router();

/**
 * Register new user
 * POST /api/auth/register
 */
router.post('/register', async (req: Request, res: Response) => {
  try {
    const { email, password, fullName } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Email and password are required'
      });
    }

    // Check if user exists
    const existingUser = await db.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        error: 'User already exists'
      });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Generate license key
    const licenseKey = `WS-${uuidv4().substring(0, 8).toUpperCase()}-${Date.now().toString(36).toUpperCase()}`;

    // Create user
    const result = await db.query(
      `INSERT INTO users (email, password_hash, full_name, license_key)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, full_name, access_level, license_key, created_at`,
      [email, passwordHash, fullName, licenseKey]
    );

    const user = result.rows[0];

    // Generate JWT
    const token = generateToken({
      userId: user.id,
      email: user.email,
      accessLevel: user.access_level
    });

    // Create session
    await db.query(
      `INSERT INTO user_sessions (user_id, token, expires_at, ip_address, user_agent)
       VALUES ($1, $2, NOW() + INTERVAL '30 days', $3, $4)`,
      [user.id, token, req.ip, req.headers['user-agent']]
    );

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          fullName: user.full_name,
          accessLevel: user.access_level,
          licenseKey: user.license_key
        },
        token
      }
    });
  } catch (error) {
    logger.error('Registration error', { error });
    res.status(500).json({
      success: false,
      error: 'Registration failed'
    });
  }
});

/**
 * Login
 * POST /api/auth/login
 */
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Email and password are required'
      });
    }

    // Find user
    const result = await db.query(
      'SELECT * FROM users WHERE email = $1 AND is_active = true',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    const user = result.rows[0];

    // Verify password
    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    // Generate JWT
    const token = generateToken({
      userId: user.id,
      email: user.email,
      accessLevel: user.access_level
    });

    // Create session
    await db.query(
      `INSERT INTO user_sessions (user_id, token, expires_at, ip_address, user_agent)
       VALUES ($1, $2, NOW() + INTERVAL '30 days', $3, $4)`,
      [user.id, token, req.ip, req.headers['user-agent']]
    );

    // Update last login
    await db.query(
      'UPDATE users SET last_login = NOW() WHERE id = $1',
      [user.id]
    );

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          fullName: user.full_name,
          accessLevel: user.access_level,
          licenseKey: user.license_key
        },
        token
      }
    });
  } catch (error) {
    logger.error('Login error', { error });
    res.status(500).json({
      success: false,
      error: 'Login failed'
    });
  }
});

/**
 * Logout
 * POST /api/auth/logout
 */
router.post('/logout', verifyToken, async (req: any, res: Response) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (token) {
      await db.query('DELETE FROM user_sessions WHERE token = $1', [token]);
    }

    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    logger.error('Logout error', { error });
    res.status(500).json({
      success: false,
      error: 'Logout failed'
    });
  }
});

/**
 * Get current user
 * GET /api/auth/me
 */
router.get('/me', verifyToken, async (req: any, res: Response) => {
  try {
    const result = await db.query(
      `SELECT id, email, full_name, access_level, license_key, created_at, last_login
       FROM users WHERE id = $1 AND is_active = true`,
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    logger.error('Get user error', { error });
    res.status(500).json({
      success: false,
      error: 'Failed to get user'
    });
  }
});

export default router;
```

### Day 4-5: User Dashboard API & Frontend

**Backend API**: `src/routes/dashboard.ts`

```typescript
import { Router, Request, Response } from 'express';
import { verifyToken } from '../auth/jwt';
import { db } from '../db/connection';
import { logger } from '../utils/logger';

const router = Router();

/**
 * Get user dashboard data
 * GET /api/dashboard
 */
router.get('/', verifyToken, async (req: any, res: Response) => {
  try {
    const userId = req.user.userId;

    // Get user stats
    const statsResult = await db.query(
      `SELECT 
        COUNT(DISTINCT w.id) as total_workflows,
        COUNT(DISTINCT we.id) as total_executions,
        COUNT(DISTINCT we.id) FILTER (WHERE we.status = 'completed') as successful_executions,
        COUNT(DISTINCT we.id) FILTER (WHERE we.status = 'failed') as failed_executions,
        COALESCE(SUM(we.execution_time), 0) as total_execution_time
       FROM users u
       LEFT JOIN saved_workflows w ON w.user_id = u.id
       LEFT JOIN workflow_executions we ON we.user_id = u.id
       WHERE u.id = $1`,
      [userId]
    );

    // Get recent executions
    const recentExecutions = await db.query(
      `SELECT we.id, we.status, we.started_at, we.completed_at, we.execution_time,
              w.name as workflow_name
       FROM workflow_executions we
       LEFT JOIN saved_workflows w ON w.id = we.workflow_id
       WHERE we.user_id = $1
       ORDER BY we.started_at DESC
       LIMIT 10`,
      [userId]
    );

    // Get saved workflows
    const workflows = await db.query(
      `SELECT id, name, description, category, execution_count, success_rate, created_at
       FROM saved_workflows
       WHERE user_id = $1
       ORDER BY updated_at DESC
       LIMIT 20`,
      [userId]
    );

    res.json({
      success: true,
      data: {
        stats: statsResult.rows[0],
        recentExecutions: recentExecutions.rows,
        workflows: workflows.rows
      }
    });
  } catch (error) {
    logger.error('Dashboard error', { error });
    res.status(500).json({
      success: false,
      error: 'Failed to load dashboard'
    });
  }
});

export default router;
```

---

## Required Package Installations

### Backend Dependencies

```bash
npm install bcrypt uuid @types/bcrypt @types/uuid
npm install pg @types/pg  # PostgreSQL client
npm install redis @types/redis  # For caching
```

### Database Setup

```bash
# Install PostgreSQL (if not already installed)
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib

# Create database
createdb workstation_saas

# Run schema
psql workstation_saas < schema.sql
```

---

## Integration Checklist

### Week 1 Deliverables

- [ ] PostgreSQL database schema created
- [ ] User registration endpoint (`POST /api/auth/register`)
- [ ] User login endpoint (`POST /api/auth/login`)
- [ ] User logout endpoint (`POST /api/auth/logout`)
- [ ] Get current user endpoint (`GET /api/auth/me`)
- [ ] Dashboard data endpoint (`GET /api/dashboard`)
- [ ] Database connection pool configured
- [ ] Session management implemented
- [ ] Password hashing with bcrypt
- [ ] License key generation

### Testing Requirements

```bash
# Test user registration
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","fullName":"Test User"}'

# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Test dashboard (with token)
curl http://localhost:3000/api/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Next Steps After Week 1

1. **Week 2**: Stripe integration for payment processing
2. **Week 3**: User dashboard UI with React
3. **Week 4**: Begin MCP container orchestration
4. **Week 5**: Agent communication layer

---

**Status**: Ready for immediate implementation
**Estimated Completion**: 5 days
**Priority**: Critical for SaaS platform foundation

