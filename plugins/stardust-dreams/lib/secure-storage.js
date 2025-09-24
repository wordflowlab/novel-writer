/**
 * 安全存储
 * 负责安全地存储认证信息（加密保存）
 * 注意：仅存储认证信息，不存储 Prompt
 */

import crypto from 'crypto';
import fs from 'fs-extra';
import path from 'path';
import os from 'os';

export class SecureStorage {
  constructor() {
    // 存储路径
    this.storageDir = path.join(os.homedir(), '.novel', 'stardust');
    this.authFile = path.join(this.storageDir, 'auth.enc');
    this.configFile = path.join(this.storageDir, 'config.json');

    // 加密配置
    this.algorithm = 'aes-256-gcm';

    // 确保存储目录存在
    this.ensureStorageDir();
  }

  /**
   * 确保存储目录存在
   */
  async ensureStorageDir() {
    try {
      await fs.ensureDir(this.storageDir);
      // 设置目录权限（仅用户可读写）
      await fs.chmod(this.storageDir, 0o700);
    } catch (error) {
      console.error('创建存储目录失败:', error.message);
    }
  }

  /**
   * 保存认证信息
   */
  async saveAuth(authData) {
    try {
      // 加密认证数据
      const encrypted = await this.encrypt(JSON.stringify(authData));

      // 保存到文件
      await fs.writeFile(this.authFile, encrypted, 'utf8');

      // 设置文件权限（仅用户可读写）
      await fs.chmod(this.authFile, 0o600);

      return true;
    } catch (error) {
      console.error('保存认证失败:', error.message);
      return false;
    }
  }

  /**
   * 获取认证信息
   */
  async getAuth() {
    try {
      // 检查文件是否存在
      if (!await fs.pathExists(this.authFile)) {
        return null;
      }

      // 读取加密数据
      const encrypted = await fs.readFile(this.authFile, 'utf8');

      // 解密
      const decrypted = await this.decrypt(encrypted);

      // 解析 JSON
      const authData = JSON.parse(decrypted);

      // 检查是否过期
      if (authData.expiresAt && Date.now() > authData.expiresAt) {
        // Token 已过期，但保留 refreshToken
        return {
          ...authData,
          token: null,
          expired: true
        };
      }

      return authData;
    } catch (error) {
      console.error('读取认证失败:', error.message);
      return null;
    }
  }

  /**
   * 更新认证信息
   */
  async updateAuth(updates) {
    try {
      const current = await this.getAuth() || {};
      const updated = { ...current, ...updates };
      return await this.saveAuth(updated);
    } catch (error) {
      console.error('更新认证失败:', error.message);
      return false;
    }
  }

  /**
   * 清除认证信息
   */
  async clearAuth() {
    try {
      if (await fs.pathExists(this.authFile)) {
        // 先用随机数据覆写文件内容
        const randomData = crypto.randomBytes(1024);
        await fs.writeFile(this.authFile, randomData);

        // 然后删除文件
        await fs.remove(this.authFile);
      }
      return true;
    } catch (error) {
      console.error('清除认证失败:', error.message);
      return false;
    }
  }

  /**
   * 保存配置（非敏感信息）
   */
  async saveConfig(config) {
    try {
      await fs.writeJson(this.configFile, config, { spaces: 2 });
      return true;
    } catch (error) {
      console.error('保存配置失败:', error.message);
      return false;
    }
  }

  /**
   * 获取配置
   */
  async getConfig() {
    try {
      if (!await fs.pathExists(this.configFile)) {
        return {};
      }
      return await fs.readJson(this.configFile);
    } catch (error) {
      console.error('读取配置失败:', error.message);
      return {};
    }
  }

  /**
   * 加密数据
   */
  async encrypt(data) {
    // 获取设备密钥
    const key = this.getDeviceKey();

    // 生成随机 IV
    const iv = crypto.randomBytes(16);

    // 创建加密器
    const cipher = crypto.createCipheriv(this.algorithm, key, iv);

    // 加密数据
    let encrypted = cipher.update(data, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    // 获取认证标签
    const authTag = cipher.getAuthTag();

    // 组合结果：iv:authTag:encrypted
    return `${iv.toString('hex')}:${authTag.toString('hex')}:${encrypted}`;
  }

  /**
   * 解密数据
   */
  async decrypt(encryptedData) {
    // 获取设备密钥
    const key = this.getDeviceKey();

    // 解析加密数据
    const parts = encryptedData.split(':');
    if (parts.length !== 3) {
      throw new Error('加密数据格式无效');
    }

    const iv = Buffer.from(parts[0], 'hex');
    const authTag = Buffer.from(parts[1], 'hex');
    const encrypted = parts[2];

    // 创建解密器
    const decipher = crypto.createDecipheriv(this.algorithm, key, iv);
    decipher.setAuthTag(authTag);

    // 解密数据
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
  }

  /**
   * 获取设备特征密钥
   * 基于设备信息生成唯一密钥
   */
  getDeviceKey() {
    // 收集设备特征
    const deviceInfo = [
      os.hostname(),           // 主机名
      os.userInfo().username,   // 用户名
      os.platform(),           // 操作系统
      os.arch(),              // 架构
      'stardust-dreams-2024'  // 固定盐值
    ].join(':');

    // 生成 256 位密钥
    return crypto.createHash('sha256').update(deviceInfo).digest();
  }

  /**
   * 检查存储健康状态
   */
  async checkHealth() {
    const health = {
      storageDir: false,
      authFile: false,
      configFile: false,
      permissions: false
    };

    try {
      // 检查目录
      health.storageDir = await fs.pathExists(this.storageDir);

      // 检查文件
      health.authFile = await fs.pathExists(this.authFile);
      health.configFile = await fs.pathExists(this.configFile);

      // 检查权限
      if (health.storageDir) {
        const stats = await fs.stat(this.storageDir);
        health.permissions = (stats.mode & 0o777) === 0o700;
      }

      return health;
    } catch (error) {
      return health;
    }
  }

  /**
   * 导出认证信息（用于调试）
   * 注意：导出的是加密后的数据
   */
  async exportAuth() {
    try {
      if (!await fs.pathExists(this.authFile)) {
        return null;
      }

      const encrypted = await fs.readFile(this.authFile, 'utf8');
      const timestamp = new Date().toISOString();

      return {
        encrypted,
        timestamp,
        device: os.hostname()
      };
    } catch (error) {
      return null;
    }
  }

  /**
   * 导入认证信息
   * 注意：需要在同一设备上才能解密
   */
  async importAuth(exportedData) {
    try {
      if (!exportedData || !exportedData.encrypted) {
        throw new Error('导入数据无效');
      }

      // 验证是否可以解密（测试解密）
      await this.decrypt(exportedData.encrypted);

      // 保存到文件
      await fs.writeFile(this.authFile, exportedData.encrypted, 'utf8');
      await fs.chmod(this.authFile, 0o600);

      return true;
    } catch (error) {
      console.error('导入认证失败:', error.message);
      return false;
    }
  }

  /**
   * 清理过期数据
   */
  async cleanup() {
    try {
      // 清理过期的认证
      const auth = await this.getAuth();
      if (auth && auth.expired) {
        await this.clearAuth();
      }

      // 清理临时文件
      const tempFiles = await fs.readdir(this.storageDir);
      for (const file of tempFiles) {
        if (file.endsWith('.tmp')) {
          await fs.remove(path.join(this.storageDir, file));
        }
      }

      return true;
    } catch (error) {
      return false;
    }
  }
}

// 导出单例
export const secureStorage = new SecureStorage();