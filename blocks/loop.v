module blocks

import gg
import gx

pub struct Loop {
pub:
	id      int
	variant Variants
pub mut:
	x int
	y int

	size      int
	input     int
	output    int
	inner     int
	condition int // need to change that (remplacer par les menus déroulants)
	params    []Params  // this also i think
}

pub fn (loop Loop) show(ctx gg.Context) {
	text_to_draw := match loop.variant {
		.for_range {
			"for each `i` between [`0` and `5`)"
		}
		.for_bool {
			"while `bool` is true"
		}
		.for_c {
			"repeat: start `i` equals `0` while `condition` and doing `action`"
		}
		else {
			panic("${loop.variant} not handled")
		}
	}
	size := int(f32(text_to_draw.len) * 8.5) - (end_block_w + attach_w + attach_w + attach_w)

	expand_h := (1 + loop.size) * blocks_h + 2 * attach_decal_y
	ctx.draw_rect_filled(loop.x, loop.y, attach_w, expand_h + blocks_h, gx.pink)
	y := loop.y + expand_h
	
	//Attach extern
	ctx.draw_rect_filled(loop.x + attach_w, loop.y + attach_decal_y, attach_w,
		blocks_h - attach_decal_y, gx.pink)
	ctx.draw_rect_filled(loop.x + attach_w, y, attach_w, blocks_h + attach_decal_y,
		gx.pink)

	// Attach intern
	ctx.draw_rect_filled(loop.x + attach_w + attach_w, loop.y, attach_w,
		blocks_h + attach_decal_y, gx.pink)
	ctx.draw_rect_filled(loop.x + attach_w + attach_w, y, attach_w, blocks_h,
		gx.pink)

	// END
	ctx.draw_rect_filled(loop.x + attach_w + attach_w + attach_w, loop.y,
		end_block_w + size, blocks_h, gx.pink)
	ctx.draw_rect_filled(loop.x + attach_w + attach_w + attach_w, y, end_block_w + size,
		blocks_h, gx.pink)

	ctx.draw_text(loop.x + attach_w/2, loop.y + blocks_h/2, text_to_draw, text_cfg)
}

pub fn (loop Loop) is_clicked(x int, y int) bool {
	text_to_draw := match loop.variant {
		.for_range {
			"for each `i` between [`0` and `5`)"
		}
		.for_bool {
			"while `bool` is true"
		}
		.for_c {
			"repeat: start `i` equals `0` while `condition` and doing `action`"
		}
		else {
			panic("${loop.variant} not handled")
		}
	}
	size := int(f32(text_to_draw.len) * 8.5) - (end_block_w + attach_w + attach_w + attach_w)
	expand_h := (1 + loop.size) * blocks_h + 2 * attach_decal_y
	if x < loop.x + attach_w + attach_w + attach_w + end_block_w + size
		&& y < loop.y + blocks_h {
		return true
	} else if x < loop.x + attach_w && y < loop.y + expand_h + blocks_h {
		return true
	} else if x > loop.x + attach_w && y > loop.y + expand_h
		&& x < loop.x + attach_w + attach_w + attach_w + end_block_w + size
		&& y < loop.y + expand_h + blocks_h {
		return true
	}
	return false
}
