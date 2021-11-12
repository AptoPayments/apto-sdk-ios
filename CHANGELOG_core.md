## CHANGELOG AptoSDK

# 2021-10-11 Version 3.8.0
- improvement: added format field to Card object with default fallback of virtual.
- improvement: new `fetchCards` method support pagination.
- deprecation: old method ´fetchCards´ has been replaced by a new implementation with the same name and different signature. See the documentation for details. 
- fix: remove deprecated method `issueCard`.
- fix: processed the error when the backend sends a wrong country to avoid the app to crash.
- fix: resolved crash in `saveFundingSources`.
- fix: resolved crash on `PieCharView`.

# 2021-09-15 Version 3.6.0
- feature: added In-App Provisioning.

# 2021-07-09 Version 3.5.0
- chore(improvement): update error codes and provide a localisable descriptions.

# 2021-05-26 Version 3.4.0
- fix: improved ImageCache definition and persistent storage.
- improvement: added backend provided error message to the global `BackendError` object.
- improvement: enabled ´authenticateOnStartup´ card option by default.
- improvement: updated AlamoFire dependency to the 5.4.3 version.
- fix: added the card logo on the main card screen.

# 2021-04-26 Version 3.3.0
- improvement: addeda new parameter on card issue, IssueCardDesign, to specify additional information for the new card. Please, refer to the public documentation for more details.
