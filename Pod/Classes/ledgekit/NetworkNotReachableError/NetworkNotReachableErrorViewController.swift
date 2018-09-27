//
//  NetworkNotReachableErrorViewController.swift
//  Pods
//
//  Created by Takeichi Kanzaki on 16/07/2018.
//
//

import UIKit
import SnapKit

public class NetworkNotReachableErrorViewController: UIViewController {
  private let config: ShiftUIConfig?
  // swiftlint:disable implicitly_unwrapped_optional
  private var titleLabel: UILabel!
  private var messageLabel: UILabel!
  // swiftlint:enable implicitly_unwrapped_optional

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }

  public init(uiConfig: ShiftUIConfig?) {
    self.config = uiConfig

    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    self.config = nil
    super.init(coder: aDecoder)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = backgroundColor
    setUpMessageLabel()
    setUpTitleLabel()
    setUpLoadingSpinner()
    setUpImageView()
  }
}

// MARK: - setup UI
private extension NetworkNotReachableErrorViewController {
  private func setUpMessageLabel() {
    messageLabel = UILabel()
    messageLabel.font = messageFont
    messageLabel.textColor = tintColor
    messageLabel.textAlignment = .center
    messageLabel.numberOfLines = 0
    messageLabel.text = "network-not-reachable.error.message".podLocalized()
    view.addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().offset(-16)
      make.center.equalToSuperview()
    }
  }

  private func setUpTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = titleFont
    titleLabel.textColor = tintColor
    titleLabel.textAlignment = .center
    titleLabel.text = "network-not-reachable.error.title".podLocalized()
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.width.equalToSuperview()
      make.top.equalTo(self.messageLabel).offset(-40)
    }
  }

  private func setUpLoadingSpinner() {
    let container = UIView()
    container.backgroundColor = .clear
    view.addSubview(container)
    container.snp.makeConstraints { make in
      make.width.equalToSuperview()
      make.top.equalTo(messageLabel.snp.bottom)
      make.bottom.equalToSuperview().offset(-60)
    }

    let spinner = UIActivityIndicatorView()
    spinner.color = tintColor
    container.addSubview(spinner)
    spinner.startAnimating()
    spinner.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  private func setUpImageView() {
    let container = UIView()
    container.backgroundColor = .clear
    view.addSubview(container)
    container.snp.makeConstraints { make in
      make.width.equalToSuperview()
      make.top.equalToSuperview().offset(60)
      make.bottom.equalTo(titleLabel.snp.top)
    }

    // swiftlint:disable:next force_unwrapping
    let image = UIImage.imageFromPodBundle("error_offline.png")
    let imageView = UIImageView(image: image?.asTemplate())
    container.addSubview(imageView)
    imageView.tintColor = tintColor
    imageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  private var backgroundColor: UIColor {
    guard let config = self.config else {
      return .white
    }

    return config.backgroundColor
  }

  private var tintColor: UIColor {
    guard let config = self.config else {
      return .gray
    }

    return config.textPrimaryColor
  }

  private var titleFont: UIFont {
    guard let config = self.config else {
      return .systemFont(ofSize: 24)
    }

    return config.shiftTitleFont
  }

  private var messageFont: UIFont {
    guard let config = self.config else {
      return .systemFont(ofSize: 16)
    }

    return config.shiftFont
  }
}
