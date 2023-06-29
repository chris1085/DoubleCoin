//
//  ViewController.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
//    ApiManager.shared.getUserProfile()
//    ApiManager.shared.getAccounts()
//    ApiManager.shared.getProducts()
//    ApiManager.shared.getCurrencies()
//    ApiManager.shared.getProductCandles()
  }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}
