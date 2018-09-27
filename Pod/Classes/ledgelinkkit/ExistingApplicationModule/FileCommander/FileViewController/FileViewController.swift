//
//  FileViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 31/03/16.
//
//

import Bond
import ReactiveKit

class FileViewController: ShiftViewController {

  let presenter: FilePresenterProtocol

  init(uiConfiguration: ShiftUIConfig, presenter: FilePresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupUI()
    let _ = combineLatest(self.presenter.viewModel.image, self.presenter.viewModel.fileName, self.presenter.viewModel.fullScreenImage).observeNext { [weak self] (image, fileName, fullScreen) in
      self?.configureUIFor(image, fileName: fileName, fullScreen: fullScreen)
    }
    self.presenter.viewLoaded()
  }

  // MARK: - Private methods

  let imageView = UIImageView()
  let fileNameLabel = UILabel()
  let containerView = UIView()
  let centeredView = UIView()

  fileprivate func setupUI() {
    fileNameLabel.font = uiConfiguration.fonth4
    fileNameLabel.textAlignment = .center
    self.view.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.left.right.equalTo(self.view)
      make.bottom.equalTo(self.view).offset(-44)
    }
    containerView.addSubview(centeredView)
    centeredView.snp.makeConstraints { make in
      make.centerX.centerY.equalTo(containerView)
    }
    centeredView.addSubview(fileNameLabel)
    fileNameLabel.snp.makeConstraints { make in
      make.left.right.bottom.equalTo(centeredView)
      make.height.equalTo(44)
    }
    imageView.contentMode = .scaleAspectFit
    centeredView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.left.top.right.equalTo(centeredView)
      make.bottom.equalTo(fileNameLabel.snp.top)
    }
  }

  fileprivate func configureUIFor(_ image:UIImage?, fileName:String?, fullScreen:Bool) {
    self.imageView.image = image
    self.fileNameLabel.text = fileName
    fileNameLabel.snp.removeConstraints()
    imageView.snp.removeConstraints()
    if fullScreen == true {
      imageView.contentMode = .scaleAspectFit
      imageView.snp.remakeConstraints { make in
        make.left.top.right.bottom.equalTo(centeredView)
      }
      centeredView.snp.remakeConstraints({ make in
        make.left.top.right.bottom.equalTo(containerView)
      })
      fileNameLabel.isHidden = true
    }
    else {
      let imageViewWidth:CGFloat = 180
      let imageViewHeight:CGFloat = image != nil ? (image?.size.height)! * (imageViewWidth / (image?.size.width)!) : imageViewWidth
      imageView.snp.remakeConstraints { make in
        make.top.equalTo(centeredView)
        make.centerX.equalTo(centeredView)
        make.width.equalTo(imageViewWidth)
        make.height.equalTo(imageViewHeight)
      }
      fileNameLabel.snp.remakeConstraints({ make in
        make.top.equalTo(imageView.snp.bottom).offset(15)
        make.bottom.equalTo(centeredView)
        make.left.right.equalTo(centeredView)
      })
      fileNameLabel.isHidden = false
    }
  }

}
