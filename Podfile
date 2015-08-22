platform :ios, '7.0'
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'

pod 'AFNetworking', '~> 2.5.3'
pod 'AFNetworkActivityLogger', '~>2.0.4'
pod 'AFHTTPSessionManager-AFUniqueGET', '~>0.5.1'
#
# pod 'SDWebImage', '~>3.7.2'
#
# pod 'FormatterKit', '~> 1.8.0'
# pod 'Realm', '~> 0.92.1'
# pod 'Realm+JSON', '~> 0.2.9'
# pod 'DZNCategories', '~> 1.2'
# pod 'libPhoneNumber-iOS', '~> 0.8.4'
# pod 'RKCategories', :git => 'https://github.com/Rich86man/RKCategories.git'
# pod 'Mixpanel', '~> 2.8.0'
# pod 'HockeySDK', '~> 3.6.4'
# pod 'JLRoutes', '~> 1.5'
# pod 'SHSPhoneComponent', '~> 2.15'
#
# pod 'XLForm', '~> 2.2'

prepare_command = <<-CMD
    SUPPORTED_LOCALES="['base', 'en']"
    find . -type d ! -name "*$SUPPORTED_LOCALES.lproj" | grep .lproj | xargs rm -rf
CMD