//
//  HistoryVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/7.
//

import UIKit

class HistoryVC: UIViewController {
  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
      tableView.registerCellWithNib(identifier: "TradeRecordCell", bundle: nil)
      tableView.sectionHeaderTopPadding = 0
    }
  }

  @IBOutlet var switchingDollarsBtn: UIButton! {
    didSet {
      switchingDollarsBtn.setTitle("\(selectedDollars) ▼", for: .normal)
    }
  }

  @IBAction func switchDollars(_ sender: Any) {
    guard let dollarsSheetVC = storyboard?.instantiateViewController(withIdentifier: "DollarsSheetVC")
      as? DollarsSheetVC else { return }
    if let sheetPresentationController = dollarsSheetVC.sheetPresentationController {
      sheetPresentationController.detents = [.medium()]
      sheetPresentationController.preferredCornerRadius = 24
    }
    dollarsSheetVC.dollarsNames = dollarsNames
    dollarsSheetVC.dollarsNames.insert("所有幣種", at: 0)
    dollarsSheetVC.selectedDollars = selectedDollars
    dollarsSheetVC.delegate = self

    present(dollarsSheetVC, animated: true)
  }

  @IBOutlet var noRecordsView: UIView! {
    didSet {
      noRecordsView.isHidden = true
    }
  }

  @IBOutlet var historyHeaderView: HistoryHeaderView!
  private var allOrders: [Order] = []
  private var filteredOrders: [Order] = []
  var dollarsNames: [String] = []
  var selectedDollars = "所有幣種"
  var productID = ""
  var filterProdcutId = ""

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getOrders()
    getAccounts()
    setNavigationBar(true)
    tabBarController?.tabBar.isHidden = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    setNavigationBar(false)
  }

  private func getOrders() {
    ApiManager.shared.getOrders(productId: productID, limits: 100) { [weak self] orders in
      guard let orders = orders else { return }
      self?.allOrders = orders
      self?.filteredOrders = self?.filterProdcutId == ""
        ? orders
        : orders.filter { $0.productID == self?.filterProdcutId }

      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
  }

  private func getAccounts() {
    ApiManager.shared.getAccounts { [weak self] accounts in
      for account in accounts {
        self?.dollarsNames.append(account.currency)
      }
    }
  }

  private func setNavigationBar(_ isNeededRest: Bool) {
    let navigationBarAppearance = UINavigationBarAppearance()

    if isNeededRest {
      navigationBarAppearance.configureWithOpaqueBackground()
      navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
      navigationController?.navigationBar.tintColor = UIColor.black
      navigationItem.title = "資產紀錄"
    } else {
      navigationBarAppearance.configureWithTransparentBackground()
      navigationController?.navigationBar.tintColor = nil
    }

    navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController?.navigationBar.tintColor = UIColor.black
  }
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    filteredOrders.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TradeRecordCell", for: indexPath)
    guard let tradeRecordCell = cell as? TradeRecordCell else { return cell }
    tradeRecordCell.selectionStyle = .none

    tradeRecordCell.configureCell(order: filteredOrders[indexPath.row])

    return tradeRecordCell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let orderId = filteredOrders[indexPath.row].id
    guard let tradeResultVC = storyboard?.instantiateViewController(withIdentifier: "TradeResultVC")
      as? TradeResultVC else { return }

    tradeResultVC.isButtonHidden = true
    tradeResultVC.orderId = orderId

    navigationController?.pushViewController(tradeResultVC, animated: true)
  }
}

extension HistoryVC: DollarsSheetVCDelegate {
  func didSelectDollar(dollarName: String) {
    if dollarName == "所有幣種" {
      filteredOrders = allOrders
    } else {
      filteredOrders = allOrders.filter { $0.productID == "\(dollarName)-USD" }
    }

    noRecordsView.isHidden = filteredOrders.count != 0 ? true : false

    selectedDollars = dollarName
    switchingDollarsBtn.setTitle("\(selectedDollars) ▼", for: .normal)
    tableView.reloadData()
  }
}
