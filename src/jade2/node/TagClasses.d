
module jade.node.TagClasses ;

import jade.Jade ;

final class TagClasses : Node {
	
	version(JADE_XTPL)
	void asD(vBuffer bu){
		bu(" class=\"");
		eachD(bu);
		bu("\"");
	}
}