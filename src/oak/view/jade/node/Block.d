
module oak.view.jade.node.Block ;

import oak.view.jade.Jade ;

final class Block : Node {
	
	void asD(Compiler* cc) {
		eachD(cc);
	}
}