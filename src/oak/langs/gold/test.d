import oak.langs.gold.css ;


void main(){
	Lang_css css ;
	
	css.Init("tag1#id1.class1{font-size:12px;}");
	
	size_t coutn_i ;

	static const names = ctfe_enum_array!(ParsingRet);
	
	ParsingRet ret ;
	bool isDone = false ;
	while( !isDone ) {
		ret = css.Parse ;
		
		switch( ret ) {
			case ParsingRet.TokenRead:
				break;
			case ParsingRet.Reduction:
				break;
			
			default:
				Log("%s", names[ret] );
				isDone = true ;
		}
		assert( coutn_i++ < short.max >> 6 );
	}
	
	
}

