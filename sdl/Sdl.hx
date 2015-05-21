package sdl;

@:cppFileCode('
#include <sdl/EventType.h>
#include <sdl/WindowStateChange.h>
')
class Sdl implements NativeWrapper {

	static var initDone = false;
	public static var isWindows(get, never) : Bool;
	inline static function get_isWindows() : Bool return (untyped __cpp__("IS_WINDOWS") : Bool);

	@:keep public static function init() {
		if( initDone ) return;
		initDone = true;
		@cpp {
			if( SDL_Init(SDL_INIT_EVERYTHING ) != 0 ) failwith("Failed to init SDL");
			// Set the internal windows timer period to 1ms (will give accurate sleep for vsync)
			timeBeginPeriod(1);
		}
	}

	public static function loop( callb : Void -> Void, ?onEvent : Event -> Void ) {
		var event = new Event();
		while( true ) {
			while( true ) {
				untyped __cpp__('
					SDL_Event e;
					if( SDL_PollEvent(&e) == 0 ) break;
					switch( e.type ) {
					case SDL_QUIT:
						event->type = EventType_obj::Quit;
						return null();
					case SDL_MOUSEMOTION:
						event->type = EventType_obj::MouseMove;
						event->mouseX = e.motion.x;
						event->mouseY = e.motion.y;
						break;
					case SDL_KEYDOWN:
						event->type = EventType_obj::KeyDown;
						event->keyCode = e.key.keysym.sym;
						event->keyRepeat = e.key.repeat != 0;
						break;
					case SDL_KEYUP:
						event->type = EventType_obj::KeyUp;
						event->keyCode = e.key.keysym.sym;
						break;
					case SDL_SYSWMEVENT:
						continue;
					case SDL_MOUSEBUTTONDOWN:
						event->type = EventType_obj::MouseDown;
						event->button = e.button.button;
						event->mouseX = e.button.x;
						event->mouseY = e.motion.y;
						break;
					case SDL_MOUSEBUTTONUP:
						event->type = EventType_obj::MouseUp;
						event->button = e.button.button;
						event->mouseX = e.button.x;
						event->mouseY = e.motion.y;
						break;
					case SDL_MOUSEWHEEL:
						event->type = EventType_obj::MouseWheel;
						event->wheelDelta = e.wheel.y;
#						if SDL_VERSION_ATLEAST(2,0,4)
						if( e.wheel.direction == SDL_MOUSEWHEEL_FLIPPED ) event->wheelDelta *= -1;
#						endif
						event->mouseX = e.wheel.x;
						event->mouseY = e.wheel.y;
						break;
					case SDL_WINDOWEVENT:
						event->type = EventType_obj::WindowState;
						switch( e.window.event ) {
						case SDL_WINDOWEVENT_SHOWN:
							event->state = WindowStateChange_obj::Show;
							break;
						case SDL_WINDOWEVENT_HIDDEN:
							event->state = WindowStateChange_obj::Hide;
							break;
						case SDL_WINDOWEVENT_EXPOSED:
							event->state = WindowStateChange_obj::Expose;
							break;
						case SDL_WINDOWEVENT_MOVED:
							event->state = WindowStateChange_obj::Move;
							break;
						case SDL_WINDOWEVENT_RESIZED:
							event->state = WindowStateChange_obj::Resize;
							break;
						case SDL_WINDOWEVENT_MINIMIZED:
							event->state = WindowStateChange_obj::Minimize;
							break;
						case SDL_WINDOWEVENT_MAXIMIZED:
							event->state = WindowStateChange_obj::Maximize;
							break;
						case SDL_WINDOWEVENT_RESTORED:
							event->state = WindowStateChange_obj::Restore;
							break;
						case SDL_WINDOWEVENT_ENTER:
							event->state = WindowStateChange_obj::Enter;
							break;
						case SDL_WINDOWEVENT_LEAVE:
							event->state = WindowStateChange_obj::Leave;
							break;
						case SDL_WINDOWEVENT_FOCUS_GAINED:
							event->state = WindowStateChange_obj::Focus;
							break;
						case SDL_WINDOWEVENT_FOCUS_LOST:
							event->state = WindowStateChange_obj::Blur;
							break;
						case SDL_WINDOWEVENT_CLOSE:
							event->state = WindowStateChange_obj::Close;
							break;
						default:
							//printf("Unknown window state code %d\\n", e.window.event);
							continue;
						}
						break;
					case SDL_TEXTEDITING:
					case SDL_TEXTINPUT:
						// skip
						continue;
					default:
						//printf("Unknown event type 0x%X\\n", e.type);
						continue;
					}
				');
				if( onEvent != null ) onEvent(event);
			}
			callb();
			@:privateAccess haxe.Timer.sync();
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