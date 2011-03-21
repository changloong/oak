
module oak.view.jade.node.ElseCode ;

import oak.view.jade.Jade ;

final class ElseCode : Node {
	
	void asD(Compiler* cc){
		cc.asLine(this.ln);
		cc.asCode("} else {\n");
		eachD(cc);
	}
}