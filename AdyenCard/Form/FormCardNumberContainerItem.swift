//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A form item which consists of card number item and the supported card icons below.
internal final class FormCardNumberContainerItem: FormItem, AdyenObserver {
    
    /// The supported card type logos.
    internal let cardTypeLogos: [FormCardLogosItem.CardTypeLogo]
    
    internal var identifier: String?
    
    internal let style: FormTextItemStyle
    
    private let localizationParameters: LocalizationParameters?
   
    internal lazy var subitems: [FormItem] = [numberItem, supportedCardLogosItem]
    
    internal lazy var numberItem: FormCardNumberItem = {
        let item = FormCardNumberItem(cardTypeLogos: cardTypeLogos,
                                      style: style,
                                      localizationParameters: localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "numberItem")
        return item
    }()
    
    internal lazy var supportedCardLogosItem: FormCardLogosItem = {
        let item = FormCardLogosItem(cardLogos: cardTypeLogos, style: style)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "supportedCardLogosItem")
        return item
    }()
    
    internal init(cardTypeLogos: [FormCardLogosItem.CardTypeLogo],
                  style: FormTextItemStyle,
                  localizationParameters: LocalizationParameters?) {
        self.cardTypeLogos = cardTypeLogos
        self.localizationParameters = localizationParameters
        self.style = style
        
        observe(numberItem.$isActive) { [weak self] isActive in
            guard let self = self else { return }
            // logo item only visible when number item is active or when it's invalid
            let hidden = !isActive && self.numberItem.isValid()
            self.supportedCardLogosItem.isHidden.wrappedValue = hidden
        }
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    internal func update(brands: [CardBrand]) {
        supportedCardLogosItem.update(brands: brands)
        numberItem.update(brands: brands)
    }
}

/// Form item to display multiple card logos.
internal final class FormCardLogosItem: FormItem, Hidable {
    
    internal var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    internal var identifier: String?
    
    internal var subitems: [FormItem] = []
    
    internal let style: FormTextItemStyle
    
    @AdyenObservable([]) internal var cardLogos: [CardTypeLogo]
    
    internal init(cardLogos: [CardTypeLogo], style: FormTextItemStyle) {
        self.style = style
        self.cardLogos = cardLogos
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    fileprivate func update(brands: [CardBrand]) {
        let containsSupportedBrand = brands.contains(where: \.isSupported)
        cardLogos = cardLogos.map { logo in
            var logoCopy = logo
            if containsSupportedBrand {
                logoCopy.alpha = brands.contains { $0.type == logoCopy.type } ? 1 : 0.3
            } else {
                logoCopy.alpha = 1
            }
            return logoCopy
        }
    }
    
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardLogosItem) -> FormItemView<FormCardLogosItem> {
        FormCardLogosItemView(item: item)
    }
    
    internal func build(with item: FormCardNumberContainerItem) -> FormItemView<FormCardNumberContainerItem> {
        FormCardNumberContainerItemView(item: item, itemSpacing: 0)
    }
}

extension FormCardLogosItem {
    /// Describes a card type logo shown in the card number form item.
    internal struct CardTypeLogo: Equatable {
        
        internal let type: CardType
        
        /// The URL of the card type logo.
        internal let url: URL
        
        internal var alpha: Float
        
        /// Initializes the card type logo.
        ///
        /// - Parameter cardType: The card type for which to initialize the logo.
        internal init(url: URL, type: CardType, alpha: Float = 1) {
            self.url = url
            self.type = type
            self.alpha = alpha
        }
        
        internal static func == (lhs: FormCardLogosItem.CardTypeLogo, rhs: FormCardLogosItem.CardTypeLogo) -> Bool {
            lhs.url == rhs.url && lhs.type == rhs.type && lhs.alpha == rhs.alpha
        }
    }
}
