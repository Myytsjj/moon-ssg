pub enum Event {
  StartBlock(String) // Tag name
  EndBlock(String)
  StartInline(String)
  EndInline(String)
  TextEvent(String)
  SelfClosing(String)
}

// Convert AST to Event Stream
pub fn to_events(blocks: Array[Block]) -> Array[Event] {
  let events = []
  
  for b in blocks {
    match b {
      Heading(level, inlines) => {
        let tag = "h" + level.to_string()
        events.push(Event::StartBlock(tag))
        for inline in inlines {
           inline_to_events(inline, events)
        }
        events.push(Event::EndBlock(tag))
      }
      Paragraph(inlines) => {
        events.push(Event::StartBlock("p"))
        for inline in inlines {
           inline_to_events(inline, events)
        }
        events.push(Event::EndBlock("p"))
      }
      ThematicBreak => {
        events.push(Event::SelfClosing("hr"))
      }
      _ => { } // unsupported blocks
    }
  }
  
  events
}

fn inline_to_events(inline: Inline, events: Array[Event]) -> Unit {
  match inline {
    Text(t) => events.push(Event::TextEvent(t))
    Emphasis(children) => {
      events.push(Event::StartInline("em"))
      for child in children {
         inline_to_events(child, events)
      }
      events.push(Event::EndInline("em"))
    }
    Strong(children) => {
      events.push(Event::StartInline("strong"))
      for child in children {
         inline_to_events(child, events)
      }
      events.push(Event::EndInline("strong"))
    }
    _ => { } // unsupported inlines
  }
}

pub fn render_html(events: Array[Event]) -> String {
  let mut output = ""
  for ev in events {
    match ev {
      StartBlock(tag) => output += "<" + tag + ">\n"
      EndBlock(tag) => output += "</" + tag + ">\n"
      StartInline(tag) => output += "<" + tag + ">"
      EndInline(tag) => output += "</" + tag + ">"
      TextEvent(t) => output += escape_html(t)
      SelfClosing(tag) => output += "<" + tag + " />\n"
    }
  }
  output
}

fn escape_html(text: String) -> String {
  // Simplistic escaping for MVP
  let mut res = ""
  for i = 0; i < text.length(); i = i + 1 {
    match text[i] {
      '<' => res += "&lt;"
      '>' => res += "&gt;"
      '&' => res += "&amp;"
      '"' => res += "&quot;"
      c => res += c.to_string()
    }
  }
  res
}
