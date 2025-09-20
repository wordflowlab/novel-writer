import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import ora from 'ora';
import inquirer from 'inquirer';

interface WritingTask {
  id: number;
  type: 'chapter' | 'revision' | 'planning' | 'research';
  title: string;
  description: string;
  priority: 'high' | 'medium' | 'low';
  status: 'pending' | 'in-progress' | 'completed';
  estimatedWords?: number;
  deadline?: string;
  dependencies?: number[];
}

export async function tasks(options: { priority?: boolean }) {
  const spinner = ora('生成写作任务...').start();

  try {
    // 检查必要文件
    const outlinePath = path.join(process.cwd(), '.novel', 'outline.json');
    if (!await fs.pathExists(outlinePath)) {
      spinner.fail(chalk.red('错误: 尚未创建章节规划'));
      console.log(chalk.cyan('提示: 请先使用 "novel outline" 规划章节'));
      process.exit(1);
    }

    spinner.stop();

    const outlineData = await fs.readJson(outlinePath);

    // 生成任务列表
    const taskList: WritingTask[] = [];
    let taskId = 1;

    // 创建章节写作任务
    for (const volume of outlineData.volumes) {
      for (const chapter of volume.chapters) {
        taskList.push({
          id: taskId++,
          type: 'chapter',
          title: `撰写 ${chapter.title}`,
          description: `完成第 ${chapter.number} 章的初稿，约 ${chapter.targetWords} 字`,
          priority: chapter.number <= 3 ? 'high' : 'medium',
          status: 'pending',
          estimatedWords: chapter.targetWords
        });
      }
    }

    // 询问是否添加其他任务
    const { addExtraTasks } = await inquirer.prompt([
      {
        type: 'confirm',
        name: 'addExtraTasks',
        message: '是否添加额外任务 (如角色完善、世界观补充等)?',
        default: true
      }
    ]);

    if (addExtraTasks) {
      const extraTasks = await createExtraTasks();
      extraTasks.forEach(task => {
        taskList.push({
          id: taskId++,
          type: task.type || 'planning',
          title: task.title || '',
          description: task.description || '',
          priority: task.priority || 'medium',
          status: task.status || 'pending',
          estimatedWords: task.estimatedWords,
          deadline: task.deadline,
          dependencies: task.dependencies
        });
      });
    }

    // 按优先级排序
    if (options.priority) {
      taskList.sort((a, b) => {
        const priorityOrder = { high: 0, medium: 1, low: 2 };
        return priorityOrder[a.priority] - priorityOrder[b.priority];
      });
    }

    // 生成任务文档
    const tasksDoc = generateTasksDocument(taskList, outlineData);

    // 保存文件
    const tasksPath = path.join(process.cwd(), 'writing-tasks.md');
    const dataPath = path.join(process.cwd(), '.novel', 'tasks.json');

    await fs.writeFile(tasksPath, tasksDoc);
    await fs.writeJson(dataPath, taskList, { spaces: 2 });

    // 显示任务统计
    displayTaskStatistics(taskList);

    console.log('\n' + chalk.green('✓ 写作任务生成完成！'));
    console.log(chalk.gray('─────────────────────────────'));
    console.log('任务列表: ' + chalk.cyan('writing-tasks.md'));
    console.log('数据文件: ' + chalk.cyan('.novel/tasks.json'));

    // 显示即将开始的任务
    const urgentTasks = taskList.filter(t => t.priority === 'high' && t.status === 'pending').slice(0, 3);
    if (urgentTasks.length > 0) {
      console.log('\n' + chalk.yellow('优先任务:'));
      urgentTasks.forEach(task => {
        console.log(`  • ${task.title}`);
      });
    }

    console.log('\n' + chalk.dim('下一步: 使用 "novel write --chapter 1" 开始创作'));

  } catch (error) {
    spinner.fail(chalk.red('生成任务失败'));
    console.error(error);
    process.exit(1);
  }
}

async function createExtraTasks(): Promise<Partial<WritingTask>[]> {
  const tasks: Partial<WritingTask>[] = [];

  const taskTypes = await inquirer.prompt([
    {
      type: 'checkbox',
      name: 'types',
      message: '选择要添加的任务类型:',
      choices: [
        { name: '完善主角设定', value: 'protagonist' },
        { name: '完善配角设定', value: 'characters' },
        { name: '补充世界观设定', value: 'world' },
        { name: '研究背景资料', value: 'research' },
        { name: '制作人物关系图', value: 'relationships' },
        { name: '绘制地图', value: 'map' },
        { name: '编写大事年表', value: 'timeline' }
      ]
    }
  ]);

  const taskTemplates: Record<string, Partial<WritingTask>> = {
    protagonist: {
      type: 'planning',
      title: '完善主角设定',
      description: '深化主角的背景故事、性格特征和成长轨迹',
      priority: 'high',
      status: 'pending'
    },
    characters: {
      type: 'planning',
      title: '完善配角设定',
      description: '为重要配角创建详细的人物档案',
      priority: 'medium',
      status: 'pending'
    },
    world: {
      type: 'planning',
      title: '补充世界观设定',
      description: '完善世界规则、历史背景和社会结构',
      priority: 'medium',
      status: 'pending'
    },
    research: {
      type: 'research',
      title: '研究背景资料',
      description: '收集和整理相关的历史、文化或技术资料',
      priority: 'low',
      status: 'pending'
    },
    relationships: {
      type: 'planning',
      title: '制作人物关系图',
      description: '绘制角色之间的关系网络图',
      priority: 'low',
      status: 'pending'
    },
    map: {
      type: 'planning',
      title: '绘制故事地图',
      description: '创建故事发生地的地理布局图',
      priority: 'low',
      status: 'pending'
    },
    timeline: {
      type: 'planning',
      title: '编写大事年表',
      description: '整理故事世界的历史大事件时间线',
      priority: 'low',
      status: 'pending'
    }
  };

  taskTypes.types.forEach((type: string) => {
    if (taskTemplates[type]) {
      tasks.push(taskTemplates[type]);
    }
  });

  return tasks;
}

function generateTasksDocument(tasks: WritingTask[], outlineData: any): string {
  const totalWords = tasks
    .filter(t => t.type === 'chapter')
    .reduce((sum, t) => sum + (t.estimatedWords || 0), 0);

  const tasksByType = {
    chapter: tasks.filter(t => t.type === 'chapter'),
    planning: tasks.filter(t => t.type === 'planning'),
    research: tasks.filter(t => t.type === 'research'),
    revision: tasks.filter(t => t.type === 'revision')
  };

  let doc = `# 写作任务清单

## 概览
- **总任务数**: ${tasks.length}
- **章节任务**: ${tasksByType.chapter.length} 个
- **规划任务**: ${tasksByType.planning.length} 个
- **研究任务**: ${tasksByType.research.length} 个
- **预计字数**: ${(totalWords / 10000).toFixed(1)} 万字

## 任务状态
- 🔴 待开始: ${tasks.filter(t => t.status === 'pending').length} 个
- 🟡 进行中: ${tasks.filter(t => t.status === 'in-progress').length} 个
- 🟢 已完成: ${tasks.filter(t => t.status === 'completed').length} 个

## 优先级分布
- **高优先级**: ${tasks.filter(t => t.priority === 'high').length} 个
- **中优先级**: ${tasks.filter(t => t.priority === 'medium').length} 个
- **低优先级**: ${tasks.filter(t => t.priority === 'low').length} 个

## 详细任务列表

### 高优先级任务
${tasks.filter(t => t.priority === 'high').map(t => formatTask(t)).join('\n')}

### 中优先级任务
${tasks.filter(t => t.priority === 'medium').map(t => formatTask(t)).join('\n')}

### 低优先级任务
${tasks.filter(t => t.priority === 'low').map(t => formatTask(t)).join('\n')}

## 执行建议

### 第一阶段 (准备期)
1. 完成所有规划任务
2. 完成必要的研究任务
3. 确保世界观和角色设定完整

### 第二阶段 (创作期)
1. 按章节顺序完成初稿
2. 保持稳定的更新节奏
3. 定期回顾和调整大纲

### 第三阶段 (完善期)
1. 修订已完成的章节
2. 检查情节连贯性
3. 统一文风和用词

## 时间规划
${generateSchedule(tasks, outlineData)}

---
*生成时间: ${new Date().toLocaleString('zh-CN')}*
`;

  return doc;
}

function formatTask(task: WritingTask): string {
  const statusIcon = {
    pending: '⬜',
    'in-progress': '🔄',
    completed: '✅'
  }[task.status];

  const typeLabel = {
    chapter: '写作',
    planning: '规划',
    research: '研究',
    revision: '修订'
  }[task.type];

  return `
#### ${statusIcon} ${task.title}
- **类型**: ${typeLabel}
- **描述**: ${task.description}
${task.estimatedWords ? `- **预计字数**: ${task.estimatedWords}` : ''}
${task.deadline ? `- **截止日期**: ${task.deadline}` : ''}
`;
}

function generateSchedule(tasks: WritingTask[], outlineData: any): string {
  const chapterTasks = tasks.filter(t => t.type === 'chapter');
  const wordsPerDay = 2000; // 假设每天写2000字
  const totalDays = Math.ceil(chapterTasks.reduce((sum, t) => sum + (t.estimatedWords || 0), 0) / wordsPerDay);

  const schedule = `
### 预计时间
- **每日写作量**: ${wordsPerDay} 字
- **总需天数**: ${totalDays} 天
- **预计完成**: ${new Date(Date.now() + totalDays * 24 * 60 * 60 * 1000).toLocaleDateString('zh-CN')}

### 里程碑
- **第一卷完成**: 约 ${Math.ceil(totalDays / 3)} 天
- **全书初稿**: 约 ${totalDays} 天
- **修订完成**: 约 ${totalDays + 30} 天
`;

  return schedule;
}

function displayTaskStatistics(tasks: WritingTask[]) {
  console.log('\n' + chalk.cyan('任务统计:'));
  console.log(chalk.gray('─────────────────────────────'));

  const stats = [
    {
      label: '章节写作',
      count: tasks.filter(t => t.type === 'chapter').length
    },
    {
      label: '角色规划',
      count: tasks.filter(t => t.type === 'planning' && t.title.includes('角色')).length
    },
    {
      label: '世界观设定',
      count: tasks.filter(t => t.type === 'planning' && t.title.includes('世界')).length
    },
    {
      label: '背景研究',
      count: tasks.filter(t => t.type === 'research').length
    }
  ];

  stats.forEach(stat => {
    if (stat.count > 0) {
      console.log(`  ${stat.label}: ${chalk.yellow(stat.count)} 个任务`);
    }
  });

  const totalWords = tasks
    .filter(t => t.type === 'chapter')
    .reduce((sum, t) => sum + (t.estimatedWords || 0), 0);

  console.log(`  预计总字数: ${chalk.yellow((totalWords / 10000).toFixed(1))} 万字`);
}