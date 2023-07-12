//
//  PhotoDetailViewController.swift
//  PVExchange
//
//  Created by Karon Bell on 7/10/23.
//

import UIKit
import Photos
import CoreLocation

class PhotoDetailViewController: UIViewController {
    let photo: Photo
  
    
    init(photo: Photo) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Configure the view controller with the photo data
        // Example: Display the photo image in an image view
        let imageView = UIImageView(image: photo.image)
        imageView.contentMode = .scaleAspectFit
        
        let imageViewHeight: CGFloat = 730 // Adjust the height as desired
        imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: imageViewHeight - 63)
        imageView.center = view.center
        imageView.autoresizingMask = [.flexibleWidth]
        view.addSubview(imageView)
        
        // Print the asset location
           print("Asset Location: \(photo.asset.location)")
           
           // Call the method to retrieve photo metadata
        getPhotoMetadata(for: photo) { [weak self] photoMetadata in
            // Handle the photo metadata
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
       
      }

      override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
          super.touchesEnded(touches, with: event)

          if let touch = touches.first {
              let touchPoint = touch.location(in: view)

              if view.bounds.contains(touchPoint) {
                  showActionSheet()
              }
          }
      }
    
    private func showActionSheet() {
        let loadingAlert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
        present(loadingAlert, animated: true)

        // Pass the photo asset to the getPhotoMetadata method
        getPhotoMetadata(for: photo) { [weak self] photoMetadata in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    if let photoMetadata = photoMetadata {
                        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

                        // Add the first row with the city, date, and time
                        let metadataActionTitle = "City: \(photoMetadata.city), Date: \(photoMetadata.date), Time: \(photoMetadata.time)"
                        let metadataAction = UIAlertAction(title: metadataActionTitle, style: .default) { [weak self] _ in
                            // Handle metadata action
                        }
                        actionSheet.addAction(metadataAction)

                        // Change the tint color of the title text for the first row
                        metadataAction.setValue(UIColor.black, forKey: "titleTextColor")

                        // Add the second row
                        let row2Action = UIAlertAction(title: "Delete flick", style: .default) { [weak self] _ in
                            // Handle row 2 action
                        }
                        actionSheet.addAction(row2Action)

                        // Change the tint color of the title text for the second row
                        row2Action.setValue(UIColor.black, forKey: "titleTextColor")

                        // Add the third row
                        let row3Action = UIAlertAction(title: "Send to auction", style: .default) { [weak self] _ in
                            // Handle row 3 action
                        }
                        actionSheet.addAction(row3Action)

                        // Change the tint color of the title text for the third row
                        row3Action.setValue(UIColor.black, forKey: "titleTextColor")

                        // Print the action sheet contents
                        self?.printActionSheetContents(actionSheet)

                        // Present the action sheet on the main thread
                        DispatchQueue.main.async {
                            self?.present(actionSheet, animated: true, completion: nil)
                        }
                    } else {
                        // Handle case where photo metadata is nil
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to retrieve photo metadata", preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                        errorAlert.addAction(dismissAction)
                        self?.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        }
    }



    private func printActionSheetContents(_ actionSheet: UIAlertController) {
        print("Action Sheet Contents:")
        print("Title: \(actionSheet.title ?? "")")
        
        for action in actionSheet.actions {
            print("Action: \(action.title ?? "")")
        }
    }

    
    func getPhotoMetadata(for photo: Photo, completion: @escaping (PhotoMetadata?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateFormatter.timeZone = TimeZone.current
        let date = dateFormatter.string(from: photo.creationDate ?? Date())

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"  // Use "h:mm a" format for displaying time
        let time = timeFormatter.string(from: Date())  // Get the current time when the user saves the photo

        if let location = photo.location {
            // Location is available, directly retrieve the city using reverse geocoding
            getLocationString(from: location) { city in
                let photoMetadata = PhotoMetadata(date: date, time: time, city: city ?? "Unknown", latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                completion(photoMetadata)
            }
        } else {
            // If location is not available, set the city as "Unknown"
            let photoMetadata = PhotoMetadata(date: date, time: time, city: "Unknown", latitude: 0, longitude: 0)
            completion(photoMetadata)
        }
    }






 
    func getLocationString(from location: CLLocation?, completion: @escaping (String?) -> Void) {
        guard let location = location else {
            completion(nil)
            return
        }
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error:", error)
            }
            
            // Rest of the code...
        

            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }

            // Rest of the code...
        
            
            let locationString = placemark.locality ?? placemark.administrativeArea ?? placemark.country
            completion(locationString)
        }
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
            completion(updatedLocation)
        }
    }
    
}
    
    extension Date {
        func toLocalTime() -> Date {
            let timeZone = TimeZone.current
            let seconds = TimeInterval(timeZone.secondsFromGMT(for: self))
            return Date(timeInterval: seconds, since: self)
        }
    }
    
       
    

struct PhotoMetadata {
    let date: String
    let time: String
    var city: String
    let latitude: Double
    let longitude: Double
    
    var displayString: String {
        return "City: \(city)\nDate: \(date)\nTime: \(time)"
    }
}



    
    

