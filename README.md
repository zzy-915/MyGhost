# 开源技术博客系统（Ghost 二次开发）

> 基于 Ghost v6.62.0 开源博客系统的二次开发实验，新增文章收藏/稍后阅读列表功能，支持本地运行和完整演示。

## 项目简介

本项目以成熟开源项目 [Ghost](https://github.com/TryGhost/Ghost) 为基线，完成可辨识的二次开发。在不修改 Ghost 核心代码的前提下，通过自定义主题实现了**文章收藏/稍后阅读列表**功能，用户可一键收藏感兴趣的文章，在专门的收藏列表页查看和管理，数据存储在浏览器本地，无需登录即可使用。

## 目标用户与问题场景

| 角色 | 场景 | 需求 |
|------|------|------|
| 博客读者 | 浏览文章时发现好文章但没时间读 | 一键收藏，稍后阅读 |
| 博客读者 | 想回顾之前看过的有用文章 | 收藏列表集中管理 |
| 管理员 | 发布和管理技术文章 | 完整的内容管理后台 |
| 会员 | 评论和互动 | 会员注册、登录、评论 |

## 功能清单

### 上游基线功能（Ghost 原生）
- [x] 会员注册/登录
- [x] 文章发布、编辑、删除
- [x] 标签管理与按标签浏览
- [x] 会员评论
- [x] 关键词搜索（命中与无结果提示）
- [x] 管理后台
- [x] 响应式主题

### 自主扩展功能（本人二次开发）
- [x] **文章收藏按钮**：文章详情页一键收藏/取消收藏
- [x] **收藏入口**：导航栏"我的收藏"链接 + 实时数量角标
- [x] **收藏列表页**：`/bookmarks/` 独立页面，展示所有已收藏文章
- [x] **移除收藏**：收藏列表中可单篇移除
- [x] **本地存储**：localStorage 存储，刷新不丢失，无需登录
- [x] **空状态提示**：无收藏时显示友好引导
- [x] **操作反馈**：toast 提示收藏/取消成功
- [x] **上限保护**：最多 500 条，防止存储溢出
- [x] **响应式设计**：桌面和移动端均可用

## 技术栈与系统架构

### 技术栈

| 层级 | 技术 | 版本 | 说明 |
|------|------|------|------|
| 后端服务 | Node.js + Express | v22.23.2 | Ghost 核心，不修改 |
| 数据库 | SQLite | 随 Ghost 安装 | 本地开发环境 |
| 管理后台 | Ember.js | 随 Ghost 安装 | Ghost Admin，不修改 |
| 前端主题 | Handlebars + CSS + 原生 JS | - | 自定义主题，本人修改 |
| 收藏存储 | localStorage | - | 浏览器本地，自主实现 |
| 版本管理 | Git | 2.55.0 | 个人实验仓库 |
| 进程管理 | Ghost CLI | 1.32.3 | Ghost 安装/启动/停止 |

### 系统架构图

![项目总体架构图](docs/images/architecture.png)

### 关键目录

```
oss-blog/
├── runtime/                    # Ghost 运行目录（不提交数据）
│   ├── content/
│   │   ├── themes/            # 已安装主题
│   │   │   └── source/        # 当前激活主题（已集成收藏功能）
│   │   ├── data/              # SQLite 数据库（.gitignore 排除）
│   │   └── logs/              # 日志（.gitignore 排除）
│   └── config.development.json
├── theme/
│   └── oss-blog-theme/        # 自定义主题源码（本人开发）
│       ├── assets/
│       │   ├── js/bookmark.js # 收藏功能核心逻辑（原创）
│       │   └── css/bookmark.css # 收藏功能样式（原创）
│       ├── default.hbs        # 修改：导航收藏入口
│       ├── post.hbs           # 修改：文章收藏按钮
│       ├── page.hbs           # 修改：收藏列表页
│       └── page-bookmarks.hbs # 新增：收藏列表模板
├── docs/
│   ├── baseline.md             # 基线记录
│   ├── architecture.md         # 架构分析
│   ├── issues/                 # Issue 跟踪记录
│   ├── pr/                     # PR 和 Code Review 记录
│   ├── export/                 # 数据导出与备份
│   └── 实验报告.md             # 实验报告
├── tests/
│   └── acceptance.md           # 功能测试验收记录
├── scripts/
│   ├── start.ps1               # 一键启动脚本
│   └── stop.ps1                # 一键停止脚本
├── .gitignore
├── NOTICE.md                   # 第三方代码与许可证声明
└── README.md                   # 本文件
```

## 环境要求与版本检查

### 系统要求
- Windows 11 / Linux / macOS（当前实验环境：Windows 11）
- 至少 2GB 可用内存
- 端口 2368 未被占用

### 软件版本

| 工具 | 要求版本 | 检查命令 | 本实验版本 |
|------|----------|----------|------------|
| Node.js | 22 LTS | `node --version` | v22.23.2 |
| npm | 10+ | `npm --version` | 10.x |
| Git | 2.40+ | `git --version` | 2.55.0 |
| Ghost CLI | 1.32+ | `ghost --version` | 1.32.3 |
| Ghost | 6.62.0（固定） | `ghost version` | 6.62.0 |

### 端口检查

```powershell
Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
```

如果有输出，说明端口被占用，需要先停止占用进程或修改 Ghost 端口。

## 安装与运行

### 1. 克隆项目

```bash
git clone <your-repo-url> oss-blog
cd oss-blog
```

### 2. 安装 Ghost CLI

```bash
npm install -g ghost-cli@latest
ghost --version
```

### 3. 安装 Ghost 运行时

```bash
cd runtime
ghost install local
```

> 注意：`ghost install local` 会自动下载并安装最新版 Ghost。如果需要固定版本，可在安装后执行 `ghost update --v6.62.0` 或手动修改 package.json。

### 4. 配置

实验使用 SQLite 和端口 2368，配置文件 `runtime/config.development.json`：

```json
{
  "url": "http://localhost:2368",
  "server": {
    "port": 2368,
    "host": "127.0.0.1"
  },
  "database": {
    "client": "sqlite3",
    "connection": {
      "filename": "content/data/ghost-dev.db"
    }
  },
  "mail": {
    "transport": "Direct"
  },
  "logging": {
    "transports": ["file", "stdout"]
  },
  "process": "local",
  "paths": {
    "contentPath": "D:/demo/oss-blog/runtime/content"
  }
}
```

### 5. 启动与停止

**一键启动（推荐）：**
```powershell
.\scripts\start.ps1
```

**手动启动：**
```bash
cd runtime
ghost start
```

**一键停止：**
```powershell
.\scripts\stop.ps1
```

**手动停止：**
```bash
cd runtime
ghost stop
```

**查看状态：**
```bash
cd runtime
ghost ls
```

### 6. 初始化管理员

首次启动后，访问 http://localhost:2368/ghost/ 完成管理员初始化：
- 设置站点标题、管理员姓名、邮箱、密码

> 注意：Ghost 密码策略要求至少 10 位，包含大小写字母和数字。

### 7. 安装自定义主题

```bash
# 将主题复制到 Ghost 主题目录
cp -r theme/oss-blog-theme runtime/content/themes/

# 或在管理后台上传主题压缩包
# 管理后台 → 设置 → 主题 → 上传主题
```

然后在管理后台 → 设置 → 主题 中激活 `oss-blog-theme`。

> 注意：本实验中收藏功能已集成到当前激活的 `source` 主题中，自定义主题 `oss-blog-theme` 为源码参考。

## 演示账号

| 角色 | 邮箱 | 密码 | 说明 |
|------|------|------|------|
| 管理员 | admin@lab.local | Admin@123456 | 管理后台全部权限 |
| 会员1 | member1@lab.local | Member@123456 | 普通会员，可评论 |
| 会员2 | member2@lab.local | Member@123456 | 普通会员，可评论 |

> 说明：Ghost 密码策略要求至少 10 位，无法使用纯 6 位数字 123456，故采用 `Admin@123456` / `Member@123456` 格式。

## 演示数据

### 文章（8篇）

| 序号 | 标题 | 标签 |
|------|------|------|
| 1 | 深入理解JavaScript闭包与作用域链 | 前端开发 |
| 2 | Node.js性能优化实战 | 后端开发 |
| 3 | 开源项目贡献指南 | 开源实践 |
| 4 | Vue3 Composition API深度解析 | 前端开发 |
| 5 | Spring Boot微服务架构设计 | 后端开发 |
| 6 | Git高级用法rebase/cherry-pick | 开源实践 |
| 7 | TypeScript类型体操进阶 | 前端开发 |
| 8 | Docker容器化部署最佳实践 | 后端开发 |

### 标签（3个）
- 前端开发 (frontend)
- 后端开发 (backend)
- 开源实践 (opensource)

### 页面（2个）
- About - 关于页面
- 我的收藏 (/bookmarks/) - 收藏列表页

## 完整 Demo 流程

### 流程一：基础功能演示（5分钟）

1. **访问前台**：打开 http://localhost:2368/，查看文章列表
2. **搜索文章**：点击搜索按钮，输入"JavaScript"，验证搜索结果
3. **浏览文章**：点击任意文章，查看文章详情
4. **会员登录**：点击"登录"，使用 member1@lab.local 登录
5. **发表评论**：在文章底部发表评论
6. **标签浏览**：点击文章标签，查看同标签文章列表

### 流程二：自主功能演示（收藏功能，3分钟）

1. **收藏文章**：在文章详情页点击"收藏"按钮，观察按钮变为"已收藏"，导航栏角标+1
2. **查看收藏列表**：点击导航栏"我的收藏"，进入 /bookmarks/ 页面，查看已收藏文章
3. **移除收藏**：在收藏列表中点击"移除收藏"，观察文章消失，角标-1
4. **空状态**：移除所有收藏后，显示"还没有收藏任何文章"提示
5. **刷新验证**：收藏文章后刷新页面，验证收藏状态保持

### 流程三：管理后台演示（2分钟）

1. **登录管理后台**：访问 http://localhost:2368/ghost/，使用管理员账号登录
2. **发布文章**：新建文章，输入标题和内容，选择标签，发布
3. **前台验证**：返回前台，验证新文章已显示
4. **数据导出**：设置 → 实验室 → 导出内容，下载 JSON 备份

## 测试方法与结果

### 运行测试

本实验采用手动验收测试，测试用例和结果记录在 `tests/acceptance.md`。

```bash
# 查看测试记录
cat tests/acceptance.md
```

### 测试统计

| 测试类型 | 用例数 | 通过 | 失败 | 通过率 |
|----------|--------|------|------|--------|
| 功能测试 | 8 | 8 | 0 | 100% |
| 权限测试 | 4 | 4 | 0 | 100% |
| 界面测试 | 4 | 4 | 0 | 100% |
| 恢复测试 | 2 | 2 | 0 | 100% |
| **合计** | **18** | **18** | **0** | **100%** |

### 已知问题与限制

1. **收藏数据不跨设备同步**：收藏数据存储在浏览器 localStorage，不同浏览器/设备间不共享。这是设计决策，简化实现并保护隐私。
2. **中文搜索分词有限**：Ghost 原生搜索基于 SQLite LIKE，中文长关键词命中率可能降低。建议使用关键词或英文术语搜索。
3. **自定义主题激活问题**：oss-blog-theme 主题通过 API 激活时遇到回退问题，实际功能集成在 source 主题中。主题源码完整保留，可手动安装。
4. **会员密码策略**：Ghost 要求密码至少 10 位，无法使用纯 6 位数字 123456。

## 二次开发内容（与上游基线的差异）

### 上游基线
- Ghost v6.62.0 原生功能
- source 主题（Ghost 官方主题）
- 无收藏功能

### 本人改造

| 类型 | 文件 | 改动说明 |
|------|------|----------|
| 新增 | `assets/js/bookmark.js` | 收藏功能核心逻辑，约 250 行，原创代码 |
| 新增 | `assets/css/bookmark.css` | 收藏功能样式，约 150 行，原创代码 |
| 新增 | `page-bookmarks.hbs` | 收藏列表页模板 |
| 修改 | `default.hbs` | 引入 bookmark.css/js，导航栏添加收藏入口 |
| 修改 | `post.hbs` | 文章详情页添加收藏按钮 |
| 修改 | `page.hbs` | 收藏页面内容渲染 |
| 修改 | `partials/components/navigation.hbs` | 导航栏添加"我的收藏"链接和角标 |

### 设计决策

**为什么在主题层实现，而不是修改 Ghost 核心？**
1. **升级边界**：Ghost 核心升级不会覆盖主题修改，收藏功能持续可用
2. **可移植性**：主题可以打包安装到其他 Ghost 实例
3. **低风险**：不涉及数据库迁移、后端 API 变更，出问题不影响核心功能
4. **符合实验要求**：实验明确推荐"在独立主题或伴随服务中做二次开发"

## 个人开发记录与贡献证据

### Git 提交历史

```
*   Merge PR #1: feat(theme) add bookmark/read-later feature
|\
| * docs: add PR #1 record and code review
| * feat(theme): add bookmark/read-later feature with localStorage
|/
* docs: add issue tracking for theme, search, backup and bookmark
* docs: add baseline evidence and architecture analysis
* chore: init project skeleton with .gitignore
```

### 分支策略
- `main`：主分支，稳定版本
- `feature/blog-enhancement`：功能开发分支，已合并

### Pull Request
- **PR #1**：`feature/blog-enhancement` → `main`
- 关联 Issue：#1（主题改造）、#4（自主功能-收藏）
- Code Review：6 大类检查清单，发现并修复 4 个问题
- 详细记录：`docs/pr/PR-001-bookmark-feature.md`

### Issue 跟踪
- Issue #1：主题改造与自定义主题开发
- Issue #2：搜索验收与中文关键词验证
- Issue #3：内容导出、备份与恢复验证
- Issue #4：自主功能 - 文章收藏/稍后阅读列表
- 详细记录：`docs/issues/`

### 版本标签
- `v1.0-lab`：实验交付版本

## 上游项目与第三方资源

### 上游项目

| 项目 | 仓库 | 版本 | 许可证 | 用途 |
|------|------|------|--------|------|
| Ghost | https://github.com/TryGhost/Ghost | v6.62.0 | MIT | 博客系统核心 |
| Ghost source 主题 | 随 Ghost 安装 | v1.7.3 | MIT | 主题基线 |

### 第三方资源

| 资源 | 来源 | 许可证 | 用途 |
|------|------|--------|------|
| 文章内容 | 本人原创 | - | 演示数据 |
| 收藏图标 | Lucide Icons (内联 SVG) | ISC | 收藏按钮和导航图标 |
| 其他主题资源 | Ghost source 主题 | MIT | 主题基线文件 |

### 许可证声明

本项目基于 Ghost（MIT 许可证）二次开发。本人新增的收藏功能代码（bookmark.js、bookmark.css）为原创代码，采用 MIT 许可证。详细声明见 `NOTICE.md`。

## 安全注意事项

### 敏感配置处理
- 数据库文件、日志、密钥不提交到 Git（已在 `.gitignore` 中排除）
- 配置文件 `config.development.json` 不包含明文密码
- 管理员和会员密码在数据库中为 bcrypt 哈希存储
- 导出文件中的会员密码为哈希值，非明文

### 收藏功能安全
- 收藏数据仅存储在用户浏览器 localStorage，不上传服务器
- 不收集用户行为数据
- 使用 `textContent` 而非 `innerHTML` 插入文章数据，防止 XSS
- 有存储上限保护（500条），防止 localStorage 溢出

### 生产环境建议
- 使用 MySQL/PostgreSQL 替代 SQLite
- 配置 HTTPS
- 使用强密码和定期轮换
- 定期备份数据库
- 关闭开发模式的详细错误输出

## 主要功能截图

截图目录：`docs/screenshots/`

| 截图 | 说明 |
|------|------|
| baseline/admin-dashboard.png | 管理后台仪表盘 |
| baseline/frontend-home.png | 前台首页 |
| bookmark/bookmark-button.png | 文章页收藏按钮 |
| bookmark/bookmark-list.png | 收藏列表页 |
| bookmark/bookmark-empty.png | 空收藏状态 |
| search/search-result.png | 搜索结果 |
| theme/desktop-layout.png | 桌面端布局 |
| theme/mobile-layout.png | 移动端布局 |

> 截图需在演示时现场截取，以上为参考路径。

## 实验追加信息

### Ghost CLI 版本
- Ghost CLI: 1.32.3
- 安装命令：`npm install -g ghost-cli@latest`

### 运行目录
- Ghost 运行目录：`runtime/`
- 内容目录：`runtime/content/`
- 主题目录：`runtime/content/themes/`
- 数据库：`runtime/content/data/ghost-dev.db`

### 主题安装/回滚
- 安装：将主题目录复制到 `runtime/content/themes/`，在管理后台激活
- 回滚：在管理后台 → 设置 → 主题 中切换回 source 主题
- 主题打包：`cd theme/oss-blog-theme && zip -r oss-blog-theme.zip .`

### 演示账号生成方式
- 管理员：首次启动后通过管理后台初始化创建
- 会员：通过管理后台 → 会员 → 新建会员创建，或通过前台注册
- 密码：手动设置，符合 Ghost 密码策略（≥10位）

### 内容导出恢复步骤
- 导出：管理后台 → 设置 → 实验室 → 迁移工具 → Export
- 恢复：管理后台 → 设置 → 实验室 → 迁移工具 → Import，选择 JSON 文件
- 数据库备份：直接复制 `runtime/content/data/ghost-dev.db`
- 详细说明：`docs/export/README.md`

## 项目结构总结

```
oss-blog/
├── runtime/          # Ghost 运行时（数据不提交）
├── theme/            # 自定义主题源码（本人开发）
├── docs/             # 项目文档（基线、架构、Issue、PR、导出、实验报告）
├── tests/            # 测试记录
├── scripts/          # 启动/停止脚本
├── .gitignore        # Git 忽略规则
├── NOTICE.md         # 许可证声明
└── README.md         # 本文件
```

---

**实验课程**：开源软件与新技术 - 实验01 开源个人博客系统二次开发
**完成日期**：2026-09-07
**版本**：v1.0-lab
