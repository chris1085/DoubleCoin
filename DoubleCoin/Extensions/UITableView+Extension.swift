//
//  UITableView+Extension.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation
import UIKit

extension UITableView {
  func registerCellWithNib(identifier: String, bundle: Bundle?) {
    let nib = UINib(nibName: identifier, bundle: bundle)
    register(nib, forCellReuseIdentifier: identifier)
  }

  func registerHeaderWithNib(identifier: String, bundle: Bundle?) {
    let nib = UINib(nibName: identifier, bundle: bundle)
    register(nib, forHeaderFooterViewReuseIdentifier: identifier)
  }
}

extension UITableViewCell {
  static var identifier: String {
    return String(describing: self)
  }
}

extension UITableViewHeaderFooterView {
  static var identifier: String {
    return String(describing: self)
  }
}
