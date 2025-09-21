/**
 * 统一版本管理模块
 * 从 package.json 中读取版本号，确保整个项目版本一致
 */

import fs from 'fs';
import path from 'path';

/**
 * 获取当前项目版本号
 * @returns 版本号字符串
 */
export function getVersion(): string {
  try {
    // 尝试从多个可能的路径读取 package.json
    const possiblePaths = [
      path.join(__dirname, '../package.json'),      // src 目录相对路径
      path.join(__dirname, '../../package.json'),   // dist 目录相对路径
      path.join(process.cwd(), 'package.json'),     // 当前工作目录
    ];

    for (const pkgPath of possiblePaths) {
      if (fs.existsSync(pkgPath)) {
        const packageJson = JSON.parse(fs.readFileSync(pkgPath, 'utf-8'));
        return packageJson.version || '0.0.0';
      }
    }

    // 如果找不到 package.json，返回默认版本
    return '0.4.1';
  } catch (error) {
    // 发生错误时返回默认版本
    return '0.4.1';
  }
}

/**
 * 获取版本信息字符串
 * @returns 格式化的版本信息
 */
export function getVersionInfo(): string {
  return `版本: ${getVersion()} | 基于 Spec Kit 架构 | 增强追踪系统`;
}

/**
 * 获取简短版本信息
 * @returns 简短的版本信息
 */
export function getShortVersionInfo(): string {
  return `v${getVersion()}`;
}

// 导出版本常量（向后兼容）
export const VERSION = getVersion();