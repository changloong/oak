
module jade.node.TagClasses ;

import jade.Jade ;

final class TagClasses : Node {
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asString(" class=\"");
		eachD(tpl);
		tpl.asString("\"");
	}
}