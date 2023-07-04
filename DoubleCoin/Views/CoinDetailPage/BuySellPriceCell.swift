//
//  BuySellPriceCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/1.
//

import UIKit

class BuySellPriceCell: UITableViewCell {

  @IBOutlet weak var sellLabel: UILabel!
  @IBOutlet weak var buyLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
