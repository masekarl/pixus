﻿// pixusGuideDragger class
// (cc)2009 JPEG Interactive
// By Jam Zhang
// jammind@gmail.com

package {
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import com.google.analytics.GATracker;

	public class pixusGuideDragger extends Sprite {
		
		private var type:String;
		private var _host:pixusMain;
		private var dx, dy:int;
		private var tracker:GATracker=pixusShell.tracker;

		public function pixusGuideDragger(pm:pixusMain, t:String, pos:int=0):void {
			_host=pm;
			type=t;
			if(type.charAt(0)=='H'){
				hotspot.rotation=-90;
				hotspot.x=-20;
			}
			hotspot.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}

		function handleMouse(event:MouseEvent):void {
			switch(event.type){
				case MouseEvent.MOUSE_DOWN:
//					tracker.trackPageview( 'Pixus/Guide');
					var p:Point=localToGlobal(new Point(0,0));
					dx=p.x-event.stageX;
					dy=p.y-event.stageY;
					stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
					stage.addEventListener(MouseEvent.MOUSE_UP, handleMouse);
					break;
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouse);
					break;
				case MouseEvent.MOUSE_MOVE:
					syncGuides(new Point(event.stageX+dx,event.stageY+dy));
					break;
			}
		}

		public function set offsetx(x0:int){
			hotspot.x=x0;
		}

		public function set offsety(y0:int){
			hotspot.y=y0;
		}

		public function syncGuides(point:Point):void{
			point=parent.globalToLocal(point);
			switch (type){
				case 'VL':
					_host.setVerticalGuides(point.x);
					break;
				case 'VR':
					_host.setVerticalGuides(_host.rulerWidth-point.x);
					break;
				case 'HT':
					_host.setHorizontalGuides(point.y);
					break;
				case 'HB':
					_host.setHorizontalGuides(_host.rulerHeight-point.y);
					break;
			}
		}
	}
}