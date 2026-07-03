# 基于 MoonBit 的轻量级静态网站生成器 (moon-ssg)

## 项目简介

`moon-ssg` 是一个完全使用 **MoonBit** 编写的、高性能且轻量级的静态网站与博客生成引擎（Static Site Generator）。

项目专为 [MoonBit 国产基础软件生态开源大赛 (OSC2026)](https://moonbitlang.github.io/OSC2026/) 设计，通过底层的编译技术将 Markdown 文本、元数据（Front-matter）和 HTML 模板（Layout）编译组合为零依赖、极速加载的静态网页。

本项目的核心目标是为 MoonBit 生态提供一个可重用、无缝移植的静态文档及博客建站底座。

## 核心亮点

* **自研 Markdown 编译器**：内置一个高度符合 CommonMark 标准的 Markdown 词法与语法分析模块，自动实现安全的 HTML 渲染，不依赖任何外部繁重的解析包。
* **YAML/JSON Front-matter 支持**：内置轻量级元数据提取器，支持通过 `---` 包裹的文章头部元数据解析（支持 `title`、`date` 等页面属性）。
* **纯函数式生成核心**：引擎设计为纯粹的数据流映射 `(文件名, Markdown 源码) -> (输出路径, 编译后 HTML)`，不强制绑定具体的本地 I/O，使其能够完美运行在 WebAssembly（浏览器、Node.js）以及 Native 等任意 MoonBit 支持的后端。
* **响应式列表（Index）自动生成**：能够全自动抓取所有文章的发布日期与标题，并动态生成格式优美、带有时间排序的博客首页（`index.html`）。

## 快速开始

本项目依赖 MoonBit 官方工具链。请确保你已经安装了最新的 [MoonBit CLI](https://cli.moonbitlang.com/)。

### 安装与构建

```bash
git clone https://github.com/Myytsjj/moon-ssg.git
cd moon-ssg
moon build
```

### 运行测试

引擎中包含详尽的模块测试（包括 Markdown 语法解析、事件流处理、Front-matter 剥离以及整站模板合成）：

```bash
moon test
```

### 代码示例

使用 `moon-ssg` 生成站点的核心流程非常直观：

```moonbit
import "moon-ssg/src/ssg"

fn init {
  // 1. 定义源 Markdown 文章（支持 Front-matter 属性声明）
  let sources = [
    ("post1.md", "---\ntitle: 探索 MoonBit 语言\ndate: 2026-07-03\n---\n这是第一篇博客，支持 *Markdown* 语法！"),
    ("post2.md", "---\ntitle: 静态生成器架构设计\ndate: 2026-07-04\n---\n利用 `moon-ssg`，你可以轻松生成个人博客。")
  ]

  // 2. 定义页面模板与首页模板
  let layout = "<html><head><title>{{title}}</title></head><body><h1>{{title}}</h1><div class=\"date\">{{date}}</div><article>{{content}}</article></body></html>"
  let index_layout = "<html><head><title>我的博客首页</title></head><body><h1>文章列表</h1>{{posts}}</body></html>"

  // 3. 一键生成全站 HTML 页面
  let pages = @ssg.generate_site(sources, layout, index_layout)

  // 4. pages 中包含了生成的 index.html 以及各个文章对应的 html 文件
  for page in pages {
    println("Path: " + page.path + ", Length: " + page.html.length().to_string())
  }
}
```

## 架构设计

1. **Parser Component (编译器组件)**：位于 `src/markdown`。负责解析 Markdown 语法并输出 Event Stream 序列，这是生成器内容的来源。
2. **SSG Core Engine (静态生成核心)**：位于 `src/ssg`。
   * **Front-matter 解析器**：用于剥离 `---` 首尾标识，并将其中的键值对存储在 `Map` 中。
   * **Template Engine**：基于简单的 `replace` 算法，将页面标题、发布时间、文章正文安全注入对应的 layout 占位符。
   * **Index Builder**：按顺序整理文章，生成列表页。

## 开源协议

本项目基于 MIT 许可证开源。
