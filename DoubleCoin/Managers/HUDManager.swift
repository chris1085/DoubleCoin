//
//  HUDManager.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/11.
//

import Foundation
import JGProgressHUD

final class HUDManager {
  static let shared = HUDManager()

  private let hud: JGProgressHUD

  private init() {
    hud = JGProgressHUD()
  }

  func showHUD(in view: UIView, text: String) {
    hud.textLabel.text = text
    hud.show(in: view)
  }

  func dismissHUD() {
    hud.dismiss()
  }

  func dismissAdterHUD(delayTime: Double) {
    hud.dismiss(afterDelay: delayTime)
  }
}
