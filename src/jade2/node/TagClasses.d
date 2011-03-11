
module jade.node.TagClasses ;

import jade.Jade ;

final class TagClasses : Node {
	
	void asD(Compiler* cc){
		cc.asString(" class=\"");
		eachD(cc);
		cc.asString("\"");
	}
}