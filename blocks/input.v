module blocks

import gg
import gx

pub struct Input {
pub:
	id      int
	variant int
pub mut:
	x             int
	y             int
	text          []string
	input         int
	output        int
	inner         []int
	attachs_rel_y []int
	params        []Params
	base_size     int
	size_in       []int
}

pub fn (mut i Input) remove_id(id_remove int) {
}

pub fn (i Input) snap_i_is_body(snap_i int) bool {
	return false
}

pub fn (input Input) show(ctx gg.Context) {
	size_txt := int(f32(input.text[0].len) * 8.8) - (end_block_w + attach_w + attach_w)
	ctx.draw_rect_filled(input.x, input.y, attach_w, blocks_h, gx.pink)
	ctx.draw_rect_filled(input.x + attach_w, input.y + attach_decal_y, attach_w, blocks_h - attach_decal_y,
		gx.pink)
	ctx.draw_rect_filled(input.x + (attach_w + attach_w), input.y, end_block_w + size_txt,
		blocks_h, gx.pink)
	ctx.draw_text(input.x + attach_w / 2, input.y + blocks_h / 2, input.text[0], text_cfg)
}

pub fn (input Input) is_clicked(x int, y int) bool {
	if x > input.x && y > input.y {
		size_txt := int(f32(input.text[0].len) * 8.8) - (end_block_w + attach_w + attach_w)
		return x < input.x + attach_w + attach_w + end_block_w + size_txt && y < input.y + blocks_h
	}
	return false
}
