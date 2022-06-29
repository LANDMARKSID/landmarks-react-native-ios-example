# react-native-landmarks-id-lod
#### React native wrapper for LandmarksId LOD SDK

## Available Functions

- initialiseSDK(appId, appSecret, apiKey, isDebugMode)
- startTracking()
- stopTracking()
- terminateSDK()
- askForLocationPermissions()
- restartRecordingData()
- stopRecordingData()
- setCustomerId(id)
- sendCustomString(key, value)
- sendCustomInteger(key, value)
- sendCustomFloat(key, value)

## Installation

1. Install LandmarksIdLod dependency in your react-native app using either ```npm``` or ```yarn```.

- If the package has been published on ```NPM```, then use this
```sh
npm install react-native-landmarks-id-lod
```
- Otherwise install using local path. Path should lead to ```.tgz``` file. For example,
```sh
npm install ../react-native-landmarks-id-lod/react-native-landmarks-id-lod-1.0.0.tgz
```

2. Copy ```BDPointSDK.xcframework``` from /react-native-landmarks-id-lod/ios/lod/ and paste in your app's ios folder.

3. In XCode, follow these steps:
    - Select your app's target
    - Open General tab
    - In "Frameworks, Libraries, and Embedded Content" section, press plus (+) icon
    - Select "Add other...", from dropdown select "Add files"
    - Locate ```BDPointSDK.xcframework``` that you just copied and press open
    - Make sure ```BDPointSDK.xcframework``` is visible in  "Frameworks, Libraries, and Embedded Content" section, and "Embed & Sign" option is selected.

4. Last step, open your ```info.plist``` file as source code and add following piece of code in it

```sh
  <key>UIBackgroundModes</key>
  <array>
    <string>location</string>
  </array>
  
  <key>NSLocationAlwaysUsageDescription</key>
  <string>{Explaination for why you want these permissions}</string>
  
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>{Explaination for why you want these permissions}</string>
  
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>{Explaination for why you want these permissions}</string>
  
  <key>BDPointLocalNotificationEnabled</key>
  <false/>
```

## Generating Gzipped Tarball

Run this in the package's root directory,
```sh
npm pack
```
this will generate a ```.tgz``` file.
You have to re-pack the package every time you make a change to the module.
## License

MIT
