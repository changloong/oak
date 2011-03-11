
module jade.util.Buffer ;


import 
	std.range,
	std.algorithm,
	std.array,
	std.conv,
	std.string,
	std.traits;
	
import std.c.string : memcpy;

private alias OutputRange!(char) out_range ;

final class vBuffer  :  out_range {
	        alias typeof(this)	This;
        static enum MaxLen	= int.max >> 4 ;
	
	private {
                ubyte[] data ;
                ptrdiff_t  pos , step ;
        }
	
        final this(size_t len, size_t step = 1024 ) in {
                assert( len >= 0 );
                assert( step >= 0 );
        } out {
                assert( data.length >= pos ) ;
        } body {
		if( len > 0 ) {
             		this.data               = new ubyte[len] ;
		}
                this.step               = step ;
                this.pos                = 0 ;
        }
       
        final this(void[] tmp) in{
                assert(tmp !is null);
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body {
                data            = cast(ubyte[]) tmp ;
                this.step       = tmp.length ;
                this.pos        = 0 ;
        }
	
        final void clear()  in{
                assert( data.length >= pos ) ;
        } out{
                assert( data.length >= pos ) ;
        } body {
                pos     = 0 ;
        }
	
        final size_t length () in{
                assert( data.length >= pos ) ;
        } out{
                assert( data.length >= pos ) ;
        } body  {
                return pos ;
        }
       
        final ubyte[] slice ()  in{
                assert( data.length >= pos ) ;
        } out{
                assert( data.length >= pos ) ;
        } body {
                return data [0 .. pos] ;
        }
       
        final ubyte[] space ()  in{
                assert( data.length >= pos ) ;
        } out{
                assert( data.length >= pos ) ;
        } body {
                return data [pos..$] ;
        }
	
        final bool move(size_t _step)  in{
                assert( data.length >= pos ) ;
        } out{
                assert( data.length >= pos , to!string(pos) ~ " :" ~ to!string( data.length) ~ " :" ~ to!string( _step) ) ;
        } body {
		size_t _pos	= pos + _step ;
		if( _pos < 0 ) {
			return false ;
		}
		if( pos > data.length ) {
			expand(pos);
		}
		pos	= _pos ;
		return true ;
        }
	
        final private void expand(string _file = __FILE__, ptrdiff_t _line = __LINE__ )(size_t size) in{
                assert( data.length >= pos ) ;
		assert( size < 1024 * 1024 * 1024 );
        } out{
                assert( data.length >= pos ) ;
        } body {
                size_t len = data.length ;
                if( len - pos >= size ) {
                        return ;
                }
                assert(step > 0 );
                while( len - pos < size ) {
                        len     +=      step ;
			assert( len < MaxLen ) ;
                }
                data.length     = len ;
		assert(len is  data.length );
        }
	
        final size_t append(string _file = __FILE__, ptrdiff_t _line = __LINE__ )(const void* buffer, size_t len) in {
                assert( data.length >= pos ) ;
        } out{
                assert( data.length >= pos ) ; 
        } body{
                if( buffer is null ) {
                        return 0 ;
                }
                if( len > 0 ) {
                        expand!(_file, _line)(len);
                        memcpy( &data[pos], buffer, len);
                        pos     +=      len ;
                }
                return len ;
        }
	
	final string toString(){
		return cast(string) slice ;
	}

	final This opCall(T_, string _file = __FILE__, ptrdiff_t _line = __LINE__ )(T_ val){
		alias Unqual!(T_) T ;
		static if( is(T==char) ) {
			expand(1) ;
			data[pos]       = val ;
			pos     +=      1 ;
		} else static if( is(T==wchar) || is(T==dchar) ) {
			static assert(false);
		} else static if( isNumeric!(T) ){
			string _tmp = to!string(val) ;
			append!(_file, _line)(_tmp.ptr, _tmp.length ) ;
		} else static if( isSomeString!(T) ){
			append!(_file, _line)(val.ptr, val.length * typeof(val[0]).sizeof ) ;
		} else static if( isArray!(T) && ( is( typeof(val[0]) == ubyte) || is( typeof(val[0]) == void)  ) ){
			append!(_file, _line)(val.ptr, val.length ) ;
		} else {
			static assert(false);
		}
		return this ;
	}
	
	ptrdiff_t capability() {
		return data.length ;
	}
	
	final void put(char val){
		expand(1) ;
		data[pos] = val ;
		pos	+=      1 ;
	}
	
	final void put(string val){
		opCall(val);
	}
	
	final void put(char[] val){
		opCall(val);
	}
	
	final void unstrip(string inp){
		ptrdiff_t len = inp.length ;
		for(ptrdiff_t i = 0; i < len; i++){
			if( inp[i] is '\\' ){
				opCall("\\\\");
			} else if( inp[i] is '\"' ){
				opCall('\\')(inp[i]);
			} else if( inp[i] is '\n'){
				opCall('\\')('n');
			} else if( inp[i] is '\r'){
				
			} else {
				opCall(inp[i]);
			}
		}
	}

	final void strip( string inp){
		ptrdiff_t len = inp.length ;
		for(ptrdiff_t i = 0; i < len; i++){
			if( inp[i] is '\\' ){
				i++;
				if( i is len  ) {
					break;
				}
				switch( inp[i] ) {
					case 'n':
						opCall('n');
						break;
					case '\'':
						opCall('\'');
						break;
					case 't':
						opCall('\t');
						break;
					case 'r':
						opCall('\r');
						break;
					case '\\':
						opCall('\\');
						break;
					default:
						i--;
						opCall(inp[i]);
				}
			} else {
				opCall(inp[i]);
			}
		}
	}
}


