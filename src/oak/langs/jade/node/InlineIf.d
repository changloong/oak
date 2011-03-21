
module oak.langs.jade.node.InlineIf ;

import oak.langs.jade.Jade ;

final class InlineIf : Node {
	
	string		cond ;
	
	this(Tok* tk) {
		cond	= tk.string_value ;
	}
	
	void asD(Compiler* cc){
		cc.asLine(this.ln);
		cc.asCode("if (").asCode(cond).asCode("){\n");
		eachD(cc);
		cc.asCode("}\n");
	}
	
}