
module jade.node.Block ;

import jade.Jade ;

final class Block : Node {
	
	void asD(Compiler* cc) {
		eachD(cc);
	}
}