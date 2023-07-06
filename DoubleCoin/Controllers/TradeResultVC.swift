//
//  TradeResultVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/5.
//

import UIKit

class TradeResultVC: BaseViewController {
  @IBOutlet var headerView: UIView! {
    didSet {
      headerView.backgroundColor = AppColor.primary
    }
  }

  @IBOutlet var contentView: UIView! {
    didSet {
      contentView.layer.cornerRadius = 8
      contentView.layer.shadowColor = UIColor.black.cgColor
      contentView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
      contentView.layer.shadowOpacity = 0.15
      contentView.layer.shadowRadius = 4.0
    }
  }

  @IBOutlet var sideView: UIView! {
    didSet {
      sideView.backgroundColor = AppColor.success
      sideView.layer.cornerRadius = 6
    }
  }

  @IBOutlet var sideLabel: UILabel! {
    didSet {
      sideLabel.textColor = UIColor.white
      sideLabel.text = "BUY"
    }
  }

  @IBOutlet var orderInfoLabel: UILabel! {
    didSet {
      orderInfoLabel.text = "\u{24D8} 訂單相關問題，請撥打客服專線"
    }
  }

  @IBOutlet var stackViewContentLabel: UILabel! {
    didSet {
      stackViewContentLabel.sizeToFit()
    }
  }

  @IBOutlet var walletBtn: UIButton! {
    didSet {
      walletBtn.layer.cornerRadius = 8
      walletBtn.backgroundColor = UIColor.gray
      walletBtn.setTitleColor(UIColor.white, for: .normal)
    }
  }

  @IBAction func tappedToWallet(_ sender: Any) {
    if let tabBarController = presentingViewController as? UITabBarController {
      let desiredIndex = 1

      if desiredIndex >= 0 && desiredIndex < tabBarController.viewControllers?.count ?? 0 {
        tabBarController.selectedIndex = desiredIndex
      }

      UIView.animate(withDuration: 1) {
        self.dismiss(animated: false, completion: nil)
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = AppColor.secondary
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNavigationBar(true)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    setNavigationBar(false)
  }

  private func setNavigationBar(_ isNeededRest: Bool) {
    let navigationBarAppearance = UINavigationBarAppearance()

    if isNeededRest {
      navigationBarAppearance.configureWithOpaqueBackground()
      navigationBarAppearance.backgroundColor = AppColor.primary
      navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
      navigationController?.navigationBar.tintColor = UIColor.white
      navigationBarAppearance.shadowColor = .clear
      navigationItem.backButtonTitle = " "
      navigationItem.title = "訂單詳情"
    } else {
      navigationBarAppearance.configureWithTransparentBackground()
      navigationController?.navigationBar.tintColor = nil
    }

    navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController?.navigationBar.tintColor = UIColor.white
  }
}
