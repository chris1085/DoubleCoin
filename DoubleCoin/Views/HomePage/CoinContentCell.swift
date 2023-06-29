//
//  CoinContentCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import UIKit

class CoinContentCell: UITableViewCell {
  @IBOutlet var coinImageView: UIImageView!
  @IBOutlet var coinNameLabel: UILabel!
  @IBOutlet var coinNameZhLabel: UILabel!
  @IBOutlet var runChartView: UIView!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var quoteChangeLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
}
