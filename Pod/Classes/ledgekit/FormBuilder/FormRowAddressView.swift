//
//  FormRowAddressView.swift
//  ShiftSDK
//
// Created by Takeichi Kanzaki on 08/10/2018.
//

import SnapKit
import Bond
import ReactiveKit

class FormRowAddressView: FormRowView {
  private let disposeBag = DisposeBag()
  private let label: UILabel
  private let textField: UITextField
  private let addressManager: AddressManager
  private let allowedCountries: [Country]
  private let searchResults = UITableView(frame: .zero, style: .plain)
  private let rowHeight = 44
  private let maxVisibleRows = 5
  private let uiConfig: ShiftUIConfig
  private let places: Observable<[Place]> = Observable([])
  private var selectedPlace: Place?
  let address: Observable<Address?> = Observable(nil)

  init(label: UILabel,
       textField: UITextField,
       addressManager: AddressManager,
       allowedCountries: [Country],
       uiConfig: ShiftUIConfig) {
    self.label = label
    self.textField = textField
    self.addressManager = addressManager
    self.allowedCountries = allowedCountries
    self.uiConfig = uiConfig
    super.init(showSplitter: false)

    setUpUI()
    setUpObservers()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Reactive observers
private extension FormRowAddressView {
  func setUpObservers() {
    textField.reactive.text.observeNext { [unowned self] address in
      guard let address = address, !address.isEmpty else {
        self.selectedPlace = nil
        self.places.next([])
        self.address.next(nil)
        return
      }
      guard address != self.selectedPlace?.name, address != self.address.value?.formattedAddress else {
        return
      }
      self.address.next(nil)
      self.addressManager.autoComplete(address: address, countries: self.allowedCountries) { result in
        switch result {
        case .failure:
          break
        case .success(let places):
          self.places.next(places)
        }
      }
    }.dispose(in: disposeBag)
    address.observeNext { [unowned self] address in
      self.valid.next(address != nil)
    }.dispose(in: disposeBag)
  }
}

// MARK: - UITableViewDataSource
extension FormRowAddressView: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.value.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = places.value[indexPath.row].name
    cell.textLabel?.font = uiConfig.fontProvider.formListFont
    cell.textLabel?.textColor = uiConfig.textPrimaryColor

    return cell
  }
}

// MARK: - UITableViewDelegate
extension FormRowAddressView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let place = places.value[indexPath.row]
    selectedPlace = place
    textField.text = selectedPlace?.name
    searchResults.isHidden = true
    searchResults.snp.updateConstraints { make in
      make.height.equalTo(0)
    }
    addressManager.placeDetails(placeId: place.id) { [unowned self] result in
      switch result {
      case .failure:
        self.address.next(nil)
      case .success(let address):
        self.address.next(address)
        self.textField.text = address.formattedAddress
      }
    }
  }
}

// MARK: - Set up UI
private extension FormRowAddressView {
  func setUpUI() {
    backgroundColor = uiConfig.uiBackgroundPrimaryColor
    setUpLabel()
    setUpTextField()
    setUpSearchResults()
    layoutSearchResults()
  }

  func setUpLabel() {
    contentView.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.top.equalToSuperview()
    }
  }

  func setUpTextField() {
    contentView.addSubview(textField)
    textField.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).offset(6)
      make.left.right.equalToSuperview()
    }
    textField.adjustsFontSizeToFitWidth = true
    textField.clearsOnBeginEditing = true
  }

  func setUpSearchResults() {
    searchResults.backgroundColor = uiConfig.uiBackgroundPrimaryColor
    searchResults.separatorStyle = .none
    searchResults.estimatedRowHeight = CGFloat(rowHeight)
    searchResults.isHidden = true
    searchResults.dataSource = self
    searchResults.delegate = self
    searchResults.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    places.observeNext { [unowned self] places in
      self.searchResults.isHidden = places.isEmpty
      self.searchResults.reloadData()
      if !places.isEmpty {
        self.searchResults.snp.updateConstraints { make in
          let visibleRows = min(places.count, self.maxVisibleRows)
          make.height.equalTo(visibleRows * self.rowHeight)
        }
      }
    }.dispose(in: disposeBag)
  }

  func layoutSearchResults() {
    contentView.addSubview(searchResults)
    searchResults.snp.makeConstraints { make in
      make.top.equalTo(textField.snp.bottom)
      make.left.right.equalTo(textField)
      make.height.equalTo(0)
      make.bottom.equalToSuperview()
    }
  }
}
