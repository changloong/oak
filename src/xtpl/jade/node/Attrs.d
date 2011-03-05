
module jade.node.Attrs ;

import jade.Jade ;


struct Attrs {
	Tok*	id ;
	Tok*[]	className ;
	string[string] list ;
	
	void add(string key, string val) {
		//log(key, "=`", val, "`");
		list[key]	= val ;
	}
	
	void add(Tok* tok) {
		if( tok.isId ) {
			id	= tok ;
		} else if(  tok.isClass ) {
			className	~= tok ;
		} else {
			assert(false);
		}
	}
	
	void copy(Attrs* attrs ){
		if( attrs.id ) {
			id	= attrs.id ;
		}
		foreach( _class ;attrs.className){
			className	~= _class ;
		}
		foreach( string key, ref val; attrs.list ) {
			list[key]	= val ;
		}
	}
	
	bool empty(){
		if( id !is null || className.length  || list.length ) {
			return false;
		}
		return true ;
	}
}