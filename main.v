module main

import blocks
import gg

const win_width = 1300
const win_height = 700
const bg_color = gg.Color{100, 100, 100, 255}

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
	mut app := &App{}
	app.ctx = gg.new_context(
		width: win_width
		height: win_height
		create_window: true
		window_title: '- Application -'
		user_data: app
		bg_color: bg_color
		frame_fn: on_frame
		event_fn: on_event
		sample_count: 2
		font_path: blocks.font_path
	)

	app.ctx.run()
}

fn (app App) find_index(id int) int {
	for i, elem in app.blocks {
		if elem.id == id {
			return i
		}
	}
	panic('Did not find id')
}

fn on_frame(mut app App) {
	// Draw
	app.ctx.begin()
	for mut block in app.blocks {
		if block.id != app.clicked_block {
			block.show(app.ctx)
		}
	}
	if app.clicked_block != -1 {
		app.blocks[app.find_index(app.clicked_block)].show(app.ctx)
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
					if x > elem.x && y > elem.y {
						if elem.is_clicked(x, y) {
							app.clicked_block = elem.id
							app.set_block_offset(x, y, elem)
						}
					}
				}
			}
		}
		.mouse_up {
			app.clicked_block = -1
		}
		else {}
	}
	if app.clicked_block != -1 {
		id := app.find_index(app.clicked_block)
		app.blocks[id].x = int(e.mouse_x) - app.block_click_offset_x
		app.blocks[id].y = int(e.mouse_y) - app.block_click_offset_y
	}
}
