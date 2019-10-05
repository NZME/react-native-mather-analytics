import { default as PageView } from './models/PageView';
import { default as Action } from './models/Action';
import { default as Impression } from './models/Impression';

declare class MatherAnalytics {
  private _accountName: string;
  private _accountNumber: string;

  /**
   * Save all tracker related data that is needed to call native methods.
   * @param accountName
   * @param accountNumber
   */
  constructor(accountName: string, accountNumber: string);

  /**
   * Track page view.
   * @param payload
   */
  trackPageView(
    payload: PageView
  ): void;

  /**
   * Track user action.
   * @param payload
   */
  trackAction(
    payload: Action
  ): void;

  /**
   * Track ad impression.
   * @param payload
   */
  trackImpression(
    payload: Impression
  ): void;
}

export default MatherAnalytics;
