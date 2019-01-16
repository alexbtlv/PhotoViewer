# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'PhotoViewer' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PhotoViewer

  plugin 'cocoapods-keys', {
  	:project => "PhotoViewer",
  	:target => "PhotoViewer",
  	:keys => [
    	"UnsplashAccessKey",
    	"UnsplashSecretKey"
  	]
  } 
  target 'PhotoViewerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PhotoViewerUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
