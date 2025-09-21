# 本地开发指南

本指南介绍如何在本地开发和测试 Novel Writer，无需发布版本或提交到主分支。

## 1. 克隆和分支管理

```bash
git clone https://github.com/wordflowlab/novel-writer.git
cd novel-writer
# 在功能分支上工作
git checkout -b feature/your-feature
```

## 2. 环境设置

### 2.1 Python 环境

```bash
# 使用 uv 创建虚拟环境（推荐）
uv venv
source .venv/bin/activate  # macOS/Linux
# Windows PowerShell: .venv\Scripts\Activate.ps1

# 安装依赖
uv pip install -e .
```

### 2.2 Node.js 环境（用于工具链）

```bash
# 安装 Node.js 依赖
npm install

# 或使用 yarn
yarn install
```

## 3. 直接运行 CLI（最快反馈）

无需安装即可直接运行 CLI：

```bash
# 从仓库根目录
python -m src.novel_cli --help
python -m src.novel_cli style my-novel --genre fantasy --ai claude
```

或使用脚本文件方式：

```bash
python src/novel_cli/__init__.py story my-novel --plot adventure
```

## 4. 使用可编辑安装（隔离环境）

创建隔离环境，确保依赖解析与用户环境一致：

```bash
# 创建并激活虚拟环境
uv venv
source .venv/bin/activate

# 可编辑模式安装
uv pip install -e .

# 现在 'novel' 命令可用
novel --help
novel style my-book --genre scifi
```

代码修改后无需重新安装（可编辑模式）。

## 5. 使用 uvx 直接从 Git 运行

### 5.1 从本地路径运行

```bash
uvx --from . novel outline my-story --chapters 10
```

### 5.2 从特定分支运行（无需合并）

```bash
# 先推送工作分支
git push origin feature/your-feature

# 从分支运行
uvx --from git+https://github.com/wordflowlab/novel-writer.git@feature/your-feature novel write chapter-1
```

### 5.3 绝对路径运行（从任何位置）

```bash
# 使用绝对路径
uvx --from /Users/yourname/dev/novel-writer novel --help

# 设置环境变量便于使用
export NOVEL_SRC=/Users/yourname/dev/novel-writer
uvx --from "$NOVEL_SRC" novel style my-book

# 定义 shell 函数（可选）
novel-dev() { uvx --from /Users/yourname/dev/novel-writer novel "$@"; }
novel-dev --help
```

## 6. 测试脚本权限

### POSIX 系统（macOS/Linux）

```bash
# 检查脚本可执行权限
ls -l scripts/*.sh
# 期望看到 -rwxr-xr-x

# 必要时添加执行权限
chmod +x scripts/*.sh
```

### Windows 系统

Windows 使用 `.ps1` 脚本，无需 chmod。

## 7. 运行测试

```bash
# 运行所有测试
pytest

# 运行特定测试
pytest tests/test_style.py

# 带覆盖率运行
pytest --cov=src --cov-report=html
```

## 8. 代码质量检查

```bash
# Python 代码检查
ruff check src/
black --check src/
mypy src/

# Markdown 文档检查
markdownlint docs/*.md

# 拼写检查
cspell docs/*.md specs/**/*.md
```

## 9. 构建本地包（可选）

验证打包配置：

```bash
# 构建 wheel
uv build
ls dist/

# 在新环境中测试安装
cd /tmp
uv venv test-env
source test-env/bin/activate
pip install /path/to/novel-writer/dist/*.whl
novel --help
```

## 10. 使用临时工作空间

测试初始化命令时创建临时空间：

```bash
# 创建临时目录
mkdir -p /tmp/novel-test && cd /tmp/novel-test

# 测试初始化
novel style test-novel --genre romance --ai gemini

# 查看生成的结构
tree -L 2
```

## 11. 调试网络问题

如果遇到网络或 TLS 问题：

```bash
# 跳过 TLS 验证（仅用于本地测试）
novel style my-book --skip-tls

# 使用代理
export HTTP_PROXY=http://localhost:8080
export HTTPS_PROXY=http://localhost:8080
novel write --api-endpoint http://localhost:8000
```

## 12. 快速迭代总结

| 操作 | 命令 |
|------|------|
| 直接运行 CLI | `python -m src.novel_cli --help` |
| 可编辑安装 | `uv pip install -e .` 然后 `novel ...` |
| 本地 uvx 运行（仓库根目录） | `uvx --from . novel ...` |
| 本地 uvx 运行（绝对路径） | `uvx --from /path/to/novel-writer novel ...` |
| Git 分支 uvx | `uvx --from git+URL@branch novel ...` |
| 构建 wheel | `uv build` |
| 运行测试 | `pytest` |
| 代码检查 | `ruff check src/` |

## 13. 清理构建产物

快速清理构建和虚拟环境：

```bash
# 清理 Python 构建产物
rm -rf .venv dist build *.egg-info

# 清理 Node.js 依赖
rm -rf node_modules

# 清理生成的文档
rm -rf docs/_site

# 清理测试覆盖率报告
rm -rf htmlcov .coverage
```

## 14. 常见问题

| 问题 | 解决方案 |
|------|---------|
| `ModuleNotFoundError: typer` | 运行 `uv pip install -e .` |
| 脚本无法执行（Linux/Mac） | 运行 `chmod +x scripts/*.sh` |
| Git 步骤被跳过 | 检查是否传递了 `--no-git` 或 Git 未安装 |
| API 连接失败 | 检查 API key 配置和网络连接 |
| 中文显示乱码 | 确保终端使用 UTF-8 编码 |
| 文档构建失败 | 确保安装了 DocFX 和 .NET SDK |

## 15. 开发工作流

### 15.1 功能开发流程

1. 创建功能分支
2. 编写测试（TDD）
3. 实现功能
4. 本地测试
5. 代码审查
6. 提交 PR

### 15.2 文档开发流程

1. 编辑文档文件
2. 本地预览：`docfx docs/docfx.json --serve`
3. 检查链接和格式
4. 提交更改

### 15.3 发布流程

1. 更新版本号（`src/__version__.py`）
2. 更新 CHANGELOG.md
3. 创建标签：`git tag v1.0.0`
4. 推送标签：`git push origin v1.0.0`
5. GitHub Actions 自动发布

## 16. 与 AI 工具集成

### 16.1 Claude Code

```bash
# 在项目根目录创建 .claude 配置
echo '{"ai_provider": "claude"}' > .claude/config.json
```

### 16.2 GitHub Copilot

```bash
# 配置 Copilot 忽略规则
echo "specs/" >> .copilotignore
echo "*.generated.py" >> .copilotignore
```

### 16.3 Cursor

```bash
# 配置 Cursor 设置
echo '{"ai_model": "gpt-4"}' > .cursor/settings.json
```

## 17. 性能分析

```bash
# CPU 性能分析
python -m cProfile -o profile.stats src/novel_cli/__init__.py write chapter-1
python -m pstats profile.stats

# 内存分析
python -m memory_profiler src/novel_cli/__init__.py style my-book
```

## 18. 下一步

- 阅读[贡献指南](CONTRIBUTING.md)了解代码规范
- 查看[架构文档](architecture.md)理解系统设计
- 参考[API 文档](api.md)了解接口规范
- 加入[开发者社区](https://github.com/wordflowlab/novel-writer/discussions)

---

💡 **提示**：开发过程中遇到问题？查看 [FAQ](faq.md) 或在 [Issues](https://github.com/wordflowlab/novel-writer/issues) 中提问。