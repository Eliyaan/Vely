module main

import blocks
import gg
import gx
import os
import time

// TODO: the (+) to be able to add args (ButtonT irrc)
// TODO: terminal width changing
// TODO: text cursor & indicator of selected input box
// ?TODO: temporary change of the children size of the snapped against block (like scratch does)
// TODO: different block text modes (pseudocode and V's syntax)

const menu_width = 365
const win_width = 1300
const win_height = 700
const bg_color = gg.Color{166, 173, 200, 255}
const menu_color = gg.Color{127, 132, 156, 255}
const console_color = gg.Color{49, 50, 68, 255}
const console_cfg = gx.TextCfg{
	size:  16
	color: gg.Color{205, 214, 244, 255}
}
const console_size = 500

const empty_contenant_h = blocks.blocks_h * 2 + blocks.attach_decal_y * 2
const fn_declare = init_block(blocks.Function{
	variant:   int(Vari.function)
	x:         30
	y:         10
	base_size: empty_contenant_h
}) or { panic(err) }
const condition = init_block(blocks.Condition{
	variant:   int(Vari.condition)
	x:         30
	y:         10
	base_size: empty_contenant_h
}) or { panic(err) }
const @match = init_block(blocks.Condition{
	variant:   int(Vari.@match)
	x:         30
	y:         80
	base_size: empty_contenant_h * 2 - blocks.blocks_h
}) or { panic(err) }
const for_range = init_block(blocks.Loop{
	variant:   int(Vari.for_range)
	x:         30
	y:         10
	base_size: empty_contenant_h
}) or { panic(err) }
const for_c = init_block(blocks.Loop{
	variant:   int(Vari.for_c)
	x:         30
	y:         80
	base_size: empty_contenant_h
}) or { panic(err) }
const for_bool = init_block(blocks.Loop{
	variant:   int(Vari.for_bool)
	x:         30
	y:         160
	base_size: empty_contenant_h
}) or { panic(err) }
const @return = init_block(blocks.Input{
	variant:   int(Vari.@return)
	x:         30
	y:         10
	base_size: blocks.blocks_h
}) or { panic(err) }
const panic = init_block(blocks.Input{
	variant:   int(Vari.panic)
	x:         30
	y:         50
	base_size: blocks.blocks_h
}) or { panic(err) }
const declare = init_block(blocks.InputOutput{
	variant:   int(Vari.declare)
	x:         30
	y:         10
	base_size: blocks.blocks_h
}) or { panic(err) }
const assign = init_block(blocks.InputOutput{
	variant:   int(Vari.assign)
	x:         30
	y:         50
	base_size: blocks.blocks_h
}) or { panic(err) }
const println = init_block(blocks.InputOutput{
	variant:   int(Vari.println)
	x:         30
	y:         90
	base_size: blocks.blocks_h
}) or { panic(err) }
const call = init_block(blocks.InputOutput{
	variant:   int(Vari.call)
	x:         30
	y:         130
	base_size: blocks.blocks_h
}) or { panic(err) }

enum MenuMode {
	function
	condition
	i_o
	input
	loop
}

@[heap]
struct App {
mut:
	ctx                  &gg.Context = unsafe { nil }
	square_size          int         = 10
	blocks               []blocks.Blocks
	draw_order	     []int
	max_id               int
	menu_mode            MenuMode
	clicked_block        int = -1
	block_click_offset_x int
	block_click_offset_y int
	block_click_x        int
	block_click_y        int
	input_id             int = -1
	input_nb             int
	input_txt_nb         int
	show_output          bool
	program_running      bool
	prog                 os.Process
	p_output             string
	console_scroll       int
	win_size             gg.Size
	palette blocks.ColorPalette = Palette{}
}

struct Palette {
mut:
	input_color gg.Color = gg.Color{235, 244, 254, 255}
	input_selected_color gg.Color = gg.Color{157, 240, 255, 255}
	con_color gg.Color = gg.Color{249, 226, 175, 255}
	loop_color gg.Color = gg.Color{166, 227, 161, 255}
	io_color gg.Color = gg.Color{250, 179, 135, 255} // mocha peach
	in_color gg.Color = gg.Color{243, 139, 168, 255} // mocha red
	func_color gg.Color = gg.Color{245, 194, 231, 255} // mocha pink
	text_cfg gx.TextCfg = gx.TextCfg{
		color:          gg.Color{17, 17, 27, 255}
		size:           16
		vertical_align: .middle
	}
	input_cfg gx.TextCfg = gx.TextCfg{
		color:          gg.Color{30, 30, 46, 255}
		size:           16
		vertical_align: .middle
	}
}

enum Vari { // Variants
	// Functions
	function
	// Conditions
	condition
	@match
	// Loops
	for_range
	for_c
	for_bool
	// Inputs (no return)
	@return
	panic
	// Input outputs
	declare
	assign
	println
	call
}

// MAIN BODY

fn main() {
	mut app := App{}
	app.ctx = gg.new_context(
		width:         win_width
		height:        win_height
		create_window: true
		window_title:  '- Application -'
		user_data:     &app
		bg_color:      bg_color
		frame_fn:      on_frame
		event_fn:      on_event
		sample_count:  2
		font_path:     blocks.font_path
	)

	app.ctx.run()
}

fn on_event(e &gg.Event, mut app App) {
	if app.input_id != -1 && e.char_code != 0 && e.char_code < 128 {
		i := blocks.find_index(app.input_id, app)

		if app.input_nb < 0 || app.input_nb >= app.blocks[i].text.len {
			panic('app.input_nb not valid ${app.input_nb} / ${app.blocks[i].text.len}')
		}
		if app.input_txt_nb < 0 || app.input_txt_nb >= app.blocks[i].text[app.input_nb].len {
			panic('app.input_txt_ not valid ${app.input_txt_nb} / ${app.blocks[i].text[app.input_nb].len}')
		}
		app.blocks[i].text[app.input_nb][app.input_txt_nb].text += u8(e.char_code).ascii_str()
	}
	app.win_size = gg.window_size()
	match e.typ {
		.key_down {
			match e.key_code {
				.escape {
					app.ctx.quit()
				}
				.enter {
					app.input_id = -99
				}
				.backspace {
					if app.input_id >= 0 {
						i := blocks.find_index(app.input_id, app)
						if app.input_nb < 0 || app.input_nb >= app.blocks[i].text.len {
							panic('app.input_nb not valid ${app.input_nb} / ${app.blocks[i].text.len}')
						}
						if app.input_txt_nb < 0
							|| app.input_txt_nb >= app.blocks[i].text[app.input_nb].len {
							panic('app.input_txt_ not valid ${app.input_txt_nb} / ${app.blocks[i].text[app.input_nb].len}')
						}
						app.blocks[i].text[app.input_nb][app.input_txt_nb].text = app.blocks[i].text[app.input_nb][app.input_txt_nb].text#[..-1]
					}
				}
				else {}
			}
		}
		.mouse_scroll {
			app.console_scroll(int(e.scroll_y))
		}
		.mouse_down {
			app.input_id = -99
			x := int(e.mouse_x)
			y := int(e.mouse_y)
			if app.check_clicks_menu(x, y) or { panic(err) } {
			} else if app.is_close_console_clicked(x, y) {
				app.show_output = false
			} else if app.is_console_button_clicked(x, y) {
				app.console_button_clicked()
			} else {
				app.handle_blocks_click(x, y)
			}
		}
		.mouse_up {
			if app.clicked_block != -1 {
				if e.mouse_x > menu_width {
					app.place_snap(int(e.mouse_x), int(e.mouse_y))
				} else {
					i := blocks.find_index(app.clicked_block, app)
					app.blocks.delete(i)
					app.draw_order.delete(app.draw_order.index(app.clicked_block))
				}
				app.clicked_block = -1
			}
		}
		else {}
	}
	app.handle_clicked_block(int(e.mouse_x), int(e.mouse_y))
}

fn on_frame(mut app App) {
	// Draw
	app.ctx.begin()
	app.show_blocks()
	app.show_blocks_menu()
	if app.clicked_block != -1 {
		app.blocks[blocks.find_index(app.clicked_block, app)].show(app)
	}
	app.show_console()
	app.ctx.end()
}

// DRAW

fn (mut app App) show_blocks() {
	for i in app.draw_order {
		if i != app.clicked_block {
			app.blocks[blocks.find_index(i, app)].show(app)
		}
	}
}

fn (mut app App) show_console() {
	run_color := if app.show_output {
		if app.program_running {
			gg.Color{255, 0, 0, 255}
		} else {
			gg.Color{0, 255, 0, 255}
		}
	} else {
		gg.Color{128, 128, 128, 255}
	}
	if app.show_output {
		app.ctx.draw_rect_filled(app.win_size.width - console_size, 0, console_size, 2000,
			console_color)
		app.ctx.draw_square_filled(app.win_size.width - console_size + 5, 5, 20, gg.Color{255, 0, 0, 255})
		split_out := app.p_output.split('\n')
		if app.p_output.len > 1_000_000 {
			app.kill_prog()
		}
		for n, line in split_out {
			y := 40 + 18 * n - app.console_scroll * 18
			if y < app.win_size.height + 16 && y > 30 {
				app.ctx.draw_text(app.win_size.width - console_size + 5, y, line, console_cfg)
			}
		}
	}
	app.ctx.draw_square_filled(app.win_size.width - 25, 5, 20, run_color)
}

// TEXT PROGRAM

fn (mut app App) kill_prog() {
	app.program_running = false
	app.prog.signal_kill()
}

fn run_prog(mut app App) {
	defer {
		app.prog.close()
		app.prog.wait()
	}

	app.prog.set_args(['-g', 'run', 'output/output.v'])
	app.prog.set_redirect_stdio()
	app.prog.run()
	for app.prog.is_alive() {
		// check if there is any input from the user (it does not block, if there is not):
		if oline := app.prog.pipe_read(.stdout) {
			app.p_output += oline
		}
		if eline := app.prog.pipe_read(.stderr) {
			app.p_output += eline
		}
		time.sleep(1 * time.millisecond)
	}
	app.program_running = false
}

fn v_file(app App) {
	mut fns := []blocks.Blocks{}
	for b in app.blocks {
		if b is blocks.Function {
			fns << b
		}
	}
	mut file := ''
	for f in fns {
		file += process_id_to_txt(app, f.id)
	}
	os.write_file('output/output.v', file) or { panic(err) }
}

fn process_inner(app App, id int) string {
	b := app.blocks[blocks.find_index(id, app)]
	mut s := ''
	for id_inner in b.inner {
		s += process_id_to_txt(app, id_inner)
	}
	return s
}

// CONSOLE

fn (app App) is_close_console_clicked(x int, y int) bool {
	console_x := app.win_size.width - console_size
	return app.show_output && x >= console_x + 5 && x < console_x + 25 && y >= 5 && y < 25
}

fn (app App) is_console_button_clicked(x int, y int) bool {
	return x >= app.win_size.width - 25 && x < app.win_size.width - 5 && y >= 5 && y < 25
}

fn (mut app App) console_button_clicked() {
	if app.show_output {
		if app.program_running {
			app.kill_prog()
		} else {
			app.p_output = ''
			app.console_scroll = 0
			app.program_running = true
			if !os.exists('output') {
				os.mkdir('output', os.MkdirParams{}) or { panic(err) }
			}
			v_file(app)
			os.execute('v fmt -w output/output.v')
			v_exe := os.find_abs_path_of_executable('v') or {
				eprintln('Vely needs a v executable in your PATH. Please install V to see it in action.')
				return
			}
			app.prog = os.new_process(v_exe)
			spawn run_prog(mut app)
		}
	} else {
		app.show_output = true
	}
}

fn (mut app App) console_scroll(scroll int) {
	if app.show_output {
		app.console_scroll += scroll
		len := app.p_output.split('\n').len
		if app.console_scroll > len {
			app.console_scroll = len
		} else if app.console_scroll < 0 {
			app.console_scroll = 0
		}
	}
}

// BLOCKS

fn init_block(b blocks.Blocks) !blocks.Blocks {
	mut block := b
	match mut block {
		blocks.Function {
			block.text = [
				[blocks.Text(blocks.JustT{'fn'}), blocks.InputT{'name'},
					blocks.JustT{'('}, blocks.ButtonT{'(+)'},
					blocks.JustT{')'}, blocks.ButtonT{'(+)'}],
			]
			block.attachs_rel_y = [blocks.blocks_h]
		}
		blocks.Condition {
			block.text << match Vari.from(block.variant)! {
				.condition {
					[blocks.Text(blocks.JustT{'if'}), blocks.InputT{'1 > 0'},
						blocks.JustT{'is true (+)'}]
				}
				.@match {
					[blocks.Text(blocks.JustT{'if'}), blocks.InputT{'0'},
						blocks.JustT{'is'}, blocks.InputT{'0'},
						blocks.ButtonT{'(+)'}]
				}
				else {
					panic('${block.variant} not supported')
				}
			}
			block.attachs_rel_y = []int{len: block.size_in.len, init: blocks.blocks_h +
				(block.size_in[index] + blocks.blocks_h + 2 * blocks.attach_decal_y) * (index + 1)}
			block.attachs_rel_y.insert(0, blocks.blocks_h)
			for nb in 0 .. block.size_in.len - 1 {
				block.text << match Vari.from(block.variant)! {
					.condition {
						if nb == block.size_in.len - 2 {
							[blocks.Text(blocks.JustT{'else'})]
						} else {
							[blocks.Text(blocks.JustT{'else if'}), blocks.InputT{'0 < 1'}]
						}
					}
					.@match {
						if nb == block.size_in.len - 2 {
							[blocks.Text(blocks.JustT{'else'})]
						} else {
							[blocks.Text(blocks.InputT{'0'})]
						}
					}
					else {
						panic('${block.variant} not supported')
					}
				}
			}
		}
		blocks.Loop {
			expand_h := block.size_in[0] + blocks.blocks_h + 2 * blocks.attach_decal_y
			block.attachs_rel_y = [blocks.blocks_h, blocks.blocks_h + expand_h]
			block.text = match Vari.from(block.variant)! {
				.for_range {
					[
						[blocks.Text(blocks.JustT{'for each'}), blocks.InputT{'i'},
							blocks.JustT{'in'}, blocks.InputT{'0'},
							blocks.JustT{'..'}, blocks.InputT{'5'}],
					]
				}
				.for_bool {
					[
						[blocks.Text(blocks.JustT{'while'}), blocks.InputT{'0 == 0'},
							blocks.JustT{'is true'}],
					]
				}
				.for_c {
					[
						[blocks.Text(blocks.JustT{'start'}), blocks.InputT{'i'},
							blocks.JustT{':='}, blocks.InputT{'0'},
							blocks.JustT{'; while'}, blocks.InputT{'1 == 1'},
							blocks.JustT{'->'}, blocks.InputT{'i += 1'}],
					]
				}
				else {
					panic('${block.variant} not handled')
				}
			}
		}
		blocks.Input {
			block.text = match Vari.from(block.variant)! {
				.@return {
					[[blocks.Text(blocks.JustT{'return'})]]
				}
				.panic {
					[
						[blocks.Text(blocks.JustT{'panic('}), blocks.InputT{'"Problem!"'},
							blocks.JustT{')'}],
					]
				}
				else {
					panic('${block.variant} not handled')
				}
			}
			block.attachs_rel_y = []
		}
		blocks.InputOutput {
			block.text = match Vari.from(block.variant)! {
				.declare {
					[
						[blocks.Text(blocks.JustT{'new'}), blocks.ButtonT{'[x]'},
							blocks.JustT{'mut'}, blocks.InputT{'a'},
							blocks.JustT{':='}, blocks.InputT{'0'}],
					]
				}
				.assign {
					[
						[blocks.Text(blocks.InputT{'a'}), blocks.JustT{'='},
							blocks.InputT{'0'}],
					]
				}
				.println {
					[
						[blocks.Text(blocks.JustT{'println('}), blocks.InputT{'"Hello!"'},
							blocks.JustT{')'}],
					]
				}
				.call {
					[
						[blocks.Text(blocks.InputT{'funct'}), blocks.JustT{'('},
							blocks.ButtonT{'(+)'}, blocks.JustT{')'}],
					]
				}
				else {
					panic('${block.variant} not handled')
				}
			}
			block.attachs_rel_y = [blocks.blocks_h]
		}
		else {
			panic('${block} not handled')
		}
	}
	return block
}

fn process_id_to_txt(app App, id int) string {
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
							s += process_id_to_txt(app, b.inner[nb])
							s += '\n}'
						}
						s += process_id_to_txt(app, b.output)
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
							s += process_id_to_txt(app, b.inner[nb])
							s += '\n}'
						}
						s += '\n}'
						s += process_id_to_txt(app, b.output)
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
						s += ' := '
						s += b.text[0][5].text
						s += process_id_to_txt(app, b.output)
					}
					.assign {
						s += '\n'
						s += b.text[0][0].text
						s += ' = '
						s += b.text[0][2].text
						s += process_id_to_txt(app, b.output)
					}
					.println {
						s += '\n'
						s += 'println('
						s += b.text[0][1].text
						s += ')'
						s += process_id_to_txt(app, b.output)
					}
					.call {
						s += '\n'
						s += b.text[0][0].text
						s += '('
						// TODO: handle args
						s += ')'
						s += process_id_to_txt(app, b.output)
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
						s += process_id_to_txt(app, b.inner[0])
						s += '\n}'
						s += process_id_to_txt(app, b.output)
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
						s += process_id_to_txt(app, b.inner[0])
						s += '\n}'
						s += process_id_to_txt(app, b.output)
					}
					.for_bool {
						s += '\nfor '
						s += b.text[0][1].text // condition
						s += ' {'
						s += process_id_to_txt(app, b.inner[0])
						s += '\n}'
						s += process_id_to_txt(app, b.output)
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

fn (mut app App) handle_blocks_click(x int, y int) {
	for i := app.draw_order.len - 1; i >= 0; i-- {
		elem := app.blocks[blocks.find_index(app.draw_order[i], app)]
		if elem.is_clicked(x, y) {
			if app.handle_click_block_element(elem, x, y) { // if click on elem of the block
				break
			} else { // then click is on the rest of the block
				app.clicked_block = elem.id
				app.set_block_offset(x, y, elem)
				app.block_click_x = elem.x
				app.block_click_y = elem.y
				break
			}
		}
	}
}

fn (mut app App) handle_click_block_element(elem blocks.Blocks, x int, y int) bool {
	mut decal_y := blocks.blocks_h
	for nb, txts in elem.text {
		mut decal_x := blocks.attach_w / 2
		if x >= elem.x + decal_x - blocks.input_margin {
			for nb_txt, txt in txts {
				match txt {
					blocks.InputT {
						decal_x += txt.text.len * blocks.text_size
						x_smaller_end_txt := x <= decal_x + elem.x + blocks.input_margin
						// TODO: take into account text size
						y_smaller_text_bot := y <= decal_y + elem.y
						y_greater_text_top := y >= decal_y - blocks.blocks_h + elem.y
						decal_x += blocks.text_size
						if x_smaller_end_txt && y_smaller_text_bot && y_greater_text_top {
							app.input_id = elem.id
							app.input_nb = nb
							app.input_txt_nb = nb_txt
							return true
						}
					}
					else { // clicked on not clickable elem
						decal_x += (txt.text.len + 1) * blocks.text_size
						x_smaller_end_txt := x <= decal_x + elem.x - blocks.input_margin // - if before an InputT
						// TODO: take into account text size
						y_smaller_text_bot := y <= decal_y + elem.y
						y_greater_text_top := y >= decal_y - blocks.blocks_h + elem.y
						if x_smaller_end_txt && y_smaller_text_bot && y_greater_text_top {
							return false
						}
					}
				}
				if !(txt is blocks.JustT) {
				}
			}
		}
		decal_y += blocks.blocks_h + elem.size_in[nb] or { 0 }
	}
	return false
}

fn (mut app App) handle_clicked_block(mouse_x int, mouse_y int) {
	if app.clicked_block != -1 {
		idx := blocks.find_index(app.clicked_block, app)
		mut b := &app.blocks[idx]
		app.draw_order.delete(app.draw_order.index(app.clicked_block))
		app.draw_order << app.clicked_block
		app.unpropagate_size(idx)
		b.detach(mut app)
		b.x = mouse_x - app.block_click_offset_x
		b.y = mouse_y - app.block_click_offset_y
		b.check_block_is_snapping_here(app)
		// propagate pos to children		
		mut child_in_ids := [b.output]
		child_in_ids << b.inner
		for child_in_ids.len > 0 {
			id_child := child_in_ids.pop()
			if id_child != -1 {
				app.draw_order.delete(app.draw_order.index(id_child))
				app.draw_order << id_child
				i := blocks.find_index(id_child, app)
				app.blocks[i].x += b.x - app.block_click_x
				app.blocks[i].y += b.y - app.block_click_y
				child_in_ids << app.blocks[i].inner
				child_in_ids << app.blocks[i].output
			}
		}
		app.block_click_x = b.x
		app.block_click_y = b.y
	}
}

fn (mut app App) place_snap(x int, y int) {
	i := blocks.find_index(app.clicked_block, app)
	app.blocks[i].x = x - app.block_click_offset_x
	app.blocks[i].y = y - app.block_click_offset_y
	if app.blocks[i] !is blocks.Function {
		for mut other in app.blocks {
			if other !is blocks.Input {
				snap_attach_i := app.blocks[i].is_snapping(other)
				if snap_attach_i != -1 { // snapped
					app.snap_update_id_y(i, mut other, snap_attach_i)
					app.propagate_size(i)
					break
				}
			}
		}
	}
}

fn (mut app App) unpropagate_size(block_i int) {
	if app.blocks[block_i].input != -1 {
		mut size := 0
		mut tmp_block_id := app.blocks[block_i].id
		for tmp_block_id != -1 {
			tmp_block := app.blocks[blocks.find_index(tmp_block_id, app)]
			size += tmp_block.base_size
			for elem in tmp_block.size_in {
				size += elem
			}
			tmp_block_id = tmp_block.output
		}
		mut child_id := app.blocks[block_i].id
		tmp_block_id = app.blocks[block_i].input
		for tmp_block_id != -1 {
			mut tmp_block := &app.blocks[blocks.find_index(tmp_block_id, app)]
			child_inner_i := app.blocks[blocks.find_index(child_id, app)].is_snapping(tmp_block)
			if child_inner_i != -1 && child_inner_i < tmp_block.size_in.len {
				tmp_block.size_in[child_inner_i] -= size
				for c_id in tmp_block.inner[child_inner_i + 1..] {
					mut child_in_ids := [c_id]
					for child_in_ids.len > 0 {
						id := child_in_ids.pop()
						if id != -1 {
							app.blocks[blocks.find_index(id, app)].y -= size
							child_in_ids << app.blocks[blocks.find_index(id, app)].inner
							child_in_ids << app.blocks[blocks.find_index(id, app)].output
						}
					}
				}
				mut child_in_ids := [tmp_block.output]
				for child_in_ids.len > 0 {
					id := child_in_ids.pop()
					if id != -1 {
						app.blocks[blocks.find_index(id, app)].y -= size
						child_in_ids << app.blocks[blocks.find_index(id, app)].inner
						child_in_ids << app.blocks[blocks.find_index(id, app)].output
					}
				}
			}
			child_id = tmp_block_id
			tmp_block_id = tmp_block.input
		}
		// only when detach single
		// app.blocks[block_i].size_in = []int{len: app.blocks[block_i].size_in.len}
	}
}

fn (mut app App) propagate_size(block_i int) {
	mut size := 0
	mut tmp_block_id := app.blocks[block_i].id
	for tmp_block_id != -1 {
		tmp_block := app.blocks[blocks.find_index(tmp_block_id, app)]
		size += tmp_block.base_size
		for elem in tmp_block.size_in {
			size += elem
		}
		tmp_block_id = tmp_block.output
	}
	mut child_id := app.blocks[block_i].id
	tmp_block_id = app.blocks[block_i].input
	for tmp_block_id != -1 {
		mut tmp_block := &app.blocks[blocks.find_index(tmp_block_id, app)]
		child_inner_i := app.blocks[blocks.find_index(child_id, app)].is_snapping(tmp_block)
		if child_inner_i != -1 && child_inner_i < tmp_block.size_in.len {
			tmp_block.size_in[child_inner_i] += size
			for c_id in tmp_block.inner[child_inner_i + 1..] {
				mut child_in_ids := [c_id]
				for child_in_ids.len > 0 {
					id := child_in_ids.pop()
					if id != -1 {
						app.blocks[blocks.find_index(id, app)].y += size
						child_in_ids << app.blocks[blocks.find_index(id, app)].inner
						child_in_ids << app.blocks[blocks.find_index(id, app)].output
					}
				}
			}
			mut child_in_ids := [tmp_block.output]
			for child_in_ids.len > 0 {
				id := child_in_ids.pop()
				if id != -1 {
					app.blocks[blocks.find_index(id, app)].y += size
					child_in_ids << app.blocks[blocks.find_index(id, app)].inner
					child_in_ids << app.blocks[blocks.find_index(id, app)].output
				}
			}
		}
		child_id = tmp_block_id
		tmp_block_id = tmp_block.input
	}
}

fn (mut app App) snap_update_id_y(id int, mut other blocks.Blocks, snap_attach_i int) {
	if snap_attach_i == other.attachs_rel_y.len - 1 && other !is blocks.Function {
		app.blocks[id].x = other.x
		if mut other is blocks.InputOutput {
			other.output = app.clicked_block
		} else if mut other is blocks.Condition {
			other.output = app.clicked_block
		} else if mut other is blocks.Loop {
			other.output = app.clicked_block
		}
	} else {
		app.blocks[id].x = other.x + blocks.attach_w
		if mut other is blocks.Function {
			other.inner[0] = app.clicked_block
		} else if mut other is blocks.Condition {
			other.inner[snap_attach_i] = app.clicked_block
		} else if mut other is blocks.Loop {
			other.inner[0] = app.clicked_block
		}
	}
	mut b := &app.blocks[id]
	if mut b is blocks.InputOutput {
		b.input = other.id
	} else if mut b is blocks.Input {
		b.input = other.id
	} else if mut b is blocks.Loop {
		b.input = other.id
	} else if mut b is blocks.Condition {
		b.input = other.id
	}
	mut decal := 0
	for decal_y in other.size_in[..snap_attach_i] {
		decal += decal_y
	}
	b.y = other.attachs_rel_y[snap_attach_i] + other.y + decal
}

// BLOCKS MENU

fn (app App) show_blocks_menu() {
	app.ctx.draw_rect_filled(0, 0, menu_width, 2000, menu_color)
	app.ctx.draw_square_filled(0, 0, 20, app.palette.func_color)
	app.ctx.draw_square_filled(0, 20, 20, app.palette.con_color)
	app.ctx.draw_square_filled(0, 40, 20, app.palette.io_color)
	app.ctx.draw_square_filled(0, 60, 20, app.palette.in_color)
	app.ctx.draw_square_filled(0, 80, 20, app.palette.loop_color)
	match app.menu_mode {
		.function {
			fn_declare.show(app)
		}
		.condition {
			condition.show(app)
			@match.show(app)
		}
		.i_o {
			declare.show(app)
			assign.show(app)
			println.show(app)
			call.show(app)
		}
		.input {
			@return.show(app)
			panic.show(app)
		}
		.loop {
			for_range.show(app)
			for_c.show(app)
			for_bool.show(app)
		}
	}
}

fn (mut app App) check_clicks_menu(x int, y int) !bool {
	app.max_id += 1
	id := app.max_id
	if x <= 20 {
		app.max_id -= 1
		if y < 20 {
			app.menu_mode = .function
		} else if y < 40 {
			app.menu_mode = .condition
		} else if y < 60 {
			app.menu_mode = .i_o
		} else if y < 80 {
			app.menu_mode = .input
		} else if y < 100 {
			app.menu_mode = .loop
		}
	} else {
		match app.menu_mode {
			.function {
				match true {
					fn_declare.is_clicked(x, y) {
						app.set_block_offset(x, y, fn_declare)
						app.blocks << init_block(blocks.Function{id, int(Vari.function), x, y, [], -1, -1, [
							-1,
						], [], [], [], [], empty_contenant_h, [
							0,
						]})!
					}
					else {
						app.max_id -= 1
					}
				}
			}
			.condition {
				match true {
					condition.is_clicked(x, y) {
						app.set_block_offset(x, y, condition)
						app.blocks << init_block(blocks.Condition{id, int(Vari.condition), x, y, [], [], -1, -1, [
							-1,
						], [], empty_contenant_h, [0]})!
					}
					@match.is_clicked(x, y) {
						app.set_block_offset(x, y, @match)
						app.blocks << init_block(blocks.Condition{id, int(Vari.@match), 30, 50, [], [], -1, -1, [
							-1,
							-1,
						], [], empty_contenant_h * 2 - blocks.blocks_h, [
							0,
							0,
						]})!
					}
					else {
						app.max_id -= 1
					}
				}
			}
			.i_o {
				match true {
					declare.is_clicked(x, y) {
						app.set_block_offset(x, y, declare)
						app.blocks << init_block(blocks.InputOutput{id, int(Vari.declare), 30, 10, [], [], -1, -1, [], [], blocks.blocks_h, []})!
					}
					assign.is_clicked(x, y) {
						app.set_block_offset(x, y, assign)
						app.blocks << init_block(blocks.InputOutput{id, int(Vari.assign), 30, 10, [], [], -1, -1, [], [], blocks.blocks_h, []})!
					}
					println.is_clicked(x, y) {
						app.set_block_offset(x, y, println)
						app.blocks << init_block(blocks.InputOutput{id, int(Vari.println), 30, 10, [], [], -1, -1, [], [], blocks.blocks_h, []})!
					}
					call.is_clicked(x, y) {
						app.set_block_offset(x, y, call)
						app.blocks << init_block(blocks.InputOutput{id, int(Vari.call), 30, 10, [], [], -1, -1, [], [], blocks.blocks_h, []})!
					}
					else {
						app.max_id -= 1
					}
				}
			}
			.input {
				match true {
					@return.is_clicked(x, y) {
						app.set_block_offset(x, y, @return)
						app.blocks << init_block(blocks.Input{id, int(Vari.@return), 30, 10, [], -1, -1, [], [], [], blocks.blocks_h, []})!
					}
					panic.is_clicked(x, y) {
						app.set_block_offset(x, y, panic)
						app.blocks << init_block(blocks.Input{id, int(Vari.panic), 30, 10, [], -1, -1, [], [], [], blocks.blocks_h, []})!
					}
					else {
						app.max_id -= 1
					}
				}
			}
			.loop {
				match true {
					for_range.is_clicked(x, y) {
						app.set_block_offset(x, y, for_range)
						app.blocks << init_block(blocks.Loop{id, int(Vari.for_range), x, y, [], [], -1, -1, [
							-1,
						], -1, [], empty_contenant_h, [
							0,
						]})!
					}
					for_c.is_clicked(x, y) {
						app.set_block_offset(x, y, for_c)
						app.blocks << init_block(blocks.Loop{id, int(Vari.for_c), x, y, [], [], -1, -1, [
							-1,
						], -1, [], empty_contenant_h, [
							0,
						]})!
					}
					for_bool.is_clicked(x, y) {
						app.set_block_offset(x, y, for_bool)
						app.blocks << init_block(blocks.Loop{id, int(Vari.for_bool), x, y, [], [], -1, -1, [
							-1,
						], -1, [], empty_contenant_h, [
							0,
						]})!
					}
					else {
						app.max_id -= 1
					}
				}
			}
		}
	}
	if app.max_id == id {
		app.clicked_block = app.max_id
		app.draw_order << id
		return true
	}
	return false
}

fn (mut app App) set_block_offset(x int, y int, block blocks.Blocks) {
	app.block_click_offset_x = x - block.x
	app.block_click_offset_y = y - block.y
}
