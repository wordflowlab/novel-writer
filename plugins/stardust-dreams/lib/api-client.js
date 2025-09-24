/**
 * 星尘织梦 API 客户端
 * 负责与服务端 API 通信，获取加密的 Prompt 和会话数据
 */

import fetch from 'node-fetch';

const API_BASE = process.env.STARDUST_API_URL || 'https://api.stardust-dreams.com';

export class StardustAPIClient {
  constructor() {
    this.baseUrl = API_BASE;
    this.apiKey = process.env.STARDUST_API_KEY || null;
  }

  /**
   * 设置 API Key
   */
  setApiKey(apiKey) {
    this.apiKey = apiKey;
  }

  /**
   * 获取会话信息
   * @param {string} sessionId - 会话 ID
   * @returns {Object} 会话数据
   */
  async getSession(sessionId) {
    const response = await this.request('/api/trpc/form.getSession', {
      method: 'POST',
      body: {
        json: { sessionId }
      }
    });

    if (!response?.result?.data?.success) {
      throw new Error(`会话 ${sessionId} 不存在或已过期`);
    }

    return response.result.data.data;
  }

  /**
   * 获取加密的 Prompt（核心功能）
   * @param {string} sessionId - 会话 ID
   * @returns {Object} 包含加密 Prompt 和解密密钥的对象
   */
  async getEncryptedPrompt(sessionId) {
    const response = await this.request('/api/trpc/form.getPrompt', {
      method: 'POST',
      body: {
        json: {
          sessionId,
          apiKey: this.apiKey
        }
      }
    });

    if (!response?.result?.data?.success) {
      throw new Error(`无法获取会话 ${sessionId} 的加密 Prompt`);
    }

    const data = response.result.data.data;

    // 返回标准格式的加密数据
    return {
      sessionId: data.sessionId,
      formId: data.formId,
      formName: data.formName,
      parameters: data.parameters,
      encryptedPrompt: data.encryptedPrompt,
      iv: data.iv,
      authTag: data.authTag,
      sessionKey: data.sessionKey,
      expiresAt: data.expiresAt
    };
  }


  /**
   * 发送 API 请求
   */
  async request(endpoint, options = {}) {
    const url = endpoint.startsWith('http') ? endpoint : `${this.baseUrl}${endpoint}`;

    const headers = {
      'Content-Type': 'application/json'
    };

    const fetchOptions = {
      method: options.method || 'GET',
      headers
    };

    if (options.body) {
      fetchOptions.body = JSON.stringify(options.body);
    }

    try {
      const response = await fetch(url, fetchOptions);
      const data = await response.json();

      // 处理速率限制
      if (response.status === 429) {
        const retryAfter = response.headers.get('Retry-After');
        throw new Error(`请求过于频繁，请 ${retryAfter || '60'} 秒后重试`);
      }

      return data;
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      }
      throw new Error(`网络请求失败: ${error}`);
    }
  }
}

// 导出单例
export const apiClient = new StardustAPIClient();