import oak.langs.gold.scss ;


void main(){
	Lang_scss scss ;
	
	auto data = cast(string) std.file.read(`../scss/example.scss`);
	scss.Init( data);
	
	size_t coutn_i ;

	static const names = ctfe_enum_array!(ParsingRet);
	
	ParsingRet ret ;
	bool isDone = false ;
	while( !isDone ) {
		ret = scss.Parse ;
		
		switch( ret ) {
			case ParsingRet.TokenRead:
				break;
			case ParsingRet.Reduction:
				break;
			
			default:
				Log("%s", names[ret] );
				isDone = true ;
		}
		assert( coutn_i++ < short.max >> 5 );
	}
	
	
}

