import oak.langs.gold.css ;


void main(){
	Lang_css css ;
	
	css.Init("p#id.test{font-size:12px}");
	
	auto tk = css.RetrieveToken ;
	
	Log("`%s`", tk.symbol );
}

