module blocks

import gg
import gx
import os

// PARAMS

pub enum ParamTypes {
	int
}

pub struct Params {
	text     string
	number   int
	contains ParamTypes
}

// BLOCKS

pub const text_size = 8
const snap_dist = 300
pub const attach_decal_y = 5
pub const attach_w = 14
const end_block_w = 10
pub const blocks_h = 27
pub const input_margin = 3
pub const font_path = os.resource_abs_path('0xProtoNerdFontMono-Regular.ttf')

pub interface App {
mut:
	blocks []Blocks
	palette ColorPalette
	ctx &gg.Context
	input_id int
	input_nb int
	input_txt_nb int
}

pub interface ColorPalette {
mut:
	input_color gg.Color
	input_selected_color gg.Color
	con_color gg.Color
	loop_color gg.Color
	io_color gg.Color
	in_color gg.Color
	func_color gg.Color
	text_cfg gx.TextCfg 
	input_cfg gx.TextCfg 
}

pub interface Text {
mut:
	text string
}

pub struct JustT {
pub mut:
	text string
}

pub struct InputT {
pub mut:
	text string
}

pub struct ButtonT {
pub mut:
	text string
}

pub interface Blocks {
	id      int
	variant int
	show(app App)
	is_clicked(x int, y int) bool
	snap_i_is_body(snap_i int) bool
mut:
	x             int
	y             int
	input         int
	output        int
	inner         []int
	text          [][]Text
	attachs_rel_y []int
	base_size     int
	size_in       []int
	remove_id(id_remove int)
}

pub fn (block Blocks) is_snapping(other Blocks) int {
	mut decal := 0
	for nb, attach in other.attachs_rel_y {
		match other {
			Loop {
				if nb == 0 {
					if (other.inner[0] == -1 || other.inner[0] == block.id)
						&& snap_check_dist(block, other, attach) {
						return nb
					}
				} else {
					if (other.output == -1 || other.output == block.id)
						&& snap_check_dist(block, other, attach + decal) {
						return nb
					}
				}
			}
			InputOutput {
				if (other.output == -1 || other.output == block.id)
					&& snap_check_dist(block, other, attach) {
					return nb
				}
			}
			Condition {
				if nb == other.attachs_rel_y.len - 1 {
					if (other.output == -1 || other.output == block.id)
						&& snap_check_dist(block, other, attach + decal) {
						return nb
					}
				} else {
					if (other.inner[nb] == -1 || other.inner[nb] == block.id)
						&& snap_check_dist(block, other, attach + decal) {
						return nb
					}
				}
			}
			Function {
				if (other.inner[0] == -1 || other.inner[0] == block.id)
					&& snap_check_dist(block, other, attach) {
					return nb
				}
			}
			else {}
		}
		if nb < other.size_in.len {
			decal += other.size_in[nb]
		}
	}
	return -1
}

fn snap_check_dist(block Blocks, other Blocks, attach int) bool {
	y_dist := block.y - (attach + other.y)
	x_dist := block.x - (other.x + attach_w)
	return y_dist * y_dist + x_dist * x_dist < snap_dist
}

pub fn (mut b Blocks) check_block_is_snapping_here(app App) {
	if b !is Function {
		for other in app.blocks {
			if other !is Input {
				snap_i := b.is_snapping(other)
				if snap_i != -1 {
					if snap_i == other.attachs_rel_y.len - 1 && other !is Function {
						b.x = other.x
					} else {
						b.x = other.x + attach_w
					}
					mut decal := 0
					for decal_y in other.size_in[..snap_i] {
						decal += decal_y
					}
					b.y = other.attachs_rel_y[snap_i] + other.y + decal
					break
				}
			}
		}
	}
}

pub fn (mut b Blocks) detach(mut app App) {
	if b.input != -1 {
		app.blocks[find_index(b.input, app)].remove_id(b.id)
		b.input = -1
	}
	/*
	if b.output != -1 { // only in detach single
		app.blocks[find_index(b.output, app)].input = -1
		b.output = -1
	}
	for mut inner in b.inner {
		if inner != -1 {
			app.blocks[find_index(inner, app)].input = -1
			inner = -1
		}
	}
	*/
}

pub fn find_index(id int, app App) int {
	for i, elem in app.blocks {
		if elem.id == id {
			return i
		}
	}
	panic('Did not find id ${id}')
}


// CONDITIONS

pub struct Condition {
pub:
	id      int = -1
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	attachs_rel_y []int
	input         int   = -1
	output        int   = -1
	inner         []int = [-1]
	conditions    []int
	base_size     int
	size_in       []int = [0]
}

pub fn (mut c Condition) remove_id(id_remove int) {
	nb := c.inner.index(id_remove)
	if nb != -1 {
		c.inner[nb] = -1
	} else {
		c.output = -1
	}
}

pub fn (c Condition) snap_i_is_body(snap_i int) bool {
	if snap_i == c.size_in.len {
		return false
	}
	return true
}

pub fn (con Condition) show(app App) {
	mut tmp_text_size := 0
	for txt in con.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (attach_w + attach_w + attach_w + end_block_w)
	// Attach up
	app.ctx.draw_rect_filled(con.x + attach_w, (con.y + attach_decal_y), attach_w, blocks_h - attach_decal_y,
		app.palette.con_color)
	// Attach down
	app.ctx.draw_rect_filled(con.x + attach_w + attach_w, con.y, attach_w, blocks_h + attach_decal_y,
		app.palette.con_color)
	// END
	app.ctx.draw_rect_filled(con.x + attach_w * 2 + attach_w, con.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, app.palette.con_color)

	mut expand_h := con.size_in[0] + blocks_h + 2 * attach_decal_y
	mut pos := []int{}
	for nb, size_px in con.size_in[1..] {
		mut tmp_text_size_in := 0
		for txt in con.text[nb + 1] {
			tmp_text_size_in += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt_in := int(f32(tmp_text_size_in) * text_size) - (attach_w * 2 + end_block_w)
		y := con.y + expand_h
		pos << y
		expand_h += size_px + blocks_h + 2 * attach_decal_y
		// Start
		app.ctx.draw_rect_filled(con.x + attach_w, y, attach_w, blocks_h, app.palette.con_color)
		// Attach down
		app.ctx.draw_rect_filled(con.x + attach_w + attach_w, y, attach_w, (blocks_h + attach_decal_y),
			app.palette.con_color)
		// END
		app.ctx.draw_rect_filled(con.x + attach_w + attach_w + attach_w, y, end_block_w + size_txt_in +
			attach_w / 2, blocks_h, app.palette.con_color)
	}
	// End for end of the con
	app.ctx.draw_rect_filled(con.x, con.y, attach_w, expand_h + blocks_h, app.palette.con_color)
	y := con.y + expand_h
	// Attach down
	app.ctx.draw_rect_filled(con.x + attach_w, y, attach_w, (blocks_h + attach_decal_y), app.palette.con_color)
	app.ctx.draw_rect_filled(con.x + attach_w + attach_w, y, attach_w, blocks_h, app.palette.con_color)
	// END
	mut decal := 0
	app.ctx.draw_rect_filled(con.x + attach_w + attach_w + attach_w, y, end_block_w + size_txt +
		attach_w / 2, blocks_h, app.palette.con_color)
	for nb, y_pos in pos {
		decal = 0
		for nb_txt, txt in con.text[nb + 1] {
			cfg := match txt {
				InputT { app.palette.input_cfg }
				else { app.palette.text_cfg }
			}
			y_txt := y_pos + blocks_h / 2
			if txt is InputT {
				color := if app.input_id == con.id && app.input_nb == nb + 1 && app.input_txt_nb == nb_txt {
					app.palette.input_selected_color
				} else {
					app.palette.input_color
				}
				app.ctx.draw_rect_filled(con.x + attach_w / 2 + decal - input_margin, y_txt - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, color)
			}
			app.ctx.draw_text(con.x + attach_w / 2 + decal, y_txt, txt.text, cfg)
			decal += (txt.text.len + 1) * text_size
		}
	}
	decal = 0
	for nb_txt, txt in con.text[0] {
		cfg := match txt {
			InputT { app.palette.input_cfg }
			else { app.palette.text_cfg }
		}
		y_txt := con.y + blocks_h / 2
		if txt is InputT {
			color := if app.input_id == con.id && app.input_nb == 0 && app.input_txt_nb == nb_txt {
				app.palette.input_selected_color
			} else {
				app.palette.input_color
			}
			app.ctx.draw_rect_filled(con.x + attach_w / 2 + decal - input_margin, y_txt - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, color)
		}
		app.ctx.draw_text(con.x + attach_w / 2 + decal, y_txt, txt.text, cfg)
		decal += (txt.text.len + 1) * text_size
	}
}

pub fn (con Condition) is_clicked(x int, y int) bool {
	if x > con.x && y > con.y {
		mut tmp_text_size := 0
		for txt in con.text[0] {
			tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt := int(f32(tmp_text_size) * text_size) - (attach_w + attach_w + attach_w +
			end_block_w)
		if x < con.x + attach_w * 2 + attach_w + end_block_w + size_txt + attach_w / 2
			&& y < con.y + blocks_h {
			return true
		} else {
			mut expand_h := con.size_in[0] + blocks_h + 2 * attach_decal_y
			for nb, size_px in con.size_in[1..] {
				mut tmp_text_size_in := 0
				for txt in con.text[nb + 1] {
					tmp_text_size_in += txt.text.len + 1 // 1 is for the space between texts
				}
				size_txt_in := int(f32(tmp_text_size_in) * text_size) - (attach_w * 2 + end_block_w)
				if x > con.x + attach_w && y > con.y + expand_h {
					if x < con.x + attach_w + attach_w + attach_w + end_block_w + size_txt_in + attach_w / 2
						&& y < con.y + expand_h + blocks_h {
						return true
					}
				}
				expand_h += size_px + blocks_h + 2 * attach_decal_y
			}
			if x < con.x + attach_w && y < con.y + expand_h + blocks_h {
				return true
			}
			if x > con.x + attach_w && y > con.y + expand_h {
				if x < con.x + attach_w + attach_w + attach_w + end_block_w + size_txt + attach_w / 2
					&& y < con.y + expand_h + blocks_h {
					return true
				}
			}
		}
	}
	return false
}

// FUNCTIONS 

pub struct Function {
pub:
	id      int = -1
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	input         int   = -1
	output        int   = -1
	inner         []int = [-1]
	attachs_rel_y []int
	args          []Params
	args_types    []ParamTypes
	return_types  []ParamTypes
	base_size     int
	size_in       []int = [0]
}

pub fn (mut f Function) remove_id(id_remove int) {
	f.inner[0] = -1
}

pub fn (f Function) snap_i_is_body(snap_i int) bool {
	return true
}

pub fn (func Function) show(app App) {
	mut tmp_text_size := 0
	for txt in func.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (attach_w * 3 + end_block_w)
	expand_h := func.size_in[0] + blocks_h + 2 * attach_decal_y
	app.ctx.draw_rect_filled(func.x, func.y, attach_w, expand_h + blocks_h, app.palette.func_color)
	// Start
	app.ctx.draw_rect_filled(func.x + attach_w, func.y, attach_w, blocks_h, app.palette.func_color)
	// End for end of the loop
	app.ctx.draw_rect_filled(func.x + attach_w, (func.y + expand_h), end_block_w + attach_w * 2 +
		size_txt + attach_w / 2, blocks_h, app.palette.func_color)
	// Attach
	app.ctx.draw_rect_filled(func.x + attach_w + attach_w, func.y, attach_w, (blocks_h + attach_decal_y),
		app.palette.func_color)
	// END
	app.ctx.draw_rect_filled(func.x + attach_w + attach_w + attach_w, func.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, app.palette.func_color)
	mut decal := 0
	for nb_txt, txt in func.text[0] {
		cfg := match txt {
			InputT { app.palette.input_cfg }
			else { app.palette.text_cfg }
		}
		y := func.y + blocks_h / 2
		if txt is InputT {
			color := if app.input_id == func.id && app.input_nb == 0 && app.input_txt_nb == nb_txt {
				app.palette.input_selected_color
			} else {
				app.palette.input_color
			}
			app.ctx.draw_rect_filled(func.x + attach_w / 2 + decal - input_margin, y - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, color)
		}
		app.ctx.draw_text(func.x + attach_w / 2 + decal, y, txt.text, cfg)
		decal += (txt.text.len + 1) * text_size
	}
}

pub fn (func Function) is_clicked(x int, y int) bool {
	if x > func.x && y > func.y {
		mut tmp_text_size := 0
		for txt in func.text[0] {
			tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt := int(f32(tmp_text_size) * text_size) - (attach_w * 3 + end_block_w)
		expand_h := func.size_in[0] + blocks_h + 2 * attach_decal_y
		if x < func.x + attach_w + attach_w + attach_w + end_block_w + size_txt + attach_w / 2
			&& y < func.y + blocks_h {
			return true
		} else if x < func.x + attach_w && y < func.y + expand_h + blocks_h {
			return true
		} else if x > func.x + attach_w && y > func.y + expand_h
			&& x < func.x + attach_w * 2 + end_block_w + size_txt + attach_w / 2
			&& y < func.y + expand_h + blocks_h {
			return true
		}
	}
	return false
}

// INPUTS

pub struct Input {
pub:
	id      int = -1
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	input         int = -1
	output        int = -1
	inner         []int
	attachs_rel_y []int
	params        []Params
	base_size     int
	size_in       []int // not used for inputs but used for the interface
}

pub fn (mut i Input) remove_id(id_remove int) {
}

pub fn (i Input) snap_i_is_body(snap_i int) bool {
	return false
}

pub fn (input Input) show(app App) {
	mut tmp_text_size := 0
	for txt in input.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (end_block_w + attach_w + attach_w)
	app.ctx.draw_rect_filled(input.x, input.y, attach_w, blocks_h, app.palette.in_color)
	app.ctx.draw_rect_filled(input.x + attach_w, input.y + attach_decal_y, attach_w, blocks_h - attach_decal_y,
		app.palette.in_color)
	app.ctx.draw_rect_filled(input.x + (attach_w + attach_w), input.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, app.palette.in_color)
	mut decal := 0
	for nb_txt, txt in input.text[0] {
		cfg := match txt {
			InputT { app.palette.input_cfg }
			else { app.palette.text_cfg }
		}
		y := input.y + blocks_h / 2
		if txt is InputT {
			color := if app.input_id == input.id && app.input_nb == 0 && app.input_txt_nb == nb_txt {
				app.palette.input_selected_color
			} else {
				app.palette.input_color
			}
			app.ctx.draw_rect_filled(input.x + attach_w / 2 + decal - input_margin, y - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, color)
		}
		app.ctx.draw_text(input.x + attach_w / 2 + decal, y, txt.text, cfg)
		decal += (txt.text.len + 1) * text_size
	}
}

pub fn (input Input) is_clicked(x int, y int) bool {
	if x > input.x && y > input.y {
		mut tmp_text_size := 0
		for txt in input.text[0] {
			tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt := int(f32(tmp_text_size) * text_size) - (end_block_w + attach_w + attach_w)
		return x < input.x + attach_w + attach_w + end_block_w + size_txt + attach_w / 2
			&& y < input.y + blocks_h
	}
	return false
}

// INPUT OUTPUTS

pub struct InputOutput {
pub:
	id      int = -1
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	attachs_rel_y []int
	input         int = -1
	output        int = -1
	inner         []int
	params        []Params
	base_size     int
	size_in       []int // not used, only for interface
}

pub fn (mut i_o InputOutput) remove_id(id_remove int) {
	i_o.output = -1
}

pub fn (i_o InputOutput) snap_i_is_body(snap_i int) bool {
	return false
}

pub fn (in_out InputOutput) show(app App) {
	mut tmp_text_size := 0
	for txt in in_out.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (attach_w + attach_w + end_block_w)
	app.ctx.draw_rect_filled(in_out.x, in_out.y, attach_w, blocks_h, app.palette.io_color)
	app.ctx.draw_rect_filled(in_out.x + attach_w, in_out.y + attach_decal_y, attach_w, blocks_h,
		app.palette.io_color)
	app.ctx.draw_rect_filled(in_out.x + (attach_w + attach_w), in_out.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, app.palette.io_color)
	mut decal := 0
	for nb_txt, txt in in_out.text[0] {
		cfg := match txt {
			InputT { app.palette.input_cfg }
			else { app.palette.text_cfg }
		}
		y := in_out.y + blocks_h / 2
		if txt is InputT {
			color := if app.input_id == in_out.id && app.input_nb == 0 && app.input_txt_nb == nb_txt {
				app.palette.input_selected_color
			} else {
				app.palette.input_color
			}
			app.ctx.draw_rect_filled(in_out.x + attach_w / 2 + decal - input_margin, y - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, color)
		}
		app.ctx.draw_text(in_out.x + attach_w / 2 + decal, y, txt.text, cfg)
		decal += (txt.text.len + 1) * text_size
	}
}

pub fn (in_out InputOutput) is_clicked(x int, y int) bool {
	if x > in_out.x && y > in_out.y {
		mut tmp_text_size := 0
		for txt in in_out.text[0] {
			tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt := int(f32(tmp_text_size) * text_size) - (attach_w + attach_w + end_block_w)
		return x < in_out.x + (attach_w + attach_w) + end_block_w + size_txt + attach_w / 2
			&& y < in_out.y + blocks_h
	}
	return false
}

// LOOPS

pub struct Loop {
pub:
	id      int = -1
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	attachs_rel_y []int
	input         int   = -1
	output        int   = -1
	inner         []int = [-1]
	condition     int   = -1 // need to change that (remplacer par les menus déroulants)
	params        []Params // this also i think
	base_size     int
	size_in       []int = [0]
}

pub fn (mut l Loop) remove_id(id_remove int) {
	if l.inner[0] == id_remove {
		l.inner[0] = -1
	} else {
		l.output = -1
	}
}

pub fn (l Loop) snap_i_is_body(snap_i int) bool {
	return !(snap_i == 1)
}

pub fn (loop Loop) show(app App) {
	mut tmp_text_size := 0
	for txt in loop.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (end_block_w + attach_w + attach_w + attach_w)

	expand_h := loop.size_in[0] + blocks_h + 2 * attach_decal_y
	app.ctx.draw_rect_filled(loop.x, loop.y, attach_w, expand_h + blocks_h, app.palette.loop_color)
	y := loop.y + expand_h

	// Attach extern
	app.ctx.draw_rect_filled(loop.x + attach_w, loop.y + attach_decal_y, attach_w, blocks_h - attach_decal_y,
		app.palette.loop_color)
	app.ctx.draw_rect_filled(loop.x + attach_w, y, attach_w, blocks_h + attach_decal_y, app.palette.loop_color)

	// Attach intern
	app.ctx.draw_rect_filled(loop.x + attach_w + attach_w, loop.y, attach_w, blocks_h + attach_decal_y,
		app.palette.loop_color)
	app.ctx.draw_rect_filled(loop.x + attach_w + attach_w, y, attach_w, blocks_h, app.palette.loop_color)

	// END
	app.ctx.draw_rect_filled(loop.x + attach_w + attach_w + attach_w, loop.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, app.palette.loop_color)
	app.ctx.draw_rect_filled(loop.x + attach_w + attach_w + attach_w, y, end_block_w + size_txt +
		attach_w / 2, blocks_h, app.palette.loop_color)

	mut decal := 0
	for nb_txt, txt in loop.text[0] {
		cfg := match txt {
			InputT { app.palette.input_cfg }
			else { app.palette.text_cfg }
		}
		y_txt := loop.y + blocks_h / 2
		if txt is InputT {
			color := if app.input_id == loop.id && app.input_nb == 0 && app.input_txt_nb == nb_txt {
				app.palette.input_selected_color
			} else {
				app.palette.input_color
			}
			app.ctx.draw_rect_filled(loop.x + attach_w / 2 + decal - input_margin, y_txt - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, color)
		}
		app.ctx.draw_text(loop.x + attach_w / 2 + decal, y_txt, txt.text,
			cfg)
		decal += (txt.text.len + 1) * text_size
	}
}

pub fn (loop Loop) is_clicked(x int, y int) bool {
	if x > loop.x && y > loop.y {
		mut tmp_text_size := 0
		for txt in loop.text[0] {
			tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
		}
		size_txt := int(f32(tmp_text_size) * text_size) - (end_block_w + attach_w + attach_w +
			attach_w)
		expand_h := loop.size_in[0] + blocks_h + 2 * attach_decal_y
		if x <= loop.x + attach_w + attach_w + attach_w + end_block_w + size_txt + attach_w / 2
			&& y <= loop.y + blocks_h {
			return true
		} else if x <= loop.x + attach_w && y <= loop.y + expand_h + blocks_h {
			return true
		} else if x >= loop.x + attach_w && y >= loop.y + expand_h
			&& x <= loop.x + attach_w + attach_w + attach_w + end_block_w + size_txt + attach_w / 2
			&& y <= loop.y + expand_h + blocks_h {
			return true
		}
	}
	return false
}

