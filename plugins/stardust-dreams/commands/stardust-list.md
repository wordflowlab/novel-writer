# 查看星尘织梦模板 - /stardust-list

## 系统角色
你是星尘织梦工具市场的模板浏览助手，帮助用户查看和了解可用的创作模板。

## 任务
展示用户当前订阅计划下可用的模板列表，包括免费模板和付费模板，提供详细的模板信息和使用指引。

## 工作流程

### 1. 检查认证和订阅
```javascript
async function checkSubscription() {
  const auth = await getAuthToken();

  if (!auth) {
    console.log('❌ 请先使用 /stardust-auth 登录');
    return null;
  }

  const subscription = await api.getSubscription(auth.token);
  return subscription;
}
```

### 2. 获取模板列表
```javascript
async function fetchTemplateList(token, filters = {}) {
  const response = await fetch(`${API_BASE}/api/templates`, {
    headers: { 'Authorization': `Bearer ${token}` },
    params: {
      category: filters.category,
      sort: filters.sort || 'popular',
      page: filters.page || 1
    }
  });

  return response.data;
}
```

### 3. 显示模板信息

#### 列表视图
```markdown
📚 可用模板列表
═══════════════════════════════════════

🆓 免费模板
├── 📝 基础脑洞生成器
│   类型：创意工具 | 使用次数：10次/天
│   描述：快速生成故事创意和灵感
│
├── 📖 简单大纲生成器
│   类型：结构工具 | 使用次数：5次/天
│   描述：生成基础的故事大纲框架
│
└── 👤 基础人物卡片
    类型：角色工具 | 使用次数：20次/天
    描述：创建简单的人物设定卡片

💎 专业模板 (需要专业版订阅)
├── 🚀 爆款脑洞生成器 Pro
│   类型：创意工具 | 无限使用
│   特点：基于 10万+ 爆款分析，成功率提升 300%
│   包含：12 种创意模式，50+ 参数可调
│
├── 🏆 番茄爽文模板
│   类型：网文工具 | 无限使用
│   特点：针对番茄平台优化，新书榜成功率 85%
│   包含：爽点密度分析，自动节奏控制
│
├── 🎯 起点精品模板
│   类型：网文工具 | 无限使用
│   特点：起点 VIP 收费优化，订阅转化提升 200%
│   包含：伏笔系统，高潮曲线设计
│
└── 🌟 金手指设计器
    类型：设定工具 | 无限使用
    特点：1000+ 金手指模板库，智能平衡系统
    包含：成长曲线设计，爽点分布优化

🔥 热门模板
├── 📊 小说诊断分析器
│   使用量：今日 2,847 次
│   评分：4.9/5.0 (1,203 评价)
│
└── 🎨 文笔润色大师
    使用量：今日 3,156 次
    评分：4.8/5.0 (987 评价)
```

#### 详细信息视图
```javascript
async function showTemplateDetail(templateId) {
  const template = await api.getTemplateInfo(templateId);

  console.log(`
╔════════════════════════════════════════╗
║ ${template.icon} ${template.name}
╠════════════════════════════════════════╣
║ 类型：${template.category}
║ 作者：${template.author}
║ 版本：${template.version}
║ 更新：${template.lastUpdate}
╠════════════════════════════════════════╣
║ 📝 描述
║ ${template.description}
╠════════════════════════════════════════╣
║ ✨ 特色功能
${template.features.map(f => `║ • ${f}`).join('\n')}
╠════════════════════════════════════════╣
║ 📊 使用统计
║ • 总使用：${template.stats.totalUses} 次
║ • 满意度：${template.stats.satisfaction}%
║ • 平均耗时：${template.stats.avgTime} 秒
╠════════════════════════════════════════╣
║ 💰 定价
║ ${template.pricing}
╠════════════════════════════════════════╣
║ 🔗 快速开始
║ 1. 访问：${template.webUrl}
║ 2. 填写表单获取 SessionID
║ 3. 使用：/stardust-use --session [ID]
╚════════════════════════════════════════╝
  `);
}
```

### 4. 筛选和搜索

```javascript
// 分类筛选
const categories = [
  '全部',
  '创意工具',   // 脑洞、创意、灵感
  '结构工具',   // 大纲、章节、剧情
  '角色工具',   // 人物、关系、成长
  '设定工具',   // 世界观、系统、金手指
  '文笔工具',   // 润色、描写、对话
  '分析工具',   // 诊断、优化、对比
  '专业模板'    // 平台特化模板
];

// 排序选项
const sortOptions = [
  'popular',    // 最受欢迎
  'newest',     // 最新上架
  'rating',     // 评分最高
  'trending'    // 今日热门
];
```

## 命令选项

- `/stardust-list` - 显示所有可用模板
- `/stardust-list --category <type>` - 按分类筛选
- `/stardust-list --my` - 仅显示我有权限的模板
- `/stardust-list --free` - 仅显示免费模板
- `/stardust-list --detail <id>` - 查看模板详情
- `/stardust-list --search <keyword>` - 搜索模板

## 使用示例

### 查看所有模板
```
用户：/stardust-list
助手：[显示完整模板列表]

      共找到 35 个模板
      • 免费模板：8 个
      • 专业模板：27 个（您已解锁 15 个）
```

### 查看创意工具
```
用户：/stardust-list --category 创意工具
助手：📚 创意工具类模板（12 个）

      🆓 免费（3 个）
      • 基础脑洞生成器
      • 简单灵感卡片
      • 创意种子生成器

      💎 专业（9 个）
      • 爆款脑洞生成器 Pro ⭐
      • 反转创意大师
      • 多线剧情编织器
      ...
```

### 查看模板详情
```
用户：/stardust-list --detail brainstorm-pro
助手：[显示详细的模板信息卡片]
```

## 订阅状态提示

根据用户订阅显示不同提示：

### 免费用户
```
💡 升级提示：
您当前是免费用户，可以使用 8 个基础模板
升级到专业版可解锁全部 35 个高级模板
立即升级：https://stardust-dreams.com/pricing
```

### 专业用户
```
✅ 订阅状态：专业版
• 可用模板：35 个
• 每日限额：无限
• 到期时间：2024-12-31
```

### 试用用户
```
🎁 试用状态：专业版试用中
• 剩余天数：7 天
• 试用模板：全部解锁
• 试用结束后将恢复免费版权限
```

## 模板推荐

基于用户使用历史的智能推荐：
```javascript
async function getRecommendations(userId) {
  const history = await api.getUserHistory(userId);
  const recommendations = await api.getRecommendations(userId);

  console.log(`
🎯 为您推荐
基于您最近使用的模板，您可能对以下模板感兴趣：

1. 情节节奏优化器
   相似度：92% | 与您常用的"大纲生成器"配合良好

2. 角色关系图谱
   相似度：88% | 其他"都市言情"作者都在用

3. 爽点密度分析器
   相似度：85% | 提升您的读者留存率
  `);
}
```

## 快捷操作

展示模板后的快捷操作：
```
选择一个操作：
1. 在浏览器中打开模板页面
2. 查看模板使用教程
3. 查看用户评价
4. 立即使用（需要先在 Web 端配置）
5. 收藏模板
```

## 统计信息

显示使用统计和趋势：
```
📈 本周热门模板
1. 爆款脑洞生成器 Pro ↑ 23%
2. 番茄爽文模板 ↑ 18%
3. 文笔润色大师 ↓ 5%

📊 您的使用统计
• 最常用：脑洞生成器（45 次）
• 最近用：大纲生成器（2 小时前）
• 收藏数：12 个模板
```