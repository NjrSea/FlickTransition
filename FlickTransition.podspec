
Pod::Spec.new do |s|
  s.name             = "FlickTransition"
  s.version          = "1.0.1"
  s.summary          = "A iOS UIViewController Transition"
  s.description      = <<-DESC
                      A iOS UIViewController Transition.
                       DESC
  s.homepage         = "https://github.com/NjrSea/FlickTransition"
  s.license          = 'MIT'
  s.author           = { "Paul" => "576330572@qq.com" }
  s.source           = { :git => "https://github.com/NjrSea/FlickTransition.git", :tag => s.version }
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'FlickTransition/*', 'FlickTransition/**/*'
  s.frameworks = 'Foundation', 'UIKit'

end
