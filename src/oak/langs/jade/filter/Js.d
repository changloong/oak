
module oak.langs.jade.filter.Js ;

import oak.langs.jade.Jade ;


alias oak.langs.jade.node.Filter.Filter Filter ;

void Jade_Js_Filter(Compiler* cc, Filter  node){
		
	if( node.args !is null ) {
		if( node.args.length is 1 ) {
			cc.asString("\n" `<script type="text/javascript" src="`);
			node.args.firstChild.asD(cc);
			cc.asString(`"></script>`);
			return ;
		}
		cc.err("js filter only can have one argument, at line %d", node.ln);
	}
	
	if( node.tag !is null ) {
		cc.asString("\n" `<script type="text/javascript"` );
		node.tag.asAttrs( cc ) ;
		cc.asString(">");
		node.eachD(cc);
		cc.asString("</script>");
	} else {
		cc.asString("\n" `<script type="text/javascript">` "\n" ) ;
		node.eachD(cc);
		cc.asString("</script>\n");
	}
}