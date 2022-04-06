/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import UIKit

public let refreshIntervalMin: TimeInterval  = 15
public let refreshIntervalMax: TimeInterval = 120
public let refreshIntervalDefault: TimeInterval  = 60

@objcMembers
public class AdUnitConfig: NSObject, NSCopying {

    // MARK: - Public properties
       
    public var configId: String
    
    public let adConfiguration = AdConfiguration();
    
    public var adFormats: Set<AdFormat> {
        didSet {
            updateAdFormat()
        }
    }
    
    public var adSize: CGSize
    
    public var minSizePerc: NSValue?
    
    public var adPosition = AdPosition.undefined

    public var contextDataDictionary: [String : [String]] {
        extensionData.mapValues { Array($0) }
    }

    public var nativeAdConfiguration: NativeAdConfiguration?

    // MARK: - Computed Properties
    
    public var additionalSizes: [CGSize]? {
        get { sizes }
        set { sizes = newValue }
    }
    
    var _refreshInterval: TimeInterval = refreshIntervalDefault
    public var refreshInterval: TimeInterval {
        get { _refreshInterval }
        set {
            if adConfiguration.winningBidAdFormat == .video {
                Log.warn("'refreshInterval' property is not assignable for Outstream Video ads")
                _refreshInterval = 0
                return
            }
            if newValue < 0 {
                _refreshInterval  = 0
            } else {
                let lowerClamped = max(newValue, refreshIntervalMin);
                let doubleClamped = min(lowerClamped, refreshIntervalMax);
                
                _refreshInterval = doubleClamped;
                
                if self.refreshInterval != newValue {
                    Log.warn("The value \(newValue) is out of range [\(refreshIntervalMin);\(refreshIntervalMax)]. The value \(_refreshInterval) will be used")
                }
            }
        }
    }

    // MARK: - Public Methods
    
    public convenience init(configId: String) {
        self.init(configId: configId, size: CGSize.zero)
    }
    
    public init(configId: String, size: CGSize) {
        self.configId = configId
        self.adSize = size
        
        adFormats = [.display]
        
        adConfiguration.autoRefreshDelay = 0
        adConfiguration.size = adSize
    }
    
    // MARK: - Context Data (imp[].ext.context.data)

    public func addContextData(key: String, value: String) {
        if extensionData[key] == nil {
            extensionData[key] = Set<String>()
        }
        
        extensionData[key]?.insert(value)
    }
    
    public func updateContextData(key: String, value: Set<String>) {
        extensionData[key] = value
    }
    
    public func removeContextData(for key: String) {
        extensionData.removeValue(forKey: key)
    }
    
    public func clearContextData() {
        extensionData.removeAll()
    }
    
    public func getContextData() -> [String: [String]] {
        contextDataDictionary
    }

    // MARK: - Context keywords (imp[].ext.context.keywords)

    public func addContextKeyword(_ newElement: String) {
        contextKeywords.insert(newElement)
    }

    public func addContextKeywords(_ newElements: Set<String>) {
        contextKeywords.formUnion(newElements)
    }
    
    public func removeContextKeyword(_ element: String) {
        contextKeywords.remove(element)
    }

    public func clearContextKeywords() {
        contextKeywords.removeAll()
    }

    public func getContextKeywords() -> Set<String> {
        contextKeywords
    }

    // MARK: - App Content (app.data)

    public func setAppContent(_ appContent: PBMORTBAppContent) {
        self.appContent = appContent
    }
    
    public func getAppContent() -> PBMORTBAppContent? {
        return appContent
    }
    
    public func clearAppContent() {
        appContent = nil
    }
    
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        if appContent == nil {
            appContent = PBMORTBAppContent()
        }
        
        if appContent?.data == nil {
            appContent?.data = [PBMORTBContentData]()
        }
        
        appContent?.data?.append(contentsOf: dataObjects)
    }

    public func removeAppContentData(_ dataObject: PBMORTBContentData) {
        if let appContentData = appContent?.data, appContentData.contains(dataObject) {
            appContent?.data?.removeAll(where: { $0 == dataObject })
        }
    }
    
    public func clearAppContentData() {
        appContent?.data?.removeAll()
    }
    
    // MARK: - User Data (user.data)
        
    public func getUserData() -> [PBMORTBContentData]? {
        return userData
    }
    
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        if userData == nil {
            userData = [PBMORTBContentData]()
        }
        userData?.append(contentsOf: userDataObjects)
    }
    
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        if let userData = userData, userData.contains(userDataObject) {
            self.userData?.removeAll { $0 == userDataObject }
        }
    }
    
    public func clearUserData() {
        userData?.removeAll()
    }
    
    // MARK: - The Prebid Ad Slot

    public func setPbAdSlot(_ newElement: String?) {
        pbAdSlot = newElement
    }

    public func getPbAdSlot() -> String? {
        return pbAdSlot
    }

    // MARK: - Private Properties
    
    private var extensionData = [String : Set<String>]()

    private var appContent: PBMORTBAppContent?

    private var userData: [PBMORTBContentData]?

    private var contextKeywords = Set<String>()
    
    private var sizes: [CGSize]?

    private var pbAdSlot: String?
    
    // MARK: - NSCopying
    
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let clone = AdUnitConfig(configId: self.configId, size: self.adSize)
        
        clone.adFormats = self.adFormats
        clone.adConfiguration.adFormats = self.adConfiguration.adFormats
        clone.adConfiguration.isInterstitialAd = self.adConfiguration.isInterstitialAd
        clone.adConfiguration.isOptIn = self.adConfiguration.isOptIn
        clone.nativeAdConfiguration = self.nativeAdConfiguration
        clone.adConfiguration.bannerParameters = clone.adConfiguration.bannerParameters
        clone.adConfiguration.videoParameters = clone.adConfiguration.videoParameters
        clone.adConfiguration.isMuted = self.adConfiguration.isMuted
        clone.adConfiguration.isSoundButtonVisible = self.adConfiguration.isSoundButtonVisible
        clone.adConfiguration.closeButtonPosition = self.adConfiguration.closeButtonPosition
        clone.adConfiguration.closeButtonArea = self.adConfiguration.closeButtonArea
        clone.adConfiguration.skipButtonArea = self.adConfiguration.skipButtonArea
        clone.adConfiguration.skipButtonPosition = self.adConfiguration.skipButtonPosition
        clone.adConfiguration.skipDelay = self.adConfiguration.skipDelay
        clone.sizes = sizes
        clone.refreshInterval = self.refreshInterval
        clone.minSizePerc = self.minSizePerc
        clone.extensionData = self.extensionData.merging(clone.extensionData) { $1 }
        clone.adPosition = self.adPosition
        
        return clone
    }
    
    // MARK: - Private Methods

    private func updateAdFormat() {
        if adConfiguration.adFormats == adFormats {
            return
        }
        
        self.adConfiguration.adFormats = adFormats
        self.refreshInterval = (adConfiguration.winningBidAdFormat == .video) ? 0 : refreshIntervalDefault;
    }
}
