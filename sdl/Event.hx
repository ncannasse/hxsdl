package sdl;

@:keep class Event {
	public var type : EventType;
	public var mouseX : Int;
	public var mouseY : Int;
	public var button : Int;
	public var wheelDelta : Int;
	public var state : WindowStateChange;
	public var keyCode : Int;
	public var keyRepeat : Bool;
	public var charCode : Int;
	public function new() {
	}
}

enum EventType {
	Quit;
	MouseMove;
	MouseLeave;
	MouseDown;
	MouseUp;
	MouseWheel;
	WindowState;
	KeyDown;
	KeyUp;
}

enum WindowStateChange {
	Show;
	Hide;
	Expose;
	Move;
	Resize;
	Minimize;
	Maximize;
	Restore;
	Enter;
	Leave;
	Focus;
	Blur;
	Close;
}
