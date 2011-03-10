
module jade.node.InlineElse;

import jade.Jade ;

final class InlineElse : Node {
	
	version(JADE_XTPL)
	void asD(vBuffer bu){
		bu("\n} else {\n");
		eachD(bu);
	}
}