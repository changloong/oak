
module oak.fcgi.Request ;

import oak.fcgi.all ;

final class FCGI_Request {
	
	public  vBuffer stdin ;
	private {
		vBuffer	_tmp_bu ;
	}
	package Pool*	pool ;
	
	string[string] headers ;
	
	this(Pool* pool){
		stdin	= new vBuffer(1024 * 16, 1024 * 256) ;
		_tmp_bu	= new vBuffer(1024 * 16, 1024 * 256) ;
		this.pool	= pool;
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
		char** param = fcgi_req.envp ;
		while (*param !is null)
		{
			ptrdiff_t eq = 0;
			while ((*param)[eq] != '\0' && (*param)[eq] != '=') {
				eq++;
			}

			ptrdiff_t end = eq;
			while ((*param)[end] != '\0') {
				end++;
			}
			
			auto _key	= cast(string) pool.Copy( (*param)[0..eq] ) ;
			auto _value	=  cast(string) pool.Copy( (*param)[eq+1..end] ) ;
			
			headers[_key]	= _value ;
			
			param++;
		}
		
		headers.rehash ;
		
	}
	
	
	package final void Finish(FCGX_Request* fcgi_req) {
		headers	= null ;	
		stdin.clear ;
		_tmp_bu.clear ;
	}
	
}