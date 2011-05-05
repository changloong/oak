
module oak.langs.jade.filter.Block ;

import oak.langs.jade.Jade ;



alias oak.langs.jade.node.Filter.Filter Filter ;

void Jade_Block_Filter(Compiler* cc, Filter node) {
	auto name	= cast(PureString) node.args.firstChild ;

	cc.asLine(node.ln);
	cc.asCode("void block_").asCode( name.value ).asCode("() {\n");
	node.eachD(cc);
	cc.asCode("\n}\n");
	
}