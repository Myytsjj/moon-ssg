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
