# 基于 MoonBit 的高性能静态网站生成器 (moon-ssg)

`moon-ssg` 是一个完全使用 **MoonBit** 编写的高性能、轻量级静态网站与博客生成引擎（Static Site Generator）。它内置了符合 CommonMark 核心规范的 Markdown 解析器与 HTML 渲染模块，能够将 Markdown 文本、元数据（Front-matter）和 HTML 模板（Layout）编译组合为零依赖、极速加载的静态网页。

本项目专为 MoonBit 国产基础软件生态开源大赛设计，为 MoonBit 生态提供一个可重用、跨平台的静态文档及个人博客建站底座。

## 核心功能与亮点

- **全功能 Markdown 解析器**：支持块级元素（标题、段落、分割线、引用块、列表、围栏代码块）及行内样式（粗体、斜体、行内代码、超链接、图片）。
- **YAML Front-matter 提取**：内置轻量级元数据提取器，支持通过 `---` 包裹的文章头部元数据解析（例如 `title`、`date` 等页面属性）。
- **纯函数式生成核心**：引擎设计为纯粹的数据流映射 `(文件名, Markdown 源码) -> (输出路径, 编译后 HTML)`，不强制绑定特定的本地 I/O，使其能够完美运行在 WebAssembly（浏览器、Node.js）以及 Native 等任意 MoonBit 支持的后端。
- **命令行工具 (CLI)**：基于 `moonbitlang/x/fs` 包实现了一键式整站编译工具，支持自动初始化目录、读取 Markdown 源文件、模版注入、并输出至生成目录。
- **自动列表索引 (Index) 生成**：根据文章的元数据发布日期自动排序，生成带有链接的博客列表首页（`index.html`）。

## 目录结构

```
.
├── content/              # Markdown 源文章目录 (自动创建)
├── layouts/              # 网页模版目录 (自动创建)
│   ├── index.html        # 博客首页模版
│   └── post.html         # 文章内容页模版
├── public/               # 静态 HTML 输出目录
├── src/
│   ├── markdown/         # 自研 Markdown 编译器及 HTML 渲染器
│   ├── ssg/              # Front-matter 解析与模版替换核心逻辑
│   └── main/             # CLI 命令行入口
├── moon.mod              # 模块配置文件
└── README.md
```

## 快速开始

本项目依赖 MoonBit 官方工具链。请确保你已经安装了最新的 [MoonBit CLI](https://cli.moonbitlang.com/)。

### 构建项目

```bash
# 编译整个项目
moon build
```

### 运行静态生成器

你可以直接通过 `moon run` 运行 CLI 工具：

```bash
moon run src/main
```

如果是首次运行，`moon-ssg` 会自动创建 `content/` 与 `layouts/` 文件夹，并生成默认的模板与示例文章。生成的 HTML 文件会输出在 `public/` 目录下。

### 运行测试

引擎中包含详尽的单元测试与集成测试，采用 MoonBit 原生的快照测试机制（`inspect` / `debug_inspect`）：

```bash
# 运行测试
moon test

# 更新快照测试结果
moon test --update
```

## 模版占位符支持

在网页模板中，你可以使用以下占位符来动态注入文章内容：

- `{{title}}` - 文章标题
- `{{date}}` - 发布日期
- `{{content}}` - 编译后的 Markdown HTML 正文
- `{{posts}}` - （仅限首页模版）生成的文章列表 HTML 块

## 开源协议

本项目基于 MIT 许可证开源。

## 第三方归属与开源许可说明

本项目在设计与实现过程中，参考并借鉴了以下优秀的开源静态网站生成器（SSG）项目：

1. **[Zola](https://github.com/getzola/zola)**
   * **原许可证**：MIT License
   * **参考范围说明**：参考了 Zola 的 Front-matter 元数据解析设计思路（如使用 `---` 包裹解析 `title`、`date`、`draft`、`tags`、`categories` 等基础字段）以及页面布局模板的替换逻辑。

2. **[Hugo](https://github.com/gohugoio/hugo)**
   * **原许可证**：Apache License 2.0
   * **参考范围说明**：借鉴了 Hugo 的命令行生成逻辑与目录结构设计（包括 `content/` 存放源文件、`layouts/` 存放模板文件、`static/` 存放静态资源、`public/` 存放编译结果的分层结构），以及分类体系（Taxonomies）如 `tags` 和 `categories` 分类静态页面的自动生成与索引设计。

3. **[CommonMark Spec](https://spec.commonmark.org/)**
   * **参考范围说明**：本项目的 Markdown 解析器（`src/markdown`）基于 CommonMark 核心语法规范进行 MoonBit 原生开发与实现，不依赖任何第三方运行时解析库，实现了纯粹的 MoonBit 块级和行内元素渲染。

## 作者身份与提交历史说明

本项目的核心开发者与申请人为 **宾雨莉**。为满足不同托管平台（GitHub 与 GitLink）的单点贡献者与账号绑定要求，提交历史中可能存在以下不同的账号标识，在此予以澄清说明：

- **GitHub 提交历史** 中的提交人 `Myytsjj <Myytsjj@users.noreply.github.com>` 及 `Myytsjj <myytsjj@github.com>` 均为申请人 **宾雨莉** 的 GitHub 账户。
- **GitLink 提交历史** 中的提交人 `Myyafa <Myyafa@users.noreply.gitlink.org.cn>` 均为申请人 **宾雨莉** 的 GitLink 账户（在 GitLink 镜像仓库推送时，已通过历史重写将提交记录中的作者/提交者身份重写为 `Myyafa`，以确保在 GitLink 上仅显示平台创建者账号为唯一贡献者，杜绝虚拟贡献者记录）。

本仓库的所有代码均为 **宾雨莉** 独立开发并享有完整版权，不存在任何第三方代码抄袭或版权纠纷。

