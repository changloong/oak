module oak.fcgi.Stream ;

import oak.fcgi.all ;

version = USE_READ_CACHE ;

final class FCGI_Stream : Stream {
	private size_t		_buffer_size	= 1024 * 4 ;
	private fd_type		_fd ;
	private size_t		_pos ;
	private FCGI_Buffer	_bu ;
	
	final this() {
    		super();
		_bu	= new FCGI_Buffer(1024 * 32, 1024 * 256);
		_pos	= 0 ;
	}
	
	final void init(fd_type fd) {
		_fd	= fd ;
		_bu.clear ;
		_pos	= 0 ;
	}
	
	final void finish(){
		_bu.clear ;
		_pos	= 0 ;
	}
	
	final override void close(){
		if( _fd > 0 ) {
			OS_IpcClose (_fd);
			_fd	= -1 ;
		}
	}
	
	final bool isClosed(){
		return _fd < 0 ;
	}
	
	version(USE_READ_CACHE) final private bool read_fcgi(size_t size) {
		ptrdiff_t cached_len	= _bu.length - _pos ;
		if(  size <= cached_len ) {
			return true ;
		}
		ptrdiff_t step	= size < _buffer_size ? _buffer_size : size + _buffer_size ;
		assert( step > size );
		_bu.move( step ) ;
		ubyte[] step_data = cast(ubyte[]) _bu.slice[ $-step .. $] ;
		assert( step_data.length is step);
		
		ptrdiff_t ret = OS_Read (_fd, step_data.ptr , step_data.length) ;
		assert( ret >= 0 && ret <=  step_data.length );
		if( ret <  step_data.length ) {
			_bu.move( ret - step ) ;
		}
		cached_len	= _bu.length - _pos ;
		if( cached_len < size ) {
			// eof 
			assert(false);
			return false ;
		}
		return true ;
	}
	
	final override size_t readBlock(void* buffer, size_t size) {
		if (_fd < 0)
			return 0 ;
		version(USE_READ_CACHE) {
			ptrdiff_t _bu_len = _bu.length ;
			ptrdiff_t _bu_pos = _pos ;
			ptrdiff_t _new_pos = _pos + size;
			assert( size > 0 ) ;
			scope(exit){
				assert( _pos is _new_pos) ;
				assert( _bu_len <= _bu.length ) ;
			}
			if( !read_fcgi( size ) ) {
				return 0 ;
			}
			memcpy( buffer, &_bu.slice[_pos], size);
			_pos	+= size ;
			return size ;
		} else {
			
			ptrdiff_t _ret	=  OS_Read (_fd, buffer , size) ;
			if( _ret <=0 || _ret > size ) {
				return 0 ;
			}
			_bu( buffer[0.._ret] );
			return _ret ;
		}
	}

	final  override size_t writeBlock(const void* buffer, size_t size) {
		if (_fd < 0)
		    return -1;
		// log("OS_Write fd: %d size:%d data:`%s`", _fd, size, cast(string) buffer[0 .. size] );
		ptrdiff_t ret = OS_Write (_fd , buffer, size) ;
		assert(ret <= size);
		return ret <0 ? 0 : ret ;
	}
	
	final override ulong seek(long offset, SeekPos rel) {
		throw new SeekException("not implement");
		return 0 ;
	}
	
	final string read_string(ptrdiff_t len){
		assert(len >= 0);
		if( len > 0 ) {
			version(USE_READ_CACHE) {
				if( !read_fcgi( len ) ) {
					throw new Exception(`invalid fcgi request`);
				}
				ubyte* _ret	= 	&_bu.slice[ _pos ];
				_pos			+=	len ;
				return cast(string) _ret[0..len] ;
			} else {
				_bu.move(len);
				char[] _ret = cast(char[]) _bu.slice[ $-len .. $];
				readExact(_ret.ptr, len);
				return cast(string) _ret ;
			}
		}
		return "" ;
	}
}
