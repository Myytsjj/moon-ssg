# moon-cmark

`moon-cmark` is a high-performance, CommonMark compliant Markdown parser and HTML renderer written entirely in MoonBit.
It is heavily inspired by the Rust `pulldown-cmark` library, focusing on an event-driven architecture that allows for high extensibility and low memory overhead.

## Features

- **Event-Stream Architecture**: Parse markdown into a stream of events that you can intercept, modify, or render to any format.
- **Safe HTML Rendering**: Built-in HTML renderer with basic XSS protection (HTML escaping).
- **Zero Dependencies**: Pure MoonBit implementation.

## Usage

```moonbit
let md = "### Hello *MoonBit*\n\nThis is a **test**."
let parser = Parser::new(md)
let blocks = parser.parse()
let events = to_events(blocks)
let html = render_html(events)
println(html)
```

## Status

Currently in early development for the MoonBit OSC2026 competition.

## License
MIT
