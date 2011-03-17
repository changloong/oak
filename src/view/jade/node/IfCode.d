
module oak.view.jade.node.IfCode ;

import oak.view.jade.Jade ;

final class IfCode : Node {
	
	string 		cond ;
	ElseIfCode	elseif ;
	ElseCode	elseBlock ;
	
	this(Tok* tk) {
		assert(tk !is null);
		cond	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		cc.asLine(this.ln);
		cc.asCode("if (").asCode(cond).asCode(") { \n");
		eachD(cc);
		if( elseif !is null ) {
			elseif.asD(cc);
		}
		if( elseBlock !is null ) {
			elseBlock.asD(cc);
		}
		cc.asCode("}\n");
	}
}