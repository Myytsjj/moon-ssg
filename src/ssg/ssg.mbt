// Static Site Generator Engine for moon-ssg

///|
pub struct BlogPost {
  title : String
  date : String
  filename : String
  content_html : String
}

///|
pub struct GeneratedPage {
  path : String
  html : String
}

// Helper to extract front matter and body
// Front matter format:
// ---
// title: My Post
// date: 2026-07-03
// ---
// Body content here...

///|
pub fn parse_front_matter(source : String) -> (Map[String, String], String) {
  let metadata : Map[String, String] = Map([])
  let mut body = source

  if source.has_prefix("---") {
    // find second --- starting from index 3
    let mut second_fm_idx = -1
    for i = 3; i < source.length() - 2; i = i + 1 {
      if source[i] == '-' && source[i + 1] == '-' && source[i + 2] == '-' {
        second_fm_idx = i
        break
      }
    }

    if second_fm_idx != -1 {
      let mut fm_block = ""
      for i = 3; i < second_fm_idx; i = i + 1 {
        let ch_code = source[i]
        fm_block += ch_code.to_int().unsafe_to_char().to_string()
      }

      // Extract body
      let body_start = second_fm_idx + 3
      let mut body_str = ""
      for i = body_start; i < source.length(); i = i + 1 {
        let ch_code = source[i]
        body_str += ch_code.to_int().unsafe_to_char().to_string()
      }
      body = body_str

      // Parse fm_block lines
      let lines = fm_block.split("\n")
      for line in lines {
        let trimmed = line.trim()
        if trimmed != "" {
          let mut colon_idx = -1
          for i = 0; i < trimmed.length(); i = i + 1 {
            if trimmed[i] == ':' {
              colon_idx = i
              break
            }
          }

          if colon_idx != -1 {
            let mut key = ""
            for i = 0; i < colon_idx; i = i + 1 {
              key += trimmed[i].to_int().unsafe_to_char().to_string()
            }
            let mut val = ""
            for i = colon_idx + 1; i < trimmed.length(); i = i + 1 {
              val += trimmed[i].to_int().unsafe_to_char().to_string()
            }
            metadata.set(key.trim().to_owned(), val.trim().to_owned())
          }
        }
      }
    }
  }

  (metadata, body)
}

// Generate the site
// Takes an array of (filename, markdown_source) tuples

///|
pub fn generate_site(
  sources : Array[(String, String)],
  layout : String,
  index_layout : String,
) -> Array[GeneratedPage] {
  let pages = []
  let posts = []

  // 1. Process all markdown posts
  for src in sources {
    let (filename, content) = src
    let (meta, body) = parse_front_matter(content)

    // Parse Markdown to HTML
    let parser = @markdown.Parser::new(body)
    let blocks = parser.parse()
    let events = @markdown.to_events(blocks)
    let html_content = @markdown.render_html(events)

    let title = meta.get("title").unwrap_or("Untitled")
    let date = meta.get("date").unwrap_or("Unknown Date")

    let post = { title, date, filename, content_html: html_content }
    posts.push(post)

    // Render the post page using the layout template
    let rendered_html = render_post(post, layout)
    let out_filename = filename.replace(old=".md", new=".html")

    pages.push({ path: out_filename, html: rendered_html })
  }

  // 2. Generate the index page
  let index_html = render_index(posts, index_layout)
  pages.push({ path: "index.html", html: index_html })

  pages
}

///|
fn render_post(post : BlogPost, template : String) -> String {
  let mut res = template
  res = res.replace(old="{{title}}", new=post.title)
  res = res.replace(old="{{date}}", new=post.date)
  res = res.replace(old="{{content}}", new=post.content_html)
  res
}

///|
fn render_index(posts : Array[BlogPost], template : String) -> String {
  let mut list_html = "<ul>\n"
  for post in posts {
    let link = post.filename.replace(old=".md", new=".html")
    list_html += "  <li><span class=\"date\">" +
      post.date +
      "</span> - <a href=\"" +
      link +
      "\">" +
      post.title +
      "</a></li>\n"
  }
  list_html += "</ul>"

  let mut res = template
  res = res.replace(old="{{title}}", new="Blog Index")
  res = res.replace(old="{{posts}}", new=list_html)
  res
}
