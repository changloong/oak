
module jade.node.InlineElse;

import jade.Jade ;

final class InlineElse : Node {

	void asD(vBuffer bu){
		bu("\n} else {\n");
		eachD(bu);
	}
}