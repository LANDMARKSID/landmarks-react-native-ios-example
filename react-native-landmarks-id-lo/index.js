// main index.js

import { NativeModules } from 'react-native';

const { RNLandmarksIdLO } = NativeModules;

/**
 * Intialises the LandmarksId SDK. Should be called before using any other functions.
 * @param {*} appId : app id value for LandmarksId SDK
 * @param {*} appSecret : app secret value for LandmarksId SDK
 * @param {*} isDebugMode : true if the SDK should be initialised in debug mode
 */
export const initialiseSDK = (appId, appSecret, isDebugMode) => {
    RNLandmarksIdLO.initialiseSDK(appId, appSecret, isDebugMode);
}

/**
 * Should be called at the start of the app, or at the point where you want
 * LandmarksId SDK to start tracking
 */
export const startTracking = () => {
    RNLandmarksIdLO.startTracking();
}

/**
 * Should be called before app is closed, or at the point where you want
 * LandmarksId SDK to stop tracking
 */
export const stopTracking = () => {
    RNLandmarksIdLO.startTracking();
}

/**
 * Should be called right before app is going to be terminated/closed.
 */
export const terminateSDK = () => {
    RNLandmarksIdLO.terminate();
}

/**
 * Shows the dialog asking for permission to get user's location only when
 * app is being used.
 * If permissions has been granted or rejected before, then the dialog will 
 * not appear
 */
export const askForLocationPermissionsWhenInUse = () => {
    RNLandmarksIdLO.requestLocationWhenInUse();
}

/**
 * Shows the dialog asking for permission to get user's location even when
 * app is in the background.
 * If permissions has been granted or rejected before, then the dialog will 
 * not appear.
 * Background locations are needed for tracking in the background.
 */
export const askForLocationPermissionsAlways = () => {
    RNLandmarksIdLO.requestLocationAlways();
}

/**
 * These functions are designed for applications that have controls in place for managing device level data collection.
 * This function restarts recording data, if data recording has been paused or stopped.
 * App should be recording data for sending custom data in events.
 */
export const restartRecordingData = () => {
    RNLandmarksIdLO.restartRecordingData();
}

/**
 * These functions are designed for applications that have controls in place for managing device level data collection.
 * This function stops recording data for the user.
 * App should be recording data for sending custom data in events.
 */
export const stopRecordingData = () => {
    RNLandmarksIdLO.stopRecordingData();
}

/**
 * Set clients Customer ID.
 * These will be recorded by the LANDMARKS ID SDK with each location event.
 * @param {*} id :- Value of customer id.
 */
export const setCustomerId = (id) => {
    RNLandmarksIdLO.setCustomerId(id);
}

/**
 * Send custom string data in the events.
 * These will be recorded by the LANDMARKS ID SDK with each location event.
 * @param {*} key : Key for custom data.
 * @param {*} value : Value of custom data.
 */
export const sendCustomString = (key, value) => {
    RNLandmarksIdLO.sendCustomString(key, value);
}

/**
 * Send custom integer data in the events.
 * These will be recorded by the LANDMARKS ID SDK with each location event.
 * @param {*} key : Key for custom data.
 * @param {*} value : Value of custom data.
 */
export const sendCustomInteger = (key, value) => {
    RNLandmarksIdLO.sendCustomInteger(key, value);
}

/**
 * Send custom float data in the events.
 * These will be recorded by the LANDMARKS ID SDK with each location event.
 * @param {*} key : Key for custom data.
 * @param {*} value : Value of custom data.
 */
export const sendCustomFloat = (key, value) => {
    RNLandmarksIdLO.sendCustomFloat(key, value);
}
