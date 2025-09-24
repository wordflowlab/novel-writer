/**
 * Prompt 管理器
 * 核心安全组件：负责从服务端获取加密的 Prompt，在内存中解密使用，确保不持久化
 */

import { apiClient } from './api-client.js';
import { Decryptor } from './decryptor.js';
import { TemplateEngine } from './template-engine.js';

export class PromptManager {
  constructor() {
    this.decryptor = new Decryptor();
    this.templateEngine = new TemplateEngine();

    // 不使用持久化缓存，仅内存临时存储
    this.memoryCache = new Map();

    // 设置内存清理定时器
    this.startMemoryCleaner();
  }

  /**
   * 使用 Prompt 模板生成内容
   * 整个过程确保 Prompt 仅在内存中，用完即清理
   */
  async usePrompt(sessionId, apiKey = null) {
    let decryptedPrompt = null;
    let filledPrompt = null;
    let encryptedData = null;

    try {
      // 设置 API Key（如果提供）
      if (apiKey) {
        apiClient.setApiKey(apiKey);
      }

      // 步骤 1: 获取会话信息
      console.log('📋 获取会话信息...');
      const session = await apiClient.getSession(sessionId);

      if (!session) {
        throw new Error('会话不存在或已过期');
      }

      // 检查会话是否过期
      if (new Date(session.expiresAt) < new Date()) {
        throw new Error('会话已过期，请在 Web 端重新生成');
      }

      // 步骤 2: 获取加密的 Prompt
      console.log('🔐 获取加密模板...');
      encryptedData = await apiClient.getEncryptedPrompt(sessionId);

      // 步骤 3: 内存中解密
      console.log('🔓 解密模板中...');
      decryptedPrompt = await this.decryptInMemory(
        {
          encrypted: encryptedData.encryptedPrompt,
          iv: encryptedData.iv,
          authTag: encryptedData.authTag
        },
        encryptedData.sessionKey
      );

      // 步骤 4: 填充参数
      console.log('📝 填充参数中...');
      filledPrompt = this.templateEngine.fill(
        decryptedPrompt,
        encryptedData.parameters
      );

      // 步骤 5: 记录使用（不含敏感内容）
      const startTime = Date.now();

      // 步骤 6: 返回填充后的 Prompt（供 AI 使用）
      // 注意：这里返回后，调用方应立即使用并清理
      return {
        prompt: filledPrompt,
        metadata: {
          formId: encryptedData.formId,
          formName: encryptedData.formName,
          sessionId: sessionId,
          duration: Date.now() - startTime
        }
      };

    } finally {
      // 步骤 7: 强制清理内存中的敏感数据
      this.clearSensitiveData(decryptedPrompt);
      this.clearSensitiveData(filledPrompt);
      this.clearSensitiveData(encryptedData);

      // 触发垃圾回收（如果可用）
      if (global.gc) {
        global.gc();
      }
    }
  }

  /**
   * 在内存中解密 Prompt
   * 不写入任何文件或日志
   */
  async decryptInMemory(encryptedPrompt, sessionKey) {
    // 使用临时变量，确保不持久化
    let decrypted = null;

    try {
      // 检查内存限制
      this.checkMemoryUsage();

      // 执行解密
      decrypted = await this.decryptor.decrypt(encryptedPrompt, sessionKey);

      // 验证解密结果
      if (!decrypted || typeof decrypted !== 'string') {
        throw new Error('解密失败：无效的结果');
      }

      // 立即返回，不存储
      return decrypted;

    } catch (error) {
      // 错误处理时也要清理
      this.clearSensitiveData(decrypted);
      throw new Error(`解密失败: ${error.message}`);
    }
  }

  /**
   * 清理敏感数据
   * JavaScript 无法真正覆写内存，但可以尽快释放引用
   */
  clearSensitiveData(data) {
    if (!data) return;

    try {
      if (typeof data === 'string') {
        // 对于字符串，创建新的空字符串并释放原引用
        data = '';
        data = null;
      } else if (typeof data === 'object') {
        // 对于对象，清理所有属性
        Object.keys(data).forEach(key => {
          if (typeof data[key] === 'string') {
            data[key] = '';
          }
          data[key] = null;
          delete data[key];
        });
        data = null;
      }
    } catch (e) {
      // 忽略清理错误
    }
  }

  /**
   * 检查内存使用情况
   * 防止内存泄漏
   */
  checkMemoryUsage() {
    const usage = process.memoryUsage();
    const heapUsedMB = usage.heapUsed / 1024 / 1024;

    // 如果堆内存超过 100MB，发出警告
    if (heapUsedMB > 100) {
      console.warn(`⚠️ 内存使用较高: ${heapUsedMB.toFixed(2)} MB`);

      // 清理内存缓存
      this.clearMemoryCache();

      // 强制垃圾回收
      if (global.gc) {
        global.gc();
      }
    }
  }

  /**
   * 清理内存缓存
   */
  clearMemoryCache() {
    // 清理所有缓存项
    for (const [key, value] of this.memoryCache) {
      this.clearSensitiveData(value);
    }
    this.memoryCache.clear();
  }

  /**
   * 启动内存清理定时器
   * 定期清理未使用的内存
   */
  startMemoryCleaner() {
    // 每分钟检查一次
    setInterval(() => {
      const now = Date.now();

      // 清理超过 5 分钟的缓存
      for (const [key, value] of this.memoryCache) {
        if (value.timestamp && now - value.timestamp > 5 * 60 * 1000) {
          this.clearSensitiveData(value);
          this.memoryCache.delete(key);
        }
      }

      // 检查内存使用
      this.checkMemoryUsage();
    }, 60 * 1000);
  }

  /**
   * 验证会话权限
   * 确保用户只能访问自己的会话
   */
  async validateAccess(sessionId, userId) {
    // 这里可以添加额外的权限验证逻辑
    const session = await apiClient.getSession(sessionId);

    if (!session) {
      throw new Error('会话不存在');
    }

    // 验证会话所有者
    if (session.userId && session.userId !== userId) {
      throw new Error('无权访问此会话');
    }

    return true;
  }

  /**
   * 获取 Prompt 元数据（不含实际内容）
   * 用于显示模板信息
   */
  async getPromptMetadata(templateId) {
    // 只返回元数据，不返回实际 Prompt
    const templates = await apiClient.getTemplates();
    const template = templates.find(t => t.id === templateId);

    if (!template) {
      throw new Error('模板不存在');
    }

    return {
      id: template.id,
      name: template.name,
      description: template.description,
      category: template.category,
      parameters: template.parameters,
      // 不包含实际的 Prompt 内容
    };
  }

  /**
   * 预检查
   * 在实际使用前检查各项条件
   */
  async preCheck(sessionId) {
    const checks = {
      session: false,
      auth: false,
      memory: false,
      network: false
    };

    try {
      // 检查会话
      const session = await apiClient.getSession(sessionId);
      checks.session = !!session && new Date(session.expiresAt) > new Date();

      // 检查认证
      checks.auth = !!apiClient.token;

      // 检查内存
      const usage = process.memoryUsage();
      checks.memory = usage.heapUsed < 200 * 1024 * 1024; // < 200MB

      // 检查网络
      checks.network = true; // 已经通过获取会话验证

      return checks;
    } catch (error) {
      return checks;
    }
  }

  /**
   * 安全执行
   * 包装执行过程，确保安全和清理
   */
  async safeExecute(fn) {
    const sensitiveData = [];

    try {
      // 注册清理函数
      const registerForCleanup = (data) => {
        sensitiveData.push(data);
        return data;
      };

      // 执行函数
      const result = await fn(registerForCleanup);

      return result;

    } finally {
      // 无论成功或失败，都清理敏感数据
      for (const data of sensitiveData) {
        this.clearSensitiveData(data);
      }
      sensitiveData.length = 0;
    }
  }
}

// 导出单例
export const promptManager = new PromptManager();