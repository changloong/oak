
module jade.node.ElseCode ;

import jade.Jade ;

final class ElseCode : Node {
	
	version(JADE_XTPL)
	void asD(vBuffer bu){
		bu("\n} else {\n");
		eachD(bu);
	}
}