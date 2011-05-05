
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
	
	this(Tok* tk) {
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
}



struct Filter_Render {
	private enum {
		Args = 1 ,
		Args_Mixed = 2 ,
		Wrapper = 1 << 3 ,
		Wrapper_Tag = 1 << 4 ,
		Wrapper_Children = 1 << 5 ,
		Tag_Args = 1 << 6 ,
		Text_Children = 1 << 7 ,
		HTML_Children = 1 << 8 ,
		Extend_Filter  = 1 << 9 ,
		Block_Filter  = 1 << 10 ,
	}
	const string name ;
	const void function(Compiler* cc, Filter) fn ;
	private const size_t _attr ;
	
	
	static __gshared Filter_Render[] Maps = [
		{"code", &Jade_Code_Filter, Text_Children } ,
		
		{"js", &Jade_Js_Filter,	Args | Args_Mixed | Wrapper | Text_Children } ,
		{"css", &Jade_Css_Filter, Args | Args_Mixed | Wrapper | Text_Children } ,
		
		{"text", &Jade_Text_Filter, Wrapper | Text_Children } ,
		
		{"i18n",  &Jade_I18n_Filter  , Args | Wrapper | Wrapper_Tag | Wrapper_Children | Tag_Args } ,
		{"i18n_chroot",  &Jade_I18n_ChRoot_Filter , Args } ,
		
		{"include", &Jade_Include_Filter , Args } ,
		{"block",  &Jade_Block_Filter  , Args | HTML_Children | Block_Filter } ,
		{"extend", &Jade_Extend_Filter  , Args | Extend_Filter } ,
	] ;
	
	bool with_args() {
		return (_attr & Args) !is 0 ;
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
	
	bool is_extend(){
		return (_attr & Extend_Filter) !is 0 ;
	}
	
	bool is_block(){
		return (_attr & Block_Filter) !is 0 ;
	}

}
