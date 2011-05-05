
module oak.langs.jade.filter.Include ;

import oak.langs.jade.Jade ;



alias oak.langs.jade.node.Filter.Filter Filter ;

void Jade_Include_Filter(Compiler* cc, Filter  node) {
	
	if( node.args.firstChild !is null ) {
		auto path	= cast(PureString) node.args.firstChild  ;
		assert(path !is null);
		auto file = path.value ;
		auto data = cc.load_file( file );
		if( data is null ) {
			cc.err(" include(%s) is not exists at line:%d ", file,  node.ln );
		}
		
		// Log("%s = `%s`", node.type , file );
		Compiler _cc ;
		_cc.reuse(cc);
		_cc.Init(file, data);
		_cc.asCode("\n");
		_cc.asLine(1);
		
		_cc.compile(true) ;
		_cc.reuse_clear ;
		
		cc.asLine(node.ln);
		
		return ;
	}
	
	cc.err(" include mising params at line:%d ",  node.ln );
}