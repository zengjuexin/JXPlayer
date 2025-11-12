

Pod::Spec.new do |spec|

  spec.name         = "JXPlayer"
  spec.version      = "0.1.8"
  spec.summary      = "基于SJVideoPlayer写的播放列表"

  spec.description  = <<-DESC
		       播放列表，使用SJVideoPlayer开发，集成了缓存功能
                   DESC

  spec.homepage     = "https://github.com/zengjuexin/JXPlayer"


 # spec.license      = "MIT (example)"
  spec.license      = { :type => "MIT", :file => "LICENSE" }


  spec.author             = { "zeng" => "zengguexin@126.com" }


  spec.source       = { :git => "https://github.com/zengjuexin/JXPlayer.git", :tag => spec.version.to_s }


  spec.ios.deployment_target = '13.0'
  spec.swift_version    = '5.0'
  spec.source_files  = "Sources", "Sources/**/*.{h,m,swift}"
 # spec.exclude_files = "Classes/Exclude"

  spec.dependency 'SJVideoPlayer', '3.4.3'
  spec.dependency 'SJMediaCacheServer', '2.1.6'

end
