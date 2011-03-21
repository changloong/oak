
module oak.langs.jade.filter.Code ;

import oak.langs.jade.Jade ;


alias oak.langs.jade.node.Filter.Filter Filter ;

void Jade_Code_Filter(Compiler* cc, Filter  node){
	if( node.hasVar ) {
		cc.err("code filter can't start with double colon, at line %d", node.ln);
	}
	
	if( node.args !is null ) {
		cc.err("code filter  can't  have args, at line %d", node.ln);
	}
	
	if( node.tag !is null ) {
		cc.err("code filter  can't  have tag, at line %d", node.ln);
	}
	if( node.tag_args !is null ) {
		cc.err("code filter  can't  have tag args, at line %d", node.ln);
	}
	for(auto n = node.firstChild; n !is null; n = n.next ) {
		if( n.ty is Node.Type.PureString ) {
			auto _n = cast(PureString) n ;
			assert(_n !is null);
			cc.asCode( _n.value );
		}
	}
}

