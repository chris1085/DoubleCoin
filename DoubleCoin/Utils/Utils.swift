//
//  Utils.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation
import UIKit

enum AppColor {
  static let primary = UIColor(red: 220 / 255, green: 95 / 255, blue: 91 / 255, alpha: 1)
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

  func formatDate(epoch: Double, dateFormat: String) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(epoch))

    let calendar = Calendar.current
    let timezone = TimeZone(secondsFromGMT: 8 * 3600) // +8 時區

    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    formatter.calendar = calendar
    formatter.timeZone = timezone

    let formattedDate = formatter.string(from: date)
    return formattedDate
  }
}
