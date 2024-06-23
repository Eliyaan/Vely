
fn process(app App, id int) string {
	mut s := ''
	if id != -1 {
		b := app.blocks[blocks.find_index(id, app)]
		match b {
			blocks.Condition {
				match Vari.from(b.variant) or { panic('variant not handled ${b.variant}') } {
					.condition {
						for nb, t in b.text {
							if nb == 0 {
								s += '\nif '
							} else if nb == b.text.len - 1 {
								s += '\nelse '
							} else {
								s += '\nelse if'
							}
							s += t[1].text
							s += ' {'
							s += process(app, b.inner[nb])
							s += '\n}'
						}
						s += process(app, b.output)
					}
					.@match {
						s += '\nmatch '
						s += b.text[0][1].text
						s += ' {'
						for nb, t in b.text[1..] {
							s += '\n'
							if nb == b.text.len - 2 {
								s += 'else '
							} else {
								s += t[0].text
							}
							s += ' {'
							s += process(app, b.inner[nb])
							s += '\n}'
						}
						s += '\n}'
						s += process(app, b.output)
					}
					else {
						panic('condition variant ${b.variant} not handled in v file output')
					}
				}
			}
			blocks.Function {
				s += '\nfn '
				s += b.text[0][1].text // name
				s += '('
				mut i := 3
				mut args := false
				mut returns := 0
				for i < b.text[0].len {
					if b.text[0][i] is blocks.InputT {
						s += b.text[0][i].text
						if args {
							returns += 1
							if returns > 1 {
								s += ', '
							}
						}
					} else if b.text[0][i] is blocks.ButtonT {
						if !args {
							s += ')'
							args = true
						}
						// /!\ might need to handle multiple return's brackets
					}
					i += 1
				}
				s += ' {'
				if b.text[0][1].text.trim_space() == 'main' {
					s += '\nunbuffer_stdout() // useful for Vely, when running the program (added automatically by Vely)'
				}
				s += process_inner(app, id)
				s += '\n}'
			}
			blocks.InputOutput {
				match Vari.from(b.variant) or { panic('variant not handled ${b.variant}') } {
					.declare {
						s += '\n'
						if b.text[0][1].text == '[x]' {
							s += 'mut '
						}
						s += b.text[0][3].text
						s += ':= '
						s += b.text[0][5].text
						s += process(app, b.output)
					}
					.println {
						s += '\n'
						s += 'println('
						s += b.text[0][1].text
						s += ')'
						s += process(app, b.output)
					}
					else {
						panic('i_o variant ${b.variant} not handled in v file output')
					}
				}
			}
			blocks.Input {
				match Vari.from(b.variant) or { panic('variant not handled ${b.variant}') } {
					.panic {
						s += '\n'
						s += 'panic('
						s += b.text[0][1].text
						s += ')'
					}
					.@return {
						s += '\nreturn'
					}
					else {
						panic('input variant ${b.variant} not handled in v file output')
					}
				}
			}
			blocks.Loop {
				match Vari.from(b.variant) or { panic('variant not handled ${b.variant}') } {
					.for_range {
						s += '\nfor '
						s += b.text[0][1].text // inc var
						s += ' in '
						s += b.text[0][3].text // lower bound
						s += ' .. '
						s += b.text[0][5].text // upper bound
						s += ' {'
						s += process(app, b.inner[0])
						s += '\n}'
						s += process(app, b.output)
					}
					.for_c {
						s += '\nfor '
						s += b.text[0][1].text // inc var
						s += ' := '
						s += b.text[0][3].text // start value
						s += ';'
						s += b.text[0][5].text // condition
						s += ';'
						s += b.text[0][7].text // inc
						s += ' {'
						s += process(app, b.inner[0])
						s += '\n}'
						s += process(app, b.output)
					}
					.for_bool {
						s += '\nfor '
						s += b.text[0][1].text // condition
						s += ' {'
						s += process(app, b.inner[0])
						s += '\n}'
						s += process(app, b.output)
					}
					else {
						panic('loop variant ${b.variant} not handled in v file output')
					}
				}
			}
			else {
				panic('Block variant ${b} not handled')
			}
		}
	}
	return s
}
