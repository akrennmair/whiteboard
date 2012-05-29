#import('dart:html');
#import('dart:json');

void main() {
	CanvasElement canvas = document.query('#wb');
	CanvasRenderingContext2D ctx = canvas.getContext("2d");

	WebSocket ws_recv = new WebSocket("ws://" + window.location.host + "/view");
	ws_recv.on.message.add((event) {
		List<int> coords = JSON.parse(event.data);
		ctx.beginPath();
		for (int i=0;i<coords.length;i+=2) {
			ctx.lineTo(coords[i], coords[i+1]);
		}
		ctx.stroke();
	});
}

