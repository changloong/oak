
module oak.langs.jade.node.TagClasses ;

import oak.langs.jade.Jade ;

final class TagClasses : Node {
	
	void asD(Compiler* cc){
		cc.asString(" class=\"");
		eachD(cc);
		cc.asString("\"");
	}
}