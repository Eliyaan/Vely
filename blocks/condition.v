module blocks

import gg
import gx

pub struct Condition {
pub:
	id      int
	variant int 
pub mut:
	x          int
	y          int	
	text []string
	input      int
	output     int
	inner      []int
	conditions []int
	size       []int
}

pub fn (con Condition) show(ctx gg.Context) {
	size := int(f32(con.text[0].len) * 8.8) - (attach_w + attach_w + attach_w + end_block_w)
	// Attach up
	ctx.draw_rect_filled(con.x + attach_w, (con.y + attach_decal_y), attach_w,
		blocks_h - attach_decal_y, gx.pink)
	// Attach down
	ctx.draw_rect_filled(con.x + attach_w + attach_w, con.y, attach_w, blocks_h +
		attach_decal_y, gx.pink)
	// END
	ctx.draw_rect_filled(con.x + attach_w * 2 + attach_w, con.y, end_block_w + size,
		blocks_h, gx.pink)

	mut expand_h := con.size[0] + blocks_h + 2 * attach_decal_y
	mut pos := []int{}
	for nb, size_px in con.size[1..] {
		size_in := int(f32(con.text[nb+1].len)*8.8) - (attach_w*2 + end_block_w)
		y := con.y + expand_h
		pos << y
		expand_h += size_px + blocks_h + 2 * attach_decal_y
		// Start
		ctx.draw_rect_filled(con.x + attach_w, y, attach_w, blocks_h, gx.pink)
		// Attach down
		ctx.draw_rect_filled(con.x + attach_w + attach_w, y, attach_w, (blocks_h +
			attach_decal_y), gx.pink)
		// END
		ctx.draw_rect_filled(con.x + attach_w + attach_w + attach_w, y,
			end_block_w + size_in, blocks_h, gx.pink)
	}
	// End for end of the con
	ctx.draw_rect_filled(con.x, con.y, attach_w, expand_h + blocks_h, gx.pink)
	y := con.y + expand_h
	// Attach down
	ctx.draw_rect_filled(con.x + attach_w, y, attach_w, (blocks_h + attach_decal_y),
		gx.pink)
	ctx.draw_rect_filled(con.x + attach_w + attach_w, y, attach_w, blocks_h,
		gx.pink)
	// END
	ctx.draw_rect_filled(con.x + attach_w + attach_w + attach_w, y, end_block_w + size,
		blocks_h, gx.pink)
	for nb, y_pos in pos {
		ctx.draw_text(con.x + attach_w/2, y_pos + blocks_h/2, con.text[nb + 1], text_cfg)
	}
	ctx.draw_text(con.x + attach_w/2, con.y + blocks_h/2, con.text[0], text_cfg)
}

pub fn (con Condition) is_clicked(x int, y int) bool {
	size := int(f32(con.text[0].len) * 8.8) - (attach_w + attach_w + attach_w + end_block_w)
	if x < con.x + attach_w * 2 + attach_w + end_block_w + size && y < con.y + blocks_h {
		return true
	} else {
		mut expand_h := con.size[0] + blocks_h + 2 * attach_decal_y
		for nb, size_px in con.size[1..] {
			size_in := int(f32(con.text[nb+1].len)*8.8) - (attach_w*2 + end_block_w)
			if x > con.x + attach_w && y > con.y + expand_h {
				if x < con.x + attach_w + attach_w + attach_w + end_block_w + size_in
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
			if x < con.x + attach_w + attach_w + attach_w + end_block_w + size
				&& y < con.y + expand_h + blocks_h {
				return true
			}
		}
	}
	return false
}
