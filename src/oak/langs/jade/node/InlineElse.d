
module oak.langs.jade.node.InlineElse;

import oak.langs.jade.Jade ;

final class InlineElse : Node {
	
	void asD(Compiler* cc){
		cc.asLine(this.ln);
		cc.asCode("} else {\n");
		eachD(cc);
	}
}