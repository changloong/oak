
module oak.fcgi.Dispatch ;

import oak.fcgi.all ;

package struct FCGI_VHost_Factory {
	string	tyid , ty ;
	string 	_file ;
	ptrdiff_t _line ;
	string  name ;
	FCGI_VHost function()	
		ctor ;
	
	string toString(){
		return ty ~ "(" ~ _file ~ ":" ~ to!string(_line) ~  ")" ; 
	}
}

package struct FCGI_App_Factory {
	string	tyid , ty ;
	string 	_file ;
	ptrdiff_t _line ;
	string  host ;
	FCGI_Application function(FCGI_VHost host)	
		ctor ;
	
	string toString(){
		return ty ~ "(" ~ _file ~ ":" ~ to!string(_line) ~  ")" ; 
	}
}

private struct Null_Handle {
	void function(FCGI_Request, FCGI_Response)	fn ;
	void delegate(FCGI_Request, FCGI_Response)	dg ;
}

private class Null_Host : FCGI_VHost {
	Null_Handle cb ;
	this( Null_Handle _cb) {
		cb	= _cb ;
	}
	
	override void service(FCGI_Request req, FCGI_Response res) {
		if( cb.fn !is null ) {
			cb.fn(req,res ) ;
		} else if( cb.dg !is null ) {
			cb.dg(req, res);
		}
	}
}

private class Default_Host : FCGI_VHost {
	this (string _name) {
		this._host	= _name ;
	}
}

struct FCGI_Dispatch {
	
	private {
		fcgi_fd		_fd ;
		Thread[]	_threads ;
		FCGI_VHost_Factory*[]
				_vhost_handles ;
		FCGI_App_Factory*[]
				_app_handles ;
		bool		_isRunning ;
		Null_Handle	_null_handle ;
		
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
	
	void Dispatch(T, string name = null, string _file = __FILE__, ptrdiff_t _line = __LINE__ )() if( is(T==class) && !__traits (isAbstractClass,T) ) {
		
		if( _isRunning ) {
			return ;
		}
		
		alias BaseClassesTuple!(T) BaseClasses ;
		
		static if( ctfe_contains!(FCGI_VHost, BaseClasses) ) {
		
			static const _tyid = typeid(T).stringof ;
			foreach( int i, ref c; _vhost_handles) {
				if( c.tyid == _tyid ) {
					assert(false) ;
					return ;
				}
			}
			
			auto h	= new FCGI_VHost_Factory ;
			
			static FCGI_VHost NewT(FCGI_VHost_Factory* h) {
				FCGI_VHost obj	= new T() ;
				obj._factory	= h ;
				return obj ;
			}
			
			h.tyid	= _tyid ;
			h.ctor	= &NewT ;
			h._file = _file ;
			h._line = _line ;
			h.ty	= T.stringof ;
			h.name	= name ;
			_vhost_handles	~= h ;
			
		} else static if( ctfe_contains!(FCGI_Application, BaseClasses) ) {
			static const _tyid = typeid(T).stringof ;
			foreach( int i, ref c; _app_handles) {
				if( c.tyid == _tyid ) {
					assert(false) ;
					return ;
				}
			}
			
			auto h	= new FCGI_App_Factory ;
			
			static FCGI_Application NewT(FCGI_VHost host) {
				FCGI_Application obj = new T() ;
				obj.Init(host);
				return obj ;
			}
			
			h.tyid	= _tyid ;
			h.ctor	= &NewT ;
			h._file = _file ;
			h._line = _line ;
			h.ty	= T.stringof ;
			h.host	= name ;
			_app_handles	~= h ;
			
		} else {
			static assert(false);
		}
	}
	
	void Dispatch(T)(T cb) if( is(T==delegate) || is(T==function) ) {
		static if( is(T==delegate) ) {
			_dg_service	= cb ;
		} else {
			_fn_service	= cb ;
		}
	}
	
	void Loop(ubyte initialThreads = 2) {
		if( _fd <= 0 ) {
			Listen() ;
		}
		if( initialThreads <= 0 || initialThreads >= byte.max ) {
			initialThreads	= 8 ;
		}
		_isRunning	= true ;
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
		
		auto pool	= cast(Pool*) GC.malloc(Pool.sizeof, GC.BlkAttr.NO_SCAN  | GC.BlkAttr.NO_MOVE) ;
		
		pool.Init( 1024 * 512 ) ;
		
		auto req	= new FCGI_Request(pool) ;
		auto res	= new FCGI_Response(pool) ;
		
		FCGI_VHost[] vhosts	= new FCGI_VHost[ _vhost_handles.length ] ;
		
		FCGI_VHost null_vhost	= null ;
		
		FCGI_VHost[string] vhosts_map ;
		
		void addVHost(FCGI_VHost vhost, string name) {
			if( name is null ) {
				if( null_vhost is null ) {
					null_vhost	= vhost ;
					return  ;
				} else {
					throw new Exception( vhost.toString ~ " == " ~ null_vhost.toString );
				}
			}
			auto p =  name in vhosts_map ;
			if( p !is null ) {
				throw new Exception( vhost.toString ~ " == " ~ p.toString );
			}
			vhosts_map[  name ] = vhost ;
		}
		
		foreach( int i , ref vhost; vhosts ) {
			vhost	= _vhost_handles[i].ctor() ;
			addVHost( vhost, vhost.name ) ;
			auto _alias_names = vhost.getAliaNames() ;
			if( _alias_names !is null) foreach(_name; _alias_names) {
				if( _name !is null ) {
					addVHost(vhost, _name);
				}
			}
		}
		
		if( null_vhost is null ) {
			null_vhost = new Null_Host( _null_handle ) ;
		}
		
		foreach( app; _app_handles ) {
			FCGI_VHost vhost ;
			if( app.host is null ) {
				vhost	= null_vhost ;
			} else {
				auto phost = app.host in vhosts_map ;
				if( phost is null ) {
					vhost	= *phost ;
				} else {
					vhost	= new Default_Host( app.host ) ;
					vhosts_map[ app.host ] = vhost ;
				}
			}
			auto _app = app.ctor( vhost ) ;
		}
		
		vhosts_map.rehash ;
		
		while( true ) {
			ret	= fcgi_req.accept() ;
			if( !ret ) {
				Log("th:%d exit", _th_id ) ;
				break ;
			}
			pool.Clear ;
			req.Init(fcgi_req) ;
			res.Init(fcgi_req) ;
			
			// dispatch 
			try {
				auto pvhost  = req.header.SERVER_NAME in vhosts_map ;
				if( pvhost !is null ) {
					(*pvhost).service(req, res) ;
				} else {
					null_vhost.service(req, res) ;
				}
 			} catch(Exception e) {
				res.stderr( e.toString ) ;
			}
			
			req.Finish(fcgi_req) ;
			res.Finish(fcgi_req) ;
			
		}
	}
}