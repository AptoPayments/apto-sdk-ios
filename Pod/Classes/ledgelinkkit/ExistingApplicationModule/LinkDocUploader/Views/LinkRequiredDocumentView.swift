//
//  RequiredDocumentView.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 29/03/16.
//
//

import Foundation

class LinkRequiredDocumentView: UIView {
  
  let requiredDocument: RequiredDocumentViewModel
  let uiConfiguration: ShiftUIConfig
  let tapHandler:()->Void
  let buttonDiameter: CGFloat = 80
  let imageInset: CGFloat = 25
  let buttonBorderWidth: CGFloat = 2
  
  init(requiredDocument: RequiredDocumentViewModel, uiConfiguration: ShiftUIConfig, tapHandler:@escaping ()->Void) {
    self.requiredDocument = requiredDocument
    self.uiConfiguration = uiConfiguration
    self.tapHandler = tapHandler
    super.init(frame: CGRect.zero)
    self.setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  fileprivate func setupView() {
    let centeredView = UIView()
    self.addSubview(centeredView)
    centeredView.snp.makeConstraints { make in
      make.centerX.top.bottom.equalTo(self)
    }
    let actionButton = UIButton.circledButtonWith(nil,
                                                  backgroundColor: self.uiConfiguration.docUploaderButtonBackgroundColor,
                                                  borderColor: nil,
                                                  borderWidth: buttonBorderWidth,
                                                  diameter: buttonDiameter,
                                                  imageInset: imageInset,
                                                  tapHandler: self.tapHandler)
    centeredView.addSubview(actionButton)
    actionButton.snp.makeConstraints { make in
      make.width.height.equalTo(buttonDiameter)
      make.top.equalTo(centeredView)
      make.centerX.equalTo(centeredView)
    }
    
    let docName = UILabel()
    docName.font = self.uiConfiguration.fonth2
    docName.numberOfLines = 0
    docName.textAlignment = .center
    centeredView.addSubview(docName)
    docName.snp.makeConstraints { make in
      make.left.right.equalTo(centeredView).inset(15)
      make.top.equalTo(actionButton.snp.bottom).offset(15)
    }
    
    let fileNumberView = UIView()

    let greenCheck = UIImageView(image: UIImage.imageFromPodBundle("green_tick_circled.png")?.asTemplate())
    greenCheck.tintColor = self.uiConfiguration.tintColor
    fileNumberView.addSubview(greenCheck)
    greenCheck.snp.makeConstraints { make in
      make.left.centerY.equalTo(fileNumberView)
      make.width.height.equalTo(16)
    }

    let fileNumber = UILabel()
    fileNumber.font = self.uiConfiguration.fonth4
    fileNumber.textAlignment = .center
    fileNumberView.addSubview(fileNumber)
    fileNumber.snp.makeConstraints { make in
      make.top.bottom.right.equalTo(fileNumberView)
      make.left.equalTo(greenCheck.snp.right).offset(5)
    }
    
    centeredView.addSubview(fileNumberView)
    fileNumberView.snp.makeConstraints { make in
      make.centerX.equalTo(centeredView)
      make.top.equalTo(docName.snp.bottom)
      make.bottom.equalTo(centeredView)
    }
    
    let _ = requiredDocument.uiRequiredDocument.files.observeNext { selectedFiles in
      if (selectedFiles != nil) && (selectedFiles!.count > 0) {
        actionButton.layer.borderColor = self.uiConfiguration.docUploaderDisabledButtonColor.cgColor
        actionButton.setImage(self.requiredDocument.disabledIcon, for: .normal)
        docName.textColor = self.uiConfiguration.docUploaderDisabledNameLabelColor
        fileNumber.textColor = self.uiConfiguration.docUploaderDisabledNameLabelColor
        fileNumber.snp.remakeConstraints { make in
          make.top.bottom.right.equalTo(fileNumberView)
          make.left.equalTo(greenCheck.snp.right).offset(5)
        }
        greenCheck.isHidden = false
      }
      else {
        actionButton.layer.borderColor = self.uiConfiguration.docUploaderEnabledButtonColor.cgColor
        actionButton.setImage(self.requiredDocument.enabledIcon, for: .normal)
        docName.textColor = self.uiConfiguration.docUploaderEnabledNameLabelColor
        fileNumber.textColor = self.uiConfiguration.docUploaderEnabledNameLabelColor
        fileNumber.snp.remakeConstraints { make in
          make.top.bottom.right.left.equalTo(fileNumberView)
        }
        greenCheck.isHidden = true
      }
    }
    
    let _ = requiredDocument.uiRequiredDocument.files.observeNext { files in
      var fileCount = 0
      if (files != nil) {
        fileCount = files!.count
      }
      fileNumber.text = "doc-uploader.file-count".podLocalized().replace(["(%file_count%)":"\(fileCount)"])
    }
    
    let _ = requiredDocument.docName.observeNext { name in
      docName.text = name
    }
  }
  
}
