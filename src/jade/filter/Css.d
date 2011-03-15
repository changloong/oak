
module oak.jade.filter.Css ;

import oak.jade.Jade ;


alias oak.jade.node.Filter.Filter Filter ;

void Jade_Css_Filter(Compiler* cc, Filter  node){
	
	if( node.args !is null ) {
		cc.err("css filter  can't  have args, at line %d", node.ln);
	}
	
	if( node.tag_args !is null ) {
		cc.err("css filter  can't  have tag args, at line %d", node.ln);
	}
	
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