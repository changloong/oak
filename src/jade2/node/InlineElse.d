
module jade.node.InlineElse;

import jade.Jade ;

final class InlineElse : Node {
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asCode("\n} else {\n");
		eachD(tpl);
	}
}