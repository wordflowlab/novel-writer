/**
 * 方法自动转换工具
 * 在不同写作方法之间转换现有内容
 */

interface StoryContent {
  chapters: Chapter[];
  characters: Character[];
  worldSetting: WorldSetting;
  themes: string[];
  currentMethod: string;
}

interface Chapter {
  number: number;
  title: string;
  content: string;
  structuralRole?: string; // 在当前结构中的角色
  wordCount: number;
}

interface Character {
  name: string;
  role: string;
  arc: string;
}

interface WorldSetting {
  time: string;
  place: string;
  rules: string[];
}

interface ConversionMap {
  chapters: ChapterMapping[];
  structuralNotes: string[];
  recommendations: string[];
  warnings: string[];
}

interface ChapterMapping {
  original: number[];
  target: string;
  description: string;
}

export class MethodConverter {
  /**
   * 转换方法
   */
  convert(content: StoryContent, targetMethod: string): ConversionMap {
    const sourceMethod = content.currentMethod;

    // 根据源方法和目标方法选择转换策略
    const converterKey = `${sourceMethod}_to_${targetMethod}`;

    switch (converterKey) {
      case 'three-act_to_hero-journey':
        return this.threeActToHeroJourney(content);
      case 'three-act_to_seven-point':
        return this.threeActToSevenPoint(content);
      case 'hero-journey_to_three-act':
        return this.heroJourneyToThreeAct(content);
      case 'hero-journey_to_story-circle':
        return this.heroJourneyToStoryCircle(content);
      case 'story-circle_to_three-act':
        return this.storyCircleToThreeAct(content);
      case 'seven-point_to_three-act':
        return this.sevenPointToThreeAct(content);
      default:
        return this.genericConversion(content, sourceMethod, targetMethod);
    }
  }

  /**
   * 三幕结构转英雄之旅
   */
  private threeActToHeroJourney(content: StoryContent): ConversionMap {
    const totalChapters = content.chapters.length;
    const act1End = Math.floor(totalChapters * 0.25);
    const act2End = Math.floor(totalChapters * 0.75);

    const mapping: ChapterMapping[] = [
      {
        original: [1, Math.floor(act1End * 0.4)],
        target: '1. 平凡世界',
        description: '将第一幕前40%映射为平凡世界'
      },
      {
        original: [Math.floor(act1End * 0.4) + 1, Math.floor(act1End * 0.6)],
        target: '2. 冒险召唤',
        description: '触发事件映射为召唤'
      },
      {
        original: [Math.floor(act1End * 0.6) + 1, Math.floor(act1End * 0.8)],
        target: '3. 拒绝召唤',
        description: '主角的犹豫期'
      },
      {
        original: [Math.floor(act1End * 0.8) + 1, act1End],
        target: '4. 遇见导师',
        description: '获得帮助或指引'
      },
      {
        original: [act1End + 1, act1End + Math.floor((act2End - act1End) * 0.1)],
        target: '5. 跨越门槛',
        description: '进入第二幕映射为跨越门槛'
      },
      {
        original: [act1End + Math.floor((act2End - act1End) * 0.1) + 1, act1End + Math.floor((act2End - act1End) * 0.4)],
        target: '6. 试炼、盟友与敌人',
        description: '第二幕前半部分的冲突'
      },
      {
        original: [act1End + Math.floor((act2End - act1End) * 0.4) + 1, act1End + Math.floor((act2End - act1End) * 0.5)],
        target: '7. 接近最深的洞穴',
        description: '准备面对最大挑战'
      },
      {
        original: [act1End + Math.floor((act2End - act1End) * 0.5) + 1, act1End + Math.floor((act2End - act1End) * 0.6)],
        target: '8. 磨难',
        description: '中点危机映射为磨难'
      },
      {
        original: [act1End + Math.floor((act2End - act1End) * 0.6) + 1, act1End + Math.floor((act2End - act1End) * 0.8)],
        target: '9. 获得奖赏',
        description: '克服磨难后的收获'
      },
      {
        original: [act1End + Math.floor((act2End - act1End) * 0.8) + 1, act2End],
        target: '10. 归途',
        description: '第二幕后期的返回过程'
      },
      {
        original: [act2End + 1, act2End + Math.floor((totalChapters - act2End) * 0.6)],
        target: '11. 复活',
        description: '第三幕高潮映射为复活'
      },
      {
        original: [act2End + Math.floor((totalChapters - act2End) * 0.6) + 1, totalChapters],
        target: '12. 带着灵药归来',
        description: '结局和新平衡'
      }
    ];

    const notes = [
      '英雄之旅强调角色的内在成长，需要加强心理描写',
      '可能需要明确或添加导师角色',
      '磨难阶段需要体现"死亡与重生"的主题'
    ];

    const recommendations = [
      '检查是否有明确的导师角色，如无需要添加',
      '强化主角的内在转变弧线',
      '确保每个阶段都推进主题'
    ];

    const warnings = [
      '三幕结构的线性发展可能不完全符合英雄之旅的循环性',
      '可能需要补充一些过渡章节'
    ];

    return { chapters: mapping, structuralNotes: notes, recommendations, warnings };
  }

  /**
   * 三幕结构转七点结构
   */
  private threeActToSevenPoint(content: StoryContent): ConversionMap {
    const totalChapters = content.chapters.length;

    const mapping: ChapterMapping[] = [
      {
        original: [1, 3],
        target: '1. 钩子 (Hook)',
        description: '开头章节作为钩子'
      },
      {
        original: [Math.floor(totalChapters * 0.25) - 1, Math.floor(totalChapters * 0.25) + 1],
        target: '2. 第一情节点 (PP1)',
        description: '第一幕结尾作为PP1'
      },
      {
        original: [Math.floor(totalChapters * 0.375) - 1, Math.floor(totalChapters * 0.375) + 1],
        target: '3. 第一收紧点 (Pinch1)',
        description: '第二幕前段压力点'
      },
      {
        original: [Math.floor(totalChapters * 0.5) - 1, Math.floor(totalChapters * 0.5) + 1],
        target: '4. 中点 (Midpoint)',
        description: '故事中点'
      },
      {
        original: [Math.floor(totalChapters * 0.625) - 1, Math.floor(totalChapters * 0.625) + 1],
        target: '5. 第二收紧点 (Pinch2)',
        description: '第二幕后段压力点'
      },
      {
        original: [Math.floor(totalChapters * 0.75) - 1, Math.floor(totalChapters * 0.75) + 1],
        target: '6. 第二情节点 (PP2)',
        description: '第二幕结尾作为PP2'
      },
      {
        original: [Math.floor(totalChapters * 0.95), totalChapters],
        target: '7. 结局 (Resolution)',
        description: '第三幕结尾作为结局'
      }
    ];

    const notes = [
      '七点结构需要明确的节奏控制点',
      '收紧点(Pinch Points)需要展示对手的力量',
      '中点必须是真正的转折'
    ];

    const recommendations = [
      '确保每个节点都有明确的功能',
      '检查中点是否真正改变了故事走向',
      '增强收紧点的压力感'
    ];

    const warnings = [
      '可能需要调整某些章节的位置以符合七点结构',
      '节奏可能需要重新调整'
    ];

    return { chapters: mapping, structuralNotes: notes, recommendations, warnings };
  }

  /**
   * 英雄之旅转三幕结构
   */
  private heroJourneyToThreeAct(content: StoryContent): ConversionMap {
    const mapping: ChapterMapping[] = [
      {
        original: [1, 5], // 阶段1-5
        target: '第一幕',
        description: '平凡世界到跨越门槛合并为第一幕'
      },
      {
        original: [6, 10], // 阶段6-10
        target: '第二幕',
        description: '试炼到归途合并为第二幕'
      },
      {
        original: [11, 12], // 阶段11-12
        target: '第三幕',
        description: '复活和归来合并为第三幕'
      }
    ];

    const notes = [
      '简化12阶段为3幕',
      '可能失去一些细节深度',
      '需要重新组织过渡'
    ];

    const recommendations = [
      '保留关键的成长节点',
      '确保三幕比例合适(25%-50%-25%)',
      '合并相似的阶段'
    ];

    const warnings = [
      '可能失去英雄之旅的仪式感',
      '角色成长弧线可能被简化'
    ];

    return { chapters: mapping, structuralNotes: notes, recommendations, warnings };
  }

  /**
   * 英雄之旅转故事圈
   */
  private heroJourneyToStoryCircle(content: StoryContent): ConversionMap {
    const mapping: ChapterMapping[] = [
      {
        original: [1], // 平凡世界
        target: '1. 你(舒适区)',
        description: '平凡世界 = 舒适区'
      },
      {
        original: [2, 3], // 召唤+拒绝
        target: '2. 需要',
        description: '召唤产生需求'
      },
      {
        original: [4, 5], // 导师+门槛
        target: '3. 进入',
        description: '跨越门槛进入新世界'
      },
      {
        original: [6, 7], // 试炼+洞穴
        target: '4. 搜索',
        description: '试炼过程就是搜索'
      },
      {
        original: [8, 9], // 磨难+奖赏
        target: '5. 找到',
        description: '通过磨难获得所需'
      },
      {
        original: [10], // 归途
        target: '6. 付出代价',
        description: '归途中的代价'
      },
      {
        original: [11], // 复活
        target: '7. 回归',
        description: '复活后的回归'
      },
      {
        original: [12], // 带着灵药归来
        target: '8. 改变',
        description: '彻底的改变'
      }
    ];

    const notes = [
      '故事圈更强调循环性',
      '简化了英雄之旅的复杂性',
      '更适合短篇或系列故事'
    ];

    const recommendations = [
      '强调角色的内在需求',
      '明确每一步的因果关系',
      '考虑循环的可能性'
    ];

    const warnings = [
      '可能需要简化某些复杂情节',
      '史诗感可能减弱'
    ];

    return { chapters: mapping, structuralNotes: notes, recommendations, warnings };
  }

  /**
   * 故事圈转三幕结构
   */
  private storyCircleToThreeAct(content: StoryContent): ConversionMap {
    const mapping: ChapterMapping[] = [
      {
        original: [1, 2], // 你+需要
        target: '第一幕',
        description: '建立和触发'
      },
      {
        original: [3, 4, 5, 6], // 进入+搜索+找到+代价
        target: '第二幕',
        description: '冒险和冲突'
      },
      {
        original: [7, 8], // 回归+改变
        target: '第三幕',
        description: '解决和新平衡'
      }
    ];

    const notes = [
      '将8步简化为3幕',
      '保持核心冲突',
      '调整节奏分配'
    ];

    const recommendations = [
      '确保第二幕不拖沓',
      '保留关键转变时刻',
      '明确三幕的功能'
    ];

    const warnings = [
      '可能失去循环结构的特色',
      '需要重新设计节奏'
    ];

    return { chapters: mapping, structuralNotes: notes, recommendations, warnings };
  }

  /**
   * 七点结构转三幕结构
   */
  private sevenPointToThreeAct(content: StoryContent): ConversionMap {
    const mapping: ChapterMapping[] = [
      {
        original: [1, 2], // Hook + PP1
        target: '第一幕',
        description: '钩子到第一情节点'
      },
      {
        original: [3, 4, 5, 6], // Pinch1 + Mid + Pinch2 + PP2
        target: '第二幕',
        description: '所有中间节点'
      },
      {
        original: [7], // Resolution
        target: '第三幕',
        description: '结局部分'
      }
    ];

    const notes = [
      '保留关键转折点',
      '简化节点为幕',
      '调整过渡'
    ];

    const recommendations = [
      '确保转折点依然明确',
      '不要失去节奏感',
      '保持张力曲线'
    ];

    const warnings = [
      '可能失去精确的节奏控制',
      '需要补充过渡内容'
    ];

    return { chapters: mapping, structuralNotes: notes, recommendations, warnings };
  }

  /**
   * 通用转换（当没有特定转换规则时）
   */
  private genericConversion(content: StoryContent, source: string, target: string): ConversionMap {
    const totalChapters = content.chapters.length;

    // 基于百分比的通用映射
    const mapping: ChapterMapping[] = [
      {
        original: [1, Math.floor(totalChapters * 0.25)],
        target: '开端/建立',
        description: '故事的建立阶段'
      },
      {
        original: [Math.floor(totalChapters * 0.25) + 1, Math.floor(totalChapters * 0.75)],
        target: '发展/冲突',
        description: '主要冲突和发展'
      },
      {
        original: [Math.floor(totalChapters * 0.75) + 1, totalChapters],
        target: '高潮/结局',
        description: '高潮和解决'
      }
    ];

    const notes = [
      `从${this.getMethodName(source)}转换到${this.getMethodName(target)}`,
      '这是基于通用规则的转换',
      '可能需要手动调整'
    ];

    const recommendations = [
      '仔细检查转换后的结构',
      '根据目标方法的特点调整',
      '考虑是否需要添加或删除内容'
    ];

    const warnings = [
      '自动转换可能不够精确',
      '建议人工审核和调整',
      '某些特色可能在转换中丢失'
    ];

    return { chapters: mapping, structuralNotes: notes, recommendations, warnings };
  }

  /**
   * 生成转换报告
   */
  generateConversionReport(content: StoryContent, targetMethod: string): string {
    const conversionMap = this.convert(content, targetMethod);

    let report = `# 📝 方法转换报告\n\n`;
    report += `## 转换概要\n`;
    report += `- **源方法**：${this.getMethodName(content.currentMethod)}\n`;
    report += `- **目标方法**：${this.getMethodName(targetMethod)}\n`;
    report += `- **总章节数**：${content.chapters.length}章\n`;
    report += `- **总字数**：${content.chapters.reduce((sum, ch) => sum + ch.wordCount, 0)}字\n\n`;

    report += `## 📊 章节映射\n\n`;
    report += `| 原章节 | 目标结构 | 说明 |\n`;
    report += `|--------|----------|------|\n`;
    conversionMap.chapters.forEach(mapping => {
      const range = mapping.original.length === 2
        ? `${mapping.original[0]}-${mapping.original[1]}`
        : `${mapping.original[0]}`;
      report += `| 第${range}章 | ${mapping.target} | ${mapping.description} |\n`;
    });

    report += `\n## 📌 结构说明\n`;
    conversionMap.structuralNotes.forEach(note => {
      report += `- ${note}\n`;
    });

    report += `\n## ✅ 建议事项\n`;
    conversionMap.recommendations.forEach(rec => {
      report += `- ${rec}\n`;
    });

    if (conversionMap.warnings.length > 0) {
      report += `\n## ⚠️ 注意事项\n`;
      conversionMap.warnings.forEach(warning => {
        report += `- ${warning}\n`;
      });
    }

    report += `\n## 🔧 后续步骤\n`;
    report += `1. 审查章节映射是否合理\n`;
    report += `2. 根据新结构调整章节内容\n`;
    report += `3. 补充或删除必要的过渡内容\n`;
    report += `4. 确保新结构的完整性\n`;
    report += `5. 测试阅读体验\n`;

    return report;
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