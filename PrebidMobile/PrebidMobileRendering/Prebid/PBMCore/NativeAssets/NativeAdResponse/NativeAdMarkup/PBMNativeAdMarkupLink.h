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

#import "PBMJsonDecodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdMarkupLink : NSObject <PBMJsonDecodable>

/// Landing URL of the clickable link.
@property (nonatomic, copy, nullable) NSString *url;

/// List of third-party tracker URLs to be fired on click of the URL.
@property (nonatomic, copy, nullable) NSArray<NSString *> *clicktrackers;

/// Fallback URL for deeplink.
/// To be used if the URL given in url is not supported by the device.
@property (nonatomic, copy, nullable) NSString *fallback;

/// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *ext;

- (instancetype)initWithUrl:(nullable NSString *)url;

@end

NS_ASSUME_NONNULL_END
