// Tests for SSG engine

///|
test "parse front matter" {
  let doc = "---\ntitle: Hello MoonBit\ndate: 2026-07-03\n---\nThis is the content."
  let (meta, body) = parse_front_matter(doc)

  if meta.get("title") != Some("Hello MoonBit") {
    abort("expected title to be 'Hello MoonBit'")
  }
  if meta.get("date") != Some("2026-07-03") {
    abort("expected date to be '2026-07-03'")
  }
  if body.trim() != "This is the content." {
    abort("expected body to be 'This is the content.'")
  }
}

///|
test "generate site" {
  let sources = [
    (
      "post1.md", "---\ntitle: Hello World\ndate: 2026-07-03\n---\nHello *world*!",
    ),
    (
      "post2.md", "---\ntitle: Second Post\ndate: 2026-07-04\n---\nThis is paragraph.",
    ),
  ]
  let layout = "<html><head><title>{{title}}</title></head><body><h1>{{title}}</h1><div class=\"date\">{{date}}</div><div class=\"content\">{{content}}</div></body></html>"
  let index_layout = "<html><body><h1>My Blog</h1>{{posts}}</body></html>"

  let pages = generate_site(sources, layout, index_layout)
  if pages.length() != 3 {
    abort("expected 3 pages generated")
  }

  // Check index
  let index_page = pages[2]
  if index_page.path != "index.html" {
    abort("expected index.html page")
  }

  // Check post 1
  let post1 = pages[0]
  if post1.path != "post1.html" {
    abort("expected post1.html")
  }
}
