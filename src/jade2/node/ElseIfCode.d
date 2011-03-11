
module jade.node.ElseIfCode ;

import jade.Jade ;

final class ElseIfCode : Node {
	
	string 		cond ;
	ElseIfCode	elseif ;
	ElseCode	elseBlock ;

	
	this(Tok* tk) {
		assert(tk !is null);
		cond	= tk.string_value ;
	}
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asLine(this.ln);
		tpl.asCode("}else if (").asCode(cond).asCode("){\n");
		eachD(tpl);
	}
}