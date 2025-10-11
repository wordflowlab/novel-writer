#!/usr/bin/env node

import { Command } from '@commander-js/extra-typings';
import chalk from 'chalk';
import path from 'path';
import fs from 'fs-extra';
import ora from 'ora';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';
import { getVersion, getVersionInfo } from './version.js';
import { PluginManager } from './plugins/manager.js';
import { ensureProjectRoot, getProjectInfo } from './utils/project.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

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

  // 规范化换行符，避免 Windows CRLF 导致 TOML 解析失败
  const normalizedContent = processedContent.replace(/\r\n/g, '\n');
  const promptValue = JSON.stringify(normalizedContent);
  const escapedDescription = description
    .replace(/\\/g, '\\\\')
    .replace(/"/g, '\\"');

  return `description = "${escapedDescription}"

prompt = ${promptValue}
`;
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
  .option('--ai <type>', '选择 AI 助手: claude | cursor | gemini | windsurf | roocode | copilot | qwen | opencode | codex | kilocode | auggie | codebuddy | q', 'claude')
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
        aiDirs.push(
          '.claude/commands',
          '.cursor/commands',
          '.gemini/commands',
          '.windsurf/workflows',
          '.roo/commands',
          '.github/prompts',
          '.vscode',
          '.qwen/commands',
          '.opencode/command',
          '.codex/prompts',
          '.kilocode/workflows',
          '.augment/commands',
          '.codebuddy/commands',
          '.amazonq/prompts'
        );
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
          case 'roocode':
            aiDirs.push('.roo/commands');
            break;
          case 'copilot':
            aiDirs.push('.github/prompts', '.vscode');
            break;
          case 'qwen':
            aiDirs.push('.qwen/commands');
            break;
          case 'opencode':
            aiDirs.push('.opencode/command');
            break;
          case 'codex':
            aiDirs.push('.codex/prompts');
            break;
          case 'kilocode':
            aiDirs.push('.kilocode/workflows');
            break;
          case 'auggie':
            aiDirs.push('.augment/commands');
            break;
          case 'codebuddy':
            aiDirs.push('.codebuddy/commands');
            break;
          case 'q':
            aiDirs.push('.amazonq/prompts');
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

      // 从构建产物复制 AI 配置和命令文件
      const packageRoot = path.resolve(__dirname, '..');
      const scriptsDir = path.join(packageRoot, 'scripts');
      const sourceMap: Record<string, string> = {
        'claude': 'dist/claude',
        'gemini': 'dist/gemini',
        'cursor': 'dist/cursor',
        'windsurf': 'dist/windsurf',
        'roocode': 'dist/roocode',
        'copilot': 'dist/copilot',
        'qwen': 'dist/qwen',
        'opencode': 'dist/opencode',
        'codex': 'dist/codex',
        'kilocode': 'dist/kilocode',
        'auggie': 'dist/auggie',
        'codebuddy': 'dist/codebuddy',
        'q': 'dist/q'
      };

      // 确定需要复制的 AI 平台
      const targetAI: string[] = [];
      if (options.all) {
        targetAI.push('claude', 'gemini', 'cursor', 'windsurf', 'roocode', 'copilot', 'qwen', 'opencode', 'codex', 'kilocode', 'auggie', 'codebuddy', 'q');
      } else {
        targetAI.push(options.ai);
      }

      // 复制 AI 配置目录（包含命令文件和 .specify 目录）
      for (const ai of targetAI) {
        const sourceDir = path.join(packageRoot, sourceMap[ai]);
        if (await fs.pathExists(sourceDir)) {
          // 复制整个构建产物目录到项目
          await fs.copy(sourceDir, projectPath, { overwrite: false });
          spinner.text = `已安装 ${ai} 配置...`;
        } else {
          console.log(chalk.yellow(`\n警告: ${ai} 构建产物未找到，请运行 npm run build:commands`));
        }
      }

      // 复制脚本文件到用户项目的 .specify/scripts 目录（构建产物已包含）
      // 注意：.specify 目录已由上面的 fs.copy 复制，此处仅作为备份逻辑
      if (await fs.pathExists(scriptsDir) && !await fs.pathExists(path.join(projectPath, '.specify', 'scripts'))) {
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

      // 为 Gemini 复制额外的配置文件
      if (aiDirs.some(dir => dir.includes('.gemini'))) {
        // 复制 settings.json
        const geminiSettingsSource = path.join(packageRoot, 'templates', 'gemini-settings.json');
        const geminiSettingsDest = path.join(projectPath, '.gemini', 'settings.json');
        if (await fs.pathExists(geminiSettingsSource)) {
          await fs.copy(geminiSettingsSource, geminiSettingsDest);
          console.log('  ✓ 已复制 Gemini settings.json');
        }

        // 复制 GEMINI.md
        const geminiMdSource = path.join(packageRoot, 'templates', 'GEMINI.md');
        const geminiMdDest = path.join(projectPath, '.gemini', 'GEMINI.md');
        if (await fs.pathExists(geminiMdSource)) {
          await fs.copy(geminiMdSource, geminiMdDest);
          console.log('  ✓ 已复制 GEMINI.md');
        }
      }

      // 为 GitHub Copilot 复制 VS Code settings
      if (aiDirs.some(dir => dir.includes('.github') || dir.includes('.vscode'))) {
        const vscodeSettingsSource = path.join(packageRoot, 'templates', 'vscode-settings.json');
        const vscodeSettingsDest = path.join(projectPath, '.vscode', 'settings.json');
        if (await fs.pathExists(vscodeSettingsSource)) {
          await fs.copy(vscodeSettingsSource, vscodeSettingsDest);
          console.log('  ✓ 已复制 GitHub Copilot settings.json');
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
            // Roo Code 使用 Markdown 命令目录
            if (aiDir.includes('.roo')) {
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
        'windsurf': 'Windsurf',
        'roocode': 'Roo Code',
        'copilot': 'GitHub Copilot',
        'qwen': 'Qwen Code',
        'opencode': 'OpenCode',
        'codex': 'Codex CLI',
        'kilocode': 'Kilo Code',
        'auggie': 'Auggie CLI',
        'codebuddy': 'CodeBuddy',
        'q': 'Amazon Q Developer'
      }[options.ai] || 'AI 助手';

      if (options.all) {
        console.log(`  2. ${chalk.white('在任意 AI 助手中打开项目（Claude Code、Cursor、Gemini、Windsurf、Roo Code、GitHub Copilot、Qwen Code、OpenCode、Codex CLI、Kilo Code、Auggie CLI、CodeBuddy、Amazon Q Developer）')}`);
      } else {
        console.log(`  2. ${chalk.white(`在 ${aiName} 中打开项目`)}`);
      }
      console.log(`  3. 使用以下斜杠命令开始创作:`);

      console.log('\n' + chalk.yellow('     📝 七步方法论:'));
      console.log(`     ${chalk.cyan('/constitution')} - 创建创作宪法，定义核心原则`);
      console.log(`     ${chalk.cyan('/specify')}      - 定义故事规格，明确要创造什么`);
      console.log(`     ${chalk.cyan('/clarify')}      - 澄清关键决策点，明确模糊之处`);
      console.log(`     ${chalk.cyan('/plan')}         - 制定技术方案，决定如何创作`);
      console.log(`     ${chalk.cyan('/tasks')}        - 分解执行任务，生成可执行清单`);
      console.log(`     ${chalk.cyan('/write')}        - AI 辅助写作章节内容`);
      console.log(`     ${chalk.cyan('/analyze')}      - 综合验证分析，确保质量一致`);

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

      console.log('\n' + chalk.gray('推荐流程: constitution → specify → clarify → plan → tasks → write → analyze'));
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
      console.log('  • Roo Code: https://roocode.com');
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
    console.log('  translate         - 中英文翻译插件');
    console.log('  authentic-voice   - 真实人声写作插件');
  });

program
  .command('plugins:list')
  .description('列出已安装的插件')
  .action(async () => {
    try {
      // 检测项目
      const projectPath = await ensureProjectRoot();
      const projectInfo = await getProjectInfo(projectPath);

      if (!projectInfo) {
        console.log(chalk.red('❌ 无法读取项目信息'));
        process.exit(1);
      }

      const pluginManager = new PluginManager(projectPath);
      const plugins = await pluginManager.listPlugins();

      console.log(chalk.cyan('\n📦 已安装的插件\n'));
      console.log(chalk.gray(`项目: ${path.basename(projectPath)}`));
      console.log(chalk.gray(`AI 配置: ${projectInfo.installedAI.join(', ') || '无'}\n`));

      if (plugins.length === 0) {
        console.log(chalk.yellow('暂无插件'));
        console.log(chalk.gray('\n使用 "novel plugins:add <name>" 安装插件'));
        console.log(chalk.gray('可用插件: translate, authentic-voice, book-analysis\n'));
        return;
      }

      for (const plugin of plugins) {
        console.log(chalk.yellow(`  ${plugin.name}`) + ` (v${plugin.version})`);
        console.log(chalk.gray(`    ${plugin.description}`));

        if (plugin.commands && plugin.commands.length > 0) {
          console.log(chalk.gray(`    命令: ${plugin.commands.map(c => `/${c.id}`).join(', ')}`));
        }

        if (plugin.experts && plugin.experts.length > 0) {
          console.log(chalk.gray(`    专家: ${plugin.experts.map(e => e.title).join(', ')}`));
        }
        console.log('');
      }
    } catch (error: any) {
      if (error.message === 'NOT_IN_PROJECT') {
        console.log(chalk.red('\n❌ 当前目录不是 novel-writer 项目'));
        console.log(chalk.gray('   请在项目根目录运行此命令\n'));
        process.exit(1);
      }

      console.error(chalk.red('❌ 列出插件失败:'), error);
      process.exit(1);
    }
  });

program
  .command('plugins:add <name>')
  .description('安装插件')
  .action(async (name) => {
    try {
      // 1. 检测项目
      const projectPath = await ensureProjectRoot();
      const projectInfo = await getProjectInfo(projectPath);

      if (!projectInfo) {
        console.log(chalk.red('❌ 无法读取项目信息'));
        process.exit(1);
      }

      console.log(chalk.cyan('\n📦 Novel Writer 插件安装\n'));
      console.log(chalk.gray(`项目版本: ${projectInfo.version}`));
      console.log(chalk.gray(`AI 配置: ${projectInfo.installedAI.join(', ') || '无'}\n`));

      // 2. 查找插件
      const packageRoot = path.resolve(__dirname, '..');
      const builtinPluginPath = path.join(packageRoot, 'plugins', name);

      if (!await fs.pathExists(builtinPluginPath)) {
        console.log(chalk.red(`❌ 插件 ${name} 未找到\n`));
        console.log(chalk.gray('可用插件:'));
        console.log(chalk.gray('  - translate (翻译出海插件)'));
        console.log(chalk.gray('  - authentic-voice (真实人声插件)'));
        console.log(chalk.gray('  - book-analysis (拆书分析插件)'));
        process.exit(1);
      }

      // 3. 读取插件配置
      const pluginConfigPath = path.join(builtinPluginPath, 'config.yaml');
      const yaml = await import('js-yaml');
      const pluginConfigContent = await fs.readFile(pluginConfigPath, 'utf-8');
      const pluginConfig = yaml.load(pluginConfigContent) as any;

      // 4. 显示插件信息
      console.log(chalk.cyan(`准备安装: ${pluginConfig.description || name}`));
      console.log(chalk.gray(`版本: ${pluginConfig.version}`));

      if (pluginConfig.commands && pluginConfig.commands.length > 0) {
        console.log(chalk.gray(`命令数量: ${pluginConfig.commands.length}`));
      }

      if (pluginConfig.experts && pluginConfig.experts.length > 0) {
        console.log(chalk.gray(`专家模式: ${pluginConfig.experts.length} 个`));
      }

      if (projectInfo.installedAI.length > 0) {
        console.log(chalk.gray(`目标 AI: ${projectInfo.installedAI.join(', ')}\n`));
      } else {
        console.log(chalk.yellow('\n⚠️  未检测到 AI 配置目录'));
        console.log(chalk.gray('   插件将被复制，但命令不会被注入到任何 AI 平台\n'));
      }

      // 5. 安装插件
      const spinner = ora('正在安装插件...').start();
      const pluginManager = new PluginManager(projectPath);

      await pluginManager.installPlugin(name, builtinPluginPath);
      spinner.succeed(chalk.green('插件安装成功！\n'));

      // 6. 显示后续步骤
      if (pluginConfig.commands && pluginConfig.commands.length > 0) {
        console.log(chalk.cyan('可用命令:'));
        for (const cmd of pluginConfig.commands) {
          console.log(chalk.gray(`  /${cmd.id} - ${cmd.description || ''}`));
        }
      }

      if (pluginConfig.experts && pluginConfig.experts.length > 0) {
        console.log(chalk.cyan('\n专家模式:'));
        for (const expert of pluginConfig.experts) {
          console.log(chalk.gray(`  /expert ${expert.id} - ${expert.title || ''}`));
        }
      }

      console.log('');
    } catch (error: any) {
      if (error.message === 'NOT_IN_PROJECT') {
        console.log(chalk.red('\n❌ 当前目录不是 novel-writer 项目'));
        console.log(chalk.gray('   请在项目根目录运行此命令，或使用 novel init 创建新项目\n'));
        process.exit(1);
      }

      console.log(chalk.red('\n❌ 安装插件失败'));
      console.error(chalk.gray(error.message || error));
      console.log('');
      process.exit(1);
    }
  });

program
  .command('plugins:remove <name>')
  .description('移除插件')
  .action(async (name) => {
    try {
      // 检测项目
      const projectPath = await ensureProjectRoot();
      const projectInfo = await getProjectInfo(projectPath);

      if (!projectInfo) {
        console.log(chalk.red('❌ 无法读取项目信息'));
        process.exit(1);
      }

      const pluginManager = new PluginManager(projectPath);

      console.log(chalk.cyan('\n📦 Novel Writer 插件移除\n'));
      console.log(chalk.gray(`准备移除插件: ${name}`));
      console.log(chalk.gray(`AI 配置: ${projectInfo.installedAI.join(', ') || '无'}\n`));

      const spinner = ora('正在移除插件...').start();
      await pluginManager.removePlugin(name);
      spinner.succeed(chalk.green('插件移除成功！\n'));
    } catch (error: any) {
      if (error.message === 'NOT_IN_PROJECT') {
        console.log(chalk.red('\n❌ 当前目录不是 novel-writer 项目'));
        console.log(chalk.gray('   请在项目根目录运行此命令\n'));
        process.exit(1);
      }

      console.log(chalk.red('\n❌ 移除插件失败'));
      console.error(chalk.gray(error.message || error));
      console.log('');
      process.exit(1);
    }
  });

// upgrade 命令 - 升级现有项目
program
  .command('upgrade')
  .option('--ai <type>', '指定要升级的 AI 配置: claude | cursor | gemini | windsurf | roocode | copilot | qwen | opencode | codex | kilocode | auggie | codebuddy | q')
  .option('--all', '升级所有 AI 配置')
  .option('--no-backup', '跳过备份')
  .option('--dry-run', '预览升级内容，不实际修改')
  .description('升级现有项目到最新版本')
  .action(async (options) => {
    const projectPath = process.cwd();
    const packageRoot = path.resolve(__dirname, '..');

    try {
      // 1. 检测项目
      const configPath = path.join(projectPath, '.specify', 'config.json');
      if (!await fs.pathExists(configPath)) {
        console.log(chalk.red('❌ 当前目录不是 novel-writer 项目'));
        console.log(chalk.gray('   请在项目根目录运行此命令，或使用 novel init 创建新项目'));
        process.exit(1);
      }

      // 读取项目配置
      const config = await fs.readJson(configPath);
      const projectVersion = config.version || '未知';

      console.log(chalk.cyan('\n📦 Novel Writer 项目升级\n'));
      console.log(chalk.gray(`当前版本: ${projectVersion}`));
      console.log(chalk.gray(`目标版本: ${getVersion()}\n`));

      // 2. 检测已安装的 AI 配置
      const installedAI: string[] = [];
      const aiConfigs = [
        { name: 'claude', dir: '.claude' },
        { name: 'cursor', dir: '.cursor' },
        { name: 'gemini', dir: '.gemini' },
        { name: 'windsurf', dir: '.windsurf' },
        { name: 'roocode', dir: '.roo' },
        { name: 'copilot', dir: '.github' },
        { name: 'qwen', dir: '.qwen' },
        { name: 'opencode', dir: '.opencode' },
        { name: 'codex', dir: '.codex' },
        { name: 'kilocode', dir: '.kilocode' },
        { name: 'auggie', dir: '.augment' },
        { name: 'codebuddy', dir: '.codebuddy' },
        { name: 'q', dir: '.amazonq' }
      ];

      for (const ai of aiConfigs) {
        if (await fs.pathExists(path.join(projectPath, ai.dir))) {
          installedAI.push(ai.name);
        }
      }

      if (installedAI.length === 0) {
        console.log(chalk.yellow('⚠️  未检测到任何 AI 配置目录'));
        process.exit(1);
      }

      console.log(chalk.green('✓') + ' 检测到 AI 配置: ' + installedAI.join(', '));

      // 确定要升级的 AI 配置
      let targetAI = installedAI;
      if (options.ai) {
        if (!installedAI.includes(options.ai)) {
          console.log(chalk.red(`❌ AI 配置 "${options.ai}" 未安装`));
          process.exit(1);
        }
        targetAI = [options.ai];
      } else if (!options.all) {
        // 默认升级所有已安装的 AI 配置
        targetAI = installedAI;
      }

      console.log(chalk.cyan(`\n升级目标: ${targetAI.join(', ')}\n`));

      if (options.dryRun) {
        console.log(chalk.yellow('🔍 预览模式（不会实际修改文件）\n'));
      }

      // 3. 创建备份
      let backupPath = '';
      if (options.backup !== false && !options.dryRun) {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
        backupPath = path.join(projectPath, 'backup', timestamp);
        await fs.ensureDir(backupPath);

        console.log(chalk.cyan('📦 创建备份...'));

        // 备份 AI 配置目录
        for (const ai of targetAI) {
          const aiDir = aiConfigs.find(c => c.name === ai)!.dir;
          const source = path.join(projectPath, aiDir);
          const dest = path.join(backupPath, aiDir);
          if (await fs.pathExists(source)) {
            await fs.copy(source, dest);
            console.log(chalk.gray(`  ✓ 备份 ${aiDir}/`));
          }
        }

        // 备份脚本
        const scriptsSource = path.join(projectPath, '.specify', 'scripts');
        if (await fs.pathExists(scriptsSource)) {
          await fs.copy(scriptsSource, path.join(backupPath, '.specify', 'scripts'));
          console.log(chalk.gray('  ✓ 备份 .specify/scripts/'));
        }

        // 保存备份信息
        const backupInfo = {
          timestamp,
          fromVersion: projectVersion,
          toVersion: getVersion(),
          upgradedAI: targetAI,
          backupPath
        };
        await fs.writeJson(path.join(backupPath, 'BACKUP_INFO.json'), backupInfo, { spaces: 2 });

        console.log(chalk.green(`✓ 备份完成: ${backupPath}\n`));
      }

      // 4. 升级命令文件（从构建产物复制）
      console.log(chalk.cyan('📝 升级命令文件...'));

      const upgradeStats = {
        commands: 0,
        claudeEnhanced: 0,
        scripts: 0
      };

      const sourceMap: Record<string, string> = {
        'claude': 'dist/claude',
        'gemini': 'dist/gemini',
        'cursor': 'dist/cursor',
        'windsurf': 'dist/windsurf',
        'roocode': 'dist/roocode',
        'copilot': 'dist/copilot',
        'qwen': 'dist/qwen',
        'opencode': 'dist/opencode',
        'codex': 'dist/codex',
        'kilocode': 'dist/kilocode',
        'auggie': 'dist/auggie',
        'codebuddy': 'dist/codebuddy',
        'q': 'dist/q'
      };

      for (const ai of targetAI) {
        const sourceDir = path.join(packageRoot, sourceMap[ai]);

        if (await fs.pathExists(sourceDir)) {
          const aiConfig = aiConfigs.find(c => c.name === ai)!;
          const targetDir = path.join(projectPath, aiConfig.dir);

          // 复制命令文件目录
          const commandsSubDir = ai === 'windsurf' ? 'workflows' : 'commands';
          const sourceCommandsDir = path.join(sourceDir, aiConfig.dir, commandsSubDir);
          const targetCommandsDir = path.join(targetDir, commandsSubDir);

          if (await fs.pathExists(sourceCommandsDir)) {
            if (!options.dryRun) {
              await fs.copy(sourceCommandsDir, targetCommandsDir, { overwrite: true });
            }

            // 统计命令文件数
            const commandFiles = await fs.readdir(sourceCommandsDir);
            upgradeStats.commands += commandFiles.filter(f =>
              f.endsWith('.md') || f.endsWith('.toml')
            ).length;

            if (ai === 'claude') {
              upgradeStats.claudeEnhanced = commandFiles.filter(f =>
                f.startsWith('novel.')
              ).length;
            }

            console.log(chalk.gray(`  ✓ ${ai}: ${commandFiles.length} 个文件`));
          }
        } else {
          console.log(chalk.yellow(`  ⚠ ${ai}: 构建产物未找到`));
        }
      }

      // 5. 升级脚本文件
      console.log(chalk.cyan('\n🔧 升级脚本文件...'));

      const scriptsSource = path.join(packageRoot, 'scripts');
      const scriptsDest = path.join(projectPath, '.specify', 'scripts');

      if (await fs.pathExists(scriptsSource)) {
        if (!options.dryRun) {
          await fs.copy(scriptsSource, scriptsDest, { overwrite: true });
        }

        // 统计脚本数量
        const bashScripts = await fs.readdir(path.join(scriptsSource, 'bash'));
        const psScripts = await fs.readdir(path.join(scriptsSource, 'powershell'));

        console.log(chalk.gray(`  ✓ 更新 ${bashScripts.length} 个 bash 脚本`));
        console.log(chalk.gray(`  ✓ 更新 ${psScripts.length} 个 powershell 脚本`));

        upgradeStats.scripts = bashScripts.length + psScripts.length;
      }

      // 6. 生成升级报告
      console.log(chalk.cyan('\n📊 升级报告\n'));
      console.log(chalk.green('✅ 升级完成！\n'));

      console.log(chalk.yellow('升级统计:'));
      console.log(`  • 版本: ${projectVersion} → ${getVersion()}`);
      console.log(`  • AI 配置: ${targetAI.join(', ')}`);
      console.log(`  • 命令文件: ${upgradeStats.commands} 个`);
      if (upgradeStats.claudeEnhanced > 0) {
        console.log(`  • Claude 增强: ${upgradeStats.claudeEnhanced} 个`);
      }
      console.log(`  • 脚本文件: ${upgradeStats.scripts} 个`);

      if (backupPath) {
        console.log(chalk.gray(`\n📦 备份位置: ${backupPath}`));
        console.log(chalk.gray('   如需回滚，删除当前文件并从备份恢复'));
      }

      console.log(chalk.cyan('\n✨ 新功能提示:'));
      if (upgradeStats.claudeEnhanced > 0) {
        console.log('  • Claude Code 增强: argument-hint, allowed-tools, 动态上下文');
      }
      console.log('  • 多线索管理: /specify 命令中的线索管理规格');
      console.log('  • 智能分析: /analyze 双模式（框架分析 + 内容分析）');

      console.log(chalk.gray('\n📚 查看详细升级指南: docs/upgrade-guide.md'));
      console.log(chalk.gray('   或访问: https://github.com/wordflowlab/novel-writer/blob/main/docs/upgrade-guide.md'));

      if (!options.dryRun) {
        // 更新项目版本号
        config.version = getVersion();
        await fs.writeJson(configPath, config, { spaces: 2 });
      }

    } catch (error) {
      console.error(chalk.red('\n❌ 升级失败:'), error);
      process.exit(1);
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
