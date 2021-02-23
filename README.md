# Mac_MOYU_CLI 

Mac Moyu Cli is a cli app running on macOS which helps you work with passion and Convenience

Mac_MOYU_CLI是一款运行于mac系统的命令行软件
通过敲击命令方便地工作和娱乐

### Requirements
* Mac OS X 11.0+
* Xcode 12.4+
* Swift 5

### Installation

###### 1.Manually Download Code
###### 2.Pod install
###### 3.Xcode->Run
###### 4.Xcode->Product->Archive and save to local storage
###### 5.Copy moyu/Products/usr/local/bin/moyu file to your mac /usr/local/bin file
###### 6.Open Terminal -> type moyu moyu -h and enjoy


### Known Issues
This project uses github libs below and should follow the pod version instruction
import Alamofire //https://github.com/Alamofire/Alamofire
import SwiftCLI //https://github.com/jakeheis/SwiftCLI#parameters
import Alamofire_Synchronous //https://github.com/Dalodd/Alamofire-Synchronous   Synchronous requests for Alamofire
import SwiftSoup //https://github.com/scinfu/SwiftSoup



pod file 

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'moyu' do
  # Comment the next line if you don't want to use dynamic frameworks
  #use_frameworks!
  pod 'Alamofire', '~> 4.0'
  pod 'SwiftCLI', git:'https://github.com/jakeheis/SwiftCLI.git'
  pod 'Alamofire-Synchronous', '~> 4.0'
  pod 'SwiftSoup'
  # Pods for moyu

end

```

If you want to know more please use issues.

