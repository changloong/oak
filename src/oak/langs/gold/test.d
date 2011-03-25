import oak.langs.gold.css ;


void main(){
	Lang_css css ;
	
	css.Init("1111*2222 + ( 1- 3 *3 ) / (3-0*7+7788) ");
	
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

