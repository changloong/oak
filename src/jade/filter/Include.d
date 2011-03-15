
module oak.jade.filter.Include ;

import oak.jade.Jade ;



alias oak.jade.node.Filter.Filter Filter ;

void Jade_Include_Filter(Compiler* cc, Filter  node) {
	
	if( node.hasVar ) {
		cc.err("include filter can't start with double colon, at line %d", node.ln);
	}

	if( node.tag !is null ) {
		cc.err("include filter  can't  have tag, at line %d", node.ln);
	}
	if( node.tag_args !is null ) {
		cc.err("include filter  can't  have tag args, at line %d", node.ln);
	}
	
	for( auto arg =  node.args.firstChild; arg !is null ; arg = arg.next ) {
		if( arg.firstChild  !is null ) {
			auto val	= cast(PureString) arg.firstChild  ;
			if( val !is null ) {
				auto file = val.value ;
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
		}
	}
	cc.err(" include mising params at line:%d ",  node.ln );
}