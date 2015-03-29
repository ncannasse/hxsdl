package haxe;

class Timer {

	static var timers = new Array<Timer>();

	var period : Int;
	var elapsed : Int;

	public function new(time_ms:Int) {
		this.period = time_ms;
		this.elapsed = 0;
		timers.push(this);
		timers.sort(sortByNext);
	}

	public function stop() : Void {
		timers.remove(this);
	}

	public dynamic function run() : Void {
	}

	public static function delay( f : Void -> Void, time_ms : Int ) : Timer {
		var t = new haxe.Timer(time_ms);
		t.run = function() {
			t.stop();
			f();
		};
		return t;
	}

	public static function measure<T>( f : Void -> T, ?pos : PosInfos ) : T {
		var t0 = stamp();
		var r = f();
		Log.trace((stamp() - t0) + "s", pos);
		return r;
	}

	public static function stamp() : Float {
		return untyped __global__.__time_stamp();
	}

	static function sortByNext( t1 : Timer, t2 : Timer ) : Int {
		var n1 = t1.period - t1.elapsed;
		var n2 = t2.period - t2.elapsed;
		return n1 == n2 ? t1.period - t2.period : n1 - n2;
	}

	static var lastStamp = 0.;
	static function sync() : Void {
		var t = stamp();
		if( lastStamp == 0 ) {
			lastStamp = t;
			return;
		}
		var dt = Std.int((t - lastStamp) * 1000);
		if( dt == 0 ) return;
		lastStamp += dt / 1000;
		// make sure the timers are run in good order
		var torun = false;
		for( t in timers ) {
			t.elapsed += dt;
			if( t.elapsed >= t.period ) torun = true;
		}
		if( !torun )
			return;
		while( true ) {
			var found = false;
			for( t in timers ) {
				if( t.elapsed >= t.period ) {
					t.elapsed -= t.period;
					t.run();
					found = true;
					timers.sort(sortByNext);
					break;
				}
			}
			if( !found ) break;
		}
	}

}