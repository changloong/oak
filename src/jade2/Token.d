module jade.Token;

import jade.Jade ;

struct Tok {
	enum Type {
		None ,
		
		String ,
		DocType ,
		Comment ,

		Tag ,
		Id ,
		Class ,
		AttrStart ,
		Attr ,
		AttrEnd ,
		AttrKey ,
		AttrValue ,

		Var ,
		If ,
		ElseIf ,
		Else ,
		EnfIf ,

		Each ,
		Each_Type ,
		Each_Key ,
		Each_Value ,
		Each_Object ,
		Each_Range ,
		Each_From ,
		Each_To ,
		Each_Step ,
		
		Code ,	
		
		Filter ,
	}
	
	static const string[] Type_Name	= EnumMemberName!(Type) ;
	
	Type	ty ;
	size_t	ln ;
	size_t	tabs ;
	Tok*	next ;
	Tok*	pre ;
	
	union {
		// String 
		string	string_value ;
		
	}
	
	bool opDispatch(string name)() if( name.length > 2 && name[0..2] == "is" ) {
		static const _ty = ctfe_indexOf!(string)(Type_Name, name[2..$]);
		static assert(_ty >=0 ,  typeof(this).stringof ~ "." ~ name ~ " is not exists");
		return _ty is ty ;
	}
	
	string type(){
		assert( ty < Type_Name.length && ty >= 0 );
		return Type_Name[ty] ;
	}
	
	static string sType(Tok.Type ty){
		assert( ty < Type_Name.length && ty >= 0 );
		return Type_Name[ty] ;
	}

}
