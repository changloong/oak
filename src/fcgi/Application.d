
module fcgi4d.Application;

import fcgi4d.all, core.thread ;


class FCGI_Application  {
	package static shared FCGI_Connection _app_conn ;

	private {
		static shared bool 	_withExceptions ;
		static Thread[]	_app_threads ;
		size_t	_id ;
	}
	
	public this(size_t id) {
		_id	= id ;
	}
	
	int run(FCGI_Request req) {
		
		return 0 ;
	}
	
	private void _run(T)(T cb) {
		log("%d", _id) ;
		FCGI_Request req	= new FCGI_Request(_withExceptions, _id) ;
		fd_type	fd	= -1 ;
		while( true ) {
			try {
				if( fd < 0 ) {
					fd	= _app_conn.accept ;
				}
				assert( fd > 0 );
				if( !req.accept(fd) ) {
					break ;
				}
				req.exitStatus = cb(req);
				req.finish ();

			} catch (FCGI_ProtocolException e) {
				// Fatal errors are forwarded
				throw e;
			}  catch (FCGI_AbortException e) {
				// AbortRequest errors only inform the handler-loop
			} catch (Exception e) {
				// All user-exceptions are printed to stderr
				if (req.isFinished ()) {
				    throw e;
				}else {
				    req.exitStatus = 1;
				    req.stderr(e.msg);
				    req.finish ();
				}
			}
			if( req.isClosed ) {
				fd	= - 1;
			}
		}
	}
	
	private static void _Run_Enter(alias T)() {
		static if( is(T==class) ) {
			static assert(  BaseClassesTuple!(T).length > 0 && is( BaseClassesTuple!(T)[0] == FCGI_Application) );
				
			Thread _td		= Thread.getThis ;
			size_t  thread_id	= to!int( _td.name ) ;
			auto app	= new T(thread_id);
			app._run(&app.run);
			
		} else {
			Thread _td		= Thread.getThis ;
			size_t  thread_id	= to!int( _td.name ) ;
			FCGI_Application app	= new FCGI_Application(thread_id);
			app._run(&T);
		}
	}
	
	public static int loop(alias T)(shared(FCGI_Connection) conn, bool withExceptions = true, ubyte initialThreads = 1) {
		if( conn is null ) {
			_app_conn	= new shared(FCGI_Connection) ;
		} else {
			_app_conn	= conn ;
		}
		assert(!_app_conn.isCGI);
		_withExceptions	= withExceptions ;

		alias _Run_Enter!(T) _RunFn ;
		synchronized (_app_conn) {
			_app_threads	= new Thread[ initialThreads] ;
			foreach(int i , ref _td; _app_threads ) {
				_td	= new Thread(&_RunFn) ;
				_td.name( to!string(i) );
				_td.start ;
			}
			foreach(ref _td; _app_threads ) {
				_td.join ;
			}
		}
	
		return 0 ;
	}
}