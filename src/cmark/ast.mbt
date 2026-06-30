// AST Definitions for Markdown elements

pub enum Block {
  Heading(Int, Array[Inline]) // Level, Content
  Paragraph(Array[Inline])
  ThematicBreak
  CodeBlock(String, String) // Info string, Content
  Blockquote(Array[Block])
  List(Bool, Array[Array[Block]]) // IsOrdered, Items
}

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
