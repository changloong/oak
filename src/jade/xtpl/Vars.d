
module oak.jade.xtpl.Vars ;

import 
	oak.jade.xtpl.all;



class XTpl_Var {
	static struct Each_Key_Value {
		string key, value ;
		this( string _key, string _val){
			key	= _key ;
			value	= _val ;
		}
	}
	ptrdiff_t	id ;
	ptrdiff_t	offset ;
	ptrdiff_t	size ;
	string		type, name, tyid, loc ;
	XTpl		_tpl ;
	Each_Key_Value*[]	_Each_Types ;
	
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
		
		ptrdiff_t _size	= size ;
		
		ptrdiff_t _step	= _G.is64 ? 8 : 4 ;
		
		while(  _size > 0 ) {
			tpl._offset	+= _step ;
			_size		-= _step ;
		}
		
		tpl._vars[var_name]	= this ;
		version(PLUGIN_DEBUG)
			tpl_print("assign tpl.name=`%s` var=`%s` id=%d  tyid=`%s` size=%d offset=%d loc=`%s` ", tpl, name, id, tyid, size, offset, loc );
	}
	
	void setEachType(char[] _each_types){
		if( _each_types is null || _each_types.length is 0 ) {
			return ;
		}
		auto each_types	= cast(char[][]) std.array.split(_each_types, ":" ) ;
		foreach( _key_val ; each_types ) {
			if( _key_val is null || _key_val.length is 0 ) {
				continue ;
			}
			int i	= ctfe_indexof( _key_val, ',');
			if( i > 0 && i < _key_val.length ) {
				auto p = new Each_Key_Value( _key_val[0..i].idup, _key_val[i+1..$].idup ) ;
				_Each_Types	~= p ;
				// tpl_print("\n`%s` , => `%s`=>`%s`\n", name, p.key, p.value );
			}
		}
	}
	
}