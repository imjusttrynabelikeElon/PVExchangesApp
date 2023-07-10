//
//  SecondVC.swift
//  PVExchange
//
//  Created by Karon Bell on 7/9/23.
//

import Foundation
import UIKit
import AVFoundation

class SecondVC: UIViewController {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoQueue = DispatchQueue(label: "videoQueue")
    private let flickButton = UIButton(type: .system)
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var imageView: UIImageView!
    private var closeButton: UIButton!
    private var cameraToggleButton: UIButton!
    private var currentCamera: AVCaptureDevice?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Pic"
        
        // Check if the device supports camera
        guard let device = AVCaptureDevice.default(for: .video) else {
            showAlert(message: "Camera Not Found")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
                
                if session.canAddOutput(photoOutput) {
                    session.addOutput(photoOutput)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.frame = view.bounds
                    view.layer.addSublayer(previewLayer)
                    
                    session.startRunning()
                } else {
                    showAlert(message: "Unable to add photo output")
                }
            } else {
                showAlert(message: "Unable to add video input")
            }
        } catch {
            showAlert(message: "Error configuring camera")
        }
        //
        
        
        // Add flick button
        flickButton.setTitle("Flick", for: .normal)
        flickButton.tintColor = .white
        
        flickButton.addTarget(self, action: #selector(didTapFlickButton), for: .touchUpInside)
        flickButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flickButton)
        
        flickButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 29)
        
        NSLayoutConstraint.activate([
            flickButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            flickButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            flickButton.widthAnchor.constraint(equalToConstant: 300),
            flickButton.heightAnchor.constraint(equalToConstant: 120),
        ])
        
        cameraToggle()
    }
    
    func cameraToggle() {
          // Add camera toggle button
          cameraToggleButton = UIButton(type: .system)
          cameraToggleButton.setImage(UIImage(systemName: "crop.rotate"), for: .normal)
          cameraToggleButton.addTarget(self, action: #selector(didTapCameraToggleButton), for: .touchUpInside)
          cameraToggleButton.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(cameraToggleButton)
          
          NSLayoutConstraint.activate([
              cameraToggleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
              cameraToggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
          ])
      }
      
      @objc func didTapCameraToggleButton() {
          session.beginConfiguration()
          
          // Remove existing input
          if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
              session.removeInput(currentInput)
          }
          
          // Get the new device
          let newCameraPosition: AVCaptureDevice.Position = (currentCamera?.position == .back) ? .front : .back
          let newCamera = getCamera(with: newCameraPosition)
          
          // Create new input
          do {
              let newInput = try AVCaptureDeviceInput(device: newCamera!)
              session.addInput(newInput)
              currentCamera = newCamera
          } catch {
              print("Error configuring new camera input: \(error.localizedDescription)")
          }
          
          session.commitConfiguration()
      }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Camera Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func getCamera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
         let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
         return discoverySession.devices.first { $0.position == position }
     }
     
    
    @objc func didTapFlickButton() {
        
        title = ""
        flickButton.setTitle("", for: .normal)
        cameraToggleButton.isHidden = true
        
        guard let videoConnection = previewLayer.connection else {
            return
        }
        
        videoConnection.videoOrientation = .portrait  // Adjust the desired orientation here
        
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// Implement AVCapturePhotoCaptureDelegate to handle captured photo
extension SecondVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Error creating image from photo data.")
            return
        }
        
        // Create and configure the image view
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: flickButton.topAnchor, constant: -20)
        ])
        
        // Create and configure the close button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("X", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    @objc func didTapCloseButton() {
        imageView.removeFromSuperview()
        closeButton.removeFromSuperview()
        title = "flick"
        flickButton.setTitle("Flick", for: .normal)
        cameraToggleButton.isHidden = false
        
    }
}
