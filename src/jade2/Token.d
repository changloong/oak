module jade.Token;

import jade.Jade ;

struct Tok {
	enum Type {
		None ,
		
		String ,
		DocType ,
		CommentStart ,
		CommentEnd ,
		CommentBlock ,

		Tag ,
		Id ,
		Class ,
		AttrStart ,
		AttrEnd ,
		AttrKey ,
		AttrValueStart ,
		AttrValueEnd ,

		Var ,
		If ,
		ElseIf ,
		Else ,
		EnfIf ,

		Code ,	
		
		Each ,
		Each_Type ,
		Each_Key ,
		Each_Value ,
		Each_Object ,
		
		IfCode,
		ElseIfCode,
		ElseCode,
		
		FilterType ,
		FilterArgStart ,
		FilterArgEnd ,
		
		FilterTagKey ,
		FilterTagValueStart ,
		FilterTagValueEnd ,
		FilterTagStart ,
		FilterTagEnd ,
	}
	
	static const string[] Type_Name	= EnumMemberName!(Type) ;
	
	Type	ty ;
	size_t	ln, _ln ;
	size_t	tabs ;
	Tok*	next ;
	Tok*	pre ;

	string	string_value ;
	bool	bool_value ;
	
	alias bool_value escaped ;
	
	
	bool opDispatch(string name)() if( name.length > 2 && name[0..2] == "is" ) {
		static const _ty = ctfe_indexOf!(string)(Type_Name, name[2..$]);
		static assert(_ty >=0 ,  typeof(this).stringof ~ "." ~ name ~ " is not exists");
		return _ty is ty ;
	}
	
	string type(string _file = __FILE__, ptrdiff_t _line = __LINE__)(){
		// Log!(_file, _line)("this=%x", cast(void*) &this);
		assert( ty < Type_Name.length && ty >= 0 );
		return Type_Name[ty] ;
	}
	
	static string sType(Tok.Type ty){
		assert( ty < Type_Name.length && ty >= 0 );
		return Type_Name[ty] ;
	}

}
