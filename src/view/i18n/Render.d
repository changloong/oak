module oak.view.i18n.Render ;

import oak.all ;

enum I18n_Render_Type {
	String ,
	TagOpen ,
	TagClose ,
}

struct I18n_Render_Tok {
	I18n_Render_Type
			ty ;
	ptrdiff_t	tag_id ;
	string		string_value ;
}

struct I18n_Render(string _file, ptrdiff_t _line, T...) {
	
	
	void check(I18n_Translate tr, string path) {
		
	}
	
	final ptrdiff_t opApply(scope ptrdiff_t delegate(ref I18n_Render_Tok tk) dg) {
		
		return 0 ;
	}
}