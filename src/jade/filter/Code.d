
module oak.jade.filter.Code ;

import oak.jade.Jade ;


alias oak.jade.node.Filter.Filter Filter ;

void Jade_Code_Filter(Compiler* cc, Filter  node){
	for(auto n = node.firstChild; n !is null; n = n.next ) {
		if( n.ty is Node.Type.PureString ) {
			auto _n = cast(PureString) n ;
			assert(_n !is null);
			cc.asCode( _n.value );
		}
	}
}

