/**
 * 方法智能推荐系统
 * 根据作品特征推荐最适合的写作方法
 */

interface StoryFeatures {
  genre: string;           // 类型
  length: number;          // 预计字数
  audience: string;        // 目标读者
  experience: string;      // 作者经验
  focus: string;          // 创作重点（情节/角色/主题）
  pace: string;           // 节奏偏好（快/中/慢）
  complexity: string;     // 复杂度（简单/中等/复杂）
}

interface MethodScore {
  method: string;
  score: number;
  reasons: string[];
  pros: string[];
  cons: string[];
}

export class MethodAdvisor {
  private methodProfiles = {
    'three-act': {
      genres: ['通用', '现实', '爱情', '历史'],
      lengthRange: { min: 50000, max: 500000 },
      audiences: ['大众', '成人', '青少年'],
      experience: ['初级', '中级', '高级'],
      focus: ['平衡', '情节'],
      pace: ['中', '快'],
      complexity: ['简单', '中等']
    },
    'hero-journey': {
      genres: ['奇幻', '科幻', '冒险', '成长'],
      lengthRange: { min: 100000, max: 1000000 },
      audiences: ['青少年', '成人', '奇幻爱好者'],
      experience: ['中级', '高级'],
      focus: ['角色', '成长'],
      pace: ['中', '慢'],
      complexity: ['复杂']
    },
    'story-circle': {
      genres: ['角色', '心理', '成长', '系列'],
      lengthRange: { min: 30000, max: 200000 },
      audiences: ['成人', '文学爱好者'],
      experience: ['中级', '高级'],
      focus: ['角色', '内心'],
      pace: ['中', '慢'],
      complexity: ['中等']
    },
    'seven-point': {
      genres: ['悬疑', '惊悚', '动作', '商业'],
      lengthRange: { min: 50000, max: 300000 },
      audiences: ['大众', '商业读者'],
      experience: ['初级', '中级'],
      focus: ['情节', '悬念'],
      pace: ['快', '中'],
      complexity: ['中等']
    },
    'pixar-formula': {
      genres: ['儿童', '短篇', '温情', '寓言'],
      lengthRange: { min: 5000, max: 50000 },
      audiences: ['儿童', '家庭', '全年龄'],
      experience: ['初级'],
      focus: ['情感', '简洁'],
      pace: ['快', '中'],
      complexity: ['简单']
    }
  };

  /**
   * 推荐最适合的写作方法
   */
  recommend(features: StoryFeatures): MethodScore[] {
    const scores: MethodScore[] = [];

    for (const [method, profile] of Object.entries(this.methodProfiles)) {
      const score = this.calculateScore(features, profile);
      const analysis = this.analyzeMatch(features, profile, method);

      scores.push({
        method,
        score: score.total,
        reasons: score.reasons,
        pros: analysis.pros,
        cons: analysis.cons
      });
    }

    // 按分数排序
    return scores.sort((a, b) => b.score - a.score);
  }

  /**
   * 计算匹配分数
   */
  private calculateScore(features: StoryFeatures, profile: any): { total: number; reasons: string[] } {
    let score = 0;
    const reasons: string[] = [];

    // 类型匹配（权重：30）
    if (profile.genres.includes(features.genre) || profile.genres.includes('通用')) {
      score += 30;
      reasons.push(`非常适合${features.genre}类型`);
    } else {
      score += 10;
    }

    // 长度匹配（权重：20）
    if (features.length >= profile.lengthRange.min && features.length <= profile.lengthRange.max) {
      score += 20;
      reasons.push('长度范围完美匹配');
    } else if (features.length < profile.lengthRange.min * 0.5 || features.length > profile.lengthRange.max * 2) {
      score -= 10;
      reasons.push('长度不太合适');
    } else {
      score += 10;
    }

    // 受众匹配（权重：15）
    if (profile.audiences.includes(features.audience)) {
      score += 15;
      reasons.push(`适合${features.audience}读者`);
    } else {
      score += 5;
    }

    // 经验匹配（权重：15）
    if (profile.experience.includes(features.experience)) {
      score += 15;
      reasons.push(`匹配${features.experience}作者水平`);
    } else {
      score += 5;
    }

    // 创作重点匹配（权重：10）
    if (profile.focus.includes(features.focus)) {
      score += 10;
      reasons.push(`擅长${features.focus}描写`);
    }

    // 节奏匹配（权重：5）
    if (profile.pace.includes(features.pace)) {
      score += 5;
      reasons.push('节奏风格吻合');
    }

    // 复杂度匹配（权重：5）
    if (profile.complexity.includes(features.complexity)) {
      score += 5;
      reasons.push('复杂度合适');
    }

    return { total: score, reasons };
  }

  /**
   * 分析优缺点
   */
  private analyzeMatch(features: StoryFeatures, profile: any, method: string): { pros: string[]; cons: string[] } {
    const pros: string[] = [];
    const cons: string[] = [];

    // 分析优势
    if (profile.genres.includes(features.genre)) {
      pros.push('类型高度匹配');
    }
    if (profile.experience.includes(features.experience)) {
      pros.push('难度适中');
    }
    if (features.length >= profile.lengthRange.min && features.length <= profile.lengthRange.max) {
      pros.push('长度合适');
    }

    // 分析劣势
    if (!profile.genres.includes(features.genre) && !profile.genres.includes('通用')) {
      cons.push('不是最适合的类型');
    }
    if (!profile.experience.includes(features.experience)) {
      if (features.experience === '初级' && !profile.experience.includes('初级')) {
        cons.push('可能过于复杂');
      } else if (features.experience === '高级' && !profile.experience.includes('高级')) {
        cons.push('可能过于简单');
      }
    }
    if (features.length < profile.lengthRange.min) {
      cons.push('可能太短，结构展不开');
    } else if (features.length > profile.lengthRange.max) {
      cons.push('可能太长，结构会拖沓');
    }

    return { pros, cons };
  }

  /**
   * 获取详细建议
   */
  getDetailedRecommendation(features: StoryFeatures): string {
    const scores = this.recommend(features);
    const top = scores[0];
    const second = scores[1];

    let recommendation = `## 📊 写作方法推荐报告\n\n`;
    recommendation += `### 作品特征分析\n`;
    recommendation += `- 类型：${features.genre}\n`;
    recommendation += `- 长度：${(features.length / 10000).toFixed(1)}万字\n`;
    recommendation += `- 读者：${features.audience}\n`;
    recommendation += `- 经验：${features.experience}\n`;
    recommendation += `- 重点：${features.focus}\n`;
    recommendation += `- 节奏：${features.pace}\n`;
    recommendation += `- 复杂度：${features.complexity}\n\n`;

    recommendation += `### 🏆 首选推荐：${this.getMethodName(top.method)}\n`;
    recommendation += `**匹配度：${top.score}%**\n\n`;
    recommendation += `**推荐理由：**\n`;
    top.reasons.forEach(reason => {
      recommendation += `- ✅ ${reason}\n`;
    });
    recommendation += `\n**优势：**\n`;
    top.pros.forEach(pro => {
      recommendation += `- ${pro}\n`;
    });
    if (top.cons.length > 0) {
      recommendation += `\n**注意事项：**\n`;
      top.cons.forEach(con => {
        recommendation += `- ⚠️ ${con}\n`;
      });
    }

    if (second && second.score >= 70) {
      recommendation += `\n### 🥈 备选推荐：${this.getMethodName(second.method)}\n`;
      recommendation += `**匹配度：${second.score}%**\n\n`;
      recommendation += `**推荐理由：**\n`;
      second.reasons.forEach(reason => {
        recommendation += `- ${reason}\n`;
      });
    }

    recommendation += `\n### 💡 创作建议\n`;
    recommendation += this.getSpecificTips(top.method, features);

    return recommendation;
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

  /**
   * 获取特定建议
   */
  private getSpecificTips(method: string, features: StoryFeatures): string {
    const tips: Record<string, string> = {
      'three-act': `
- 第一幕控制在25%左右，快速建立冲突
- 第二幕注意避免中间拖沓，可以设置多个小高潮
- 第三幕要紧凑有力，不要草草收尾`,
      'hero-journey': `
- 不必严格遵循所有12个阶段，可以根据需要调整
- 重点关注角色的内在转变，而不仅是外在冒险
- 导师角色可以多样化，不一定是传统的智者形象`,
      'story-circle': `
- 强调角色的需求必须足够强烈
- 每个步骤都要推进角色的内在变化
- 可以在大循环中嵌套小循环增加深度`,
      'seven-point': `
- 确保每个节点都真正推进故事
- 中点必须是真正的转折，改变游戏规则
- 收紧点不要省略，它们维持张力很重要`,
      'pixar-formula': `
- 保持简洁，不要过度描写
- 强调因果关系的清晰连接
- 结局要满意但可以留有思考空间`
    };

    return tips[method] || '';
  }
}

/**
 * 快速推荐函数
 */
export function quickRecommend(
  genre: string,
  length: number,
  experience: string = '初级'
): string {
  // 快速规则
  if (length < 30000) return 'pixar-formula';
  if (genre === '奇幻' || genre === '冒险') return 'hero-journey';
  if (genre === '悬疑' || genre === '惊悚') return 'seven-point';
  if (genre === '心理' || genre === '成长') return 'story-circle';
  return 'three-act'; // 默认
}

/**
 * 混合方法推荐
 */
export function recommendHybrid(features: StoryFeatures): string {
  const recommendations: string[] = [];

  // 主线结构
  if (features.length > 100000 && (features.genre === '奇幻' || features.genre === '冒险')) {
    recommendations.push('主线使用英雄之旅');
  } else if (features.genre === '悬疑') {
    recommendations.push('主线使用七点结构');
  } else {
    recommendations.push('主线使用三幕结构');
  }

  // 支线结构
  if (features.focus === '角色') {
    recommendations.push('角色支线使用故事圈');
  }

  // 章节结构
  if (features.pace === '快') {
    recommendations.push('单章可用皮克斯公式组织');
  }

  return recommendations.join('\\n');
}