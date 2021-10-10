//
//  CameraViewController.swift
//  CameraApp
//
//  Created by Josh Sorokin on 08/10/2021.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var capturePhotoView: UIButton!
    @IBOutlet weak var recordVideoButton: UIButton!
    @IBOutlet weak var toggleTorchButton: UIButton!
    
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var device: AVCaptureDevice!
    
    // This class is completely decoupled and injectable except for these references which are interchangable.
    let savePhotoService: SavePhotoServiceProtocol = SavePhotoToFilesService()
    let saveVideoService: SaveVideoServiceProtocol = SaveVideoToFilesService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment this and run app to clear files
        // clearFiles()
        
        self.title = "Camera App"
        
        recordVideoButton.isHidden = true
        
        setupCaptureSession()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .unspecified)
        device = videoDevice
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput) else { return }
        
        captureSession.addInput(videoDeviceInput)
        
        let audioDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified)
        
        guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice!), captureSession.canAddInput(audioDeviceInput) else { return }
        captureSession.addInput(audioDeviceInput)
        
        photoOutput = AVCapturePhotoOutput()
        
        guard captureSession.canAddOutput(photoOutput) else { return }
        
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        setupLivePreview()
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    func startRecording() {
        if movieOutput.isRecording == false {
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = .portrait
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
            if let image = UIImage(named: "red-video-circle") {
                recordVideoButton.setImage(image, for: .normal)
            }
        }
        else {
            stopRecording()
        }
    }
    
    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
            
            if let image = UIImage(named: "green-video-circle") {
                recordVideoButton.setImage(image, for: .normal)
            }
        }
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func toggleTorch(on: Bool) {
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    func clearFiles() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            try fileManager.removeItem(at: myDocuments)
        } catch {
            return
        }
    }
    
    @IBAction func didTakePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func videoRecordButtonTapped(_ sender: Any) {
        startRecording()
    }
    
    @IBAction func switchMedia(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            capturePhotoView.isHidden = false
            recordVideoButton.isHidden = true
        } else {
            capturePhotoView.isHidden = true
            recordVideoButton.isHidden = false
        }
    }
    
    @IBAction func toggleTorchTapped(_ sender: UIButton) {
        if device.torchMode == .off {
            toggleTorch(on: true)
            toggleTorchButton.setBackgroundImage(UIImage(systemName: "lightbulb.slash"), for: UIControl.State.normal)
        } else {
            toggleTorch(on: false)
            toggleTorchButton.setBackgroundImage(UIImage(systemName: "lightbulb"), for: UIControl.State.normal)
        }
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    
        guard let photoData = photo.fileDataRepresentation() else { return }
        
        let photo = UIImage(data: photoData)!
        
        savePhotoService.savePhoto(image: photo)
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        saveVideoService.saveVideo(videoURL: outputFileURL)
    }
    
}

