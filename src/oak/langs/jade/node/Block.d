
module oak.langs.jade.node.Block ;

import oak.langs.jade.Jade ;

final class Block : Node {
	
	void asD(Compiler* cc) {
		eachD(cc);
	}
}