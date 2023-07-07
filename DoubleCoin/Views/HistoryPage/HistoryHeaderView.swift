//
//  HistoryHeaderView.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/7.
//

import UIKit

protocol HistoryHeaderDelegate: AnyObject {
  func didTappedSelectedDollats()
}

class HistoryHeaderView: UIView {
  weak var delegate: HistoryHeaderDelegate?
  @IBOutlet var allDollarsBtn: UIButton!
  @IBAction func tappedSelectedDollars(_ sender: Any) {
    delegate?.didTappedSelectedDollats()
  }
}
