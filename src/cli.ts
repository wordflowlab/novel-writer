#!/usr/bin/env node

import { Command } from '@commander-js/extra-typings';
import chalk from 'chalk';
import { init } from './commands/init.js';
import { style } from './commands/style.js';
import { story } from './commands/story.js';
import { outline } from './commands/outline.js';
import { tasks } from './commands/tasks.js';
import { write } from './commands/write.js';
import { displayBanner } from './utils/display.js';
import { checkEnvironment } from './utils/environment.js';

const program = new Command();

// 显示欢迎横幅
displayBanner();

// 检查环境
checkEnvironment();

program
  .name('novel')
  .description(chalk.cyan('AI 驱动的中文小说创作工具'))
  .version('0.1.0', '-v, --version', '显示版本号')
  .helpOption('-h, --help', '显示帮助信息');

// init 命令 - 初始化小说项目
program
  .command('init')
  .argument('<name>', '小说项目名称')
  .option('--ai <type>', '选择 AI 助手: claude | gemini | qwen', 'claude')
  .option('--genre <type>', '小说类型: 科幻 | 奇幻 | 现实 | 历史 | 言情 | 悬疑')
  .description('初始化一个新的小说项目')
  .action(init);

// style 命令 - 设定创作风格
program
  .command('style')
  .description('设定个人写作风格和创作准则')
  .option('--template <name>', '使用预设模板: 网文 | 文学 | 轻小说')
  .action(style);

// story 命令 - 创建故事大纲
program
  .command('story')
  .argument('[description]', '故事的简要描述')
  .description('创建故事大纲、角色设定和世界观')
  .option('--interactive', '交互式创建')
  .action(story);

// outline 命令 - 章节规划
program
  .command('outline')
  .description('制定详细的章节结构和情节安排')
  .option('--chapters <number>', '预计章节数', '30')
  .option('--words-per-chapter <number>', '每章字数', '3000')
  .action(outline);

// tasks 命令 - 写作任务
program
  .command('tasks')
  .description('将章节分解为具体的写作任务')
  .option('--priority', '按优先级排序任务')
  .action(tasks);

// write 命令 - 开始创作
program
  .command('write')
  .description('AI 辅助执行实际内容创作')
  .option('--chapter <number>', '指定章节编号')
  .option('--mode <type>', '创作模式: draft(草稿) | refine(精修)', 'draft')
  .action(write);

// 自定义帮助信息
program.on('--help', () => {
  console.log('');
  console.log(chalk.yellow('使用示例:'));
  console.log('');
  console.log('  $ novel init "我的第一本小说" --ai claude --genre 科幻');
  console.log('  $ novel style --template 网文');
  console.log('  $ novel story "一个关于时间旅行者的故事"');
  console.log('  $ novel outline --chapters 50 --words-per-chapter 4000');
  console.log('  $ novel tasks --priority');
  console.log('  $ novel write --chapter 1 --mode draft');
  console.log('');
  console.log(chalk.gray('更多信息请访问: https://github.com/novel-writer/novel-writer'));
});

// 解析命令行参数
program.parse(process.argv);

// 如果没有提供任何命令，显示帮助信息
if (!process.argv.slice(2).length) {
  program.outputHelp();
}