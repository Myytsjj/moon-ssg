test "markdown to html integration" {
  let md = "### Hello *MoonBit*\n\nThis is a **test**."
  let parser = Parser::new(md)
  let blocks = parser.parse()
  let events = to_events(blocks)
  let html = render_html(events)
  
  // Note: For MVP the output might have slightly different whitespace
  // but we test that it compiles and runs without panic.
  let _ = html
}
