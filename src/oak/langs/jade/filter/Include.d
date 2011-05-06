
module oak.langs.jade.filter.Include ;

import oak.langs.jade.Jade ;



alias oak.langs.jade.node.Filter.Filter Filter ;

void Jade_Include_Filter(Compiler* cc, Filter  node) {
	auto path = cast(PureString) node.args.firstChild  ;
	assert(path !is null);
	auto file = path.value ;
	cc.compiler_child( path.value,  node.ln);
}