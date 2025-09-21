/**
 * 混合方法支持
 * 允许组合使用多种写作方法
 */

interface HybridConfig {
  primary: {
    method: string;
    scope: 'main-plot';
  };
  secondary?: {
    method: string;
    scope: 'sub-plot' | 'character-arc' | 'chapter-structure';
  };
  micro?: {
    method: string;
    scope: 'scene' | 'chapter';
  };
}

interface HybridStructure {
  config: HybridConfig;
  mapping: StructureMapping;
  guidelines: string[];
  examples: string[];
}

interface StructureMapping {
  mainPlot: PlotStructure;
  subPlots?: PlotStructure[];
  characterArcs?: CharacterArcStructure[];
  chapterTemplates?: ChapterTemplate[];
}

interface PlotStructure {
  method: string;
  elements: StructureElement[];
}

interface StructureElement {
  name: string;
  chapters: number[];
  description: string;
}

interface CharacterArcStructure {
  character: string;
  method: string;
  arc: StructureElement[];
}

interface ChapterTemplate {
  chapterRange?: number[];
  method: string;
  template: string;
}

export class HybridMethodManager {
  /**
   * 预定义的有效混合组合
   */
  private validCombinations = [
    {
      name: '史诗奇幻组合',
      primary: 'hero-journey',
      secondary: 'story-circle',
      description: '主线用英雄之旅，角色支线用故事圈',
      suitable: ['奇幻', '史诗', '系列小说']
    },
    {
      name: '悬疑惊悚组合',
      primary: 'seven-point',
      secondary: 'three-act',
      description: '整体用七点结构，章节用三幕组织',
      suitable: ['悬疑', '惊悚', '推理']
    },
    {
      name: '多线叙事组合',
      primary: 'three-act',
      secondary: 'story-circle',
      micro: 'pixar-formula',
      description: '主线三幕，支线故事圈，场景用皮克斯',
      suitable: ['群像', '多线', '现代文学']
    },
    {
      name: '成长故事组合',
      primary: 'story-circle',
      secondary: 'hero-journey',
      description: '整体循环结构，关键章节用英雄之旅',
      suitable: ['成长', '青春', '系列']
    }
  ];

  /**
   * 创建混合结构
   */
  createHybridStructure(config: HybridConfig, storyDetails: any): HybridStructure {
    // 验证组合有效性
    this.validateCombination(config);

    // 创建主线结构
    const mainPlot = this.createMainPlot(config.primary.method, storyDetails);

    // 创建次要结构
    const mapping: StructureMapping = {
      mainPlot
    };

    if (config.secondary) {
      if (config.secondary.scope === 'sub-plot') {
        mapping.subPlots = this.createSubPlots(config.secondary.method, storyDetails);
      } else if (config.secondary.scope === 'character-arc') {
        mapping.characterArcs = this.createCharacterArcs(config.secondary.method, storyDetails);
      }
    }

    if (config.micro) {
      mapping.chapterTemplates = this.createChapterTemplates(config.micro.method, storyDetails);
    }

    // 生成指导原则
    const guidelines = this.generateGuidelines(config);

    // 生成示例
    const examples = this.generateExamples(config);

    return {
      config,
      mapping,
      guidelines,
      examples
    };
  }

  /**
   * 验证组合有效性
   */
  private validateCombination(config: HybridConfig): void {
    const incompatible = [
      ['pixar-formula', 'hero-journey'], // 复杂度不匹配
      ['pixar-formula', 'seven-point']   // 复杂度不匹配
    ];

    if (config.primary && config.secondary) {
      const pair = [config.primary.method, config.secondary.method].sort();
      incompatible.forEach(([a, b]) => {
        if (pair[0] === a && pair[1] === b) {
          throw new Error(`不建议的组合：${a} 和 ${b} 复杂度差异太大`);
        }
      });
    }
  }

  /**
   * 创建主线结构
   */
  private createMainPlot(method: string, storyDetails: any): PlotStructure {
    const structures: Record<string, StructureElement[]> = {
      'three-act': [
        { name: '第一幕：建立', chapters: [1, 25], description: '介绍世界和冲突' },
        { name: '第二幕：发展', chapters: [26, 75], description: '冲突升级和发展' },
        { name: '第三幕：解决', chapters: [76, 100], description: '高潮和结局' }
      ],
      'hero-journey': [
        { name: '平凡世界', chapters: [1, 8], description: '英雄的日常' },
        { name: '冒险召唤', chapters: [9, 16], description: '打破平静' },
        // ... 其他阶段
      ],
      'seven-point': [
        { name: '钩子', chapters: [1, 3], description: '吸引读者' },
        { name: 'PP1', chapters: [25], description: '第一情节点' },
        // ... 其他节点
      ]
    };

    return {
      method,
      elements: structures[method] || []
    };
  }

  /**
   * 创建支线结构
   */
  private createSubPlots(method: string, storyDetails: any): PlotStructure[] {
    // 为每条支线创建结构
    const subPlots: PlotStructure[] = [];

    if (storyDetails.subPlots) {
      storyDetails.subPlots.forEach((subplot: any) => {
        subPlots.push({
          method,
          elements: this.adaptStructureToSubplot(method, subplot)
        });
      });
    }

    return subPlots;
  }

  /**
   * 创建角色弧线结构
   */
  private createCharacterArcs(method: string, storyDetails: any): CharacterArcStructure[] {
    const arcs: CharacterArcStructure[] = [];

    if (storyDetails.characters) {
      storyDetails.characters.forEach((character: any) => {
        if (character.hasArc) {
          arcs.push({
            character: character.name,
            method,
            arc: this.createCharacterArcElements(method, character)
          });
        }
      });
    }

    return arcs;
  }

  /**
   * 创建章节模板
   */
  private createChapterTemplates(method: string, storyDetails: any): ChapterTemplate[] {
    if (method === 'pixar-formula') {
      return [
        {
          method: 'pixar-formula',
          template: `
## 章节结构（皮克斯公式）
1. 开始状态：[本章开始时的情况]
2. 日常/期望：[角色在做什么/想要什么]
3. 变化事件：[什么打破了平静]
4. 因此1：[直接后果]
5. 因此2：[连锁反应]
6. 结果：[本章结尾状态]
          `
        }
      ];
    }

    return [];
  }

  /**
   * 适配结构到支线
   */
  private adaptStructureToSubplot(method: string, subplot: any): StructureElement[] {
    // 简化主线结构用于支线
    if (method === 'story-circle') {
      return [
        { name: '舒适区', chapters: subplot.startChapter, description: '支线起点' },
        { name: '需要', chapters: subplot.startChapter + 2, description: '产生需求' },
        { name: '搜索', chapters: subplot.middleChapters, description: '寻找解决' },
        { name: '找到', chapters: subplot.endChapter - 2, description: '获得答案' },
        { name: '改变', chapters: subplot.endChapter, description: '支线解决' }
      ];
    }

    return [];
  }

  /**
   * 创建角色弧线元素
   */
  private createCharacterArcElements(method: string, character: any): StructureElement[] {
    if (method === 'story-circle') {
      return [
        { name: '初始状态', chapters: [1, 10], description: `${character.name}的起点` },
        { name: '产生需求', chapters: [11, 20], description: '意识到缺失' },
        { name: '努力改变', chapters: [21, 60], description: '尝试和失败' },
        { name: '获得成长', chapters: [61, 80], description: '真正的改变' },
        { name: '新的自我', chapters: [81, 100], description: '完成转变' }
      ];
    }

    return [];
  }

  /**
   * 生成指导原则
   */
  private generateGuidelines(config: HybridConfig): string[] {
    const guidelines: string[] = [];

    guidelines.push(`主线情节使用${this.getMethodName(config.primary.method)}结构`);

    if (config.secondary) {
      if (config.secondary.scope === 'sub-plot') {
        guidelines.push(`支线情节使用${this.getMethodName(config.secondary.method)}结构`);
        guidelines.push('支线不要喧宾夺主，保持与主线的关联');
      } else if (config.secondary.scope === 'character-arc') {
        guidelines.push(`角色成长使用${this.getMethodName(config.secondary.method)}追踪`);
        guidelines.push('确保角色弧线与主线情节同步发展');
      }
    }

    if (config.micro) {
      guidelines.push(`单个${config.micro.scope}可以使用${this.getMethodName(config.micro.method)}组织`);
      guidelines.push('微观结构要服务于宏观结构');
    }

    guidelines.push('保持整体的一致性和连贯性');
    guidelines.push('避免结构冲突和重复');

    return guidelines;
  }

  /**
   * 生成示例
   */
  private generateExamples(config: HybridConfig): string[] {
    const examples: string[] = [];

    if (config.primary.method === 'hero-journey' && config.secondary?.method === 'story-circle') {
      examples.push(`
示例：《奇幻冒险》
- 主线（英雄之旅）：主角从平凡少年成长为拯救世界的英雄
- 支线A（故事圈）：导师角色寻找传承者的循环
- 支线B（故事圈）：反派从善到恶的堕落循环
      `);
    }

    if (config.primary.method === 'seven-point' && config.micro?.method === 'pixar-formula') {
      examples.push(`
示例：《都市悬疑》
- 整体结构（七点）：通过7个关键节点推进悬疑
- 章节结构（皮克斯）：每章用"因此...因此...最终"推进
      `);
    }

    return examples;
  }

  /**
   * 推荐混合方案
   */
  recommendHybrid(genre: string, length: number, complexity: string): HybridConfig | null {
    // 根据特征推荐混合方案
    if (genre === '奇幻' && length > 200000 && complexity === '复杂') {
      return {
        primary: { method: 'hero-journey', scope: 'main-plot' },
        secondary: { method: 'story-circle', scope: 'character-arc' }
      };
    }

    if (genre === '悬疑' && complexity === '中等') {
      return {
        primary: { method: 'seven-point', scope: 'main-plot' },
        micro: { method: 'three-act', scope: 'chapter' }
      };
    }

    if (genre === '群像' || genre === '多线') {
      return {
        primary: { method: 'three-act', scope: 'main-plot' },
        secondary: { method: 'story-circle', scope: 'sub-plot' }
      };
    }

    return null;
  }

  /**
   * 生成混合方法文档
   */
  generateHybridDocument(structure: HybridStructure): string {
    let doc = `# 混合方法结构文档\n\n`;

    doc += `## 方法配置\n`;
    doc += `- **主要方法**：${this.getMethodName(structure.config.primary.method)} (${structure.config.primary.scope})\n`;

    if (structure.config.secondary) {
      doc += `- **次要方法**：${this.getMethodName(structure.config.secondary.method)} (${structure.config.secondary.scope})\n`;
    }

    if (structure.config.micro) {
      doc += `- **微观方法**：${this.getMethodName(structure.config.micro.method)} (${structure.config.micro.scope})\n`;
    }

    doc += `\n## 结构映射\n\n`;
    doc += `### 主线结构\n`;
    structure.mapping.mainPlot.elements.forEach(element => {
      doc += `- **${element.name}**：第${element.chapters[0]}-${element.chapters[1]}章 - ${element.description}\n`;
    });

    if (structure.mapping.subPlots) {
      doc += `\n### 支线结构\n`;
      structure.mapping.subPlots.forEach((subplot, index) => {
        doc += `#### 支线${index + 1}\n`;
        subplot.elements.forEach(element => {
          doc += `- ${element.name}：${element.description}\n`;
        });
      });
    }

    if (structure.mapping.characterArcs) {
      doc += `\n### 角色弧线\n`;
      structure.mapping.characterArcs.forEach(arc => {
        doc += `#### ${arc.character}\n`;
        arc.arc.forEach(element => {
          doc += `- ${element.name}：第${element.chapters[0]}-${element.chapters[1]}章\n`;
        });
      });
    }

    doc += `\n## 使用指南\n`;
    structure.guidelines.forEach(guideline => {
      doc += `- ${guideline}\n`;
    });

    if (structure.examples.length > 0) {
      doc += `\n## 示例\n`;
      structure.examples.forEach(example => {
        doc += example + '\n';
      });
    }

    return doc;
  }

  /**
   * 获取方法中文名
   */
  private getMethodName(method: string): string {
    const names: Record<string, string> = {
      'three-act': '三幕结构',
      'hero-journey': '英雄之旅',
      'story-circle': '故事圈',
      'seven-point': '七点结构',
      'pixar-formula': '皮克斯公式'
    };
    return names[method] || method;
  }
}