
module jade.node.IfCode ;

import jade.Jade ;

final class IfCode : Node {
	
	string 		cond ;
	ElseIfCode	elseif ;
	ElseCode	elseBlock ;
	
	this(Tok* tk) {
		assert(tk !is null);
		cond	= tk.string_value ;
	}
	
	version(JADE_XTPL)
	void asD(XTpl tpl){
		tpl.asCode("\nif (").asCode(cond).asCode(") { \n");
		eachD(tpl);
		if( elseif !is null ) {
			elseif.asD(tpl);
		}
		if( elseBlock !is null ) {
			elseBlock.asD(tpl);
		}
		tpl.asCode("\n}\n");
	}
}