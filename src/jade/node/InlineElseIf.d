
module oak.jade.node.InlineElseIf ;

import oak.jade.Jade ;

final class InlineElseIf : Node {
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		cc.asLine(this.ln);
		cc.asCode("}else if (").asCode(cond).asCode("){\n");
		eachD(cc);
	}
}