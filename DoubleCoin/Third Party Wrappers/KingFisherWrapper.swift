//
//  KingFisherWrapper.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation
import Kingfisher
import UIKit

extension UIImageView {
  func loadImage(_ urlString: String?, placeHolder: UIImage? = nil) {
    guard let urlString = urlString else { return }
    let url = URL(string: urlString)
    self.kf.setImage(with: url, placeholder: placeHolder)
  }
}
