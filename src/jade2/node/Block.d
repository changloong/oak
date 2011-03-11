
module jade.node.Block ;

import jade.Jade ;

final class Block : Node {
	
	version(JADE_XTPL) 
	void asD(XTpl tpl) {
		eachD(tpl);
	}
}