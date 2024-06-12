module main

import blocks
import gg
import os
import time

const win_width = 1300
const win_height = 700
const bg_color = gg.Color{166, 173, 200, 255}
const menu_color = gg.Color{127, 132, 156, 255}

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
	show_output 	bool
	program_running bool
	prog os.Process
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

fn on_frame(mut app App) {
	// Draw
	app.ctx.draw_rect_filled(0, 0, 365, 2000, menu_color)
	app.ctx.begin()
	for mut block in app.blocks {
		if block.id != app.clicked_block {
			block.show(app.ctx)
		}
	}
	if app.clicked_block != -1 {
		app.blocks[blocks.find_index(app.clicked_block, app)].show(app.ctx)
	}
	app.show_blocks_menu()
	win_size := gg.window_size()
	run_color := if app.show_output {
		if app.program_running {
			gg.Color{255, 0, 0, 255}
		} else {
			gg.Color{0, 255, 0, 255}
		}
	}
	else {
		gg.Color{128, 128, 128, 255}
	}	
	if app.show_output {
		app.ctx.draw_rect_filled(win_size.width-300, 0, 300, 2000, menu_color)
		app.ctx.draw_square_filled(win_size.width-295, 5, 20, gg.Color{255, 0, 0, 255})
	}
	app.ctx.draw_square_filled(win_size.width-25, 5, 20, run_color)
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	win_size := gg.window_size()
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

						app.blocks[i].text[app.input_nb] or {
							panic('input_id valid but not input_nb')
						}[app.input_txt_nb] or { panic('input_id valid but not input_txt_nb') }.text = app.blocks[i].text[app.input_nb][app.input_txt_nb].text#[..-1]
					}
				}
				.delete { // TODO change with button
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
		.mouse_down {
			app.input_id = -1
			x := int(e.mouse_x)
			y := int(e.mouse_y)
			if app.check_clicks_menu(x, y) or { panic(err) } {
			} else if app.show_output && x >= win_size.width-295 && x < win_size.width-275 && y >= 5 && y < 25 {
				app.show_output = false
			} else if x >= win_size.width-25 && x < win_size.width-5 && y >= 5 && y < 25{
				if app.show_output {
					if app.program_running {
						app.program_running = false
						app.prog.signal_kill()
					} else {
						app.program_running = true
						v_file(app)
						os.execute("v fmt -w output/output.v")
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
			} else {
				block_click: for elem in app.blocks {
					if elem.is_clicked(x, y) {
						mut decal_y := blocks.blocks_h
						mut txt_click_detec := true
						for nb, txts in elem.text {
							if txt_click_detec {
								mut decal_x := blocks.attach_w / 2
								for nb_txt, txt in txts {
									decal_x += (txt.text.len + 1) * blocks.text_size
									if (x - elem.x) < decal_x && (y - elem.y) < decal_y
										&& (y - elem.y) > decal_y - blocks.blocks_h {
										match txt {
											blocks.InputT {
												app.input_id = elem.id
												app.input_nb = nb
												app.input_txt_nb = nb_txt
												break block_click // only important thing is the text, not the block moving
											}
											else {}
										}
										txt_click_detec = false
										break
									}
								}
								decal_y += blocks.blocks_h + elem.size_in[nb] or { 0 }
							}
						}
						app.clicked_block = elem.id
						app.set_block_offset(x, y, elem)
						app.block_click_x = elem.x
						app.block_click_y = elem.y
						break
					}
				}
			}
		}
		.mouse_up {
			app.place_snap(int(e.mouse_x), int(e.mouse_y))
		}
		else {}
	}
	if app.clicked_block != -1 {
		id := blocks.find_index(app.clicked_block, app)
		mut b := &app.blocks[id]
		app.unpropagate_size(id)
		b.detach(mut app)
		b.x = int(e.mouse_x) - app.block_click_offset_x
		b.y = int(e.mouse_y) - app.block_click_offset_y
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
			print(oline)
		}
		if eline := app.prog.pipe_read(.stderr) {
			eprint(eline)
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
				if b.text[0][1].text.trim_space() == "main" {
					s += "\nunbuffer_stdout() // useful for Vely, when running the program (added automatically by Vely)"
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
