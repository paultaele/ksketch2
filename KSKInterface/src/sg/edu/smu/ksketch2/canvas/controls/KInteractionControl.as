/**
*Copyright 2010-2012 Singapore Management University
*Developed under a grant from the Singapore-MIT GAMBIT Game Lab

*This Source Code Form is subject to the terms of the
*Mozilla Public License, v. 2.0. If a copy of the MPL was
*not distributed with this file, You can obtain one at
*http://mozilla.org/MPL/2.0/.
*/
package sg.edu.smu.ksketch2.canvas.controls
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import sg.edu.smu.ksketch2.KSketch2;
	import sg.edu.smu.ksketch2.canvas.components.timebar.KSketch_TimeControl;
	import sg.edu.smu.ksketch2.events.KSketchEvent;
	import sg.edu.smu.ksketch2.operators.operations.IModelOperation;
	import sg.edu.smu.ksketch2.utils.KInteractionOperation;
	import sg.edu.smu.ksketch2.utils.KSelection;
	

	public class KInteractionControl extends EventDispatcher implements IInteractionControl
	{
		public static const EVENT_INTERACTION_BEGIN:String = "Interaction Begin";
		public static const EVENT_INTERACTION_END:String = "Interaction End";
		public static const EVENT_UNDO_REDO:String = "Undo Redo";
		public static const EVENT_TRANSITION_MODE_CHANGED:String = "Transition Mode Changed";
		
		private var _KSketch:KSketch2;
		private var _transitionMode:int;
		private var _selection:KSelection;
		private var _timeControl:KSketch_TimeControl;
		
		private var _undoStack:Vector.<IModelOperation>;
		private var _redoStack:Vector.<IModelOperation>;
		private var _currentInteraction:KInteractionOperation;
		
		public function KInteractionControl(KSketchInstance:KSketch2, timeControl:KSketch_TimeControl)
		{
			super(this);
			_KSketch = KSketchInstance;
			_timeControl = timeControl;
		}
		
		/**
		 * Resets application state variables
		 *  - Resets undo/redo stacks
		 *  - Resets selection
		 *  - Resets interaction state
		 *  - Resets time Control
		 */
		public function reset():void
		{
			_undoStack = new Vector.<IModelOperation>();
			_redoStack = new Vector.<IModelOperation>();
			_selection = null;
			_currentInteraction = null;
			
			_timeControl.reset();
			
			_KSketch.reset();
		}
		
		public function set transitionMode(mode:int):void
		{
			_transitionMode = mode;
		}
		
		public function get transitionMode():int
		{
			return _transitionMode;
		}
		
		public function set selection(newSelection:KSelection):void
		{
			if(newSelection)
			{
				if(newSelection.objects.length() == 0)
					newSelection = null;
				else
				{
					if(!newSelection.isDifferentFrom(_selection))
						return;
				}
			}
			
			if(!_selection && !newSelection)
				return;
			
			var oldSelection:KSelection = _selection;
			_selection = newSelection;
			
			var i:int;
			var length:int;
			
			//Will trigger the selection/deselection
			//Will cause the objects to trigger their selection events
			if(oldSelection)
				oldSelection.triggerDeselected();
			
			if(newSelection)
				newSelection.triggerSelected();
			
			dispatchEvent(new KSketchEvent(KSketchEvent.EVENT_SELECTION_SET_CHANGED));
		}
		
		public function get selection():KSelection
		{
			return _selection;
		}
		
		/**
		 * For touch versions, call after every selection interaction
		 */
		public function addToUndoStack(operation:IModelOperation):void
		{
			if(!operation.isValid())
				throw new Error(operation.errorMessage);
			_undoStack.push(operation);
			
			if(hasRedo)
				_redoStack = new Vector.<IModelOperation>();

			dispatchEvent(new Event(EVENT_UNDO_REDO));
		}
		
		public function undo():void
		{
			if(!_undoStack)
				_undoStack = new Vector.<IModelOperation>();
			
			if(_undoStack.length == 0)
				return;
			
			var undoOp:IModelOperation = _undoStack.pop();
			undoOp.undo();
			_redoStack.push(undoOp);
			
			var log:XML = <op/>;
			var date:Date = new Date();
			
			log.@category = "Undo";
			log.@type = "Undo";
			log.@elapsedTime = KSketch_TimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			_KSketch.log.appendChild(log);
			
			dispatchEvent(new Event(EVENT_UNDO_REDO));
		}
		
		public function redo():void
		{
			if(!_redoStack)
				_redoStack = new Vector.<IModelOperation>();
			
			if(_redoStack.length == 0)
				return;
			
			var redoOp:IModelOperation = _redoStack.pop();
			redoOp.redo();
			_undoStack.push(redoOp);
			
			var log:XML = <op/>;
			var date:Date = new Date();
			
			log.@category = "Undo";
			log.@type = "Redo";
			log.@elapsedTime = KSketch_TimeControl.toTimeCode(date.time - _KSketch.logStartTime);
			_KSketch.log.appendChild(log);
			
			dispatchEvent(new Event(EVENT_UNDO_REDO));
		}
		
		public function get hasUndo():Boolean
		{
			return _undoStack.length > 0;
		}
		
		public function get hasRedo():Boolean
		{
			return _redoStack.length > 0;
		}
		
		public function triggerInterfaceUpdate():void
		{
			//Wait and see if we need to do anything ehre
		}
		
		public function get currentInteraction():KInteractionOperation
		{
			return _currentInteraction;
		}
		
		public function beginRecording():void
		{
			_timeControl.startRecording();
		}
		
		public function stopRecording():void
		{
			_timeControl.stopRecording();
		}
		
		public function begin_interaction_operation():void
		{
			if(currentInteraction)
				throw new Error("Can't begin an interaction operation. The previous interaction was not properly closed.");
			_currentInteraction = new KInteractionOperation(this, _timeControl);
			_currentInteraction.startTime = _KSketch.time;
			_currentInteraction.oldSelection = selection;
		}
		
		public function cancel_interaction_operation():void
		{
			_currentInteraction = null;
		}
		
		public function end_interaction_operation(operation:IModelOperation=null, newSelection:KSelection=null):void
		{
			if(currentInteraction)
			{
				if(operation)
					currentInteraction.addOperation(operation);
	
				currentInteraction.newSelection = selection;
				currentInteraction.endTime = _KSketch.time;
				
				if(currentInteraction.length > 0)
					addToUndoStack(currentInteraction);
				else
					cancel_interaction_operation();
			}
			_currentInteraction = null;
		}
		
		public function debugView():void
		{
			
		}		
		
		/**
		 * Not required for touch
		 */
		public function beginCanvasInput(point:Point, isManipulation:Boolean, manipulationType:String):void
		{
			//Disabled for touch
		}
		
		public function updateCanvasInput(point:Point):void
		{
			//Disabled for touch
		}
		
		public function completeCanvasInput():void
		{
			//Disabled for touch
		}
		
		public function enterDrawingMode(drawModeType:String):void
		{
			
		}
		
		
		public function init():void
		{
			
		}
		

		public function determineMode():void
		{
			
		}
		
		public function enterSelectionMode():void
		{
			
		}
	}
}