import chalk from 'chalk';
import inquirer from 'inquirer';
import fs from 'fs-extra';
import path from 'path';
import ora from 'ora';

export async function story(description?: string, options?: { interactive?: boolean }) {
  const spinner = ora('准备创建故事大纲...').start();

  try {
    // 检查项目目录
    const configPath = path.join(process.cwd(), '.novel', 'config.json');
    if (!await fs.pathExists(configPath)) {
      spinner.fail(chalk.red('错误: 当前目录不是小说项目目录'));
      process.exit(1);
    }

    spinner.stop();

    let storyData: any = {};

    if (options?.interactive || !description) {
      // 交互式创建
      storyData = await interactiveStoryCreation();
    } else {
      // 基于描述生成基础框架
      console.log(chalk.cyan('基于您的描述生成故事框架...'));
      storyData = {
        description,
        title: '',
        genre: '',
        summary: description,
        theme: '',
        conflict: '',
        protagonist: {},
        characters: [],
        worldSetting: {},
        plotOutline: {}
      };

      // 这里可以集成 AI 来扩展描述
      console.log(chalk.yellow('提示: 建议使用 --interactive 模式获得更完整的设定'));
    }

    // 生成故事大纲文档
    const storyDoc = generateStoryDocument(storyData);

    // 保存文件
    const storyPath = path.join(process.cwd(), 'story-outline.md');
    const dataPath = path.join(process.cwd(), '.novel', 'story.json');

    await fs.writeFile(storyPath, storyDoc);
    await fs.writeJson(dataPath, storyData, { spaces: 2 });

    console.log('\n' + chalk.green('✓ 故事大纲创建成功！'));
    console.log(chalk.gray('─────────────────────────────'));
    console.log('故事大纲: ' + chalk.cyan('story-outline.md'));
    console.log('数据文件: ' + chalk.cyan('.novel/story.json'));

    // 创建角色文件
    if (storyData.protagonist || storyData.characters?.length > 0) {
      await createCharacterFiles(storyData);
      console.log('角色设定: ' + chalk.cyan('characters/'));
    }

    console.log('\n' + chalk.dim('下一步: 使用 "novel outline" 规划章节结构'));

  } catch (error) {
    spinner.fail(chalk.red('创建故事大纲失败'));
    console.error(error);
    process.exit(1);
  }
}

async function interactiveStoryCreation() {
  console.log(chalk.cyan('\n开始交互式故事创建...\n'));

  const basicInfo = await inquirer.prompt([
    {
      type: 'input',
      name: 'title',
      message: '小说标题:',
      validate: (input) => input.trim() !== '' || '标题不能为空'
    },
    {
      type: 'list',
      name: 'genre',
      message: '小说类型:',
      choices: ['科幻', '奇幻', '现实', '历史', '言情', '悬疑', '武侠', '仙侠', '其他']
    },
    {
      type: 'input',
      name: 'summary',
      message: '一句话概括 (电梯游说):',
      validate: (input) => input.trim() !== '' || '请输入故事概要'
    },
    {
      type: 'input',
      name: 'theme',
      message: '核心主题 (想表达什么):',
      validate: (input) => input.trim() !== '' || '请输入核心主题'
    },
    {
      type: 'input',
      name: 'conflict',
      message: '核心冲突 (主要矛盾):',
      validate: (input) => input.trim() !== '' || '请输入核心冲突'
    }
  ]);

  // 主角设定
  console.log(chalk.yellow('\n主角设定:'));
  const protagonist = await inquirer.prompt([
    {
      type: 'input',
      name: 'name',
      message: '主角姓名:',
      validate: (input) => input.trim() !== '' || '请输入主角姓名'
    },
    {
      type: 'input',
      name: 'age',
      message: '年龄:',
      default: '25'
    },
    {
      type: 'list',
      name: 'gender',
      message: '性别:',
      choices: ['男', '女', '其他']
    },
    {
      type: 'input',
      name: 'personality',
      message: '性格特征 (用逗号分隔):',
      filter: (input: string) => input.split(',').map(s => s.trim())
    },
    {
      type: 'input',
      name: 'background',
      message: '背景故事 (简述):',
    },
    {
      type: 'input',
      name: 'motivation',
      message: '核心动机 (想要什么):',
    },
    {
      type: 'input',
      name: 'growth',
      message: '成长弧线 (如何变化):',
    }
  ]);

  // 配角设定
  const { addCharacters } = await inquirer.prompt([
    {
      type: 'confirm',
      name: 'addCharacters',
      message: '是否添加重要配角?',
      default: true
    }
  ]);

  const characters = [];
  if (addCharacters) {
    let addMore = true;
    while (addMore) {
      console.log(chalk.yellow('\n添加配角:'));
      const character = await inquirer.prompt([
        {
          type: 'input',
          name: 'name',
          message: '角色姓名:',
          validate: (input) => input.trim() !== '' || '请输入角色姓名'
        },
        {
          type: 'input',
          name: 'role',
          message: '角色定位 (如: 导师/对手/伙伴):',
        },
        {
          type: 'input',
          name: 'relationship',
          message: '与主角的关系:',
        }
      ]);
      characters.push(character);

      const { continueAdd } = await inquirer.prompt([
        {
          type: 'confirm',
          name: 'continueAdd',
          message: '继续添加配角?',
          default: false
        }
      ]);
      addMore = continueAdd;
    }
  }

  // 世界观设定
  console.log(chalk.yellow('\n世界观设定:'));
  const worldSetting = await inquirer.prompt([
    {
      type: 'input',
      name: 'time',
      message: '时代背景:',
      default: '现代'
    },
    {
      type: 'input',
      name: 'location',
      message: '主要地点:',
    },
    {
      type: 'input',
      name: 'rules',
      message: '特殊规则/设定 (如有):',
    }
  ]);

  // 情节结构
  console.log(chalk.yellow('\n情节结构 (三幕式):'));
  const plotOutline = await inquirer.prompt([
    {
      type: 'input',
      name: 'act1',
      message: '第一幕 - 开端 (如何开始):',
    },
    {
      type: 'input',
      name: 'incitingIncident',
      message: '触发事件 (改变主角命运的事件):',
    },
    {
      type: 'input',
      name: 'act2a',
      message: '第二幕上 - 上升阶段:',
    },
    {
      type: 'input',
      name: 'midpoint',
      message: '中点转折 (重大转变):',
    },
    {
      type: 'input',
      name: 'act2b',
      message: '第二幕下 - 下降阶段:',
    },
    {
      type: 'input',
      name: 'act3',
      message: '第三幕 - 高潮与结局:',
    }
  ]);

  return {
    ...basicInfo,
    protagonist,
    characters,
    worldSetting,
    plotOutline
  };
}

function generateStoryDocument(data: any): string {
  return `# 小说：${data.title || '[待定标题]'}

## 基本信息
- **类型**: ${data.genre || '未分类'}
- **创建时间**: ${new Date().toLocaleDateString('zh-CN')}
- **状态**: 大纲阶段

## 故事内核

### 一句话故事
${data.summary || '[待填写]'}

### 核心冲突
${data.conflict || '[待填写]'}

### 主题思想
${data.theme || '[待填写]'}

## 角色设定

### 主角
- **姓名**: ${data.protagonist?.name || '[待定]'}
- **年龄/性别**: ${data.protagonist?.age || ''}/${data.protagonist?.gender || ''}
- **性格特征**: ${Array.isArray(data.protagonist?.personality) ? data.protagonist.personality.join('、') : data.protagonist?.personality || '[待定]'}
- **背景故事**: ${data.protagonist?.background || '[待填写]'}
- **核心动机**: ${data.protagonist?.motivation || '[待填写]'}
- **成长弧线**: ${data.protagonist?.growth || '[待填写]'}

### 重要配角
${data.characters?.map((c: any) => `
#### ${c.name}
- **角色定位**: ${c.role || '未定'}
- **与主角关系**: ${c.relationship || '未定'}
`).join('\n') || '暂无配角设定'}

## 世界观设定

### 时代背景
${data.worldSetting?.time || '[待定]'}

### 地理环境
${data.worldSetting?.location || '[待定]'}

### 特殊规则
${data.worldSetting?.rules || '无特殊设定'}

## 情节大纲

### 第一幕：开端 (约25%)
- **引入**: ${data.plotOutline?.act1 || '[待填写]'}
- **触发事件**: ${data.plotOutline?.incitingIncident || '[待填写]'}

### 第二幕：发展 (约50%)
- **上升阶段**: ${data.plotOutline?.act2a || '[待填写]'}
- **中点转折**: ${data.plotOutline?.midpoint || '[待填写]'}
- **下降阶段**: ${data.plotOutline?.act2b || '[待填写]'}

### 第三幕：高潮与结局 (约25%)
- **最终对决**: ${data.plotOutline?.act3 || '[待填写]'}
- **结局**: [待定]

## 创作备注

### 灵感来源
[记录灵感来源]

### 参考作品
[列出参考的作品]

### 注意事项
[创作时需要注意的问题]

---
*最后更新: ${new Date().toLocaleString('zh-CN')}*
`;
}

async function createCharacterFiles(storyData: any) {
  const charactersDir = path.join(process.cwd(), 'characters');
  await fs.ensureDir(charactersDir);

  // 创建主角文件
  if (storyData.protagonist?.name) {
    const protagonistDoc = `# ${storyData.protagonist.name}

## 基本信息
- **身份**: 主角
- **年龄**: ${storyData.protagonist.age || '未定'}
- **性别**: ${storyData.protagonist.gender || '未定'}

## 性格特征
${Array.isArray(storyData.protagonist.personality) ? storyData.protagonist.personality.map((p: string) => `- ${p}`).join('\n') : storyData.protagonist.personality || '待定'}

## 背景故事
${storyData.protagonist.background || '待填写'}

## 核心动机
${storyData.protagonist.motivation || '待填写'}

## 成长弧线
${storyData.protagonist.growth || '待填写'}

## 外貌描写
[待补充]

## 性格分析
[待补充]

## 人物关系
[待补充]

## 重要经历
[待补充]

## 台词风格
[待补充]
`;

    await fs.writeFile(
      path.join(charactersDir, `${storyData.protagonist.name}.md`),
      protagonistDoc
    );
  }

  // 创建配角文件
  for (const character of storyData.characters || []) {
    if (character.name) {
      const characterDoc = `# ${character.name}

## 基本信息
- **身份**: ${character.role || '配角'}
- **与主角关系**: ${character.relationship || '待定'}

## 角色功能
[在故事中的作用]

## 性格特征
[待补充]

## 背景故事
[待补充]

## 外貌描写
[待补充]

## 重要台词
[待补充]
`;

      await fs.writeFile(
        path.join(charactersDir, `${character.name}.md`),
        characterDoc
      );
    }
  }
}