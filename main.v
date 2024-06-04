module main

import blocks
import gg
import gx

const win_width = 1300
const win_height = 700
const bg_color = gg.Color{100, 100, 100, 255}

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
	app.ctx.draw_rect_filled(0, 0, 500, 2000, gx.black)
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
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			match e.key_code {
				.escape { app.ctx.quit() }
				else {}
			}
		}
		.mouse_down {
			x := int(e.mouse_x)
			y := int(e.mouse_y)
			if app.check_clicks_menu(x, y) or { panic(err) } {
			} else {
				for elem in app.blocks {
					if elem.is_clicked(x, y) {
						app.clicked_block = elem.id
						app.set_block_offset(x, y, elem)
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
	}
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
		app.blocks[block_i].size_in = []int{len: app.blocks[block_i].size_in.len}
		// -
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
