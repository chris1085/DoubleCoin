//
//  TradeRecordCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/1.
//

import UIKit

class TradeRecordCell: UITableViewCell {
  @IBOutlet var tradeWayLabel: UILabel! {
    didSet {
      tradeWayLabel.textColor = UIColor.white
    }
  }

  @IBOutlet var tradeWayView: UIView! {
    didSet {
      tradeWayView.layer.cornerRadius = 4
    }
  }

  @IBOutlet var tradeTimeLabel: UILabel!
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var sizeLabel: UILabel!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var statusLabel: UILabel!
  @IBOutlet var statusLightView: UIView! {
    didSet {
      statusLightView.layer.cornerRadius = statusLightView.bounds.height / 2
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func configureCell(order: Order) {
    tradeWayLabel.text = order.side.uppercased()
    tradeWayView.backgroundColor = SideInfo(rawValue: order.side)?.color
    tradeTimeLabel.text = dateFormat(dateString: order.doneAt) != nil ? dateFormat(dateString: order.doneAt) : ""
    let productName = String(order.productID.prefix(while: { $0 != "-" }))
    if let description = SideInfo(rawValue: order.side)?.description {
      descriptionLabel.text = "\(description)\(productName)"
    } else {
      descriptionLabel.text = "\(productName)"
    }
    statusLightView.backgroundColor = StatusInfo.success.color
    statusLabel.text = StatusInfo.success.description
    guard let usdPrice = Double(order.executedValue)?.formatNumber(Double(order.executedValue)!,
                                                                   max: 6, min: 0, isAddSep: true)
    else {
      priceLabel.text = order.executedValue
      return
    }
    sizeLabel.text = order.size
    priceLabel.text = usdPrice
  }

  private func dateFormat(dateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    dateFormatter.timeZone = TimeZone(identifier: "GMT+8")

    if let date = dateFormatter.date(from: dateString) {
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
      let formattedDate = dateFormatter.string(from: date)
      return formattedDate
    } else {
      print("Invalid date string")
      return nil
    }
  }
}
