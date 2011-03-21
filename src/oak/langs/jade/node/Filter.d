
module oak.langs.jade.node.Filter ;

import oak.langs.jade.Jade ;

import 
	oak.langs.jade.filter.Js,
	oak.langs.jade.filter.Code,
	oak.langs.jade.filter.Css,
	oak.langs.jade.filter.Text,
	oak.langs.jade.filter.Include,
	oak.langs.jade.filter.I18n;

final class Filter : Node {
	string		type ;
	bool		hasVar ;
	
	FilterArgs	args ;
	Tag		tag ;
	FilterTagArgs	tag_args ;
	
	this(Tok* tk) {
		type	= tk.string_value ;
		hasVar	= tk.bool_value ;
	}
	
	void asD(Compiler* cc) {
		Render_Map* map = null ;
		foreach( ref p; Render_Maps) {
			if( p.name == type ) {
				map = &p ;
			}
		}
		if( map is null ) {
			cc.err("filter `%s` is not defined at line:%d ", type, ln);
		}
		
		// Log("type = %s,", map.name ) ;
		map.fn(cc, this) ;
	}
}

struct Render_Map {
	const string name ;
	const void function(Compiler* cc, Filter) fn ;
}

static __gshared Render_Map[] Render_Maps = [
		{"js",  &Jade_Js_Filter } ,
		{"code", &Jade_Code_Filter } ,
		{"css",  &Jade_Css_Filter } ,
		{"text",  &Jade_Text_Filter } ,
		{"include",  &Jade_Include_Filter } ,
		{"i18n",  &Jade_I18n_Filter } ,
		{"i18n_chroot",  &Jade_I18n_ChRoot_Filter } ,
	] ;
