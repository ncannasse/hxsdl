package sdl;

class Window implements NativeWrapper {

	static var windows : Array<Window> = [];

	@cpp var win : PTR<SDL_Window>;
	@cpp var glctx : SDL_GLContext;
	var lastFrame : Float;
	public var vsync(default, set) : Bool;
	public var width(get, never) : Int;
	public var height(get, never) : Int;
	public var fullScreen(default, set) : Bool;

	public function new( title : String, width : Int, height : Int ) {
		@cpp {
			SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 2 );
			SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 1 );
			SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1);
			SDL_GL_SetAttribute( SDL_GL_STENCIL_SIZE, 0);
			SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, 16);

			win = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
			if( win == NULL ) failwith("Failed to create window");
			glctx = SDL_GL_CreateContext(win);
			if( glctx == NULL ) failwith("Failed to init GL Context (OpenGL 2.1 required)");
		}
		if( !GL.init() ) throw "Failed to init GL API";
		windows.push(this);
		vsync = true;
	}

	function set_fullScreen(b) {
		if( b == fullScreen )
			return b;
		var k = 0;
		if( b ) k = @cpp SDL_WINDOW_FULLSCREEN_DESKTOP;
		if( @cpp SDL_SetWindowFullscreen(win, k) == 0 )
			fullScreen = b;
		return fullScreen;
	}

	public function resize( width : Int, height : Int ) {
		@cpp SDL_SetWindowSize(win, width, height);
	}

	function get_width() {
		var w = 0;
		@cpp SDL_GetWindowSize(win, ADDR(w), NULL);
		return w;
	}

	function get_height() {
		var h = 0;
		@cpp SDL_GetWindowSize(win, NULL, ADDR(h));
		return h;
	}

	function set_vsync(v) {
		var i = v ? 1 : 0;
		@cpp SDL_GL_SetSwapInterval(i);
		return vsync = v;
	}

	/**
		Set the current window you will render to (in case of multiple windows)
	**/
	public function renderTo() {
		@cpp SDL_GL_MakeCurrent(win, glctx);
	}

	public function present() {
		if( vsync && Sdl.isWindows ) {
			// NVIDIA OpenGL windows driver does implement vsync as an infinite loop, causing high CPU usage
			// make sure to sleep a bit here based on how much time we spent since the last frame
			var spent = haxe.Timer.stamp() - lastFrame;
			if( spent < 0.0155 ) Sys.sleep(0.0155 - spent);
		}
		GL.finish();
		@cpp SDL_GL_SwapWindow(win);
		lastFrame = haxe.Timer.stamp();
	}

	public function destroy() {
		@cpp {
			SDL_DestroyWindow(win);
			SDL_GL_DeleteContext(glctx);
			win = NULL;
			glctx = NULL;
		}
		windows.remove(this);
	}

}