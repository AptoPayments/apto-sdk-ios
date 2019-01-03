//
//  FileCommanderViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 31/03/16.
//
//

import Foundation

protocol FileCommanderViewControllerProtocol {
  func showNextFile()
  func showPreviousFile()
  func previousTapped()
}

class FileCommanderViewController: CarouselViewcontroller, FileCommanderViewControllerProtocol {

  var presenter: FileCommanderPresenterProcotol!
  let fileViewControllerBuilder: FileViewControllerBuilder

  init(uiConfiguration: ShiftUIConfig, presenter: FileCommanderPresenter, fileViewControllerBuilder: FileViewControllerBuilder) {
    self.presenter = presenter
    self.fileViewControllerBuilder = fileViewControllerBuilder
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupUI()
    let _ = self.presenter.viewModel.files.observeNext { files in
      self.setupWith(files: files)
    }
    let _ = self.presenter.viewModel.title.observeNext { newTitle in
      self.title = newTitle
    }
    self.presenter.viewLoaded()
  }

  override func previousTapped() {
    self.navigationController?.popViewController(animated: true)
  }

  // MARK: - Private functions

  fileprivate let navigationView = UIView()
  fileprivate let navBackButton = UIButton(type: .custom)
  fileprivate let navNextButton = UIButton(type: .custom)
  fileprivate let navDeleteButton = UIButton(type: .custom)

  fileprivate func setupUI() {

    self.title = "file-commander.title".podLocalized()
    self.view.backgroundColor = self.uiConfiguration.uiBackgroundPrimaryColor
    self.showNavPreviousButton(self.uiConfiguration.iconTertiaryColor)

    self.view.addSubview(navigationView)
    navigationView.snp.makeConstraints { make in
      make.height.equalTo(44)
      make.left.right.bottom.equalTo(self.view)
    }
    let topBorderView = UIView()
    topBorderView.backgroundColor = uiConfiguration.applicationListNavigationBorderColor
    navigationView.addSubview(topBorderView)
    topBorderView.snp.makeConstraints { make in
      make.height.equalTo(1 / UIScreen.main.scale)
      make.left.right.top.equalTo(navigationView)
    }

    navigationView.addSubview(navBackButton)
    navBackButton.snp.makeConstraints { make in
      make.left.equalTo(navigationView).offset(15)
      make.centerY.equalTo(navigationView)
      make.height.equalTo(navigationView)
    }
    let previousIcon = UIImage.imageFromPodBundle("top_back_default.png")
    navBackButton.set(image: previousIcon!, title: "file-commander.nav.button.back".podLocalized().podLocalized(), titlePosition: .right, additionalSpacing: 10, state: UIControlState())
    navBackButton.setTitleColor(uiConfiguration.tintColor, for: UIControlState())
    navBackButton.titleLabel?.font = uiConfiguration.fonth4
    navBackButton.addTarget(self, action: #selector(FileCommanderViewController.previousFileTapped), for: .touchUpInside)
    navBackButton.alpha = 0

    navigationView.addSubview(navNextButton)
    navNextButton.snp.makeConstraints { make in
      make.right.equalTo(navigationView).offset(-15)
      make.centerY.equalTo(navigationView)
      make.height.equalTo(navigationView)
    }
    let nextIcon = UIImage.imageFromPodBundle("top_next_default.png")
    navNextButton.set(image: nextIcon!, title: "file-commander.nav.button.next".podLocalized(), titlePosition: .left, additionalSpacing: 5, state: UIControlState())
    navNextButton.setTitleColor(uiConfiguration.tintColor, for: UIControlState())
    navNextButton.titleLabel?.font = uiConfiguration.fonth4
    navNextButton.addTarget(self, action: #selector(FileCommanderViewController.nextFileTapped), for: .touchUpInside)

    navigationView.addSubview(navDeleteButton)
    navDeleteButton.snp.makeConstraints { make in
      make.centerX.equalTo(navigationView)
      make.centerY.equalTo(navigationView)
      make.height.equalTo(navigationView)
    }
    let deleteIcon = UIImage.imageFromPodBundle("trash_bin.png")
    navDeleteButton.set(image: deleteIcon!, title: "", titlePosition: .left, additionalSpacing: 0, state: UIControlState())
    navDeleteButton.setTitleColor(uiConfiguration.tintColor, for: UIControlState())
    navDeleteButton.titleLabel?.font = uiConfiguration.fonth4
    navDeleteButton.addTarget(self, action: #selector(FileCommanderViewController.deleteFileTapped), for: .touchUpInside)

    navigationView.backgroundColor = uiConfiguration.applicationListNavigationBackgrundColor

  }

  fileprivate func setupWith(files:[File]?) {
    guard let files = files else {
      // TODO: What if there are no files here?
      return
    }
    self.viewControllers = files.map { file -> UIViewController in
      return fileViewControllerBuilder.prepareFileViewController(file)
    }
    self.currentPageIndex = 0
  }

  func showNextFile() {
    showNextViewController()
  }

  func showPreviousFile() {
    showPreviousViewController()
  }

  @objc func nextFileTapped() {
    presenter.nextFileTapped()
  }

  @objc func previousFileTapped() {
    presenter.previousFileTapped()
  }

  @objc func deleteFileTapped() {
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let deleteFileAction = UIAlertAction(title: "file-commander.delete-file".podLocalized(), style: .destructive, handler: { [weak self] (alert: UIAlertAction!) -> Void in
      self?.presenter.deleteFileTapped((self?.currentPageIndex)!)
    })
    let cancelAction = UIAlertAction(title: "file-commander.button.cancel", style: .cancel, handler: nil)
    optionMenu.addAction(deleteFileAction)
    optionMenu.addAction(cancelAction)
    self.present(optionMenu, animated: true, completion: nil)
  }

  override func viewControllerShown(_ index:Int) {
    presenter.didShow(index)
    guard viewControllers.count > 1 else {
      navBackButton.alpha = 0
      navNextButton.alpha = 0
      return
    }
    navBackButton.alpha = (index <= 0) ? 0 : 1
    navNextButton.alpha = (index >= (viewControllers.count - 1)) ? 0 : 1
  }

}
