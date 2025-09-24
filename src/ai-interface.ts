/**
 * AI 接口层
 * 为 AI 助手提供简化的功能调用接口
 * 支持自然语言参数和引导式交互
 */

import { MethodAdvisor } from './method-advisor.js';
import { MethodConverter } from './method-converter.js';
import { HybridMethodManager } from './hybrid-method.js';
import fs from 'fs-extra';
import path from 'path';

/**
 * AI 友好的参数接口
 */
interface StoryContext {
  genre?: string;
  description?: string;
  estimatedLength?: string;
  targetAudience?: string;
  tone?: string;
  themes?: string[];
}

/**
 * 方法选择结果
 */
interface MethodSelection {
  method: string;
  reason: string;
  template: string;
  tips: string[];
}

/**
 * AI 接口主类
 */
export class AIInterface {
  private advisor: MethodAdvisor;
  private converter: MethodConverter;
  private hybridManager: HybridMethodManager;

  constructor() {
    this.advisor = new MethodAdvisor();
    this.converter = new MethodConverter();
    this.hybridManager = new HybridMethodManager();
  }

  /**
   * 智能引导选择写作方法
   * AI 通过对话收集信息后调用
   */
  async guideMethodSelection(context: StoryContext): Promise<MethodSelection> {
    // 解析自然语言参数
    const features = this.parseContext(context);

    // 获取推荐
    const scores = this.advisor.recommend(features);
    const top = scores[0];

    // 加载对应模板
    const templatePath = await this.getMethodTemplate(top.method);

    return {
      method: top.method,
      reason: top.reasons.join('；'),
      template: templatePath,
      tips: this.getMethodTips(top.method)
    };
  }

  /**
   * 引导式问答收集信息
   * 返回需要询问用户的问题
   */
  getGuidingQuestions(): string[] {
    return [
      "这是一个什么类型的故事？（奇幻/科幻/爱情/悬疑/现实/其他）",
      "预计写多少字？（短篇3万字以内/中篇10万字左右/长篇20万字以上）",
      "目标读者是谁？（儿童/青少年/成人/大众）",
      "你希望故事的节奏如何？（紧凑刺激/平稳推进/缓慢深入）",
      "你更注重什么？（精彩的情节/丰富的人物/深刻的主题）"
    ];
  }

  /**
   * 解析上下文为特征参数
   */
  private parseContext(context: StoryContext): any {
    // 智能解析长度
    let length = 100000; // 默认10万字
    if (context.estimatedLength) {
      if (context.estimatedLength.includes('短')) length = 30000;
      else if (context.estimatedLength.includes('长')) length = 200000;
      else if (context.estimatedLength.includes('超长')) length = 500000;

      // 提取数字
      const match = context.estimatedLength.match(/(\d+)/);
      if (match) {
        const num = parseInt(match[1]);
        if (context.estimatedLength.includes('万')) {
          length = num * 10000;
        } else if (context.estimatedLength.includes('千')) {
          length = num * 1000;
        } else {
          length = num;
        }
      }
    }

    // 智能解析节奏
    let pace = '中';
    if (context.tone?.includes('紧') || context.tone?.includes('刺激')) pace = '快';
    else if (context.tone?.includes('缓') || context.tone?.includes('深')) pace = '慢';

    // 智能解析复杂度
    let complexity = '中等';
    if (length > 200000 || context.description?.includes('复杂')) complexity = '复杂';
    else if (length < 50000 || context.description?.includes('简单')) complexity = '简单';

    // 智能解析经验（根据描述推测）
    let experience = '初级';
    if (context.description?.includes('系列') || complexity === '复杂') experience = '中级';

    return {
      genre: context.genre || '通用',
      length,
      audience: context.targetAudience || '大众',
      experience,
      focus: this.parseFocus(context),
      pace,
      complexity
    };
  }

  /**
   * 解析创作重点
   */
  private parseFocus(context: StoryContext): string {
    if (context.description?.includes('人物') || context.description?.includes('角色')) {
      return '角色';
    }
    if (context.description?.includes('情节') || context.description?.includes('剧情')) {
      return '情节';
    }
    if (context.themes && context.themes.length > 0) {
      return '主题';
    }
    return '平衡';
  }

  /**
   * 获取方法对应的模板路径
   */
  private async getMethodTemplate(method: string): Promise<string> {
    const methodMap: Record<string, string> = {
      'three-act': 'three-act',
      'hero-journey': 'hero-journey',
      'story-circle': 'story-circle',
      'seven-point': 'seven-point',
      'pixar-formula': 'pixar-formula'
    };

    const methodDir = methodMap[method] || 'three-act';
    return `spec/presets/${methodDir}/story.md`;
  }

  /**
   * 获取方法使用提示
   */
  private getMethodTips(method: string): string[] {
    const tips: Record<string, string[]> = {
      'three-act': [
        '第一幕要快速建立冲突',
        '第二幕可设置多个小高潮避免拖沓',
        '第三幕要紧凑有力'
      ],
      'hero-journey': [
        '不必严格遵循所有12个阶段',
        '重点关注角色的内在转变',
        '导师角色可以多样化'
      ],
      'story-circle': [
        '角色的需求必须足够强烈',
        '每个步骤都要推进内在变化',
        '可以嵌套小循环增加深度'
      ],
      'seven-point': [
        '确保每个节点都推进故事',
        '中点必须是真正的转折',
        '收紧点很重要，不要省略'
      ],
      'pixar-formula': [
        '保持简洁，不要过度描写',
        '强调因果关系的清晰连接',
        '结局要满意但可留有思考空间'
      ]
    };

    return tips[method] || ['遵循方法的基本结构', '保持故事的连贯性'];
  }

  /**
   * 智能转换建议
   * 分析当前项目并建议是否需要转换
   */
  async suggestConversion(currentMethod: string, storyProgress: any): Promise<any> {
    // 分析进度
    const hasContent = storyProgress.chapters && storyProgress.chapters.length > 0;

    if (!hasContent) {
      return {
        needConversion: false,
        reason: '项目刚开始，可以直接切换方法'
      };
    }

    // 分析内容特征
    const contentFeatures = this.analyzeContent(storyProgress);

    // 获取推荐方法
    const recommended = this.advisor.recommend(contentFeatures)[0];

    if (recommended.method === currentMethod) {
      return {
        needConversion: false,
        reason: '当前方法已经最适合'
      };
    }

    // 生成转换方案
    const conversionMap = this.converter.convert(storyProgress, recommended.method);

    return {
      needConversion: true,
      targetMethod: recommended.method,
      reason: recommended.reasons[0],
      conversionMap,
      impact: this.assessConversionImpact(storyProgress, conversionMap)
    };
  }

  /**
   * 分析内容特征
   */
  private analyzeContent(progress: any): any {
    // 基于实际内容分析
    return {
      genre: progress.genre || '通用',
      length: progress.plannedLength || 100000,
      audience: progress.audience || '大众',
      experience: '中级',
      focus: progress.focus || '平衡',
      pace: progress.pace || '中',
      complexity: progress.complexity || '中等'
    };
  }

  /**
   * 评估转换影响
   */
  private assessConversionImpact(progress: any, conversionMap: any): string {
    const chaptersWritten = progress.chapters?.filter((c: any) => c.written).length || 0;

    if (chaptersWritten === 0) {
      return '无影响，还未开始写作';
    } else if (chaptersWritten < 5) {
      return '影响较小，只需调整少量章节';
    } else if (chaptersWritten < 20) {
      return '影响中等，需要重新组织部分内容';
    } else {
      return '影响较大，建议保持当前方法完成作品';
    }
  }

  /**
   * 智能混合方案生成
   * 根据故事特点自动设计混合方案
   */
  async designHybridScheme(context: StoryContext): Promise<any> {
    const features = this.parseContext(context);

    // 判断是否需要混合
    if (features.complexity === '简单' || features.length < 50000) {
      return {
        needHybrid: false,
        reason: '简单故事使用单一方法即可',
        recommendation: this.advisor.recommend(features)[0].method
      };
    }

    // 推荐混合方案
    const hybrid = this.hybridManager.recommendHybrid(
      features.genre,
      features.length,
      features.complexity
    );

    if (!hybrid) {
      return {
        needHybrid: false,
        reason: '此类型故事适合单一方法',
        recommendation: this.advisor.recommend(features)[0].method
      };
    }

    // 生成详细方案
    const structure = this.hybridManager.createHybridStructure(hybrid, {
      ...features,
      subPlots: context.description?.includes('支线') ? ['支线1'] : [],
      characters: context.description?.includes('群像') ? ['角色1', '角色2'] : []
    });

    return {
      needHybrid: true,
      reason: this.getHybridReason(features),
      scheme: hybrid,
      structure,
      guidelines: structure.guidelines
    };
  }

  /**
   * 获取使用混合方法的理由
   */
  private getHybridReason(features: any): string {
    if (features.genre === '奇幻' && features.length > 200000) {
      return '长篇奇幻适合用英雄之旅构建主线，故事圈追踪角色成长';
    }
    if (features.genre === '悬疑' && features.complexity === '复杂') {
      return '复杂悬疑适合七点结构控制节奏，章节用三幕组织';
    }
    if (features.focus === '角色' && features.length > 150000) {
      return '角色驱动的长篇适合混合方法，主线和角色线分别处理';
    }
    return '故事较复杂，混合方法能更好地组织结构';
  }

  /**
   * 获取当前项目配置
   */
  async getCurrentConfig(): Promise<any> {
    const configPath = path.join(process.cwd(), '.specify', 'config.json');
    if (await fs.pathExists(configPath)) {
      return await fs.readJson(configPath);
    }
    return null;
  }

  /**
   * 更新项目方法配置
   */
  async updateProjectMethod(method: string | any): Promise<void> {
    const configPath = path.join(process.cwd(), '.specify', 'config.json');
    if (await fs.pathExists(configPath)) {
      const config = await fs.readJson(configPath);

      if (typeof method === 'string') {
        config.method = method;
      } else {
        // 混合方法配置
        config.method = 'hybrid';
        config.hybridScheme = method;
      }

      config.updatedAt = new Date().toISOString();
      await fs.writeJson(configPath, config, { spaces: 2 });
    }
  }

  /**
   * 获取方法的中文名称
   */
  getMethodDisplayName(method: string): string {
    const names: Record<string, string> = {
      'three-act': '三幕结构',
      'hero-journey': '英雄之旅',
      'story-circle': '故事圈',
      'seven-point': '七点结构',
      'pixar-formula': '皮克斯公式',
      'hybrid': '混合方法'
    };
    return names[method] || method;
  }
}

/**
 * 导出单例实例供 AI 直接使用
 */
export const aiInterface = new AIInterface();