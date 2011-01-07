package org.understandinguncertainty.QRiskLifetime
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
	
	import org.understandinguncertainty.QRISKLifetime.vo.QResultVO;

	[Event(name="complete", type="flash.events.Event")]
	public class NativeScore2011 extends EventDispatcher
	{
		public var outputData:String;
		public var errorData:String;
		public var process:NativeProcess;
		
		public function calculateScore(
			b_gender:int,			// 0..1
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
		):void
		{
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
			callInfo.executable = f.resolvePath("lifetime"+b_gender);
			var args:Vector.<String> = new Vector.<String>;
			args[0] = b_AF.toString();
			args[1] = b_ra.toString();
			args[2] = b_renal.toString();
			args[3] = b_treatedhyp.toString();
			args[4] = b_type2.toString();
			args[5] = bmi.toString();
			args[6] = ethrisk.toString();
			args[7] = fh_cvd.toString();
			args[8] = rati.toString();
			args[9] = sbp.toString();
			args[10] = smoke_cat.toString();
			args[11] = town.toString();
			args[12] = age.toString();
			args[13] = noOfFollowupYears.toString();
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
		
	}
}