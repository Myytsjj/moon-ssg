///|
test "parse block elements" {
  let parser1 = Parser::new("### Hello *MoonBit*\n\nThis is a paragraph.")
  debug_inspect(
    parser1.parse(),
    content=(
      #|[
      #|  Heading(3, [Text("Hello "), Emphasis([Text("MoonBit")])]),
      #|  Paragraph([Text("This is a paragraph.")]),
      #|]
    ),
  )

  let parser2 = Parser::new("```moonbit\nfn main {}\n```")
  debug_inspect(
    parser2.parse(),
    content=(
      #|[CodeBlock("moonbit", "fn main {}")]
    ),
  )

  let parser3 = Parser::new("> This is a blockquote\n> containing text.")
  debug_inspect(
    parser3.parse(),
    content=(
      #|[Blockquote([Paragraph([Text("This is a blockquote containing text.")])])]
    ),
  )

  let parser4 = Parser::new("* Item 1\n* Item 2\n\n1. First\n2. Second")
  debug_inspect(
    parser4.parse(),
    content=(
      #|[
      #|  List(
      #|    false,
      #|    [[Paragraph([Text("Item 1")])], [Paragraph([Text("Item 2")])]],
      #|  ),
      #|  List(
      #|    true,
      #|    [[Paragraph([Text("First")])], [Paragraph([Text("Second")])]],
      #|  ),
      #|]
    ),
  )

  let parser5 = Parser::new("---")
  debug_inspect(
    parser5.parse(),
    content=(
      #|[ThematicBreak]
    ),
  )
}
