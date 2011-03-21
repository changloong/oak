
module oak.util.Pool ;

import 
	std.c.string,
	core.memory ,
	std.traits ;


struct Pool {
	private {
		static const _Max_Step		= int.max >> 4  ;
		static const _Min_Step		= ubyte.max << 4 ;
		static const _Def_Step		= ushort.max << 4 ;
		
		ubyte*	data ;
		size_t	pos ;
		
		size_t	size ;
		size_t	step ;
		GC.BlkAttr attr ;
	}
	
	void Init(size_t _step = _Def_Step , GC.BlkAttr _attr = GC.BlkAttr.NO_SCAN  | GC.BlkAttr.NO_MOVE ) {
		if( _step >= _Min_Step && _step < _Max_Step ) {
			step	= _step ;
		} else {
			step	= _Min_Step ;
		}
		if( _attr !is 0 ) {
			attr	= _attr ;
		}
		pos	= 0 ;
		size	= 0 ;
		data	= null ;
	}
	
	void Clear(){
		pos	= 0 ;
	}
	
	~this(){
		if( data !is null ) {
			GC.free(data) ;
		}
	}
	
	T Copy(T)(T v) if( isSomeString!(T) ) {
		if( v is null ) {
			return null ;
		}
		alias typeof(T[0]) C ;
		auto _len = v.length   ;
		auto len  = C.sizeof * _len   ;
		if( len is 0 ) {
			return v ;
		}
		C* ret	= cast(C*) alloc( len + C.sizeof ) ;
		memcpy(ret, v.ptr, len ) ;
		ret[_len] = 0 ;
		return ret[ 0 .. _len ] ;
	}
	
	ubyte* alloc(size_t _size) {
		size_t _pos	= pos + _size ;
		if( _pos > size ) {
			size_t _new_size	= size + step ;
			while( _new_size <= _pos ) {
				_new_size	+= step ;
			}
			if( _size > step ) {
				_new_size	+= step ;
			}
			if( data is null ) {
				data	= cast(ubyte*) GC.malloc( _new_size , attr ) ;
			} else {
				data	= cast(ubyte*) GC.realloc(data, _new_size , attr ) ;
			}
			assert(data !is null);
			size	= _new_size ;
		}
		scope(exit){
			pos	= _pos ;
		}
		return &data[pos] ;
	}
	
	T* New(T, A...)(A a) if( is(T==struct) ) {
		T* p	= cast(T*) alloc(T.sizeof) ;
		memcpy(p, &T.init, T.sizeof) ;
		static if ( A.length > 0 ) {
			static if ( is(typeof(p.__ctor(a))) ){
		   		p.__ctor(a);
			} else {
				static assert(false);
			}
		}
		static if( is(typeof(p.__dtor)) ){
			static assert(false, T.stringof ~ ".__dtor is not implement with " ~ typeof(this).stringof );
		}
		return p;
	}
	
	T New(T, A...)(A a) if( is(T==class) && !__traits(isAbstractClass, T) ) {
		T p = new(&this,  __traits(classInstanceSize, T) ) T(a) ;
		static if( is(typeof(p.__dtor)) ){
			static assert(false, T.stringof ~ ".__dtor is not implement with " ~ typeof(this).stringof );
		}
		return p;
	}
	
	template Allocator() {
		alias typeof(this) Pool_Alloc_This ;
		static assert( is(Pool_Alloc_This==class), typeof(this).stringof ~ ".Allocator only for class" );
		enum Pool_Alloc_Size	= __traits(classInstanceSize, Pool_Alloc_This) ;
		static assert( is(Pool_Alloc_This==class) ) ;
		final new(size_t size, Pool* pool, size_t _size) {
			return pool.alloc(_size) ;
		}
	}
}


