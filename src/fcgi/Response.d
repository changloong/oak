
module oak.fcgi.Response ;

import oak.fcgi.all ;

final class FCGI_Response {
	
	vBuffer	stdout, stderr ;
	package Pool*	pool ;
	
	private {
		ptrdiff_t 	_exitStatus = 0 ;
	}
	
	this(Pool* pool){
		stdout	= new vBuffer(1024 * 16 , 1024 * 256) ;
		stderr	= new vBuffer(1024 * 8 , 1024 * 64) ;
		this.pool	= pool ;
	}

	package final void Init(FCGX_Request* fcgi_req){
		
	}
	
	package final void Finish(FCGX_Request* fcgi_req) {
		fcgi_req.appStatus	= _exitStatus ;
		auto _len = stdout.length ;
		if( _len ) {
			auto ret = FCGX_PutStr(cast(const char*) stdout.slice.ptr, _len, fcgi_req.outStream );
		}
		_len = stderr.length ;
		if( _len ) {
			auto  ret = FCGX_PutStr(cast(const char*) stdout.slice.ptr, _len, fcgi_req.errStream );
		}
		_exitStatus = 0 ;
		stdout.clear ;
		stderr.clear ;
	}
	
	@property  void exitStatus(ptrdiff_t i) {
		_exitStatus	= i ;
	}
	
	@property ptrdiff_t exitStatus() {
		return _exitStatus ;
	}
}