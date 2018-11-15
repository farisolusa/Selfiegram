//
//  CaptureViewController.swift
//  Selfiegram
//
//  Created by Anil Prasad on 11/16/18.
//  Copyright © 2018 Anil Prasad. All rights reserved.
//

import UIKit
import AVKit

class CaptureViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillLayoutSubviews() {
        //self.cameraPreview?.setCameraOrientation(currentVideoOrientation)
    }
}

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
