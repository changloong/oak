
module oak.jade.filter.Text ;

import oak.jade.Jade ;


alias oak.jade.node.Filter.Filter Filter ;

void Jade_Text_Filter(Compiler* cc, Filter  node){
	cc.asString("<textarea>");
	node.eachD(cc);
	cc.asString("</textarea>");
}