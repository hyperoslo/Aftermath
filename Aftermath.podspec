Pod::Spec.new do |s|
  s.name             = "Aftermath"
  s.summary          = "Stateless message-driven micro-framework in Swift."
  s.version          = "1.1.0"
  s.homepage         = "https://github.com/hyperoslo/Aftermath"
  s.license          = 'MIT'
  s.author           = {
    "Hyper Interaktiv AS" => "ios@hyper.no"
  }
  s.source           = {
    :git => "https://github.com/hyperoslo/Aftermath.git",
    :tag => s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/hyperoslo'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.2'

  s.requires_arc = true
  s.ios.source_files = 'Sources/**/*'
  s.tvos.source_files = 'Sources/**/*'
  s.osx.source_files = 'Sources/**/*'

  s.frameworks = 'Foundation'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
