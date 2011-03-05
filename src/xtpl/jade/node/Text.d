
module jade.node.Text ;

import jade.Jade ;

struct Text {
	mixin Node.Child!(typeof(this)) node ;
	
	void push(string val){
		assert(false);
	}
	
	void fill(vBuffer bu) {
		bu(parent.val) ;
	}
}