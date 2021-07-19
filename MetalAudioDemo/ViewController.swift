//
//  ViewController.swift
//  MetalAudioDemo
//
//  Created by 柳钰柯 on 2021/7/19.
//

import UIKit
import AVFoundation
import MetalKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        func addAndStartVideoView() {
            view.addSubview(avcaptureVideoPreviewView)
            view.addSubview(previewImageView)
            NSLayoutConstraint.activate([
                avcaptureVideoPreviewView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
                avcaptureVideoPreviewView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height*2/3),
                avcaptureVideoPreviewView.topAnchor.constraint(equalTo: view.topAnchor),
                avcaptureVideoPreviewView.leftAnchor.constraint(equalTo: view.leftAnchor),
                
                previewImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
                previewImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height*2/3),
                previewImageView.topAnchor.constraint(equalTo: view.topAnchor),
                previewImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            ])
            setupSession()
        }
        view.backgroundColor = .white
        view.addSubview(shotButton)
        NSLayoutConstraint.activate([
            shotButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shotButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -61-view.safeAreaInsets.bottom),
            shotButton.widthAnchor.constraint(equalToConstant: 88),
            shotButton.heightAnchor.constraint(equalToConstant: 88)
        ])
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            addAndStartVideoView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted {
                    DispatchQueue.main.async {
                        addAndStartVideoView()
                    }
                }
            })
        case .denied,.restricted:
            print("无相机权限")
        @unknown default:
            print("未知状态")
        }
    }
    
    private lazy var shotButton: UIButton = {
        let temp = UIButton()
        temp.setBackgroundImage(UIImage(named: "camera_shot_btn"), for: .normal)
        temp.addTarget(self, action: #selector(shotButtonClick), for: .touchUpInside)
        temp.translatesAutoresizingMaskIntoConstraints = false
        return temp
    }()
    
    private lazy var previewImageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFill
        temp.isHidden = true
        temp.translatesAutoresizingMaskIntoConstraints = false
        return temp
    }()
    
    private lazy var avcaptureVideoPreviewView: AVCaptureVideoPreviewView = {
        let temp = AVCaptureVideoPreviewView()
        temp.videoPreviewLayer.session = session
        temp.videoPreviewLayer.videoGravity = .resizeAspectFill
        temp.translatesAutoresizingMaskIntoConstraints = false
        return temp
    }()
    
    private lazy var recordingQueue: DispatchQueue = {
        let temp = DispatchQueue(label: "com.larry.AVCaptureSession.recordingQueue",qos: .userInteractive)
        return temp
    }()
    
    private let session = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput?
}

private extension ViewController {
    func setupSession() {
        guard let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device) else { return }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            photoOutput = output
            session.addOutput(output)
        }
        if !session.inputs.isEmpty && !session.outputs.isEmpty {
            session.startRunning()
        }
    }
    
    // MARK: objc
    @objc func shotButtonClick() {
        photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { return }
        guard let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) else { return }
        previewImageView.isHidden = false
        UIView.transition(with: previewImageView, duration: 0.3, options: .curveLinear) {
            self.previewImageView.image = image
        } completion: { _ in
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
