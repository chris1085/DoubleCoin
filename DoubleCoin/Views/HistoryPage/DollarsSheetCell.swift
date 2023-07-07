//
//  DollarsSheetCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/7.
//

import UIKit

class DollarsSheetCell: UITableViewCell {
  @IBOutlet var dollarImageView: UIImageView!
  @IBOutlet var dollarNameLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  func configureCell(name: String, selectedDollars: String) {
    let lowercaseName = name.lowercased()

    dollarImageView.image = name == "所有幣種" ? UIImage(named: "coin") : UIImage(named: "\(lowercaseName)-black")
    dollarNameLabel.text = name

    accessoryType = name == selectedDollars ? .checkmark : .none
    tintColor = .black
  }
}
