
module jade.Node ;

import jade.Jade ;

package import 
	jade.node.Attrs ,
	jade.node.Attr ,
	
	jade.node.MixString ,
	jade.node.PureString ,
	jade.node.InlineIf ,
	jade.node.Var ,
	
	jade.node.Block ,
	jade.node.Comment ,
	jade.node.Code ,
	jade.node.DocType ,
	
	jade.node.Filter ,
	jade.node.FilterArgs,
	
	jade.node.Tag ;


abstract class Node {
	
	enum Type {
		None ,
		
		Attrs ,
		Attr ,
		
		MixString ,
		PureString ,
		
		Block ,
		Code ,
		Comment ,
		DocType ,
		Tag ,
		
		Var ,
		
		Filter ,
		FilterArgs,
		
		InlineIf ,
		Each ,
	}
	
	static const string[] Type_Name = EnumMemberName!(Type) ;
	
	Type		ty ;
	size_t	ln ;
	Tok*		_tok ;
	Node		next , firstChild , lastChild ;
	
	bool opDispatch(string name)() if( name.length > 2 && name[0..2] == "is" ) {
		static const _ty = ctfe_indexOf!(string)(Type_Name, name[2..$]);
		static assert(_ty >=0 ,  typeof(this).stringof ~ "." ~ name ~ " is not exists");
		return _ty is ty ;
	}
	
	string type(){
		assert( ty < Type_Name.length && ty >= 0 );
		return Type_Name[ty] ;
	}
	
	void pushChild(Node node) {
		if( firstChild is null ) {
			assert(lastChild is null) ;
			firstChild	= node ;
			lastChild	= node ;
		} else {
			assert(lastChild !is null) ;
			lastChild.next	= node ;
			lastChild	= node ;
		}
	}
	
	bool empty() {
		return firstChild is null ;
	}
	
	mixin Pool.Allocator ;
}



