
module jade.node.Each ;

import jade.Jade ;

final class Each : Node {
	string type, key, value, obj ;
	
	this(Tok* tk){
		assert(tk !is null);
		obj	= tk.string_value ;
	}
	
	
	void asD(vBuffer bu){
		bu("\nforach(");
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