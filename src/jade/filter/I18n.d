
module oak.jade.filter.I18n ;

import oak.jade.Jade ;



alias oak.jade.node.Filter.Filter Filter ;

void Jade_I18n_Filter(Compiler* cc, Filter  node) {
	string _i18n_path = null ;
	for( auto arg =  node.args.firstChild; arg !is null ; arg = arg.next ) {
		if( arg.firstChild  !is null ) {
			auto val	= cast(PureString) arg.firstChild  ;
			if( val !is null ) {
				_i18n_path	= val.value ;
				break;
			}
		}
	}
	if(  _i18n_path is null ) {
		cc.err("i18n filter missing path", node.ln);
	}
	string[] _tags ;
	if( node.tag !is null ) {
		Jade_I18n_Tag_Open(cc, node.tag, (string tag){
			_tags	~= tag ;
		});
	}
	scope(exit){
		cc.FinishLastOut() ;
		for( int i =_tags.length; i--;){
			cc.asString("</").asString( _tags[i]).asString(">") ;
		}
	}
	cc.FinishLastOut() ;
	
	FilterTagArg[] _tag_tags ;
	if( node.tag_args !is null ) for(auto n = node.tag_args.firstChild; n !is null; n = n.next ) {
		assert( n.ty is Node.Type.FilterTagArg );
		auto _n = cast(FilterTagArg) n ;
		assert(_n.key !is null); 
		_tag_tags	~= _n ;
	}
	
	ptrdiff_t _i18n_render_pos = cc._str_bu.length ;
	cc._str_bu("_i18n_render_pos_");
	foreach( c; cc.filename) {
		if( c >='0' && c <= '9' || c >='A' && c <= 'Z' || c >='a' && c <='z' ) {
			cc._str_bu(c);
		} else {
			cc._str_bu( cast(byte) c);
		}
	}
	cc._str_bu("_id")(cc.i18n_id++);
	string _i18n_render	= cc._str_bu.toString[ _i18n_render_pos .. $] ;

	cc.asLine(node.ln);
	cc._ret_bu("static I18n_Render!(`")(cc.filename)("`,")(node.ln)(",");
	foreach(n; _tag_tags ) {
		cc.asCode("`").asCode(n.key).asCode("`,") ;
	}
	cc._ret_bu.move(-1);
	
	cc._ret_bu(") ")(_i18n_render)(" ;\n") ;
	
	cc.asLine(node.ln);
	cc._ret_bu(_i18n_render)(".check(i18n, `")(_i18n_path)("`);\n") ;
	
	cc._ret_bu("foreach(")(_i18n_render)("_tk; ")(_i18n_render)(") {\n") ;

	cc._ret_bu("\tswitch(")(_i18n_render)("_tk.ty) {\n") ;
		cc._ret_bu("\t\tcase I18n.Render_Type.String:\n") ;
		cc._ret_bu("\t\t\tob.escape(")(_i18n_render)("_tk.string_value);\n") ;
		cc._ret_bu("\t\t\tbreak;\n\n") ;
	
		cc._ret_bu("\t\tcase I18n.Render_Type.TagOpen:\n") ;
		cc._ret_bu("\t\t\tswitch(")(_i18n_render)("_tk.tag_id){\n") ;
		foreach(ptrdiff_t i, n; _tag_tags ) {
			cc._ret_bu("\t\t\t\tcase ");
			cc._ret_bu(i);
			cc.asCode(":\n") ;
			if( n.tag !is null ) {
				Jade_I18n_Tag_Open(cc, n.tag) ;
			}
			if( n.value !is null ) {
				n.value.eachD(cc) ;
			}
			cc.asCode("\t\t\t\tbreak;\n") ;
		}
		cc._ret_bu("\t\t\t\tdefault:\n");
		cc.asLine(node.ln);
		cc._ret_bu("\t\t\t\t throw new I18n_Render_Exception(")(_i18n_render)("_tk, `");
		cc._ret_bu( cc.filename)("`, ")( node.ln ) ;
		cc._ret_bu(");\n");
		
		cc._ret_bu("\t\t\t}\n") ;
		cc._ret_bu("\t\t\tbreak;\n") ;
	
	
		cc._ret_bu("\t\tcase I18n.Render_Type.TagClose:\n") ;
		cc._ret_bu("\t\t\tswitch(tk.tag_id){\n") ;
		foreach(ptrdiff_t i, n; _tag_tags ) {
			cc._ret_bu("\t\t\t\tcase ");
			cc._ret_bu(i);
			cc.asCode(":\n") ;
			if( n.tag !is null ) {
				if( n.tag.tag[0] is '*' ) {
					cc.asString("</div>");
				} else {
					cc.asString("</").asString(n.tag.tag).asString(">");
				}
			}
			cc.asCode("\t\t\t\tbreak;\n") ;
		}
		cc._ret_bu("\t\t\t\tdefault:\n");
		cc.asLine(node.ln);
		cc._ret_bu("\t\t\t\t throw new I18n_Render_Exception(")(_i18n_render)("_tk, `");
		cc._ret_bu( cc.filename)("`, ")( node.ln ) ;
		cc._ret_bu(");\n");
		cc._ret_bu("\t\t\t}\n") ;
		
	cc._ret_bu("\t\tdefault:") ;
	
	cc._ret_bu("\t\t\tbreak;\n") ;
	cc.asLine(node.ln);
	cc._ret_bu("\t\t throw new I18n_Render_Exception(")(_i18n_render)("_tk, `");
	cc._ret_bu( cc.filename)("`, ")( node.ln ) ;
	cc._ret_bu(");\n");
	
	cc.asCode("\t}\n") ;
	cc.asCode("}\n") ;
}

private void Jade_I18n_Tag_Open(Compiler* cc,Tag tag , void delegate(string) dg = null ) {
	cc.asString("<") ;
	auto _tag = tag. tag[0] is '*'  ? "div" : tag. tag ;
	cc.asString(_tag) ;
	tag.asAttrs(cc) ;
	cc.asString(">") ;
	if( dg !is null ) {
		dg(_tag);
	}
	
	for( auto n = tag.firstChild; n !is null ; n = n.next ) {
		if( n.ty is Node.Type.Tag ) {
			auto sub_tag = cast(Tag) n ;
			assert( sub_tag !is null);
			Jade_I18n_Tag_Open(cc, sub_tag, dg) ; 
			break ;	
		}
	}
}
