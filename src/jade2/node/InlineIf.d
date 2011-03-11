
module jade.node.InlineIf ;

import jade.Jade ;

final class InlineIf : Node {
	
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asCode("\nif (").asCode(cond).asCode("){\n");
		eachD(tpl);
		tpl.asCode("\n}\n");
	}
	
}