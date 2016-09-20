
Pod::Spec.new do |s|
  s.name             = "FlickTransition"
  s.version          = "1.0.0"
  s.summary          = "A iOS UIViewController Transition"
  s.description      = <<-DESC
                      A iOS UIViewController Transition.
                       DESC
  s.homepage         = "https://github.com/NjrSea/FlickTransition"
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Paul" => "576330572@qq.com" }
  s.source           = { :git => "https://github.com/NjrSea/FlickTransition.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/NAME'

  s.platform     = :ios, '9.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'FlickTransition/*', 'FlickTransition/**/*'
  # s.resources = 'Assets'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'UIKit'

end
