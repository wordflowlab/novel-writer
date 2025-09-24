import * as fs from 'fs-extra'
import * as path from 'path'
import * as yaml from 'js-yaml'
import { logger } from '../utils/logger.js'

interface PluginConfig {
  name: string
  version: string
  description: string
  type: 'feature' | 'expert' | 'workflow'
  commands?: Array<{
    id: string
    file: string
    description: string
  }>
  experts?: Array<{
    id: string
    file: string
    title: string
    description: string
  }>
  dependencies?: {
    core: string
  }
  installation?: {
    files?: Array<{
      source: string
      target: string
      prefix?: string
    }>
    message?: string
  }
}

export class PluginManager {
  private pluginsDir: string
  private commandsDir: string
  private expertsDir: string

  constructor(projectRoot: string) {
    this.pluginsDir = path.join(projectRoot, 'plugins')
    this.commandsDir = path.join(projectRoot, '.claude', 'commands')
    this.expertsDir = path.join(projectRoot, 'experts')
  }

  /**
   * 扫描并加载所有插件
   */
  async loadPlugins(): Promise<void> {
    try {
      // 确保插件目录存在
      await fs.ensureDir(this.pluginsDir)

      // 扫描插件目录
      const plugins = await this.scanPlugins()

      if (plugins.length === 0) {
        logger.info('没有发现插件')
        return
      }

      logger.info(`发现 ${plugins.length} 个插件`)

      // 加载每个插件
      for (const pluginName of plugins) {
        await this.loadPlugin(pluginName)
      }

      logger.success('所有插件加载完成')
    } catch (error) {
      logger.error('加载插件失败:', error)
    }
  }

  /**
   * 扫描插件目录，返回所有插件名称
   */
  private async scanPlugins(): Promise<string[]> {
    try {
      const entries = await fs.readdir(this.pluginsDir, { withFileTypes: true })

      // 过滤出目录，并且包含config.yaml的
      const plugins = []
      for (const entry of entries) {
        if (entry.isDirectory()) {
          const configPath = path.join(this.pluginsDir, entry.name, 'config.yaml')
          if (await fs.pathExists(configPath)) {
            plugins.push(entry.name)
          }
        }
      }

      return plugins
    } catch (error) {
      logger.error('扫描插件目录失败:', error)
      return []
    }
  }

  /**
   * 加载单个插件
   */
  private async loadPlugin(pluginName: string): Promise<void> {
    try {
      logger.info(`加载插件: ${pluginName}`)

      // 读取插件配置
      const configPath = path.join(this.pluginsDir, pluginName, 'config.yaml')
      const config = await this.loadConfig(configPath)

      if (!config) {
        logger.warn(`插件 ${pluginName} 配置无效`)
        return
      }

      // 检查依赖
      if (!this.checkDependencies(config)) {
        logger.warn(`插件 ${pluginName} 依赖不满足`)
        return
      }

      // 注入命令
      if (config.commands && config.commands.length > 0) {
        await this.injectCommands(pluginName, config.commands)
      }

      // 注册专家
      if (config.experts && config.experts.length > 0) {
        await this.registerExperts(pluginName, config.experts)
      }

      logger.success(`插件 ${pluginName} 加载成功`)

      // 显示安装信息
      if (config.installation?.message) {
        console.log(config.installation.message)
      }
    } catch (error) {
      logger.error(`加载插件 ${pluginName} 失败:`, error)
    }
  }

  /**
   * 读取并解析插件配置
   */
  private async loadConfig(configPath: string): Promise<PluginConfig | null> {
    try {
      const content = await fs.readFile(configPath, 'utf-8')
      const config = yaml.load(content) as PluginConfig

      // 验证必要字段
      if (!config.name || !config.version) {
        return null
      }

      return config
    } catch (error) {
      logger.error(`读取配置文件失败: ${configPath}`, error)
      return null
    }
  }

  /**
   * 检查插件依赖
   */
  private checkDependencies(config: PluginConfig): boolean {
    if (!config.dependencies) {
      return true
    }

    // 检查核心版本依赖
    if (config.dependencies.core) {
      // 这里简化处理，实际应该比较版本号
      // 可以使用 semver 库进行版本比较
      const requiredVersion = config.dependencies.core
      logger.debug(`需要核心版本: ${requiredVersion}`)
      // TODO: 实现版本比较逻辑
    }

    return true
  }

  /**
   * 注入插件命令到.claude/commands目录
   */
  private async injectCommands(
    pluginName: string,
    commands: PluginConfig['commands']
  ): Promise<void> {
    if (!commands) return

    await fs.ensureDir(this.commandsDir)

    for (const cmd of commands) {
      try {
        const sourcePath = path.join(this.pluginsDir, pluginName, cmd.file)
        const destName = `plugin-${pluginName}-${cmd.id}.md`
        const destPath = path.join(this.commandsDir, destName)

        // 复制命令文件
        await fs.copy(sourcePath, destPath)
        logger.debug(`注入命令: /${cmd.id} -> ${destName}`)
      } catch (error) {
        logger.error(`注入命令 ${cmd.id} 失败:`, error)
      }
    }
  }

  /**
   * 注册插件专家
   */
  private async registerExperts(
    pluginName: string,
    experts: PluginConfig['experts']
  ): Promise<void> {
    if (!experts) return

    const pluginExpertsDir = path.join(this.expertsDir, 'plugins', pluginName)
    await fs.ensureDir(pluginExpertsDir)

    for (const expert of experts) {
      try {
        const sourcePath = path.join(this.pluginsDir, pluginName, expert.file)
        const destPath = path.join(pluginExpertsDir, `${expert.id}.md`)

        // 复制专家文件
        await fs.copy(sourcePath, destPath)
        logger.debug(`注册专家: ${expert.title} (${expert.id})`)
      } catch (error) {
        logger.error(`注册专家 ${expert.id} 失败:`, error)
      }
    }
  }

  /**
   * 列出所有已安装的插件
   */
  async listPlugins(): Promise<PluginConfig[]> {
    const plugins = await this.scanPlugins()
    const configs: PluginConfig[] = []

    for (const pluginName of plugins) {
      const configPath = path.join(this.pluginsDir, pluginName, 'config.yaml')
      const config = await this.loadConfig(configPath)
      if (config) {
        configs.push(config)
      }
    }

    return configs
  }

  /**
   * 安装插件（从模板或远程）
   */
  async installPlugin(pluginName: string, source?: string): Promise<void> {
    try {
      logger.info(`安装插件: ${pluginName}`)

      // 如果提供了源路径，从源复制
      if (source) {
        const destPath = path.join(this.pluginsDir, pluginName)
        await fs.copy(source, destPath)
      } else {
        // TODO: 实现从远程仓库或注册中心安装
        logger.warn('远程安装功能尚未实现')
        return
      }

      // 加载新安装的插件
      await this.loadPlugin(pluginName)
      logger.success(`插件 ${pluginName} 安装成功`)
    } catch (error) {
      logger.error(`安装插件 ${pluginName} 失败:`, error)
    }
  }

  /**
   * 移除插件
   */
  async removePlugin(pluginName: string): Promise<void> {
    try {
      logger.info(`移除插件: ${pluginName}`)

      // 删除插件目录
      const pluginPath = path.join(this.pluginsDir, pluginName)
      await fs.remove(pluginPath)

      // 删除注入的命令
      const commandFiles = await fs.readdir(this.commandsDir)
      for (const file of commandFiles) {
        if (file.startsWith(`plugin-${pluginName}-`)) {
          await fs.remove(path.join(this.commandsDir, file))
          logger.debug(`移除命令文件: ${file}`)
        }
      }

      // 删除注册的专家
      const pluginExpertsDir = path.join(this.expertsDir, 'plugins', pluginName)
      if (await fs.pathExists(pluginExpertsDir)) {
        await fs.remove(pluginExpertsDir)
        logger.debug(`移除专家目录: ${pluginExpertsDir}`)
      }

      logger.success(`插件 ${pluginName} 移除成功`)
    } catch (error) {
      logger.error(`移除插件 ${pluginName} 失败:`, error)
    }
  }

  /**
   * 更新插件
   */
  async updatePlugin(pluginName: string, source?: string): Promise<void> {
    logger.info(`更新插件: ${pluginName}`)

    // 先移除旧版本
    await this.removePlugin(pluginName)

    // 安装新版本
    await this.installPlugin(pluginName, source)
  }
}