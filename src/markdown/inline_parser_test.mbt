///|
test "parse inline elements" {
  debug_inspect(
    parse_inline("hello world"),
    content=(
      #|[Text("hello world")]
    ),
  )
  debug_inspect(
    parse_inline("hello *world* and **bold**"),
    content=(
      #|[
      #|  Text("hello "),
      #|  Emphasis([Text("world")]),
      #|  Text(" and "),
      #|  Strong([Text("bold")]),
      #|]
    ),
  )
  debug_inspect(
    parse_inline("code span: `let x = 1`"),
    content=(
      #|[Text("code span: "), CodeSpan("let x = 1")]
    ),
  )
  debug_inspect(
    parse_inline("link: [MoonBit](https://moonbitlang.org \"Official Site\")"),
    content=(
      #|[
      #|  Text("link: "),
      #|  Link("https://moonbitlang.org", "Official Site", [Text("MoonBit")]),
      #|]
    ),
  )
  debug_inspect(
    parse_inline("image: ![Logo](logo.png)"),
    content=(
      #|[Text("image: "), Image("logo.png", "", "Logo")]
    ),
  )
}
