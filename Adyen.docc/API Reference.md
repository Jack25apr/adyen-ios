# API Reference

The Adyen DropIn/Components SDK API Reference.

### Adyen Session

- ``AdyenSession``
- ``AdyenSessionDelegate``
- ``AdyenSessionPaymentsHandler``
- ``AdyenSessionPaymentDetailsHandler``

### Drop In Component

- ``DropInComponent``
- ``DropInComponentDelegate``
- ``PaymentMethodListConfiguration``
- ``StoredPaymentMethodsDelegate``

### Styling

- ``TextStyle``
- ``ButtonStyle``
- ``ImageStyle``
- ``CornerRounding``
- ``ToolbarMode``
- ``FormComponentStyle``
- ``FormTextItemStyle``
- ``FormToggleItemStyle``
- ``FormButtonItemStyle``
- ``ListComponentStyle``
- ``ListSectionHeaderStyle``
- ``ListSectionFooterStyle``
- ``ListItemStyle``
- ``ActionComponentStyle``
- ``AwaitComponentStyle``
- ``RedirectComponentStyle``
- ``VoucherComponentStyle``
- ``QRCodeComponentStyle``
- ``DocumentComponentStyle``
- ``NavigationStyle``
- ``CancelButtonStyle``
- ``ProgressViewStyle``
- ``ApplePayStyle``

### Basic Payment Methods

- ``PaymentMethod``
- ``PaymentMethods``
- ``StoredPaymentMethod``
- ``IssuerListPaymentMethod``
- ``AwaitPaymentMethod``
- ``VoucherPaymentMethod``
- ``QRCodePaymentMethod``
- ``DocumentPaymentMethod``

### Stored payment methods

- ``StoredPayPalPaymentMethod``
- ``StoredCardPaymentMethod``
- ``StoredBCMCPaymentMethod``
- ``StoredBLIKPaymentMethod``

### Actions

- ``Action``
- ``RedirectAction``
- ``ThreeDS2Action``
- ``ThreeDS2FingerprintAction``
- ``ThreeDS2ChallengeAction``
- ``AwaitAction``
- ``GenericVoucherAction``
- ``VoucherAction``
- ``DokuVoucherAction``
- ``MultibancoVoucherAction``
- ``BoletoVoucherAction``
- ``EContextATMVoucherAction``
- ``EContextStoresVoucherAction``
- ``OXXOVoucherAction``
- ``QRCodeAction``
- ``SDKAction``
- ``WeChatPaySDKAction``
- ``DocumentAction``
- ``AppleWalletError``

### Action-handling components

- ``AdyenActionComponent``
- ``VoucherComponent``
- ``QRCodeComponent``
- ``AwaitComponent``
- ``AwaitActionDetails``
- ``RedirectComponent``
- ``RedirectDetails``
- ``WeChatPaySDKActionComponent``
- ``DocumentComponent``

### Card Component

- ``AnyCardPaymentMethod``
- ``CardPaymentMethod``
- ``BCMCPaymentMethod``
- ``StoredCardPaymentMethod``
- ``StoredBCMCPaymentMethod``
- ``CardComponent``
- ``BCMCComponent``
- ``CardDetails``
- ``KCPDetails``
- ``CardFundingSource``
- ``CardType``
- ``CardBrand``
- ``CardExpiryDateFormatter``
- ``CardExpiryDateValidator``
- ``CardSecurityCodeFormatter``
- ``CardSecurityCodeValidator``
- ``CardNumberFormatter``
- ``CardNumberValidator``
- ``CardComponentDelegate``
- ``StoredCardConfiguration``
- ``InstallmentConfiguration``
- ``InstallmentOptions``
- ``Installments``

### 3D Secure 2 Component

- ``ThreeDS2Component``
- ``ThreeDS2Details``
- ``ThreeDS2Action``
- ``ThreeDS2FingerprintAction``
- ``ThreeDS2ChallengeAction``

### Apple Pay Component

- ``ApplePayPaymentMethod``
- ``ApplePayComponent``
- ``ApplePayDetails``

### Gift Card Component

- ``GiftCardComponent``
- ``GiftCardDetails``
- ``GiftCardPaymentMethod``

### SEPA Direct Debit Component

- ``SEPADirectDebitPaymentMethod``
- ``SEPADirectDebitComponent``
- ``SEPADirectDebitDetails``
- ``IBANFormatter``
- ``IBANValidator``

### BACS Direct Debit Component

- ``BACSDirectDebitPaymentMethod``
- ``BACSDirectDebitComponent``
- ``BACSDirectDebitDetails``

### ACH Direct Debit Component

- ``ACHDirectDebitPaymentMethod``
- ``ACHDirectDebitComponent``
- ``ACHDirectDebitDetails``

### Qiwi Wallet Component

- ``QiwiWalletPaymentMethod``
- ``QiwiWalletComponent``
- ``QiwiWalletDetails``

### Affirm Component

- ``AffirmPaymentMethod``
- ``AffirmComponent``
- ``AffirmDetails``

### BLIK Component

- ``BLIKPaymentMethod``
- ``StoredBLIKPaymentMethod``
- ``BLIKComponent``
- ``BLIKDetails``
          
### Boleto Component

- ``BoletoComponent``
- ``BoletoPaymentMethod``
- ``BoletoDetails``
    
### MBWay Component

- ``MBWayPaymentMethod``
- ``MBWayComponent``
- ``MBWayDetails``
    
### WeChat Pay
  
- ``WeChatPaySDKData``
- ``WeChatPayPaymentMethod``
- ``WeChatPaySDKActionComponent``
- ``WeChatPaySDKAction``
    
### Issuer List Component

- ``IssuerListComponent``
- ``IdealComponent``
- ``MOLPayComponent``
- ``DotpayComponent``
- ``EPSComponent``
- ``EntercashComponent``
- ``OpenBankingComponent``
- ``EntercashDetails``
- ``OpenBankingDetails``
- ``EPSDetails``
- ``DotpayDetails``
- ``MOLPayDetails``
- ``IdealDetails``
- ``IssuerListDetails``
    
### Instant Payment Component

- ``InstantPaymentMethod``
- ``InstantComponents``
- ``MultibancoPaymentMethod``
- ``MultibancoComponent``
- ``OXXOPaymentMethod``
- ``OXXOComponent``
    
### EContext Component

- ``EContextPaymentMethod``
- ``EContextATMComponent``
- ``EContextOnlineComponent``
- ``EContextStoreComponent``
- ``EContextATMVoucherAction``
- ``EContextStoresVoucherAction``
- ``SevenElevenPaymentMethod``
- ``SevenElevenComponent``

### Doku Component

- ``VoucherPaymentMethod``
- ``DokuPaymentMethod``
- ``DokuComponent``
- ``DokuDetails``
    
### Public Protocols

- ``Component``
- ``ComponentError``
- ``PaymentComponent``
- ``PresentableComponent``
- ``ActionComponent``
- ``FinalizableComponent``
- ``PaymentAwareComponent``
- ``PartialPaymentError``
- ``Details``
- ``AdditionalDetails``
- ``PaymentMethodDetails``
- ``AnyVoucherAction``

### Public delegates

- ``ActionComponentDelegate``
- ``PaymentComponentDelegate``
- ``PresentationDelegate``
- ``PartialPaymentDelegate``
- ``StoredPaymentMethodsDelegate``
    
### Models

- ``APIContext``
- ``Payment``
- ``Amount``
- ``Balance``
- ``ShopperName``
- ``PostalAddress``
- ``ShopperInteraction``
- ``DisplayInformation``
- ``CardFundingSource``
- ``BrowserInfo``
- ``ShopperInformation``
- ``PrefilledShopperInformation``
- ``PartialPaymentOrder``
- ``PaymentComponentData``
- ``ActionComponentData``
    
### Encryption

- ``CardEncryptor``
- ``BankDetailsEncryptor``
- ``Card``
- ``EncryptedCard``
- ``EncryptionError``
    
### Utilities

- ``AdyenLogging``
- ``Formatter``
- ``Sanitizer``
- ``BrazilSocialSecurityNumberFormatter``
- ``threeDS2SdkVersion``
- ``Validator``
- ``DateValidator``
- ``LengthValidator``
- ``LogoURLProvider``
- ``Localizable``
- ``LocalizationParameters``

