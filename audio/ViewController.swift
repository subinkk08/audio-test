//
//  ViewController.swift
//  audio
//
//  Created by Vineeth Vijayan on 02/12/15.
//  Copyright © 2015 Vineeth Vijayan. All rights reserved.
//

import UIKit
import EZAudio

class ViewController: UIViewController, EZMicrophoneDelegate, EZRecorderDelegate, EZAudioPlayerDelegate {
    
    var microphone: EZMicrophone!;
    var recorder: EZRecorder!
    var player: EZAudioPlayer!
    var isRecording = false
    var isPause = false
    var fileUrl = NSURL!()
    var session = 0
    var totalFrames:Int64 = 0
    
    var startTime = NSTimeInterval()
    var elapsedTime = NSTimeInterval()
    var startTimeDate = NSDate()
    var elapsedTimeDate = NSDate()
    var timer = NSTimer()
    
    
    @IBOutlet weak var audioPilotView: EZAudioPlotGL!
    
    @IBOutlet weak var playingAudioPilot: EZAudioPlot!
    
    @IBOutlet weak var btnRecord: UIButton!
    
    @IBOutlet weak var btnFinish: UIButton!
    
    @IBOutlet weak var btnPauseResume: UIButton!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var btnStop: UIButton!
    
    @IBAction func btnPlayTapped(sender: AnyObject) {
        
        
        if player == nil {
            
            btnPlay.setTitle("Play", forState: UIControlState.Normal)
            
            self.player = EZAudioPlayer(delegate: self)
            
            let path1 = NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory, .UserDomainMask, true
                ).first
            
            
            let documentDirectoryURL =  NSURL.fileURLWithPath(path1! + "/EZAudioTest_0.m4a")
            let final =  documentDirectoryURL
            let audioFile = EZAudioFile(URL:  final)
            //EZAudioFile *audioFile = [EZAudioFile audioFileWithURL:[self testFilePathURL]];
            self.player.audioFile = audioFile
            
            self.volumeSlider.value = self.player.volume
            
            
            totalFrames = self.player.audioFile.totalFrames
            self.slider.maximumValue = Float(self.player.audioFile.totalFrames)
        }
        
        
        if player.isPlaying == true {
            btnPlay.setTitle("Pause", forState: UIControlState.Normal)
            player.pause()
        }
        else {
            
            
            if isRecording{
                isRecording = false
                self.microphone.stopFetchingAudio()
            }
            
            ///////////////
            //////////////////////
            player.play()
            btnStop.hidden = false
            btnPlay.setTitle("Play", forState: UIControlState.Normal)
            
        }
    }
    
    
    @IBAction func stopPlaying(sender: UIButton) {
        
        btnStop.hidden = true
        btnPlay.setTitle("Play", forState: UIControlState.Normal)
        self.player.seekToFrame(totalFrames)
        self.lblTime.text = "00:00:00"
    }
    
    @IBAction func changeVolume(sender: UISlider) {
        self.player.volume = sender.value
        
    }
    
    
    
    @IBAction func seekFile(sender: UISlider) {
        self.player.seekToFrame(Int64(sender.value))
        
    }
    
    func updateTime() {
        
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        
        lblTime.text = strMinutes+":"+strSeconds+":"+strFraction
        
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        
        // Update any UI controls including sliders and labels
        // display current time/duration
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            
            if (!self.slider.touchInside)
            {
                self.slider.setValue(Float(framePosition), animated: true)
            }
            
            
            //self.lblTime.text = String(Int(framePosition)/36000)
            let seconds = Int(((self.totalFrames-framePosition)/36000)) % 60
            let minutes = (Int(((self.totalFrames-framePosition)/36000)) / 60) % 60
            let hours = Int(((self.totalFrames-framePosition)/36000)) / 3600
            let strHours = hours > 9 ? String(hours) : "0" + String(hours)
            let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
            let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
            print((strHours)+":"+(strMinutes)+":"+(strSeconds))
            self.lblTime.text = (strHours)+":"+(strMinutes)+":"+(strSeconds)
            
        })
    }
    
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, reachedEndOfAudioFile audioFile: EZAudioFile!) {
        let path1 = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first
        
        
        var documentDirectoryURL:NSURL? =  NSURL.fileURLWithPath(path1! + "/EZAudioTest_0.m4a")
        
        //        self.recorder = EZRecorder(URL: documentDirectoryURL,
        //            clientFormat: self.microphone.audioStreamBasicDescription(),
        //            fileType: EZRecorderFileType.M4A,
        //            delegate: self)
        //        self.recorder.delegate = self
        //        self.recorder.closeAudioFile()
        
        //self.player = nil
        self.btnPlay.hidden = false
        self.btnPauseResume.hidden = true
        self.btnStop.hidden = true
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        if isPause == true {
            self.playingAudioPilot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    
    @IBAction func btnPauseTapped(sender: AnyObject) {
        if isPause {
            isPause = false
            btnPauseResume.setTitle("Resume ", forState: UIControlState.Normal)
            isPause = false
            self.microphone.stopFetchingAudio()
            audioPilotView.pauseDrawing()
            elapsedTime += startTimeDate.timeIntervalSinceNow
            timer.invalidate()
        }
        else {
            
            
            btnPauseResume.setTitle("Pause ", forState: UIControlState.Normal)
            isPause = true
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTimeDate = NSDate()
            startTime = NSDate.timeIntervalSinceReferenceDate() + elapsedTime
            
            self.microphone.startFetchingAudio()
            audioPilotView.resumeDrawing()
            
        }
        
        
    }
    
    @IBAction func sliderTouchInside(sender: UISlider) {
        self.player.seekToFrame(Int64(sender.value))
    }
    
    
    
    //    func combineTwoFile(session:Int){
    //
    //
    //
    //        var composition = AVMutableComposition()
    //        var compositionAudioTrack1:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
    //        var compositionAudioTrack2:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
    //
    //        //create new file to receive data
    //
    //        let path1 = NSSearchPathForDirectoriesInDomains(
    //            .DocumentDirectory, .UserDomainMask, true
    //            ).first
    //
    //
    //        var documentDirectoryURL =  NSURL.fileURLWithPath(path1! + "/resultmerge.wav")
    //
    //
    //
    //
    //        let orginalFile = NSURL.fileURLWithPath(path1! + "/EZAudioTest_0.m4a")
    //        let currentFile = NSURL.fileURLWithPath(path1! + "/EZAudioTest_"+session.description+".m4a")
    //
    //
    //
    //
    //        let avAsset1: AVURLAsset = AVURLAsset(URL: orginalFile, options: nil)
    //        let avAsset2: AVURLAsset = AVURLAsset(URL: currentFile, options: nil)
    //
    //        var tracks1 =  avAsset1.tracksWithMediaType(AVMediaTypeAudio)
    //        var tracks2 =  avAsset2.tracksWithMediaType(AVMediaTypeAudio)
    //
    //        let assetTrack1:AVAssetTrack = tracks1[0]
    //        let assetTrack2:AVAssetTrack = tracks2[0]
    //
    //        let duration1: CMTime = assetTrack1.timeRange.duration
    //        let duration2: CMTime = assetTrack2.timeRange.duration
    //
    //        let timeRange1 = CMTimeRangeMake(kCMTimeZero, duration1)
    //        let timeRange2 = CMTimeRangeMake(duration1, duration2)
    //
    //
    //        _ = try? compositionAudioTrack1.insertTimeRange(timeRange1, ofTrack: assetTrack1, atTime: kCMTimeZero)
    //        _ = try?  compositionAudioTrack1.insertTimeRange(timeRange2, ofTrack: assetTrack2, atTime: duration1)
    //
    //
    //        //AVAssetExportPresetPassthrough => concatenation
    //        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
    //        assetExport!.outputFileType = AVFileTypeAppleM4A
    //        assetExport!.outputURL = documentDirectoryURL
    //        assetExport!.exportAsynchronouslyWithCompletionHandler({
    //            switch assetExport!.status{
    //            case  AVAssetExportSessionStatus.Failed:
    //                print("failed \(assetExport!.error)")
    //            case AVAssetExportSessionStatus.Cancelled:
    //                print("cancelled \(assetExport!.error)")
    //            default:
    //                print("complete")
    //            }
    //        })
    //
    //    }
    
    
    //    func combineTwoFile(session:Int) {
    //        let composition: AVMutableComposition = AVMutableComposition()
    //        var appendedAudioTrack: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
    //        let path1 = NSSearchPathForDirectoriesInDomains(
    //            .DocumentDirectory, .UserDomainMask, true
    //            ).first
    //
    //       let orginalFile = NSURL.fileURLWithPath(path1! + "/EZAudioTest_0.m4a")
    //          let currentFile = NSURL.fileURLWithPath(path1! + "/EZAudioTest_"+session.description+".m4a")
    //
    //
    //        let originalAsset: AVURLAsset = AVURLAsset(URL: orginalFile, options: nil)
    //        let newAsset: AVURLAsset = AVURLAsset(URL: currentFile, options: nil)
    //
    //
    //        var ok1 = false
    //        var ok2 = false
    //
    //
    //        var tracks1 =  originalAsset.tracksWithMediaType(AVMediaTypeAudio)
    //        var tracks2 =  newAsset.tracksWithMediaType(AVMediaTypeAudio)
    //
    //        var assetTrack1:AVAssetTrack = tracks1[0] as! AVAssetTrack
    //        var assetTrack2:AVAssetTrack = tracks2[0] as! AVAssetTrack
    //
    //        var duration1: CMTime = assetTrack1.timeRange.duration
    //        var duration2: CMTime = assetTrack2.timeRange.duration
    //
    //        print(duration2.seconds.description)
    //
    //        var timeRange1 = CMTimeRangeMake(kCMTimeZero, duration1)
    //        var timeRange2 = CMTimeRangeMake(duration1, duration2)
    //
    //
    //        try? appendedAudioTrack.insertTimeRange(timeRange1, ofTrack: assetTrack1, atTime: kCMTimeZero)
    //
    //
    //        try? appendedAudioTrack.insertTimeRange(timeRange2, ofTrack: assetTrack2, atTime: duration1)
    //
    //             let exportSession: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
    //        if exportSession == false {
    //            // do something
    //            return
    //        }
    //
    //        let fileManager = NSFileManager.defaultManager()
    //        try? fileManager.removeItemAtURL(NSURL.fileURLWithPath(path1! + "/EZAudioTest_0.m4a"))
    //          try? fileManager.removeItemAtURL(NSURL.fileURLWithPath(path1! + "/EZAudioTest_1.m4a"))
    //        // make sure to fill this value in
    //        exportSession.outputURL = NSURL(string: (NSURL.fileURLWithPath(path1! + "/EZAudioTest_0.m4a").description))
    //        exportSession.outputFileType = AVFileTypeAppleM4A;
    //        exportSession.exportAsynchronouslyWithCompletionHandler({() -> Void in
    //            // exported successfully?
    //            switch exportSession.status {
    //            case .Failed: break
    //
    //            case .Completed: break
    //                // you should now have the appended audio file
    //
    //            case .Waiting: break
    //
    //            default: break
    //            }
    //          //  var error: NSErrorPointer? = nil
    //        })
    //
    //
    //    }
    
    
    @IBAction func btnFinishTapped(sender: AnyObject) {
        isPause = false
        isRecording = false
        btnPauseResume.hidden = true
        btnFinish.hidden = true
        btnRecord.hidden = false
        btnPlay.hidden = false
        self.microphone.stopFetchingAudio()
        if ((self.recorder) != nil)
        {
            self.recorder.closeAudioFile()
        }
        if session != 0{
            // combineTwoFile(session)
        }
        session = 0
        timer.invalidate()
        elapsedTime = 0
        lblTime.text = "00:00:00"
    }
    
    
    @IBAction func btnRecordTapped(sender: AnyObject) {
        
        if isRecording == true{
            isRecording = false
            btnPauseResume.hidden = false
            btnFinish.hidden = false
            btnPlay.hidden = true
            isRecording = false
            self.microphone.stopFetchingAudio()
            
            
            
        }
        else {
            btnRecord.hidden = true
            btnPauseResume.hidden = false
            btnFinish.hidden = false
            isPause = true
            isRecording = true
            btnPlay.hidden = true
            isRecording = true
            print(fileUrl.description)
            
            
            
            self.microphone.startFetchingAudio()
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTimeDate = NSDate()
            startTime = NSDate.timeIntervalSinceReferenceDate() + elapsedTime
            
        }
        
    }
    
    
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        if isRecording{
            self.recorder.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnPauseResume.hidden = true
        btnFinish.hidden = true
        btnPlay.hidden = true
        btnStop.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        microphone = EZMicrophone(delegate: self, startsImmediately: true);
        self.microphone.stopFetchingAudio()
        
        
        //        self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
        
        audioPilotView.plotType = EZPlotType.Rolling
        audioPilotView?.shouldFill = true;
        audioPilotView?.shouldMirror = true;
        
        
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first
        
        self.fileUrl = NSURL.fileURLWithPath(path! + "/EZAudioTest_"+session.description+".m4a")
        
        self.recorder = EZRecorder(URL: self.fileUrl,
            clientFormat: self.microphone.audioStreamBasicDescription(),
            fileType: EZRecorderFileType.M4A,
            delegate: self)
        
        self.recorder.delegate = self
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidChangePlayState:", name:EZAudioPlayerDidChangePlayStateNotification , object: self.player)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidReachEndOfFile:", name:EZAudioPlayerDidReachEndOfFileNotification , object: self.player)
        
        self.slider.addTarget(self, action: "touchInside:", forControlEvents: UIControlEvents.TouchDown)
        
        
    }
    
    
    
    
    func touchInside(sender:UISlider) {
        self.player.seekToFrame(Int64(sender.value))
    }
    func playerDidChangePlayState(notification: NSNotification){
        
    }
    
    func playerDidReachEndOfFile(notification: NSNotification){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.audioPilotView?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
    
}

