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
      tableView.registerCellWithNib(identifier: "TradeRecordCell", bundle: nil)
      tableView.sectionHeaderTopPadding = 0
    }
  }

  var productID = ""
  var navTitle = ""
  var orders: [Order] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    coinbaseWebSocketClient = CoinbaseWebSocketClient(productID: productID)
    coinbaseWebSocketClient?.delegate = self
//    coinbaseWebSocketClient.connect()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    ApiManager.shared.getOrders(productId: productID) { [weak self] orders in
      guard let orders = orders else { return }
      self?.orders = orders

      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
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
      navigationItem.title = navTitle
    } else {
      navigationBarAppearance.configureWithTransparentBackground()
      navigationController?.navigationBar.tintColor = nil
    }

    navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController?.navigationBar.tintColor = UIColor.white
  }
}

extension CoinDetailVC: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    3
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 2 {
      return orders.count
    }
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "BuySellPriceCell", for: indexPath)
      guard let buySellPriceCell = cell as? BuySellPriceCell else { return cell }
      buySellPriceCell.selectionStyle = .none

      return buySellPriceCell
    } else if indexPath.section == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartMainCell", for: indexPath)
      guard let lineChartCell = cell as? LineChartMainCell else { return cell }
      lineChartCell.selectionStyle = .none

      return lineChartCell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "TradeRecordCell", for: indexPath)
      guard let tradeRecordCell = cell as? TradeRecordCell else { return cell }
      tradeRecordCell.selectionStyle = .none

      tradeRecordCell.configureCell(order: orders[indexPath.row])

      return tradeRecordCell
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 1 {
      return UIScreen.main.bounds.height * 0.45
    }
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 2 {
      let headerView = TradeRecordHeaderView()
      return headerView
    }

    return nil
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 2 {
      return 48
    }
    return CGFloat.leastNormalMagnitude
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
}

extension CoinDetailVC: WebSocketReceiveDelegate {
  func didReceiveTickerData(buyPrice: String, sellPrice: String) {
    guard let formattedBuyPrice = Double(buyPrice)?.formatNumber(Double(buyPrice)!),
          let formattedSellPrice = Double(sellPrice)?.formatNumber(Double(sellPrice)!)
    else {
      return
    }

    let visibleCells = tableView.visibleCells
    for cell in visibleCells {
      if let cellIdentifier = cell.reuseIdentifier,
         cellIdentifier == "BuySellPriceCell",
         let buySellCell = cell as? BuySellPriceCell
      {
        buySellCell.sellLabel.text = formattedBuyPrice
        buySellCell.buyLabel.text = formattedSellPrice
      }
    }
  }
}
