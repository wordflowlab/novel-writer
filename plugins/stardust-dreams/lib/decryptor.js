/**
 * 解密器
 * 负责在内存中解密从服务端获取的加密 Prompt
 * 安全原则：解密结果仅在内存中，永不持久化
 */

import crypto from 'crypto';

export class Decryptor {
  constructor() {
    // 算法配置
    this.algorithm = 'aes-256-gcm';
    this.saltLength = 32;
    this.ivLength = 16;
    this.tagLength = 16;
  }

  /**
   * 解密加密的 Prompt
   * @param {Object} encryptedData - 包含加密数据的对象
   * @param {string} encryptedData.encrypted - hex 编码的加密数据
   * @param {string} encryptedData.iv - hex 编码的 IV
   * @param {string} encryptedData.authTag - hex 编码的认证标签
   * @param {string} sessionKey - hex 格式的会话密钥
   * @returns {string} 解密后的 Prompt（仅在内存中）
   */
  async decrypt(encryptedData, sessionKey) {
    let decrypted = null;

    try {
      // 验证输入
      if (!encryptedData || !encryptedData.encrypted || !encryptedData.iv || !encryptedData.authTag) {
        throw new Error('加密数据不完整');
      }

      // 从 hex 格式转换为 Buffer
      const iv = Buffer.from(encryptedData.iv, 'hex');
      const authTag = Buffer.from(encryptedData.authTag, 'hex');
      const encrypted = Buffer.from(encryptedData.encrypted, 'hex');
      const key = Buffer.from(sessionKey, 'hex');

      // 验证数据完整性
      if (iv.length !== this.ivLength) {
        throw new Error('IV 长度无效');
      }

      if (authTag.length !== this.tagLength) {
        throw new Error('认证标签长度无效');
      }

      if (key.length !== 32) {
        throw new Error('密钥长度无效');
      }

      // 创建解密器
      const decipher = crypto.createDecipheriv(this.algorithm, key, iv);
      decipher.setAuthTag(authTag);

      // 执行解密
      let decrypted = decipher.update(encrypted, null, 'utf8');
      decrypted += decipher.final('utf8');

      // 验证解密结果
      if (!this.isValidPrompt(decrypted)) {
        throw new Error('解密结果无效');
      }

      // 立即返回，不存储
      return decrypted;

    } catch (error) {
      // 清理可能的敏感数据
      if (decrypted) {
        this.secureClear(decrypted);
      }

      // 根据错误类型提供有用的信息
      if (error.message.includes('bad decrypt')) {
        throw new Error('解密失败：密钥无效或数据损坏');
      } else if (error.message.includes('auth tag')) {
        throw new Error('解密失败：数据完整性验证失败');
      } else {
        throw new Error(`解密失败: ${error.message}`);
      }
    }
  }


  /**
   * 验证解密的 Prompt 是否有效
   * 基础验证，确保不是乱码
   */
  isValidPrompt(prompt) {
    if (!prompt || typeof prompt !== 'string') {
      return false;
    }

    // 检查是否包含基本的 Prompt 特征
    // 这些特征应该是所有 Prompt 都有的通用部分
    const hasValidStructure =
      prompt.length > 10 && // 至少有一定长度
      prompt.includes('{{') && // 包含参数占位符
      /[\u4e00-\u9fa5]/.test(prompt); // 包含中文字符

    return hasValidStructure;
  }

  /**
   * 安全清理敏感数据
   * 尽可能快地释放内存引用
   */
  secureClear(data) {
    if (!data) return;

    try {
      if (typeof data === 'string') {
        // 对于字符串，无法真正覆写，但可以释放引用
        data = null;
      } else if (Buffer.isBuffer(data)) {
        // 对于 Buffer，可以填充零
        data.fill(0);
        data = null;
      } else if (typeof data === 'object') {
        // 对于对象，递归清理
        Object.keys(data).forEach(key => {
          this.secureClear(data[key]);
          delete data[key];
        });
        data = null;
      }
    } catch (e) {
      // 忽略清理错误
    }
  }

  /**
   * 验证会话密钥格式
   */
  isValidSessionKey(sessionKey) {
    if (!sessionKey || typeof sessionKey !== 'string') {
      return false;
    }

    // 会话密钥应该是一个合理长度的字符串
    return sessionKey.length >= 32 && sessionKey.length <= 256;
  }


  /**
   * 估算解密后的大小
   * 用于内存管理
   */
  estimateDecryptedSize(encryptedData) {
    // Base64 编码会增加约 33% 的大小
    // AES 加密可能会有填充
    const base64Size = encryptedData.length;
    const estimatedSize = Math.floor(base64Size * 0.75);
    return estimatedSize;
  }

  /**
   * 检查是否可以安全解密
   * 确保有足够的内存
   */
  canSafelyDecrypt(encryptedData) {
    const estimatedSize = this.estimateDecryptedSize(encryptedData);
    const memoryUsage = process.memoryUsage();
    const availableMemory = 500 * 1024 * 1024; // 假设 500MB 上限

    return (memoryUsage.heapUsed + estimatedSize) < availableMemory;
  }
}

// 导出单例
export const decryptor = new Decryptor();