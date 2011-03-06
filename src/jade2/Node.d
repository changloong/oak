
module jade.Node ;

import jade.Jade ;



abstract class Node {
	enum Type {
		None ,
		Attrs ,
		Block ,
		Code ,
		Comment ,
		DocType ,
		Each ,
		Filter ,
		Tag ,
		Text ,
	}
	static const string[] Type_Name = EnumMemberName!(Type) ;
	
	Type	ty ;
	size_t	ln ;
	
	bool opDispatch(string name)() if( name.length > 2 && name[0..2] == "is" ) {
		static const _ty = ctfe_indexOf!(string)(Type_Name, name[2..$]);
		static assert(_ty >=0 ,  typeof(this).stringof ~ "." ~ name ~ " is not exists");
		return _ty is ty ;
	}
	
	string type(){
		assert( ty < Type_Name.length && ty >= 0 );
		return Type_Name[ty] ;
	}
	
	mixin Pool.Allocator ;
}



