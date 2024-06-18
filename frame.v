import gg
import blocks

fn on_frame(mut app App) {
	// Draw
	app.ctx.draw_rect_filled(0, 0, 365, 2000, menu_color)
	app.ctx.begin()
	app.show_blocks()
	app.show_blocks_menu()
	app.show_console()
	app.ctx.end()
}

fn (mut app App) show_blocks() {
	for mut block in app.blocks {
		if block.id != app.clicked_block {
			block.show(app.ctx)
		}
	}
	if app.clicked_block != -1 {
		app.blocks[blocks.find_index(app.clicked_block, app)].show(app.ctx)
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
