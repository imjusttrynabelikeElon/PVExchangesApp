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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = username
        
        configureProfileImageView()
        configurePlusSignImageView()
    }
    
    private func configureProfileImageView() {
        let profileImageSize: CGFloat = 103
        let titleLabelHeight: CGFloat = 30 // Adjust this value as needed

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: titleLabelHeight))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        let profileImageViewY = titleLabel.frame.origin.y + titleLabel.frame.size.height + 20 // Adjust the vertical spacing as needed
        profileImageView.frame = CGRect(x: 143, y: 133, width: profileImageSize, height: profileImageSize)
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

    @objc private func profileImageViewTapped() {
        // Handle profileImageView tapped event here
        print("Profile image view tapped")
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


}


