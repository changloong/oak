
module jade.node.TagClasses ;

import jade.Jade ;

final class TagClasses : Node {
	
	void asD(vBuffer bu){
		bu(" class=\"");
		eachD(bu);
		bu("\"");
	}
}