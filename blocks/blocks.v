module blocks

import gg
import gx
import os

const attach_decal_y = 5
const attach_w = 14
const end_block_w = 10
const blocks_h = 27
const text_cfg = gx.TextCfg{color:gx.black, size:15, vertical_align:.middle}
pub const font_path := os.resource_abs_path('0xProtoNerdFontMono-Regular.ttf')

pub interface Blocks {
	id      int
	variant int
	show(ctx gg.Context)
	is_clicked(x int, y int) bool
mut:
	x int
	y int
	text []string
}

