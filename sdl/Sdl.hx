package sdl;

class Sdl implements NativeWrapper {

	public static var isWindows(get, never) : Bool;
	inline static function get_isWindows() : Bool return (untyped __cpp__("IS_WINDOWS") : Bool);

	public static function init() {
		@cpp {
			if( SDL_Init(SDL_INIT_EVERYTHING ) != 0 ) failwith("Failed to init SDL");
			// Set the internal windows timer period to 1ms (will give accurate sleep for vsync)
			timeBeginPeriod(1);
		}
	}

	public static function loop( callb : Void -> Void ) {
		while( true ) {
			@cpp {
				var e : SDL_Event;
				while( SDL_PollEvent(ADDR(e)) != 0 ) {
					if( e.type == SDL_QUIT )
						return;
				}
			}
			callb();
        }
	}

	public static function quit() {
		@cpp {
			SDL_Quit();
			timeEndPeriod(1);
		}
	}

	public static function delay(time:Int) {
		@cpp SDL_Delay(time);
	}


	public static function getScreenWidth() : Int {
		@cpp {
			var e : SDL_DisplayMode;
			SDL_GetCurrentDisplayMode(0, ADDR(e));
			return e.w;
		}
		return 0;
	}

	public static function getScreenHeight() : Int {
		@cpp {
			var e : SDL_DisplayMode;
			SDL_GetCurrentDisplayMode(0, ADDR(e));
			return e.h;
		}
		return 0;
	}

	public static function message( title : String, text : String, error = false ) {
		@cpp SDL_ShowSimpleMessageBox(error?SDL_MESSAGEBOX_ERROR:0, title.c_str(), text.c_str(), NULL);
	}

}