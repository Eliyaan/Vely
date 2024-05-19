module blocks

import gg
import gx

pub struct Condition {
pub:
	id      int
	variant Variants
pub mut:
	x          int
	y          int
	input      int
	output     int
	inner      []int
	conditions []int
	size       []int
}

pub fn (con Condition) show(ctx gg.Context) {
	// Attach up
	ctx.draw_rect_filled(con.x + expand_block_w, (con.y + attach_decal), mid_block_w,
		blocks_h - attach_decal, gx.red)
	// Attach down
	ctx.draw_rect_filled(con.x + mid_block_w + expand_block_w, con.y, mid_block_w, blocks_h +
		attach_decal, gx.green)
	// END
	ctx.draw_rect_filled(con.x + mid_block_w * 2 + expand_block_w, con.y, end_block_w,
		blocks_h, gx.blue)

	mut expand_h := con.size[0] + blocks_h + 2 * attach_decal
	for size in con.size[1..] {
		y := con.y + expand_h
		expand_h += size + blocks_h + 2 * attach_decal
		// Start
		ctx.draw_rect_filled(con.x + expand_block_w, y, start_block_w, blocks_h, gx.red)
		// Attach down
		ctx.draw_rect_filled(con.x + expand_block_w + start_block_w, y, mid_block_w, (blocks_h +
			attach_decal), gx.red)
		// END
		ctx.draw_rect_filled(con.x + expand_block_w + start_block_w + mid_block_w, y,
			end_block_w, blocks_h, gx.red)
	}
	// End for end of the con
	ctx.draw_rect_filled(con.x, con.y, expand_block_w, expand_h + blocks_h, gx.pink)
	y := con.y + expand_h
	// Attach down
	ctx.draw_rect_filled(con.x + expand_block_w, y, mid_block_w, (blocks_h + attach_decal),
		gx.red)
	ctx.draw_rect_filled(con.x + expand_block_w + mid_block_w, y, start_block_w, blocks_h,
		gx.red)
	// END
	ctx.draw_rect_filled(con.x + expand_block_w + mid_block_w + start_block_w, y, end_block_w,
		blocks_h, gx.red)
}

pub fn (con Condition) is_clicked(x int, y int) bool {
	if x < con.x + mid_block_w * 2 + expand_block_w + end_block_w && y < con.y + blocks_h {
		return true
	} else {
		mut expand_h := con.size[0] + blocks_h + 2 * attach_decal
		for size in con.size[1..] {
			if x > con.x + expand_block_w && y > con.y + expand_h {
				if x < con.x + expand_block_w + start_block_w + mid_block_w + end_block_w
					&& y < con.y + expand_h + blocks_h {
					return true
				}
			}
			expand_h += size + blocks_h + 2 * attach_decal
		}
		if x < con.x + expand_block_w && y < con.y + expand_h + blocks_h {
			return true
		}
		if x > con.x + expand_block_w && y > con.y + expand_h {
			if x < con.x + expand_block_w + mid_block_w + start_block_w + end_block_w
				&& y < con.y + expand_h + blocks_h {
				return true
			}
		}
	}
	return false
}
