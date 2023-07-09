//
//  BuySellVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/4.
//

import UIKit

class BuySellVC: UIViewController {
  var coinbaseWebSocketClient: CoinbaseWebSocketClient?
  @IBOutlet var headerView: UIView! {
    didSet {
      headerView.backgroundColor = AppColor.primary
    }
  }

  @IBAction func tappedCancelBtn(_ sender: Any) {
    coinbaseWebSocketClient?.socket.disconnect()
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

  @IBOutlet var sourceUnitLabel: UILabel! {
    didSet {
      sourceUnitLabel.textColor = UIColor.white
    }
  }

  @IBOutlet var unitPriceLabel: UILabel! {
    didSet {
      unitPriceLabel.textColor = UIColor.white
    }
  }

  @IBOutlet var unitLabel: UILabel! {
    didSet {
      unitLabel.textColor = UIColor.white
    }
  }

  @IBOutlet var sourceImageView: UIImageView! {
    didSet {
      sourceImageView.layer.cornerRadius = sourceImageView.bounds.height / 2
    }
  }

  @IBOutlet var sourceCoinLabel: UILabel!
  @IBOutlet var sourceTitleLabel: UILabel! {
    didSet {
      sourceTitleLabel.textColor = UIColor.secondaryLabel
    }
  }

  @IBOutlet var sourcePriceTextField: UITextField! {
    didSet {
      sourcePriceTextField.borderStyle = .none
      sourcePriceTextField.textColor = UIColor.secondaryLabel
      sourcePriceTextField.isUserInteractionEnabled = false
      sourcePriceTextField.delegate = self
    }
  }

  @IBAction func tappedChangeCoinBtn(_ sender: Any) {
    isSourceEditable = !isSourceEditable
    sourcePriceTextField.isUserInteractionEnabled = isSourceEditable
    originPriceTextField.isUserInteractionEnabled = !isSourceEditable

    if isSourceEditable {
      sourcePriceTextField.textColor = UIColor.black
      sourceTitleLabel.textColor = UIColor.black
      originPriceTextField.textColor = UIColor.secondaryLabel
      originTitleLabel.textColor = UIColor.secondaryLabel

    } else {
      sourcePriceTextField.textColor = UIColor.secondaryLabel
      sourceTitleLabel.textColor = UIColor.secondaryLabel
      originPriceTextField.textColor = UIColor.black
      originTitleLabel.textColor = UIColor.black
    }
  }

  @IBOutlet var originImageView: UIImageView! {
    didSet {
      originImageView.layer.cornerRadius = originImageView.bounds.height / 2
    }
  }

  @IBOutlet var originCoinLabel: UILabel!
  @IBOutlet var originTitleLabel: UILabel!
  @IBOutlet var originPriceTextField: UITextField! {
    didSet {
      originPriceTextField.borderStyle = .none
      originPriceTextField.delegate = self
    }
  }

  @IBOutlet var exchangeRateView: UIView! {
    didSet {
      exchangeRateView.layer.cornerRadius = 8
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

  @IBAction func tappedTradeBtn(_ sender: Any) {
    coinbaseWebSocketClient?.socket.disconnect()

    guard let sourcePriceText = sourcePriceTextField.text,
          let sourcePrice = Double(sourcePriceText)
    else {
      showOkAlert(title: "交易失敗", message: "請重新確認交易金額", viewController: self)
      return
    }

    if sourcePrice == 0.0 {
      showOkAlert(title: "交易失敗", message: "請重新確認交易金額", viewController: self)
    }

    ApiManager.shared.createOrder(size: sourcePriceText, side: side, productId: productID) { [weak self] orderInfo in
      self?.orderInfo = orderInfo
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      guard let orderInfo = self.orderInfo else { return }
      guard let tradeResultVC = self.storyboard?.instantiateViewController(withIdentifier: "TradeResultVC")
        as? TradeResultVC else { return }

      tradeResultVC.isButtonHidden = false
      tradeResultVC.orderId = orderInfo.id

      self.navigationController?.pushViewController(tradeResultVC, animated: true)
    }
  }

  @IBOutlet var exchangeRateInfoView: UIView! {
    didSet {
      exchangeRateInfoView.backgroundColor = AppColor.secondary
    }
  }

  @IBAction func tappedMaxBtn(_ sender: Any) {
    if accountBalance != "" {
      let unitPrice = Double(unitPriceLabel.text ?? "0")!
      let sourcePrice = Double(accountBalance)!
      let price = unitPrice * sourcePrice
      originPriceTextField.text = String(price)
      sourcePriceTextField.text = sourcePrice.formatNumber(sourcePrice, max: 8, min: 2, isAddSep: false)
      isSourceEditable = true
    }
  }

  var side = ""
  var productID = ""
  private var isSourceEditable = false
  var bestBid = ""
  var bestAsk = ""
  var sourcePrice: Double = 0
  var originPrice: Double = 0
  var accountBalance = ""
  var orderInfo: OrderPost?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = AppColor.secondary

    coinbaseWebSocketClient = CoinbaseWebSocketClient(productID: productID)
    coinbaseWebSocketClient?.delegate = self
    setDefaultView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
    getCoinBlance()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
//    navigationItem.backBarButtonItem?.title = ""
//    navigationController?.navigationBar.topItem?.title = ""
  }

  private func setDefaultView() {
    if let productInfo = ProductInfo.fromTableStatName(productID) {
      sourceImageView.image = productInfo.image
      sourceCoinLabel.text = productInfo.name

      if side == "buy" {
        headerLabel.text = "買入 \(productInfo.name)"
        sourceTitleLabel.text = "買入"
        originTitleLabel.text = "花費"
        tradeBtn.setTitle("買入", for: .normal)
        exchangeRateInfoView.isHidden = true
      } else {
        headerLabel.text = "賣出 \(productInfo.name)"
        sourceTitleLabel.text = "賣出"
        originTitleLabel.text = "獲得"
        tradeBtn.setTitle("賣出", for: .normal)
        exchangeRateInfoView.isHidden = false
      }

      sourceUnitLabel.text = "1 \(productInfo.name) = "
    }
  }

  private func changeTextFieldValue(_ textField: UITextField) {
    let unitPrice = side == "buy" ? bestAsk : bestBid

    if textField.text == "" && textField == sourcePriceTextField { originPriceTextField.text = "0" }
    if textField.text == "" && textField == originPriceTextField { sourcePriceTextField.text = "0" }

    guard let textFieldText = textField.text, !textFieldText.isEmpty, textFieldText != "",
          let inputValue = Double(textFieldText),
          let bestPrice = Double(unitPrice)
    else {
      return
    }

    if textField == sourcePriceTextField {
      let originPrice = inputValue * bestPrice
      let originPriceText = originPrice.formatNumber(originPrice, max: 8, min: 2, isAddSep: false)
      originPriceTextField.text = originPriceText
    } else if textField == originPriceTextField {
      let sourcePrice = inputValue / bestPrice
      let sourcePriceText = sourcePrice.formatNumber(sourcePrice, max: 8, min: 2, isAddSep: false)
      sourcePriceTextField.text = sourcePriceText
    }
  }

  private func getCoinBlance() {
    ApiManager.shared.getAccounts { accounts in
      guard let productInfo = ProductInfo.fromTableStatName(self.productID) else { return }
      let account = accounts.filter { $0.currency == productInfo.name }
      self.accountBalance = account.first?.balance ?? "0.00"
      let blance = Double(account.first?.balance ?? "0.00") ?? 0.0
      let balanceText = blance.formatNumber(blance, max: 8, min: 2, isAddSep: true) ?? "0.00"

      DispatchQueue.main.async {
        self.exchangeRateInfoLabel.text = "可用餘額：\(balanceText)"
      }
    }
  }
}

extension BuySellVC: WebSocketReceiveDelegate {
  func didReceiveTickerData(buyPrice: String, sellPrice: String) {
    bestBid = buyPrice
    bestAsk = sellPrice
    unitPriceLabel.text = side == "buy" ? bestAsk : bestBid
    let textField = isSourceEditable ? sourcePriceTextField : originPriceTextField
    changeTextFieldValue(textField!)
  }
}

extension BuySellVC: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField.text == "0" { textField.text = "" }
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    changeTextFieldValue(textField)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
    let replacementStringCharacterSet = CharacterSet(charactersIn: string)
    let isCharacterAllowed = allowedCharacters.isSuperset(of: replacementStringCharacterSet)

    let currentText = (textField.text ?? "") as NSString
    let newText = currentText.replacingCharacters(in: range, with: string)
    let decimalCount = newText.components(separatedBy: ".").count - 1
    let isDecimalPointAllowed = decimalCount <= 1

    return isCharacterAllowed && isDecimalPointAllowed
  }

  func textFieldDidChangeSelection(_ textField: UITextField) {
    changeTextFieldValue(textField)
  }
}
