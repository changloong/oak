
module oak.fcgi.Request ;

import oak.fcgi.all ;

final class FCGI_Request {
	
	public  vBuffer stdin ;
	private {
		vBuffer stdtmp ;
	}
	
	string[string] header ;
	
	
	
	this(){
		stdin	= new vBuffer(1024 * 16, 1024 * 256) ;
		stdtmp	= new vBuffer(1024 * 16, 1024 * 256) ;
	}
	
	
	package final void Init(FCGX_Request* fcgi_req) {
		stdin.clear ;
		stdtmp.clear ;
		
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
		
		void addParam(char[] key, char[] value){
			auto pos = stdtmp.length ;
			stdtmp(key);
			auto _key	= cast(string) stdtmp.slice[ pos .. $] ;
			stdtmp('\0') ;
			
			pos = stdtmp.length ;
			stdtmp(value);
			auto _value	= cast(string) stdtmp.slice[ pos .. $] ;
			stdtmp('\0') ;
			
			header[_key]	= _value ;
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
			
			char[] key = (*param)[0..eq] ;
			char[] value = (*param)[eq+1..end] ;
			addParam(key, value);
			
			param++;
		}
		header.rehash ;
		
	}
	
	
	package final void Finish(FCGX_Request* fcgi_req) {
		
	}
	
}