//
//  FirstVC.swift
//  PVExchange
//
//  Created by Karon Bell on 7/9/23.
//

import Foundation
import UIKit


class ProfileView: UIViewController {
    let username = "KaronB"
    let profileImageView = UIImageView()
    let flicksCount: Int = 2300000 // Example value, modify as needed
    let auctionedFlicksCount: Int = 100000 // Example value, modify as needed
    
    // Declare flicksLabel as a property
    lazy var flicksLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 47, y: 311, width: self.view.bounds.width/2, height: 20))
        label.text = "Flicks"
        label.textAlignment = .left
        return label
    }()
    
    // Declare auctionedFlicksLabel as a property
    lazy var auctionedFlicksLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 165, y: 311, width: self.view.bounds.width/2, height: 20))
        label.text = "AuctionedFlicks"
        label.textAlignment = .right
        return label
    }()
    
    lazy var greyLineView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: profileImageView.frame.origin.y + profileImageView.frame.size.height + 130, width: self.view.bounds.width, height: 1))
        view.backgroundColor = .lightGray
        return view
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = username
        
        configureProfileImageView()
        configurePlusSignImageView()
        configureFlicksCountLabel()
        configureAuctionedFlicksCountLabel()
        configureGreyLine()
       
    }

    private func configureProfileImageView() {
        let profileImageSize: CGFloat = 103
        let titleLabelHeight: CGFloat = 30 // Adjust this value as needed

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleLabelHeight))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        view.addSubview(flicksLabel)
        view.addSubview(auctionedFlicksLabel)

        let profileImageViewY = view.bounds.height/2 - profileImageSize/2 - 20 // Adjust the vertical spacing as needed
        profileImageView.frame = CGRect(x: 143, y: 143, width: profileImageSize, height: profileImageSize)
        profileImageView.layer.cornerRadius = profileImageSize / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .lightGray
        view.addSubview(profileImageView)

        // Add tap gesture recognizer to the profileImageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
    }

    private func configurePlusSignImageView() {
        let plusSignImage = UIImage(systemName: "plus.circle.fill")
        let plusSignSize: CGFloat = 30
        
        let plusSignImageView = UIImageView(frame: CGRect(x: profileImageView.frame.origin.x + profileImageView.frame.size.width - plusSignSize, y: profileImageView.frame.origin.y + profileImageView.frame.size.height - plusSignSize, width: plusSignSize, height: plusSignSize))
        plusSignImageView.image = plusSignImage
        plusSignImageView.contentMode = .scaleAspectFit
        plusSignImageView.tintColor = .blue
        
        view.addSubview(plusSignImageView)
    }

    private func configureFlicksCountLabel() {
        let flicksCountLabel = UILabel(frame: CGRect(x: flicksLabel.frame.origin.x - 76, y: flicksLabel.frame.origin.y + flicksLabel.frame.size.height + 10, width: flicksLabel.frame.size.width, height: 20))
        flicksCountLabel.textAlignment = .center
        flicksCountLabel.textColor = .systemTeal
        flicksCountLabel.text = "\(flicksCount)" // Display the flicks count
        view.addSubview(flicksCountLabel)
    }
    
    private func configureAuctionedFlicksCountLabel() {
        let auctionedFlicksCountLabel = UILabel(frame: CGRect(x: auctionedFlicksLabel.frame.origin.x + 37, y: auctionedFlicksLabel.frame.origin.y + auctionedFlicksLabel.frame.size.height + 10, width: auctionedFlicksLabel.frame.size.width, height: 20))
        auctionedFlicksCountLabel.textAlignment = .center
        auctionedFlicksCountLabel.textColor = .systemTeal
        auctionedFlicksCountLabel.text = "\(auctionedFlicksCount)" // Display the auctioned flicks count
        view.addSubview(auctionedFlicksCountLabel)
    }
    
    private func configureGreyLine() {
        view.addSubview(greyLineView)
    }
    

    @objc private func profileImageViewTapped() {
        // Handle profileImageView tapped event here
        print("Profile image view tapped")
    }
}
