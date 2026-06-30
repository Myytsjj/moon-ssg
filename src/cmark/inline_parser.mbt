// Simple inline parser

pub fn parse_inline(text: String) -> Array[Inline] {
  let result = []
  let mut pos = 0
  let mut current_text = ""

  while pos < text.length() {
    if pos + 1 < text.length() && text[pos] == '*' && text[pos+1] == '*' {
      if current_text != "" {
        result.push(Inline::Text(current_text))
        current_text = ""
      }
      pos += 2
      let mut strong_text = ""
      while pos < text.length() && !(pos + 1 < text.length() && text[pos] == '*' && text[pos+1] == '*') {
        strong_text += text[pos].to_string()
        pos += 1
      }
      result.push(Inline::Strong([Inline::Text(strong_text)]))
      pos += 2 // skip closing **
    } else if text[pos] == '*' {
      if current_text != "" {
        result.push(Inline::Text(current_text))
        current_text = ""
      }
      pos += 1
      let mut em_text = ""
      while pos < text.length() && text[pos] != '*' {
        em_text += text[pos].to_string()
        pos += 1
      }
      result.push(Inline::Emphasis([Inline::Text(em_text)]))
      pos += 1 // skip closing *
    } else {
      current_text += text[pos].to_string()
      pos += 1
    }
  }

  if current_text != "" {
    result.push(Inline::Text(current_text))
  }

  result
}
