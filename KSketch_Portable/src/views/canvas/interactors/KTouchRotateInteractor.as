package views.canvas.interactors
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import org.gestouch.events.GestureEvent;
	import org.gestouch.gestures.PanGesture;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.controls.interactors.KRotateInteractor;
	import sg.edu.smu.ksketch2.model.objects.KObject;
	import sg.edu.smu.ksketch2.utils.KMathUtil;
	
	import views.canvas.interactioncontrol.KMobileInteractionControl;
	
	public class KTouchRotateInteractor extends KTouchTransitionInteractor
	{
		private var _rotateGesture:PanGesture;
		private var _theta:Number;
		
		private var _center:Point;
		private var _previousPoint:Point;
		private var _startPoint:Point;
		
		public function KTouchRotateInteractor(KSketchInstance:KSketch2, interactionControl:KMobileInteractionControl, inputComponent:DisplayObject)
		{
			super(KSketchInstance, interactionControl);
			
			_rotateGesture = new PanGesture(inputComponent);
			_rotateGesture.maxNumTouchesRequired = 1;
		}
		
		override public function reset():void
		{
			super.reset();
			_rotateGesture.removeAllEventListeners();
			_theta = NaN;
			
			activate();
		}
		
		override public function activate():void
		{
			super.activate();
			_rotateGesture.addEventListener(GestureEvent.GESTURE_BEGAN, _interaction_begin);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			_rotateGesture.removeAllEventListeners();
		}
		
		override protected function _interaction_begin(event:GestureEvent):void
		{
			super._interaction_begin(event);
			
			_theta = 0;
			_previousPoint = _rotateGesture.location;
			_center = _newSelection.centerAt(_KSketch.time);
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			trace("_interaction control's transition mode", _interactionControl.transitionMode == KSketch2.TRANSITION_DEMONSTRATED);
			for(i; i < length; i++)
				_KSketch.beginTransform(_transitionObjects.getObjectAt(i),_interactionControl.transitionMode);
			
			_rotateGesture.addEventListener(GestureEvent.GESTURE_CHANGED, _update_Rotate);
			_rotateGesture.addEventListener(GestureEvent.GESTURE_ENDED, _interaction_end);			
		}
		
		override protected function _interaction_end(event:GestureEvent):void
		{
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.endTransform(_transitionObjects.getObjectAt(i),  _interactionControl.currentInteraction);
			
			super._interaction_end(event);
			reset();
		}
		
		private function _update_Rotate(event:GestureEvent):void
		{
			var touchLocation:Point = _rotateGesture.location;

			var angleChange:Number = KMathUtil.angleOf(_previousPoint.subtract(_center), touchLocation.subtract(_center));
			
			if(angleChange > Math.PI)
				angleChange = angleChange - KRotateInteractor.PIx2;
			
			_theta += angleChange;
			
			var i:int = 0;
			var length:int = _transitionObjects.length();
			var currentObject:KObject;
			
			for(i; i < length; i++)
				_KSketch.updateTransform(_transitionObjects.getObjectAt(i), 0, 0, _theta, 0 );
			
			_previousPoint = touchLocation;
		}
	}
}