
module jade.util.Buffer ;


import 
	std.array,
	std.conv,
	std.string,
	std.traits;
	
import std.c.string : memcpy;

final class vBuffer {
        alias typeof(this)      This;
        static const MaxLen             = int.max >> 4 ;

        private {
                ubyte[] data ;
                size_t  pos , step ;
        }
       
        final this(size_t len, size_t step = 0) in {
                assert( len > 0 );     
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body {
                this.data               = new ubyte[len] ;
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
                this.step       = 0 ;
                this.pos        = 0 ;
        }
       
        final void clear()  in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body {
                pos     = 0 ;
        }
       
        final size_t length () in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body  {
                return pos ;
        }
       
        final ubyte[] slice ()  in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body {
                return data [0 .. pos] ;
        }
       
        final ubyte[] space ()  in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body {
                return data [pos..$] ;
        }
       
        final bool move(int _step)  in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos , to!string(pos) ~ " :" ~ to!string( data.length) ~ " :" ~ to!string( _step) ) ;
        } body {
		ptrdiff_t _pos	= pos + _step ;
		if( _pos < 0 ) {
			return false ;
		}
		if( pos > data.length ) {
			expand(pos);
		}
		pos	= _pos ;
		return true ;
        }
       
        final private void expand (size_t size) in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body {
                ptrdiff_t len = data.length ;
                if( len - pos >= size ) {
                        return ;
                }
                assert(step > 0 );
                while( len - pos < size ) {
                        len     +=      step ;
                        assert( len < MaxLen ) ;
                }
                data.length     = len ;
        }
       
        final This putString(void[] tmp) in {
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ; 
        } body{
                if( tmp is null ) {
                        return this ;
                }
                ptrdiff_t len = tmp.length ;
                if( len > 0 ) {
                        expand(len);
                        memcpy( &data[pos], &tmp[0], len);
                        pos     +=      len ;
                }
                return this ;
        }
	
        final size_t append(void[] tmp) in {
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ; 
        } body{
                if( tmp is null ) {
                        return 0 ;
                }
                ptrdiff_t len = tmp.length ;
                if( len > 0 ) {
                        expand(len);
                        memcpy( &data[pos], &tmp[0], len);
                        pos     +=      len ;
                }
                return len ;
        }
       
        final private This putByte(T)(T t)  in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body {
                static assert(T.sizeof is 1) ;
                expand(1) ;
                data[pos]       = t ;
                pos     +=      1 ;
                return this ;
        }
       
        final private This putInteger(T)(T t)  in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body  {
                static assert( isIntegral!(T)  ) ;
                //char[66] tmp    = void;
                string _tmp     =  to!string(t);
                append( cast(void[]) _tmp) ;
                return this ;
        }

        final private This putFloat(T)(T t) in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body  {
                static assert( isFloatingPoint!(T) );
                //char[66] tmp    = void;
                string _tmp     = to!string(t);
                append( cast(void[])  _tmp) ;
                return this ;
        }
       
        final private This putInt(T)(T t,  char[] fmt)  in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body {
                static assert( isIntegral!(T)  || isPointer!(T)  ) ;
               // char[66] tmp    = void;
                string _tmp     = std.string.format (fmt, t) ;
                append(cast(void[])_tmp) ;
                return this ;
        }
       
        final ubyte[] opSlice (size_t start, size_t end) in{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } out{
                assert( data !is null ) ;
                assert( data.length >= pos ) ;
        } body {
                assert (start <= pos);
                return data [start .. end] ;
        }
       
        final This replace(char[] tmp, char[][] from, char[][] to){
                if( tmp is null || tmp.length is 0 ){
                        return this ;
                }
                assert(from.length <= to.length ) ;

                while( true ) {
                        ptrdiff_t pos = tmp.length ;
                        ptrdiff_t index       = 0 ;
                        foreach(ptrdiff_t i, _tmp; from) {
                                if( _tmp is null || _tmp.length is 0 ) {
                                        continue ;
                                }
                                ptrdiff_t _pos        = indexOf( tmp, _tmp);
                                if( _pos < pos && _pos > 0  ) {
                                        pos     = _pos ;
                                        index   = i ;
                                }
                        }
                        if( pos is  tmp.length ) {
                                putString(tmp);
                                break ;
                        }
                        putString(tmp[ 0 .. pos ] ) ;
                        putString( to[index] ) ;

                        tmp     = tmp[ pos + from[ index ] .length .. $] ;
                       
                }
                return this ;
        }
	
	final This opCall(string tmp){
		putString(cast(char[]) tmp);
		return this ;
	}

        alias length            readable ;
        alias putString         opCall ;
       
        alias putByte!(char)    opCall ;

        alias putInteger!(short)        opCall ;
        alias putInteger!(ushort)       opCall ;
        alias putInteger!(int)  opCall ;
        alias putInteger!(uint) opCall ;
        alias putInteger!(long) opCall ;
        alias putInteger!(ulong)        opCall ;
       
        alias putFloat!(float)  opCall ;
        alias putFloat!(double) opCall ;
       
        alias putInt!(void*)    opCall ;
        alias putInt!(byte)     opCall ;
        alias putInt!(ubyte)    opCall ;
        alias putInt!(short)    opCall ;
        alias putInt!(ushort)   opCall ;
        alias putInt!(int)      opCall ;
        alias putInt!(uint)     opCall ;
        alias putInt!(long)     opCall ;
        alias putInt!(ulong)    opCall ;

	
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


