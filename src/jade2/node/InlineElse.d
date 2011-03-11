
module jade.node.InlineElse;

import jade.Jade ;

final class InlineElse : Node {
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asLine(this.ln);
		tpl.asCode("} else {\n");
		eachD(tpl);
	}
}