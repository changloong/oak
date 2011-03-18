
module oak.fcgi.Dispatch ;

import oak.fcgi.all ;

struct FCGI_Dispatch {
	
	alias void delegate(FCGI_Request, FCGI_Response) FCGI_Service ;
	
	private {
		fcgi_fd		_fd ;
		Thread[]	_threads ;
		FCGI_Service	_default_service ;
	}
	
	void Listen(string socket_s = null, fcgi_int flag = 10 ){
		FCGX_Init() ;
		if( socket_s !is null ) {
			_fd	= FCGX_OpenSocket(toStringz(socket_s), flag);
		} else {
			_fd	= FCGX_OpenSocket(null, flag);
			assert( !FCGX_IsCGI() );
		}
		assert( _fd > 0 ) ;
	}
	
	private void default_service(FCGI_Request req, FCGI_Response res){
		res.stderr("no service") ;
	}
	
	void setDefaultService(FCGI_Service dg ) {
		_default_service	= dg ;
	}
	
	void Loop(ubyte initialThreads = 2) {
		if( _fd <= 0 ) {
			Listen() ;
		}
		if( initialThreads <= 0 || initialThreads >= byte.max ) {
			initialThreads	= 8 ;
		}
		if( _default_service is null ) {
			_default_service	= &default_service ;
		}
		_threads	= new Thread[ initialThreads ] ;
		foreach(ptrdiff_t i, ref th ; _threads ) {
			th = new Thread(&_Thread_Enter) ;
			th.name( to!string(i) );
			th.start ;
		}
		foreach(ref th; _threads ) {
			th.join ;
		}
	}
	
	private void _Thread_Enter() {
		auto _th_id	= to!ptrdiff_t( Thread.getThis.name ) ;
		assert( Thread.getThis is _threads[ _th_id ] ) ;
		Log("id = %d, fd = %d", _th_id, _fd );
		auto fcgi_req  = cast(FCGX_Request*) GC.malloc(FCGX_Request.sizeof, GC.BlkAttr.NO_SCAN  | GC.BlkAttr.NO_MOVE) ;
		
                auto ret = fcgi_req.Init(_fd) ;
		assert(ret is 0);
		
		auto req	= new FCGI_Request() ;
		auto res	= new FCGI_Response() ;
		
		auto _service	= _default_service ;
		
		while( true ) {
			ret	= fcgi_req.accept() ;
			if( !ret ) {
				Log("th:%d exit", _th_id ) ;
				break ;
			}
			
			req.Init(fcgi_req) ;
			res.Init(fcgi_req) ;
			
			// dispatch 
			try{
				_service( req, res);
			} catch(Exception e) {
				res.stderr( e.toString ) ;
			}
			
			req.Finish(fcgi_req) ;
			res.Finish(fcgi_req) ;
			
		}
	}
}