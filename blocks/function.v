module blocks

import gg

pub const func_color = gg.Color{245, 194, 231, 255} // mocha pink

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

pub fn (func Function) show(ctx gg.Context, input_id int, input_nb int, input_txt_nb int) {
	mut tmp_text_size := 0
	for txt in func.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (attach_w * 3 + end_block_w)
	expand_h := func.size_in[0] + blocks_h + 2 * attach_decal_y
	ctx.draw_rect_filled(func.x, func.y, attach_w, expand_h + blocks_h, func_color)
	// Start
	ctx.draw_rect_filled(func.x + attach_w, func.y, attach_w, blocks_h, func_color)
	// End for end of the loop
	ctx.draw_rect_filled(func.x + attach_w, (func.y + expand_h), end_block_w + attach_w * 2 +
		size_txt + attach_w / 2, blocks_h, func_color)
	// Attach
	ctx.draw_rect_filled(func.x + attach_w + attach_w, func.y, attach_w, (blocks_h + attach_decal_y),
		func_color)
	// END
	ctx.draw_rect_filled(func.x + attach_w + attach_w + attach_w, func.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, func_color)
	mut decal := 0
	for nb_txt, txt in func.text[0] {
		cfg := match txt {
			InputT { input_cfg }
			else { text_cfg }
		}
		y := func.y + blocks_h / 2
		if txt is InputT {
			color := if input_id == func.id && input_nb == 0 && input_txt_nb == nb_txt {
				input_selected_color
			} else {
				input_color
			}
			ctx.draw_rect_filled(func.x + attach_w / 2 + decal - input_margin, y - cfg.size / 2, txt.text.len * text_size + input_margin * 2, cfg.size, color)
		}
		ctx.draw_text(func.x + attach_w / 2 + decal, y, txt.text, cfg)
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
