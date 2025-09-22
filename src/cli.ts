#!/usr/bin/env node

import { Command } from '@commander-js/extra-typings';
import chalk from 'chalk';
import path from 'path';
import fs from 'fs-extra';
import ora from 'ora';
import { execSync } from 'child_process';
import { getVersion, getVersionInfo } from './version';
import { PluginManager } from './plugins/manager';

const program = new Command();

// 辅助函数：处理命令模板生成 Markdown 格式
function generateMarkdownCommand(template: string, scriptPath: string): string {
  // 直接替换 {SCRIPT} 并返回完整内容，保留所有 frontmatter 包括 scripts 部分
  return template.replace(/{SCRIPT}/g, scriptPath);
}

// 辅助函数：生成 TOML 格式命令
function generateTomlCommand(template: string, scriptPath: string): string {
  // 提取 description
  const descMatch = template.match(/description:\s*(.+)/);
  const description = descMatch ? descMatch[1].trim() : '命令说明';

  // 移除 YAML frontmatter
  const content = template.replace(/^---[\s\S]*?---\n/, '');

  // 替换 {SCRIPT}
  const processedContent = content.replace(/{SCRIPT}/g, scriptPath);

  return `description = "${description}"

prompt = """
${processedContent}
"""`;
}

// 显示欢迎横幅
function displayBanner(): void {
  const banner = `
╔═══════════════════════════════════════╗
║     📚  Novel Writer  📝              ║
║     AI 驱动的中文小说创作工具        ║
╚═══════════════════════════════════════╝
`;
  console.log(chalk.cyan(banner));
  console.log(chalk.gray(`  ${getVersionInfo()}\n`));
}

displayBanner();

program
  .name('novel')
  .description(chalk.cyan('Novel Writer - AI 驱动的中文小说创作工具初始化'))
  .version(getVersion(), '-v, --version', '显示版本号')
  .helpOption('-h, --help', '显示帮助信息');

// init 命令 - 初始化小说项目（类似 specify init）
program
  .command('init')
  .argument('[name]', '小说项目名称')
  .option('--here', '在当前目录初始化')
  .option('--ai <type>', '选择 AI 助手: claude | cursor | gemini | windsurf', 'claude')
  .option('--all', '为所有支持的 AI 助手生成配置')
  .option('--method <type>', '选择写作方法: three-act | hero-journey | story-circle | seven-point | pixar | snowflake', 'three-act')
  .option('--no-git', '跳过 Git 初始化')
  .option('--with-experts', '包含专家模式')
  .option('--plugins <names>', '预装插件，逗号分隔')
  .description('初始化一个新的小说项目')
  .action(async (name, options) => {
    const spinner = ora('正在初始化小说项目...').start();

    try {
      // 确定项目路径
      let projectPath: string;
      if (options.here) {
        projectPath = process.cwd();
        name = path.basename(projectPath);
      } else {
        if (!name) {
          spinner.fail('请提供项目名称或使用 --here 参数');
          process.exit(1);
        }
        projectPath = path.join(process.cwd(), name);
        if (await fs.pathExists(projectPath)) {
          spinner.fail(`项目目录 "${name}" 已存在`);
          process.exit(1);
        }
        await fs.ensureDir(projectPath);
      }

      // 创建基础项目结构
      const baseDirs = [
        '.specify',
        '.specify/memory',
        '.specify/scripts',
        '.specify/scripts/bash',
        '.specify/scripts/powershell',
        '.specify/templates',
        'stories',
        'spec',
        'spec/tracking',
        'spec/knowledge'
      ];

      for (const dir of baseDirs) {
        await fs.ensureDir(path.join(projectPath, dir));
      }

      // 根据 AI 类型创建特定目录
      const aiDirs: string[] = [];
      if (options.all) {
        // 创建所有 AI 目录
        aiDirs.push('.claude/commands', '.cursor/commands', '.gemini/commands', '.windsurf/workflows');
      } else {
        // 根据选择的 AI 创建目录
        switch(options.ai) {
          case 'claude':
            aiDirs.push('.claude/commands');
            break;
          case 'cursor':
            aiDirs.push('.cursor/commands');
            break;
          case 'gemini':
            aiDirs.push('.gemini/commands');
            break;
          case 'windsurf':
            aiDirs.push('.windsurf/workflows');
            break;
        }
      }

      for (const dir of aiDirs) {
        await fs.ensureDir(path.join(projectPath, dir));
      }

      // 创建基础配置文件
      const config = {
        name,
        type: 'novel',
        ai: options.ai,
        method: options.method || 'three-act',
        created: new Date().toISOString(),
        version: getVersion()
      };

      await fs.writeJson(path.join(projectPath, '.specify', 'config.json'), config, { spaces: 2 });

      // 创建 spec.md 文件，合并所有命令模板
      const packageRoot = path.resolve(__dirname, '..');
      const templatesDir = path.join(packageRoot, 'templates', 'commands');
      const scriptsDir = path.join(packageRoot, 'scripts');

      // 读取所有命令模板
      let specContent = `# Novel Writer Spec - AI 小说创作命令规范

本文件定义了 Novel Writer 支持的所有斜杠命令。
在 Claude Code、Cursor 或其他 AI 助手中使用这些命令进行小说创作。

`;

      if (await fs.pathExists(templatesDir)) {
        const commandFiles = await fs.readdir(templatesDir);

        // 生成合并的 spec.md
        for (const file of commandFiles.sort()) {
          if (file.endsWith('.md')) {
            const content = await fs.readFile(path.join(templatesDir, file), 'utf-8');
            const commandName = path.basename(file, '.md');
            specContent += `## /${commandName}\n\n${content}\n\n`;
          }
        }
        await fs.writeFile(path.join(projectPath, '.specify', 'spec.md'), specContent);

        // 为每个 AI 助手生成特定格式的命令文件
        for (const file of commandFiles) {
          if (file.endsWith('.md')) {
            const content = await fs.readFile(path.join(templatesDir, file), 'utf-8');
            const commandName = path.basename(file, '.md');

            // 提取脚本路径
            const shMatch = content.match(/sh:\s*(.+)/);
            const scriptPath = shMatch ? shMatch[1].trim() : `.specify/scripts/bash/${commandName}.sh`;

            // 为 Claude 生成命令文件
            if (aiDirs.some(dir => dir.includes('.claude'))) {
              const claudePath = path.join(projectPath, '.claude', 'commands', file);
              const claudeContent = generateMarkdownCommand(content, scriptPath);
              await fs.writeFile(claudePath, claudeContent);
            }

            // 为 Cursor 生成命令文件
            if (aiDirs.some(dir => dir.includes('.cursor'))) {
              const cursorPath = path.join(projectPath, '.cursor', 'commands', file);
              const cursorContent = generateMarkdownCommand(content, scriptPath);
              await fs.writeFile(cursorPath, cursorContent);
            }

            // 为 Windsurf 生成命令文件
            if (aiDirs.some(dir => dir.includes('.windsurf'))) {
              const windsurfPath = path.join(projectPath, '.windsurf', 'workflows', file);
              const windsurfContent = generateMarkdownCommand(content, scriptPath);
              await fs.writeFile(windsurfPath, windsurfContent);
            }

            // 为 Gemini 生成 TOML 格式
            if (aiDirs.some(dir => dir.includes('.gemini'))) {
              const geminiPath = path.join(projectPath, '.gemini', 'commands', `${commandName}.toml`);
              const geminiContent = generateTomlCommand(content, scriptPath);
              await fs.writeFile(geminiPath, geminiContent);
            }
          }
        }
      } else {
        await fs.writeFile(path.join(projectPath, '.specify', 'spec.md'), specContent);
      }

      // 复制脚本文件到用户项目的 .specify/scripts 目录
      if (await fs.pathExists(scriptsDir)) {
        const userScriptsDir = path.join(projectPath, '.specify', 'scripts');
        await fs.copy(scriptsDir, userScriptsDir);

        // 设置 bash 脚本执行权限
        const bashDir = path.join(userScriptsDir, 'bash');
        if (await fs.pathExists(bashDir)) {
          const bashFiles = await fs.readdir(bashDir);
          for (const file of bashFiles) {
            if (file.endsWith('.sh')) {
              const filePath = path.join(bashDir, file);
              await fs.chmod(filePath, 0o755);
            }
          }
        }
      }

      // 复制模板文件到 .specify/templates 目录
      const fullTemplatesDir = path.join(packageRoot, 'templates');
      if (await fs.pathExists(fullTemplatesDir)) {
        const userTemplatesDir = path.join(projectPath, '.specify', 'templates');
        await fs.copy(fullTemplatesDir, userTemplatesDir);
      }

      // 复制 memory 文件到 .specify/memory 目录
      const memoryDir = path.join(packageRoot, 'memory');
      if (await fs.pathExists(memoryDir)) {
        const userMemoryDir = path.join(projectPath, '.specify', 'memory');
        await fs.copy(memoryDir, userMemoryDir);
      }

      // 复制追踪文件模板到 spec/tracking 目录
      const trackingTemplatesDir = path.join(packageRoot, 'templates', 'tracking');
      if (await fs.pathExists(trackingTemplatesDir)) {
        const userTrackingDir = path.join(projectPath, 'spec', 'tracking');
        await fs.copy(trackingTemplatesDir, userTrackingDir);
      }

      // 复制知识库模板到 spec/knowledge 目录
      const knowledgeTemplatesDir = path.join(packageRoot, 'templates', 'knowledge');
      if (await fs.pathExists(knowledgeTemplatesDir)) {
        const userKnowledgeDir = path.join(projectPath, 'spec', 'knowledge');
        await fs.copy(knowledgeTemplatesDir, userKnowledgeDir);

        // 更新模板中的日期
        const knowledgeFiles = await fs.readdir(userKnowledgeDir);
        const currentDate = new Date().toISOString().split('T')[0];
        for (const file of knowledgeFiles) {
          if (file.endsWith('.md')) {
            const filePath = path.join(userKnowledgeDir, file);
            let content = await fs.readFile(filePath, 'utf-8');
            content = content.replace(/\[日期\]/g, currentDate);
            await fs.writeFile(filePath, content);
          }
        }
      }

      // 复制spec目录结构（包括预设）
      const specDir = path.join(packageRoot, 'spec');
      if (await fs.pathExists(specDir)) {
        const userSpecDir = path.join(projectPath, 'spec');
        // 复制整个spec目录，但不覆盖已存在的tracking和knowledge
        const specSubDirs = await fs.readdir(specDir);
        for (const subDir of specSubDirs) {
          if (subDir === 'presets' || subDir === 'config.json') {
            await fs.copy(
              path.join(specDir, subDir),
              path.join(userSpecDir, subDir),
              { overwrite: false }
            );
          }
        }
      }

      // 如果指定了 --with-experts，复制专家文件和 expert 命令
      if (options.withExperts) {
        spinner.text = '安装专家模式...';

        // 复制专家目录
        const expertsSourceDir = path.join(packageRoot, 'experts');
        if (await fs.pathExists(expertsSourceDir)) {
          const userExpertsDir = path.join(projectPath, 'experts');
          await fs.copy(expertsSourceDir, userExpertsDir);
        }

        // 复制 expert 命令到各个 AI 目录
        const expertCommandSource = path.join(packageRoot, 'templates', 'commands', 'expert.md');
        if (await fs.pathExists(expertCommandSource)) {
          const expertContent = await fs.readFile(expertCommandSource, 'utf-8');

          for (const aiDir of aiDirs) {
            if (aiDir.includes('claude') || aiDir.includes('cursor')) {
              const expertPath = path.join(projectPath, aiDir, 'expert.md');
              await fs.writeFile(expertPath, expertContent);
            }
            // Windsurf 使用 workflows 目录
            if (aiDir.includes('windsurf')) {
              const expertPath = path.join(projectPath, aiDir, 'expert.md');
              await fs.writeFile(expertPath, expertContent);
            }
            // Gemini 格式处理
            if (aiDir.includes('gemini')) {
              const expertPath = path.join(projectPath, aiDir, 'expert.toml');
              const expertToml = generateTomlCommand(expertContent, '');
              await fs.writeFile(expertPath, expertToml);
            }
          }
        }
      }

      // 如果指定了 --plugins，安装插件
      if (options.plugins) {
        spinner.text = '安装插件...';

        const pluginNames = options.plugins.split(',').map((p: string) => p.trim());
        const pluginManager = new PluginManager(projectPath);

        for (const pluginName of pluginNames) {
          // 检查内置插件
          const builtinPluginPath = path.join(packageRoot, 'plugins', pluginName);
          if (await fs.pathExists(builtinPluginPath)) {
            await pluginManager.installPlugin(pluginName, builtinPluginPath);
          } else {
            console.log(chalk.yellow(`\n警告: 插件 "${pluginName}" 未找到`));
          }
        }
      }

      // Git 初始化
      if (options.git !== false) {
        try {
          execSync('git init', { cwd: projectPath, stdio: 'ignore' });

          // 创建 .gitignore
          const gitignore = `# 临时文件
*.tmp
*.swp
.DS_Store

# 编辑器配置
.vscode/
.idea/

# AI 缓存
.ai-cache/

# 节点模块
node_modules/
`;
          await fs.writeFile(path.join(projectPath, '.gitignore'), gitignore);

          execSync('git add .', { cwd: projectPath, stdio: 'ignore' });
          execSync('git commit -m "初始化小说项目"', { cwd: projectPath, stdio: 'ignore' });
        } catch {
          console.log(chalk.yellow('\n提示: Git 初始化失败，但项目已创建成功'));
        }
      }

      spinner.succeed(chalk.green(`小说项目 "${name}" 创建成功！`));

      // 显示后续步骤
      console.log('\n' + chalk.cyan('接下来:'));
      console.log(chalk.gray('─────────────────────────────'));

      if (!options.here) {
        console.log(`  1. ${chalk.white(`cd ${name}`)} - 进入项目目录`);
      }

      const aiName = {
        'claude': 'Claude Code',
        'cursor': 'Cursor',
        'gemini': 'Gemini',
        'windsurf': 'Windsurf'
      }[options.ai] || 'AI 助手';

      if (options.all) {
        console.log(`  2. ${chalk.white('在任意 AI 助手中打开项目（Claude Code、Cursor、Gemini、Windsurf）')}`);
      } else {
        console.log(`  2. ${chalk.white(`在 ${aiName} 中打开项目`)}`);
      }
      console.log(`  3. 使用以下斜杠命令开始创作:`);

      console.log('\n' + chalk.yellow('     📝 核心创作流程:'));
      console.log(`     ${chalk.cyan('/method')}      - 智能选择写作方法（推荐先执行）`);
      console.log(`     ${chalk.cyan('/style')}       - 设定创作风格和准则`);
      console.log(`     ${chalk.cyan('/story')}       - 创建故事大纲`);
      console.log(`     ${chalk.cyan('/outline')}     - 规划章节结构`);
      console.log(`     ${chalk.cyan('/track-init')} - 初始化追踪系统`);
      console.log(`     ${chalk.cyan('/chapters')}    - 分解写作任务`);
      console.log(`     ${chalk.cyan('/write')}       - 开始章节创作`);

      console.log('\n' + chalk.yellow('     📊 追踪管理命令:'));
      console.log(`     ${chalk.cyan('/plot-check')}  - 检查情节一致性`);
      console.log(`     ${chalk.cyan('/timeline')}    - 管理故事时间线`);
      console.log(`     ${chalk.cyan('/relations')}   - 追踪角色关系`);
      console.log(`     ${chalk.cyan('/world-check')} - 验证世界观设定`);
      console.log(`     ${chalk.cyan('/track')}       - 综合追踪与智能分析`);

      // 如果安装了专家模式，显示提示
      if (options.withExperts) {
        console.log('\n' + chalk.yellow('     🎓 专家模式:'));
        console.log(`     ${chalk.cyan('/expert')}       - 列出可用专家`);
        console.log(`     ${chalk.cyan('/expert plot')} - 剧情结构专家`);
        console.log(`     ${chalk.cyan('/expert character')} - 人物塑造专家`);
      }

      // 如果安装了插件，显示插件命令
      if (options.plugins) {
        const installedPlugins = options.plugins.split(',').map((p: string) => p.trim());
        if (installedPlugins.includes('translate')) {
          console.log('\n' + chalk.yellow('     🌍 翻译插件:'));
          console.log(`     ${chalk.cyan('/translate')}   - 中英文翻译`);
          console.log(`     ${chalk.cyan('/polish')}      - 英文润色`);
        }
      }

      console.log('\n' + chalk.gray('推荐流程: method → story → outline → track-init → write'));
      console.log(chalk.dim('提示: 斜杠命令在 AI 助手内部使用，不是在终端中'));

    } catch (error) {
      spinner.fail(chalk.red('项目初始化失败'));
      console.error(error);
      process.exit(1);
    }
  });

// check 命令 - 检查环境
program
  .command('check')
  .description('检查系统环境和 AI 工具')
  .action(() => {
    console.log(chalk.cyan('检查系统环境...\n'));

    const checks = [
      { name: 'Node.js', command: 'node --version', installed: false },
      { name: 'Git', command: 'git --version', installed: false },
      { name: 'Claude CLI', command: 'claude --version', installed: false },
      { name: 'Cursor', command: 'cursor --version', installed: false },
      { name: 'Gemini CLI', command: 'gemini --version', installed: false }
    ];

    checks.forEach(check => {
      try {
        execSync(check.command, { stdio: 'ignore' });
        check.installed = true;
        console.log(chalk.green('✓') + ` ${check.name} 已安装`);
      } catch {
        console.log(chalk.yellow('⚠') + ` ${check.name} 未安装`);
      }
    });

    const hasAI = checks.slice(2).some(c => c.installed);
    if (!hasAI) {
      console.log('\n' + chalk.yellow('警告: 未检测到 AI 助手工具'));
      console.log('请安装以下任一工具:');
      console.log('  • Claude: https://claude.ai');
      console.log('  • Cursor: https://cursor.sh');
      console.log('  • Gemini: https://gemini.google.com');
    } else {
      console.log('\n' + chalk.green('环境检查通过！'));
    }
  });

// plugins 命令 - 插件管理
program
  .command('plugins')
  .description('插件管理')
  .action(() => {
    // 显示插件子命令帮助
    console.log(chalk.cyan('\n📦 插件管理命令:\n'));
    console.log('  novel plugins list              - 列出已安装的插件');
    console.log('  novel plugins add <name>        - 安装插件');
    console.log('  novel plugins remove <name>     - 移除插件');
    console.log('\n' + chalk.gray('可用插件:'));
    console.log('  translate - 中英文翻译插件');
  });

program
  .command('plugins:list')
  .description('列出已安装的插件')
  .action(async () => {
    const projectPath = process.cwd();
    const pluginManager = new PluginManager(projectPath);

    try {
      const plugins = await pluginManager.listPlugins();

      if (plugins.length === 0) {
        console.log(chalk.yellow('没有安装任何插件'));
        console.log(chalk.gray('\n使用 "novel plugins add <name>" 安装插件'));
        return;
      }

      console.log(chalk.cyan('\n已安装的插件:\n'));
      for (const plugin of plugins) {
        console.log(chalk.yellow(`  ${plugin.name}`) + ` (v${plugin.version})`);
        console.log(chalk.gray(`    ${plugin.description}`));

        if (plugin.commands && plugin.commands.length > 0) {
          console.log(chalk.gray(`    命令: ${plugin.commands.map(c => `/${c.id}`).join(', ')}`));
        }

        if (plugin.experts && plugin.experts.length > 0) {
          console.log(chalk.gray(`    专家: ${plugin.experts.map(e => e.title).join(', ')}`));
        }
      }
    } catch (error) {
      console.error(chalk.red('列出插件失败:'), error);
    }
  });

program
  .command('plugins:add <name>')
  .description('安装插件')
  .action(async (name) => {
    const spinner = ora(`正在安装插件 ${name}...`).start();
    const projectPath = process.cwd();
    const pluginManager = new PluginManager(projectPath);

    try {
      // 获取 package root
      const packageRoot = path.dirname(require.resolve('../package.json'));
      const builtinPluginPath = path.join(packageRoot, 'plugins', name);

      if (await fs.pathExists(builtinPluginPath)) {
        await pluginManager.installPlugin(name, builtinPluginPath);
        spinner.succeed(chalk.green(`插件 ${name} 安装成功！`));
      } else {
        spinner.fail(chalk.red(`插件 ${name} 未找到`));
        console.log(chalk.gray('\n可用插件: translate'));
      }
    } catch (error) {
      spinner.fail(chalk.red(`安装插件 ${name} 失败`));
      console.error(error);
    }
  });

program
  .command('plugins:remove <name>')
  .description('移除插件')
  .action(async (name) => {
    const spinner = ora(`正在移除插件 ${name}...`).start();
    const projectPath = process.cwd();
    const pluginManager = new PluginManager(projectPath);

    try {
      await pluginManager.removePlugin(name);
      spinner.succeed(chalk.green(`插件 ${name} 移除成功！`));
    } catch (error) {
      spinner.fail(chalk.red(`移除插件 ${name} 失败`));
      console.error(error);
    }
  });

// info 命令 - 查看方法信息（保留简单版本）
program
  .command('info')
  .description('查看可用的写作方法')
  .action(() => {
    console.log(chalk.cyan('\n📚 可用的写作方法:\n'));
    console.log(chalk.yellow('  三幕结构') + ' - 经典的故事结构，适合大多数类型');
    console.log(chalk.yellow('  英雄之旅') + ' - 12阶段的成长之旅，适合奇幻冒险');
    console.log(chalk.yellow('  故事圈') + ' - 8环节的循环结构，适合角色驱动');
    console.log(chalk.yellow('  七点结构') + ' - 紧凑的情节结构，适合悬疑惊悚');
    console.log(chalk.yellow('  皮克斯公式') + ' - 简单有力的故事模板，适合短篇');
    console.log(chalk.yellow('  雪花十步') + ' - 系统化的递进式规划，适合细致构建');
    console.log('\n' + chalk.gray('提示：在 AI 助手中使用 /method 命令进行智能选择'));
    console.log(chalk.gray('AI 会通过对话了解你的需求，推荐最适合的方法'));
    console.log(chalk.gray('追踪系统会在写作过程中自动更新，保持数据同步'));
  });

// 自定义帮助信息
program.on('--help', () => {
  console.log('');
  console.log(chalk.yellow('使用示例:'));
  console.log('');
  console.log('  $ novel init my-story           # 创建新项目');
  console.log('  $ novel init --here              # 在当前目录初始化');
  console.log('  $ novel check                    # 检查环境');
  console.log('  $ novel info                     # 查看写作方法');
  console.log('');
  console.log(chalk.cyan('核心创作命令:'));
  console.log('  /method      - 智能选择写作方法（推荐先执行）');
  console.log('  /style       - 设定创作风格和准则');
  console.log('  /story       - 创建故事大纲（使用选定方法）');
  console.log('  /outline     - 规划章节结构（基于方法模板）');
  console.log('  /track-init  - 初始化追踪系统');
  console.log('  /write       - AI 辅助章节创作（自动更新追踪）');
  console.log('');
  console.log(chalk.cyan('追踪管理命令:'));
  console.log('  /plot-check  - 智能检查情节发展一致性');
  console.log('  /timeline    - 管理和验证时间线');
  console.log('  /relations   - 追踪角色关系变化');
  console.log('  /track       - 综合追踪与智能分析');
  console.log('');
  console.log(chalk.gray('更多信息: https://github.com/wordflowlab/novel-writer'));
});

// 解析命令行参数
program.parse(process.argv);

// 如果没有提供任何命令，显示帮助信息
if (!process.argv.slice(2).length) {
  program.outputHelp();
}