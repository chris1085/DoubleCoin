//
//  UICollectionView+Extension.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation
import UIKit

extension UICollectionView {
  func registerCellWithNib(identifier: String, bundle: Bundle?) {
    let nib = UINib(nibName: identifier, bundle: bundle)
    register(nib, forCellWithReuseIdentifier: identifier)
  }
}
