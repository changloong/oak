
module oak.jade.filter.Css ;

import oak.jade.Jade ;


alias oak.jade.node.Filter.Filter Filter ;

void Jade_Css_Filter(Compiler* cc, Filter  node){
	
	if( node.tag is null ) {
		cc.asString(`<style type="text/css">`);
		node.eachD(cc);
		cc.asString(`</style>`);
		return ;
	} 
	
	if( node.empty ) {
		cc.asString(`<link rel="stylesheet" type="text/css" media="all" `);
		node.tag.asAttrs( cc ) ;
		cc.asString(` />`);
	} else {
		cc.asString(`<style type="text/css"`);
		node.tag.asAttrs( cc ) ;
		cc.asString(`>`);
		node.eachD(cc);
		cc.asString(`</style>`);
	}
}