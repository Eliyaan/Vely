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
	text          []string
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
	size_txt := int(f32(in_out.text[0].len) * 8.8) - (attach_w + attach_w + end_block_w)
	ctx.draw_rect_filled(in_out.x, in_out.y, attach_w, blocks_h, gx.pink)
	ctx.draw_rect_filled(in_out.x + attach_w, in_out.y + attach_decal_y, attach_w, blocks_h,
		gx.pink)
	ctx.draw_rect_filled(in_out.x + (attach_w + attach_w), in_out.y, end_block_w + size_txt,
		blocks_h, gx.pink)
	ctx.draw_text(in_out.x + attach_w / 2, in_out.y + blocks_h / 2, in_out.text[0], text_cfg)
}

pub fn (in_out InputOutput) is_clicked(x int, y int) bool {
	if x > in_out.x && y > in_out.y {
		size_txt := int(f32(in_out.text[0].len) * 8.8) - (attach_w + attach_w + end_block_w)
		return x < in_out.x + (attach_w + attach_w) + end_block_w + size_txt
			&& y < in_out.y + blocks_h
	}
	return false
}
