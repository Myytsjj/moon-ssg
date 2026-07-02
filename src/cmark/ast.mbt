// AST Definitions for Markdown elements

///|
pub enum Block {
  Heading(Int, Array[Inline]) // Level, Content
  Paragraph(Array[Inline])
  ThematicBreak
  CodeBlock(String, String) // Info string, Content
  Blockquote(Array[Block])
  List(Bool, Array[Array[Block]]) // IsOrdered, Items
}

///|
pub enum Inline {
  Text(String)
  CodeSpan(String)
  Emphasis(Array[Inline])
  Strong(Array[Inline])
  Link(String, String, Array[Inline]) // URL, Title, Content
  Image(String, String, String) // URL, Title, AltText
  HardBreak
  SoftBreak
}

///|
test "dummy use of AST variants for warning suppression" {
  let _ = Block::CodeBlock("info", "content")
  let _ = Block::Blockquote([])
  let _ = Block::List(false, [])
  let _ = Inline::CodeSpan("code")
  let _ = Inline::Link("url", "title", [])
  let _ = Inline::Image("url", "title", "alt")
  let _ = Inline::HardBreak
  let _ = Inline::SoftBreak
}
