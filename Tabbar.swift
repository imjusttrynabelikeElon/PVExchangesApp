//
//  Tabbar.swift
//  PVExchange
//
//  Created by Karon Bell on 7/9/23.
//

import Foundation
import UIKit




class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = UINavigationController(rootViewController: ProfileView())
        let vc2 = UINavigationController(rootViewController: SecondVC())
        let vc3 = UINavigationController(rootViewController: ThirdVC())
        
        vc1.title = "Home"
        vc2.title = "Pic"
        vc3.title = "Auction"
        
        vc1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), selectedImage: UIImage(systemName: ""))
        vc2.tabBarItem = UITabBarItem(title: "Flick", image: UIImage(systemName: "camera.shutter.button"), selectedImage: UIImage(named: ""))
              vc3.tabBarItem = UITabBarItem(title: "Auction", image: UIImage(systemName: "house.lodge.fill"), selectedImage: UIImage(named: ""))
    
        
        view.backgroundColor = .white
        viewControllers = [vc1,vc2,vc3]
      

    }
}
//
//
//
