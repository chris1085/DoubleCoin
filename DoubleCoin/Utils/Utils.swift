//
//  Utils.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation
import UIKit

enum AppColor {
  static let primary = UIColor(red: 233 / 255, green: 74 / 255, blue: 80 / 255, alpha: 1)
  static let secondary = UIColor(red: 250 / 255, green: 250 / 255, blue: 250 / 255, alpha: 1)
  static let success = UIColor(red: 33 / 255, green: 168 / 255, blue: 121 / 255, alpha: 1)
}

class ShadowView: UIView {
  override func awakeFromNib() {
    super.awakeFromNib()
    configureView()
  }

  func configureView() {
    layer.cornerRadius = 4
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 1.0)
    layer.shadowOpacity = 0.05
    layer.shadowRadius = 4.0
  }
}

extension Double {
  func formatNumber(_ number: Double) -> String? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2

    return formatter.string(from: NSNumber(value: number))
  }
}
