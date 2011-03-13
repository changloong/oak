
module oak.jade.node.Block ;

import oak.jade.Jade ;

final class Block : Node {
	
	void asD(Compiler* cc) {
		eachD(cc);
	}
}