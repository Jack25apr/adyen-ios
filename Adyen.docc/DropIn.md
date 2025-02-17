# DropIn

The Drop-in handles the presentation of available payment methods and the subsequent entry of a customer's payment details. It is initialized with the response of `/paymentMethods`, and provides everything you need to make an API call to `/payments` and `/payments/details`.

### Presenting the Drop-in

The Drop-in requires the response of the `/paymentMethods` endpoint to be initialized. To pass the response to Drop-in, decode the response to the `PaymentMethods` structure:

```swift
let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: response)
```

All Components need an `APIContext`. An instance of `APIContext` wraps your client key and an environment.
Please read more [here](https://docs.adyen.com/development-resources/client-side-authentication) about the client key and how to get.
Use **Environment.test** for environment. When you're ready to accept live payments, change the value to one of our [live environments](https://adyen.github.io/adyen-ios/Docs/Structs/Environment.html)

```swift
let apiContext = APIContext(clientKey: clientKey, environment: Environment.test)
let configuration = DropInComponent.Configuration(apiContext: apiContext)
```

Some payment methods need additional configuration. For example `ApplePayComponent`. These payment method specific configuration parameters can be set in an instance of `DropInComponent.Configuration`:

```swift
let summaryItems = [
                      PKPaymentSummaryItem(label: "Item A", amount: 75, type: .final),
                      PKPaymentSummaryItem(label: "Item B", amount: 25, type: .final),
                      PKPaymentSummaryItem(label: "Total", amount: 100, type: .final)
                   ]

let configuration = DropInComponent.Configuration(apiContext: apiContext)
configuration.payment = payment
configuration.applePay = .init(summaryItems: summaryItems,
                               merchantIdentifier: "merchant.com.adyen.MY_MERCHANT_ID")
```

Also for voucher payment methods like Doku variants, in order for the `DokuComponent` to enable the shopper to save the voucher, access to the shopper photos is requested, so a suitable text need to be added to key  `NSPhotoLibraryAddUsageDescription` in the application Info.plist.

After serializing the payment methods and creating the configuration, the Drop-in is ready to be initialized. Assign a `delegate` and use the `viewController` property to present the Drop-in on the screen:

```swift
let dropInComponent = DropInComponent(paymentMethods: paymentMethods, configuration: configuration)
dropInComponent.delegate = self
present(dropInComponent.viewController, animated: true)
```
#### Implementing DropInComponentDelegate

To handle the results of the Drop-in, the following methods of `DropInComponentDelegate` should be implemented:

---

```swift
func didSubmit(_ data: PaymentComponentData, for paymentMethod: PaymentMethod, from component: DropInComponent)
```

This method is invoked when the customer has selected a payment method and entered its payment details. The payment details can be read from `data.paymentMethod` and can be submitted as-is to `/payments`.

---

```swift
func didProvide(_ data: ActionComponentData, from component: DropInComponent)
```

This method is invoked when additional details are provided by the Drop-in after the first call to `/payments`. This happens, for example, during the 3D Secure 2 authentication flow or any redirect flow. The additional details can be retrieved from `data.details` and can be submitted to `/payments/details`.

---

```swift
func didFail(with error: Error, from component: DropInComponent)
```

This method is invoked when an error occurred during the use of the Drop-in. Dismiss the Drop-in's view controller and display an error message.

---

```swift
func didComplete(from component: DropInComponent)
```

This method is invoked when the action component finishes, without any further steps needed by the application, for example in case of voucher payment methods. The application just needs to dismiss the `DropInComponent`.

---

```swift
func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent)
```

This optional method is invoked when user closes a payment component managed by Drop-in.

---

```swift
func didOpenExternalApplication(component: DropInComponent)
```

This optional method is invoked after a redirect to an external application has occurred.

---

### Handling an action

When `/payments` or `/payments/details` responds with a non-final result and an `action`, you can use one of the following techniques.

#### Using Drop-in

In case of Drop-in integration you must use build-in action handler on the current instance of `DropInComponent`:

```swift
let action = try JSONDecoder().decode(Action.self, from: actionData)
dropInComponent.handle(action)
```

#### Using components

In case of using individual components - not Drop-in -, create and persist an instance of `AdyenActionComponent`:

```swift
lazy var actionComponent: AdyenActionComponent = {
    let handler = AdyenActionComponent(apiContext: apiContext)
    handler.delegate = self
    handler.presentationDelegate = self
    return handler
}()
```

Than use it to handle the action:

```swift
let action = try JSONDecoder().decode(Action.self, from: actionData)
actionComponent.handle(action)
```

#### Receiving redirect

In case the customer is redirected to an external URL or App, make sure to let the `RedirectComponent` know when the user returns to your app. Do this by implementing the following in your `UIApplicationDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
    RedirectComponent.applicationDidOpen(from: url)

    return true
}
```
