
module jade.node.MixString ;

import jade.Jade ;

final class MixString : Node {
	
	version(JADE_XTPL)
	void asD(XTpl tpl) {
		eachD(tpl);
	}
}