//
//  TradeRecordHeaderView.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/1.
//

import UIKit

class TradeRecordHeaderView: UIView {
  @IBOutlet var contentView: UIView! {
    didSet {
      contentView.layer.backgroundColor = AppColor.secondary.cgColor
    }
  }

  @IBAction func showRecordsTapped(_ sender: Any) {
    didTappedShowRecords!()
  }

  @IBOutlet var allRecordsBtn: UIButton!
  var didTappedShowRecords: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    loadNib()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadNib()
  }

  func loadNib() {
    Bundle.main.loadNibNamed("TradeRecordHeaderView", owner: self)

    addSubview(contentView)
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
}
