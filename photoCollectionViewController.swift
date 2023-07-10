//
//  photoCollectionViewController.swift
//  PVExchange
//
//  Created by Karon Bell on 7/10/23.
//

import UIKit

private let reuseIdentifier = PhotoCollectionViewCell.reuseIdentifier


class photoCollectionViewController: UICollectionViewController {
    private let reuseIdentifier = PhotoCollectionViewCell.reuseIdentifier
    var photosArray: [Photo] = []  // Update the access level to internal or public
        
    // Custom initializer to receive the photosArray
       init(photosArray: [Photo]) {
           self.photosArray = photosArray
           
           // Call the designated initializer of the superclass
           super.init(collectionViewLayout: UICollectionViewFlowLayout())
       }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.down.square.fill"), style: .plain, target: self, action: #selector(didTapBackButton))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
     

        // Set the delegate and data source of the collection view
          collectionView.delegate = self
          collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    // MARK: - Collection View Data Source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return photosArray.count
        
       }

       override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell

           let photo = photosArray[indexPath.item]
           cell.configure(with: photo)

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
        imageView.image = photo.image
    }
}
