// Helper to get character at index

///|
fn char_at(text : StringView, index : Int) -> Char {
  text[index].to_int().unsafe_to_char()
}

///|
pub fn parse_inline(text : String) -> Array[Inline] {
  parse_inline_view(text.to_string_view())
}

// Inner parser working with StringView

///|
fn parse_inline_view(text : StringView) -> Array[Inline] {
  let result = []
  let mut i = 0
  let len = text.length()
  let mut current_text = ""

  let commit_text = fn() {
    if current_text != "" {
      result.push(Inline::Text(current_text))
      current_text = ""
    }
  }

  while i < len {
    // 1. Image: ! [ alt ] ( url )
    if i + 1 < len && char_at(text, i) == '!' && char_at(text, i + 1) == '[' {
      let mut bracket_level = 1
      let mut j = i + 2
      let mut alt_text = ""
      while j < len && bracket_level > 0 {
        let ch = char_at(text, j)
        if ch == '[' {
          bracket_level += 1
        } else if ch == ']' {
          bracket_level -= 1
        }
        if bracket_level > 0 {
          alt_text += ch.to_string()
        }
        j += 1
      }
      if j < len && char_at(text, j) == '(' {
        let mut k = j + 1
        let mut url_and_title = ""
        while k < len && char_at(text, k) != ')' {
          url_and_title += char_at(text, k).to_string()
          k += 1
        }
        if k < len && char_at(text, k) == ')' {
          commit_text()
          let trimmed = url_and_title.trim().to_owned()
          let mut url = trimmed
          let mut title = ""

          if trimmed.contains("\"") {
            match trimmed.find("\"") {
              Some(quote_idx) => {
                url = trimmed[0:quote_idx].trim().to_owned()
                let remaining = trimmed[quote_idx + 1:]
                match remaining.find("\"") {
                  Some(end_quote_idx) =>
                    title = remaining[0:end_quote_idx].to_owned()
                  None => ()
                }
              }
              None => ()
            }
          }
          result.push(Inline::Image(url, title, alt_text))
          i = k + 1
          continue
        }
      }
    }

    // 2. Link: [ text ] ( url )
    if char_at(text, i) == '[' {
      let mut bracket_level = 1
      let mut j = i + 1
      let mut link_text = ""
      while j < len && bracket_level > 0 {
        let ch = char_at(text, j)
        if ch == '[' {
          bracket_level += 1
        } else if ch == ']' {
          bracket_level -= 1
        }
        if bracket_level > 0 {
          link_text += ch.to_string()
        }
        j += 1
      }
      if j < len && char_at(text, j) == '(' {
        let mut k = j + 1
        let mut url_and_title = ""
        while k < len && char_at(text, k) != ')' {
          url_and_title += char_at(text, k).to_string()
          k += 1
        }
        if k < len && char_at(text, k) == ')' {
          commit_text()
          let trimmed = url_and_title.trim().to_owned()
          let mut url = trimmed
          let mut title = ""

          if trimmed.contains("\"") {
            match trimmed.find("\"") {
              Some(quote_idx) => {
                url = trimmed[0:quote_idx].trim().to_owned()
                let remaining = trimmed[quote_idx + 1:]
                match remaining.find("\"") {
                  Some(end_quote_idx) =>
                    title = remaining[0:end_quote_idx].to_owned()
                  None => ()
                }
              }
              None => ()
            }
          }
          let link_content = parse_inline_view(link_text.to_string_view())
          result.push(Inline::Link(url, title, link_content))
          i = k + 1
          continue
        }
      }
    }

    // 3. Bold: **text** or __text__
    if (i + 1 < len && char_at(text, i) == '*' && char_at(text, i + 1) == '*') ||
      (i + 1 < len && char_at(text, i) == '_' && char_at(text, i + 1) == '_') {
      let marker = text[i:i + 2]
      let mut j = i + 2
      let mut bold_content = ""
      let mut found = false
      while j + 1 < len {
        if text[j:j + 2] == marker {
          found = true
          break
        }
        bold_content += char_at(text, j).to_string()
        j += 1
      }
      if found {
        commit_text()
        let bold_inlines = parse_inline_view(bold_content.to_string_view())
        result.push(Inline::Strong(bold_inlines))
        i = j + 2
        continue
      }
    }

    // 4. Emphasis: *text* or _text_
    if char_at(text, i) == '*' || char_at(text, i) == '_' {
      let marker = char_at(text, i)
      let mut j = i + 1
      let mut em_content = ""
      let mut found = false
      while j < len {
        if char_at(text, j) == marker {
          found = true
          break
        }
        em_content += char_at(text, j).to_string()
        j += 1
      }
      if found {
        commit_text()
        let em_inlines = parse_inline_view(em_content.to_string_view())
        result.push(Inline::Emphasis(em_inlines))
        i = j + 1
        continue
      }
    }

    // 5. Code Span: `code`
    if char_at(text, i) == '`' {
      let mut j = i + 1
      let mut code_content = ""
      let mut found = false
      while j < len {
        if char_at(text, j) == '`' {
          found = true
          break
        }
        code_content += char_at(text, j).to_string()
        j += 1
      }
      if found {
        commit_text()
        result.push(Inline::CodeSpan(code_content))
        i = j + 1
        continue
      }
    }

    // Default character
    current_text += char_at(text, i).to_string()
    i += 1
  }

  commit_text()
  result
}
