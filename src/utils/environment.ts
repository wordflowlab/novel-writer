import { execSync } from 'child_process';
import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import { displayWarning, displayInfo } from './display.js';

export function checkEnvironment(): void {
  // 检查 Node.js 版本
  const nodeVersion = process.version;
  const majorVersion = parseInt(nodeVersion.split('.')[0].substring(1));

  if (majorVersion < 18) {
    displayWarning(`当前 Node.js 版本为 ${nodeVersion}，建议使用 18.0.0 或更高版本`);
  }

  // 检查是否有 Git
  try {
    execSync('git --version', { stdio: 'ignore' });
  } catch {
    displayWarning('未检测到 Git，版本管理功能将不可用');
  }

  // 检查 AI 工具
  checkAITools();
}

function checkAITools(): void {
  const tools = [
    { name: 'Claude', command: 'claude --version', hint: 'https://claude.ai' },
    { name: 'Gemini', command: 'gemini --version', hint: 'https://gemini.google.com' },
    { name: '通义千问', command: 'qwen --version', hint: 'https://qwen.aliyun.com' }
  ];

  const available: string[] = [];

  tools.forEach(tool => {
    try {
      execSync(tool.command, { stdio: 'ignore' });
      available.push(tool.name);
    } catch {
      // 工具不存在，忽略
    }
  });

  if (available.length === 0) {
    displayInfo('未检测到 AI 助手，部分智能创作功能将不可用');
    displayInfo('支持的 AI 助手: Claude, Gemini, 通义千问');
  }
}

export async function findProjectRoot(currentDir: string = process.cwd()): Promise<string | null> {
  let dir = currentDir;

  while (dir !== path.dirname(dir)) { // 到达根目录时停止
    const configPath = path.join(dir, '.novel', 'config.json');
    if (await fs.pathExists(configPath)) {
      return dir;
    }
    dir = path.dirname(dir);
  }

  return null;
}

export async function loadProjectConfig(): Promise<any> {
  const projectRoot = await findProjectRoot();

  if (!projectRoot) {
    throw new Error('当前目录不在小说项目中');
  }

  const configPath = path.join(projectRoot, '.novel', 'config.json');
  return await fs.readJson(configPath);
}

export async function saveProjectConfig(config: any): Promise<void> {
  const projectRoot = await findProjectRoot();

  if (!projectRoot) {
    throw new Error('当前目录不在小说项目中');
  }

  const configPath = path.join(projectRoot, '.novel', 'config.json');
  await fs.writeJson(configPath, config, { spaces: 2 });
}

export function getSystemInfo(): { platform: string; arch: string; memory: string } {
  const platform = process.platform;
  const arch = process.arch;
  const totalMemory = Math.round(require('os').totalmem() / 1024 / 1024 / 1024);

  const platformNames: Record<string, string> = {
    'darwin': 'macOS',
    'win32': 'Windows',
    'linux': 'Linux'
  };

  return {
    platform: platformNames[platform] || platform,
    arch,
    memory: `${totalMemory}GB`
  };
}

export function isInteractive(): boolean {
  return process.stdin.isTTY && process.stdout.isTTY;
}

export function hasCommand(command: string): boolean {
  try {
    execSync(`which ${command}`, { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

export async function ensureDirectory(dirPath: string): Promise<void> {
  await fs.ensureDir(dirPath);
}

export async function backupFile(filePath: string): Promise<string> {
  if (!await fs.pathExists(filePath)) {
    throw new Error(`文件不存在: ${filePath}`);
  }

  const timestamp = new Date().getTime();
  const backupPath = filePath.replace(/(\.[^.]+)$/, `.backup-${timestamp}$1`);

  await fs.copy(filePath, backupPath);
  return backupPath;
}

export function getEditorCommand(): string {
  // 检查常用编辑器
  const editors = [
    { command: 'code', name: 'VS Code' },
    { command: 'subl', name: 'Sublime Text' },
    { command: 'atom', name: 'Atom' },
    { command: 'vim', name: 'Vim' },
    { command: 'nano', name: 'Nano' }
  ];

  for (const editor of editors) {
    if (hasCommand(editor.command)) {
      return editor.command;
    }
  }

  return 'nano'; // 默认使用 nano
}

export async function openInEditor(filePath: string): Promise<void> {
  const editor = getEditorCommand();

  try {
    execSync(`${editor} "${filePath}"`, { stdio: 'inherit' });
  } catch (error) {
    displayWarning(`无法打开编辑器: ${error}`);
  }
}