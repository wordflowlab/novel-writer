/**
 * 模板引擎
 * 负责将用户参数填充到 Prompt 模板中
 * 支持变量替换、条件渲染和循环等功能
 */

export class TemplateEngine {
  constructor() {
    // 支持的模板语法
    this.syntax = {
      variable: /\{\{([^}]+)\}\}/g,           // {{variable}}
      condition: /\{\{#if\s+([^}]+)\}\}([\s\S]*?)\{\{\/if\}\}/g,  // {{#if condition}}...{{/if}}
      unless: /\{\{#unless\s+([^}]+)\}\}([\s\S]*?)\{\{\/unless\}\}/g,  // {{#unless condition}}...{{/unless}}
      each: /\{\{#each\s+([^}]+)\}\}([\s\S]*?)\{\{\/each\}\}/g,   // {{#each items}}...{{/each}}
      with: /\{\{#with\s+([^}]+)\}\}([\s\S]*?)\{\{\/with\}\}/g,   // {{#with object}}...{{/with}}
    };
  }

  /**
   * 填充模板
   * @param {string} template - Prompt 模板
   * @param {object} parameters - 用户参数
   * @returns {string} 填充后的 Prompt
   */
  fill(template, parameters) {
    if (!template || typeof template !== 'string') {
      throw new Error('模板无效');
    }

    if (!parameters || typeof parameters !== 'object') {
      throw new Error('参数无效');
    }

    let result = template;

    try {
      // 1. 处理条件块
      result = this.processConditions(result, parameters);

      // 2. 处理循环块
      result = this.processLoops(result, parameters);

      // 3. 处理 with 块
      result = this.processWithBlocks(result, parameters);

      // 4. 处理变量替换（放在最后）
      result = this.processVariables(result, parameters);

      // 5. 清理未使用的占位符
      result = this.cleanupTemplate(result);

      return result;
    } catch (error) {
      throw new Error(`模板填充失败: ${error.message}`);
    }
  }

  /**
   * 处理变量替换
   */
  processVariables(template, parameters) {
    return template.replace(this.syntax.variable, (match, path) => {
      const trimmedPath = path.trim();

      // 支持嵌套属性访问 (如 user.name)
      const value = this.getValueByPath(parameters, trimmedPath);

      // 处理不同类型的值
      if (value === undefined || value === null) {
        return ''; // 未定义的变量替换为空
      }

      if (typeof value === 'object') {
        // 对象转为 JSON 字符串
        return JSON.stringify(value, null, 2);
      }

      // 其他类型转为字符串
      return String(value);
    });
  }

  /**
   * 处理条件渲染
   */
  processConditions(template, parameters) {
    // 处理 {{#if condition}}
    template = template.replace(this.syntax.condition, (match, condition, content) => {
      const trimmedCondition = condition.trim();
      const conditionValue = this.evaluateCondition(trimmedCondition, parameters);

      return conditionValue ? content : '';
    });

    // 处理 {{#unless condition}}
    template = template.replace(this.syntax.unless, (match, condition, content) => {
      const trimmedCondition = condition.trim();
      const conditionValue = this.evaluateCondition(trimmedCondition, parameters);

      return !conditionValue ? content : '';
    });

    return template;
  }

  /**
   * 处理循环
   */
  processLoops(template, parameters) {
    return template.replace(this.syntax.each, (match, arrayPath, content) => {
      const trimmedPath = arrayPath.trim();
      const array = this.getValueByPath(parameters, trimmedPath);

      if (!Array.isArray(array)) {
        return ''; // 非数组返回空
      }

      // 为每个元素渲染内容
      return array.map((item, index) => {
        // 创建循环上下文
        const loopContext = {
          ...parameters,
          '@item': item,
          '@index': index,
          '@first': index === 0,
          '@last': index === array.length - 1
        };

        // 在循环内容中替换变量
        return content.replace(this.syntax.variable, (m, path) => {
          const p = path.trim();

          // 特殊变量
          if (p.startsWith('@')) {
            return loopContext[p] !== undefined ? String(loopContext[p]) : '';
          }

          // 支持 this 关键字
          if (p === 'this' || p === '.') {
            return String(item);
          }

          // 常规属性访问
          return this.getValueByPath(loopContext, p);
        });
      }).join('');
    });
  }

  /**
   * 处理 with 块
   */
  processWithBlocks(template, parameters) {
    return template.replace(this.syntax.with, (match, objectPath, content) => {
      const trimmedPath = objectPath.trim();
      const object = this.getValueByPath(parameters, trimmedPath);

      if (!object || typeof object !== 'object') {
        return ''; // 非对象返回空
      }

      // 创建新的上下文
      const withContext = {
        ...parameters,
        ...object
      };

      // 在 with 块内填充变量
      return this.processVariables(content, withContext);
    });
  }

  /**
   * 评估条件表达式
   */
  evaluateCondition(condition, parameters) {
    // 支持的操作符
    const operators = {
      '==': (a, b) => a == b,
      '===': (a, b) => a === b,
      '!=': (a, b) => a != b,
      '!==': (a, b) => a !== b,
      '>': (a, b) => a > b,
      '>=': (a, b) => a >= b,
      '<': (a, b) => a < b,
      '<=': (a, b) => a <= b,
      '&&': (a, b) => a && b,
      '||': (a, b) => a || b
    };

    // 简单条件（仅变量名）
    if (!condition.match(/[=!<>&|]/)) {
      const value = this.getValueByPath(parameters, condition);
      return this.isTruthy(value);
    }

    // 复杂条件（包含操作符）
    // 这里简化处理，实际可能需要更复杂的表达式解析
    for (const [op, fn] of Object.entries(operators)) {
      if (condition.includes(op)) {
        const parts = condition.split(op).map(p => p.trim());
        if (parts.length === 2) {
          const left = this.getValueByPath(parameters, parts[0]) || parts[0];
          const right = this.getValueByPath(parameters, parts[1]) || parts[1];
          return fn(left, right);
        }
      }
    }

    // 默认返回 false
    return false;
  }

  /**
   * 判断值是否为真
   */
  isTruthy(value) {
    if (value === undefined || value === null) {
      return false;
    }

    if (typeof value === 'boolean') {
      return value;
    }

    if (typeof value === 'number') {
      return value !== 0;
    }

    if (typeof value === 'string') {
      return value.length > 0;
    }

    if (Array.isArray(value)) {
      return value.length > 0;
    }

    if (typeof value === 'object') {
      return Object.keys(value).length > 0;
    }

    return !!value;
  }

  /**
   * 通过路径获取值
   * 支持嵌套属性访问，如 'user.profile.name'
   */
  getValueByPath(object, path) {
    if (!object || !path) {
      return undefined;
    }

    // 处理字面量
    if (path.startsWith('"') && path.endsWith('"')) {
      return path.slice(1, -1);
    }

    if (path.startsWith("'") && path.endsWith("'")) {
      return path.slice(1, -1);
    }

    // 数字字面量
    if (/^\d+$/.test(path)) {
      return parseInt(path, 10);
    }

    // 布尔字面量
    if (path === 'true') return true;
    if (path === 'false') return false;

    // 属性路径
    const parts = path.split('.');
    let current = object;

    for (const part of parts) {
      if (current === undefined || current === null) {
        return undefined;
      }

      // 支持数组索引
      const arrayMatch = part.match(/^(\w+)\[(\d+)\]$/);
      if (arrayMatch) {
        current = current[arrayMatch[1]];
        if (Array.isArray(current)) {
          current = current[parseInt(arrayMatch[2], 10)];
        } else {
          return undefined;
        }
      } else {
        current = current[part];
      }
    }

    return current;
  }

  /**
   * 清理未使用的模板标记
   */
  cleanupTemplate(template) {
    // 移除未匹配的变量占位符
    template = template.replace(/\{\{[^}]*\}\}/g, '');

    // 移除多余的空行
    template = template.replace(/\n\s*\n\s*\n/g, '\n\n');

    // 去除尾部空白
    template = template.trimEnd();

    return template;
  }

  /**
   * 验证模板语法
   * 在填充前检查模板是否有语法错误
   */
  validateTemplate(template) {
    const errors = [];

    // 检查未闭合的标签
    const openTags = template.match(/\{\{#(if|unless|each|with)[^}]*\}\}/g) || [];
    const closeTags = template.match(/\{\{\/(if|unless|each|with)\}\}/g) || [];

    if (openTags.length !== closeTags.length) {
      errors.push('模板包含未闭合的标签');
    }

    // 检查变量格式
    const variables = template.match(this.syntax.variable) || [];
    for (const variable of variables) {
      if (variable.includes('{{{{')) {
        errors.push(`无效的变量格式: ${variable}`);
      }
    }

    return errors.length === 0 ? null : errors;
  }

  /**
   * 预处理参数
   * 添加一些有用的内置变量
   */
  preprocessParameters(parameters) {
    return {
      ...parameters,
      '@date': new Date().toISOString().split('T')[0],
      '@time': new Date().toTimeString().split(' ')[0],
      '@timestamp': Date.now(),
      '@random': Math.random().toString(36).substr(2, 9)
    };
  }
}

// 导出单例
export const templateEngine = new TemplateEngine();