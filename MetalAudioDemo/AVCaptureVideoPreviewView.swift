//
//  AVCaptureVideoPreviewView.swift
//  MetalAudioDemo
//
//  Created by 柳钰柯 on 2021/7/19.
//

import UIKit
import AVFoundation

class AVCaptureVideoPreviewView: UIView {
    
    override func layoutSubviews() {
        layer.frame = bounds
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
}
