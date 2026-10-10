Pod::Spec.new do |s|
  s.name = 'AICOpenCV'
  s.version = '4.10.0.2'
  s.summary = 'OpenCV 4.10.0 for iOS 15 and Apple Silicon Simulator.'
  s.homepage = 'https://github.com/FromApeToMen/AICOpenCV'
  s.license = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author = { 'FromApeToMen' => 'https://github.com/FromApeToMen' }
  s.source = { :git => 'https://github.com/FromApeToMen/AICOpenCV.git', :tag => s.version.to_s }
  s.platform = :ios, '15.0'
  s.static_framework = true
  s.vendored_frameworks = 'opencv2.xcframework'
  s.preserve_paths = 'third-party-licenses/**/*'
  s.libraries = 'c++'
  s.frameworks = 'AVFoundation', 'UIKit', 'CoreGraphics', 'CoreImage', 'CoreMedia', 'CoreVideo', 'QuartzCore', 'Accelerate'
end
