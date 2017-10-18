#
# Be sure to run `pod lib lint PictureInPicture.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PictureInPicture'
  s.version          = '0.3.0'
  s.summary          = 'Picture in Picture.'

  s.description      = <<-DESC
Picture in Picture with your ViewController.
                       DESC

  s.homepage         = 'https://github.com/malt03/PictureInPicture'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Koji Murata' => 'malt.koji@gmail.com' }
  s.source           = { :git => 'https://github.com/malt03/PictureInPicture.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PictureInPicture/Classes/**/*'
end
