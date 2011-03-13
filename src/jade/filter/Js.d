
module oak.jade.filter.Js ;

import oak.jade.Jade ;


alias oak.jade.node.Filter.Filter Filter ;

void Jade_Js_Filter(Compiler* cc, Filter  node){
	cc.asString("\n" `<script type="text/javascript">` "\n");
	node.eachD(cc);
	cc.asString("</script>\n");
}