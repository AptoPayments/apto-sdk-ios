//
//  DataConfirmationViewControllerTheme1.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//

import UIKit
import Bond
import ReactiveKit
import SnapKit

class DataConfirmationViewControllerTheme1: ShiftViewController {
  private let disposeBag = DisposeBag()
  private let presenter: DataConfirmationPresenterProtocol
  private let formView = MultiStepForm()
  private let formatterFactory = DataPointFormatterFactory()

  init(uiConfiguration: ShiftUIConfig, presenter: DataConfirmationPresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not being implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpUI()
    setUpViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  override func previousTapped() {
    presenter.closeTapped()
  }

  override func nextTapped() {
    presenter.confirmDataTapped()
  }

  private func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.userData.observeNext { userData in
      self.setUpUI(for: userData)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension DataConfirmationViewControllerTheme1 {
  func setUpUI() {
    title = "select_balance_store.oauth_confirm.title".podLocalized()
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    view.addSubview(formView)
    formView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    showNavNextButton(title: "select_balance_store.oauth_confirm.call_to_action.title".podLocalized(),
                      tintColor: uiConfiguration.textTopBarColor)
  }

  func setUpUI(for userData: DataPointList?) {
    guard let userData = userData else {
      return
    }

    var rows = [createTopSeparator()]
    rows.append(contentsOf: createRows(for: userData))
    formView.show(rows: rows)
  }

  func createTopSeparator() -> FormRowView {
    return FormRowSeparatorView(backgroundColor: uiConfiguration.uiBackgroundPrimaryColor, height: 52)
  }

  func createRows(for userData: DataPointList) -> [FormRowView] {
    var rows = [FormRowView]()
    userData.forEach {
      let formatter = formatterFactory.formatter(for: $0)
      formatter.titleValues.forEach {
        rows.append(FormBuilder.formLabelRowWith(text: $0.title, uiConfig: uiConfiguration))
        rows.append(FormBuilder.formAnswerRowWith(text: $0.value, uiConfig: uiConfiguration))
        rows.append(FormRowSeparatorView(backgroundColor: uiConfiguration.uiBackgroundPrimaryColor, height: 20))
      }
    }
    return rows
  }
}
