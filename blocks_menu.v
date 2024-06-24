import blocks

const empty_contenant_h = blocks.blocks_h * 2 + blocks.attach_decal_y * 2
const fn_declare = init_block(blocks.Function{-1, int(Vari.function), 30, 10, [], -1, -1, [
	-1,
], [], [], [], [], empty_contenant_h, [
	0,
]}) or { panic(err) }
const condition = init_block(blocks.Condition{-1, int(Vari.condition), 30, 10, [], [], -1, -1, [
	-1,
], [], empty_contenant_h, [
	0,
]}) or { panic(err) }
const @match = init_block(blocks.Condition{-1, int(Vari.@match), 30, 80, [], [], -1, -1, [
	-1,
], [], empty_contenant_h * 2 - blocks.blocks_h, [
	0,
	0,
]}) or { panic(err) }
const for_range = init_block(blocks.Loop{-1, int(Vari.for_range), 30, 10, [], [], -1, -1, [
	-1,
], -1, [], empty_contenant_h, [
	0,
]}) or { panic(err) }
const for_c = init_block(blocks.Loop{-1, int(Vari.for_c), 30, 80, [], [], -1, -1, [-1], -1, [], empty_contenant_h, [
	0,
]}) or { panic(err) }
const for_bool = init_block(blocks.Loop{-1, int(Vari.for_bool), 30, 160, [], [], -1, -1, [
	-1,
], -1, [], empty_contenant_h, [
	0,
]}) or { panic(err) }
const @return = init_block(blocks.Input{-1, int(Vari.@return), 30, 10, [], -1, -1, [], [], [], blocks.blocks_h, []}) or {
	panic(err)
}
const panic = init_block(blocks.Input{-1, int(Vari.panic), 30, 50, [], -1, -1, [], [], [], blocks.blocks_h, []}) or {
	panic(err)
}
const declare = init_block(blocks.InputOutput{-1, int(Vari.declare), 30, 10, [], [], -1, -1, [], [], blocks.blocks_h, []}) or {
	panic(err)
}
const assign = init_block(blocks.InputOutput{-1, int(Vari.assign), 30, 50, [], [], -1, -1, [], [], blocks.blocks_h, []}) or {
	panic(err)
}
const println = init_block(blocks.InputOutput{-1, int(Vari.println), 30, 90, [], [], -1, -1, [], [], blocks.blocks_h, []}) or {
	panic(err)
}
const call = init_block(blocks.InputOutput{-1, int(Vari.call), 30, 130, [], [], -1, -1, [], [], blocks.blocks_h, []}) or {
	panic(err)
}

enum MenuMode {
	function
	condition
	i_o
	input
	loop
}

fn (app App) show_blocks_menu() {
	app.ctx.draw_square_filled(0, 0, 20, blocks.func_color)
	app.ctx.draw_square_filled(0, 20, 20, blocks.con_color)
	app.ctx.draw_square_filled(0, 40, 20, blocks.io_color)
	app.ctx.draw_square_filled(0, 60, 20, blocks.in_color)
	app.ctx.draw_square_filled(0, 80, 20, blocks.loop_color)
	match app.menu_mode {
		.function {
			fn_declare.show(app.ctx)
		}
		.condition {
			condition.show(app.ctx)
			@match.show(app.ctx)
		}
		.i_o {
			declare.show(app.ctx)
			assign.show(app.ctx)
			println.show(app.ctx)
			call.show(app.ctx)
		}
		.input {
			@return.show(app.ctx)
			panic.show(app.ctx)
		}
		.loop {
			for_range.show(app.ctx)
			for_c.show(app.ctx)
			for_bool.show(app.ctx)
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
		return true
	}
	return false
}

fn (mut app App) set_block_offset(x int, y int, block blocks.Blocks) {
	app.block_click_offset_x = x - block.x
	app.block_click_offset_y = y - block.y
}
