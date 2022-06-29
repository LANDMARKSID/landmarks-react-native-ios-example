# LANDMARKS_ID_iOS_SDK_LO

## V 2.1

## Support
- The LandmarksID SDK supports iOS 9.0 and above.

## Setup Instructions
**Usage**
1. Drag and drop the LandmarksIDiOSDK.framework into your project.
2. Drag and drop the LandmarksIDiOSDK.framework into your Project's Embedded Binaries.

**iOS Configuration Information**
- **Required background updates description**
 
  Starting from iOS 8, a usage description is required to be set in the applications `info.plist` when utilising Location services.
   
  1. Locate the app's `info.plist` file in the Supporting Files folder of the Xcode project.
  2.  for location permission request and description
    - a. If your app needs to track the location **while in use** you need to
        - Select the icon and select the following item, setting an appropriate description as the value.
         - `Privacy - Location When In Use Usage Description`
     - b. If your app needs to track the location **always** then you need to
        - Select the icon and select the following item, setting an appropriate description as the value.
         - `Privacy - Location Always Usage Description`


**Required background modes(only if the location permission is **always**)**
  1. Locate the app's `info.plist` file in the Supporting Files folder of the Xcode project.
  2. Select the file once to display the Key/Value pairs in the editor pane.
  3. Find an existing entry titled 'Required background modes' or create one if it does not exist.
  4. Select the (+) icon and select from the drop-down list provided: App registers for location updates.
 

**Edit the AppDelegate**
 
1. Import the LandmarksID SDK into `AppDelegate.swift` 
    ```swift
    import LandmarksIDSDK
    ```

2. Add `landmarksIdManager` as a property on the `AppDelegate`

    ```swift
    var landmarksIdManager: LandmarksIDManagerDelegate?
    ```

3. Add the following Snippets to the app delegate functions:

    `application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool`

    ```swift
    let appId = "APP_ID"
    let appSecret = "APP_SECRET"
    
    self.landmarksIdManager = LandmarksIDManagerDelegate.initialize(appId, appSecret: appSecret)
    
    landmarksIdManager?.setup()
    ```

    `applicationDidBecomeActive(_ application: UIApplication)`
    ```swift
    self.landmarksIDManager?.startTracking()
    ```

    `applicationDidEnterBackground(_ application: UIApplication)`
    ```swift
    self.landmarksIDManager?.stopTracking()
    ```
      `func applicationWillTerminate(_ application: UIApplication)`
    ```swift
    LandmarksIDManagerDelegate.sharedManager()?.applicationWillTerminate()
    ```

## Additional Controls

**Controlling Location Manager Access**

To avoid initiating unwanted location permission prompts, the LandmarksID SDK will only access the location manager when `allowLocationPermissionsRequest` is set to `true`. This should be set to true, after the application has used the location manager for the first time, or at any point, if the application wants the Landmarks ID SDK to handle location permission requests.


- If your app needs to track the location while in use then
```swift
LandmarksIDManagerDelegate.sharedManager()?.requestLocationPermissions(.authorizedWhenInUse)
```

- Otherwise, If your app needs to track the location always then 
 ```swift
LandmarksIDManagerDelegate.sharedManager()?.requestLocationPermissions(.authorizedAlways)
```


**Controlling User Data Collection**

These functions are designed for applications that have controls in place for managing device level data collection. When the `isAllowedToRecordData` function is set to `false` the Landmarks ID SDK will not record any data from the device.

- Checking if it is allowed to collect data for the user (Default: `true`).
    ```swift
    LandmarksIDManagerDelegate.sharedManager().isAllowedToRecordData()
    ```
- Stop recording data for the user.
    ```swift
    LandmarksIDManagerDelegate.sharedManager().stopRecordingData()
    ```
- Restart recording data for the user.
    ```swift
    LandmarksIDManagerDelegate.sharedManager().restartRecordingData()
    ```

### Sending Additional Data

User data that is collected by, or made available to, the application can be attach to the Landmarks ID SDK session as custom values. These will be recorded by the Landmarks ID SDK with each location event. Multiple custom values can be passed into each function.

**Standardised - Functions provisioned for specific user data**

  - Set Clients Customer ID
    ```swift
    LandmarksIDManagerDelegate.sharedManager().customerId = "CUSTOMER_ID"
    ```

**Custom - Functions provisioned for all other non specific user data**

  - Set an integer value
    ```swift
    LandmarksIDManagerDelegate.sharedManager().setCustomInt("rank", value: 12)
    ```

  - Set a float value
    ```swift
    LandmarksIDManagerDelegate.sharedManager().setCustomFloat("score", value: 23.29)
    ```

  - Set a string value
    ```swift
    LandmarksIDManagerDelegate.sharedManager().setCustomString("mobile", value: "123134323432")
    ```

## Files Size

SDK File Size - 1 MB (Compiled Size ~ 49 KB)

## Contact Details

If you have any further questions please do not hesitate to contact our friendly team at;

developers@landmarksid.com