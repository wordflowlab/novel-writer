# Novel Writer 文档

这个目录包含 Novel Writer 的文档源文件，使用 [DocFX](https://dotnet.github.io/docfx/) 构建。

## 文档结构

```
docs/
├── README.md              # 本文件
├── docfx.json            # DocFX 配置
├── toc.yml               # 目录配置
├── index.md              # 文档主页
├── installation.md       # 安装指南
├── quickstart.md         # 快速入门
├── workflow.md           # 创作流程
├── commands.md           # 斜杠命令详解 ⭐新增
├── writing-methods.md    # 写作方法详解 ⭐新增
├── best-practices.md     # 最佳实践指南 ⭐新增
├── upgrade-guide.md      # 升级指南
├── word-count-guide.md   # 字数统计指南
└── _site/                # 生成的文档（git忽略）
```

## 本地构建

### 安装 DocFX

1. 安装 .NET SDK：
   ```bash
   # macOS
   brew install dotnet-sdk

   # Windows
   # 从 https://dotnet.microsoft.com/download 下载安装

   # Linux
   sudo apt-get install dotnet-sdk-6.0
   ```

2. 安装 DocFX：
   ```bash
   dotnet tool install -g docfx
   ```

### 构建文档

1. 进入文档目录：
   ```bash
   cd docs
   ```

2. 构建并预览：
   ```bash
   docfx docfx.json --serve
   ```

3. 在浏览器访问 `http://localhost:8080` 查看文档。

## 编写指南

### Markdown 规范

- 使用标准 Markdown 语法
- 标题使用 `#` 符号，从 `#` 开始（H1）
- 代码块使用三个反引号 ``` 并指定语言
- 链接使用相对路径

### 中文写作规范

- 中英文之间加空格
- 使用中文标点符号
- 专有名词保持英文（如 Novel Writer、Git）
- 代码和命令使用英文

### 文档组织

#### 核心文档
1. **index.md** - 项目介绍和概览
2. **installation.md** - 详细的安装步骤
3. **quickstart.md** - 5分钟快速开始
4. **workflow.md** - 完整的创作流程

#### 参考文档（⭐新增）
5. **commands.md** - 所有斜杠命令的详细说明、参数和最佳实践
6. **writing-methods.md** - 6种经典写作方法详解（三幕结构、英雄之旅等）
7. **best-practices.md** - 实战经验、高级技巧和常见问题解决

#### 进阶文档
8. **upgrade-guide.md** - 版本升级说明和迁移指南
9. **word-count-guide.md** - 中文字数统计最佳实践

### 添加新文档

1. 创建 `.md` 文件
2. 在 `toc.yml` 中添加条目
3. 更新相关文档的链接

## 自动部署

文档通过 GitHub Actions 自动部署到 GitHub Pages：

1. 推送到 `main` 分支时触发
2. 自动构建文档
3. 部署到 `gh-pages` 分支
4. 访问 https://wordflowlab.github.io/novel-writer/

## 贡献文档

欢迎贡献文档！请：

1. Fork 仓库
2. 创建分支：`git checkout -b docs/your-feature`
3. 编写或修改文档
4. 本地预览确认
5. 提交 PR

## 文档规范检查

运行检查：
```bash
# Markdown lint
npm install -g markdownlint-cli
markdownlint docs/*.md

# 拼写检查
npm install -g cspell
cspell docs/*.md
```

## 常见问题

### Q: DocFX 构建失败

确保：
- 安装了正确版本的 .NET SDK
- DocFX 已全局安装
- 在 docs 目录下运行命令

### Q: 中文显示乱码

确保：
- 文件编码为 UTF-8
- 浏览器编码设置正确
- DocFX 配置中设置了 `"_lang": "zh-CN"`

### Q: 图片不显示

确保：
- 图片放在 `images/` 目录
- 使用相对路径引用
- 文件名不含中文和空格

## 相关链接

- [DocFX 文档](https://dotnet.github.io/docfx/)
- [Markdown 指南](https://www.markdownguide.org/)
- [Novel Writer 主页](https://github.com/wordflowlab/novel-writer)

---

📝 文档持续更新中，欢迎提出建议和改进！