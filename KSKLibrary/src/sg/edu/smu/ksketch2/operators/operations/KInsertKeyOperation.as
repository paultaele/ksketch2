/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.operators.operations
{
	import sg.edu.smu.ksketch2.model.data_structures.IKeyFrame;
	import sg.edu.smu.ksketch2.model.data_structures.KKeyFrame;
	
	/**
	 * The KInsertKeyOperation class serves as the concrete class for handling
	 * insert key frame operations in K-Sketch.
	 */
	public class KInsertKeyOperation extends KKeyOperation
	{
		/**
		 * The main constructor for the KInsertKeyOperation class.
		 * 
		 * @param before The previous key frame.
		 * @param after The next key frame.
		 * @param insertedKey The inserted key frame.
		 */
		public function KInsertKeyOperation(before:IKeyFrame, after:IKeyFrame, insertedKey:IKeyFrame)
		{
			// set the newer key frame as the inserted key frame
			_newKey = insertedKey as KKeyFrame;
			
			// set the previous and next key frames
			super(before, after);
			
			// case: the insert key operation is invalid
			// throw an error
			if(!isValid())
				throw new Error(errorMessage);
		}
		
		/**
		 * Gets the error message for the insert key operation.
		 * 
		 * @return The error message for the insert key time operation.
		 */
		override public function get errorMessage():String
		{
			return "KInsertKeyOperation: No inserted key is given to this operation"
		}
		
		/**
		 * Checks whether the insert key operation is valid. If not, it should
		 * fail on construction and not be added to the operation stack.
		 * 
		 * @return Whether the insert key operation is valid.
		 */
		override public function isValid():Boolean
		{
			// check if the newer key frame is non-null
			return _newKey != null;
		}
		
		/**
		 * Undoes the insert key operation by reverting the state of the
		 * operation to immediately before the operation was performed.
		 */
		override public function undo():void
		{
			// case: the previous key frame is non-null
			// set the previous key frame as the next key frame
			if(_before)
				_before.next = _after;
			
			// case: the next key frame is non-null
			// set the next key frame as the previous key frame
			if(_after)
				_after.previous = _before;
			
			// nullify the newer key frame's previous and next keys
			_newKey.previous = null;
			_newKey.next = null;
		}
		
		/**
		 * Redoes the insert key operation by reverting the state of the
		 * operation to immediately after the operation was performed.
		 */
		override public function redo():void
		{
			// case: the previous key frame is non-null
			// set the previous key frame as the newer key frame
			if(_before)
				_before.next = _newKey;
			
			// case: the next key frame is non-null
			// set the next key frame as the newer key frame
			if(_after)
				_after.previous = _newKey;
			
			// set the newer key frame's previous and next key frames as the
			// current key frame's previous and next key frames, respectively
			_newKey.previous = _before;
			_newKey.next = _after;
		}
	}
}