//
//  TabBarVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/10.
//

import UIKit

class TabBarVC: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let topBorder = CALayer()
    topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1)
    topBorder.backgroundColor = UIColor.separator.cgColor
    tabBar.layer.addSublayer(topBorder)
  }
}
