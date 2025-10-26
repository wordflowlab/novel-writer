#!/usr/bin/env node
/**
 * Interactive selection utilities for Novel Writer
 * Provides arrow-key based selection interface similar to spec-kit
 */

import inquirer from 'inquirer';
import chalk from 'chalk';

export interface AIConfig {
  name: string;
  dir: string;
  commandsDir: string;
  displayName: string;
  extraDirs?: string[];
}

/**
 * Display project banner
 */
export function displayProjectBanner(): void {
  console.log('');
  console.log(chalk.cyan.bold('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'));
  console.log(chalk.cyan.bold('  Novel Writer - AI 驱动的中文小说创作工具'));
  console.log(chalk.cyan.bold('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'));
  console.log('');
}

/**
 * Select AI assistant interactively
 */
export async function selectAIAssistant(aiConfigs: AIConfig[]): Promise<string> {
  const choices = aiConfigs.map(config => ({
    name: `${chalk.cyan(config.name.padEnd(12))} ${chalk.dim(`(${config.displayName})`)}`,
    value: config.name,
    short: config.name
  }));

  const answer = await inquirer.prompt([
    {
      type: 'list',
      name: 'ai',
      message: chalk.bold('选择你的 AI 助手:'),
      choices,
      default: 'claude',
      pageSize: 15
    }
  ]);

  return answer.ai;
}

/**
 * Select writing method interactively
 */
export async function selectWritingMethod(): Promise<string> {
  const methodChoices = [
    {
      name: `${chalk.cyan('three-act'.padEnd(15))} ${chalk.dim('(三幕结构 - 经典故事结构)')}`,
      value: 'three-act',
      short: 'three-act'
    },
    {
      name: `${chalk.cyan('hero-journey'.padEnd(15))} ${chalk.dim('(英雄之旅 - 12阶段成长)')}`,
      value: 'hero-journey',
      short: 'hero-journey'
    },
    {
      name: `${chalk.cyan('story-circle'.padEnd(15))} ${chalk.dim('(故事圈 - 8环节循环)')}`,
      value: 'story-circle',
      short: 'story-circle'
    },
    {
      name: `${chalk.cyan('seven-point'.padEnd(15))} ${chalk.dim('(七点结构 - 紧凑情节)')}`,
      value: 'seven-point',
      short: 'seven-point'
    },
    {
      name: `${chalk.cyan('pixar'.padEnd(15))} ${chalk.dim('(皮克斯公式 - 简单有力)')}`,
      value: 'pixar',
      short: 'pixar'
    },
    {
      name: `${chalk.cyan('snowflake'.padEnd(15))} ${chalk.dim('(雪花十步 - 系统化规划)')}`,
      value: 'snowflake',
      short: 'snowflake'
    }
  ];

  const answer = await inquirer.prompt([
    {
      type: 'list',
      name: 'method',
      message: chalk.bold('选择写作方法:'),
      choices: methodChoices,
      default: 'three-act'
    }
  ]);

  return answer.method;
}

/**
 * Select script type interactively
 */
export async function selectScriptType(): Promise<string> {
  const scriptChoices = [
    {
      name: `${chalk.cyan('sh'.padEnd(12))} ${chalk.dim('(POSIX Shell - macOS/Linux)')}`,
      value: 'sh',
      short: 'sh'
    },
    {
      name: `${chalk.cyan('ps'.padEnd(12))} ${chalk.dim('(PowerShell - Windows)')}`,
      value: 'ps',
      short: 'ps'
    }
  ];

  const answer = await inquirer.prompt([
    {
      type: 'list',
      name: 'scriptType',
      message: chalk.bold('选择脚本类型:'),
      choices: scriptChoices,
      default: 'sh'
    }
  ]);

  return answer.scriptType;
}

/**
 * Confirm expert mode
 */
export async function confirmExpertMode(): Promise<boolean> {
  const answer = await inquirer.prompt([
    {
      type: 'confirm',
      name: 'experts',
      message: chalk.bold('是否启用专家模式？'),
      default: false
    }
  ]);

  return answer.experts;
}

/**
 * Display initialization step
 */
export function displayStep(step: number, total: number, message: string): void {
  console.log(chalk.dim(`[${step}/${total}]`) + ' ' + message);
}

/**
 * Check if running in interactive terminal
 */
export function isInteractive(): boolean {
  return process.stdin.isTTY === true && process.stdout.isTTY === true;
}
