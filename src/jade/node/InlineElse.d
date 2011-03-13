
module oak.jade.node.InlineElse;

import oak.jade.Jade ;

final class InlineElse : Node {
	
	void asD(Compiler* cc){
		cc.asLine(this.ln);
		cc.asCode("} else {\n");
		eachD(cc);
	}
}