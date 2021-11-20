//
//  ViewController.swift
//  MiroCompanion
//
//  Created by Jese on 19.11.2021.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    var fullsTring: String?
    var hasrecorded: Bool?
    var timer: Timer!
    var timer2: Timer!
    var timer3: Timer!
    var timer4: Timer!
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_GB"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var buttonColor: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.layer.cornerRadius = 10.0
        buttonColor = recordButton.backgroundColor
        self.recordButton.setTitle("Start Listening", for: .normal)
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status {
              case .notDetermined: print("Not determined")
              case .restricted: print("Restricted")
              case .denied: print("Denied")
              case .authorized: print("We can recognize speech now.")
            @unknown default: print("Unknown case")
          }
        }
    }
    
    @objc func startRecording() {
        self.recordButton.tintColor = UIColor.red
        self.recordButton.setTitle("Listening", for: .normal)
            
        self.fullsTring = ""
        audioEngine.reset()
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record)
            try audioSession.setMode(.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioSession.setPreferredSampleRate(44100.0)
            
            if audioSession.isInputGainSettable {
                let error : NSErrorPointer = nil
                
                let success: ()? = try? audioSession.setInputGain(1.0)
                
                guard success != nil else {
                    print ("audio error")
                    return
                }
                if (success != nil) {
                    print("\(String(describing: error))")
                }
            }
            else {
                print("Cannot set input gain")
            }
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        self.timer4 = Timer.scheduledTimer(timeInterval: TimeInterval(40), target: self, selector: #selector(againStartRec), userInfo: nil, repeats: false)
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error ) in
            
            var isFinal = false  //8
            
            if result != nil {
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(2.0), target: self, selector: #selector(self.didFinishTalk), userInfo: nil, repeats: false)
                
                self.textLabel.text = result?.bestTranscription.formattedString
                
                isFinal = result!.isFinal
                
            }
            if error == nil{
                
            }
            if  isFinal {
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.fullsTring = result?.bestTranscription.formattedString
                self.textLabel.text = result?.bestTranscription.formattedString
                self.recognitionRequest = nil
                self.recognitionTask = nil
                isFinal = false
                
            }
            if error != nil{
                URLCache.shared.removeAllCachedResponses()
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                guard let task = self.recognitionTask else {
                    return
                }
                task.cancel()
                task.finish()
            }
        })
        audioEngine.reset()
        inputNode.removeTap(onBus: 0)
        
        let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        self.hasrecorded = true
    }

    @objc func againStartRec(){
        self.recordButton.tintColor = UIColor.red
        self.recordButton.setTitle("Listening", for: .normal)
        
        self.timer4.invalidate()
        self.timer?.invalidate()
        self.timer?.invalidate()
        
        if ((self.audioEngine.isRunning)){
            
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.recognitionTask?.finish()
        }
        self.timer2 = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
    }
    
    @objc func didFinishTalk(){
        
        if self.fullsTring != ""{
            
            self.recordButton.tintColor = self.buttonColor
            self.recordButton.setTitle("Start Listening", for: .normal)
            self.timer4.invalidate()
            self.timer?.invalidate()
            self.timer2?.invalidate()
            
            if ((self.audioEngine.isRunning)){
                self.audioEngine.stop()
                guard let task = self.recognitionTask else {
                    return
                }
                task.cancel()
                task.finish()
            }
        }
    }
    
    @objc func finishTalk(){
        
        self.recordButton.tintColor = self.buttonColor
        self.recordButton.setTitle("Start Listening", for: .normal)
        self.timer4.invalidate()
        self.timer?.invalidate()
        self.timer2?.invalidate()
        
        if ((self.audioEngine.isRunning)){
            self.audioEngine.stop()
            guard let task = self.recognitionTask else {
                return
            }
            task.cancel()
            task.finish()
        }
    }
    var bool = true
    @IBAction func recordingPress(_ sender: Any) {
        if (bool){
            startRecording()
        } else {
            finishTalk()
        }
        bool = (bool == false)
           
    }
    


}

