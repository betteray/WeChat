# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'WeChat' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!
  pod 'FastSocket'
  pod 'ASIHTTPRequest'
  pod 'Protobuf'
  pod 'SDWebImage'
  pod 'Ono' # xml
  pod 'Realm'
  pod 'CocoaLumberjack'
  pod 'RegexKitLite'
  pod 'Json2pb' , :git => 'https://github.com/henrayluo/json2pb.git'
  pod 'IQKeyboardManager'
  pod 'MBProgressHUD', '~> 1.1.0'
  pod 'YYModel'
  
  # Pods for WeChat

  target 'WeChatTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Protobuf'
  end

  target 'WeChatUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
