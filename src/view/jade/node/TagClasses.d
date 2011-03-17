
module oak.view.jade.node.TagClasses ;

import oak.view.jade.Jade ;

final class TagClasses : Node {
	
	void asD(Compiler* cc){
		cc.asString(" class=\"");
		eachD(cc);
		cc.asString("\"");
	}
}