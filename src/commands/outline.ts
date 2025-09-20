import chalk from 'chalk';
import inquirer from 'inquirer';
import fs from 'fs-extra';
import path from 'path';
import ora from 'ora';

interface ChapterOutline {
  number: number;
  title: string;
  viewpoint: string;
  timePlace: string;
  events: string[];
  characterDevelopment: string;
  plotFunction: string;
  emotionalTone: string;
  targetWords: number;
}

export async function outline(options: { chapters?: string; wordsPerChapter?: string }) {
  const spinner = ora('准备章节规划...').start();

  try {
    // 检查项目和故事大纲
    const configPath = path.join(process.cwd(), '.novel', 'config.json');
    const storyPath = path.join(process.cwd(), '.novel', 'story.json');

    if (!await fs.pathExists(configPath)) {
      spinner.fail(chalk.red('错误: 当前目录不是小说项目目录'));
      process.exit(1);
    }

    if (!await fs.pathExists(storyPath)) {
      spinner.warn(chalk.yellow('警告: 尚未创建故事大纲'));
      console.log(chalk.cyan('提示: 请先使用 "novel story" 创建故事大纲'));
      process.exit(1);
    }

    spinner.stop();

    const storyData = await fs.readJson(storyPath);
    const chapterCount = parseInt(options.chapters || '30');
    const wordsPerChapter = parseInt(options.wordsPerChapter || '3000');

    console.log(chalk.cyan(`\n规划 ${chapterCount} 章，每章约 ${wordsPerChapter} 字\n`));

    // 询问整体结构
    const structure = await inquirer.prompt([
      {
        type: 'input',
        name: 'volumes',
        message: '分为几卷/部分? (输入数字):',
        default: '1',
        validate: (input) => {
          const num = parseInt(input);
          return num > 0 && num <= 10 || '请输入1-10之间的数字';
        }
      },
      {
        type: 'list',
        name: 'updateSchedule',
        message: '更新计划:',
        choices: ['日更', '周更', '不定期', '存稿后一次发布']
      },
      {
        type: 'confirm',
        name: 'detailedOutline',
        message: '是否创建详细的章节大纲?',
        default: false
      }
    ]);

    const volumeCount = parseInt(structure.volumes);
    const chaptersPerVolume = Math.ceil(chapterCount / volumeCount);

    // 生成章节框架
    const volumes = [];
    for (let v = 1; v <= volumeCount; v++) {
      const volumeData = await createVolume(v, chaptersPerVolume, wordsPerChapter, structure.detailedOutline);
      volumes.push(volumeData);
    }

    // 生成章节规划文档
    const outlineDoc = generateOutlineDocument({
      title: storyData.title || '未命名小说',
      totalChapters: chapterCount,
      wordsPerChapter,
      updateSchedule: structure.updateSchedule,
      volumes
    });

    // 保存文件
    const outlinePath = path.join(process.cwd(), 'chapter-outline.md');
    const dataPath = path.join(process.cwd(), '.novel', 'outline.json');

    await fs.writeFile(outlinePath, outlineDoc);
    await fs.writeJson(dataPath, {
      chapterCount,
      wordsPerChapter,
      updateSchedule: structure.updateSchedule,
      volumes
    }, { spaces: 2 });

    // 创建章节目录结构
    await createChapterFolders(volumes);

    console.log('\n' + chalk.green('✓ 章节规划完成！'));
    console.log(chalk.gray('─────────────────────────────'));
    console.log('章节大纲: ' + chalk.cyan('chapter-outline.md'));
    console.log('数据文件: ' + chalk.cyan('.novel/outline.json'));
    console.log('章节目录: ' + chalk.cyan('chapters/'));
    console.log('\n预计总字数: ' + chalk.yellow(`${(chapterCount * wordsPerChapter / 10000).toFixed(1)} 万字`));

    // 生成节奏控制建议
    generatePacingAdvice(chapterCount);

    console.log('\n' + chalk.dim('下一步: 使用 "novel tasks" 生成写作任务'));

  } catch (error) {
    spinner.fail(chalk.red('章节规划失败'));
    console.error(error);
    process.exit(1);
  }
}

async function createVolume(
  volumeNumber: number,
  chapterCount: number,
  wordsPerChapter: number,
  detailed: boolean
): Promise<any> {
  const volumeName = await inquirer.prompt([
    {
      type: 'input',
      name: 'name',
      message: `第 ${volumeNumber} 卷标题:`,
      default: `第${volumeNumber}卷`
    },
    {
      type: 'input',
      name: 'theme',
      message: `第 ${volumeNumber} 卷主题:`,
      default: ''
    }
  ]);

  const chapters: ChapterOutline[] = [];

  if (detailed) {
    console.log(chalk.yellow(`\n创建第 ${volumeNumber} 卷的章节大纲:`));

    // 只为前3章创建详细大纲作为示例
    for (let i = 1; i <= Math.min(3, chapterCount); i++) {
      const chapterNum = (volumeNumber - 1) * chapterCount + i;
      console.log(chalk.cyan(`\n第 ${chapterNum} 章:`));

      const chapter = await inquirer.prompt([
        {
          type: 'input',
          name: 'title',
          message: '章节标题:',
          default: `第${chapterNum}章`
        },
        {
          type: 'input',
          name: 'mainEvent',
          message: '主要事件 (一句话概括):',
        }
      ]);

      chapters.push({
        number: chapterNum,
        title: chapter.title,
        viewpoint: '主角',
        timePlace: '',
        events: [chapter.mainEvent || '待定'],
        characterDevelopment: '',
        plotFunction: '',
        emotionalTone: '',
        targetWords: wordsPerChapter
      });
    }

    // 其余章节使用占位符
    for (let i = 4; i <= chapterCount; i++) {
      const chapterNum = (volumeNumber - 1) * chapterCount + i;
      chapters.push({
        number: chapterNum,
        title: `第${chapterNum}章`,
        viewpoint: '待定',
        timePlace: '待定',
        events: ['待定'],
        characterDevelopment: '待定',
        plotFunction: '待定',
        emotionalTone: '待定',
        targetWords: wordsPerChapter
      });
    }
  } else {
    // 自动生成章节占位符
    for (let i = 1; i <= chapterCount; i++) {
      const chapterNum = (volumeNumber - 1) * chapterCount + i;
      chapters.push({
        number: chapterNum,
        title: `第${chapterNum}章`,
        viewpoint: '待定',
        timePlace: '待定',
        events: ['待定'],
        characterDevelopment: '待定',
        plotFunction: '待定',
        emotionalTone: '待定',
        targetWords: wordsPerChapter
      });
    }
  }

  return {
    number: volumeNumber,
    name: volumeName.name,
    theme: volumeName.theme,
    chapters
  };
}

function generateOutlineDocument(data: any): string {
  let doc = `# 章节规划：${data.title}

## 整体结构
- **总章节数**: ${data.totalChapters} 章
- **平均章节字数**: ${data.wordsPerChapter} 字
- **预计总字数**: ${(data.totalChapters * data.wordsPerChapter / 10000).toFixed(1)} 万字
- **更新计划**: ${data.updateSchedule}

## 卷册划分
`;

  data.volumes.forEach((volume: any) => {
    doc += `
### ${volume.name}
**主题**: ${volume.theme || '待定'}
**章节数**: ${volume.chapters.length} 章
**预计字数**: ${(volume.chapters.length * data.wordsPerChapter / 10000).toFixed(1)} 万字
`;
  });

  doc += `\n## 详细章节大纲\n`;

  data.volumes.forEach((volume: any) => {
    doc += `\n### ${volume.name}\n`;

    volume.chapters.forEach((chapter: ChapterOutline) => {
      doc += `
#### ${chapter.title}
- **视角人物**: ${chapter.viewpoint}
- **时间地点**: ${chapter.timePlace || '待定'}
- **主要事件**: ${chapter.events.join(', ')}
- **角色发展**: ${chapter.characterDevelopment || '待定'}
- **情节功能**: ${chapter.plotFunction || '待定'}
- **情绪基调**: ${chapter.emotionalTone || '待定'}
- **字数目标**: ${chapter.targetWords} 字
`;
    });
  });

  doc += `
## 节奏控制

### 情节密度分布
- **开篇钩子**: 第1-3章
- **世界展开**: 第4-10章
- **矛盾升级**: 第11-20章
- **中段高潮**: 第21-25章
- **危机加深**: 第26-35章
- **最终对决**: 第36-40章
- **收尾余韵**: 最后几章

### 悬念与伏笔
- **主要悬念**: [待设置]
- **伏笔位置**: [待标记]
- **揭示时机**: [待规划]

### 情感曲线
- **轻松段落**: [标记章节]
- **紧张段落**: [标记章节]
- **感动段落**: [标记章节]
- **高燃段落**: [标记章节]

---
*创建时间: ${new Date().toLocaleString('zh-CN')}*
`;

  return doc;
}

async function createChapterFolders(volumes: any[]) {
  const chaptersDir = path.join(process.cwd(), 'chapters');

  for (const volume of volumes) {
    const volumeDir = path.join(chaptersDir, `volume-${volume.number}`);
    await fs.ensureDir(volumeDir);

    // 为每个章节创建占位文件
    for (const chapter of volume.chapters) {
      const chapterFile = path.join(
        volumeDir,
        `chapter-${String(chapter.number).padStart(3, '0')}.md`
      );

      if (!await fs.pathExists(chapterFile)) {
        const content = `# ${chapter.title}

## 章节信息
- **字数目标**: ${chapter.targetWords}
- **视角**: ${chapter.viewpoint}
- **基调**: ${chapter.emotionalTone || '待定'}

## 大纲
${chapter.events.map((e: string) => `- ${e}`).join('\n')}

## 正文

[待创作]

---
*创建时间: ${new Date().toLocaleString('zh-CN')}*
`;
        await fs.writeFile(chapterFile, content);
      }
    }
  }
}

function generatePacingAdvice(chapterCount: number) {
  console.log('\n' + chalk.cyan('节奏控制建议:'));
  console.log(chalk.gray('─────────────────────────────'));

  const suggestions = [
    { range: [1, 3], advice: '开篇钩子，快速吸引读者' },
    { range: [Math.floor(chapterCount * 0.25), Math.floor(chapterCount * 0.25) + 2], advice: '第一个小高潮' },
    { range: [Math.floor(chapterCount * 0.5), Math.floor(chapterCount * 0.5) + 2], advice: '中段大转折' },
    { range: [Math.floor(chapterCount * 0.75), Math.floor(chapterCount * 0.75) + 2], advice: '危机最深处' },
    { range: [chapterCount - 3, chapterCount], advice: '最终高潮与结局' }
  ];

  suggestions.forEach(({ range, advice }) => {
    if (range[0] <= chapterCount) {
      console.log(`  第 ${range[0]}-${Math.min(range[1], chapterCount)} 章: ${chalk.yellow(advice)}`);
    }
  });
}