
module oak.util.Stack ;


import std.conv ;

struct Stack (V, int Size = 0,  size_t Step = 64 ) {
	
        alias nth              opIndex;
        alias slice            opSlice;
        alias rotateRight      opShrAssign;
        alias rotateLeft       opShlAssign;
        alias push             opCatAssign;
          
        
        static if (Size == 0) {
		private size_t depth ;
		private V[]  stack ;
	} else {
		private size_t     depth ;
		private V[Size]  stack ;
	}

        Stack* clear (){
                depth = 0;
                return &this;
        }

        size_t size ()
        {
                return depth;
        }
	
        size_t unused ()
        {
                return stack.length - depth;
        }

        Stack clone ()
        {       
                Stack s = void;
                static if (Size == 0) {
			s.stack.length = stack.length;
		}
                s.stack[] = stack;
                s.depth = depth;
                return s;
        }

        V dup() {
                auto v = top;
                push (v);       
                return v;
        }

        Stack* push (V value) {
                static if (Size == 0) {
			if (depth >= stack.length) {
                              stack.length = stack.length + Step ;
			}
			stack[depth++] = value;
		}else {                      
                        if (depth < stack.length) {
                              stack[depth++] = value;
			} else {
                              error (__LINE__);
			}
		}
                return &this ;
        }

        Stack* append (V[] value...){
                foreach (v; value)
                         push (v);
                return &this ;
        }
	
        V pop () {
                if (depth) {
                    return stack[--depth];
		}
                return error (__LINE__);
        }

        V top () {
                if (depth)
                    return stack[depth-1];

                return error (__LINE__);
        }

        V swap () {
                auto p = stack.ptr + depth;
                if ((p -= 2) >= stack.ptr) {
			auto v = p[0];
			p[0] = p[1];
			return p[1] = v; 
		}
                return error (__LINE__);                
        }

        V nth (size_t i){
                if (i < depth) {
                	return stack [depth-i-1];
		}
                return error (__LINE__);
        }

        private V error (size_t line) {
                assert(false, to!string(line) ) ;
        }

        ptrdiff_t opApply (ptrdiff_t delegate(ref V value) dg) {
		ptrdiff_t result;

		for (ptrdiff_t i=depth; i-- && result is 0;){
		     result = dg (stack[i]) ;
		}
		return result;
        }
	
	
        Stack* rotateLeft (size_t d){
                if (d <= depth)
                   {
                   auto p = &stack[depth-d];
                   auto t = *p;
                   while (--d)
                          *p++ = *(p+1);
                   *p = t;
                   }
                else
                   error (__LINE__);
                return &this ;
        }

        Stack* rotateRight (size_t d){
                if (d <= depth)
                   {
                   auto p = &stack[depth-1];
                   auto t = *p;
                   while (--d)
                          *p-- = *(p-1);
                   *p = t;
                   }
                else
                   error (__LINE__);
                return &this ;
        }
	
        V[] slice () {
                return stack [0 .. depth];
        }
	size_t length(){
		return depth ;
	}
}
