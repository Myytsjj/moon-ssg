///|
test "markdown to html integration" {
  let md =
    #|### Hello *MoonBit*
    #|
    #|This is a **test**.
    #|
    #|```mbt
    #|let x = 1
    #|```
    #|
    #|> Quote here
    #|
    #|* List 1
    #|* List 2
  let parser = Parser::new(md)
  let blocks = parser.parse()
  let events = to_events(blocks)
  let html = render_html(events)
  inspect(
    html,
    content=(
      #|<h3>
      #|Hello <em>MoonBit</em></h3>
      #|<p>
      #|This is a <strong>test</strong>.</p>
      #|<pre>
      #|<code class="language-mbt">
      #|let x = 1</code>
      #|</pre>
      #|<blockquote>
      #|<p>
      #|Quote here</p>
      #|</blockquote>
      #|<ul>
      #|<li>
      #|<p>
      #|List 1</p>
      #|</li>
      #|<li>
      #|<p>
      #|List 2</p>
      #|</li>
      #|</ul>
      #|
    ),
  )
}
