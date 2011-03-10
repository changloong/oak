
module jade.node.MixString ;

import jade.Jade ;

final class MixString : Node {
	
	version(JADE_XTPL)
	void asD(vBuffer bu) {
		eachD(bu);
	}
}