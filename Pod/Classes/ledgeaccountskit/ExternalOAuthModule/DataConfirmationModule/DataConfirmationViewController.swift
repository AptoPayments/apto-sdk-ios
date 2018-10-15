//
//  DataConfirmationViewController.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 25/09/2018.
//

import UIKit
import Bond
import ReactiveKit
import SnapKit

class DataConfirmationViewController: ShiftViewController {
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
private extension DataConfirmationViewController {
  func setUpUI() {
    title = "data.confirmation.title".podLocalized()
    view.backgroundColor = uiConfiguration.backgroundColor
    setUpNavigationBar()
    view.addSubview(formView)
    formView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    showNavNextButton(title: "data.confirmation.confirm".podLocalized(), tintColor: uiConfiguration.textTopBarColor)
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
    return FormRowSeparatorView(backgroundColor: uiConfiguration.backgroundColor, height: 52)
  }

  func createRows(for userData: DataPointList) -> [FormRowView] {
    var rows = [FormRowView]()
    userData.forEach {
      let formatter = formatterFactory.formatter(for: $0)
      formatter.titleValues.forEach {
        rows.append(FormBuilder.formLabelRowWith(text: $0.title, uiConfig: uiConfiguration))
        rows.append(FormBuilder.formAnswerRowWith(text: $0.value, uiConfig: uiConfiguration))
        rows.append(FormRowSeparatorView(backgroundColor: uiConfiguration.backgroundColor, height: 20))
      }
    }
    return rows
  }
}
