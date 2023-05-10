# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'Trivio! (iOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Trivio! (iOS)
  pod 'Firebase/Analytics'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'FirebaseFirestoreSwift', '~> 7.11.0-beta'
  pod 'Introspect'
  pod 'GoogleSignIn', '~> 6.2'
end

# target 'Trivio! (macOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!

  # Pods for Trivio! (macOS)
  # pod 'Firebase/Analytics'
  # pod 'Firebase/Firestore'
  # pod 'Firebase/Auth'
  # pod 'FirebaseFirestoreSwift', '~> 7.11.0-beta'
  
# end

# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'Trivio! (iOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Trivio! (iOS)
  pod 'Firebase/Analytics'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'FirebaseFirestoreSwift', '~> 7.11.0-beta'
  pod 'Introspect'
  pod 'GoogleSignIn', '~> 6.2'
end

# target 'Trivio! (macOS)' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!

  # Pods for Trivio! (macOS)
  # pod 'Firebase/Analytics'
  # pod 'Firebase/Firestore'
  # pod 'Firebase/Auth'
  # pod 'FirebaseFirestoreSwift', '~> 7.11.0-beta'
  
# end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
