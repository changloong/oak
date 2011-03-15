
module oak.jade.filter.Text ;

import oak.jade.Jade ;


alias oak.jade.node.Filter.Filter Filter ;

void Jade_Text_Filter(Compiler* cc, Filter  node){
	
	if( node.args !is null ) {
		cc.err("text filter  can't  have args, at line %d", node.ln);
	}
	
	if( node.tag_args !is null ) {
		cc.err("text filter  can't  have tag args, at line %d", node.ln);
	}
	
	if( node.tag !is null ) {
		cc.asString("<textarea");
		node.tag.asAttrs( cc ) ;
		cc.asString(">");
	} else {
		cc.asString("<textarea>");
	}
	setEscape(node, true) ;
	node.eachD(cc);
	cc.asString("</textarea>");
}

private void setEscape(Node node, bool escape = true ) {
	for(auto n = node.firstChild; n !is null; n = n.next ) {
		if( n.ty is Node.Type.PureString ) {
			auto _n = cast(PureString) n ;
			assert( _n !is null) ;
			_n.escape = escape ;
		} else if( n.ty is Node.Type.Var ) {
			auto _n = cast(Var) n ;
			assert( _n !is null) ;
			_n.unQuota = escape ;
		} else {
			setEscape(n, escape);
		}
	}
}