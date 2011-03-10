
module jade.node.Block ;

import jade.Jade ;

final class Block : Node {
	
	version(JADE_XTPL) 
	void asD(vBuffer bu) {
		eachD(bu);
	}
}