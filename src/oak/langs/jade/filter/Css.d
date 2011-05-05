
module oak.langs.jade.filter.Css ;

import oak.langs.jade.Jade ;


alias oak.langs.jade.node.Filter.Filter Filter ;

void Jade_Css_Filter(Compiler* cc, Filter  node){
	
	if( node.args !is null ) {
		if( node.args.length is 1 ) {
			cc.asString(`<link rel="stylesheet" type="text/css" media="all" href="`);
			node.args.firstChild.asD(cc);
			cc.asString(`" />`);
			return ;
		}
		cc.err("css filter only can have one argument, at line %d", node.ln);
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