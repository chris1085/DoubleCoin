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
  static let checkOk = UIColor(red: 91 / 255, green: 188 / 255, blue: 122 / 255, alpha: 1)
  static let checkDisabled = UIColor(red: 220 / 255, green: 95 / 255, blue: 91 / 255, alpha: 1)
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
  func formatNumber(_ number: Double, max maxDigits: Int, min minDigits: Int, isAddSep: Bool) -> String? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = maxDigits
    formatter.minimumFractionDigits = minDigits
    formatter.groupingSeparator = ","
    formatter.usesGroupingSeparator = isAddSep
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

extension String {
  func formatDateString(fromFormat: String, toFormat: String, timeZoneOffset: TimeInterval) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = fromFormat
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

    if let date = dateFormatter.date(from: self) {
      dateFormatter.dateFormat = toFormat
      dateFormatter.timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffset))
      return dateFormatter.string(from: date)
    }

    return nil
  }
}

func showOkAlert(title: String, message: String, viewController: UIViewController) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
  alertController.addAction(doneAction)
  viewController.present(alertController, animated: true, completion: nil)
}
