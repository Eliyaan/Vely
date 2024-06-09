module blocks

import gg
import gx

pub struct Function {
pub:
	id      int
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	input         int = -1
	output        int = -1
	inner         []int
	attachs_rel_y []int
	args          []Params
	args_types    []ParamTypes
	return_types  []ParamTypes
	base_size     int
	size_in       []int
}

pub fn (mut f Function) remove_id(id_remove int) {
	f.inner[0] = -1
}

pub fn (f Function) snap_i_is_body(snap_i int) bool {
	return true
}

pub fn (func Function) show(ctx gg.Context) {
	mut tmp_text_size := 0
	for txt in func.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (attach_w * 3 + end_block_w)
	expand_h := func.size_in[0] + blocks_h + 2 * attach_decal_y
	ctx.draw_rect_filled(func.x, func.y, attach_w, expand_h + blocks_h, gx.pink)
	// Start
	ctx.draw_rect_filled(func.x + attach_w, func.y, attach_w, blocks_h, gx.pink)
	// End for end of the loop
	ctx.draw_rect_filled(func.x + attach_w, (func.y + expand_h), end_block_w + attach_w * 2 +
		size_txt + attach_w / 2, blocks_h, gx.pink)
	// Attach
	ctx.draw_rect_filled(func.x + attach_w + attach_w, func.y, attach_w, (blocks_h + attach_decal_y),
		gx.pink)
	// END
	ctx.draw_rect_filled(func.x + attach_w + attach_w + attach_w, func.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, gx.pink)
	mut decal := 0
	for txt in func.text[0] {
		cfg := match txt {
			InputT { input_cfg }
			else { text_cfg }
		}
		ctx.draw_text(func.x + attach_w / 2 + decal, func.y + blocks_h / 2, txt.text,
			cfg)
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
