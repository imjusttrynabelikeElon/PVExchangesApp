//
//  photoCollectionViewController.swift
//  PVExchange
//
//  Created by Karon Bell on 7/10/23.
//
//

import UIKit
import Photos

protocol PhotoCollectionViewControllerDelegate: AnyObject {
    func photosUpdated()
}

private let reuseIdentifier = PhotoCollectionViewCell.reuseIdentifier


class photoCollectionViewController: UICollectionViewController, SQliteDatabaseDelegate {
    func photoInserted(photo: Photo) {
        photosArray.append(photo)
        collectionView.reloadData()
    }
    
    func photosUpdated() {
           // Call the delegate method to notify the parent view controller about the photo updates
           delegate?.photosUpdated()
       }
    
    // Add the delegate property
      weak var delegate: PhotoCollectionViewControllerDelegate?

    private let reuseIdentifier = "PhotoCell" // Use the same reuse identifier as in the PhotoCollectionViewCell class
    var photosArray: [Photo] = [] {
           didSet {
               collectionView.reloadData()
           }
       }
    
        // Custom initializer to receive the photosArray
    init(photosArray: [Photo]) {
        self.photosArray = photosArray.reversed()  // Reverse the photosArray
        
        // Call the designated initializer of the superclass
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

        // this is the required init
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            SQliteDatabase.sharedInstance.delegate = self // Add this line to set the delegate
            
        
        


              // Register the cell class with the reuse identifier
              collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            

            // ...
            
            // Set the delegate and data source of the collection view
            collectionView.delegate = self
            collectionView.dataSource = self
            
            // Set the navigation title
            let titleLabel = UILabel()
            titleLabel.text = "Flicks"
            titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
            titleLabel.textColor = .black
            navigationItem.titleView = titleLabel
            
            // Set the delegate and data source of the collection view
            collectionView.delegate = self
            collectionView.dataSource = self
            
            // Set the item size of the collection view flow layout
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 20, height: UIScreen.main.bounds.width / 1.3 - 73) // Adjust the size as desired
                layout.itemSize = itemSize
                layout.minimumInteritemSpacing = 8 // Adjust the spacing as desired
                layout.minimumLineSpacing = 10 // Adjust the spacing as desired
                layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Adjust the insets as desired
            }
        }
        
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)

           // Check if the database is initialized before retrieving photos
        // Check if the database is initialized before retrieving photos
          if SQliteDatabase.sharedInstance.isInitialized {
              // Database is initialized, proceed with data retrieval
              retrievePhotosAndUpdateCollectionView()
          } else {
              // Database is not yet initialized, wait for the completion handler to be called
              SQliteDatabase.sharedInstance.initializeDatabase { [weak self] success in
                  if success {
                      // Database initialized successfully, retrieve photos and update the collectionView
                      self?.retrievePhotosAndUpdateCollectionView()
                  } else {
                      // Database initialization failed, handle the error
                      // You can show an alert or any other appropriate action here
                  }
              }
          }
       }

       private func retrievePhotosAndUpdateCollectionView() {
           // Create the "photos" table if it doesn't exist
           SQliteDatabase.sharedInstance.createTable()

           // Retrieve photos from the database and update the collectionView
           let localPhotosArray = SQliteDatabase.sharedInstance.getAllPhotos().reversed()
           photosArray = Array(localPhotosArray.reversed()) // Re-reverse the collection to get the original order
           collectionView.reloadData()
       }

    
        // MARK: - Collection View Data Source
        
        override func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let photo = photosArray[indexPath.item]
            let detailViewController = PhotoDetailViewController(photo: photo)
            navigationController?.pushViewController(detailViewController, animated: true)
            
            // Save the photo to the database when selected
            SQliteDatabase.sharedInstance.insertPhoto(photo: photo)
        }
        
        
        
        
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of photos in the array: \(photosArray.count)")
        return photosArray.count
    }

        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell

        let photo = photosArray[indexPath.item]
        cell.configure(with: photo)
        print("Cell at indexPath: \(indexPath)")


        return cell
    }
        // MARK: - Action
        
        @objc func didTapBackButton() {
            navigationController?.popViewController(animated: true)
        }
    }
    
class PhotoCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PhotoCell"
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureImageView()
    }
    // this is the amount
    // go to the collectionViewTime
    // goToTheAmountofDidTapBackButton
    // goToTheAmountTheTheirIsTheFrontButton
    // goToThisAmountTheAmountOfVibeItTakesTo
    
    
    // thisIsforcollectionThis
    // thisShowsThisAmount
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

       
    }

    
    func configure(with photo: Photo) {
        // Set a placeholder image before the actual image is fetched
        
        // Set the imageView's image to the photo.image
        imageView.image = photo.image

        // You can remove the print statement here, as it's not needed anymore
        // Since the image is not fetched from the asset, there won't be any "Failed to load image for photo" message
        print("Configuring cell with photo: \(photo)")
    }

}

