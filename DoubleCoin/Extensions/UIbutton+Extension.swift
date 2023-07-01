//
//  UIbutton+Extension.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/30.
//

import Foundation
import UIKit

extension UIButton {
  func applyPrimaryStyle() {
    if #available(iOS 15.0, *) {
      var config = UIButton.Configuration.plain()
      config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
      self.configuration = config

    } else {
      // Fallback for earlier iOS versions
      contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    layer.cornerRadius = 4
    backgroundColor = AppColor.primary
    setTitleColor(UIColor.white, for: .normal)
  }
}
