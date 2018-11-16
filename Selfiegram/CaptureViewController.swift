//
//  CaptureViewController.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/16/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import UIKit
import AVKit

class PreviewView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func setSession(_ session: AVCaptureSession) {
        // Ensure that we only ever do this once for this view
        guard self.previewLayer == nil else {
            NSLog("Warning: \(self.description) attempted to set its" + " preview layer more than once. This is not allowed.")
            return
        }
        
        // Create a preview layer that gets its content from the provided capture session
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        // Fill the contents of the layer, preserving the original aspect ratio
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        // Add the preview layer to our layer
        self.layer.addSublayer(previewLayer)
        
        // Store a reference to the layer
        self.previewLayer = previewLayer
        
        // Ensure that the sublayer is laid out
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        previewLayer?.frame = self.bounds
    }
    
    func setCameraOrientation(_ orientation: AVCaptureVideoOrientation) {
        previewLayer?.connection?.videoOrientation = orientation
    }
}

class CaptureViewController: UIViewController {
    
    @IBOutlet weak var cameraPreview: PreviewView!
    typealias ComplitionHandler = (UIImage?) -> Void
    var complition: ComplitionHandler?
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    
    var currentVideoOrientation: AVCaptureVideoOrientation {
        let orientationMap: [UIDeviceOrientation: AVCaptureVideoOrientation]
        
        orientationMap = [
            .portrait: .portrait,
            .landscapeLeft: .landscapeLeft,
            .landscapeRight: .landscapeRight,
            .portraitUpsideDown: .portraitUpsideDown
        ]
        
        let currentOrientation = UIDevice.current.orientation
        let videoOrientation = orientationMap[currentOrientation, default: .portrait]
        
        return videoOrientation
    }
    
    override func viewDidLoad() {
        
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.front
        )
        
        // Get the first available devide, bail if we can't find one
        
        guard let captureDevice = discovery.devices.first else {
            NSLog("No capture devices available")
            self.complition?(nil)
            return
        }
        
        // Attempt to add this device to the capture session
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch {
            NSLog("Failed to add camera to capture session: \(error)")
            self.complition?(nil)
        }
        
        // Configure the camera to use high-resolution capture settings
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        // Begin the capture session
        captureSession.startRunning()
        
        // Add the photo output to the session, so that it can receive photos when it wants them
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        self.cameraPreview.setSession(captureSession)
        
        super.viewDidLoad()
    }
    
    @IBAction func close(_ sender: Any) {
        self.complition?(nil)
    }
    
    @IBAction func takeSelfie(_ sender: Any) {
        // Get a connection to the output
        guard let videoConnection = photoOutput.connection(with: AVMediaType.video) else {
            print("Failed to get camera connection")
            return
        }
        
        // Set its orientation, so that the image is oriented correctly
        videoConnection.videoOrientation = currentVideoOrientation
        
        // Indicate that we want the data it captures to be in JPEG format
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        
        // Begin capturing a photo; it will call
        // photoOutput(_ didFinishProcessingPhoto:, error:) when done
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
 
    override func viewWillLayoutSubviews() {
        self.cameraPreview?.setCameraOrientation(currentVideoOrientation)
    }
}


extension CaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Failed to get photo: \(error)")
            return
        }
        
        guard let jpegData = photo.fileDataRepresentation(),
        let image = UIImage(data: jpegData) else {
            print("Failed to get image from encoded data")
            return
        }
        
        self.complition?(image)
    }
}
