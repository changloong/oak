module oka.test ;

import oak.all  ;

class User {
	bool 	login = false;
	bool 	admin ;
	int	id  = 3001 ;
	string 	name = "<Chang Long>" ;
}


class MyApp : FCGI_Application {
	alias Tpl!("UserList", __FILE__, __LINE__) MyTpl ;
	
	MyTpl	tpl ;
	User	u ;
	string	page_title	= "test page"[] ;
	vBuffer bu ;
	
	
	public this(size_t id) {
		super(id) ;
		
		tpl	= new MyTpl ;
		u	= new User ;
		
		static assert(isPointer!( typeof(&u) ));
		
		tpl.assign!("user", __FILE__, __LINE__)(u);
		
		tpl.assign!("page_title", __FILE__, __LINE__)( page_title );
		
		// tpl.assign!("env", __FILE__, __LINE__)(environment.toAA);
		
		bu		= new vBuffer(1024 * 32, 1024 * 512 ) ;
		
	}
	
	int run(FCGI_Request req) {
	
		assert( bu !is null);
		
		assert( req !is null);
		auto stdout = req.stdout ;
		assert( stdout !is null);
		
		StopWatch sw;
		sw.start;
		
		u.login	= !u.login ;
		u.id ++ ;
		if( u.id % 3 is 0 ) {
			u.admin	= !u.admin ;
		}
		
		tpl.assign!"req"( req );
		
		mixin Tpl_Jade!("./example.jade", typeof(tpl) , __FILE__, __LINE__) jade ;
		
		auto obj	= jade.compile(tpl);

		for( int i =0; i < 1 ; i++) {
			bu.clear;
			assert(bu.length is 0);
			obj.render(bu);
			assert( bu.capability < 1024 * 1024 * 12 );
		}
		
		sw.stop;
		
		stdout ("Content-type: text/html\r\n");
		stdout ("RenderTime: ")(sw.peek.msecs)("ms\r\n");
		stdout ("Content-Length: ")( bu.length)("\r\n");
		stdout("\r\n");
		stdout(bu.slice);
		
		bu.clear;
		
		return 0 ;
	}
}


void main() {
	auto conn	= new shared(FCGI_Connection)(null, "1983" );
	FCGI_Application.loop!MyApp(conn, true, 1) ;
}