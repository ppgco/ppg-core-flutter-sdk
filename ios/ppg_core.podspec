#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ppg_core.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ppg_core'
  s.version          = '0.0.7'
  s.summary          = 'PushPushGo Core SDK'
  s.description      = <<-DESC
  PushPushGo Core SDK for Flutter (Dart)
  Supports iOS and Android (Firebase/HMS)
                       DESC
  s.homepage         = 'https://github.com/ppgco/ppg-core-flutter-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'PushPushGo Core Developers' => 'mateusz@pushpushgo.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'PpgCoreSDK'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
