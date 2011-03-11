
module jade.Node ;

import jade.Jade ;

package import 
	jade.node.Attrs ,
	jade.node.Attr ,
	jade.node.AttrIf ,
	
	jade.node.MixString ,
	jade.node.PureString ,
	jade.node.InlineIf ,
	jade.node.InlineElseIf,
	jade.node.InlineElse,
	jade.node.Var ,
	
	jade.node.Block ,
	jade.node.Comment ,
	jade.node.CommentBlock,
	jade.node.Code ,
	jade.node.DocType ,
	
	jade.node.Each ,
	jade.node.IfCode ,
	jade.node.ElseIfCode,
	jade.node.ElseCode,
	
	jade.node.Filter ,
	jade.node.FilterArgs,
	jade.node.FilterTagArg ,
	jade.node.FilterTagArgs ,
	
	jade.node.TagClass ,
	jade.node.TagClasses ,
	jade.node.Tag ;


abstract class Node {
	
	enum Type {
		None ,
		
		Attrs ,
		Attr ,
		AttrIf ,
		
		MixString ,
		PureString ,
		
		Block ,
		Code ,
		Comment ,
		CommentBlock ,
		DocType ,
		Tag ,
		TagClass,
		TagClasses,
		
		Var ,
		
		Filter ,
		FilterArgs,
		FilterTagArg,
		FilterTagArgs,
		
		InlineIf ,
		InlineElseIf ,
		InlineElse ,
		IfCode ,
		ElseIfCode ,
		ElseCode ,
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
	
	
	version(JADE_XTPL) 
	void asD(XTpl tpl){
		assert(false, this.type);
	}
	
	version(JADE_XTPL)
	void eachD(XTpl tpl) {
		for(Node n = firstChild ; n !is null ; n = n.next ) {
			n.asD(tpl);
		}
	}
	
	mixin Pool.Allocator ;
}



