module blocks

import gg
import gx

pub struct InputOutput {
pub:
	id      int
	variant int
pub mut:
	x             int
	y             int
	text          [][]Text
	attachs_rel_y []int
	input         int
	output        int
	inner         []int
	params        []Params
	base_size     int
	size_in       []int
}

pub fn (mut i_o InputOutput) remove_id(id_remove int) {
	i_o.output = -1
}

pub fn (i_o InputOutput) snap_i_is_body(snap_i int) bool {
	return false
}

pub fn (in_out InputOutput) show(ctx gg.Context) {
	mut tmp_text_size := 0
	for txt in in_out.text[0] {
		tmp_text_size += txt.text.len + 1 // 1 is for the space between texts
	}
	size_txt := int(f32(tmp_text_size) * text_size) - (attach_w + attach_w + end_block_w)
	ctx.draw_rect_filled(in_out.x, in_out.y, attach_w, blocks_h, gx.pink)
	ctx.draw_rect_filled(in_out.x + attach_w, in_out.y + attach_decal_y, attach_w, blocks_h,
		gx.pink)
	ctx.draw_rect_filled(in_out.x + (attach_w + attach_w), in_out.y, end_block_w + size_txt +
		attach_w / 2, blocks_h, gx.pink)
	mut decal := 0
	for txt in in_out.text[0] {
		ctx.draw_text(in_out.x + attach_w / 2 + decal, in_out.y + blocks_h / 2, txt.text,
			text_cfg)
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
