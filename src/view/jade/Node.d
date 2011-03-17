
module oak.view.jade.Node ;

import oak.view.jade.Jade ;

package import 
	oak.view.jade.node.Attrs ,
	oak.view.jade.node.Attr ,
	oak.view.jade.node.AttrIf ,
	
	oak.view.jade.node.MixString ,
	oak.view.jade.node.PureString ,
	oak.view.jade.node.InlineIf ,
	oak.view.jade.node.InlineElseIf,
	oak.view.jade.node.InlineElse,
	oak.view.jade.node.Var ,
	
	oak.view.jade.node.Block ,
	oak.view.jade.node.Comment ,
	oak.view.jade.node.CommentBlock,
	oak.view.jade.node.Code ,
	oak.view.jade.node.DocType ,
	
	oak.view.jade.node.Each ,
	oak.view.jade.node.IfCode ,
	oak.view.jade.node.ElseIfCode,
	oak.view.jade.node.ElseCode,
	
	oak.view.jade.node.Filter ,
	oak.view.jade.node.FilterArgs,
	oak.view.jade.node.FilterTagArg ,
	oak.view.jade.node.FilterTagArgs ,
	
	oak.view.jade.node.TagClass ,
	oak.view.jade.node.TagClasses ,
	oak.view.jade.node.Tag ;


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
	
	static const string[] Type_Name = ctfe_enum_array!(Type) ;
	
	Type		ty ;
	size_t	ln ;
	Tok*		_tok ;
	Node		next , firstChild , lastChild ;
	
	bool opDispatch(string name)() if( name.length > 2 && name[0..2] == "is" ) {
		static const _ty = ctfe_indexof!(string)(Type_Name, name[2..$]);
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
	
	
	void asD(Compiler* cc){
		assert(false, this.type);
	}
	
	void eachD(Compiler* cc) {
		for(Node n = firstChild ; n !is null ; n = n.next ) {
			n.asD(cc);
		}
	}
	
	void err(size_t _line = __LINE__, T...)(Compiler* cc, string fmt,  T t){
		auto a = appender!string() ;
		formattedWrite(a, "(%s:%d) ", __FILE__, _line);
		formattedWrite(a, fmt, t);
		formattedWrite(a, " at file:`%s` line:%d", cc.filename, ln);
		throw new Exception(a.data);
	}
	
	mixin Pool.Allocator ;
}



