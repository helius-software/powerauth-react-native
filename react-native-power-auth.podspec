require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-powerauth"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = "React Native PowerAuth component for iOS and Android"
  s.homepage     = "https://github.com/helius-software/powerauth-react-native"
  s.license      = "Apache 2.0"
  s.authors      = { "Helius Systems" => "info@helius-software.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/helius-software/powerauth-react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "PowerAuth2"
end
