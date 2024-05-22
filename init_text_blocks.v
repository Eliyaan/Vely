import blocks

fn init_block(b blocks.Blocks) !blocks.Blocks {
	mut block := b
	match mut block {
		blocks.Function {
			block.text = ['fn `name` `name type`(+) returns`type`(+)']
		}
		blocks.Condition {
			mut a := []string{}
			a << match Vari.from(block.variant)! {
				.condition {
					'if `condi` is true'
				}
				.@match {
					'if `val` is :'
				}
				else {
					panic('${block.variant} not supported')
				}
			}
			for nb in 0 .. block.size.len - 1 {
				a << match Vari.from(block.variant)! {
					.condition {
						if nb == block.size.len - 2 {
							'else'
						} else {
							'else if'
						}
					}
					.@match {
						if nb == block.size.len - 2 {
							'else'
						} else {
							'`val`'
						}
					}
					else {
						panic('${block.variant} not supported')
					}
				}
			}
			block.text = a
		}
		blocks.Loop {
			block.text = match Vari.from(block.variant)! {
				.for_range {
					['for each `i` in [`0` and `5`)']
				}
				.for_bool {
					['while `bool` is true']
				}
				.for_c {
					[
						'repeat: start `i` equals `0` while `condition` and doing `action`',
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
					['return']
				}
				.panic {
					['panic `arg`']
				}
				else {
					panic('${block.variant} not handled')
				}
			}
		}
		blocks.InputOutput {
			block.text = match Vari.from(block.variant)! {
				.declare {
					['new [x]mut var `a` value `val`']
				}
				else {
					panic('${block.variant} not handled')
				}
			}
		}
		else {
			panic('${block} not handled')
		}
	}
	return block
}
