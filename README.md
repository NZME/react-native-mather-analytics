# react-native-mather-analytics

## Getting started

`$ npm install react-native-mather-analytics --save`

### Mostly automatic installation

`$ react-native link react-native-mather-analytics`

- Add `resolver` entry into `metro.config.js` or `rn-cli.config.js` if it does not work.
  - Note that it is [workaround](https://github.com/facebook/react-native/issues/21242#issuecomment-445784118), so you should remove when it's no longer needed

```js
const blacklist = require('metro-config/src/defaults/blacklist');

module.exports = {
  resolver: {
    blacklistRE: blacklist([/node_modules\/.*\/node_modules\/react-native\/.*/])
  }
};
```

### iOS

- Make `Podfile` and `pod install && pod update`

### Android

- Add maven source to repositories in `android/build.gradle`
- [Enables multiDex](https://developer.android.com/studio/build/multidex).

```gradle
allprojects {
  repositories {
      maven {
          // Mather SDK repository
          url "https://s3.amazonaws.com/android-listener/mvn-repo"
      }
  }
}
```
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
import { MatherAnalytics } from 'react-native-mather-analytics';

    const matherAnalytics = new MatherAnalytics('ma01278', '96248264');
    console.log('Firing trackPageView');
    matherAnalytics.trackPageView({
      pageUrl: 'http://www.mynewspaper.com',
      pageTitle: 'Time for Sports',
      referrer: 'http://www.anothernewspaper.com',
      userId: {
        user: 'doug@mynewspaper.com',
        loggedIn: true,
      },
      section: 'sports',
      author: 'by author one and author two',
      pageType: 'article',
      articlePublishTime: {
        time: '2016-05-05T15:41:38',
        timeZone: 'America/Los_Angeles',
        format: "yyyy-MM-dd'T'HH:mm:ss",
      },
      premium: true,
      metered: '1|5',
      publication: 'The Reader News',
      categories: [
        'structure',
        'structure/home_page',
        'columbus',
        'ohio',
        'new',
        'sports',
      ],
      appName: 'Best News Reader',
      referenceNav: 'SectionScroll',
      articleId: '3245671.b',
      articleUpdateTime: {
        time: '2016-05-06T16:41:38',
        timeZone: 'America/Los_Angeles',
        format: "yyyy-MM-dd'T'HH:mm:ss",
      },
      hierarchy: [
        'sports',
        'local',
        'highschool',
      ],
      email: 'kurt@gmail.com',
      articleSource: 'AP',
      mediaType: 'video',
      articleType: 'editorial',
      characterCount: '25000',
      wordCount: '1200',
      paragraphCount: '33',
      scrollPercent: '50',
      pageNumber: 'A5',
      addCtxSection: {
        name: 'identities',
        value: {
          'type': 'paywallUserId',
          'id': 'paywallUserId',
        },
      },
      userDB: {
        minPageViews: 2,
        timeoutMs: 10000,
        noCache: false,
        userDBUr: 'https://app.matheranalytics.com',
      },
    });

    console.log('Firing trackAction');
    matherAnalytics.trackAction({
      type: 'paywall',
      category: 'block',
      action: 'stop',
      custom: {
        name: 'vendor',
        value: 'custom',
      },
    });

    console.log('Firing trackImpression');
    matherAnalytics.trackImpression({
      eaid: '263509965',
      ebuy: '380850765',
      eadv: '83331405',
      ecid: '97302828285',
      epid: '101145405',
      esid: '100998765',
      custom: {
        name: 'server',
        value: 'adx',
      },
    });

```
