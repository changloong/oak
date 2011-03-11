
module jade.node.ElseCode ;

import jade.Jade ;

final class ElseCode : Node {
	
	void asD(Compiler* cc){
		cc.asLine(this.ln);
		cc.asCode("} else {\n");
		eachD(cc);
	}
}