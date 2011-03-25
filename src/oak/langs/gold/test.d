import oak.langs.gold.css ;


void main(){
	Lang_css css ;
	
	css.Init("p#id.test{font-size:12px}");
	
	ParsingRet ret ;
	for( ret = css.Parse; ret is ParsingRet.TokenRead; ret = css.Parse ) {
		
	}
	Log("%s", ret);
}

