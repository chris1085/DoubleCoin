//
//  AccountTableCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/6.
//

import Kingfisher
import UIKit

class AccountTableCell: UITableViewCell {
  @IBOutlet var coinImageView: UIImageView! {
    didSet {
      coinImageView.layer.cornerRadius = coinImageView.bounds.height / 2
    }
  }

  @IBOutlet var coinNameLabel: UILabel!
  @IBOutlet var coinBalanceLabel: UILabel!
  @IBOutlet var coinAmountLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func configureCell(data: AccountNT) {
    let lowercaseCurrency = data.currency.lowercased()
    let coinIconUrl = "https://cryptoicons.org/api/icon/\(lowercaseCurrency)/200"
    print(coinIconUrl)
    coinImageView.image = UIImage(named: lowercaseCurrency)
//    DispatchQueue.main.async {
//      self.coinImageView.loadImage(coinIconUrl)
//    }
//    coinImageView.loadImage(coinIconUrl)
    coinNameLabel.text = data.currency
    coinBalanceLabel.text = data.balance
    coinAmountLabel.text = "≈NT$ \(data.twd)"
  }

//  private func getIconUrl(imageView: UIImageView, for coinCode: String) {
//    let lowercased = coinCode.lowercased()
//    let coinIconUrl = "https://cryptoicons.org/api/icon//(lowercased)/200"
//    imageView.kf.setImage(with: URL(string: coinIconUrl))
//  }
}
