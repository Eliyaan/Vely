module main

import blocks
import gg
import gx
import os
import time

const win_width = 1300
const win_height = 700
const bg_color = gg.Color{166, 173, 200, 255}
const menu_color = gg.Color{127, 132, 156, 255}
const console_color = gg.Color{49, 50, 68, 255}
const console_cfg = gx.TextCfg{
	size: 16
	color: gg.Color{205, 214, 244, 255}
}
const console_size = 500

@[heap]
struct App {
mut:
	ctx                  &gg.Context = unsafe { nil }
	square_size          int = 10
	blocks               []blocks.Blocks
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
	println
}

fn main() {
	mut app := App{}
	app.ctx = gg.new_context(
		width: win_width
		height: win_height
		create_window: true
		window_title: '- Application -'
		user_data: &app
		bg_color: bg_color
		frame_fn: on_frame
		event_fn: on_event
		sample_count: 2
		font_path: blocks.font_path
	)

	app.ctx.run()
}

fn (mut app App) kill_prog() {
	app.program_running = false
	app.prog.signal_kill()
}

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

fn on_event(e &gg.Event, mut app App) {
	app.win_size = gg.window_size()
	match e.typ {
		.key_down {
			match e.key_code {
				.escape {
					app.ctx.quit()
				}
				.enter {
					app.input_id = -1
				}
				.backspace {
					if app.input_id != -1 {
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
				else {
					if app.input_id != -1 {
						i := blocks.find_index(app.input_id, app)

						app.blocks[i].text[app.input_nb] or {
							panic('input_id valid but not input_nb')
						}[app.input_txt_nb] or { panic('input_id valid but not input_txt_nb') }.text =
							app.blocks[i].text[app.input_nb][app.input_txt_nb].text +
							e.key_code.str()
					}
				}
			}
		}
		.mouse_scroll {
			app.console_scroll(int(e.scroll_y))
		}
		.mouse_down {
			app.input_id = -1
			x := int(e.mouse_x)
			y := int(e.mouse_y)
			if app.check_clicks_menu(x, y) or { panic(err) } {
			} else if app.is_close_console_clicked(x, y) {
				app.show_output = false
			} else if app.is_console_button_clicked(x, y) {
				app.console_button_clicked()
			} else {
				for elem in app.blocks {
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
		}
		.mouse_up {
			app.place_snap(int(e.mouse_x), int(e.mouse_y))
		}
		else {}
	}
	app.handle_clicked_block(int(e.mouse_x), int(e.mouse_y))
}

fn (mut app App) handle_click_block_element(elem blocks.Blocks, x int, y int) bool {
	mut decal_y := blocks.blocks_h
	for nb, txts in elem.text {
		mut decal_x := blocks.attach_w / 2
		if x >= elem.x + decal_x {
			for nb_txt, txt in txts {
				decal_x += (txt.text.len + 1) * blocks.text_size
				x_smaller_end_txt := x < decal_x + elem.x
				// TODO: take into account text size
				y_smaller_text_bot := y < decal_y + elem.y
				y_greater_text_top := y > decal_y - blocks.blocks_h + elem.y
				if x_smaller_end_txt && y_smaller_text_bot && y_greater_text_top {
					match txt {
						blocks.InputT {
							app.input_id = elem.id
							app.input_nb = nb
							app.input_txt_nb = nb_txt
							return true
						}
						else { // clicked on not clickable elem
							return false
						}
					}
				}
			}
		}
		decal_y += blocks.blocks_h + elem.size_in[nb] or { 0 }
	}
	return false
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

fn (mut app App) handle_clicked_block(mouse_x int, mouse_y int) {
	if app.clicked_block != -1 {
		id := blocks.find_index(app.clicked_block, app)
		mut b := &app.blocks[id]
		app.unpropagate_size(id)
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

fn run_prog(mut app App) {
	defer {
		app.prog.close()
		app.prog.wait()
	}

	app.prog.set_args(['run', 'output/output.v'])
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
		file += process(app, f.id)
	}
	os.write_file('output/output.v', file) or { panic(err) }
}

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
						s += 'println("'
						s += b.text[0][1].text
						s += '")'
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
						s += 'panic("'
						s += b.text[0][1].text
						s += '")'
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

fn process_inner(app App, id int) string {
	b := app.blocks[blocks.find_index(id, app)]
	mut s := ''
	for id_inner in b.inner {
		s += process(app, id_inner)
	}
	return s
}

fn (mut app App) place_snap(x int, y int) {
	if app.clicked_block != -1 {
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
	app.clicked_block = -1
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
