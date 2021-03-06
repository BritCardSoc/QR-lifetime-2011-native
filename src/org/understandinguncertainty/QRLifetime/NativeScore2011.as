/*
This file forms part of the library which provides the JBS3Risk Risk Model.
It is ©2012 University of Cambridge.
It is released under version 3 of the GNU General Public License
Source code, including a copy of the license is available at https://github.com/BritCardSoc/JBS3Risk

It contains code derived from http://qrisk.org/lifetime/QRISK-lifetime-2011-opensource.v1.0.tgz released by ClinRisk Ltd.

*/
package org.understandinguncertainty.QRLifetime
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import org.understandinguncertainty.QRLifetime.vo.QParametersVO;
	import org.understandinguncertainty.QRLifetime.vo.QResultVO;

	[Event(name="complete", type="flash.events.Event")]
	public class NativeScore2011 extends EventDispatcher
	{
		public var outputData:String;
		public var errorData:String;
		public var process:NativeProcess;
		
		public function calculateScore(q:QParametersVO):void
		{
			var p:QParametersVO = q.clone();
			outputData = "";
			
			if(NativeProcess.isSupported) {
				errorData = "";
			}
			else {
				errorData = "Native calls not supported in this profile";
			}
			
			var callInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var f:File = File.applicationDirectory.resolvePath("QRISK-lifetime-2011-opensource");
			callInfo.workingDirectory = f; 
			callInfo.executable = f.resolvePath("lifetime"+p.b_gender);
			var args:Vector.<String> = new Vector.<String>;
			args[0] = p.b_AF.toString();
			args[1] = p.b_ra.toString();
			args[2] = p.b_renal.toString();
			args[3] = p.b_treatedhyp.toString();
			args[4] = p.b_type2.toString();
			args[5] = p.bmi.toString();
			args[6] = p.ethRisk.toString();
			args[7] = p.fh_cvd.toString();
			args[8] = p.rati.toString();
			args[9] = p.sbp.toString();
			args[10] = p.smoke_cat.toString();
			args[11] = p.town.toString();
			args[12] = p.age.toString();
			args[13] = p.noOfFollowUpYears.toString();
			callInfo.arguments = args;
			
			process = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, readStdout);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, readStderr);
			process.addEventListener(NativeProcessExitEvent.EXIT, nativeDone);
			process.start(callInfo);
			return;

		}
		
		private function nativeDone(event:NativeProcessExitEvent):void
		{
			dispatchEvent(new Event(Event.COMPLETE));	
		}	
		
		private function readStdout(event:ProgressEvent):void
		{
			outputData += process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);	
		}
		
		private function readStderr(event:ProgressEvent):void
		{
			errorData += process.standardError.readUTFBytes(process.standardError.bytesAvailable);
		}
		
		public function get result():QResultVO
		{
			if(outputData == null) return null;
			var rsa:Array = outputData.split(/\s*,\s*/);
			var result:QResultVO = new QResultVO(rsa[0], rsa[1]);
			if(errorData != "") {
				result.error = new Error(errorData);
			}
			else if(isNaN(result.nYearRisk) || isNaN(result.lifetimeRisk)) {
				result.error = new Error("invalid numbers: "+outputData);
			} 
			
			// clean up event handlers 
			process.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, readStdout);
			process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, readStderr);
			return result;
		}
/*		
		public function getDummyScores(
			b_AF:int,			// 0..1
			b_ra:int,			// 0..1
			b_renal:int, 		// 0..1
			b_treatedhyp:int, 	// 0..1 
			b_type2:int,         // 0..1
			bmi:Number,          // 20..40
			ethrisk:int,         // 1..9
			fh_cvd:int,          // 0..1
			rati:Number,          // 1..12
			sbp:Number,           // 70..210
			smoke_cat:int,        //  0..4
			town:Number,          // -7..11
			age:int,              // ..95
			noOfFollowupYears:int // <95-age
			):Vector.<Number>
		{
			var result:Vector.<Number> = new Vector.<Number>();
			result[0] = 1;
			result[1] = 1;
			return result;
		}
*/		
	}
}