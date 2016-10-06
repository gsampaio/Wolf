Pod::Spec.new do |s|
  s.name = 'Wolf'
  s.version = '0.8.2'
  s.summary = 'An opinionated, protocol-oriented networking layer.'
  s.description = <<-DESC
Wolf approaches networking by bringing together the battle experience of Alamofire and the flexible power of Swift protocols.
                  DESC
  s.homepage = 'https://github.com/fellipecaetano/Wolf'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Fellipe Caetano' => 'fellipe.caetano4@gmail.com' }
  s.source = { :git => 'https://github.com/fellipecaetano/Wolf.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  s.subspec 'Basic' do |ss|
    ss.source_files = ['Wolf/Classes/**/*']
    ss.dependency 'Alamofire', '~> 4.0'
    ss.dependency 'BrightFutures', '~> 5.0'
    ss.exclude_files = ['Wolf/Classes/Argo/**/*', 'Wolf/Classes/Unbox/**/*']
  end
  s.subspec 'Unbox' do |ss|
    ss.source_files = ['Wolf/Classes/**/*']
    ss.dependency 'Alamofire', '~> 4.0'
    ss.dependency 'BrightFutures', '~> 5.0'
    ss.dependency 'Unbox', '~> 2.0'
    ss.exclude_files = ['Wolf/Classes/Argo/**/*']
  end
  s.default_subspec = 'Basic'
end
