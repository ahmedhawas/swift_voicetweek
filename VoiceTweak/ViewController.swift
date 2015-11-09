//
//  ViewController.swift
//  VoiceTweak
//
//  Created by Ahmed Hawas on 2015-11-08.
//  Copyright © 2015 Ahmed Hawas. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var rate : Float = 1.0
    var audioURL : NSURL?
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var loopSwitch: UISwitch!
    @IBOutlet weak var playButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpAudioRecorder()
    }
    
    func setUpAudioRecorder() {
        do {
            let basePath : String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
            let pathComponenets = [basePath, "theAudio.m4a"]
            self.audioURL = NSURL.fileURLWithPathComponents(pathComponenets)
            
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            try session.setActive(true)
            
            var recordSettings = [String : AnyObject]()
            recordSettings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
            recordSettings[AVSampleRateKey] = 44100.0
            recordSettings[AVNumberOfChannelsKey] = 2
            
            self.audioRecorder = try AVAudioRecorder(URL: self.audioURL!, settings: recordSettings)
            self.audioRecorder!.meteringEnabled = true
            self.audioRecorder!.prepareToRecord()
            
        } catch {}
    }
    
    @IBAction func recordTapped(button: UIButton) {
        if self.audioRecorder!.recording {
            self.audioRecorder!.stop()
            button.setTitle("RECORD", forState: UIControlState.Normal)
        } else {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                self.audioRecorder!.record()
                button.setTitle("STOP", forState: UIControlState.Normal)
            } catch {}
        }
    }
    
    @IBAction func playTapped(sender: UIButton) {
        
        if self.audioPlayer == nil {
            setUpAndPlay()
        } else {
            if self.audioPlayer!.playing {
                self.audioPlayer!.stop()
                self.playButton.setTitle("PLAY", forState: UIControlState.Normal)
            } else {
                setUpAndPlay()
            }
        }
    }
    
    func setUpAndPlay() {
        do {
            self.audioPlayer =  try AVAudioPlayer(contentsOfURL: self.audioURL!)
            self.audioPlayer!.enableRate = true
            self.audioPlayer!.rate = self.rate
            if self.loopSwitch.on {
                self.audioPlayer!.numberOfLoops = -1
            }
            self.audioPlayer!.delegate = self
            self.audioPlayer!.play()
            self.playButton.setTitle("STOP", forState: UIControlState.Normal)
        } catch {}
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.playButton.setTitle("PLAY", forState: UIControlState.Normal)
    }
    
    @IBAction func sliderMoved(slider: UISlider) {
        self.rate = 0.2
        self.rate += (slider.value * 3.8)
        
        let prettyRate = String(format: "%.1f", self.rate)
        self.speedLabel.text = "Speed \(prettyRate)x"
        
        if self.audioPlayer != nil {
            self.audioPlayer!.rate = self.rate
        }
    }
}

