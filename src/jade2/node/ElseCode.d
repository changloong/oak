
module jade.node.ElseCode ;

import jade.Jade ;

final class ElseCode : Node {
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asCode("\n} else {\n");
		eachD(tpl);
	}
}