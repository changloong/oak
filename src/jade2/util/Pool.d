
module jade.util.Pool ;

import jade.Jade ;


struct Pool {
	private {
		static const _Max_Step		= int.max >> 4  ;
		static const _Min_Step		= ubyte.max << 4 ;
		static const _Def_Step		= ushort.max << 4 ;
		
		ubyte*	data	= null ;
		size_t	pos ;
		
		size_t	size ;
		size_t	step 	= _Min_Step ;
		GC.BlkAttr attr	= GC.BlkAttr.NO_SCAN  | GC.BlkAttr.NO_MOVE ;
	}
	
	void Init(size_t _step = _Def_Step , GC.BlkAttr _attr = cast(GC.BlkAttr) 0 ) {
		if( _step >= _Min_Step && _step < _Max_Step ) {
			step	= _step ;
		}
		if( _attr !is 0 ){
			attr	= _attr ;
		}
	}
	
	void Clear(){
		pos	= 0 ;
	}
	
	~this(){
		if( data !is null ) {
			GC.free(data) ;
		}
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
		final new(uint size, Pool* pool, uint _size) {
			return pool.alloc(_size) ;
		}
	}
}


