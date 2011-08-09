
module oak.langs.jade.node.ElseIfCode ;

import oak.langs.jade.Jade ;

final class ElseIfCode : Node {
	
	string 		cond ;
	ElseIfCode	elseif ;
	ElseCode	elseBlock ;

	
	this(Tok tk) {
		assert(tk !is null);
		cond	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		cc.asLine(this.ln);
		cc.asCode("}else if (").asCode(cond).asCode("){\n");
		eachD(cc);
	}
}