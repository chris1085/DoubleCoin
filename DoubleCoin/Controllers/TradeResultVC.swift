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

  @IBOutlet var sizeLabel: UILabel!
  @IBOutlet var createdAtLabel: UILabel!
  @IBOutlet var doneAtLabel: UILabel!
  @IBOutlet var unitPriceLabel: UILabel!
  @IBOutlet var amountLabel: UILabel!
  var isButtonHidden = false
  var orderId = ""
  private var order: Order?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = AppColor.secondary
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNavigationBar(true)
    walletBtn.isHidden = isButtonHidden
    getData {}
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    setNavigationBar(false)
  }

  private func getData(completion: @escaping () -> Void) {
    if orderId != "" {
      ApiManager.shared.getSingleOrder(orderId: orderId) { [weak self] order in
        guard let order = order,
              let productInfo = ProductInfo.fromTableStatName(order.productID) else { return }
        DispatchQueue.main.async {
          self?.sideView.backgroundColor = order.side == "buy" ? AppColor.success : AppColor.primary
          self?.sideLabel.text = order.side.uppercased()
          self?.sizeLabel.text = "\(order.size) \(productInfo.name)"
          let timeZoneOffset: TimeInterval = 8 * 3600
          let fromFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSS'Z'"
          let toFormat = "yyyy-MM-dd HH:mm:ss"
          self?.createdAtLabel.text = order.createdAt.formatDateString(
            fromFormat: fromFormat, toFormat: toFormat, timeZoneOffset: timeZoneOffset)!
          self?.doneAtLabel.text = order.doneAt.formatDateString(
            fromFormat: fromFormat, toFormat: toFormat, timeZoneOffset: timeZoneOffset)!

          let price = Double(order.executedValue)
          let fee = Double(order.fillFees)
          let size = Double(order.size)
          guard let price = price, let fee = fee, let size = size else { return }
          let unitPrice = (price - fee) / size
          let unitPriceText = unitPrice.formatNumber(unitPrice, max: 8, min: 2, isAddSep: true)
          guard let unitPriceText = unitPriceText else { return }
          self?.unitPriceLabel.text = "USD \(unitPriceText)"
          self?.amountLabel.text = "USD \(String(price.formatNumber(price, max: 8, min: 2, isAddSep: true)!))"
//          self?.amountLabel.text = "USD \(order.executedValue)"
        }
      }
    }
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