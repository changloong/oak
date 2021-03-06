
module oak.langs.jade.filter.Text ;

import oak.langs.jade.Jade ;


alias oak.langs.jade.node.Filter.Filter Filter ;

void Jade_Text_Filter(Compiler* cc, Filter  node){

	if( node.tag !is null ) {
		node.tag.find_name = true ;
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