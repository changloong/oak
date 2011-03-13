
module oak.jade.filter.Js ;

import oak.jade.Jade ;


alias oak.jade.node.Filter.Filter Filter ;

void Jade_Js_Filter(Compiler* cc, Filter  node){
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