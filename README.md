# Apto iOS Mobile SDK [![CocoaPods](https://img.shields.io/cocoapods/v/AptoSDK.svg?style=plastic)](https://cocoapods.org/pods/AptoSDK)

Welcome to the Apto iOS Mobile SDK. This SDK provides access to Apto's mobile API, and is designed to be used for mobile apps. When using this SDK, there is no need for a separate API integration. All the API endpoints are exposed as simple-to-use SDK methods, and the data returned by the API is already encapsulated in the SDK and is easily accessible.

With this SDK, you can:

* [Onboard new users](#user-content-create-a-new-user)
* [Issue new cards](#user-content-issue-a-card)
* [Obtain card activity information](#user-content-view-monthly-spending-stats)
* Manage cards ([set pin](#user-content-change-a-card-pin), [lock / unlock](#user-content-lock--unlock-a-card), etc.)

**Note:** The Apto Mobile API has a request rate limit of 1 request per 30 seconds for the verification and login endpoints.

This document provides an overview of how to:

* [Install the SDK](#user-content-install-the-sdk)
* [Initialize the SDK](#user-content-initialize-the-sdk)
* [Verify a User Credential to Obtain a User Token](#user-content-verify-a-user-credential-to-obtain-a-user-token)
* [Authenticate a User](#user-content-authenticate-a-user)
* [Manage Users](#user-content-manage-users)
* [Manage Card Programs](#user-content-manage-card-programs)
* [Manage Cards](#user-content-manage-cards)
* [Manage Funding Sources](#user-content-manage-funding-sources)
* [Set Notification Preferences](#user-content-set-notification-preferences)
* [Manage Transactions](#user-content-manage-transactions)

For more information, see the [Apto Developer Docs](http://docs.aptopayments.com) or the [Apto API Docs](https://docs.aptopayments.com/api/MobileAPI.html).

To contribute to the SDK development, see [Contributions & Development](#user-content-contributions--development)

## Requirements

* iOS 10.0 (minimum version)
* Swift 5 (minimum version)
* CocoaPods. No minimum version is required, but version 1.8.3 or higher is recommended.

### Get the Mobile API key

A Mobile API Key is required to run the SDK. To retrieve your Mobile API Key:

1. Register for an account or login into the [Apto Developer Portal](https://developer.aptopayments.com). 
	
	**Note:** In order to register or login to your [Apto Developer Portal](https://developer.aptopayments.com) account, you will need to download a 2FA app such as the [Google Authenticator App](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2) for your mobile device.

2. 	Your account has different Mobile API Keys: Sandbox and Production. Ensure you choose the correct environment from the dropdown located in the lower left of the page. 
	
	![Mobile API Key](readme_images/environment.jpg)

3. Select **Developers** from the left menu. Your **Mobile API Key** is listed on this page.

	![Mobile API Key](readme_images/devPortal_mobileApiKey.jpg)

	**Note:** `MOBILE_API_KEY` is used throughout this document to represent your Mobile API key. Ensure you replace `MOBILE_API_KEY` with the Mobile API Key in your account.

## Install the SDK

1. We suggest using [CocoaPods](https://cocoapods.org) to install the SDK:

2. In your project's `Podfile`:

	* At the top of the document, ensure the platform specified is set to iOS 10 and frameworks are enabled:
	
	    ```
	    platform :ios, '10.0'
	    
	    ...
	    
	    use_frameworks!
	    ```
    
	* Add the Apto iOS SDK pod dependency:

		```
		def runtimepods
			
			...
			
	   		pod 'AptoSDK'
	   		
	   		...
	   	```

3. Open your Terminal app, and navigate to your project's folder containing the `Podfile` using `cd`:

	```bash
	cd PATH_TO_PROJECT_FOLDER
	```

4. Install the SDK by running the following command:

	```bash
	pod install
	```

## Initialize the SDK

The SDK must be initialized with your `MOBILE_API_KEY`.

Invoke `initializeWithApiKey` SDK method and pass in the `MOBILE_API_KEY` from the [Apto Developer Portal](https://developer.aptopayments.com). This fully initializes the SDK for your application.


```swift
AptoPlatform.defaultManager().initializeWithApiKey("MOBILE_API_KEY")
```

**Note:** By default, the SDK is initialized for production mode. 

To use the SDK in sandbox mode, append the `environment` parameter during initialization and set the environment to `.sandbox`:

```swift
AptoPlatform.defaultManager().initializeWithApiKey("MOBILE_API_KEY", environment: .sandbox)
```


## Verify a User Credential to Obtain a User Token

The SDK enables users to sign up or sign in to the Apto Mobile API. 

A user's credentials must be verified prior to authenticating a user. A successful verification will return a user token, which is used during the authentication process. Depending on your project's configuration, the user's credentials can be:

* **Primary credential**: The user's phone number or email address. The default primary credential is a phone number.
* **Secondary credential**: The user's date of birth.

**Note:** To set the primary credential as the user's email address, please [contact us](mailto:developers@aptopayments.com).

There are three main methods for the [User Verification Process](#user-content-user-verification-process):

* [Start a New Verification](#user-content-start-a-new-verification) - Use this to initialize the verification process.
* [Complete a Verification](#user-content-complete-a-verification) - Use this to finish the verification process.
* [Restart a Verification](#user-content-restart-a-verification) - This only applies to phone / email verifications. Use this to conduct subsequent verifications, should the initial verification fail.

### User Verification Process

1. **Start verification for the user's primary credential.** See [Start a New Verification](#user-content-start-a-new-verification) for more information.

2. **Complete verification for the user's primary credential.** See [Complete a Verification](#user-content-complete-a-verification) for more information.

3. **Determine if the user is a new or existing user.** Once the user's primary credential is verified, the API response will contain data indicating if the credential belongs to an existing user or a new user.

	**If the credentials belong to an existing user:**
	
	1. Verify the user's secondary credential. See [Complete a Verification](#user-content-complete-a-verification) for more information.
	2. Use the SDK's login method to obtain a user session token. The login method consumes the two previous verifications, and the SDK automatically stores and manages the user token. See [Login with an Existing User](#user-content-login-with-an-existing-user) for more information.

	**If the credentials don't belong to an existing user:**
	
	* Create a new user with the verified credentials and obtain a user token. The SDK automatically stores and manages the user token.

### Start a New Verification

Depending on your project's configuration for your users, use one of the following SDK methods to start a new verification:

* [Phone Verification](#user-content-phone-verification): `AptoPlatform.startPhoneVerification` 
* [Email Verification](#user-content-email-verification): `AptoPlatform.startEmailVerification`


#### Phone Verification

To initialize a user verification with a phone number, use the `startPhoneVerification` method:

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

**Note:** The `phoneNumber` should be passed in as a string and only contain numerical values.

* When the method succeeds, the user will receive a single use code via SMS. You can add additional verification handling within the `verification` response.
* When the method fails, error handling can be included within the `error` response.

#### Email Verification

To initialize a user verification with an email address, use the `startEmailVerification` method:

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

* When the method succeeds, the user will receive a single use code via email. You can add additional verification handling within the `verification` response.
* When the method fails, error handling can be included within the `error` response.

### Complete a Verification

To complete a verification, the user will need to enter their SMS / email code or date of birth, depending on the type of verification.

1. Set the `secret` property on the `verification` object:

	* If verifying a phone number, replace `SMS_EMAIL_CODE_OR_BIRTHDATE` with the SMS code from the [Start a New Verification](#user-content-start-a-new-verification) process. **Note:** Use only numerical values.
	* If verifying an email address, replace `SMS_EMAIL_CODE_OR_BIRTHDATE` with the email code from the [Start a New Verification](#user-content-start-a-new-verification) process. **Note:** Use only numerical values.
	* If verifying a date of birth, replace `SMS_EMAIL_CODE_OR_BIRTHDATE` with the user's date of birth, using the format `YYYY-MM-DD`. For example, `1999-01-01`.

```swift
verification.secret = "SMS_EMAIL_CODE_OR_BIRTHDATE"
```

2. Complete the verification by passing the `verification` object into the `completeVerification` method.

```swift
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

* When the method succeeds:
	* If the `status` property is set to `.passed`, the verification is successful. If the verification belongs to an existing user, the response will contain a non-null `secondaryCredential` value.
	* Otherwise, the verification failed due to an invalid `secret` value. You can add error handling for the user to re-enter their pin.
* When the method fails, error handling can be included within the `error` response.

### Restart a Verification

If you previously initialized a phone or email verification, you can restart a verification by passing in the verification object to the `restartVerification` method:

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

* When the method succeeds, the user will receive a single use code via email or SMS (depending on your project's configuration for your users). You can add additional verification handling within the `verification` response.
* When the method fails, error handling can be included within the `error` response.


## Authenticate a User

A user session token is required for authentication. See [Verify a User Credential to Obtain a User Token](#user-content-verify-a-user-credential-to-obtain-a-user-token) for more information on how to retrieve a user session token.

If you are using the Apto B2B API and have an existing user session token, you can set the user token with `setUserToken`, replacing `USER_TOKEN` with your user token:

```swift
AptoPlatform.defaultManager().setUserToken("USER_TOKEN")
```

**Note:** This is optional. If a session token is not provided, the SDK will obtain one by verifying the user.

## Manage Users

The SDK enables you to:

* [Create a New User](#user-content-create-a-new-user)
* [Login with an Existing User](#user-content-login-with-an-existing-user)
* [Update a User's Info](#user-content-update-a-users-info)
* [Close a User Session](#user-content-close-a-user-session)

### Create a New User

Once a user's primary credential is verified, you can create a new user using the `createUser` method.

1. Create a primary credential object and set its `verification` object.

	This example, creates a `PhoneNumber` object for project configurations that use a phone number as the primary credential.

```swift
// Prepare a DataPointList containing the verified user's primary credential.
let primaryCredential = PhoneNumber(countryCode, phoneNumber)
primaryCredential.verification = verification // The verification obtained before.
```

2. Create a `DataPointList` object and add the `primaryCredential`; then pass the `DataPointList` object into the `createUser` method to create a new user.

```swift
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

(Optional) You can send an arbitrary string (up to 256 characters) as metadata that will be attached to the user. To do this, just send the metadata parameter:

```swift
let userPII = DataPointList()
userPII.add(primaryCredential)
AptoPlatform.defaultManager().createUser(userData: userPII, metadata: "My data") { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let user):
    // The user created. It contains the user id and the user session token.
  }
}
```

* When the method succeeds, the `user` object contains the user ID and user session token.
* When the method fails, error handling can be included within the `error` response.

**Note:** The `createUser` method can accept an optional `custodianUid` parameter. Use this parameter to send Apto the user ID, so future webhook notifications can include this information. This simplifies the process of matching the user with the notification event. 
**Note:** The `createUser` method can accept an optional `metadata` parameter. Use this parameter to send Apto metadata about the new user (Max 256 chars).

```swift
let custodianUid = "your_platform_user_id"
AptoPlatform.defaultManager().createUser(userData: userPII, custodianUid: custodianUid) { [weak self] result in
  ...
}
```

### Login with an Existing User

Once the primary and secondary credentials are verified, you log the user in with the `loginUserWith` method and obtain a user token for the existing user.

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

* When the method succeeds, the `user` object contains the user ID and user session token.
* When the method fails, error handling can be included within the `error` response.


### Update a User's Info

You can update the user's info, with the `updateUserInfo` method:

1. Create a `DataPointList` object:

```swift
let userPII = DataPointList()
```

2. Pass the `userData` into the `updateUserInfo` method:

```swift
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

* When the method succeeds, the update is successful and the `user` object contains the updated user information.
* When the method fails, error handling can be included within the `error` response.


### Close a User Session

To close the current user's session, use the `logout` SDK method:

```swift
AptoPlatform.defaultManager().logout()
```

## Manage Card Programs

The SDK enables you to manage card programs. This document explains how to use the SDK to:

* [Get Available Card Programs](#user-content-get-available-card-programs)
* [Get Card Program Details](#user-content-get-card-program-details)

### Get Available Card Programs

To retrieve a list of all the available card programs, use the `fetchCardProducts` method:

```swift
AptoPlatform.defaultManager().fetchCardProducts() { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let cardProductSummary):
    // cardProductSummary is a CardProductSummary object
  }
}
```

* When the method succeeds, a `cardProducts` object is returned with a list of `CardProductSummary` objects, containing details for each card program.
* When the method fails, error handling can be included within the `error` response.


## Manage Cards

The SDK enables you to manage cards. This document explains how to use the SDK to:

* [Get Cards](#user-content-get-cards)
* [Get a Card by ID](#user-content-get-a-card-by-id)
* [Issue a Card](#user-content-issue-a-card)
* [Activate a Physical Card](#user-content-activate-a-physical-card)
* [Change a Card PIN](#user-content-change-a-card-pin)
* [Lock / Unlock a Card](#user-content-lock--unlock-a-card)
* [View Monthly Spending Stats](#user-content-view-monthly-spending-stats)

### Get Cards

To retrieve a list of cards for the current user, use the `fetchCards` method:

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

* When the method succeeds, a `cards` object is returned, containing a list of `Card` objects.
* When the method fails, error handling can be included within the `error` response.

### Get a Card by ID

To retrieve a card by ID, use the `fetchCardProduct` method:

```swift
AptoPlatform.defaultManager().fetchCardProduct(cardProductId) { [weak self] result in
  guard let self = self else { return }
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let cardProduct):
    // cardProduct is a CardProduct object
  }
}
```

* When the method succeeds, a `cardProduct` object is returned, containing a details for the card.
* When the method fails, error handling can be included within the `error` response.

### Issue a Card

To issue a card for the current user, use the `issueCard` method:

1. Generate a `Custodian` object. Use this object to set up your custodian data.

	**Note:** You may need to set the `externalCredentials` property.

```swift
let custodian = Custodian()
```

2. Retrieve a list of all the card programs using the `fetchCardProducts` method.

```swift
AptoPlatform.defaultManager().fetchCardProducts { result in
  switch result {
  case .failure(let error):
    // Do something with the error
  case .success(let cardProducts):
    
    ...
    
  }
}
```

3. with the returned `cardProducts` value, pass the card program you want to issue, into the `issueCard` method.

	If you have more than one card program, you may need to enable the user to select a specific card program. This example demonstrates how to issue a card for the first card program.
	
	**Note:** To retrieve details about the card program, use the `fetchCardProduct(cardProductId:forceRefresh:callback:)` method.

```swift    
    AptoPlatform.defaultManager().issueCard(cardProduct: cardProducts[0], custodian: custodian) { result in
      switch result {
      case .failure(let error):
        // Do something with the error
      case .success(let card):
        // card contains the issued Card object
      }
    }
```

* When the method succeeds, a `card` object is returned containing the issued card details.
* When the method fails, error handling can be included within the `error` response.


#### Issue a Card with Additional Info

The `issueCard` method also accepts two optional parameters:

* `additionalFields` - Use this parameter to send additional data that may be required for card issuance, but may not have been captured during the user creation process. For a list of allowed fields and values [contact us](mailto:developers@aptopayments.com).

* `initialFundingSourceId` - Use this parameter to specify the wallet ID connected to the issued card.
	
	**Note:** This only applies to debit card programs. For additional information regarding this parameter, [contact us](mailto:developers@aptopayments.com).

```swift
let additionalFields: [String: AnyObject] = [
  "field1": "value1",
  "field2": 2
]
let initialFundingSourceId = "initial_funding_source_id"
AptoPlatform.defaultManager().issueCard(cardProduct: cardProduct, custodian: custodian,
                                        additionalFields: additionalFields,
                                        initialFundingSourceId: initialFundingSourceId) { result in
  ...
}
```

### Activate a Physical Card

Physical cards need to be activated using the provided activation code sent to the cardholder.

To activate the physical card, use the `activatePhysicalCard` method:

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

* When the method succeeds, a `result` object is returned containing information about the activation process. If the activation fails, the `result` object will contain the reason for the failure.
* When the method fails, error handling can be included within the `error` response.


### Change a Card PIN

To set or change the card pin, use the `changeCardPin` method:

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

* When the method succeeds, a `card` object is returned containing information about the updated card.
* When the method fails, error handling can be included within the `error` response.


### Lock / Unlock a Card

Cards can be locked or unlocked at any time. Transactions using a locked card will be rejected by the merchant's POS.

#### Lock a Card

To lock a card, pass the account ID into the `lockCard` method:

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

* When the method succeeds, a `card` object is returned containing information about the locked card.
* When the method fails, error handling can be included within the `error` response.

#### Unlock a Card

To unlock a card, pass the account ID into the `unlockCard` method:

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

* When the method succeeds, a `card` object is returned containing information about the unlocked card.
* When the method fails, error handling can be included within the `error` response.

### View Monthly Spending Stats

The SDK enables you to view the monthly spending for cards, classified by category.

To retrieve information about the monthly spending for a card, use the `cardMonthlySpending` method with the following parameters:

* Card ID
* Spending month name (IE January, February, March, etc)
* Four-digit spending year (IE 2018, 2019, 2020, etc)

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

* When the method succeeds, a `monthlySpending` object is returned containing the stats for the provided month. The spending is classified by transaction category, and difference from the previous month.
* When the method fails, error handling can be included within the `error` response.

## Manage Funding Sources

The SDK enables you to:

* [Get a Card's Default Funding Source](#user-content-get-a-cards-default-funding-source)
* [List a Card's Available Funding Sources](#user-content-list-a-cards-available-funding-sources)
* [Connect a Funding Source to a Card](#user-content-connect-a-funding-source-to-a-card)

### Get a Card's Default Funding Source

To retrieve a card's default funding source, pass the card ID into the `fetchCardFundingSource` method.

**Note:** If no default funding source is specified, the first available funding source will be used as the default funding source.

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

* When the method succeeds, a `fundingSource` object is returned containing information about the funding source.
* When the method fails, error handling can be included within the `error` response.

### List a Card's Available Funding Sources

Apto cards may have multiple funding sources. To retrieve a list of available funding sources for a card, pass the card ID into the `fetchCardFundingSources` method.

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

* When the method succeeds, a `fundingSources` object is returned containing a list of `FundingSource` objects.
* When the method fails, error handling can be included within the `error` response.

### Connect a Funding Source to a Card

To connect a funding source to a card, pass the card ID and funding source ID into the `setCardFundingSource` method.

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

* When the method succeeds, a `fundingSource` object is returned containing information for the funding source.
* When the method fails, error handling can be included within the `error` response.


## Notification preferences

Push notifications for users are available for several events (transactions, card status changes, etc.). The SDK can enable the users to decide how they receive some of these notifications.

This document demonstrates how to:

* [Get Notification Preferences](#user-content-get-notification-preferences)
* [Update Notification Preferences](#user-content-update-notification-preferences)

### Get Notification Preferences

To retrieve the current user's notification preferences, use the `fetchNotificationPreferences` method.

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

* When the method succeeds, a `notificationPreferences` object is returned containing the information for current user's notification preferences.
* When the method fails, error handling can be included within the `error` response.

### Update Notification Preferences

To update the current user's notification preferences:

1. Create a `NotificationPreferences` object.

```swift
let preferences = NotificationPreferences()
```

2. Pass the preferences object into the `updateNotificationPreferences` method.

```swift
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

* When the method succeeds, a `notificationPreferences` object is returned containing the information for current user's notification preferences.
* When the method fails, error handling can be included within the `error` response.

## Manage Transactions

To retrieve a list of transactions, pass the following into the `fetchCardTransactions` method:

* `cardId` - The card ID
* `filters` - Array of type `Filter`, which filters the transactions by type.
* `forceRefresh` - Boolean value indicating if transactions should be retrieved from the Apto Mobile API or the local cached transaction list. If true, transactions are retrieved from the Apto Mobile API.

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

* When the method succeeds, a `transactions` object is returned containing a list of `Transaction` objects.
* When the method fails, error handling can be included within the `error` response.

## Contributions & Development

We look forward to receiving your feedback, including new feature requests, bug fixes and documentation improvements.

If you would like to help: 

1. Refer to the [issues](issues) section of the repository first, to ensure your feature or bug doesn't already exist (The request may be ongoing, or newly finished task).
2. If your request is not in the [issues](issues) section, please feel free to [create one](issues/new). We'll get back to you as soon as possible.

If you want to help improve the SDK by adding a new feature or bug fix, we'd be happy to receive [pull requests](compare)!
