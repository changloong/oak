
module oak.view.jade.filter.Js ;

import oak.view.jade.Jade ;


alias oak.view.jade.node.Filter.Filter Filter ;

void Jade_Js_Filter(Compiler* cc, Filter  node){
	
	if( node.args !is null ) {
		cc.err("js filter  can't  have args, at line %d", node.ln);
	}
	
	if( node.tag_args !is null ) {
		cc.err("js filter  can't  have tag args, at line %d", node.ln);
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