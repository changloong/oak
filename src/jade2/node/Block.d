
module jade.node.Block ;

import jade.Jade ;

final class Block : Node {
	
	void asD(vBuffer bu) {
		eachD(bu);
	}
}