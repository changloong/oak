
module jade.node.Code;

import jade.Jade ;

struct Code {
	mixin Node.Child!(typeof(this)) node ;
		
	Node*		block ;
	bool		isVar ;
}