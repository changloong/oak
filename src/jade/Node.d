
module oak.jade.Node ;

import oak.jade.Jade ;

package import 
	oak.jade.node.Attrs ,
	oak.jade.node.Attr ,
	oak.jade.node.AttrIf ,
	
	oak.jade.node.MixString ,
	oak.jade.node.PureString ,
	oak.jade.node.InlineIf ,
	oak.jade.node.InlineElseIf,
	oak.jade.node.InlineElse,
	oak.jade.node.Var ,
	
	oak.jade.node.Block ,
	oak.jade.node.Comment ,
	oak.jade.node.CommentBlock,
	oak.jade.node.Code ,
	oak.jade.node.DocType ,
	
	oak.jade.node.Each ,
	oak.jade.node.IfCode ,
	oak.jade.node.ElseIfCode,
	oak.jade.node.ElseCode,
	
	oak.jade.node.Filter ,
	oak.jade.node.FilterArgs,
	oak.jade.node.FilterTagArg ,
	oak.jade.node.FilterTagArgs ,
	
	oak.jade.node.TagClass ,
	oak.jade.node.TagClasses ,
	oak.jade.node.Tag ;


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



