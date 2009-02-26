﻿// update class
// update NativeWindow
// Version 0.1.0 2009-1-30
// (cc)2007-2008 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.net.SharedObject;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.desktop.Updater;
	import flash.utils.ByteArray;


	public class update extends MovieClip {

		const PANEL_WIDTH:int=260;
		const STATE_CHECKING:int=0;
		const STATE_CONNECTION_FAILED:int=1;
		const STATE_LATEST:int=2;
		const STATE_OUTOFDATE:int=3;
		const STATE_DOWNLOADING:int=4;
		const STATE_DOWNLOADED:int=5;
		const STATE_DOWNLOAD_FAILED:int=6;

		var urlLoader:URLLoader=new URLLoader();
		var updateInfo:XML;
		var urlStream:URLStream = new URLStream(); 
		var fileData:ByteArray = new ByteArray(); 
		var file:File;

		function update():void {
			stop();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		function init(event:Event):void {
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			bClose.addEventListener(MouseEvent.CLICK, handleCloseButton);
			bg.addEventListener(MouseEvent.MOUSE_DOWN,handleMove);
			control.bCheck01.addEventListener(MouseEvent.CLICK,handleButtons);
			control.bCheck02.addEventListener(MouseEvent.CLICK,handleButtons);
			control.bDownload01.addEventListener(MouseEvent.CLICK,handleButtons);
			control.bDownload02.addEventListener(MouseEvent.CLICK,handleButtons);
			control.bInstall.addEventListener(MouseEvent.CLICK,handleButtons);
			control.bCancel.addEventListener(MouseEvent.CLICK,handleButtons);
			urlStream.addEventListener(ProgressEvent.PROGRESS,updateProgress); 
			urlStream.addEventListener(Event.COMPLETE,updateLoaded); 
			urlLoader.addEventListener(Event.COMPLETE,handleLoader);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,handleLoader);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,handleLoader);
			checkUpdate();
		}

		public function handleCloseButton(event:MouseEvent):void {
			stage.nativeWindow.visible=false;
		}

		function handleButtons(event:MouseEvent):void {
			switch (event.target) {
				case control.bCheck01 :
				case control.bCheck02 :
					checkUpdate();
					break;
				case control.bDownload01 :
				case control.bDownload02 :
//					trace(updateInfo.source[0]);
					downloadUpdate(updateInfo.source[0]);
					break;
				case control.bInstall :
					var updater:Updater=new Updater();
					updater.update(file,updateInfo.latest.version.toString());
					break;
				case control.bCancel :
					cancelUpdate();
					break;
			}
		}

		function checkUpdate():void {
			setState(STATE_CHECKING);
			urlLoader.load(new URLRequest(pixusShell.options.updateFeedURL));
		}

		function handleLoader(event:Event):void {
			switch(event.type){
				case Event.COMPLETE: // Update feed XML successfully loaded
					updateInfo=new XML(event.target.data);
					control.tfInfo01.text=control.tfInfo02.text=updateInfo.latest.version+'\n'+updateInfo.latest.release+'\n'+updateInfo.latest.date+'\n'+updateInfo.latest.size;
					if(pixusShell.options.version.release<updateInfo.latest.release){
						setState(STATE_OUTOFDATE);
						stage.nativeWindow.visible=true;
					} else
						setState(STATE_LATEST);
					break;
				default:
					setState(STATE_CONNECTION_FAILED);
					break;
			}
		}

		function cancelUpdate():void {
			setState(STATE_OUTOFDATE);
			urlLoader.close();
		}

		function downloadUpdate(url:XML){
			setState(STATE_DOWNLOADING);
			urlStream.load(new URLRequest(url.toString())); 
		}

		function updateProgress(event:ProgressEvent):void {
			control.tfProgress.text=int(event.bytesLoaded*0.001)+'/'+int(event.bytesTotal*0.001)+'KB';
			control.progress01.setProgress(event.bytesLoaded/event.bytesTotal);
			control.progress02.setProgress(event.bytesLoaded/event.bytesTotal);
		} 
 
		function updateLoaded(event:Event):void { 
			control.progress01.setProgress(1);
			control.progress02.setProgress(1);
		    urlStream.readBytes(fileData, 0, urlStream.bytesAvailable); 
		    writeAirFile(); 
			setState(STATE_DOWNLOADED);
		} 
 
		function writeAirFile():void { 
		    file = File.applicationStorageDirectory.resolvePath("pixus_update.air"); 
		    var fileStream:FileStream = new FileStream(); 
		    fileStream.open(file, FileMode.WRITE); 
		    fileStream.writeBytes(fileData, 0, fileData.length); 
		    fileStream.close(); 
		    trace("The AIR file is written."); 
		}

		function setState(s:int){
			control.x=-PANEL_WIDTH*s;
		}

		function handleMove(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN :
					stage.nativeWindow.startMove();
					stage.addEventListener(MouseEvent.MOUSE_UP,handleMove);
					break;
				case MouseEvent.MOUSE_UP :
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMove);
					pixusShell.options.updateWindowPosition=new Object();
					pixusShell.options.updateWindowPosition={x:stage.nativeWindow.x,y:stage.nativeWindow.y};
					break;
			}
		}

	}
}