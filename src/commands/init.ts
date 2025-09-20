import chalk from 'chalk';
import path from 'path';
import fs from 'fs-extra';
import ora from 'ora';
import { execSync } from 'child_process';

export async function init(name: string, options: { ai?: string; genre?: string }) {
  const spinner = ora('正在初始化小说项目...').start();

  try {
    // 创建项目目录
    const projectPath = path.join(process.cwd(), name);

    if (await fs.pathExists(projectPath)) {
      spinner.fail(chalk.red(`项目目录 "${name}" 已存在`));
      process.exit(1);
    }

    await fs.ensureDir(projectPath);

    // 创建项目结构
    const dirs = [
      'chapters',        // 章节内容
      'characters',      // 角色设定
      'world',          // 世界观设定
      'outlines',       // 章节大纲
      'drafts',         // 草稿
      'notes',          // 创作笔记
      '.novel'          // 配置文件
    ];

    for (const dir of dirs) {
      await fs.ensureDir(path.join(projectPath, dir));
    }

    // 创建项目配置文件
    const config = {
      name,
      genre: options.genre || '未分类',
      ai: options.ai || 'claude',
      created: new Date().toISOString(),
      version: '0.1.0',
      author: '',
      wordCount: 0,
      chapterCount: 0,
      status: '构思中',
      settings: {
        wordsPerChapter: 3000,
        updateSchedule: '日更',
        language: 'zh-CN'
      }
    };

    await fs.writeJson(path.join(projectPath, '.novel', 'config.json'), config, { spaces: 2 });

    // 创建 README
    const readme = `# ${name}

## 小说信息
- **类型**: ${config.genre}
- **状态**: ${config.status}
- **AI 助手**: ${config.ai}
- **创建时间**: ${new Date().toLocaleDateString('zh-CN')}

## 目录结构
- \`chapters/\` - 章节内容
- \`characters/\` - 角色设定
- \`world/\` - 世界观设定
- \`outlines/\` - 章节大纲
- \`drafts/\` - 草稿
- \`notes/\` - 创作笔记

## 快速开始
\`\`\`bash
# 设定创作风格
novel style

# 创建故事大纲
novel story

# 规划章节
novel outline

# 开始写作
novel write --chapter 1
\`\`\`

---
*使用 Novel Writer 创建*
`;

    await fs.writeFile(path.join(projectPath, 'README.md'), readme);

    // 初始化 Git 仓库
    spinner.text = '正在初始化 Git 仓库...';
    try {
      execSync('git init', { cwd: projectPath, stdio: 'ignore' });

      // 创建 .gitignore
      const gitignore = `# 临时文件
*.tmp
*.swp
.DS_Store

# 备份文件
*.bak
*.backup

# 编辑器配置
.vscode/
.idea/

# 私人笔记
notes/private/

# AI 生成的临时文件
.ai-cache/
`;
      await fs.writeFile(path.join(projectPath, '.gitignore'), gitignore);

      execSync('git add .', { cwd: projectPath, stdio: 'ignore' });
      execSync('git commit -m "初始化小说项目"', { cwd: projectPath, stdio: 'ignore' });
    } catch (gitError) {
      // Git 初始化失败不影响项目创建
      console.log(chalk.yellow('\n提示: Git 初始化失败，但项目已创建成功'));
    }

    spinner.succeed(chalk.green(`小说项目 "${name}" 创建成功！`));

    // 显示后续步骤
    console.log('\n' + chalk.cyan('接下来:'));
    console.log(chalk.gray('─────────────────────────────'));
    console.log(`  1. ${chalk.white(`cd ${name}`)} - 进入项目目录`);
    console.log(`  2. ${chalk.white('novel style')} - 设定创作风格`);
    console.log(`  3. ${chalk.white('novel story')} - 创建故事大纲`);
    console.log(`  4. ${chalk.white('novel outline')} - 规划章节结构`);
    console.log(`  5. ${chalk.white('novel write')} - 开始创作`);

    console.log('\n' + chalk.dim('提示: 使用 novel --help 查看所有可用命令'));

  } catch (error) {
    spinner.fail(chalk.red('项目初始化失败'));
    console.error(error);
    process.exit(1);
  }
}