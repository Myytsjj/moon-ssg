pub struct Parser {
  lexer: Lexer
}

pub fn Parser::new(input: String) -> Parser {
  { lexer: Lexer::new(input) }
}

pub fn Parser::parse(self: Parser) -> Array[Block] {
  let blocks = []
  
  while true {
    let token = self.lexer.next_token()
    match token {
      EOF => break
      HeadingMarker(level) => {
        // parse heading
        let mut content = ""
        while true {
          match self.lexer.next_token() {
            EOF | Newline => break
            Text(t) => content += t
            Space(n) => {
              for i = 0; i < n; i = i + 1 {
                content += " "
              }
            }
            HeadingMarker(l) => {
               for i = 0; i < l; i = i + 1 {
                content += "#"
              }
            }
            ThematicBreakMarker => {
              content += "---"
            }
          }
        }
        // naive inline parsing for heading content
        let inline_content = [Inline::Text(content)]
        blocks.push(Block::Heading(level, inline_content))
      }
      ThematicBreakMarker => {
        blocks.push(Block::ThematicBreak)
      }
      _ => {
        // Ignore other tokens for now
      }
    }
  }
  
  blocks
}
