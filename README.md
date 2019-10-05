# react-native-mather-analytics

## Getting started

`$ npm install react-native-mather-analytics --save`

### Mostly automatic installation

`$ react-native link react-native-mather-analytics`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-mather-analytics` and add `MatherAnalytics.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libMatherAnalytics.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import com.matejdr.matheranalytics.MatherAnalyticsPackage;` to the imports at the top of the file
  - Add `new MatherAnalyticsPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-mather-analytics'
  	project(':react-native-mather-analytics').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-mather-analytics/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-mather-analytics')
  	```


## Usage
```javascript
import MatherAnalytics from 'react-native-mather-analytics';

// TODO: What to do with the module?
MatherAnalytics;
```
