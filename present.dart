#import('dart:html');
#import('dart:json');

CanvasRenderingContext2D ctx;
WebSocket ws_send;
List<int> coords;
bool authenticated = false;
bool mouseDown = false;
int left_offset, top_offset;

void try_authenticate() {
	InputElement password = document.query('#password');
	if (password.value == "dontmessitup") {
		document.query('#error').style.display = 'none';
		authenticated = true;
	} else {
		document.query('#error').style.display = 'inline';
	}
}

void drawStart(int x, int y) {
	ctx.beginPath();
	ctx.moveTo(x, y);
	coords = [ x, y ];
}

void drawTo(int x, int y) {
	ctx.lineTo(x, y);
	ctx.stroke();
	coords.add(x);
	coords.add(y);
}
	
void drawEnd() {
	ctx.closePath();
	ws_send.send(JSON.stringify(coords));
	coords = [];
}


void main() {
	CanvasElement canvas = document.query('#wb');
	ctx = canvas.getContext("2d");
	ws_send = new WebSocket("ws://" + window.location.host + "/present");

	Future<ElementRect> f = canvas.rect; f.then((ElementRect rect) {
		left_offset = rect.offset.left;
		top_offset = rect.offset.top;
	});

	canvas.on.mouseDown.add( (MouseEvent e) {
		try_authenticate();
		if (!authenticated)
			return;
		mouseDown = true;
		int x = e.clientX - left_offset;
		int y = e.clientY - top_offset;
		drawStart(x, y);
	});

	canvas.on.touchStart.add( (TouchEvent e) {
		e.preventDefault();
		try_authenticate();
		if (!authenticated)
			return;
		mouseDown = true;
		Touch t = e.touches.item(0);
		int x = t.clientX - left_offset;
		int y = t.clientY - top_offset;
		drawStart(x, y);
	});

	canvas.on.mouseMove.add( (MouseEvent e) {
		if (!authenticated || !mouseDown)
			return;
		int x = e.clientX - left_offset;
		int y = e.clientY - top_offset;
		drawTo(x, y);
	});

	canvas.on.touchMove.add( (TouchEvent e) {
		e.preventDefault();
		if (!authenticated || !mouseDown)
			return;
		Touch t = e.touches.item(0);
		int x = t.clientX - left_offset;
		int y = t.clientY - top_offset;
		drawTo(x, y);
	});

	canvas.on.mouseUp.add( (MouseEvent e) {
		if (!authenticated || !mouseDown)
			return;
		mouseDown = false;
		drawEnd();
	});

    canvas.on.touchEnd.add( (TouchEvent e) {
		if (!authenticated || !mouseDown)
			return;
		mouseDown = false;
		drawEnd();
	});
}
