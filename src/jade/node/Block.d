
module jade.node.Block;

import jade.Jade ;

struct Block {
	mixin Node.Child!(typeof(this)) node ;
	
	Node*[]	list;
	
	void push(Node* it){
		list	~= it ;
	}
	
	int opApply (int delegate (ref Node*) dg) {
		int  ret ;
		foreach(int i, ref _node; list ) {
			ret	= dg(_node) ;
			if( ret !is 0 ){
				return ret ;
			}
		}
		return ret ;
	}
	
	int opApply (int delegate (int , ref Node*) dg) {
		int  ret ;
		foreach(int i, ref _node; list ) {
			ret	= dg(i, _node) ;
			if( ret !is 0 ){
				return ret ;
			}
		}
		return ret ;
	}
	
	bool empty(){
		return list.length is 0 ;
	}
}