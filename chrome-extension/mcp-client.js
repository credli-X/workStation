/**
 * MCP Client for Chrome Extension
 * Handles WebSocket communication with MCP backend
 */

class MCPClient {
  constructor() {
    this.ws = null;
    this.connected = false;
    this.messageHandlers = new Map();
    this.requestCallbacks = new Map();
    this.subscriptions = new Set();
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectDelay = 1000;
  }

  /**
   * Connect to MCP WebSocket server
   */
  async connect(url) {
    if (this.ws && this.connected) {
      console.log('[MCPClient] Already connected');
      return;
    }

    return new Promise((resolve, reject) => {
      try {
        this.ws = new WebSocket(url || 'ws://localhost:7042/mcp');

        this.ws.onopen = () => {
          console.log('[MCPClient] Connected to MCP server');
          this.connected = true;
          this.reconnectAttempts = 0;
          resolve();
        };

        this.ws.onmessage = (event) => {
          try {
            const message = JSON.parse(event.data);
            this.handleMessage(message);
          } catch (error) {
            console.error('[MCPClient] Error parsing message:', error);
          }
        };

        this.ws.onerror = (error) => {
          console.error('[MCPClient] WebSocket error:', error);
          reject(error);
        };

        this.ws.onclose = () => {
          console.log('[MCPClient] Disconnected from MCP server');
          this.connected = false;
          this.attemptReconnect(url);
        };
      } catch (error) {
        console.error('[MCPClient] Connection error:', error);
        reject(error);
      }
    });
  }

  /**
   * Attempt to reconnect
   */
  attemptReconnect(url) {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('[MCPClient] Max reconnection attempts reached');
      return;
    }

    this.reconnectAttempts++;
    const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);
    
    console.log(`[MCPClient] Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
    
    setTimeout(() => {
      this.connect(url).catch(console.error);
    }, delay);
  }

  /**
   * Handle incoming message
   */
  handleMessage(message) {
    switch (message.type) {
      case 'response':
        this.handleResponse(message);
        break;
      
      case 'notification':
        this.handleNotification(message);
        break;
      
      default:
        console.warn('[MCPClient] Unknown message type:', message.type);
    }
  }

  /**
   * Handle response message
   */
  handleResponse(message) {
    const callback = this.requestCallbacks.get(message.id);
    if (callback) {
      if (message.error) {
        callback.reject(message.error);
      } else {
        callback.resolve(message.result);
      }
      this.requestCallbacks.delete(message.id);
    }
  }

  /**
   * Handle notification message
   */
  handleNotification(message) {
    const { method, params } = message;
    
    // Handle special notifications
    if (method === 'connected') {
      console.log('[MCPClient] Server config:', params.config);
      this.emit('connected', params);
      return;
    }

    // Call registered handlers
    const handlers = this.messageHandlers.get(method);
    if (handlers) {
      handlers.forEach(handler => handler(params));
    }

    // Emit generic event
    this.emit(method, params);
  }

  /**
   * Send a request
   */
  async request(method, params = {}) {
    if (!this.connected) {
      throw new Error('Not connected to MCP server');
    }

    return new Promise((resolve, reject) => {
      const id = `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      
      this.requestCallbacks.set(id, { resolve, reject });

      this.ws.send(JSON.stringify({
        type: 'request',
        id,
        method,
        params,
      }));

      // Timeout after 30 seconds
      setTimeout(() => {
        if (this.requestCallbacks.has(id)) {
          this.requestCallbacks.delete(id);
          reject(new Error('Request timeout'));
        }
      }, 30000);
    });
  }

  /**
   * Send a notification
   */
  notify(method, params = {}) {
    if (!this.connected) {
      console.warn('[MCPClient] Not connected, cannot send notification');
      return;
    }

    this.ws.send(JSON.stringify({
      type: 'notification',
      method,
      params,
    }));
  }

  /**
   * Subscribe to a channel
   */
  async subscribe(channel, handler) {
    if (!this.connected) {
      throw new Error('Not connected to MCP server');
    }

    const result = await this.request('subscribe', { channel });
    
    if (result.subscribed) {
      this.subscriptions.add(channel);
      
      // Register handler for messages from this channel
      if (handler) {
        this.on('message', (params) => {
          if (params.channel === channel) {
            handler(params.message);
          }
        });
      }
    }

    return result;
  }

  /**
   * Unsubscribe from a channel
   */
  async unsubscribe(channel) {
    if (!this.connected) {
      return;
    }

    const result = await this.request('unsubscribe', { channel });
    
    if (result.unsubscribed) {
      this.subscriptions.delete(channel);
    }

    return result;
  }

  /**
   * Register event handler
   */
  on(event, handler) {
    if (!this.messageHandlers.has(event)) {
      this.messageHandlers.set(event, new Set());
    }
    this.messageHandlers.get(event).add(handler);
  }

  /**
   * Unregister event handler
   */
  off(event, handler) {
    const handlers = this.messageHandlers.get(event);
    if (handlers) {
      handlers.delete(handler);
    }
  }

  /**
   * Emit event
   */
  emit(event, data) {
    const handlers = this.messageHandlers.get(event);
    if (handlers) {
      handlers.forEach(handler => {
        try {
          handler(data);
        } catch (error) {
          console.error(`[MCPClient] Error in event handler for ${event}:`, error);
        }
      });
    }
  }

  /**
   * Execute workflow via MCP
   */
  async executeWorkflow(agentId, workflowId, actions) {
    return await this.request('execute_workflow', {
      agentId,
      workflowId,
      actions,
    });
  }

  /**
   * Get task status
   */
  async getTaskStatus(taskId) {
    return await this.request('get_task_status', { taskId });
  }

  /**
   * Browser automation methods
   */
  async navigate(url) {
    return await this.request('navigate', { url });
  }

  async click(selector) {
    return await this.request('click', { selector });
  }

  async fill(selector, value) {
    return await this.request('fill', { selector, value });
  }

  async screenshot() {
    return await this.request('screenshot', {});
  }

  /**
   * Disconnect
   */
  disconnect() {
    if (this.ws) {
      this.connected = false;
      this.ws.close();
      this.ws = null;
    }
  }

  /**
   * Get connection status
   */
  isConnected() {
    return this.connected;
  }

  /**
   * Get statistics
   */
  getStats() {
    return {
      connected: this.connected,
      subscriptions: this.subscriptions.size,
      pendingRequests: this.requestCallbacks.size,
    };
  }
}

// Create singleton instance
const mcpClient = new MCPClient();

// Auto-connect on extension load
chrome.storage.local.get(['settings'], (result) => {
  const settings = result.settings || {};
  const mcpUrl = settings.mcpUrl || 'ws://localhost:7042/mcp';
  
  mcpClient.connect(mcpUrl).then(() => {
    console.log('[MCPClient] Auto-connected successfully');
    
    // Subscribe to task updates
    mcpClient.on('task_status_update', (params) => {
      console.log('[MCPClient] Task status update:', params);
      // Update UI or trigger notifications
    });
    
    mcpClient.on('task_completed', (params) => {
      console.log('[MCPClient] Task completed:', params);
      // Update history, show notification
    });
    
  }).catch((error) => {
    console.error('[MCPClient] Auto-connect failed:', error);
  });
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = mcpClient;
}
