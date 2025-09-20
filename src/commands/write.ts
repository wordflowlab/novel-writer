import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import ora from 'ora';
import inquirer from 'inquirer';

export async function write(options: { chapter?: string; mode?: string }) {
  const spinner = ora('准备写作环境...').start();

  try {
    // 检查必要文件
    const outlinePath = path.join(process.cwd(), '.novel', 'outline.json');
    const stylePath = path.join(process.cwd(), '.novel', 'style.json');
    const storyPath = path.join(process.cwd(), '.novel', 'story.json');

    if (!await fs.pathExists(outlinePath)) {
      spinner.fail(chalk.red('错误: 尚未创建章节规划'));
      console.log(chalk.cyan('提示: 请先使用 "novel outline" 规划章节'));
      process.exit(1);
    }

    spinner.stop();

    const outlineData = await fs.readJson(outlinePath);
    const styleData = await fs.pathExists(stylePath) ? await fs.readJson(stylePath) : {};
    const storyData = await fs.pathExists(storyPath) ? await fs.readJson(storyPath) : {};

    // 确定要写作的章节
    let chapterNumber: number = options.chapter ? parseInt(options.chapter) : 0;

    if (!chapterNumber) {
      // 自动找到下一个未写的章节
      const nextChapter = await findNextChapter(outlineData);
      if (!nextChapter) {
        console.log(chalk.yellow('所有章节都已有内容，请指定要重写的章节'));
        const { selectedChapter } = await inquirer.prompt([
          {
            type: 'number',
            name: 'selectedChapter',
            message: '输入章节号:',
            validate: (input) => input > 0 && input <= getTotalChapters(outlineData)
          }
        ]);
        chapterNumber = selectedChapter;
      } else {
        chapterNumber = nextChapter;
      }
    }

    // 获取章节信息
    const chapterInfo = getChapterInfo(outlineData, chapterNumber);
    if (!chapterInfo) {
      console.log(chalk.red(`错误: 找不到第 ${chapterNumber} 章`));
      process.exit(1);
    }

    console.log(chalk.cyan(`\n准备创作: ${chapterInfo.title}`));
    console.log(chalk.gray('─────────────────────────────'));

    // 显示章节大纲
    console.log(chalk.yellow('章节大纲:'));
    console.log(`  视角: ${chapterInfo.viewpoint}`);
    console.log(`  事件: ${chapterInfo.events.join(', ')}`);
    console.log(`  基调: ${chapterInfo.emotionalTone}`);
    console.log(`  目标字数: ${chapterInfo.targetWords}`);

    // 获取前文摘要
    const previousSummary = await getPreviousChaptersSummary(chapterNumber);
    if (previousSummary) {
      console.log('\n' + chalk.yellow('前文摘要:'));
      console.log(chalk.gray(previousSummary));
    }

    // 写作模式选择
    const mode = options.mode || 'draft';

    if (mode === 'draft') {
      console.log('\n' + chalk.cyan('草稿模式 - 快速创作，不追求完美'));
      await writeDraft(chapterInfo, styleData, storyData, previousSummary);
    } else if (mode === 'refine') {
      console.log('\n' + chalk.cyan('精修模式 - 优化已有内容'));
      await refineChapter(chapterInfo, styleData);
    }

    // 更新任务状态
    await updateTaskStatus(chapterNumber, 'completed');

    console.log('\n' + chalk.green(`✓ 第 ${chapterNumber} 章创作完成！`));
    console.log(chalk.dim('提示: 使用 "novel write --chapter ' + (chapterNumber + 1) + '" 继续下一章'));

  } catch (error) {
    spinner.fail(chalk.red('写作过程出错'));
    console.error(error);
    process.exit(1);
  }
}

async function findNextChapter(outlineData: any): Promise<number | null> {
  for (const volume of outlineData.volumes) {
    for (const chapter of volume.chapters) {
      const chapterPath = getChapterFilePath(chapter.number);
      if (await fs.pathExists(chapterPath)) {
        const content = await fs.readFile(chapterPath, 'utf-8');
        if (content.includes('[待创作]')) {
          return chapter.number;
        }
      } else {
        return chapter.number;
      }
    }
  }
  return null;
}

function getTotalChapters(outlineData: any): number {
  return outlineData.volumes.reduce((sum: number, v: any) =>
    sum + v.chapters.length, 0);
}

function getChapterInfo(outlineData: any, chapterNumber: number): any {
  for (const volume of outlineData.volumes) {
    const chapter = volume.chapters.find((c: any) => c.number === chapterNumber);
    if (chapter) {
      return { ...chapter, volumeName: volume.name };
    }
  }
  return null;
}

function getChapterFilePath(chapterNumber: number): string {
  // 简单假设每30章一卷
  const volumeNumber = Math.ceil(chapterNumber / 30);
  const fileName = `chapter-${String(chapterNumber).padStart(3, '0')}.md`;
  return path.join(process.cwd(), 'chapters', `volume-${volumeNumber}`, fileName);
}

async function getPreviousChaptersSummary(currentChapter: number): Promise<string | null> {
  if (currentChapter === 1) return null;

  const summaries = [];
  const checkCount = Math.min(3, currentChapter - 1); // 最多检查前3章

  for (let i = currentChapter - checkCount; i < currentChapter; i++) {
    const chapterPath = getChapterFilePath(i);
    if (await fs.pathExists(chapterPath)) {
      const content = await fs.readFile(chapterPath, 'utf-8');
      // 提取摘要部分（如果有的话）
      const summaryMatch = content.match(/## 摘要\n([\s\S]*?)(\n##|$)/);
      if (summaryMatch) {
        summaries.push(`第${i}章: ${summaryMatch[1].trim()}`);
      }
    }
  }

  return summaries.length > 0 ? summaries.join('\n') : null;
}

async function writeDraft(
  chapterInfo: any,
  styleData: any,
  storyData: any,
  previousSummary: string | null
) {
  console.log('\n' + chalk.cyan('开始创作初稿...'));

  // 构建创作提示
  const prompt = buildWritingPrompt(chapterInfo, styleData, storyData, previousSummary);

  // 这里应该调用 AI API 来生成内容
  // 暂时生成一个模板
  const content = generateDraftTemplate(chapterInfo, prompt);

  // 保存到文件
  const chapterPath = getChapterFilePath(chapterInfo.number);
  await fs.ensureDir(path.dirname(chapterPath));
  await fs.writeFile(chapterPath, content);

  console.log(chalk.green('初稿已保存到: ' + chapterPath));

  // 显示字数统计
  const wordCount = content.length;
  console.log(chalk.cyan(`字数: ${wordCount} / ${chapterInfo.targetWords} (${(wordCount / chapterInfo.targetWords * 100).toFixed(1)}%)`));
}

async function refineChapter(chapterInfo: any, styleData: any) {
  const chapterPath = getChapterFilePath(chapterInfo.number);

  if (!await fs.pathExists(chapterPath)) {
    console.log(chalk.yellow('章节文件不存在，将创建初稿'));
    await writeDraft(chapterInfo, styleData, {}, null);
    return;
  }

  console.log(chalk.cyan('读取现有内容...'));
  const currentContent = await fs.readFile(chapterPath, 'utf-8');

  // 这里应该调用 AI API 来优化内容
  console.log(chalk.yellow('精修功能开发中...'));

  // 暂时只是备份
  const backupPath = chapterPath.replace('.md', `.backup-${Date.now()}.md`);
  await fs.copy(chapterPath, backupPath);
  console.log(chalk.dim('已创建备份: ' + path.basename(backupPath)));
}

function buildWritingPrompt(
  chapterInfo: any,
  styleData: any,
  storyData: any,
  previousSummary: string | null
): string {
  const parts = [];

  // 基本信息
  parts.push(`章节: ${chapterInfo.title}`);
  parts.push(`字数要求: ${chapterInfo.targetWords} 字`);

  // 风格要求
  if (styleData.narrative) {
    const narrativeMap: Record<string, string> = {
      'first-person': '第一人称',
      'third-limited': '第三人称有限视角',
      'third-omniscient': '第三人称全知视角'
    };
    parts.push(`叙事视角: ${narrativeMap[styleData.narrative]}`);
  }

  if (styleData.tone) {
    parts.push(`基调: ${styleData.tone}`);
  }

  if (styleData.language) {
    parts.push(`语言风格: ${styleData.language}`);
  }

  // 情节要求
  parts.push(`\n主要事件:\n${chapterInfo.events.map((e: string) => `- ${e}`).join('\n')}`);

  // 角色信息
  if (storyData.protagonist) {
    parts.push(`\n主角: ${storyData.protagonist.name}`);
    if (storyData.protagonist.personality) {
      parts.push(`性格: ${Array.isArray(storyData.protagonist.personality) ?
        storyData.protagonist.personality.join('、') : storyData.protagonist.personality}`);
    }
  }

  // 前文衔接
  if (previousSummary) {
    parts.push(`\n前情提要:\n${previousSummary}`);
  }

  return parts.join('\n');
}

function generateDraftTemplate(chapterInfo: any, prompt: string): string {
  return `# ${chapterInfo.title}

## 章节信息
- **所属卷**: ${chapterInfo.volumeName || '未分卷'}
- **字数目标**: ${chapterInfo.targetWords}
- **视角**: ${chapterInfo.viewpoint}
- **基调**: ${chapterInfo.emotionalTone || '待定'}
- **创作时间**: ${new Date().toLocaleString('zh-CN')}

## 大纲
${chapterInfo.events.map((e: string) => `- ${e}`).join('\n')}

## 摘要
[本章主要讲述了...]

## 正文

### 开场

[待创作 - 这里应该是引人入胜的开场]

### 发展

[待创作 - 情节逐步展开]

### 转折

[待创作 - 关键转折点]

### 结尾

[待创作 - 留下悬念或铺垫]

---

## 创作笔记

### AI 提示词
\`\`\`
${prompt}
\`\`\`

### 待完善
- [ ] 补充环境描写
- [ ] 深化人物心理
- [ ] 检查逻辑连贯性
- [ ] 优化对话

### 修订记录
- ${new Date().toLocaleDateString('zh-CN')}: 创建初稿

---
*使用 Novel Writer 创作*
`;
}

async function updateTaskStatus(chapterNumber: number, status: string) {
  const tasksPath = path.join(process.cwd(), '.novel', 'tasks.json');

  if (await fs.pathExists(tasksPath)) {
    const tasks = await fs.readJson(tasksPath);
    const task = tasks.find((t: any) =>
      t.type === 'chapter' && t.title.includes(`第 ${chapterNumber} 章`)
    );

    if (task) {
      task.status = status;
      await fs.writeJson(tasksPath, tasks, { spaces: 2 });
      console.log(chalk.dim(`任务状态已更新: ${task.title} -> ${status}`));
    }
  }
}