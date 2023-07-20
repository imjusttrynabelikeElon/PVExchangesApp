//
//  SecondVC.swift
//  PVExchange
//
//  Created by Karon Bell on 7/9/23.
//

import Foundation
import UIKit
import AVFoundation
import Photos
//
// make the photos show on the profileView blury
// and save the pictures from the collection view


struct Photo {
    let image: UIImage
    let asset: PHAsset
    let identifier: String
    let creationDate: Date?
    let location: CLLocation?
    
    init(image: UIImage, asset: PHAsset, identifier: String, creationDate: Date?, location: CLLocation?) {
        self.image = image
        self.asset = asset
        self.identifier = identifier
        self.creationDate = creationDate
        self.location = location
    }
    
}


class SecondVC: UIViewController, CLLocationManagerDelegate {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoQueue = DispatchQueue(label: "videoQueue")
    private let flickButton = UIButton(type: .system)
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let locationManager = CLLocationManager()
    static let shared = SecondVC()
    private var imageView: UIImageView!
    private var closeButton: UIButton!
    private var cameraToggleButton: UIButton!
    private var currentCamera: AVCaptureDevice?
    private var currentLocation: CLLocation?
    private var isPhotoCaptured = false
    let photoArtFrameButton = UIButton(type: .system)
    let dockArrowButton = UIButton(type: .system)
    private weak var photoCollectionView: UICollectionView?
    private var capturedAsset: PHAsset?

    
    static var photosArray: [Photo] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Pic"
        
        testLocation()
        
        
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
    
    // this is the c
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
        
        photosButton()
        dockArrowButton.isHidden = true
    }
    
    func getLocation(for asset: PHAsset, completion: @escaping (CLLocation?) -> Void) {
        guard let location = asset.location else {
            completion(nil)
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil, let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            
            let updatedLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            print("Latitude: \(updatedLocation.coordinate.latitude)")
            print("Longitude: \(updatedLocation.coordinate.longitude)")
            
            completion(updatedLocation)
        }
    }
    
    
    @objc func didTapCameraToggleButton() {
        session.beginConfiguration()
        
        // Get the new device
        let newCameraPosition: AVCaptureDevice.Position = (currentCamera?.position == .front) ? .back : .front
        let newCamera = getCamera(with: newCameraPosition)
        
        // Remove existing input
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
        }
        
        // Create new input
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera!)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                currentCamera = newCamera
            } else {
                showAlert(message: "Unable to add video input")
            }
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
    
    func photosButton() {
        // Add photo.artframe button
        let photoArtFrameButton = UIButton(type: .system)
        let buttonSize: CGFloat = 88
        let imageSize = CGSize(width: buttonSize - 40, height: buttonSize - 30) // Adjust image size as desired
        
        let originalImage = UIImage(systemName: "photo.artframe")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let resizedImage = resizeImage(originalImage, targetSize: imageSize)
        photoArtFrameButton.setImage(resizedImage, for: .normal)
        photoArtFrameButton.tintColor = .white
        photoArtFrameButton.imageView?.contentMode = .scaleAspectFit
        photoArtFrameButton.addTarget(self, action: #selector(didTapPhotoArtFrameButton), for: .touchUpInside)
        photoArtFrameButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoArtFrameButton)
        
        NSLayoutConstraint.activate([
            photoArtFrameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            photoArtFrameButton.bottomAnchor.constraint(equalTo: flickButton.topAnchor, constant: 140),
            photoArtFrameButton.widthAnchor.constraint(equalToConstant: buttonSize),
            photoArtFrameButton.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        
        let dockButtonSize: CGFloat = 130
        
        dockArrowButton.setImage(UIImage(systemName: "dock.arrow.down.rectangle"), for: .normal)
        dockArrowButton.tintColor = .white
        dockArrowButton.addTarget(self, action: #selector(didTapDockArrowButton), for: .touchUpInside)
        dockArrowButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dockArrowButton)
        
        NSLayoutConstraint.activate([
            dockArrowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38),
            dockArrowButton.bottomAnchor.constraint(equalTo: photoArtFrameButton.bottomAnchor, constant: -26),
        ])
    }
    
    func testLocation() {
        locationManager.delegate = self
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Handle location authorization denied case
        }
    }
    
    
    @objc func didTapDockArrowButton() {
        // Check if the image view is not nil and contains an image
        guard let image = imageView?.image else {
            print("Error: Image is nil.")
            return
        }

        // Assuming you have obtained the PHAsset object from some other place in your code
        guard let asset = getLastPhotoAsset() else {
            print("Error: PHAsset is nil.")
            return
        }


        // Assuming you have 'identifier', 'creationDate', and 'location' from some other place in your code
        let photo = Photo(image: image, asset: asset, identifier: asset.localIdentifier, creationDate: asset.creationDate, location: asset.location)

        // Insert the photo into the database
        SQliteDatabase.sharedInstance.insertPhoto(photo: photo)

        // Reset the view after saving the photo
        imageView?.removeFromSuperview()
        closeButton?.removeFromSuperview()
        title = "flick"
        flickButton.setTitle("Flick", for: .normal)
        cameraToggleButton.isHidden = false
        isPhotoCaptured = false
        photoArtFrameButton.isHidden = false
        dockArrowButton.isHidden = true
    }


    
    @objc func didTapPhotoArtFrameButton() {
        let photoCollectionVC = photoCollectionViewController(photosArray: SecondVC.photosArray)
        photoCollectionVC.modalTransitionStyle = .coverVertical
        photoCollectionVC.modalPresentationStyle = .fullScreen
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.down.square.fill"), style: .plain, target: nil, action: nil)
        backButton.tintColor = .black
        navigationItem.backBarButtonItem = backButton
        navigationController?.pushViewController(photoCollectionVC, animated: true)
        
        // Assign the reference of the collection view to the property
        photoCollectionView = photoCollectionVC.collectionView
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        currentLocation = location
    }
    
    
    private func savePhotoToCollection(image: UIImage) {
        guard let asset = getLastPhotoAsset() else {
            return
        }
        
        let identifier = asset.localIdentifier
        
        let date = asset.creationDate // Get the creation date from the asset
        
        let photo = Photo(image: image, asset: asset, identifier: identifier, creationDate: date, location: nil)
        
        
       
    }
    
    
    // ...
    
    
    
    func resizeImage(_ image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        let scaledSize = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: targetSize)).size
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        
        return resizedImage.withRenderingMode(.alwaysOriginal)
    }
    
    
    private func getLastPhotoAsset() -> PHAsset? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        return fetchResult.firstObject
    }
    
    @objc func didTapFlickButton() {
        guard let location = locationManager.location else {
            // Location is not available, handle the case accordingly
            return
        }
        
        guard let asset = getLastPhotoAsset() else {
            // Asset is not available, handle the case accordingly
            return
        }
        
        let identifier = asset.localIdentifier
        let date = asset.creationDate
        
        guard !isPhotoCaptured else {
            return
        }
        
        isPhotoCaptured = true
        
        title = ""
        flickButton.setTitle("", for: .normal)
        cameraToggleButton.isHidden = true
        photoArtFrameButton.isHidden = true
        dockArrowButton.isHidden = false
        
        guard let videoConnection = previewLayer.connection else {
            return
        }
        
        videoConnection.videoOrientation = .portrait  // Adjust the desired orientation here
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}



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
        
        guard let location = locationManager.location else {
            print("Location is not available.")
            return
        }
        
        guard let asset = getLastPhotoAsset() else {
            print("Asset is not available.")
            return
        }
        
        let identifier = asset.localIdentifier
        let date = asset.creationDate
        
        let capturedPhoto = Photo(image: image, asset: asset, identifier: identifier, creationDate: date, location: location)
        SecondVC.photosArray.append(capturedPhoto)
        
        // Continue with any additional processing or UI updates
        // ...
    }
    
    @objc func didTapCloseButton() {
        imageView.removeFromSuperview()
        closeButton.removeFromSuperview()
        title = "flick"
        flickButton.setTitle("Flick", for: .normal)
        cameraToggleButton.isHidden = false
        isPhotoCaptured = false
        photoArtFrameButton.isHidden = false
        dockArrowButton.isHidden = true
    }
}

