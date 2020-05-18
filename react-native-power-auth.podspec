require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-power-auth"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = "React Native PowerAuth component for iOS + Android"
  s.homepage     = "https://github.com/helius-software/powerauth-react-native"
  # brief license entry:
  s.license      = "Apache 2.0"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "Apache 2.0", :file => "LICENSE" }
  s.authors      = { "Helius Systems" => "yourname@email.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/helius-software/powerauth-react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  # ...
  # s.dependency "..."
end

