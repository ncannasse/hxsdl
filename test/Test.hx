import sdl.GL;

class Test {

	static var VSHADER = "
		attribute vec2 position;
		attribute vec2 uv;
		varying vec2 tuv;

		uniform vec4 rotation[1];

		void main() {
			float r = rotation[0].x;
			gl_Position = vec4(position.x * cos(r) + position.y * sin(r), -position.x * sin(r) + position.y * cos(r), 0, 1);
			tuv = uv;
		}
	";

	static var FSHADER = "
		varying vec2 tuv;
		uniform sampler2D tex;
		void main()
		{
			gl_FragColor = texture(tex, tuv);
		}
	";

	static function main() {
		trace("INIT");
		sdl.Sdl.init();
		try {
			start();
		} catch( e : Dynamic ) {
			sdl.Sdl.message("ERROR",Std.string(e),true);
		}
		sdl.Sdl.quit();
		trace("DONE");
	}

	static function start() {
		var win = new sdl.Window("Hello", 800, 600);
		win.vsync = true;

		var vs = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vs, VSHADER);
		GL.compileShader(vs);
		if( GL.getShaderParameter(vs, GL.COMPILE_STATUS) != 1 )
			throw GL.getShaderInfoLog(vs);

		var fs = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(fs, FSHADER);
		GL.compileShader(fs);
		if( GL.getShaderParameter(fs, GL.COMPILE_STATUS) != 1 )
			throw GL.getShaderInfoLog(fs);

		var pr = GL.createProgram();
		GL.attachShader(pr, vs);
		GL.attachShader(pr, fs);
		GL.linkProgram(pr);
		if( GL.getProgramParameter(pr, GL.LINK_STATUS) != 1 )
			throw GL.getProgramInfoLog(pr);
		GL.useProgram(pr);

		var buf = GL.createBuffer();
		var arr : Array<cpp.Float32> = [
			0, 0.5, 0.5, 0,
			0.5, -0.5, 1, 1,
			-0.5, -0.5, 0, 1
		];
		GL.bindBuffer(GL.ARRAY_BUFFER, buf);
		GL.bufferData(GL.ARRAY_BUFFER, arr, GL.STATIC_DRAW);

		var ibuf = GL.createBuffer();
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, ibuf);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, ([0, 1, 2] : Array<cpp.UInt16>), GL.STATIC_DRAW);

		var pos = GL.getAttribLocation(pr, "position");
		var uv = GL.getAttribLocation(pr, "uv");
		GL.enableVertexAttribArray(0);
		GL.enableVertexAttribArray(1);

		var unk = GL.getAttribLocation(pr, "unknown");
		if( unk != null )
			throw unk+" unknown should be null";

		GL.vertexAttribPointer(pos, 2, GL.FLOAT, false, 16, 0);
		GL.vertexAttribPointer(uv, 2, GL.FLOAT, false, 16, 2 * 4);

		var image = sys.io.File.getBytes("hxlogo.png");
		var png = new format.png.Reader(new haxe.io.BytesInput(image)).read();
		var pngHeader = format.png.Tools.getHeader(png);
		var pngData = format.png.Tools.extract32(png);


		// BGRA to RGBA
		for( i in 0...pngData.length << 2 ) {
			var b = pngData.get(i << 2);
			var r = pngData.get((i << 2) + 2);
			pngData.set(i << 2, r);
			pngData.set((i << 2) + 2, b);
		}

		var tex = GL.createTexture();
		GL.bindTexture(GL.TEXTURE_2D, tex);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, pngHeader.width, pngHeader.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, pngData.getData());
		var tid = GL.getUniformLocation(pr, "tex");
		GL.uniform1i(tid, 0);
		GL.activeTexture(GL.TEXTURE0);

		GL.enable(GL.BLEND);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

		var rot = GL.getUniformLocation(pr, "rotation");


		var oldTime = haxe.Timer.stamp();
		var fps = 60.;
		var time = 0.;
		var t = new haxe.Timer(1000);
		t.run = function() {
			trace("FPS = " + fps);
		}
		sdl.Sdl.loop(function() {
			GL.clearColor(0, 0 ,(Math.sin(time*2) + 1) * 0.25, 1);
			GL.clear(GL.COLOR_BUFFER_BIT);

			GL.uniform4fv(rot, [time, 0, 0, 0]);
			GL.drawElements(GL.TRIANGLES, 3, GL.UNSIGNED_SHORT, 0);

			win.present();
			var newTime = haxe.Timer.stamp();
			var realFPS = 1 / (newTime - oldTime);
			time += newTime - oldTime;
			oldTime = newTime;
			fps = fps * 0.98 + realFPS * 0.02;
		},function(e) {
			var a : Dynamic = switch( e.type ) {
			case MouseMove: { x : e.mouseX, y : e.mouseY };
			case MouseDown, MouseUp: { but : e.button, x : e.mouseX, y : e.mouseY };
			case MouseWheel: { delta : e.wheelDelta };
			case KeyDown:
				if( e.keyCode == 0x40000044 /*F11*/ )
					win.fullScreen = !win.fullScreen;
				{ k : e.keyCode, repeat : e.keyRepeat };
			case KeyUp: { k : e.keyCode };
			case WindowState:
				switch( e.state ) {
				case Resize:
					"Resize " + win.width + "x" + win.height;
				default:
					e.state;
				}
			case Quit, MouseLeave: "";
			}
			trace(e.type+" " + a);
		});

		win.destroy();
	}

}