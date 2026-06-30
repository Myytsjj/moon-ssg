// Simple inline parser

pub fn parse_inline(text: String) -> Array[Inline] {
  // A very basic implementation that just returns text
  // Later it will handle *em* and **strong**
  [Inline::Text(text)]
}
