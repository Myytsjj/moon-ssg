// Tests for SSG engine

///|
test "parse front matter with advanced metadata" {
  let doc =
    #|---
    #|title: Hello MoonBit
    #|date: 2026-07-03
    #|draft: true
    #|tags: [MoonBit, WebAssembly]
    #|categories:
    #|  - Tech
    #|  - News
    #|---
    #|This is the content.
  let (meta, body) = parse_front_matter(doc)

  // Use the public getters (which are automatically generated or accessible fields)
  if meta.title != "Hello MoonBit" {
    abort("expected title to be 'Hello MoonBit'")
  }
  if meta.date != "2026-07-03" {
    abort("expected date to be '2026-07-03'")
  }
  if !meta.draft {
    abort("expected draft to be true")
  }
  if meta.tags != ["MoonBit", "WebAssembly"] {
    abort("failed to parse inline tags list")
  }
  if meta.categories != ["Tech", "News"] {
    abort("failed to parse multiline categories list")
  }
  if body.trim() != "This is the content." {
    abort("expected body to be 'This is the content.'")
  }
}

///|
test "generate site with taxonomy pagination RSS search" {
  let post1_src =
    #|---
    #|title: Hello World
    #|date: 2026-07-03
    #|tags: [MoonBit]
    #|categories: [Programming]
    #|---
    #|Hello *world*!

  let post2_src =
    #|---
    #|title: Second Post
    #|date: 2026-07-04
    #|tags: [MoonBit, Wasm]
    #|categories: [Programming]
    #|---
    #|This is paragraph.

  let draft_src =
    #|---
    #|title: Draft Post
    #|date: 2026-07-05
    #|draft: true
    #|---
    #|This is draft.

  let sources = [
    ("post1.md", post1_src),
    ("post2.md", post2_src),
    ("draft.md", draft_src),
  ]

  let layout = "<html><head><title>{{title}}</title></head><body><h1>{{title}}</h1><div class=\"date\">{{date}}</div><div class=\"content\">{{content}}</div></body></html>"
  let index_layout = "<html><body><h1>My Blog</h1>{{posts}}{{pagination}}</body></html>"
  let tag_layout = "<html><body><h1>{{tag}}</h1>{{posts}}</body></html>"
  let category_layout = "<html><body><h1>{{category}}</h1>{{posts}}</body></html>"

  // Use the constructor method Config::make
  let config = Config::make(
    "My MoonBit Blog", "Description", "https://example.com", 1, // posts_per_page
     "content", "layouts", "public", "static",
  )

  // 1. Generate without drafts
  let pages = generate_site(
    sources, layout, index_layout, tag_layout, category_layout, config, false, // include_drafts = false
  )

  // Expected pages:
  // - post1.html
  // - post2.html
  // - index.html (page 1)
  // - index2.html (page 2)
  // - tag-MoonBit.html
  // - tag-Wasm.html
  // - category-Programming.html
  // - rss.xml
  // - search.json
  // Total: 9 pages
  if pages.length() != 9 {
    abort("expected 9 pages generated, got " + pages.length().to_string())
  }

  // Verify pagination page names
  let mut found_index1 = false
  let mut found_index2 = false
  let mut found_rss = false
  let mut found_search = false
  let mut found_tag_wasm = false

  for page in pages {
    if page.path == "index.html" {
      found_index1 = true
    } else if page.path == "index2.html" {
      found_index2 = true
    } else if page.path == "rss.xml" {
      found_rss = true
    } else if page.path == "search.json" {
      found_search = true
    } else if page.path == "tag-Wasm.html" {
      found_tag_wasm = true
    }
  }

  if !found_index1 || !found_index2 {
    abort("missing index.html or index2.html pagination pages")
  }
  if !found_rss {
    abort("missing rss.xml")
  }
  if !found_search {
    abort("missing search.json")
  }
  if !found_tag_wasm {
    abort("missing tag-Wasm.html")
  }

  // 2. Generate with drafts
  let pages_with_drafts = generate_site(
    sources, layout, index_layout, tag_layout, category_layout, config, true, // include_drafts = true
  )

  // With drafts: draft.html is generated. Posts list changes.
  let mut found_draft = false
  for page in pages_with_drafts {
    if page.path == "draft.html" {
      found_draft = true
    }
  }
  if !found_draft {
    abort("expected draft.html to be generated")
  }
}

///|
test "char to string test" {
  let c = 'A'
  let s2 = "\{c}"
  if s2 != "A" {
    abort("failed: s2=" + s2)
  }
}

///|
test "escape json test" {
  let esc = @ssg.escape_json_str("Hello")
  if esc != "Hello" {
    abort("escape failed: " + esc)
  }
}
