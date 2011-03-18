
module oak.fcgi.Request ;

import oak.fcgi.all ;

final class FCGI_Request {
	
	public  vBuffer stdin ;
	private {
		vBuffer	_tmp_bu ;
	}
	package Pool*	pool ;
	
	Req_Header 	header ;
	
	package this(Pool* pool){
		stdin	= new vBuffer(1024 * 16, 1024 * 256) ;
		_tmp_bu	= new vBuffer(1024 * 16, 1024 * 256) ;
		this.pool	= pool;
		header.Boostrap ;
	}
	
	package final void Init(FCGX_Request* fcgi_req) {

		// read stdin
		enum _step = 1024 * 4 ;
		while( !fcgi_req.inStream.eof ) {
			ptrdiff_t _pos	= stdin.length ;
			stdin.move(_step);
			auto  _buf =  cast(char[]) stdin.slice[_pos..$] ;
			auto _len = FCGX_GetStr(_buf.ptr, _buf.length, fcgi_req.inStream );
			if( _len <= 0 || _len > _step ) {
				assert(  fcgi_req.inStream.eof ) ;
				break ;
			}
			if( _len < _step ) {
				stdin.move( _len - _step ) ;
			}
		}
		
		// copy params

		header.Init(fcgi_req.envp, pool) ;
	}
	
	
	package final void Finish(FCGX_Request* fcgi_req) {
		header.Reset ;	
		stdin.clear ;
		_tmp_bu.clear ;
	}
	
}