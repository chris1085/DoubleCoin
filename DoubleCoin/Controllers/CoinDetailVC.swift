//
//  CoinDetailVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/30.
//

import UIKit

class CoinDetailVC: UIViewController {
  var coinbaseWebSocketClient: CoinbaseWebSocketClient?
  @IBOutlet var sellBtn: UIButton! {
    didSet {
      sellBtn.applyPrimaryStyle()
    }
  }

  @IBOutlet var buyBtn: UIButton! {
    didSet {
      buyBtn.applyPrimaryStyle()
    }
  }

  @IBAction func butCoinTapped(_ sender: Any) {}
  @IBAction func sellCoinTapped(_ sender: Any) {}
  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
      tableView.registerCellWithNib(identifier: "LineChartMainCell", bundle: nil)
      tableView.registerCellWithNib(identifier: "BuySellPriceCell", bundle: nil)
      tableView.sectionHeaderTopPadding = 0
    }
  }

  var productID = ""
  var navTitle = ""
  override func viewDidLoad() {
    super.viewDidLoad()
    coinbaseWebSocketClient = CoinbaseWebSocketClient(productID: productID)
//    coinbaseWebSocketClient.connect()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.configureWithOpaqueBackground()
    navigationBarAppearance.backgroundColor = AppColor.primary
    navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController?.navigationBar.tintColor = UIColor.white
    navigationItem.title = navTitle
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // 重置 Navigation Bar 的外觀為預設值
    let defaultNavigationBarAppearance = UINavigationBarAppearance()
    defaultNavigationBarAppearance.configureWithTransparentBackground()
    navigationController?.navigationBar.standardAppearance = defaultNavigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = defaultNavigationBarAppearance
    navigationController?.navigationBar.tintColor = nil
  }
}

extension CoinDetailVC: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "BuySellPriceCell", for: indexPath)
      guard let buySellPriceCell = cell as? BuySellPriceCell else { return cell }

      return buySellPriceCell
    } else if indexPath.section == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartMainCell", for: indexPath)
      guard let lineChartCell = cell as? LineChartMainCell else { return cell }

      return lineChartCell
    }

    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0.1
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return UITableView.automaticDimension
    }
    return UIScreen.main.bounds.height * 0.45
  }
}
