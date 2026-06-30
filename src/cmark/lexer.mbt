// Lexer and Token definitions

pub enum Token {
  Text(String)
  HeadingMarker(Int) // level
  ThematicBreakMarker
  Space(Int) // number of spaces
  Newline
  EOF
  // To be expanded
}

pub struct Lexer {
  input: String
  mut pos: Int
}

pub fn Lexer::new(input: String) -> Lexer {
  { input, pos: 0 }
}

pub fn Lexer::next_char(self: Lexer) -> Char? {
  if self.pos >= self.input.length() {
    None
  } else {
    let ch = self.input[self.pos]
    self.pos += 1
    Some(ch)
  }
}

pub fn Lexer::peek_char(self: Lexer) -> Char? {
  if self.pos >= self.input.length() {
    None
  } else {
    Some(self.input[self.pos])
  }
}

pub fn Lexer::next_token(self: Lexer) -> Token {
  // basic implementation, will be enhanced
  match self.peek_char() {
    None => EOF
    Some('\n') => {
      let _ = self.next_char()
      Newline
    }
    Some(' ') => {
      let mut count = 0
      while self.peek_char() == Some(' ') {
        let _ = self.next_char()
        count += 1
      }
      Space(count)
    }
    Some('#') => {
      let mut level = 0
      while self.peek_char() == Some('#') && level < 6 {
        let _ = self.next_char()
        level += 1
      }
      HeadingMarker(level)
    }
    Some('-') => {
      let mut count = 0
      while self.peek_char() == Some('-') {
        let _ = self.next_char()
        count += 1
      }
      if count >= 3 {
        ThematicBreakMarker
      } else {
        let mut text = ""
        for i = 0; i < count; i = i + 1 {
          text += "-"
        }
        Text(text)
      }
    }
    Some(_) => {
      let mut text = ""
      while true {
        match self.peek_char() {
          None | Some('\n') | Some(' ') | Some('#') | Some('-') => break
          Some(ch) => {
            let _ = self.next_char()
            text += ch.to_string()
          }
        }
      }
      Text(text)
    }
  }
}
