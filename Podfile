# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'YHDailyDemo' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for YHDailyDemo
	pod 'MLeaksFinder'
	pod 'FBRetainCycleDetector'
	pod 'JSONModel'
	pod 'YHNotificationCenter'

post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] ='9.0'
            end
        end
    end

end
