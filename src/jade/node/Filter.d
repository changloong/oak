
module jade.node.Filter ;

import jade.Jade ;

struct Filter {
	mixin Node.Child!(typeof(this))	node ;
	Node*	block ;
	Tok*	attrs ;
	
}