
module oak.langs.jade.node.Filter ;

import oak.langs.jade.Jade ;

import 
	oak.langs.jade.filter.Js,
	oak.langs.jade.filter.Code,
	oak.langs.jade.filter.Css,
	oak.langs.jade.filter.Text,
	oak.langs.jade.filter.Include,
	oak.langs.jade.filter.Block,
	oak.langs.jade.filter.Extend,
	oak.langs.jade.filter.I18n;

final class Filter : Node {
	bool		hasVar ;
	
	FilterArgs	args ;
	Tag		tag ;
	FilterTagArgs	tag_args ;
	Filter_Render*	render_obj ;
	string		filter_name ;
	Filter		parent_filter ;
	
	this(Tok tk) {
		hasVar		= tk.bool_value ;
		render_obj	= tk.render_obj ;
	}
	
	void asD(Compiler* cc) {
		render_obj.fn(cc, this) ;
	}
	
	static Filter_Render* getRender(string name){
		foreach( ref p; Filter_Render.Maps ) {
			if( p.name == name ) {
				return &p ;
			}
		}
		return null ;
	}
	
	string get_arg( size_t offset = 0 ){
		if( args is null || args.length is 0 ) {
			return null ;
		}
		for( auto n = args.firstChild; n !is null; n = n.next ){
			if( offset <= 0 ) {
				auto _n = cast(PureString) n ;
				return _n.value ;
			}
			offset--;
		}
		return null ;
	}
}



struct Filter_Render {
	private enum {
		None	= 0 ,
		Args_Mixed = 1 ,
		Wrapper = 1 << 2 ,
		Wrapper_Tag = 1 << 3 ,
		Wrapper_Children = 1 << 4 ,
		Tag_Args = 1 << 5 ,
		Text_Children = 1 << 6 ,
		HTML_Children = 1 << 7 ,
	}
	enum Type {
		Code ,
		Js ,
		Css ,
		Text ,
		I18n ,
		Include ,
		Block ,
		Block_Parent,
		Extend ,
	}
	static const string[] Type_Name = ctfe_enum_array!(Type) ;
	
	const string	name ;
	const Type	ty ;
	const size_t	args_min, args_max ;
	const void function(Compiler* cc, Filter) fn ;
	private const size_t _attr ;
	
	bool opDispatch(string name)() if( name.length > 2 && name[0..2] == "is" ) {
		static const _ty = ctfe_indexof!(string)(cast( string[] ) Type_Name, name[2..$]);
		static assert(_ty >=0 ,  typeof(this).stringof ~ "." ~ name ~ " is not exists");
		return _ty is ty ;
	}
	
	static __gshared Filter_Render[] Maps = [
		{"code", Type.Code, 0 , 0, 
			&Jade_Code_Filter,
			Text_Children ,
			} ,
		
		{"js", Type.Js, 0, 1, 
			&Jade_Js_Filter,
			Args_Mixed | Wrapper | Text_Children,
			} ,
		{"css", Type.Css, 0, 1, 
			&Jade_Css_Filter, 
			Args_Mixed | Wrapper | Text_Children ,
			} ,
		
		{"text", Type.Text, 0, 0 ,
			&Jade_Text_Filter,
			Wrapper | Text_Children,
			} ,
		
		{"i18n", Type.I18n, 1, 1, 
			&Jade_I18n_Filter  ,
			Wrapper | Wrapper_Tag | Wrapper_Children | Tag_Args ,
			} ,
		{"i18n_chroot", Type.I18n, 1, 1,
			&Jade_I18n_ChRoot_Filter ,
			None ,
			} ,
		
		{"include", Type.Include, 1, 1, 
			&Jade_Include_Filter ,
			None ,
			} ,
		{"block", Type.Block, 1, 2,
			&Jade_Block_Filter  ,
			HTML_Children ,
			} ,
		{"block_parent", Type.Block_Parent, 0, 0,
			&Jade_Block_Parent_Filter  ,
			None ,
			} ,
		{"extend", Type.Extend , 1, 1,
			&Jade_Extend_Filter  ,
			None ,
			} ,
	] ;
	
	bool with_args() {
		return args_max > 0  ;
	}
	
	bool with_args_mixed() {
		return (_attr & Args_Mixed) !is 0 ;
	}
	
	bool with_wrapper(){
		return (_attr & Wrapper) !is 0 ;
	}

	bool with_wrapper_tag(){
		return (_attr & Wrapper_Tag) !is 0 ;
	}

	bool with_wrapper_children(){
		return (_attr & Wrapper_Children) !is 0 ;
	}
	
	bool with_tag_args(){
		return (_attr & Tag_Args) !is 0 ;
	}
	
	bool with_text_children(){
		return (_attr & Text_Children) !is 0 ;
	}

	bool with_html_children(){
		return (_attr & HTML_Children) !is 0 ;
	}

}
