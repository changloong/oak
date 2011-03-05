
module jade.node.Each ;

import jade.Jade ;


struct Each {
	mixin Node.Child!(typeof(this)) node ;
	
	Node*	block;
	string	key ;
	string	obj ;
	
	string value(){
		return parent.val ;
	}
}