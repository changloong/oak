
module jade.node.InlineElseIf ;

import jade.Jade ;

final class InlineElseIf : Node {
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asLine(this.ln);
		tpl.asCode("}else if (").asCode(cond).asCode("){\n");
		eachD(tpl);
	}
}