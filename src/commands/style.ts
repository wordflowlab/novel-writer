import chalk from 'chalk';
import inquirer from 'inquirer';
import fs from 'fs-extra';
import path from 'path';
import ora from 'ora';

export async function style(options: { template?: string }) {
  const spinner = ora('加载创作风格设置...').start();

  try {
    // 检查是否在小说项目目录中
    const configPath = path.join(process.cwd(), '.novel', 'config.json');
    if (!await fs.pathExists(configPath)) {
      spinner.fail(chalk.red('错误: 当前目录不是小说项目目录'));
      console.log(chalk.yellow('提示: 请先使用 "novel init" 创建项目'));
      process.exit(1);
    }

    spinner.stop();

    let styleConfig: any = {};

    if (options.template) {
      // 使用预设模板
      styleConfig = getStyleTemplate(options.template);
    } else {
      // 交互式设置
      const answers = await inquirer.prompt([
        {
          type: 'list',
          name: 'narrative',
          message: '选择叙事视角:',
          choices: [
            { name: '第一人称 (我)', value: 'first-person' },
            { name: '第三人称有限 (他/她，单一视角)', value: 'third-limited' },
            { name: '第三人称全知 (上帝视角)', value: 'third-omniscient' }
          ]
        },
        {
          type: 'list',
          name: 'tone',
          message: '选择整体基调:',
          choices: [
            { name: '轻松幽默', value: 'humorous' },
            { name: '严肃深沉', value: 'serious' },
            { name: '温馨治愈', value: 'warm' },
            { name: '紧张刺激', value: 'thrilling' },
            { name: '浪漫唯美', value: 'romantic' }
          ]
        },
        {
          type: 'list',
          name: 'pacing',
          message: '选择叙事节奏:',
          choices: [
            { name: '快节奏 (情节推进迅速)', value: 'fast' },
            { name: '中等节奏 (平衡叙事)', value: 'medium' },
            { name: '慢节奏 (细腻描写)', value: 'slow' }
          ]
        },
        {
          type: 'checkbox',
          name: 'techniques',
          message: '选择常用的文学技巧:',
          choices: [
            { name: '倒叙', value: 'flashback' },
            { name: '伏笔', value: 'foreshadowing' },
            { name: '象征', value: 'symbolism' },
            { name: '对比', value: 'contrast' },
            { name: '悬念', value: 'suspense' },
            { name: '内心独白', value: 'monologue' }
          ]
        },
        {
          type: 'list',
          name: 'language',
          message: '选择语言风格:',
          choices: [
            { name: '现代白话 (简洁明了)', value: 'modern' },
            { name: '文艺风格 (优美抒情)', value: 'literary' },
            { name: '古风雅致 (半文半白)', value: 'classical' },
            { name: '网文风格 (通俗易懂)', value: 'web' }
          ]
        },
        {
          type: 'input',
          name: 'principles',
          message: '输入您的创作原则 (用逗号分隔):',
          default: '角色立体,情节合理,情感真实',
          filter: (input: string) => input.split(',').map(s => s.trim())
        }
      ]);

      styleConfig = answers;
    }

    // 生成创作准则文档
    const constitution = generateConstitution(styleConfig);

    // 保存到文件
    const stylePath = path.join(process.cwd(), '.novel', 'style.json');
    const constitutionPath = path.join(process.cwd(), 'writing-constitution.md');

    await fs.writeJson(stylePath, styleConfig, { spaces: 2 });
    await fs.writeFile(constitutionPath, constitution);

    console.log('\n' + chalk.green('✓ 创作风格设定完成！'));
    console.log(chalk.gray('─────────────────────────────'));
    console.log('风格配置已保存到: ' + chalk.cyan('.novel/style.json'));
    console.log('创作准则已保存到: ' + chalk.cyan('writing-constitution.md'));
    console.log('\n' + chalk.dim('提示: 您可以随时编辑这些文件来调整创作风格'));

  } catch (error) {
    spinner.fail(chalk.red('设置创作风格失败'));
    console.error(error);
    process.exit(1);
  }
}

function getStyleTemplate(template: string): any {
  const templates: Record<string, any> = {
    '网文': {
      narrative: 'third-limited',
      tone: 'thrilling',
      pacing: 'fast',
      techniques: ['suspense', 'foreshadowing', 'contrast'],
      language: 'web',
      principles: ['爽点密集', '节奏明快', '代入感强', '金手指合理']
    },
    '文学': {
      narrative: 'third-omniscient',
      tone: 'serious',
      pacing: 'slow',
      techniques: ['symbolism', 'monologue', 'flashback'],
      language: 'literary',
      principles: ['深度思考', '人性探索', '社会批判', '艺术表达']
    },
    '轻小说': {
      narrative: 'first-person',
      tone: 'humorous',
      pacing: 'medium',
      techniques: ['contrast', 'monologue'],
      language: 'modern',
      principles: ['轻松愉快', '角色可爱', '日常温馨', '偶有感动']
    }
  };

  return templates[template] || templates['网文'];
}

function generateConstitution(config: any): string {
  const narrativeMap: Record<string, string> = {
    'first-person': '第一人称叙事',
    'third-limited': '第三人称有限视角',
    'third-omniscient': '第三人称全知视角'
  };

  const toneMap: Record<string, string> = {
    'humorous': '轻松幽默',
    'serious': '严肃深沉',
    'warm': '温馨治愈',
    'thrilling': '紧张刺激',
    'romantic': '浪漫唯美'
  };

  const pacingMap: Record<string, string> = {
    'fast': '快节奏',
    'medium': '中等节奏',
    'slow': '慢节奏'
  };

  const languageMap: Record<string, string> = {
    'modern': '现代白话',
    'literary': '文艺风格',
    'classical': '古风雅致',
    'web': '网文风格'
  };

  return `# 创作准则

## 核心风格设定

### 叙事视角
**${narrativeMap[config.narrative] || config.narrative}**

### 整体基调
**${toneMap[config.tone] || config.tone}**

### 叙事节奏
**${pacingMap[config.pacing] || config.pacing}**

### 语言风格
**${languageMap[config.language] || config.language}**

## 文学技巧

${config.techniques?.map((t: string) => `- ${t}`).join('\n') || '- 暂未设定'}

## 创作原则

${config.principles?.map((p: string, i: number) => `${i + 1}. **${p}**`).join('\n') || '1. **暂未设定**'}

## 写作规范

### 必须遵循
- 保持角色性格的一致性
- 确保情节逻辑的合理性
- 维护世界观设定的完整性
- 注意伏笔与回收的对应

### 应当避免
- 角色行为与性格不符
- 情节发展过于突兀
- 设定前后矛盾
- 过度使用俗套桥段

## 质量标准

### 文字要求
- 语言流畅，符合设定的风格
- 描写生动，画面感强
- 对话自然，符合角色身份

### 情节要求
- 冲突明确，张力充足
- 节奏合理，张弛有度
- 转折自然，不生硬

### 情感要求
- 情感真实，能引起共鸣
- 角色成长，有说服力
- 主题明确，不说教

---
*创建时间: ${new Date().toLocaleDateString('zh-CN')}*
*此文档可根据创作需要随时调整*
`;
}