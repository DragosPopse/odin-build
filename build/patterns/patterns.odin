package patterns

import "core:unicode/utf8"

// continuation byte?
is_cont :: proc(b: byte) -> bool {
	return b & 0xc0 == 0x80
}

utf8_peek :: proc(bytes: string) -> (c: rune, size: int, ok: bool) {
	c, size = utf8.decode_rune_in_string(bytes)

    ok = c != utf8.RUNE_ERROR
	return
}

utf8_prev :: proc(bytes: string, a, b: int) -> int {
	b := b

	for a < b && is_cont(bytes[b - 1]) {
		b -= 1
	}

	return a < b ? b - 1 : a
}

utf8_next :: proc(bytes: string, a: int) -> int {
	a := a
	b := len(bytes)

	for a < b - 1 && is_cont(bytes[a + 1]) {
		a += 1
	}

	return a < b ? a + 1 : b
}


match :: proc(pattern, str: string) -> bool {
    s_len := len(str)
    p_len := len(pattern)
    if p_len == 0 && s_len == 0 do return true
    pat_char, _, _ := utf8_peek(pattern)
    str_char, _, _ := utf8_peek(str)
    next_pat_index := utf8_next(pattern, 0)
    next_str_index := utf8_next(pattern, 0)
    next_pat := pattern[next_pat_index:] if next_pat_index < p_len else ""
    next_str := str[next_str_index:] if next_str_index < s_len else ""
    if pat_char == '?' || pat_char == str_char do return s_len != 0 && match(next_pat, next_str)
    if pat_char == '*' do return match(next_pat, str) || (s_len != 0 && match(pattern, next_str))
    return false
}