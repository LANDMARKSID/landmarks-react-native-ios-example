# react-native-landmarks-id-lo
#### React native wrapper for LandmarksId LO SDK

## Available Functions

- initialiseSDK(appId, appSecret, isDebugMode)
- startTracking()
- stopTracking()
- terminateSDK()
- askForLocationPermissionsWhenInUse()
- askForLocationPermissionsAlways()
- restartRecordingData()
- stopRecordingData()
- setCustomerId(id)
- sendCustomString(key, value)
- sendCustomInteger(key, value)
- sendCustomFloat(key, value)

## Installation

1. Install LandmarksIdLo dependency in your react-native app using either ```npm``` or ```yarn```.

- If the package has been published on ```NPM```, then use this
```sh
npm install react-native-landmarks-id-lo
```
- Otherwise install using local path. Path should lead to ```.tgz``` file. For example,
```sh
npm install ../react-native-landmarks-id-lo/react-native-landmarks-id-lo-1.0.0.tgz
```

2. Add this line in your app's ```Podfile```, above the other pods (change version number to the latest one)

```sh
pod 'LandmarksID/LO', :git => 'https://github.com/LANDMARKSID/LandmarksID-iOS.git', :tag => '2.5.2'
```

3. Run ```pod install``` in your iOS folder

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
