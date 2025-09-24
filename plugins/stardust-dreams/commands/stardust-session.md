# 星尘织梦会话管理 - /stardust-session

## 系统角色
你是星尘织梦工具市场的会话管理助手，负责帮助用户查看、管理和监控活跃的会话。

## 任务
提供会话的完整生命周期管理，包括查看活跃会话、检查会话状态、延长会话时间、清理过期会话等功能。

## 工作流程

### 1. 查看活跃会话
```javascript
async function listActiveSessions(token) {
  const response = await fetch(`${API_BASE}/api/user/sessions`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });

  const sessions = response.data;

  if (sessions.length === 0) {
    console.log('📭 暂无活跃会话');
    console.log('💡 提示：在 Web 端创建会话后会显示在这里');
    return;
  }

  console.log(`
📋 活跃会话列表 (${sessions.length} 个)
═══════════════════════════════════════════

${sessions.map(renderSession).join('\n\n')}
  `);
}

function renderSession(session) {
  const remaining = getTimeRemaining(session.expiresAt);
  const statusIcon = getStatusIcon(session.status);

  return `
${statusIcon} 会话 ID: ${session.id}
├── 模板：${session.templateName}
├── 创建时间：${formatTime(session.createdAt)}
├── 剩余时间：${remaining}
├── 状态：${session.status}
├── 使用次数：${session.useCount || 0} 次
└── 参数预览：${truncate(JSON.stringify(session.parameters), 50)}
  `;
}
```

### 2. 查看会话详情
```javascript
async function getSessionDetail(sessionId, token) {
  const response = await fetch(`${API_BASE}/api/session/${sessionId}`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });

  const session = response.data;

  console.log(`
╔════════════════════════════════════════════════╗
║          会话详细信息                          ║
╠════════════════════════════════════════════════╣
║ 🆔 会话 ID: ${session.id}
║ 📝 模板: ${session.templateName}
║ 🏷️ 类型: ${session.templateType}
╠════════════════════════════════════════════════╣
║ ⏱️ 时间信息
║ • 创建时间: ${session.createdAt}
║ • 过期时间: ${session.expiresAt}
║ • 剩余时间: ${getTimeRemaining(session.expiresAt)}
╠════════════════════════════════════════════════╣
║ 📊 使用统计
║ • 使用次数: ${session.useCount} 次
║ • 最后使用: ${session.lastUsedAt || '未使用'}
║ • 生成字数: ${session.totalGenerated || 0} 字
╠════════════════════════════════════════════════╣
║ ⚙️ 配置参数
${formatParameters(session.parameters)}
╠════════════════════════════════════════════════╣
║ 🔗 快速操作
║ 1. 使用此会话: /stardust-use --session ${session.id}
║ 2. 延长时间: /stardust-session --extend ${session.id}
║ 3. 复制参数: /stardust-session --clone ${session.id}
╚════════════════════════════════════════════════╝
  `);
}

function formatParameters(params) {
  return Object.entries(params)
    .map(([key, value]) => `║ • ${key}: ${JSON.stringify(value)}`)
    .join('\n');
}
```

### 3. 延长会话时间
```javascript
async function extendSession(sessionId, token) {
  console.log('⏰ 正在延长会话时间...');

  const response = await fetch(`${API_BASE}/api/session/${sessionId}/extend`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });

  if (response.ok) {
    const { newExpiresAt } = response.data;
    console.log(`✅ 会话延长成功！`);
    console.log(`   新的过期时间：${newExpiresAt}`);
    console.log(`   剩余时间：${getTimeRemaining(newExpiresAt)}`);
  } else {
    throw new Error('延长失败：' + response.statusText);
  }
}
```

### 4. 复制会话参数
```javascript
async function cloneSession(sessionId, token) {
  // 获取原会话信息
  const original = await getSession(sessionId, token);

  console.log('📋 正在复制会话参数...');

  // 创建新会话（相同参数）
  const response = await fetch(`${API_BASE}/api/session/create`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      templateId: original.templateId,
      parameters: original.parameters,
      sourceSessionId: sessionId
    })
  });

  if (response.ok) {
    const newSession = response.data;
    console.log(`✅ 复制成功！`);
    console.log(`   新会话 ID: ${newSession.id}`);
    console.log(`   有效期至: ${newSession.expiresAt}`);
    console.log(`   使用: /stardust-use --session ${newSession.id}`);
  }
}
```

### 5. 批量管理
```javascript
async function batchManage(action, token) {
  switch (action) {
    case 'clean':
      await cleanExpiredSessions(token);
      break;
    case 'export':
      await exportSessions(token);
      break;
    case 'stats':
      await showStatistics(token);
      break;
  }
}

async function cleanExpiredSessions(token) {
  const response = await fetch(`${API_BASE}/api/sessions/clean`, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` }
  });

  const { removed } = response.data;
  console.log(`🧹 清理完成，删除了 ${removed} 个过期会话`);
}

async function exportSessions(token) {
  const sessions = await getAllSessions(token);
  const exportData = sessions.map(s => ({
    id: s.id,
    template: s.templateName,
    parameters: s.parameters,
    created: s.createdAt,
    expires: s.expiresAt
  }));

  const filename = `sessions-${Date.now()}.json`;
  await fs.writeFile(filename, JSON.stringify(exportData, null, 2));
  console.log(`📁 导出成功：${filename}`);
}
```

### 6. 会话统计
```javascript
async function showStatistics(token) {
  const stats = await fetch(`${API_BASE}/api/user/stats`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });

  console.log(`
📊 会话使用统计
═══════════════════════════════════════════

📈 今日统计
• 创建会话：${stats.today.created} 个
• 使用次数：${stats.today.used} 次
• 生成字数：${stats.today.generated} 字
• 平均耗时：${stats.today.avgTime} 秒

📅 本周统计
• 创建会话：${stats.week.created} 个
• 使用次数：${stats.week.used} 次
• 最常用模板：${stats.week.topTemplate}
• 高峰时段：${stats.week.peakHour}

🏆 历史记录
• 总会话数：${stats.total.sessions} 个
• 总使用次数：${stats.total.uses} 次
• 总生成字数：${stats.total.generated} 字
• 最爱模板：${stats.total.favoriteTemplate}

💰 配额使用
• 今日配额：${stats.quota.used}/${stats.quota.daily}
• 本月配额：${stats.quota.monthUsed}/${stats.quota.monthly}
• 配额重置：${stats.quota.resetAt}
  `);
}
```

## 命令选项

### 基础命令
- `/stardust-session` - 列出所有活跃会话
- `/stardust-session --detail <id>` - 查看会话详情
- `/stardust-session --use <id>` - 快速使用会话

### 管理命令
- `/stardust-session --extend <id>` - 延长会话时间（+15分钟）
- `/stardust-session --clone <id>` - 复制会话参数创建新会话
- `/stardust-session --delete <id>` - 删除指定会话

### 批量操作
- `/stardust-session --clean` - 清理所有过期会话
- `/stardust-session --export` - 导出会话列表
- `/stardust-session --stats` - 查看使用统计

## 使用示例

### 查看所有会话
```
用户：/stardust-session
助手：📋 活跃会话列表 (3 个)

      ✅ 会话 ID: xyz789abc
      ├── 模板：脑洞生成器
      ├── 创建时间：10:30:00
      ├── 剩余时间：8 分钟
      ├── 状态：active
      └── 使用次数：2 次

      ⏰ 会话 ID: def456ghi
      ├── 模板：大纲生成器
      ├── 创建时间：09:45:00
      ├── 剩余时间：2 分钟
      ├── 状态：expiring_soon
      └── 使用次数：0 次

      ❌ 会话 ID: jkl012mno
      ├── 模板：人物卡片
      ├── 创建时间：09:00:00
      ├── 剩余时间：已过期
      ├── 状态：expired
      └── 使用次数：5 次
```

### 查看会话详情
```
用户：/stardust-session --detail xyz789abc
助手：[显示完整的会话信息卡片]
```

### 延长会话
```
用户：/stardust-session --extend def456ghi
助手：⏰ 正在延长会话时间...
      ✅ 会话延长成功！
         新的过期时间：11:00:00
         剩余时间：17 分钟
```

### 查看统计
```
用户：/stardust-session --stats
助手：[显示详细的使用统计]
```

## 状态图标说明

- ✅ `active` - 会话正常，可以使用
- ⏰ `expiring_soon` - 即将过期（< 5分钟）
- ❌ `expired` - 已过期，不能使用
- 🔄 `in_use` - 正在使用中
- ⏸️ `paused` - 暂停状态

## 时间管理

### 剩余时间显示
```javascript
function getTimeRemaining(expiresAt) {
  const now = Date.now();
  const expires = new Date(expiresAt).getTime();
  const remaining = expires - now;

  if (remaining <= 0) return '已过期';
  if (remaining < 60000) return '< 1 分钟';
  if (remaining < 300000) return `${Math.floor(remaining / 60000)} 分钟 ⚠️`;
  return `${Math.floor(remaining / 60000)} 分钟`;
}
```

### 自动提醒
```javascript
// 会话即将过期时提醒
function checkExpiringSessions() {
  const expiring = sessions.filter(s => {
    const remaining = new Date(s.expiresAt) - Date.now();
    return remaining > 0 && remaining < 5 * 60 * 1000; // 5分钟内
  });

  if (expiring.length > 0) {
    console.log(`⚠️ 您有 ${expiring.length} 个会话即将过期！`);
    console.log('💡 使用 --extend 命令可以延长时间');
  }
}
```

## 配额管理

根据用户订阅级别显示配额信息：

### 免费用户
```
配额状态：免费版
• 每日会话：3/3 (已用完)
• 重置时间：明天 00:00
• 升级提示：升级到专业版获得无限会话
```

### 专业用户
```
配额状态：专业版
• 每日会话：无限
• 并发会话：10 个
• 会话时长：30 分钟/个
```

## 错误处理

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| SESSION_NOT_FOUND | 会话不存在 | 检查 ID 是否正确 |
| SESSION_EXPIRED | 会话已过期 | 创建新会话或延长时间 |
| QUOTA_EXCEEDED | 超出配额 | 等待重置或升级计划 |
| PERMISSION_DENIED | 无权访问 | 确认会话属于当前用户 |