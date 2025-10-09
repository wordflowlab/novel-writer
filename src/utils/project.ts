import fs from 'fs-extra';
import path from 'path';

export interface ProjectInfo {
  root: string;
  version: string;
  installedAI: string[];
}

/**
 * 向上查找项目根目录
 * 通过查找 .specify/config.json 来识别项目根目录
 */
export async function findProjectRoot(startDir: string = process.cwd()): Promise<string | null> {
  let currentDir = path.resolve(startDir);
  const root = path.parse(currentDir).root;

  while (currentDir !== root) {
    const configPath = path.join(currentDir, '.specify', 'config.json');
    if (await fs.pathExists(configPath)) {
      return currentDir;
    }
    currentDir = path.dirname(currentDir);
  }

  return null;
}

/**
 * 验证是否是有效的 novel-writer 项目
 */
export async function validateProject(projectPath: string): Promise<boolean> {
  const configPath = path.join(projectPath, '.specify', 'config.json');
  return await fs.pathExists(configPath);
}

/**
 * 检测项目安装了哪些 AI 配置
 */
export async function detectInstalledAI(projectPath: string): Promise<string[]> {
  const aiConfigs = [
    { name: 'claude', dir: '.claude' },
    { name: 'cursor', dir: '.cursor' },
    { name: 'gemini', dir: '.gemini' },
    { name: 'windsurf', dir: '.windsurf' },
    { name: 'roocode', dir: '.roo' }
  ];

  const installedAI: string[] = [];
  for (const ai of aiConfigs) {
    const aiPath = path.join(projectPath, ai.dir);
    if (await fs.pathExists(aiPath)) {
      installedAI.push(ai.name);
    }
  }

  return installedAI;
}

/**
 * 获取项目信息
 */
export async function getProjectInfo(projectPath: string): Promise<ProjectInfo | null> {
  const configPath = path.join(projectPath, '.specify', 'config.json');

  if (!await fs.pathExists(configPath)) {
    return null;
  }

  try {
    const configContent = await fs.readFile(configPath, 'utf-8');
    const config = JSON.parse(configContent);
    const installedAI = await detectInstalledAI(projectPath);

    return {
      root: projectPath,
      version: config.version || '未知',
      installedAI
    };
  } catch (error) {
    return null;
  }
}

/**
 * 确保在有效的项目目录中，否则抛出错误
 */
export async function ensureProjectRoot(): Promise<string> {
  const projectRoot = await findProjectRoot();

  if (!projectRoot) {
    throw new Error('NOT_IN_PROJECT');
  }

  return projectRoot;
}
