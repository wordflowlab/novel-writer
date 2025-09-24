# 使用星尘织梦模板 - /stardust-use

## 系统角色
你是星尘织梦工具市场的执行助手，负责从服务端获取加密的 Prompt 模板，在内存中解密并填充参数，生成高质量的创作内容。

## 重要安全原则
⚠️ **核心安全要求**：
1. **永不保存** - 解密后的 Prompt 绝不能写入文件或日志
2. **即用即删** - 使用完立即从内存清理
3. **权限验证** - 必须有有效的认证 token
4. **会话校验** - SessionID 必须有效且属于当前用户

## 工作流程

### 步骤 1：参数验证
```javascript
async function validateParams(sessionId, options) {
  // 检查必需参数
  if (!sessionId) {
    throw new Error('请提供 SessionID (--session 参数)');
  }

  // 验证 SessionID 格式
  if (!/^[a-zA-Z0-9]{8,12}$/.test(sessionId)) {
    throw new Error('SessionID 格式无效');
  }

  // 检查认证状态
  const auth = await getAuthToken();
  if (!auth || isExpired(auth)) {
    throw new Error('请先使用 /stardust-auth 登录');
  }

  return { sessionId, token: auth.token };
}
```

### 步骤 2：获取会话信息
```javascript
async function fetchSessionInfo(sessionId) {
  // 从公开 API 获取会话基本信息
  const response = await fetch(`${API_BASE}/api/session/${sessionId}`);

  if (!response.ok) {
    if (response.status === 404) {
      throw new Error('会话不存在或已过期，请重新在 Web 端生成');
    }
    throw new Error('获取会话信息失败');
  }

  const session = await response.json();

  // 显示会话信息
  console.log(`
📋 会话信息：
- 模板：${session.templateName}
- 类型：${session.templateType}
- 创建时间：${session.createdAt}
- 过期时间：${session.expiresAt}
  `);

  return session;
}
```

### 步骤 3：获取加密的 Prompt
```javascript
async function fetchEncryptedPrompt(token, templateId, sessionId) {
  console.log('🔐 正在获取加密模板...');

  const response = await fetch(`${API_BASE}/api/protected/prompt/get`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      templateId,
      sessionId
    })
  });

  if (!response.ok) {
    if (response.status === 401) {
      throw new Error('认证失败，请重新登录');
    }
    if (response.status === 403) {
      throw new Error('无权访问此模板，请检查订阅状态');
    }
    if (response.status === 429) {
      throw new Error('请求过于频繁，请稍后重试');
    }
    throw new Error(`获取模板失败: ${response.statusText}`);
  }

  const data = await response.json();

  return {
    encryptedPrompt: data.encryptedPrompt,  // 加密的 Prompt
    sessionKey: data.sessionKey,            // 解密密钥
    parameters: data.parameters,            // 用户参数
    metadata: data.metadata                 // 元数据
  };
}
```

### 步骤 4：内存中解密和处理
```javascript
async function processPromptInMemory(encryptedData) {
  let decryptedPrompt = null;
  let finalPrompt = null;

  try {
    console.log('🔓 解密模板中...');

    // 1. 在内存中解密 Prompt
    decryptedPrompt = await decrypt(
      encryptedData.encryptedPrompt,
      encryptedData.sessionKey
    );

    // 2. 填充用户参数
    console.log('📝 填充参数中...');
    finalPrompt = fillTemplate(decryptedPrompt, encryptedData.parameters);

    // 3. 立即使用（传递给 AI）
    console.log('🤖 生成内容中...');
    const result = await executeWithAI(finalPrompt);

    return result;

  } finally {
    // 4. 强制清理内存（无论成功或失败）
    if (decryptedPrompt) {
      clearSensitiveData(decryptedPrompt);
      decryptedPrompt = null;
    }
    if (finalPrompt) {
      clearSensitiveData(finalPrompt);
      finalPrompt = null;
    }

    // 如果 Node.js 支持，触发垃圾回收
    if (global.gc) {
      global.gc();
    }
  }
}

// 清理敏感数据
function clearSensitiveData(data) {
  if (typeof data === 'string') {
    // JavaScript 无法真正覆写内存，但可以尽快释放引用
    data = '';
    data = null;
  } else if (typeof data === 'object') {
    Object.keys(data).forEach(key => {
      data[key] = null;
      delete data[key];
    });
  }
}
```

### 步骤 5：解密实现（仅内存操作）
```javascript
const crypto = require('crypto');

async function decrypt(encryptedData, sessionKey) {
  // 解析加密数据
  const parts = encryptedData.split(':');
  const iv = Buffer.from(parts[0], 'base64');
  const authTag = Buffer.from(parts[1], 'base64');
  const encrypted = Buffer.from(parts[2], 'base64');

  // 派生解密密钥
  const key = crypto.scryptSync(sessionKey, 'stardust-dreams', 32);

  // 创建解密器
  const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
  decipher.setAuthTag(authTag);

  // 解密（结果仅在内存中）
  let decrypted = decipher.update(encrypted, null, 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}
```

### 步骤 6：模板填充
```javascript
function fillTemplate(template, parameters) {
  let filled = template;

  // 简单替换 {{variable}}
  Object.keys(parameters).forEach(key => {
    const regex = new RegExp(`{{\\s*${key}\\s*}}`, 'g');
    filled = filled.replace(regex, parameters[key]);
  });

  // 处理条件块 {{#if condition}}...{{/if}}
  filled = processConditionals(filled, parameters);

  // 处理循环 {{#each items}}...{{/each}}
  filled = processLoops(filled, parameters);

  return filled;
}
```

## 命令选项

### 基础用法
```bash
/stardust-use --session <sessionId>
```

### 高级选项
- `--session <id>` - 指定会话 ID（必需）
- `--output <file>` - 保存生成结果到文件（仅保存结果，不保存 Prompt）
- `--format <type>` - 输出格式（text/json/markdown）
- `--stream` - 流式输出（实时显示生成进度）
- `--retry` - 失败时自动重试

## 使用示例

### 示例 1：基础使用
```
用户：/stardust-use --session xyz789abc
助手：📋 会话信息：
      - 模板：脑洞生成器
      - 类型：创意工具
      - 创建时间：10:30:00
      - 过期时间：10:45:00

      🔐 正在获取加密模板...
      🔓 解密模板中...
      📝 填充参数中...
      🤖 生成内容中...

      ✨ 生成完成！

      【创意 1】修仙界的程序员系统
      主角是现代程序员穿越到修仙世界，发现可以用代码
      来编写法术和阵法...

      【创意 2】数据流大道
      在这个世界，修炼就是处理数据流，突破就是算法
      优化...
```

### 示例 2：保存结果
```
用户：/stardust-use --session xyz789abc --output ideas.md
助手：✅ 内容已生成并保存到 ideas.md
```

### 示例 3：流式输出
```
用户：/stardust-use --session xyz789abc --stream
助手：🤖 正在生成... [实时显示生成的文字]
```

## 错误处理

| 错误类型 | 原因 | 解决方案 |
|---------|------|----------|
| SESSION_NOT_FOUND | 会话不存在 | 重新在 Web 端生成 |
| SESSION_EXPIRED | 会话已过期 | 重新在 Web 端生成 |
| AUTH_REQUIRED | 未登录 | 使用 /stardust-auth 登录 |
| SUBSCRIPTION_REQUIRED | 需要付费订阅 | 升级订阅计划 |
| RATE_LIMIT | 请求过频 | 等待后重试 |
| DECRYPT_FAILED | 解密失败 | 检查会话有效性 |

## 性能优化

### 内存管理
```javascript
// 使用 WeakMap 自动管理内存
const promptCache = new WeakMap();

// 设置内存限制
const MAX_MEMORY = 50 * 1024 * 1024; // 50MB

// 监控内存使用
if (process.memoryUsage().heapUsed > MAX_MEMORY) {
  console.warn('内存使用过高，清理缓存...');
  global.gc && global.gc();
}
```

### 缓存策略
- **不缓存 Prompt** - 解密后的 Prompt 永不缓存
- **缓存会话信息** - 会话基本信息缓存 5 分钟
- **缓存认证 Token** - Token 加密缓存至过期

## 安全审计

所有操作都会记录审计日志（不含敏感内容）：
```json
{
  "action": "use_template",
  "userId": "user123",
  "templateId": "brainstorm",
  "sessionId": "xyz789abc",
  "timestamp": "2024-01-20T10:35:00Z",
  "success": true,
  "duration": 3500
}
```

## 注意事项

1. **不要尝试保存 Prompt** - 这违反使用条款
2. **不要共享 SessionID** - 每个会话绑定特定用户
3. **及时使用** - 会话 15 分钟后过期
4. **合理使用** - 遵守速率限制
5. **保护账号** - 不要共享认证信息

## 后续步骤

生成内容后，你可以：
1. 继续编辑和完善生成的内容
2. 使用其他模板生成更多创意
3. 查看 `/stardust-session` 管理会话
4. 访问 Web 端查看使用记录和统计