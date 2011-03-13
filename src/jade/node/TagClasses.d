
module oak.jade.node.TagClasses ;

import oak.jade.Jade ;

final class TagClasses : Node {
	
	void asD(Compiler* cc){
		cc.asString(" class=\"");
		eachD(cc);
		cc.asString("\"");
	}
}