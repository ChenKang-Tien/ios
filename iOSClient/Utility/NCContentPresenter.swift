//
//  NCContentPresenter.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 23/12/2019.
//  Copyright © 2019 TWS. All rights reserved.
//

import SwiftEntryKit
import UIKit
import CFNetwork

class NCContentPresenter: NSObject {
    @objc static let shared: NCContentPresenter = {
        let instance = NCContentPresenter()
        return instance
    }()
        
    typealias MainFont = Font.HelveticaNeue
    enum Font {
        enum HelveticaNeue: String {
            case ultraLightItalic = "UltraLightItalic"
            case medium = "Medium"
            case mediumItalic = "MediumItalic"
            case ultraLight = "UltraLight"
            case italic = "Italic"
            case light = "Light"
            case thinItalic = "ThinItalic"
            case lightItalic = "LightItalic"
            case bold = "Bold"
            case thin = "Thin"
            case condensedBlack = "CondensedBlack"
            case condensedBold = "CondensedBold"
            case boldItalic = "BoldItalic"
            
            func with(size: CGFloat) -> UIFont {
                return UIFont(name: "HelveticaNeue-\(rawValue)", size: size)!
            }
        }
    }
    
    @objc enum messageType: Int {
        case error
        case success
        case info
    }
    
    //MARK: - Message
    
    @objc func messageNotification(_ title: String, description: String?, delay: TimeInterval, type: messageType, errorCode: Int) {
                       
        DispatchQueue.main.async {
            switch errorCode {
            case Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue):
                let image = CCGraphics.changeThemingColorImage(UIImage(named: "networkInProgress")!, width: 40, height: 40, color: .white)
                self.noteTop(text:  NSLocalizedString(title, comment: ""), image: image, color: .lightGray, delay: delay, name: "\(errorCode)")
            //case Int(kOCErrorServerUnauthorized), Int(kOCErrorServerForbidden):
            //    break
            default:
                var description = description
                if description == nil { description = "" }
                self.flatTop(title: NSLocalizedString(title, comment: ""), description: NSLocalizedString(description!, comment: ""), delay: delay, imageName: nil, type: type, name: "\(errorCode)")
            }
        }
    }
    
    //MARK: - Flat message
    
    @objc func flatTop(title: String, description: String, delay: TimeInterval, imageName: String?, type: messageType, name: String?) {
     
        if name != nil && SwiftEntryKit.isCurrentlyDisplaying(entryNamed: name) { return }
        
        var attributes = EKAttributes.topFloat
        var image: UIImage?
        
        attributes.windowLevel = .normal
        attributes.displayDuration = delay
        attributes.name = name
        attributes.entryBackground = .color(color: EKColor(getBackgroundColorFromType(type)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)

        let title = EKProperty.LabelContent(text: title, style: .init(font:  MainFont.bold.with(size: 16), color: .white))
        let description = EKProperty.LabelContent(text: description, style: .init(font:  MainFont.medium.with(size: 13), color: .white))
        
        if imageName == nil {
            image = getImageFromType(type)
        } else {
            image = UIImage(named: imageName!)
        }
        let imageMessage = EKProperty.ImageContent(image: image!, size: CGSize(width: 35, height: 35))

        let simpleMessage = EKSimpleMessage(image: imageMessage, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        DispatchQueue.main.async { SwiftEntryKit.display(entry: contentView, using: attributes) }
    }
   
    @objc func flatBottom(title: String, description: String, delay: TimeInterval, image: UIImage, type: messageType, name: String?) {
        
        if name != nil && SwiftEntryKit.isCurrentlyDisplaying(entryNamed: name) { return }
           
        var attributes = EKAttributes.bottomFloat
           
        attributes.windowLevel = .normal
        attributes.displayDuration = delay
        attributes.name = name
        attributes.entryBackground = .color(color: EKColor(getBackgroundColorFromType(type)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.positionConstraints.verticalOffset = 60
        
        let title = EKProperty.LabelContent(text: title, style: .init(font:  MainFont.bold.with(size: 16), color: .white))
        let description = EKProperty.LabelContent(text: description, style: .init(font:  MainFont.medium.with(size: 13), color: .white))
        let imageMessage = EKProperty.ImageContent(image: image, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: imageMessage, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
           
        let contentView = EKNotificationMessageView(with: notificationMessage)
        
        DispatchQueue.main.async {
            SwiftEntryKit.dismiss(.displayed)
            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
    }
    
    //MARK: - Note Message
    
    @objc func noteTop(text: String, image: UIImage?, color: UIColor, delay: TimeInterval, name: String?) {
        
        var attributes = EKAttributes.topNote
        
        attributes.windowLevel = .normal
        attributes.displayDuration = delay
        attributes.name = name
        attributes.entryBackground = .color(color: EKColor(color))
        
        let style = EKProperty.LabelStyle(font: MainFont.light.with(size: 14), color: .white, alignment: .center)
        let labelContent = EKProperty.LabelContent(text: text, style: style)
        
        if let image = image {
            let imageContent = EKProperty.ImageContent(image: image, size: CGSize(width: 17, height: 17))
            let contentView = EKImageNoteMessageView(with: labelContent, imageContent: imageContent)
            DispatchQueue.main.async { SwiftEntryKit.display(entry: contentView, using: attributes) }
        } else {
            let contentView = EKNoteMessageView(with: labelContent)
            DispatchQueue.main.async { SwiftEntryKit.display(entry: contentView, using: attributes) }
        }
    }
    
    //MARK: - Dismiss
    
    @objc func dismissAll() {
        DispatchQueue.main.async { SwiftEntryKit.dismiss(.all) }
    }
    
    @objc func dismissDisplayed() {
        DispatchQueue.main.async { SwiftEntryKit.dismiss(.displayed) }
    }
    
    //MARK: - Private

    private func getBackgroundColorFromType(_ type: messageType) -> UIColor {
        switch type {
        case .info:
            return NCBrandColor.sharedInstance.brand
        case .error:
            return UIColor(red: 1, green: 0, blue: 0, alpha: 0.9)
        case .success:
            return UIColor(red: 0.588, green: 0.797, blue: 0, alpha: 0.9)
        default:
            return .white
        }
    }
    
    private func getImageFromType(_ type: messageType) -> UIImage? {
        switch type {
        case .info:
            return UIImage(named: "iconInfo")
        case .error:
            return UIImage(named: "iconError")
        case .success:
            return UIImage(named: "iconSuccess")
        default:
            return nil
        }
    }
    
}
