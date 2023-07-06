//
//  BaseViewController.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/6.
//

import UIKit

class BaseViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//    backItem.title = ""
    navigationItem.backBarButtonItem = backItem
  }
}
