Pod::Spec.new do |s|
  s.name             = 'glass_bottom_navigation'
  s.version          = '0.1.0'
  s.summary          = 'Glass bottom navigation for Flutter.'
  s.description      = 'A customizable frosted glass bottom navigation bar with native iOS Liquid Glass action buttons.'
  s.homepage         = 'https://github.com/hame-dev/glass_bottom_navigation.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'glass_bottom_navigation' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.swift_version = '5.9'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
