module main

import blocks
import gg

const win_width = 801
const win_height = 701
const bg_color = gg.Color{100, 100, 100, 255}

struct App {
mut:
	ctx         &gg.Context = unsafe { nil }
	square_size int = 10
	blocks []blocks.Blocks
    clicked_block int = -1
    block_click_offset_x int 
    block_click_offset_y int 
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

	// lancement du programme/de la fenêtre
	app.blocks << blocks.Input{1, blocks.Variants.panic, 100, 100, -1, []}
	app.blocks << blocks.Input_output{2, blocks.Variants.declare, 250, 100, -1, -1, []}
	app.blocks << blocks.Function{4, blocks.Variants.function, 250, 200, 0, 0, [], [], []}
	app.blocks << blocks.Loop{5, blocks.Variants.for_range, 400, 100, 0, -1, -1, -1, 0, []}
	app.blocks << blocks.Condition{6, blocks.Variants.condition, 200, 400, -1, -1, [], [], [
		0,
	]}
	app.blocks << blocks.Condition{7, blocks.Variants.condition, 100, 200, -1, -1, [], [], [
		0,
		0,
	]}
	app.blocks << blocks.Condition{8, blocks.Variants.@match, 400, 250, -1, -1, [], [], [
		0,
		0,
		0,
	]}
	app.ctx.run()
}

fn (app App) find_index(id int) int {
    for i, elem in app.blocks {
        if elem.id == id {
            return i
        }
    }
    panic("Did not find id")
}

fn on_frame(mut app App) {
	// Draw
	app.ctx.begin()
	for block in app.blocks {
        if block.id != app.clicked_block {
            block.show(app.ctx)
        }
	}
    if app.clicked_block != -1 {
        app.blocks[app.find_index(app.clicked_block)].show(app.ctx)
    }
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
			for elem in app.blocks {
				if e.mouse_x > elem.x && e.mouse_y > elem.y {
					if elem.is_clicked(int(e.mouse_x), int(e.mouse_y)) {
						app.clicked_block = elem.id
                        app.block_click_offset_x = int(e.mouse_x) - elem.x
                        app.block_click_offset_y = int(e.mouse_y) - elem.y
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
