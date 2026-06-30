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
