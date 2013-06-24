/**
 * Copyright 2010-2012 Singapore Management University
 * Developed under a grant from the Singapore-MIT GAMBIT Game Lab
 * This Source Code Form is subject to the terms of the
 * Mozilla Public License, v. 2.0. If a copy of the MPL was
 * not distributed with this file, You can obtain one at
 * http://mozilla.org/MPL/2.0/.
 */
package sg.edu.smu.ksketch2.canvas.controls.interactors.widgetstates
{
	public interface IWidgetMode
	{
		function init():void;
		function activate():void;
		function deactivate():void;
		function set demonstrationMode(demo:Boolean):void
		function set enabled(enable:Boolean):void;
	}
}