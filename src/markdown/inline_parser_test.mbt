///|
test "parse inline text" {
  let inlines = parse_inline("hello world")
  if inlines.length() != 1 {
    abort("expected 1 inline")
  }
}

///|
test "parse emphasis" {
  let inlines = parse_inline("hello *world*")
  if inlines.length() != 2 {
    abort("expected 2 inlines")
  }
}

///|
test "parse strong" {
  let inlines = parse_inline("hello **world**")
  if inlines.length() != 2 {
    abort("expected 2 inlines")
  }
}
