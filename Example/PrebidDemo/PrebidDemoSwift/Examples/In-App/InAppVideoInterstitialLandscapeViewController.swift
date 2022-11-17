/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

import UIKit
import PrebidMobile

fileprivate let storedImpVideoInterstitialLandscape = "imp-prebid-video-interstitial-vertical"
fileprivate let storedResponseRenderingVideoInterstitialLandscape = "response-prebid-video-interstitial-landscape-with-end-card"

class InAppVideoInterstitialLandscapeViewController: UIViewController {

    // Prebid
    private var renderingInterstitial: InterstitialRenderingAdUnit!
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseRenderingVideoInterstitialLandscape
        createAd()
    }

    func createAd() {
        // Setup Prebid ad unit
        renderingInterstitial = InterstitialRenderingAdUnit(configID: storedImpVideoInterstitialLandscape)
        renderingInterstitial.adFormats = [.video]
        renderingInterstitial.delegate = self
        // Load ad
        renderingInterstitial.loadAd()
    }
    
    // MARK: - InterstitialAdUnitDelegate

    func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
        interstitial.show(from: self)
    }
    
    func interstitial(_ interstitial: InterstitialRenderingAdUnit, didFailToReceiveAdWithError error: Error?) {
        PrebidDemoLogger.shared.error("Interstitial Rendering ad unit did fail to receive ad with error: \(error)")
    }

}