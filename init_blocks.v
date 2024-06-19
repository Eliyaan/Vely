import blocks

fn init_block(b blocks.Blocks) !blocks.Blocks {
	mut block := b
	match mut block {
		blocks.Function {
			block.text = [
				[blocks.Text(blocks.JustT{'fn'}), blocks.InputT{'name'},
					blocks.JustT{'('}, blocks.ButtonT{'(+)'},
					blocks.JustT{')'}, blocks.ButtonT{'(+)'}],
			]
			block.attachs_rel_y = [blocks.blocks_h]
		}
		blocks.Condition {
			block.text << match Vari.from(block.variant)! {
				.condition {
					[blocks.Text(blocks.JustT{'if'}), blocks.InputT{'1 > 0'},
						blocks.JustT{'is true (+)'}]
				}
				.@match {
					[blocks.Text(blocks.JustT{'if'}), blocks.InputT{'0'},
						blocks.JustT{'is'}, blocks.InputT{'0'},
						blocks.ButtonT{'(+)'}]
				}
				else {
					panic('${block.variant} not supported')
				}
			}
			block.attachs_rel_y = []int{len: block.size_in.len, init: blocks.blocks_h +
				(block.size_in[index] + blocks.blocks_h + 2 * blocks.attach_decal_y) * (index + 1)}
			block.attachs_rel_y.insert(0, blocks.blocks_h)
			for nb in 0 .. block.size_in.len - 1 {
				block.text << match Vari.from(block.variant)! {
					.condition {
						if nb == block.size_in.len - 2 {
							[blocks.Text(blocks.JustT{'else'})]
						} else {
							[blocks.Text(blocks.JustT{'else if'}), blocks.InputT{'0 < 1'}]
						}
					}
					.@match {
						if nb == block.size_in.len - 2 {
							[blocks.Text(blocks.JustT{'else'})]
						} else {
							[blocks.Text(blocks.InputT{'0'})]
						}
					}
					else {
						panic('${block.variant} not supported')
					}
				}
			}
		}
		blocks.Loop {
			expand_h := block.size_in[0] + blocks.blocks_h + 2 * blocks.attach_decal_y
			block.attachs_rel_y = [blocks.blocks_h, blocks.blocks_h + expand_h]
			block.text = match Vari.from(block.variant)! {
				.for_range {
					[
						[blocks.Text(blocks.JustT{'for each'}), blocks.InputT{'i'},
							blocks.JustT{'in'}, blocks.InputT{'0'},
							blocks.JustT{'..'}, blocks.InputT{'5'}],
					]
				}
				.for_bool {
					[
						[blocks.Text(blocks.JustT{'while'}), blocks.InputT{'0 == 0'},
							blocks.JustT{'is true'}],
					]
				}
				.for_c {
					[
						[blocks.Text(blocks.JustT{'start'}), blocks.InputT{'i'},
							blocks.JustT{':='}, blocks.InputT{'0'},
							blocks.JustT{'; while'}, blocks.InputT{'1 == 1'},
							blocks.JustT{'->'}, blocks.InputT{'i += 1'}],
					]
				}
				else {
					panic('${block.variant} not handled')
				}
			}
		}
		blocks.Input {
			block.text = match Vari.from(block.variant)! {
				.@return {
					[[blocks.Text(blocks.JustT{'return'})]]
				}
				.panic {
					[
						[blocks.Text(blocks.JustT{'panic('}), blocks.InputT{'"Problem!"'},
							blocks.JustT{')'}],
					]
				}
				else {
					panic('${block.variant} not handled')
				}
			}
			block.attachs_rel_y = []
		}
		blocks.InputOutput {
			block.text = match Vari.from(block.variant)! {
				.declare {
					[
						[blocks.Text(blocks.JustT{'new'}), blocks.ButtonT{'[x]'},
							blocks.JustT{'mut'}, blocks.InputT{'a'},
							blocks.JustT{':='}, blocks.InputT{'0'}],
					]
				}
				.println {
					[
						[blocks.Text(blocks.JustT{'println('}), blocks.InputT{'"Hello!"'},
							blocks.JustT{')'}],
					]
				}
				else {
					panic('${block.variant} not handled')
				}
			}
			block.attachs_rel_y = [blocks.blocks_h]
		}
		else {
			panic('${block} not handled')
		}
	}
	return block
}
