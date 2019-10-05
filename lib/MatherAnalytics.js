/**
 * @format
 * @jsdoc
 */

'use strict';

import { NativeModules } from 'react-native';
const RCTMatherAnalytics = NativeModules.MatherAnalytics;

if (!RCTMatherAnalytics) {
  throw new Error(`[@RNC/MatherAnalytics]: NativeModule: MatherAnalytics is null.

To fix this issue try these steps:

  • Run \`react-native link react-native-mather-analytics\` in the project root.

  • Rebuild and restart the app.

  • Run the packager with \`--clearCache\` flag.

  • If you are using CocoaPods on iOS, run \`pod install\` in the \`ios\` directory and then rebuild and re-run the app.

If none of these fix the issue, please open an issue on the Github repository: https://github.com/matejdr/react-native-mather-analytics/issues
`);
}

export default class MatherAnalytics {
  _accountName;
  _accountNumber;

  /**
   * Initialise the tracker with account name and account number
   * @param accountName
   * @param accountNumber
   */
  constructor(accountName, accountNumber) {
    this._accountName = accountName;
    this._accountNumber = accountNumber;
  }

  /**
   * Track page view using PageView Object
   * @param payload
   */
  trackPageView(payload) {
    RCTMatherAnalytics.trackPageView(
      this._accountName,
      this._accountNumber,
      payload,
    );
  }

  /**
   * Track user action using Action Object
   * @param payload
   */
  trackAction(payload) {
    RCTMatherAnalytics.trackAction(
      this._accountName,
      this._accountNumber,
      payload,
    );
  }

  /**
   * Track impression using Impression Object
   * @param payload
   */
  trackImpression(payload) {
    RCTMatherAnalytics.trackImpression(
      this._accountName,
      this._accountNumber,
      payload,
    );
  }
}
