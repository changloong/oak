
module jade.Node ;

import jade.Jade ;


private enum NodeType {
	None ,
	// Attrs ,
	Block ,
	Code ,
	Comment ,
	DocType ,
	Each ,
	Filter ,
	Tag ,
	Text ,
}


abstract class Node {
	
	mixin Pool.Allocator ;
}



