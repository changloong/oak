
module jade.node.Var ;

import jade.Jade ;

final class Var : Node {
	string		value ;
	this(Tok* tk) {
		value	= tk.string_value ;
	}
	
	version(JADE_XTPL)
	void asD(XTpl tpl) {
		tpl.asLine(this.ln);
		tpl.asVar(value);
	}
}