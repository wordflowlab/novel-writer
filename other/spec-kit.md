# Spec-Kit 编程实战指南: 规格驱动开发(SDD)方法论

> 面向中国开发者的Spec-Kit实战教程
> 从零构建"智慧课堂"在线教育平台

---

## 零、开始使用 Spec-Kit

### 安装 Specify CLI 工具

Spec-Kit 提供了 `specify` 命令行工具来快速初始化项目。选择以下任一安装方式:

#### 方式一: 持久安装(推荐)

一次安装,随处使用:

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

安装后可直接使用:

```bash
specify init <项目名称>
specify check
```

升级工具:

```bash
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git
```

#### 方式二: 一次性使用

无需安装,直接运行:

```bash
uvx --from git+https://github.com/github/spec-kit.git specify init <项目名称>
```

### 初始化项目

使用 `specify init` 命令初始化 Spec-Kit 项目:

```bash
# 创建新项目
specify init my-project

# 指定 AI 代理
specify init my-project --ai claude

# 在当前目录初始化
specify init . --ai claude
# 或使用 --here 标志
specify init --here --ai claude

# 强制合并到非空目录(跳过确认)
specify init . --force --ai claude
```

### 支持的 AI 代理

| AI 代理 | 支持状态 | 备注 |
|---------|---------|------|
| [Claude Code](https://www.anthropic.com/claude-code) | ✅ | |
| [GitHub Copilot](https://code.visualstudio.com/) | ✅ | |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | ✅ | |
| [Cursor](https://cursor.sh/) | ✅ | |
| [Windsurf](https://windsurf.com/) | ✅ | |
| [Qwen Code](https://github.com/QwenLM/qwen-code) | ✅ | |
| [opencode](https://opencode.ai/) | ✅ | |
| [Roo Code](https://roocode.com/) | ✅ | |

### 前置要求

- **操作系统**: Linux/macOS (或 Windows WSL2)
- **AI 代理**: 上述任一支持的 AI 编程工具
- **Python**: 3.11+
- **包管理器**: [uv](https://docs.astral.sh/uv/)
- **版本控制**: [Git](https://git-scm.com/downloads)

---

## 一、核心理念: 规格驱动开发的本质

### 什么是规格驱动开发?

**SDD (Spec-Driven Development 规格驱动开发)** 是一种颠覆性的软件开发方法论,核心思想是:

> **规格不再服务于代码,代码服务于规格**s

**传统软件开发的困境**:
```
需求文档(Word) → 设计文档(Visio) → 编码 → 测试 → 上线
    ↓               ↓                ↓      ↓
  过时了         和代码不符         真相   补救
```
结果: 文档永远落后,最后"代码即文档"

**SDD驱动开发的循环**:
```
项目宪法 → 功能规格 → 澄清决策 → 技术方案 → 任务分解
                                              ↓
                                          质量门检查
                                              ↓
                                          自动实现代码
  ↑                                           ↓
  └────── 发现问题,回到合适层级修改规格 ──────┘
```

### 为什么现在需要SDD?

**三大趋势使SDD成为必然:**

1. **AI能力突破**: GPT-4/Claude等LLM可以理解自然语言规格并生成可用代码
2. **复杂度爆炸**: 现代系统集成Redis、MQ、微服务等几十个组件,手工维护一致性越来越难
3. **需求变化加速**: 敏捷开发常态下,需求每周都变。传统方式改需求=灾难,SDD只需更新规格重新生成

**SDD的核心洞察**:

传统开发: 代码是真相,文档是附属品 → 代码不断演进,文档逐渐过时

SDD反转关系: **规格是真相,代码是其在Java/Python/Go下的表达**
- 维护软件 = 演进规格
- 调试BUG = 修复规格中的逻辑错误
- 重构 = 重组规格的结构

### SDD不是线性流程,而是递归循环

**❌ 错误理解: 线性执行一次**
```
整个项目: 宪法 → 规格 → 方案 → 任务 → 实现(手工写100个功能)
                                      ↑
                              一直在这里手工编码
```

**✅ 正确理解: 分层递归**
```
第1层 - 整个项目:   宪法 → 规格(架构) → 技术选型
           ↓
第2层 - 单个功能:   规格 → 澄清 → 方案 → 任务 → 质量门 → 实现
           ↓
第3层 - 功能模块:   方案 → 任务 → 实现
           ↓
第4层 - 单个任务:   实现
```

**每个层级都可以执行完整的SDD循环!** 这才是方法论的精髓。

---

## 二、七步法详解

### 核心命令流程

SDD 提供了以下核心命令来实现完整的开发流程:

```
1. /speckit.constitution  →  项目宪法(最高原则,定义项目DNA)
2. /speckit.specify       →  功能规格(单一真相源,定义做什么和为什么)
3. /speckit.clarify       →  澄清决策(消除歧义,标记待确认点) [可选,推荐]
4. /speckit.plan          →  技术方案(定义怎么做,选择技术栈)
5. /speckit.tasks         →  任务分解(可执行步骤,标注并行性)
6. /speckit.analyze       →  质量门(一致性验证,CRITICAL问题必修) [可选,推荐]
7. /speckit.implement     →  执行实现(TDD方式生成代码)
```

**可选增强命令:**
- `/speckit.checklist` - 生成自定义质量检查清单,验证需求完整性、清晰度和一致性

### 各命令的核心职责

| 命令 | 输入 | 输出 | 关键约束 |
|------|------|------|---------|
| `/speckit.constitution` | 项目理念 | `项目宪法.md` | 定义不可妥协的原则 |
| `/speckit.specify` | 功能描述 | `功能规格.md` | 只写做什么/为什么,不写怎么做 |
| `/speckit.clarify` | 规格文档 | 更新后的规格 | 强制解决所有待确认点 |
| `/speckit.plan` | 规格+技术选型 | `技术方案.md`+`数据模型.md` | 必须通过宪法检查 |
| `/speckit.tasks` | 技术方案 | `任务列表.md` | 标注依赖和并行性 |
| `/speckit.analyze` | 规格+方案+任务 | 分析报告 | **只读**,不修改文件 |
| `/speckit.implement` | 任务列表 | 代码+测试 | 严格TDD: 先测试后实现 |
| `/speckit.checklist` | 规格文档 | 质量检查清单 | 验证需求完整性和一致性 |

### 七步流程的质量门机制

```
宪法 ──→ 规格 ──→ 澄清 ──→ 方案 ──→ 任务
         ↓         ↓        ↓        ↓
     [标记歧义] [解决歧义] [宪法门] [任务门]
                                     ↓
                                 质量门 ←── CRITICAL问题阻塞
                                     ↓
                                   实现
```

**`/speckit.analyze` 是关键质量门**:
- 在 `/speckit.tasks` 完成后、`/speckit.implement` 之前**强制运行**
- 检测6种问题: 重复、歧义、覆盖度、宪法违规、一致性、术语漂移
- 分级: CRITICAL(必修) / HIGH(建议) / MEDIUM(改进) / LOW(可选)
- **如有CRITICAL问题,阻塞 `/speckit.implement`**

### 各层级如何应用七步法

| 层级 | 宪法 | 规格 | 澄清 | 方案 | 任务 | 质量门 | 实现 |
|------|------|------|------|------|------|--------|------|
| **整个项目** | ✅ 一次 | ✅ 高层架构 | ✅ 核心决策 | ✅ 技术选型 | ✅ 功能清单 | ✅ 架构验证 | - |
| **单个功能** | 继承 | ✅ 功能规格 | ✅ 细节 | ✅ 实现方案 | ✅ 开发任务 | ✅ **强制** | ✅ 生成代码 |
| **功能模块** | 继承 | 继承 | - | ✅ 模块设计 | ✅ 子任务 | ✅ 可选 | ✅ 模块代码 |
| **单个任务** | 继承 | 继承 | - | - | - | - | ✅ 任务代码 |

---

## 三、实战案例: "智慧课堂"在线教育平台

### 项目背景

- **项目名称**: 智慧课堂
- **项目类型**: K12在线教育平台
- **核心功能**: 课程管理、作业批改、在线考试、成绩分析
- **技术栈**: Spring Boot 3.x + Vue 3 + MySQL 8.0 + Redis
- **目标**: 展示从零到可运行应用的完整SDD流程

---

## 场景1: 项目初始化 - 用Constitution定义项目DNA

### 步骤1: 创建项目宪法

```bash
/speckit.constitution 创建聚焦代码质量、测试标准、教育行业合规性和性能要求的项目原则
```

**AI生成的宪法核心内容**:

```markdown
# 智慧课堂项目宪法

## 第一条: 模块优先原则

每个功能必须先设计为独立模块。禁止在主应用代码中直接实现业务逻辑,
必须先抽象为可复用的Service层组件。

**理由**: 强制模块化、可复用性和可测试性。

## 第二条: 接口清晰原则

所有Service必须定义清晰的接口:
- RESTful API: 统一返回Result<T>包装
- 错误处理: 业务异常BusinessException,系统异常统一拦截
- 支持JSON格式,字段命名驼峰式

**理由**: 确保前后端接口一致,便于Mock测试。

## 第三条: 测试先行原则(不可妥协)

禁止在以下步骤完成前编写实现代码:
1. 接口契约已定义(OpenAPI规范)
2. 测试用例已编写并通过评审
3. 测试已运行并确认失败(TDD红灯阶段)

**理由**: 防止不可测试的代码,确保需求明确。

## 第四条: 数据安全原则(教育行业合规)

学生个人信息必须:
1. 手机号/身份证号加密存储(AES-256)
2. 日志中脱敏显示(135****1234)
3. 数据导出需审批流程
4. 满足《个人信息保护法》要求

**违规后果**: CRITICAL级别,阻止上线。

## 第七条: 简单性关卡

- 初始版本最多3个Maven模块: common、service、web
- 禁止引入"可能未来用到"的依赖(如Elasticsearch,当前MySQL够用)
- YAGNI原则: 你不会需要它

## 第八条: 反过度抽象关卡

- 直接使用MyBatis-Plus,不要再包装一层BaseMapper
- 单一模型表示: Entity直接用于Controller返回(小项目无需DTO/VO分离)

## 第九条: 集成测试优先

- 使用真实MySQL(docker-compose),不用H2内存库
- Controller测试用@SpringBootTest完整启动
- 测试数据使用SQL脚本管理(src/test/resources/data.sql)
```

**为什么宪法重要?**

宪法是项目的"基因",定义了**不可妥协的原则**。后续所有`/speckit.plan`生成的方案都必须通过这些检查,否则`/speckit.analyze`会报CRITICAL错误,阻止实现。

---

## 场景2: 功能开发完整流程 - 从规格到实现

### 步骤2: 定义功能规格(只写做什么,不写怎么做)

```bash
/speckit.specify 开发"作业批改"功能。教师可以发布作业(题目+截止时间+附件),学生提交作业(支持上传图片/PDF),教师在线批改并给分(0-100分+文字评语)。初始版本: 3个教师、30个学生、2个班级。作业状态包括: 未提交、已提交、已批改、需修改。学生可查看批改结果和历史记录,教师可统计班级提交率和平均分。逾期提交的作业标记为红色。权限控制: 学生只能看到自己的作业,教师只能看到自己任教班级的作业。
```

**输出**: `specs/001-zuoye-pigai/spec.md`

**关键内容**:

```markdown
## 功能概述

**做什么**: 在线作业提交和批改系统
**为什么**: 替代传统纸质作业收发,提升批改效率,留存学习记录

## 功能需求

### 需求1: 作业发布
教师可以创建作业,包含以下信息:
- 作业标题(必填,≤50字)
- 作业内容(必填,富文本,支持插入图片)
- 截止时间(必填,不能早于当前时间)
- 附件(可选,支持PDF/Word,单个≤10MB)

### 需求2: 学生提交作业
学生可以提交作业答案:
- 支持上传图片(jpg/png,单张≤5MB,最多9张)
- 支持上传PDF(≤10MB)
- 可在截止时间前修改提交内容
- 逾期提交需标记(显示红色"迟交"标签)

### 需求3: 教师批改
教师可以批改已提交的作业:
- 给分: 0-100整数
- 评语: 文字评价(≤500字)
- 批改时间自动记录

### 需求4: 状态管理
作业对学生有4种状态:
- 未提交: 学生未提交,截止时间内
- 已提交: 学生已提交,等待批改
- 已批改: 教师已批改并给分
- 需修改: 教师要求学生重新提交

### 需求5: 统计功能
教师可查看班级作业统计:
- 提交率: 已提交人数/班级总人数
- 平均分: 已批改作业的平均成绩
- 分数分布: 各分数段人数

### 需求6: 权限控制
- 学生: 只能看到自己提交的作业和批改结果
- 教师: 只能看到自己任教班级的所有学生作业

## 非功能需求

### 性能要求
- 作业列表加载时间 < 1秒(100个作业内)
- 文件上传速度: 5MB文件在10秒内完成

### 数据安全
- 学生姓名和学号符合《个人信息保护法》,日志脱敏
- 作业内容和批改记录保留1年

### 待确认点
- [待确认] 学生逾期是否还能提交? 还是直接锁定?
  - 方案A: 允许逾期提交,但标记"迟交",教师可酌情扣分
  - 方案B: 截止时间后禁止提交

- [待确认] 批改后学生是否可申诉?
  - 方案A: 不支持申诉,教师批改为最终结果
  - 方案B: 学生可发起申诉,教师重新批改

## 用户故事

### 用户故事1: 教师发布作业
**作为** 数学老师张老师
**我想要** 在系统中创建一个作业"第三章练习题"
**以便于** 学生在线提交,我可以集中批改

**验收标准**:
- 输入标题、内容、截止时间(2024-06-30 23:59)
- 上传附件"练习题.pdf"
- 点击"发布"后,2个班级(初一(1)班、初一(2)班)的学生都能看到

### 用户故事2: 学生提交作业
**作为** 初一(1)班学生小明
**我想要** 上传我的作业答案照片
**以便于** 老师批改

**验收标准**:
- 拍摄3张作业照片,上传成功
- 提交后状态变为"已提交"
- 如果在截止时间(2024-06-30 23:59)后提交,显示红色"迟交"标签

### 用户故事3: 教师批改作业
**作为** 张老师
**我想要** 批改小明的作业
**以便于** 给出成绩和反馈

**验收标准**:
- 查看小明上传的3张照片
- 给分: 85分
- 评语: "计算过程清晰,但第3题粗心算错了"
- 保存后,小明可以看到批改结果

## 边界情况

### 边界1: 截止时间恰好到达时提交
学生在2024-06-30 23:59:58提交,是否算逾期?
**决策**: 截止时间当分钟内提交都算准时(≤23:59:59)

### 边界2: 文件上传失败
学生上传5MB图片,网络超时失败。
**处理**: 前端显示"上传失败,请重试",已上传的其他图片保留

### 边界3: 教师误批
教师给小明打了58分,发现输错了,应该是85分。
**处理**: 教师可以重新批改,覆盖之前的成绩和评语
```

**注意**:
- ✅ 专注于做什么(功能需求)和为什么(业务目标)
- ✅ 标记了2个待确认点,等待`/speckit.clarify`解决
- ❌ 没有提及MySQL、Redis、MyBatis等技术细节

### 步骤3: 澄清待确认点

```bash
/speckit.clarify
```

**AI自动分析并提问**:

```markdown
## 待确认问题

### 问题1: 逾期提交策略(需求2相关)
当前规格不明确。可选方案:

**方案A: 允许逾期提交(推荐)**
- 优点: 灵活,教师可酌情给分
- 缺点: 可能被滥用
- 实现: 数据库加字段`is_late`标记

**方案B: 截止后禁止提交**
- 优点: 规则严格,培养时间观念
- 缺点: 学生忘记截止时间会投诉
- 实现: Controller判断时间,超时返回403

**建议**: 教育场景选方案A,给学生改正机会。

用户选择: 方案A
```

**AI更新规格文档**:

```markdown
### 需求2: 学生提交作业(已更新)

学生可以提交作业答案:
- 支持上传图片(jpg/png,单张≤5MB,最多9张)
- 支持上传PDF(≤10MB)
- 可在截止时间前修改提交内容
- **逾期提交策略**: 允许逾期提交,但前端显示红色"迟交"标签,教师可酌情扣分
```

**问题2: 批改后申诉机制**

```markdown
**方案A: 不支持申诉(推荐MVP)**
- 优点: 简单,减少争议
- 缺点: 教师误批无法纠正?
- 实现: 无需额外表设计

**方案B: 支持申诉流程**
- 优点: 公平,可纠错
- 缺点: 复杂,需要申诉表、通知机制
- 实现: 需要`homework_appeal`表 + 消息推送

**建议**: 初始版本选方案A,但教师可自行修改批改结果(等同简化版申诉)。

用户选择: 方案A,但允许教师修改
```

**澄清完成,所有待确认点已解决**。

### 步骤4: 制定技术方案(开始涉及怎么做)

```bash
/speckit.plan 使用Spring Boot 3.2 + MyBatis-Plus + MySQL 8.0 + Redis作为缓存。文件上传使用阿里云OSS,统计数据用Redis缓存5分钟。前端Vue3 + Element Plus,图片预览用viewerjs。
```

**输出**: `specs/001-zuoye-pigai/plan.md`, `data-model.md`, `contracts/api-spec.yaml`

**技术方案关键内容**:

```markdown
## 技术架构

### 技术选型
- **后端框架**: Spring Boot 3.2.5
- **ORM**: MyBatis-Plus 3.5.6(简化CRUD)
- **数据库**: MySQL 8.0
- **缓存**: Redis 7.0(缓存班级统计数据)
- **文件存储**: 阿里云OSS(存储作业附件和学生提交的图片)
- **前端**: Vue 3.3 + Element Plus + Axios
- **图片预览**: viewerjs

### 第0阶段: 实现前检查(宪法关卡)

#### 简单性关卡(第七条)
- [✅] 使用≤3个Maven模块?
  是: homework-common、homework-service、homework-web
- [✅] 无未来导向功能?
  是: 不引入Elasticsearch(当前MySQL够用)

#### 反过度抽象关卡(第八条)
- [✅] 直接使用框架?
  是: 用MyBatis-Plus BaseMapper,不再封装
- [⚠️] 单一模型表示?
  否: 分离Entity和VO(理由: Entity包含敏感字段如`student_id_card`,VO需要脱敏)
  **复杂度跟踪**: 已记录,用户审批

#### 测试先行关卡(第三条)
- [✅] 契约已定义?
  是: 见`contracts/api-spec.yaml`
- [⏳] 契约测试已写?
  待执行: 在`/speckit.tasks`阶段完成

### 核心实现阶段

#### 阶段1: 数据层搭建
1. 创建MySQL表: `homework`(作业表)、`homework_submission`(提交表)、`homework_review`(批改表)
2. 实现Entity: HomeworkEntity、HomeworkSubmissionEntity、HomeworkReviewEntity
3. MyBatis-Plus Mapper: HomeworkMapper、SubmissionMapper、ReviewMapper
4. 数据初始化: 3个教师、30个学生、2个班级

#### 阶段2: 业务层实现
1. HomeworkService: 发布作业、查询作业列表
2. SubmissionService: 提交作业、查询提交记录、判断逾期
3. ReviewService: 批改作业、修改批改
4. StatisticsService: 计算提交率、平均分(Redis缓存5分钟)

#### 阶段3: 接口层实现
1. HomeworkController: POST /api/homework(发布), GET /api/homework/list(列表)
2. SubmissionController: POST /api/submission(提交), GET /api/submission/:id(详情)
3. ReviewController: POST /api/review(批改), PUT /api/review/:id(修改)
4. FileController: POST /api/file/upload(OSS上传)

#### 阶段4: 前端页面
1. 教师端: 作业发布页、批改页、统计页
2. 学生端: 作业列表页、提交页、结果查看页
3. 公共组件: 文件上传组件、图片预览组件
```

**数据模型(data-model.md)**:

```markdown
## 数据表设计

### 作业表(homework)
```sql
CREATE TABLE homework (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '作业ID',
  title VARCHAR(50) NOT NULL COMMENT '作业标题',
  content TEXT NOT NULL COMMENT '作业内容(富文本)',
  teacher_id BIGINT NOT NULL COMMENT '发布教师ID',
  class_ids VARCHAR(200) NOT NULL COMMENT '班级ID列表(JSON数组)',
  deadline DATETIME NOT NULL COMMENT '截止时间',
  attachment_url VARCHAR(500) COMMENT '附件OSS地址',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_teacher_id (teacher_id),
  INDEX idx_deadline (deadline)
) COMMENT='作业表';
```

### 提交表(homework_submission)
```sql
CREATE TABLE homework_submission (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  homework_id BIGINT NOT NULL COMMENT '作业ID',
  student_id BIGINT NOT NULL COMMENT '学生ID',
  content TEXT COMMENT '提交内容(文字)',
  image_urls TEXT COMMENT '图片地址列表(JSON数组)',
  pdf_url VARCHAR(500) COMMENT 'PDF地址',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1未批改 2已批改 3需修改',
  is_late TINYINT NOT NULL DEFAULT 0 COMMENT '0准时 1逾期',
  submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_homework_student (homework_id, student_id),
  INDEX idx_student_id (student_id),
  INDEX idx_status (status)
) COMMENT='作业提交表';
```

### 批改表(homework_review)
```sql
CREATE TABLE homework_review (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  submission_id BIGINT NOT NULL COMMENT '提交ID',
  teacher_id BIGINT NOT NULL COMMENT '批改教师ID',
  score TINYINT NOT NULL COMMENT '分数0-100',
  comment VARCHAR(500) COMMENT '评语',
  reviewed_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '批改时间',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_submission (submission_id),
  INDEX idx_teacher_id (teacher_id)
) COMMENT='批改表';
```
```

**API契约(contracts/api-spec.yaml)**:

```yaml
openapi: 3.0.0
info:
  title: 智慧课堂-作业批改API
  version: 1.0.0

paths:
  /api/homework:
    post:
      summary: 发布作业
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [title, content, classIds, deadline]
              properties:
                title:
                  type: string
                  maxLength: 50
                  example: "第三章练习题"
                content:
                  type: string
                  example: "<p>完成第45-50页习题</p>"
                classIds:
                  type: array
                  items:
                    type: integer
                  example: [1, 2]
                deadline:
                  type: string
                  format: date-time
                  example: "2024-06-30T23:59:59"
                attachmentUrl:
                  type: string
                  example: "https://oss.example.com/homework/xxx.pdf"
      responses:
        '200':
          description: 发布成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Result'

  /api/submission:
    post:
      summary: 提交作业
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [homeworkId]
              properties:
                homeworkId:
                  type: integer
                  example: 1
                content:
                  type: string
                  example: "我的答案是..."
                imageUrls:
                  type: array
                  items:
                    type: string
                  example: ["https://oss.example.com/sub/1.jpg", "https://oss.example.com/sub/2.jpg"]
                pdfUrl:
                  type: string
      responses:
        '200':
          description: 提交成功

  /api/review:
    post:
      summary: 批改作业
      requestBody:
        content:
          application/json:
            schema:
              type: object
              required: [submissionId, score]
              properties:
                submissionId:
                  type: integer
                score:
                  type: integer
                  minimum: 0
                  maximum: 100
                  example: 85
                comment:
                  type: string
                  maxLength: 500
                  example: "计算过程清晰,但第3题粗心算错了"
      responses:
        '200':
          description: 批改成功

components:
  schemas:
    Result:
      type: object
      properties:
        code:
          type: integer
          example: 200
        message:
          type: string
          example: "操作成功"
        data:
          type: object
```

### 步骤5: 分解为可执行任务

```bash
/speckit.tasks
```

**输出**: `specs/001-zuoye-pigai/tasks.md`

```markdown
## 任务分解

### 第0阶段: 搭建骨架和契约

#### 任务001 [可并行] - 创建项目结构
- 初始化Spring Boot项目(maven)
- 创建3个模块: common、service、web
- 配置pom.xml依赖(MyBatis-Plus、Redis、OSS SDK)
- **交付物**: 项目可编译通过

#### 任务002 [可并行] - 定义API契约
- 复制`contracts/api-spec.yaml`到项目
- 使用swagger-codegen生成Java DTO
- **交付物**: DTO类可被Controller引用

#### 任务003 [依赖: 任务002] - 编写契约测试
- 测试: POST /api/homework 返回200
- 测试: POST /api/submission 无homeworkId返回400
- 测试: POST /api/review score=101 返回400
- **交付物**: 所有测试失败(TDD红灯阶段)

### 第1阶段: 数据层(可并行组A)

#### 任务004 [可并行] [依赖: 任务003] - 搭建MySQL
- docker-compose启动MySQL 8.0
- 创建数据库`classroom_db`
- 执行DDL脚本(homework、homework_submission、homework_review)
- **交付物**: 表结构创建完成

#### 任务005 [可并行] [依赖: 任务003] - 初始化种子数据
- 插入3个教师: 张老师(数学)、李老师(语文)、王老师(英语)
- 插入30个学生: 学号1001-1030,分配到2个班级
- 插入2个班级: 初一(1)班、初一(2)班
- **交付物**: 种子数据可查询

### 第2阶段: 业务层实现(依赖: 第1阶段)

#### 任务006 [依赖: 任务004] - 实现HomeworkService
- 创建HomeworkMapper(MyBatis-Plus)
- 实现发布作业: `publishHomework(HomeworkDTO dto)`
- 实现查询列表: `listHomework(Long teacherId)`
- **交付物**: 任务003中的POST /api/homework测试通过(变绿)

#### 任务007 [依赖: 任务004] - 实现SubmissionService
- 创建SubmissionMapper
- 实现提交作业: `submitHomework(SubmissionDTO dto)`
- 实现逾期判断: `isLate(Long homeworkId, LocalDateTime submitTime)`
- 实现查询: `getSubmission(Long submissionId)`
- **交付物**: POST /api/submission测试通过

#### 任务008 [依赖: 任务004] - 实现ReviewService
- 创建ReviewMapper
- 实现批改: `reviewHomework(ReviewDTO dto)`
- 实现修改批改: `updateReview(Long reviewId, ReviewDTO dto)`
- **交付物**: POST /api/review测试通过

### 第3阶段: 接口层(可并行组B)

#### 任务009 [可并行] [依赖: 任务006] - HomeworkController
- 创建Controller,注入HomeworkService
- 实现POST /api/homework
- 实现GET /api/homework/list?teacherId=1
- 权限校验: 只有教师可发布
- **交付物**: Postman测试通过

#### 任务010 [可并行] [依赖: 任务007] - SubmissionController
- 实现POST /api/submission
- 实现GET /api/submission/:id
- 权限校验: 学生只能查询自己的提交
- **交付物**: 前端可调用

#### 任务011 [依赖: 任务008] - ReviewController
- 实现POST /api/review
- 实现PUT /api/review/:id(修改批改)
- 权限校验: 教师只能批改自己班级学生作业
- **交付物**: 完整批改流程打通

#### 任务012 [可并行] - FileController文件上传
- 集成阿里云OSS SDK
- 实现POST /api/file/upload(支持图片/PDF)
- 文件大小校验: 图片≤5MB,PDF≤10MB
- 返回OSS地址
- **交付物**: 前端可上传文件获得URL

#### 任务013 [依赖: 任务007] - StatisticsService统计功能
- 实现计算提交率: `calcSubmitRate(Long homeworkId)`
- 实现计算平均分: `calcAvgScore(Long homeworkId)`
- Redis缓存5分钟(key: `stats:homework:{id}`)
- **交付物**: GET /api/statistics/:homeworkId 返回统计数据

### 第4阶段: 前端页面

#### 任务014 [依赖: 任务009] - 教师发布作业页面
- Vue组件: HomeworkPublish.vue
- 表单: 标题、富文本编辑器、截止时间选择器
- 调用POST /api/homework
- **交付物**: 教师可发布作业

#### 任务015 [依赖: 任务010, 任务012] - 学生提交作业页面
- Vue组件: HomeworkSubmit.vue
- 图片上传组件(最多9张)
- PDF上传组件
- 逾期提示(红色"迟交"标签)
- **交付物**: 学生可提交作业

#### 任务016 [依赖: 任务011] - 教师批改页面
- Vue组件: HomeworkReview.vue
- 图片预览(viewerjs)
- 评分输入框(0-100)
- 评语文本框
- **交付物**: 教师可批改作业

### 第5阶段: 集成测试和上线准备

#### 任务017 - 端到端测试
- 场景1: 张老师发布作业 → 小明提交(准时) → 张老师批改85分
- 场景2: 小红逾期提交 → 显示红色标签
- 场景3: 张老师修改小明成绩为90分
- **交付物**: 所有场景通过

#### 任务018 - 性能验证
- 加载100个作业的列表,测试响应时间(目标<1秒)
- 上传5MB文件,测试上传时间(目标<10秒)
- **交付物**: 满足非功能需求

## 执行计划

### 第1周
- 并行组: 任务001、任务002、任务004、任务005
- 串行: 任务003(契约测试写完)

### 第2周
- 串行: 任务006 → 任务007 → 任务008(业务层)
- 并行启动: 任务012(文件上传,独立)

### 第3周
- 并行组B: 任务009、任务010(Controller层)
- 串行: 任务011、任务013

### 第4周
- 前端: 任务014 → 任务015 → 任务016
- 最后: 任务017、任务018(测试验证)

## 统计指标
- 总任务数: 18个
- 预计工期: 4周
- 可并行任务: 7个
- 关键路径: 任务002 → 任务003 → 任务004 → 任务006 → 任务009 → 任务014 → 任务017
```

### 步骤6: 运行质量门检查(关键!)

```bash
/speckit.analyze
```

**AI执行的检查**:

```markdown
# 规格分析报告

## 执行摘要
- 功能需求总数: 6个
- 非功能需求总数: 2个
- 任务总数: 18个
- 覆盖率: 100%(8/8需求都有对应任务)
- **CRITICAL问题: 1个**
- HIGH问题: 2个
- MEDIUM问题: 3个
- LOW问题: 1个

## ❌ CRITICAL问题(必须修复才能/implement)

| ID | 类别 | 严重性 | 位置 | 问题描述 | 建议 |
|----|------|--------|------|----------|------|
| C1 | 宪法违规 | CRITICAL | tasks.md第2阶段 | 违反第三条"测试先行原则": 任务006"实现HomeworkService"在任务003"契约测试"之前执行 | 调整依赖: 任务003必须在任务004-005之前,确保测试失败后再实现 |

## ⚠️ HIGH问题(强烈建议修复)

| ID | 类别 | 严重性 | 位置 | 问题描述 | 建议 |
|----|------|--------|------|----------|------|
| H1 | 覆盖度缺失 | HIGH | spec.md需求4 | "需修改"状态无对应任务 | 在ReviewService中添加`setNeedRevision()`方法 |
| H2 | 歧义 | HIGH | plan.md第3阶段 | "权限校验"没有说明失败后返回什么错误码 | 规定: 无权限返回403,带message"无权访问" |

## 📊 覆盖度详情

| 需求 | 有任务? | 任务ID | 备注 |
|------|--------|--------|------|
| 需求1: 作业发布 | ✅ | 任务006、任务009 | 完整覆盖 |
| 需求2: 学生提交 | ✅ | 任务007、任务010 | 完整覆盖 |
| 需求3: 教师批改 | ✅ | 任务008、任务011 | 完整覆盖 |
| 需求4: 状态管理 | ⚠️ | 任务007(部分) | 缺少"需修改"状态处理,见H1 |
| 需求5: 统计功能 | ✅ | 任务013 | 完整覆盖 |
| 需求6: 权限控制 | ✅ | 任务009-011 | 每个Controller都有 |
| 非功能1: 性能 | ✅ | 任务018 | 完整覆盖 |
| 非功能2: 数据安全 | ✅ | 宪法第四条自动执行 | 完整覆盖 |

## 🚨 宪法对齐问题

### 第三条违规(CRITICAL)
**位置**: tasks.md第2阶段
**问题**: 任务006"实现HomeworkService"依赖任务004(数据库),但应该依赖任务003(契约测试失败)
**宪法原文**: "禁止在测试已确认失败前编写实现代码"
**修复**: 调整任务依赖顺序为 任务003 → 任务004 → 任务006

## 📈 统计指标
- 需求覆盖率: 100%(8/8)
- 任务映射率: 94%(17/18,任务001为基础搭建)
- 歧义计数: 1(H2)
- 重复计数: 0
- CRITICAL问题: 1

## ⚙️ 下一步行动

### ❌ 阻塞: 不能执行/implement
**原因**: 1个CRITICAL问题(宪法违规)

### 必须修复:
1. **修复C1**: 调整tasks.md任务依赖顺序
   - 修改: 任务006依赖从`[依赖: 任务004]`改为`[依赖: 任务003]`
   - 理由: 契约测试必须先失败,才能开始实现

2. **解决H1**: 添加"需修改"状态处理
   - 在任务008中增加子任务: "实现setNeedRevision()方法"

### 修复后:
重新运行`/speckit.analyze`确认CRITICAL=0,然后执行`/speckit.implement`。
```

**用户响应**:

```
修复C1和H1
```

**AI自动修复tasks.md**:

```markdown
#### 任务003 [依赖: 任务002] - 编写契约测试
(内容不变)

#### 任务004 [依赖: 任务003] - 搭建MySQL  ← 修改: 添加依赖任务003
- docker-compose启动MySQL 8.0
- ...

#### 任务006 [依赖: 任务004, 任务003] - 实现HomeworkService  ← 修改: 明确依赖003
- ...

#### 任务008 [依赖: 任务004] - 实现ReviewService
- 创建ReviewMapper
- 实现批改: `reviewHomework(ReviewDTO dto)`
- 实现修改批改: `updateReview(Long reviewId, ReviewDTO dto)`
- **新增: 实现设置需修改: `setNeedRevision(Long submissionId, String reason)`**  ← 新增
- **交付物**: POST /api/review测试通过
```

**再次运行 `/speckit.analyze`**:

```bash
/speckit.analyze
```

```markdown
# 规格分析报告

## 执行摘要
- **CRITICAL问题: 0** ✅
- HIGH问题: 1(H2 - 错误码规范)
- MEDIUM问题: 3
- LOW问题: 1

## ⚙️ 下一步行动
✅ **准备就绪**: 无CRITICAL问题。HIGH/MEDIUM问题为改进项,不阻塞实现。

可以执行: `/speckit.implement`
```

### 步骤7: 执行实现(TDD方式生成代码)

```bash
/speckit.implement
```

**AI执行流程**(严格TDD):

```
[任务001] 创建项目结构...
✅ Maven项目创建成功,3个模块可编译

[任务002] 定义API契约...
✅ 从api-spec.yaml生成DTO: HomeworkDTO、SubmissionDTO、ReviewDTO

[任务003] 编写契约测试...
```java
@SpringBootTest
@AutoConfigureMockMvc
class HomeworkControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testPublishHomework_成功() throws Exception {
        HomeworkDTO dto = new HomeworkDTO()
            .setTitle("第三章练习题")
            .setContent("<p>完成第45-50页</p>")
            .setClassIds(Arrays.asList(1L, 2L))
            .setDeadline(LocalDateTime.of(2024, 6, 30, 23, 59));

        mockMvc.perform(post("/api/homework")
                .contentType(MediaType.APPLICATION_JSON)
                .content(JsonUtil.toJson(dto)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void testPublishHomework_标题为空_返回400() throws Exception {
        HomeworkDTO dto = new HomeworkDTO()
            .setContent("内容")
            .setDeadline(LocalDateTime.now().plusDays(1));

        mockMvc.perform(post("/api/homework")
                .contentType(MediaType.APPLICATION_JSON)
                .content(JsonUtil.toJson(dto)))
            .andExpect(status().isBadRequest());
    }
}
```
❌ 测试失败(预期) - Controller还未实现

[任务004] 搭建MySQL...
✅ Docker容器启动,表结构创建完成

[任务005] 初始化种子数据...
✅ 3个教师、30个学生、2个班级数据插入

[任务006] 实现HomeworkService...
```java
@Service
public class HomeworkServiceImpl implements HomeworkService {

    @Autowired
    private HomeworkMapper homeworkMapper;

    @Override
    public Long publishHomework(HomeworkDTO dto) {
        HomeworkEntity entity = new HomeworkEntity();
        BeanUtils.copyProperties(dto, entity);
        entity.setCreatedAt(LocalDateTime.now());

        homeworkMapper.insert(entity);
        return entity.getId();
    }

    @Override
    public List<HomeworkVO> listHomework(Long teacherId) {
        return homeworkMapper.selectList(
            new QueryWrapper<HomeworkEntity>()
                .eq("teacher_id", teacherId)
                .orderByDesc("created_at")
        ).stream()
         .map(this::toVO)
         .collect(Collectors.toList());
    }
}
```

[任务009] 实现HomeworkController...
```java
@RestController
@RequestMapping("/api/homework")
public class HomeworkController {

    @Autowired
    private HomeworkService homeworkService;

    @PostMapping
    public Result<Long> publishHomework(@Validated @RequestBody HomeworkDTO dto,
                                        @RequestAttribute Long teacherId) {
        Long id = homeworkService.publishHomework(dto);
        return Result.success(id);
    }

    @GetMapping("/list")
    public Result<List<HomeworkVO>> listHomework(@RequestAttribute Long teacherId) {
        List<HomeworkVO> list = homeworkService.listHomework(teacherId);
        return Result.success(list);
    }
}
```
✅ 任务003的测试现在通过了 - TDD循环完成

... (任务007-018类似的TDD循环)

[任务018] 性能验证...
✅ 加载100个作业列表耗时: 0.8秒(目标<1秒)
✅ 上传5MB图片耗时: 7秒(目标<10秒)

🎉 所有18个任务完成。功能已就绪可测试。
```

**最终交付物**:
- ✅ 完整可运行的"作业批改"功能
- ✅ 18个任务全部完成,所有测试通过
- ✅ 满足所有宪法原则(模块化、测试先行、数据安全)
- ✅ 前后端打通,教师和学生可实际使用

---

## 场景3: /analyze发现问题的真实案例

### 案例: 发现数据安全违规

假设在步骤6运行`/speckit.analyze`时发现:

```markdown
| ID | 类别 | 严重性 | 位置 | 问题描述 | 建议 |
|----|------|--------|------|----------|------|
| C2 | 宪法违规 | CRITICAL | plan.md数据模型 | 违反第四条"数据安全原则": student_id_card字段未加密 | 添加字段student_id_card_encrypted,存储AES加密后的数据 |
```

**修复流程**:

**步骤1: 判断问题层级**

这是`/speckit.plan`层级的问题(数据模型设计),需回退到`/speckit.plan`

**步骤2: 更新data-model.md**

```markdown
### 学生表(student) - 已修复

```sql
CREATE TABLE student (
  id BIGINT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  student_no VARCHAR(20) NOT NULL COMMENT '学号',
  -- 修改前: id_card VARCHAR(18) COMMENT '身份证号'
  id_card_encrypted VARCHAR(200) COMMENT '身份证号(AES-256加密)',  ← 修复
  phone_encrypted VARCHAR(200) COMMENT '手机号(AES-256加密)',     ← 修复
  class_id BIGINT NOT NULL,
  ...
);
```
```

**步骤3: 更新tasks.md**

```markdown
#### 任务005 - 初始化种子数据(已更新)
- 插入30个学生数据
- **新增: 使用AESUtil加密身份证号和手机号后存储**
- **新增: 配置加密密钥(从环境变量读取,不提交到Git)**
```

**步骤4: 重新运行 `/speckit.analyze`**

```bash
/analyze
```

```markdown
## 执行摘要
- **CRITICAL问题: 0** ✅
- 宪法第四条: 已合规

✅ 准备就绪,可执行 `/speckit.implement`
```

**关键**: `/speckit.analyze`像编译器,在"运行"前捕获安全隐患。

---

## 场景4: 需求变更快速响应

### 变更需求

产品经理提出:

```
需求变更: 希望支持作业的"优秀作业展示"功能,教师可以将批改后评分≥90的作业标记为"优秀",
          展示在班级公告栏,其他学生可以查看学习(但不显示学生姓名,只显示"优秀作业")
```

**SDD处理流程**:

**步骤1: 判断变更层级**

| 变更类型 | 影响层级 | 需要回退到 |
|---------|---------|-----------|
| 修改按钮颜色 | 实现细节 | `/speckit.implement` |
| 添加"is_excellent"字段 | 数据模型 | `/speckit.plan` |
| 新增"展示功能" | 功能定义 | `/speckit.specify` |
| 改变项目架构 | 项目DNA | `/speckit.constitution` |

**当前变更**: 新增功能 → 回退到 `/speckit.specify`

**步骤2: 更新spec.md**

```markdown
### 需求7: 优秀作业展示(新增)

教师可将评分≥90的作业标记为"优秀作业",展示在班级公告栏。

**功能细节**:
- 教师批改时可勾选"设为优秀作业"
- 班级公告栏显示优秀作业列表(按时间倒序)
- 学生可查看优秀作业内容,但不显示提交者姓名(显示"优秀作业示范")
- 教师可取消"优秀"标记

**验收标准**:
- 张老师批改小明作业95分,勾选"优秀"
- 初一(1)班学生小红在公告栏看到该作业,显示"优秀作业示范"
- 小红可查看作业图片,但看不到是谁提交的
```

**步骤3: 重新执行后续步骤**

```bash
/clarify  # AI可能问: 一个作业可以有多个优秀示范吗?
/plan     # AI更新plan.md,homework_submission表添加is_excellent字段
/tasks    # AI自动插入新任务
```

**AI生成的新任务**:

```markdown
#### 任务008.1 [依赖: 任务008] - 优秀作业标记功能
- ReviewService添加`markAsExcellent(Long submissionId)`方法
- homework_submission表添加is_excellent字段(0否1是)
- **交付物**: 教师可标记优秀作业

#### 任务019 [依赖: 任务008.1] - 优秀作业展示API
- 实现GET /api/excellent-homework/list?classId=1
- 返回数据脱敏: studentName字段改为"优秀作业示范"
- **交付物**: 前端可获取优秀作业列表

#### 任务020 [依赖: 任务019] - 前端公告栏页面
- Vue组件: ExcellentHomeworkList.vue
- 展示优秀作业(不显示学生信息)
- 点击可查看详情
- **交付物**: 学生可查看优秀作业
```

**步骤4: 运行/analyze**

```bash
/analyze
```

```markdown
## 执行摘要
- **CRITICAL问题: 0** ✅
- 新需求覆盖率: 100%(需求7有3个任务覆盖)

✅ 准备就绪: `/speckit.implement`
```

**步骤5: 增量实现**

```bash
/implement
```

AI只生成新增的任务008.1、任务019、任务020,不重新生成整个项目。

**耗时对比**:

| 阶段 | 传统开发 | SDD方式 |
|------|---------|---------|
| 更新PRD | 1小时 | 5分钟(编辑spec.md) |
| 设计评审 | 2小时 | 0分钟(自动) |
| 修改代码 | 4小时 | 15分钟(/implement) |
| 测试验证 | 2小时 | 自动(TDD) |
| **总计** | **9小时** | **20分钟** |
| **加速比** | - | **27倍** |

---

## 四、三大核心机制深度解析

### 4.1 Constitution宪法: 如何自动约束LLM行为

#### 宪法的九大类原则(以智慧课堂为例)

| 条款 | 内容 | 如何检测 | 违规后果 |
|------|------|---------|---------|
| **第一条: 模块优先** | 功能先做成独立Service | `/speckit.analyze`检测是否直接在Controller写业务逻辑 | CRITICAL错误 |
| **第二条: 接口清晰** | 统一Result<T>返回格式 | `/speckit.analyze`检测Controller返回值类型 | HIGH警告 |
| **第三条: 测试先行** | 先写测试后实现 | `/speckit.implement`检查任务顺序 | 拒绝生成代码 |
| **第四条: 数据安全** | 敏感信息加密存储 | `/speckit.analyze`检测是否有`_encrypted`字段 | CRITICAL错误 |
| **第七条: 简单性** | ≤3个Maven模块 | `/speckit.plan`生成时检查 | 需书面justification |
| **第八条: 反过度抽象** | 直接用MyBatis-Plus | `/speckit.analyze`检测是否有多余的Wrapper | 需justification |
| **第九条: 集成测试** | 用真实MySQL测试 | `/speckit.implement`检查测试配置 | 测试套件不通过 |

#### 宪法如何在/implement时自动执行

**示例: 第三条"测试先行"的执行**

1. **用户运行 `/speckit.implement`**
2. **AI读取宪法第三条**:
   ```
   禁止在以下步骤完成前编写实现代码:
   1. 契约测试已编写
   2. 测试已通过用户审查
   3. 测试已运行并确认失败
   ```
3. **AI强制执行TDD流程**:
   ```
   [任务003] 编写契约测试...

   @Test
   void testPublishHomework() {
       // 调用接口
       Result<Long> result = homeworkController.publishHomework(dto, 1L);
       // 断言
       assertEquals(200, result.getCode());
   }

   ❌ 测试失败(预期) - HomeworkService还未实现

   [等待用户确认...]

   用户: "测试写得很好,继续"

   // 现在AI才生成实现代码
   [任务006] 实现HomeworkService...
   ```

**传统AI编码** vs **宪法约束的AI编码**:

| 方面 | 传统AI | 宪法约束AI |
|------|--------|------------|
| 测试 | 事后补测试(或不测) | 强制测试先行 |
| 架构 | 随意创建模块 | ≤3个模块,超过需justification |
| 数据安全 | 可能明文存储 | 敏感字段必须加密,否则CRITICAL |
| 质量 | 依赖人工Review | `/speckit.analyze`自动检测违规 |

#### 如何为自己的项目定制宪法

**步骤1: 识别不可妥协的原则**

问自己:
- 什么技术决策错误会导致项目失败?
- 什么代码质量标准必须100%遵守?
- 什么架构原则不能因deadline牺牲?

**示例: 某金融支付项目的宪法**

```markdown
# 支付系统项目宪法

## 第一条: 幂等性原则(不可妥协)

所有写操作API必须:
1. 接受幂等键(idempotency-key请求头)
2. 重复请求返回相同结果,不重复扣款
3. 幂等键在Redis存储24小时

违规 = CRITICAL,阻止上线。

## 第二条: 审计日志强制

所有状态变更必须:
1. 记录操作人、时间、变更前/后值
2. 写入audit_log表(append-only)
3. 保留7年(监管要求)

违规 = CRITICAL,合规性不通过。

## 第三条: 金额精度

所有金额计算必须:
1. 使用BigDecimal,禁止float/double
2. 四舍五入到分(2位小数)
3. 单元测试覆盖边界值(0.01、-0.01、Max)

违规 = HIGH,需修复。

## 第四条: 性能预算

所有API必须:
1. P95延迟 < 200ms
2. P99延迟 < 500ms
3. 支持1000 QPS并发

违规 = HIGH,需性能优化任务。
```

**步骤2: 在/plan阶段定义检查关卡**

```markdown
### 第0阶段: 实现前检查

#### 幂等性关卡(第一条)
- [ ] 所有POST/PUT接口接受idempotency-key?
- [ ] Redis配置已就绪?
- [ ] 重复请求测试用例已写?

#### 审计关卡(第二条)
- [ ] audit_log表已创建?
- [ ] AOP切面已配置?

#### 金额精度关卡(第三条)
- [ ] pom.xml禁止引入Lombok(会生成float的builder)?
- [ ] 所有金额字段类型为BigDecimal?
```

**步骤3: /analyze自动执行检查**

```bash
/analyze
```

AI自动扫描:
```markdown
| ID | 类别 | 严重性 | 位置 | 问题 | 建议 |
|----|------|--------|------|------|------|
| C1 | 宪法违规 | CRITICAL | PaymentService.java:45 | 第三条违规: 使用double类型计算金额 | 改为BigDecimal |
| C2 | 宪法违规 | CRITICAL | tasks.md | 第二条违规: 无审计日志任务 | 添加任务: 实现审计AOP |
```

### 4.2 Template模板: 引导LLM生成高质量规格

#### 模板如何约束LLM输出

**问题**: 直接问LLM"帮我写个登录功能的PRD",会得到模糊的结果。

**传统Prompt**(低质量):
```
用户: 帮我写一个学生提交作业功能的需求文档

AI: 学生提交作业功能包括:
1. 学生登录后可以上传作业
2. 支持文件上传
3. 提交后教师可以看到

(问题: 太模糊,没有边界条件,没有错误处理)
```

**Template约束方式**(高质量):
```
用户: /specify 学生提交作业功能

AI: (读取 spec-template.md)

模板要求:
- ✅ 专注于做什么和为什么,不写怎么做
- ✅ 用[待确认]标记模糊点
- ✅ 包含边界情况
- ✅ 定义可测量的验收标准

生成的spec.md:

## 功能概述
**做什么**: 学生在线提交作业答案
**为什么**: 替代纸质提交,便于留存和批改

## 功能需求

### 需求1: 文件上传
学生可上传作业文件。

[待确认: 支持哪些文件格式? 图片、PDF还是Word?]
[待确认: 文件大小限制? 5MB还是10MB?]

## 边界情况

### 边界1: 上传超时
学生上传5MB文件,网络慢,30秒未完成。
**处理**: 前端显示"上传中"进度条,超过30秒提示"请检查网络"

### 边界2: 重复提交
学生提交后发现错误,想重新提交。
[待确认: 允许修改吗? 还是一次提交后锁定?]

## 非功能需求

### 性能要求
- 上传5MB文件在10秒内完成(正常网络)
- 支持50个学生同时上传

### 数据安全
- 作业文件存储在OSS,有访问权限控制
- 学生只能访问自己的作业,不能访问他人的
```

**对比**: 模板强制AI思考了:
1. ✅ 核心功能(需求1)
2. ✅ 边界情况(超时、重复提交)
3. ✅ 标记歧义(2个待确认点)
4. ✅ 性能指标(有具体数字: 10秒、50人)
5. ✅ 数据安全(权限控制)
6. ✅ 可测试性(验收标准明确)
7. ✅ 没有技术实现(没提OSS、MySQL)

#### [待确认]机制: 强制AI承认不确定性

**问题**: LLM倾向于"猜测"缺失信息,导致错误假设。

**解决**: 模板强制标记:

```markdown
创建规格时的规则:
1. **标记所有歧义点**: 使用[待确认: 具体问题]
2. **不要猜测**: 如果prompt没说,就标记
3. **提供选项**: 给出2-3个备选方案
```

**实战示例**:

用户prompt:
```
/specify 开发一个文件上传功能
```

AI生成(带待确认标记):
```markdown
## 需求1: 文件上传

用户可以上传文件。

[待确认: 支持哪些文件类型?]
- 方案A: 仅图片(jpg、png) - 适合作业提交
- 方案B: 文档(pdf、docx) - 适合资料分享
- 方案C: 任意文件(安全风险较高)

[待确认: 文件大小限制?]
- 方案A: 5MB(Web标准) - 适合图片
- 方案B: 10MB - 适合PDF
- 方案C: 100MB - 适合视频(需CDN支持)

[待确认: 存储在哪里?]
- 方案A: 本地服务器磁盘 - 简单,但不易扩展
- 方案B: 阿里云OSS/腾讯云COS - 推荐,可靠
- 方案C: 数据库BLOB字段 - 不推荐,性能差
```

**用户在 `/speckit.clarify` 阶段解决**:
```
用户: 文件类型选方案A(仅图片),大小选方案A(5MB),存储选方案B(OSS)
```

AI更新规格:
```markdown
### 需求1: 文件上传(已明确)

用户可上传图片文件(jpg、png格式),单个文件≤5MB,存储在阿里云OSS。
```

#### Phase Gates关卡: 自动质量检查

**定义**: 在`/speckit.plan`生成时,AI必须检查宪法的关卡。

**plan-template.md片段**:
```markdown
### 第0阶段: 实现前检查

#### 简单性关卡(第七条)
- [ ] 使用≤3个Maven模块?
  - 如果否: 在"复杂度跟踪"章节说明理由

#### 反过度抽象关卡(第八条)
- [ ] 直接使用框架?
  - 如果否: 说明为什么需要包装

#### 测试先行关卡(第三条)
- [ ] 契约测试在实现之前?
  - 必须是tasks.md的第0阶段
```

**AI执行 `/speckit.plan` 时的流程**:

```
[AI] 读取宪法...
[AI] 第七条: 最多3个Maven模块
[AI] 检查方案...
[AI] 发现: common、service、web、admin = 4个模块
[AI] ❌ 简单性关卡未通过
[AI] 写入plan.md:

### 第0阶段: 实现前检查

#### 简单性关卡(第七条)
- [❌] 使用≤3个Maven模块?
  **状态**: 未通过(4个模块)
  **理由**: admin模块需要单独的权限控制,不能和web模块混在一起
  **审批**: 待用户确认

[等待用户审查...]

用户: 去掉admin模块,初始版本不做后台管理

[AI] ✅ 更新plan.md,去掉admin模块,简单性关卡通过
```

### 4.3 Analyze质量门: 六种检测 + 四级严重性

#### /analyze的六种检测类型

**1. 重复检测(Duplication)**

检测相似或重复的需求。

**示例**:
```markdown
spec.md:
需求1: 学生可以上传作业图片
需求5: 系统支持学生提交图片作业

/analyze报告:
| D1 | 重复 | HIGH | 需求1 vs 需求5 | 两个需求描述相同功能 | 合并为需求1,删除需求5 |
```

**2. 歧义检测(Ambiguity)**

检测模糊形容词,无法测量的标准。

**示例**:
```markdown
spec.md:
非功能需求1: 系统应该快速响应

/analyze报告:
| A1 | 歧义 | HIGH | 非功能需求1 | "快速"无法测量 | 改为"API响应时间P95 < 200ms" |
```

**常见歧义词**: 快、慢、好、稳定、安全、流畅、直观

**3. 规格不足(Underspecification)**

检测缺少对象或结果的需求。

**示例**:
```markdown
spec.md:
需求3: 教师可以删除

/analyze报告:
| U1 | 规格不足 | MEDIUM | 需求3 | 缺少对象: 删除什么? | 改为"教师可以删除自己发布的作业" |
```

**4. 宪法对齐(Constitution Alignment)**

检测违反宪法原则。

**示例**:
```markdown
constitution.md:
第三条: 测试先行原则(不可妥协)

tasks.md:
阶段1: 任务001 - 实现HomeworkService
阶段2: 任务010 - 编写HomeworkService测试

/analyze报告:
| C1 | 宪法违规 | CRITICAL | tasks.md阶段1 | 违反第三条: 实现在测试之前 | 调整顺序: 任务010必须在任务001之前 |
```

**5. 覆盖度缺失(Coverage Gap)**

检测需求无对应任务,或任务无对应需求。

**示例**:
```markdown
spec.md:
非功能需求2: 系统必须支持100个学生同时提交作业

tasks.md:
(未找到并发测试任务)

/analyze报告:
| G1 | 覆盖度缺失 | CRITICAL | 非功能需求2 | 无任务覆盖并发测试 | 添加任务020: "JMeter压测100并发" |
```

**6. 一致性检查(Inconsistency)**

检测术语漂移,数据模型冲突。

**示例**:
```markdown
spec.md:
使用术语"作业状态"(未提交、已提交、已批改)

data-model.md:
字段名: homework_state(enum)

api-spec.yaml:
参数名: homeworkStatus(string)

/analyze报告:
| I1 | 不一致 | MEDIUM | spec/plan/contracts | 术语漂移: "状态"vs"state"vs"Status" | 统一为"status"(数据库、API、文档) |
```

#### 四级严重性分级

| 级别 | 定义 | 典型问题 | 如何处理 |
|------|------|---------|---------|
| **CRITICAL** | 违反宪法MUST条款,或核心功能零覆盖 | 测试先行未遵守、数据安全违规、主功能无任务 | **阻塞 `/speckit.implement`**,必须修复 |
| **HIGH** | 重复/冲突需求,安全/性能需求模糊 | 两个需求描述同一功能、非功能需求无指标 | 强烈建议修复,继续有风险 |
| **MEDIUM** | 术语漂移,非功能需求未覆盖 | status vs state不一致、文档与代码用词不同 | 建议修复,不影响功能 |
| **LOW** | 风格/措辞改进 | 任务ID格式不一致(T1 vs T001)、注释不规范 | 可选改进,不影响质量 |

#### /analyze的典型输出结构

```markdown
# 规格分析报告

## 执行摘要
- 功能需求: 6个
- 非功能需求: 2个
- 任务总数: 18个
- 覆盖率: 100%(8/8需求有任务)
- **CRITICAL问题: 1个**
- HIGH问题: 2个
- MEDIUM问题: 3个
- LOW问题: 1个

## ❌ CRITICAL问题(必须修复)

| ID | 类别 | 严重性 | 位置 | 问题描述 | 建议 |
|----|------|--------|------|----------|------|
| C1 | 宪法违规 | CRITICAL | tasks.md第2阶段 | 违反第三条: 任务006实现在任务003测试之前 | 调整依赖顺序 |

## ⚠️ HIGH问题(强烈建议)

| ID | 类别 | 严重性 | 位置 | 问题描述 | 建议 |
|----|------|--------|------|----------|------|
| H1 | 重复 | HIGH | 需求2 vs 需求7 | 都描述"学生提交作业" | 合并为需求2 |
| H2 | 歧义 | HIGH | 非功能需求1 | "系统应该安全"无标准 | 具体化: "通过等保三级认证" |

## 📊 覆盖度详情

| 需求 | 有任务? | 任务ID | 备注 |
|------|--------|--------|------|
| 需求1: 作业发布 | ✅ | 任务006、任务009 | 完整覆盖 |
| 需求2: 学生提交 | ✅ | 任务007、任务010 | 完整覆盖 |
| ...
| 非功能需求2: 并发性能 | ❌ | 无 | **缺失** - 见G1 |

## 🚨 宪法对齐问题

### 第三条违规(CRITICAL)
- ❌ 任务006"实现Service"在任务003"测试"之前
- ✅ 其他任务遵守TDD顺序

## 📈 统计指标
- 需求覆盖率: 88%(7/8)
- 任务映射率: 94%(17/18)
- 歧义计数: 1
- CRITICAL问题: 1

## ⚙️ 下一步行动

### ❌ 阻塞: 不能执行/implement
**原因**: 1个CRITICAL问题

### 必须修复:
1. **C1**: 调整tasks.md任务依赖
2. **G1**: 添加并发测试任务

### 修复后:
重新运行`/speckit.analyze`确认CRITICAL=0,然后执行`/speckit.implement`。
```

---

## 五、常见问题与解答

### Q1: AI生成的代码偏离了需求,如何更新规格?

**场景**: 运行`/speckit.implement`后发现AI生成的批改页面没有"批量批改"功能,现在想加。

**❌ 错误做法**:
```
直接告诉AI: "加一个批量批改按钮"
→ AI加了,但spec.md/plan.md没更新
→ 下次重新生成时又消失了
```

**✅ 正确做法**:

**步骤1: 判断变更层级**

"批量批改"是新功能需求 → 影响`/speckit.specify`层级

**步骤2: 回退到 `/speckit.specify`,更新spec.md**

```markdown
### 需求8: 批量批改(新增)

教师可一次批改多个学生的作业,提升效率。

**功能细节**:
- 作业列表页,教师可勾选多个"已提交"状态的作业
- 点击"批量批改"按钮,进入批量模式
- 逐个显示作业,教师快速给分和评语
- 支持键盘快捷键: Enter跳下一个,Ctrl+S保存

**验收标准**:
- 张老师勾选5个作业,进入批量模式
- 逐个批改,每个耗时10秒
- 5个作业批改完成,状态全部变为"已批改"
```

**步骤3: 重新执行后续流程**

```bash
/clarify  # AI可能问: 批量时能跳过某个作业吗?
/plan     # AI更新BatchReviewService
/tasks    # AI自动插入新任务
/analyze  # 检查一致性
/implement  # 生成批量批改功能
```

**关键原则**:

| 变更类型 | 回退到 | 示例 |
|---------|--------|------|
| UI样式 | `/speckit.implement` | 按钮颜色改蓝色 |
| 添加字段 | `/speckit.plan` | 作业表加difficulty字段 |
| 新增功能 | `/speckit.specify` | 添加批量批改 |
| 改核心逻辑 | `/speckit.specify` | 批改改用AI自动评分 |
| 架构变更 | `/speckit.constitution` | 改为微服务架构 |

### Q2: /analyze发现CRITICAL问题怎么办?

**场景**: 运行`/speckit.analyze`看到:

```markdown
## CRITICAL问题

| C1 | 宪法违规 | CRITICAL | tasks.md | 第三条违规: 任务010实现在任务009测试之前 |
```

**处理流程**:

**步骤1: 理解CRITICAL含义**

CRITICAL = **阻塞`/speckit.implement`的问题**,必须修复,否则:
- 违反项目宪法(不可妥协原则)
- 或导致核心功能无法实现

**步骤2: 评估影响范围**

```
任务009 - 编写HomeworkService单元测试
任务010 - 实现HomeworkService  ← 顺序错误
```

影响: 如果先实现再测试,违反TDD原则 → 宪法第三条

**步骤3: 修复tasks.md**

**修复前**:
```markdown
阶段1: 业务层
- 任务009 [可并行] - 编写HomeworkService测试
- 任务010 [可并行] - 实现HomeworkService  ← 错误!
```

**修复后**:
```markdown
阶段1: 业务层
- 任务009 [可并行] - 编写HomeworkService测试
- 任务010 [依赖: 任务009] - 实现HomeworkService  ← 添加依赖
```

**步骤4: 重新运行 `/speckit.analyze`**

```bash
/analyze
```

```markdown
## 执行摘要
- **CRITICAL问题: 0** ✅
- HIGH问题: 2

✅ 准备就绪: 可执行`/speckit.implement`
```

**关键**:
- ❌ 不要跳过CRITICAL直接实现
- ✅ 修复后必须重新`/speckit.analyze`确认
- ✅ 宪法违规永远是CRITICAL,无妥协

### Q3: 需求频繁变更,如何快速响应?

**场景**: 产品经理每周改需求,传统开发很痛苦。

**SDD解决方案: 规格是单一真相源**

**传统开发痛点**:
```
需求变更 → 更新PRD → 通知开发 → 手动改代码 → 重新测试 → 更新文档(常忘)
              ↓          ↓           ↓
           永远过时   漏改一处   文档与代码不符
```

**SDD方式**:
```
需求变更 → 更新spec.md → /plan → /tasks → /analyze → /implement
           (单一真相源)                               ↓
                                                 自动重新生成代码
```

**实战示例: 智慧课堂需求变更**

**第1周**: 初始需求
```
/specify 作业截止时间为固定时间点
```

**第2周**: 产品说要支持延期
```
# 编辑 spec.md

### 需求9: 截止时间延期(新增)

教师可以延长作业截止时间。

# 重新执行
/plan    # AI自动更新HomeworkService.extendDeadline()
/tasks   # AI自动添加任务: "实现延期功能"
/analyze
/implement  # 只重新生成HomeworkService,其他不变
```

**耗时**: 8分钟

**第3周**: 产品又说要支持针对单个学生延期
```
# 编辑 spec.md

### 需求9: 截止时间延期(更新)

教师可以延长作业截止时间:
- 全班延期: 所有学生的截止时间统一延长
- 单个学生延期: 为特定学生(如请假)单独延长

# 重新执行
/plan    # AI添加student_id参数
/tasks   # AI添加任务: "支持学生级延期"
/analyze
/implement
```

**耗时**: 10分钟

**关键优势**:
1. **单一真相源**: spec.md永远最新,代码从规格生成
2. **增量更新**: `/speckit.implement`只重新生成受影响的部分
3. **自动一致性**: `/speckit.analyze`确保规格+方案+任务+代码一致
4. **版本控制**: spec.md用Git跟踪,变更历史清晰

**对比耗时**:

| 任务 | 传统开发 | SDD方式 | 加速比 |
|------|---------|---------|-------|
| 添加延期功能 | 2小时 | 8分钟 | 15x |
| 支持学生级延期 | 3小时 | 10分钟 | 18x |
| 确保文档同步 | 1小时(常忘) | 0分钟(自动) | ∞ |

### Q4: 如何确保测试先行(Test-First)?

**场景**: 希望团队严格遵守TDD,但总有人先写代码。

**SDD解决方案: 宪法 + /analyze双重保障**

**机制1: 宪法强制**

```markdown
# constitution.md

## 第三条: 测试先行原则(不可妥协)

禁止在以下步骤完成前编写实现代码:
1. 契约测试已编写
2. 测试已通过评审
3. 测试已运行并确认失败(TDD红灯)

违规后果:
- /analyze报CRITICAL错误
- /implement拒绝生成代码
```

**机制2: tasks.md强制顺序**

```markdown
## 第0阶段: 契约和测试(永远最先)

#### 任务001 - 定义API契约
- 创建OpenAPI规范
- **交付物**: api-spec.yaml

#### 任务002 [依赖: 任务001] - 编写契约测试
- 测试所有端点
- **交付物**: 所有测试失败(红灯) ← 明确要求失败

#### 任务003 [依赖: 任务002] - 用户审查检查点
- 用户审查测试质量
- **交付物**: 用户明确批准

## 第1阶段: 实现(测试通过关卡后)

#### 任务004 [依赖: 任务003] - 实现API
- 让任务002的测试通过
- **交付物**: 所有测试变绿
```

**机制3: /implement执行逻辑**

```
AI内部逻辑:

def implement_task(task_id):
    if task_id == "任务004":  # 实现任务
        # 检查依赖
        if not is_completed("任务003"):
            raise Error("不能实现: 任务003(测试审查)未完成")

        # 检查测试状态
        test_results = run_tests("任务002")
        if test_results.status != "FAILED":
            raise Error("不能实现: 测试必须先失败(TDD红灯)")

        # 生成实现代码
        generate_implementation()

        # 验证测试变绿
        test_results = run_tests("任务002")
        if test_results.status != "PASSED":
            raise Error("实现不完整: 测试仍失败")

        return "✅ 任务004完成: 测试现在通过"
```

**实际执行流程**:

```bash
/implement

[任务001] 定义API契约...
✅ 创建api-spec.yaml

[任务002] 编写契约测试...
```java
@Test
void testPublishHomework_成功() {
    // 调用API
    Result<Long> result = client.post("/api/homework", dto);
    // 断言
    assertEquals(200, result.getCode());
}
```
运行测试...
❌ 10/10测试失败(预期 - TDD红灯)

[任务003] 等待用户审查...

用户: "测试写得很全面,批准"

[任务004] 实现API...
```java
@RestController
public class HomeworkController {
    @PostMapping("/api/homework")
    public Result<Long> publishHomework(@RequestBody HomeworkDTO dto) {
        Long id = homeworkService.publish(dto);
        return Result.success(id);
    }
}
```

运行测试...
✅ 10/10测试通过(TDD绿灯)
```

**如果有人试图跳过测试**:

```bash
/implement

[检查前置条件...]
❌ 错误: 宪法第三条违规

tasks.md显示:
- 任务010 [可并行] - 实现HomeworkService  ← 无测试依赖!

要求的结构:
- 任务009 - 编写HomeworkService测试
- 任务010 [依赖: 任务009] - 实现HomeworkService

必须: 修复tasks.md强制TDD顺序

运行 /analyze 查找所有违规。
```

---

## 六、最佳实践

### 1. 规格应该写到什么粒度?

**判断标准**:
- ✅ 可测试(testable)
- ✅ 无歧义(unambiguous)
- ❌ 不写实现(no HOW)

**粒度对比**:

| 粒度 | ❌ 太粗(不可测) | ✅ 恰当(可测试) | ❌ 太细(实现细节) |
|------|----------------|----------------|------------------|
| **功能需求** | "系统要快" | "API响应P95 < 200ms" | "用Redis缓存查询结果" |
| **用户操作** | "学生可提交作业" | "学生可上传jpg/png,≤5MB" | "前端用axios POST到/api/submission" |
| **错误处理** | "系统要健壮" | "网络超时30秒后提示重试" | "使用axios的timeout配置30000ms" |

**实战案例: 文件上传功能**

**❌ 太粗**:
```markdown
需求1: 学生可以上传文件
```
问题: 什么文件?多大?存哪?无法写测试。

**✅ 恰当**:
```markdown
需求1: 学生可上传作业图片

**功能细节**:
- 支持格式: jpg、png
- 文件大小: 单张≤5MB,最多9张
- 上传时限: 10秒内完成(正常网络)
- 成功后返回OSS地址

**验收标准**:
- 上传1张3MB的jpg图片 → 返回URL
- 上传6MB的图片 → 提示"文件过大"
- 上传.docx文件 → 提示"格式不支持"
```
可以写自动化测试了!

**❌ 太细**:
```markdown
需求1: 学生通过multipart/form-data POST到/api/file/upload上传图片

**实现细节**:
- 后端用MultipartFile接收
- 调用OSSUtil.upload()上传到阿里云
- 返回JSON: {"code":200,"data":"https://..."}
```
问题: 这是`/speckit.plan`的内容,不属于规格。

**判断方法**:

1. **能写测试吗?** 如果不能,太粗。
2. **有多种实现吗?** 如果只有一种,太细。
3. **换技术栈成立吗?** 如果不成立,太细。

### 2. 何时必须使用/clarify?

**必须使用**:
- ✅ spec.md有`[待确认]`标记
- ✅ AI生成的规格明显遗漏关键决策
- ✅ 在`/speckit.plan`之前强制执行

**不需要使用**:
- ❌ 规格已足够清晰(零`[待确认]`)
- ❌ 只是改改措辞(直接编辑spec.md)

**实战示例**:

```bash
# 步骤1: /specify生成规格
/specify 开发搜索功能,支持按关键词查找作业

# AI生成的规格包含:
[待确认: 搜索算法 - 精确匹配还是模糊搜索?]
[待确认: 搜索范围 - 只搜标题还是包括内容?]

# 步骤2: 必须运行/clarify
/clarify

AI: 发现2个待确认点。

问题1: 搜索算法
方案A: 精确匹配(LIKE '关键词') - 简单,但不友好
方案B: 模糊搜索(LIKE '%关键词%') - 推荐
方案C: 全文搜索(MySQL FULLTEXT或ES) - 复杂

用户选择: 方案B

AI: ✅ 更新规格 → "使用SQL模糊匹配(LIKE %keyword%)"

问题2: 搜索范围
方案A: 仅搜索标题 - 快
方案B: 标题+内容 - 推荐,体验好

用户选择: 方案B

AI: ✅ 更新规格 → "搜索字段: title、content"

所有待确认点已解决。可以执行 /plan。
```

### 3. /analyze的最佳使用时机

**强制运行**:
1. **After `/speckit.tasks`, before `/speckit.implement`**(最重要!)
2. **需求变更后** - 更新spec.md后运行
3. **Code review前** - 确保规格与代码一致

**可选运行**:
- After `/speckit.plan`: 检查方案是否覆盖所有需求
- 每周定期: 检查规格漂移

**实战案例1: 发现隐藏的覆盖度缺失**

```bash
# 你以为任务全覆盖了
/tasks

# 运行analyze
/analyze

报告:
| G1 | 覆盖度缺失 | CRITICAL | 非功能需求2 | "数据安全:敏感信息加密"无对应任务 |

# 你意识到: 哦对,加密忘了!
# 添加任务
任务025 - 实现AES-256加密工具类EncryptUtil

# 重新analyze
/analyze
✅ 覆盖率: 100%
```

**实战案例2: 早期发现术语不一致**

```bash
/analyze

报告:
| I1 | 不一致 | MEDIUM | spec vs plan | spec用"作业",plan用"homework" |

# 早期发现,容易修复
# 如果等到代码写完,改动范围巨大(表名、API、变量名...)
```

### 4. 如何制定好的宪法(Constitution)

**原则1: 不超过10条**

太多原则=没有原则。

**原则2: 每条都可自动检测**

如果`/speckit.analyze`检测不了,不是好原则。

**❌ 不可检测**:
```markdown
第五条: 代码应该优雅且易维护
```
问题: "优雅"和"易维护"无法量化。

**✅ 可检测**:
```markdown
第五条: 代码复杂度限制

所有方法必须:
- 圈复杂度 ≤ 10
- 最大嵌套层级 ≤ 3
- 方法长度 ≤ 50行

检测方式: /analyze阶段运行代码复杂度检查工具。
```

**原则3: 违规后果明确**

每条原则标注违规严重性。

**宪法模板**:

```markdown
## 第[N]条: [原则名称]

### 规则
[具体的、可测量的要求]

### 理由
[为什么有这个原则]

### 违规处理
- 严重性: CRITICAL / HIGH / MEDIUM
- 检测方式: /analyze如何检测
- 后果: 阻塞/警告/记录

### 例外情况
[什么情况可违反,需要什么审批]
```

**示例: 金融系统宪法**

```markdown
## 第一条: 金额精度原则

### 规则
所有金额计算必须:
1. 使用BigDecimal类型,禁止float/double
2. 四舍五入到分(setScale(2, RoundingMode.HALF_UP))
3. 单元测试覆盖边界值(0.01、-0.01、Long.MAX_VALUE)

### 理由
float/double存在精度丢失,可能导致资金差额,引发对账问题。

### 违规处理
- 严重性: CRITICAL
- 检测方式: /analyze扫描代码中的float/double字段
- 后果: 阻塞上线,必须修复

### 例外情况
无例外。金额精度不可妥协。
```

---

## 七、总结: SDD的核心价值

### 传统开发 vs SDD对比

| 维度 | 传统开发 | SDD方式 | 提升 |
|------|---------|---------|------|
| **真相源** | 代码(文档过时) | 规格文档 | 单一真相 |
| **需求变更** | 手工改代码+文档 | 更新规格重新生成 | 20-30x加速 |
| **质量保证** | 人工Code Review | 宪法+/analyze自动检测 | 自动化 |
| **测试先行** | 依赖自觉 | 强制TDD流程 | 100%遵守 |
| **一致性** | 经常不一致 | /analyze强制检测 | 0不一致 |
| **新人上手** | 需数月 | 遵循模板即可 | 周级上手 |

### SDD适合的项目

✅ **理想场景**:
- 新项目(从零开始)
- 需求频繁变更
- 团队3-20人
- 质量要求高(金融、医疗、教育)
- 需要快速试错

⚠️ **需要调整**:
- 遗留系统改造 - 需先"规格化"现有代码
- 超大型项目(>50人) - 需分层宪法

❌ **不适合**:
- 一次性脚本
- 纯前端UI调试

### 开始你的SDD之旅

**第1步: 安装Spec-Kit**

```bash
# 使用uv安装(推荐)
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 或使用uvx临时运行
uvx --from git+https://github.com/github/spec-kit.git specify init 我的项目
```

**第2步: 初始化项目**

```bash
specify init 智慧课堂 --ai claude
# 选择: 使用Claude Code作为AI助手
```

**第3步: 建立宪法**

```bash
/constitution 创建聚焦代码质量、测试标准和教育行业合规性的原则
```

**第4步: 开发第一个功能**

```bash
/specify 开发学生提交作业功能,支持上传图片和PDF
/clarify
/plan 使用Spring Boot + MyBatis-Plus + MySQL + 阿里云OSS
/tasks
/analyze  # 关键步骤!
/implement
```

**第5步: 加入社区**

- GitHub: https://github.com/github/spec-kit
- 提Issue分享你的实践经验
- 参与讨论SDD方法论改进

---

## 记住SDD的四个核心

1. **规格是真相,代码是表达**
   - 维护软件=演进规格
   - 调试=修复规格逻辑
   - 重构=重组规格结构

2. **宪法是基因,不可妥协**
   - 定义≤10条核心原则
   - 每条都可自动检测
   - 违规=CRITICAL,阻塞实现

3. **/analyze是质量门,CRITICAL必修**
   - 6种检测: 重复、歧义、覆盖度、宪法、一致性、术语
   - 4级严重性: CRITICAL阻塞,HIGH建议,MEDIUM改进,LOW可选
   - 在/tasks和/implement之间强制运行

4. **SDD不是线性,是递归循环**
   - 项目级/功能级/模块级/任务级
   - 每个层级都可执行完整SDD循环
   - 发现问题回退到合适层级,不是推倒重来

---

**开始用SDD开发你的下一个项目吧!** 🚀

> 本指南基于Spec-Kit项目,面向中国开发者编写。
> 最后更新: 2025年1月
> 欢迎反馈: https://github.com/github/spec-kit/issues
