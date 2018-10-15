//
//  DataPointFormatter.swift
//  ShiftSDK
//
//  Created by Takeichi Kanzaki on 26/09/2018.
//

struct TitleValue {
  let title: String
  let value: String
}

class DataPointFormatter {
  let dataPoint: DataPoint

  init(dataPoint: DataPoint) {
    self.dataPoint = dataPoint
  }

  var titleValues: [TitleValue] {
    return [TitleValue(title: title, value: value)]
  }

  fileprivate var title: String {
    return "Title for type \(dataPoint.type.description)"
  }

  fileprivate var value: String {
    return "Value for type \(dataPoint.type.description)"
  }
}

class PhoneFormatter: DataPointFormatter {
  private let phoneHelper = PhoneHelper.sharedHelper()

  fileprivate override var title: String {
    return "data-point.formatter.phone.title".podLocalized()
  }

  fileprivate override var value: String {
    guard let phoneNumber = dataPoint as? PhoneNumber else {
      return ""
    }
    return phoneHelper.formatPhoneWith(countryCode: phoneNumber.countryCode.value,
                                       nationalNumber: phoneNumber.phoneNumber.value,
                                       numberFormat: .nationalWithPrefix)
  }
}

class EmailFormatter: DataPointFormatter {
  fileprivate override var title: String {
    return "data-point.formatter.email.title".podLocalized()
  }

  fileprivate override var value: String {
    guard let email = dataPoint as? Email, let emailAddress = email.email.value else {
      return ""
    }
    return emailAddress
  }
}

class PersonalNameFormatter: DataPointFormatter {
  override var titleValues: [TitleValue] {
    guard let personalName = dataPoint as? PersonalName,
          let firstName = personalName.firstName.value,
          let lastName = personalName.lastName.value else {
      return []
    }
    return [
      TitleValue(title: "data-point.formatter.first-name.title".podLocalized(), value: firstName),
      TitleValue(title: "data-point.formatter.last-name.title".podLocalized(), value: lastName),
    ]
  }
}

class AddressFormatter: DataPointFormatter {
  fileprivate override var title: String {
    return "data-point.formatter.address.title".podLocalized()
  }

  fileprivate override var value: String {
    guard let address = dataPoint as? Address else {
      return ""
    }

    var strAddress = ""
    if let value = address.address.value {
      strAddress = append(value, to: strAddress)
    }
    if let value = address.apUnit.value {
      strAddress = append(value, to: strAddress)
    }
    if let value = address.city.value {
      strAddress = append(value, to: strAddress)
    }
    if let value = address.region.value {
      strAddress = append(value, to: strAddress)
    }
    if let value = address.zip.value {
      strAddress = append(value, to: strAddress)
    }
    if let value = address.country.value {
      strAddress = append(value.name, to: strAddress)
    }
    return strAddress
  }

  private func append(_ string: String, to: String, separator: String = ", ") -> String {
    if to.isEmpty {
      return string
    }
    return to + separator + string
  }
}

class BirthDateFormatter: DataPointFormatter {
  private static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }

  fileprivate override var title: String {
    return "data-point.formatter.birth-date.title".podLocalized()
  }

  fileprivate override var value: String {
    guard let birthDate = dataPoint as? BirthDate, let date = birthDate.date.value else {
      return ""
    }
    return BirthDateFormatter.dateFormatter.string(from: date)
  }
}

class SSNFormatter: DataPointFormatter {
  fileprivate override var title: String {
    return "birthday-collector.id-document.type.ssn".podLocalized()
  }

  fileprivate override var value: String {
    guard let ssn = dataPoint as? IdDocument, let value = ssn.value.value, value.count == 9 else {
      return SSNTextValidator.unknownValidSSN
    }
    let firstDivision = value.index(value.startIndex, offsetBy: 3)
    let secondDivision = value.index(firstDivision, offsetBy: 2)
    return String(value[..<firstDivision]) + "-" + String(value[firstDivision..<secondDivision]) + "-" + String(value[secondDivision...])
  }
}

class IdDocumentFormatter: DataPointFormatter {
  fileprivate override var title: String {
    guard let idDocument = dataPoint as? IdDocument, let documentType = idDocument.documentType.value else {
      return "data-point.formatter.id-document.title".podLocalized()
    }

    return documentType.localizedDescription
  }

  fileprivate override var value: String {
    guard let idDocument = dataPoint as? IdDocument, let value = idDocument.value.value else {
      return ""
    }
    return value
  }
}

class DataPointFormatterFactory {
  func formatter(for dataPoint: DataPoint) -> DataPointFormatter {
    switch dataPoint.type {
    case .phoneNumber:
      return PhoneFormatter(dataPoint: dataPoint)
    case .email:
      return EmailFormatter(dataPoint: dataPoint)
    case .personalName:
      return PersonalNameFormatter(dataPoint: dataPoint)
    case .address:
      return AddressFormatter(dataPoint: dataPoint)
    case .birthDate:
      return BirthDateFormatter(dataPoint: dataPoint)
    case .idDocument:
      if let dataPoint = dataPoint as? IdDocument, dataPoint.documentType.value == .ssn {
        return SSNFormatter(dataPoint: dataPoint)
      }
      else {
        return IdDocumentFormatter(dataPoint: dataPoint)
      }
    default:
      return DataPointFormatter(dataPoint: dataPoint)
    }
  }
}
