# Apto SDK for iOS [![CocoaPods](https://img.shields.io/cocoapods/v/AptoSDK.svg?style=plastic)](https://cocoapods.org/pods/AptoSDK)

Welcome to the Apto iOS SDK. This SDK gives access to the Apto's mobile API, designed to be used from a mobile app. Using this SDK there's no need to integrate the API itself, all the API endpoints are exposed as simple to use methods, and the data returned by the API is properly encapsulated and easy to access.

With this SDK, you'll be able to onboard new users, issue cards, obtain card activity information and manage the card (set pin, freeze / unfreeze, etc.)

For more information, see the [Apto developer portal](https://aptopayments.com/developer).

## Requirements

    * Xcode 10
    * Swift 5
    * CocoaPods

### Installation (Using [CocoaPods](https://cocoapods.org))

1. In your `Podfile`, add the following dependency:

    ```
    platform :ios, '10.0'
    use_frameworks!

    pod 'AptoSDK'
    ```

2. Run `pod install`.

## Using the SDK

To run the SDK you must first register a project in order to get a `API KEY`. Please contact Apto to create a project for you. Then, initialise the SDK by passing the public api key:

```swift
AptoPlatform.defaultManager().initializeWithApiKey("API KEY")
```

This will initialise the SDK to operate in production mode. If you want to use it in sandbox mode, an additional parameter can be sent during initialization:

```swift
AptoPlatform.defaultManager().initializeWithApiKey("API KEY",
                                                   environment: .sandbox)
```

## User session token

In order to authenticate a user and retrieve a user session token, the Apto mobile API provides mechanisms to sign up or sign in. Both mechanisms are based on verifying the user primary credentials, which can be user's phone or email, depending on the configuration of your project. Please contact us to set up the proper primary credential for your users.

Typical steps to obtain a user token involve:

1. Verify user's primary credential. Once verified, the verification contains data showing if the credential belongs to an existing user or to a new user.

1. If the credential belongs to an existing user, verify user's secondary credential.
   1. Obtain a user session token by using the login method on the SDK. That method receives the two previous verifications. The user token will be stored and handled by the SDK.

1. If the credential doesn't belong to any existing user, create a new user with the verified credential and obtain a user token. The user token will be stored and handled by the SDK.

## Verifications

### Start a new verification

To start a new verification, you can use the following SDK methods:

```swift
AptoPlatform.defaultManager().startPhoneVerification(phone) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let verification):
    // The verification started and the user received an SMS with a single use code.
  }
}
```

```swift
AptoPlatform.defaultManager().startEmailVerification(email) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let verification):
    // The verification started and the user received an email with a single use code.
  }
}
```

### Restart a verification

Verifications can be restarted, by using the following SDK method:

```swift
AptoPlatform.defaultManager().restartVerification(verification) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let verification):
    // The verification started and the user received a new secret via email or phone.
  }
}
```

### Complete a verification

To complete a new verification, you can use the following SDK method:

```swift
verification.secret = pin // pin entered by the user
AptoPlatform.defaultManager().completeVerification(verification) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let verification):
    if verification.status == .passed {
      // The verification succeeded. If it belongs to an existing user, it will contain a non null `secondaryCredential`.
    }
    else {
      // The verification failed: the secret is invalid.
    }
  }
}
```

## Users management

### Creating a new user

Once the primary credential has been verified, you can use the following SDK method to create a new user:

```swift
// Prepare a DataPointList containing the verified user's primary credential.
let primaryCredential = PhoneNumber(countryCode, phoneNumber)
primaryCredential.verification = verification // The verification obtained before.
let userPII = DataPointList()
userPII.add(primaryCredential)

AptoPlatform.defaultManager().createUser(userData: userPII) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let user):
    // The user created. It contains the user id and the user session token.
  }
}
```

### Login with an existing user

Once the primary and secondary credentials have been verified, you can use the following SDK method to obtain a user token for an existing user:

```swift
AptoPlatform.defaultManager().loginUserWith([phoneVerification, dobVerification]) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let user):
    // The user logged in. The user variable contains the user id and the user session token.
  }
}
```

### Update user info

To update user's info, use the following SDK method:

```swift
let userPII = DataPointList()
// Add to userPII the datapoints that you want to update
AptoPlatform.defaultManager().updateUserInfo(userPII) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let user):
    // Update successful
  }
}
```

### Close user session

To close the current user's session, use the following SDK method:

```swift
AptoPlatform.defaultManager().logout()
```

## Cards management

### Get cards

To retrieve the user cards, you can use the following SDK method:

```swift
AptoPlatform.defaultManager().fetchCards() { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let cards):
    // cards contain an array of Card objects
  }
}
```

### Physical card activation

Physical cards need to be activated by providing an activation code that is sent to the cardholder. In order to activate the physical card, you can use this SDK method:

```swift
AptoPlatform.defaultManager().activatePhysicalCard(cardId) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let result):
    // Result contains information about the activation process and, if it failed, the reason why it failed.
  }
}
```

### Change card PIN

In order to set the card PIN, you can use the following SDK method:

```swift
AptoPlatform.defaultManager().changeCardPIN(cardId, newPIN) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let card):
    // Operation successful
  }
}
```

### Freeze / unfreeze card

Cards can be freezed and unfreezed at any moment. Transactions of a freezed card will be rejected in the merchant's POS. To freeze / unfreeze cards, you can ue the following SDK methods:

```swift
AptoPlatform.defaultManager().lockCard(cardId) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let card):
    // Operation successful
  }
}
```

```swift
AptoPlatform.defaultManager().unlockCard(cardId) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let card):
    // Operation successful
  }
}
```

## Funding Sources management

Apto cards can be connected to different funding sources. You can obtain a list of the available funding sources for the current user, and connect one of them to a user's card.

### Get a list of the available funding sources

```swift
AptoPlatform.defaultManager().fetchCardFundingSources(cardId) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let fundingSources):
    // fundingSources contain a list of FundingSource objects.
  }
}
```

### Get the funding source connected to a card

```swift
AptoPlatform.defaultManager().fetchCardFundingSource(cardId) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let fundingSource):
    // fundingSource is a FundingSource object.
  }
}
```

### Connect a funding source to a card

```swift
AptoPlatform.defaultManager().setCardFundingSource(cardId, fundingSourceId) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let fundingSource):
    // Operation successful
  }
}
```

## Monthly spending stats

To obtain information about the monthly spendings of a given card, classified by Category, you can use the following SDK method:

```swift
AptoPlatform.defaultManager().cardMonthlySpending(cardId, date) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let monthlySpending):
    // monthlySpending contains the stats of the given month; spendings classified by transaction category and difference with the previous month.
  }
}
```

date represents the month of the spending stats.

## Notification preferences

Users can be notified via push notifications regarding several events (transactions, card status changes, etc.). The SDK offers some functions that allow the users to decide how they receive these notifications.

### Obtain the current user notification preferences

```swift
AptoPlatform.defaultManager().fetchNotificationPreferences() { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let notificationPreferences):
    // notificationPreferences contains all the information regarding the current user preferences.
  }
}
```

### Update the current user notification preferences

```swift
let preferences = NotificationPreferences()
// Set the user preferences in `preferences`
AptoPlatform.defaultManager().updateNotificationPreferences(preferences) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let notificationPreferences):
    // Operation successful
  }
}
```

## Transactions management

To get a list of transactions, you can use the following SDK method:

```swift
AptoPlatform.defaultManager().fetchCardTransactions(cardId, filters, forceRefresh) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let transactions):
    // Operation successful
  }
}
```

The filters parameter allows you to filter the type of transactions that are returned by the SDK.

The forceRefresh parameter controls whenever the SDK returns the local cached transaction list of whenever it asks for the transaction list through the Apto mobile API.

## Contributing & Development

We're looking forward to receive your feedback including new feature requests, bug fixes and documentation improvements. If you waht to help us, please take a look at the [issues](https://github.com/ShiftFinancial/apto-sdk-ios/issues) section in the repository first; maybe someone else had the same idea and it's an ongoing or even better a finished task! If what you want to share with us is not in the issues section, please [create one](https://github.com/ShiftFinancial/apto-sdk-ios/issues/new) and we'll get back to you as soon as possible.

And, if you want to help us improve our SDK by adding a new feature or fixing a bug, we'll be glad to see your [pull requests!](https://github.com/ShiftFinancial/apto-sdk-ios/compare)
