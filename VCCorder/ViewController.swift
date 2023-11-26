//
//  ViewController.swift
//  VCCorder
//
//  Created by victor on 2023/11/26.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    var delegate: AVCaptureFileOutputRecordingDelegate?
    
    @IBOutlet weak var imagePreview: UIView!
    
    var session: AVCaptureSession!
    var fileOutput: AVCaptureFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isRecording: Bool = false
    
    func initCamera() {
                
        let discoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera], mediaType: .video, position: .back)
        let devices = discoverSession.devices
        guard !devices.isEmpty else { fatalError("Missing Ultra Wide-angled Camera")}
        let ultraWideCamera: AVCaptureDevice = devices.first!
        
        let videoIn = try! AVCaptureDeviceInput(device: ultraWideCamera)
        self.session = AVCaptureSession()
        self.session.addInput(videoIn)
        self.fileOutput = AVCaptureMovieFileOutput()
        self.session.addOutput(self.fileOutput)
        
        var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.frame = self.imagePreview.frame
        self.imagePreview.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
                      
    override func viewDidLoad() {
        super.viewDidLoad()
        initCamera()
        delegate = self
        
    }

    @IBAction func recordButtonPressed(_ sender: UIButton) {
       
        if !self.isRecording {
            
            let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let dateTimePrefix: String = formatter.string(from: NSDate() as Date)
            
            let paths = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true)

            let documentsDirectory = paths[0] as String
            
            var fileNamePostfix = 0
            let filePath = "\(documentsDirectory)/\(dateTimePrefix)-\(fileNamePostfix).mp4"
            if FileManager.default.fileExists(atPath: filePath) {
                fileNamePostfix += 1
            }

            self.fileOutput.startRecording(to: NSURL(fileURLWithPath: filePath) as URL, recordingDelegate: delegate!)

        } else {
            self.session.stopRunning()
        }
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        self.isRecording = false
        print("finish recording")
    }
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        self.isRecording = true
        print("start recording")
    }
    
}

