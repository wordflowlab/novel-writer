---
description: 智能写作方法助手 - 引导选择最适合的写作方法
sh: .specify/scripts/bash/method.sh
scripts:
  init: .specify/scripts/bash/method.sh
---

# 智能写作方法助手

这个命令帮助你通过引导式对话选择最适合的写作方法。

## 使用方式

在 AI 助手中输入 `/method`，然后 AI 会：
1. 通过友好的对话了解你的故事设想
2. 智能分析并推荐最适合的写作方法
3. 帮你应用到项目中

## AI 执行指南

当用户输入 `/method` 时：

### 1. 引导式收集信息

通过自然对话了解用户需求，可以问：
- "你想写一个什么样的故事？可以简单描述一下吗？"
- "大概会写多长？几万字的短篇还是几十万字的长篇？"
- "你的目标读者是谁？"
- "你希望故事节奏是紧凑刺激还是缓慢深入？"
- "你最看重什么？精彩的情节、丰富的人物还是深刻的主题？"

### 2. 调用 AI 接口分析

```javascript
import { aiInterface } from '../src/ai-interface';

// 根据对话内容构建上下文
const context = {
  genre: '从对话中提取的类型',
  description: '用户的故事描述',
  estimatedLength: '用户提到的长度',
  targetAudience: '目标读者',
  tone: '故事基调',
  themes: ['主题1', '主题2']
};

// 获取推荐
const selection = await aiInterface.guideMethodSelection(context);
```

### 3. 展示推荐结果

用友好的方式解释：
- 推荐的方法及原因
- 方法的特点和优势
- 具体的使用建议

### 4. 询问是否需要高级功能

"需要我帮你考虑混合方法吗？比如主线用一种方法，支线用另一种？"

如果需要：
```javascript
const hybrid = await aiInterface.designHybridScheme(context);
```

### 5. 应用到项目

确认后，更新项目配置：
```javascript
await aiInterface.updateProjectMethod(selection.method);
```

## 示例对话

**用户**: /method

**AI**: 你好！我来帮你选择最适合的写作方法。先聊聊你的故事设想吧，你想写什么类型的故事呢？

**用户**: 我想写一个奇幻冒险故事，主角从普通人成长为英雄

**AI**: 听起来很精彩！这是经典的成长型奇幻故事。请问你预计写多长呢？

**用户**: 大概20万字左右的长篇

**AI**: 明白了。你的目标读者主要是？

**用户**: 青少年和年轻人吧

**AI**: 了解了！你希望故事的节奏如何？是快节奏的冒险，还是慢慢展开的史诗？

**用户**: 希望有张有弛，既有紧张刺激的冒险，也有角色成长的深度

**AI**:
根据你的描述，我推荐使用**英雄之旅**作为主要写作方法！

**推荐理由**：
- 非常适合奇幻冒险题材
- 完美匹配"从普通人到英雄"的成长主线
- 12个阶段的结构能很好地支撑20万字的篇幅
- 既有外在冒险，又重视内在成长

**使用建议**：
1. 不必严格遵循所有12个阶段，可以根据需要调整
2. 重点关注主角的内在转变，而不仅是外在冒险
3. 导师角色可以多样化，不一定是传统的智者形象

如果你的故事有重要的支线或者多个主要角色，我还可以帮你设计混合方法，比如支线用"故事圈"来追踪角色成长。需要吗？

## 进阶功能

### 方法转换
如果项目已经开始，可以分析并建议是否需要转换：
```javascript
const suggestion = await aiInterface.suggestConversion(currentMethod, progress);
```

### 混合设计
为复杂故事设计多层级方法：
```javascript
const hybrid = await aiInterface.designHybridScheme(context);
```

## 注意事项

1. **保持自然对话**：不要机械地问问题，要像朋友聊天一样了解需求
2. **智能推理**：从用户的描述中推断隐含信息
3. **给出理由**：解释为什么推荐这个方法
4. **提供选择**：如果有次优选择，也可以提及
5. **持续支持**：选择后，在后续创作中持续应用该方法