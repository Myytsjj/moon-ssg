///|
// Helper to join an array of strings with a separator
fn join_strings(arr : Array[String], sep : String) -> String {
  let mut res = ""
  for i = 0; i < arr.length(); i = i + 1 {
    if i > 0 {
      res += sep
    }
    res += arr[i]
  }
  res
}

// Check list item prefix

///|
fn parse_list_item(line : StringView) -> (Bool, Bool, String)? {
  let trimmed = line.trim_start()
  if trimmed.has_prefix("* ") {
    return Some((false, true, trimmed[2:].to_owned()))
  }
  if trimmed.has_prefix("- ") {
    if trimmed.trim() == "---" {
      return None
    }
    return Some((false, true, trimmed[2:].to_owned()))
  }
  if trimmed.has_prefix("+ ") {
    return Some((false, true, trimmed[2:].to_owned()))
  }

  // Ordered list item: digits followed by ". "
  let len = trimmed.length()
  if len > 2 {
    let mut i = 0
    while i < len {
      let ch = char_at(trimmed, i)
      if ch >= '0' && ch <= '9' {
        i += 1
      } else {
        break
      }
    }
    if i > 0 &&
      i + 1 < len &&
      char_at(trimmed, i) == '.' &&
      char_at(trimmed, i + 1) == ' ' {
      return Some((true, true, trimmed[i + 2:].to_owned()))
    }
  }
  None
}

// Check heading prefix

///|
fn parse_heading(line : StringView) -> (Int, String)? {
  let trimmed = line.trim_start()
  if trimmed.has_prefix("#") {
    let mut level = 0
    while level < trimmed.length() && char_at(trimmed, level) == '#' {
      level += 1
    }
    if level >= 1 &&
      level <= 6 &&
      level < trimmed.length() &&
      char_at(trimmed, level) == ' ' {
      return Some((level, trimmed[level + 1:].to_owned()))
    }
  }
  None
}

// Check thematic break

///|
fn is_thematic_break(line : StringView) -> Bool {
  let trimmed = line.trim()
  if trimmed.length() < 3 {
    return false
  }
  let first = char_at(trimmed, 0)
  if first != '-' && first != '*' && first != '_' {
    return false
  }
  for i = 0; i < trimmed.length(); i = i + 1 {
    let ch = char_at(trimmed, i)
    if ch != first && ch != ' ' {
      return false
    }
  }
  true
}

// Check blockquote line

///|
fn parse_blockquote_line(line : StringView) -> String? {
  let trimmed = line.trim_start()
  if trimmed.has_prefix(">") {
    let rest = trimmed[1:]
    if rest.length() > 0 && char_at(rest, 0) == ' ' {
      return Some(rest[1:].to_owned())
    }
    return Some(rest.to_owned())
  }
  None
}

///|
pub struct Parser {
  lexer : Lexer
}

///|
pub fn Parser::new(input : String) -> Parser {
  { lexer: Lexer::new(input) }
}

///|
pub fn Parser::parse(self : Parser) -> Array[Block] {
  let blocks = []
  let input = self.lexer.input

  // Split into lines
  let lines = []
  for line in input.split("\n") {
    lines.push(line)
  }

  let mut i = 0
  let total_lines = lines.length()

  while i < total_lines {
    let line = lines[i]

    // 1. Skip empty lines
    if line.trim() == "" {
      i += 1
      continue
    }

    // 2. Fenced Code Block
    let trimmed = line.trim_start()
    if trimmed.has_prefix("```") {
      let info_string = trimmed[3:].trim().to_owned()
      let mut code_content = ""
      i += 1
      while i < total_lines {
        let current_line = lines[i]
        if current_line.trim_start().has_prefix("```") {
          i += 1
          break
        }
        if code_content != "" {
          code_content += "\n"
        }
        code_content += current_line.to_owned()
        i += 1
      }
      blocks.push(Block::CodeBlock(info_string, code_content))
      continue
    }

    // 3. Heading
    match parse_heading(line) {
      Some((level, content)) => {
        blocks.push(Block::Heading(level, parse_inline(content)))
        i += 1
        continue
      }
      None => ()
    }

    // 4. Thematic Break
    if is_thematic_break(line) {
      blocks.push(Block::ThematicBreak)
      i += 1
      continue
    }

    // 5. Blockquote
    match parse_blockquote_line(line) {
      Some(first_bq_line) => {
        let bq_lines = [first_bq_line]
        i += 1
        let mut bq_active = true
        while i < total_lines && bq_active {
          let next_line = lines[i]
          match parse_blockquote_line(next_line) {
            Some(bq_line) => {
              bq_lines.push(bq_line)
              i += 1
            }
            None =>
              // Lazy blockquote line (continuation of paragraph)
              if next_line.trim() != "" &&
                !next_line.trim_start().has_prefix("```") &&
                parse_heading(next_line) is None &&
                !is_thematic_break(next_line) {
                bq_lines.push(next_line.trim_start().to_owned())
                i += 1
              } else {
                bq_active = false
              }
          }
        }
        // Recursively parse the collected blockquote content
        let bq_text = join_strings(bq_lines, "\n")
        let bq_parser = Parser::new(bq_text)
        let bq_blocks = bq_parser.parse()
        blocks.push(Block::Blockquote(bq_blocks))
        continue
      }
      None => ()
    }

    // 6. List
    match parse_list_item(line) {
      Some((is_ordered, _, first_item_content)) => {
        let items = []
        let mut current_item_lines = [first_item_content]
        i += 1

        let mut list_active = true
        while i < total_lines && list_active {
          let next_line = lines[i]
          match parse_list_item(next_line) {
            Some((next_ordered, _, next_item_content)) =>
              if next_ordered == is_ordered {
                // Finish current item
                let item_text = join_strings(current_item_lines, "\n")
                let item_parser = Parser::new(item_text)
                items.push(item_parser.parse())

                // Start next item
                current_item_lines = [next_item_content]
                i += 1
              } else {
                list_active = false
              }
            None =>
              // Check if continuation of current item
              if next_line.trim() == "" {
                // Empty line might separate items or just be a blank line in item
                let mut next_item_idx = i + 1
                while next_item_idx < total_lines &&
                      lines[next_item_idx].trim() == "" {
                  next_item_idx += 1
                }
                if next_item_idx < total_lines {
                  match parse_list_item(lines[next_item_idx]) {
                    Some((next_ordered, _, _)) =>
                      if next_ordered == is_ordered {
                        i = next_item_idx
                        continue
                      }
                    None => ()
                  }
                }
                list_active = false
              } else if next_line.trim_start().has_prefix("```") ||
                parse_heading(next_line) is Some(_) ||
                is_thematic_break(next_line) {
                list_active = false
              } else {
                current_item_lines.push(next_line.trim_start().to_owned())
                i += 1
              }
          }
        }
        // Add final item
        let item_text = join_strings(current_item_lines, "\n")
        let item_parser = Parser::new(item_text)
        items.push(item_parser.parse())

        blocks.push(Block::List(is_ordered, items))
        continue
      }
      None => ()
    }

    // 7. Paragraph
    let para_lines = [line.trim_start().to_owned()]
    i += 1
    let mut para_active = true
    while i < total_lines && para_active {
      let next_line = lines[i]
      if next_line.trim() == "" ||
        next_line.trim_start().has_prefix("```") ||
        parse_heading(next_line) is Some(_) ||
        is_thematic_break(next_line) ||
        parse_blockquote_line(next_line) is Some(_) ||
        parse_list_item(next_line) is Some(_) {
        para_active = false
      } else {
        para_lines.push(next_line.to_owned())
        i += 1
      }
    }
    let para_content = join_strings(para_lines, " ")
    blocks.push(Block::Paragraph(parse_inline(para_content)))
  }

  blocks
}
