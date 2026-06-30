# 基于 MoonBit 的高性能 Markdown 解析与渲染引擎 (moon-cmark)

## 项目简介

`moon-cmark` 是一个完全使用 **MoonBit** 语言编写的、高性能且高度符合 CommonMark 标准的 Markdown 解析与 HTML 渲染引擎。

本项目专为 [MoonBit 国产基础软件生态开源大赛 (OSC2026)](https://moonbitlang.github.io/OSC2026/) 设计，旨在填补目前 MoonBit 生态中缺乏标准化、工业级 Markdown 处理基础库的空白。项目架构从底层彻底解耦了“词法分析”、“语法解析”和“HTML渲染”三个阶段，并暴露了事件流（Event Stream）API。

## 核心亮点

* **纯 MoonBit 实现**：零外部依赖，最大化发挥 MoonBit 的编译期优化与 Wasm 运行效率。
* **事件驱动架构 (Event Stream)**：将 Markdown 解析为事件流（例如 `StartBlock("h1")`, `TextEvent("Hello")`, `EndBlock("h1")`）。这种架构不但能高效地渲染 HTML，还极大地增强了扩展性，允许开发者在渲染前注入自定义过滤逻辑。
* **极速编译与低内存占用**：通过智能复用字符串索引（底层基于 UTF-16 内存模型安全读取）和扁平的 AST（抽象语法树）设计，极大降低了内存分配（Allocation）开销。
* **安全渲染核心**：内置基础 XSS 防护，在 HTML 渲染阶段对敏感符号进行强制转义，确保生成的内容在浏览器中安全展现。

## 快速开始

本项目依赖 MoonBit 官方工具链。请确保你已经安装了最新的 [MoonBit CLI](https://cli.moonbitlang.com/)。

### 安装与构建

```bash
git clone https://github.com/Myytsjj/myyProject.git
cd myyProject
moon build
```

### 运行测试

引擎中自带了详尽的单元测试，覆盖了区块扫描、行内解析和集成渲染场景：

```bash
moon test
```

### 代码示例

只需几行代码，即可实现从 Markdown 文本到 HTML 的无缝转换：

```moonbit
let md = "### Hello *MoonBit*\n\nThis is a **test**."
let parser = Parser::new(md)
// 1. 将文本解析为 AST (抽象语法树)
let blocks = parser.parse()
// 2. 将 AST 转换为 Event Stream (事件流)
let events = to_events(blocks)
// 3. 将 Event Stream 渲染为 HTML
let html = render_html(events)

println(html)
// 输出:
// <h3>Hello <em>MoonBit</em></h3>
// <p>This is a <strong>test</strong>.</p>
```

## 架构解析

1. **Lexer (词法分析器)**：负责消费输入字符串并生成一系列 `Token`（如 `HeadingMarker`, `Text`, `Space`, `Newline` 等）。它封装了指针状态，避免了多余的子字符串复制。
2. **Parser (语法分析器)**：基于 Lexer 提供的 Token，进行区块（Block）与行内（Inline）双重解析，生成强类型的 `AST`。
3. **Event Stream (事件流)**：通过 `to_events` 方法遍历 AST 并展开为扁平的枚举结构，极大地简化了渲染器的逻辑。
4. **HTML Renderer (渲染器)**：负责消费 Event 队列，生成最终的 HTML 字符串，并在此阶段执行转义操作。

## 参与贡献与致谢

本项目是为 OSC2026 大赛第一阶段构建的核心原型库。
灵感与架构参考了 Rust 生态下著名的 `pulldown-cmark` 引擎，在此特别致谢。

## 开源协议

本项目基于 MIT 许可证开源。
