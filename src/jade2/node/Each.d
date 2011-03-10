
module jade.node.Each ;

import jade.Jade ;

final class Each : Node {
	string type, key, value, obj ;
	
	this(Tok* tk){
		assert(tk !is null);
		obj	= tk.string_value ;
	}
	
	version(JADE_XTPL)
	void asD(vBuffer bu){
		bu("\nforeach(");
		if( type !is null ) {
			bu(type)(' ')(key)(',')(value);
		} else if( key !is null ){
			bu(key)(',')(value);
		} else {
			bu(value);
		}
		
		bu(';')(obj)(") { \n");
		
		eachD(bu);
		bu("\n}\n");
	}
}