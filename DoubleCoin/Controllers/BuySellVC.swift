//
//  BuySellVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/4.
//

import UIKit

class BuySellVC: UIViewController {
  @IBOutlet var headerView: UIView! {
    didSet {
      headerView.backgroundColor = AppColor.primary
    }
  }

  @IBAction func tappedCancelBtn(_ sender: Any) {
    dismiss(animated: true)
  }

  @IBOutlet var cancelBtn: UIButton! {
    didSet {
      cancelBtn.tintColor = UIColor.white
    }
  }

  @IBOutlet var headerLabel: UILabel! {
    didSet {
      headerLabel.textColor = UIColor.white
    }
  }

  @IBOutlet var perExchangeRateLabel: UILabel!
  @IBOutlet var exchangeRateView: UIView! {
    didSet {
      exchangeRateView.layer.cornerRadius = 4
      exchangeRateView.layer.shadowColor = UIColor.black.cgColor
      exchangeRateView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
      exchangeRateView.layer.shadowOpacity = 0.15
      exchangeRateView.layer.shadowRadius = 4.0
    }
  }

  @IBOutlet var exchangeRateInfoLabel: UILabel!
  @IBOutlet var tradeBtn: UIButton! {
    didSet {
      tradeBtn.layer.cornerRadius = 6
      tradeBtn.backgroundColor = AppColor.primary
      tradeBtn.setTitleColor(UIColor.white, for: .normal)
    }
  }

  var side = ""
  var productID = ""

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = AppColor.secondary
  }
}
