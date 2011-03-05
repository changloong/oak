
module xtpl.Vars ;

import 
	xtpl.all;
	
class XTpl_Var {
	ptrdiff_t	id ;
	ptrdiff_t	offset ;
	ptrdiff_t	size ;
	string		type, name, tyid, loc ;
	XTpl		_tpl ;
	
	enum Index {
		Name ,
		Loc ,
		Type ,
		TypeID ,
		Size ,
	}
	
	string index_message(){
		return _tpl._name ~ ":" ~ name ~ ":" ~ ctfe_i2a(id) ~ ":" ~ ctfe_i2a(offset) ~ ":" ~  ctfe_i2a(size) ;
	}
	
	public this(XTpl tpl, char[][] args){
		string var_name	= cstring_dup(args[ Index.Name ].ptr) ;
		
		auto _pvar	= var_name in tpl._vars ;
		if( _pvar !is null ){
			return  ;
		}
		
		id	= tpl._vars.length ;
		
		name	= var_name ;
		type	= cstring_dup(args[Index.Type ].ptr) ;
		tyid	= cstring_dup(args[Index.TypeID].ptr) ;
		size	= ctfe_a2i(args[Index.Size]) ;
		loc	= cstring_dup(args[ Index.Loc ].ptr) ;
		_tpl	= tpl ;
		offset	= tpl._offset ;
		
		int _size	= size ;
	
		while(  _size > 0 ) {
			tpl._offset	+= size_t.sizeof ;
			_size		-= size_t.sizeof ;
		}
		
		tpl._vars[var_name]	= this ;
		version(PLUGIN_DEBUG)
			tpl_print("assign tpl.name=`%s` var=`%s` id=%d  tyid=`%s` size=%d offset=%d loc=`%s` ", tpl, name, id, tyid, size, offset, loc );
	}
	
}