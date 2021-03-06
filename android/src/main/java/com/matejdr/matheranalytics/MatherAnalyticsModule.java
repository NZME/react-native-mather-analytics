package com.matejdr.matheranalytics;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.LifecycleEventListener;

import com.matheranalytics.listener.tracker.MListener;
import com.matheranalytics.listener.tracker.MUserDB;
import com.matheranalytics.listener.tracker.MUtil;
import com.matheranalytics.listener.tracker.events.MPageView;
import com.matheranalytics.listener.tracker.events.MActionEvent;
import com.matheranalytics.listener.tracker.events.MUnstructured;
import com.matheranalytics.listener.tracker.MLogger;

public class MatherAnalyticsModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    private final ReactApplicationContext reactContext;

    public MatherAnalyticsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addLifecycleEventListener(this);
    }

    @Override
    public String getName() {
        return "MatherAnalytics";
    }

    private HashMap<String, MListener> mListenerList = new HashMap<String, MListener>();

    private synchronized MListener getMListener(String accountName, String accountNumber) {
        String listenerId = accountName + accountNumber;
        if (!mListenerList.containsKey(listenerId)) {
            try {
                MListener mListener = new MListener
                        .Builder(getCurrentActivity(), accountName, accountNumber)
                        //.logLevel(MLogger.LogLevel.DEBUG)
                        .enableActivityTracking(true)
                        .build();
                mListenerList.put(listenerId, mListener);
            } catch (Exception e) {
                return null;
            }
        }
        return mListenerList.get(listenerId);
    }

    @ReactMethod
    public void trackPageView(String accountName, String accountNumber, ReadableMap payload) {
        MListener mListener = getMListener(accountName, accountNumber);

        if (mListener != null) {
            MPageView.Builder mPageView = new MPageView.Builder();
            if (payload.hasKey("pageUrl") && payload.getType("pageUrl") == ReadableType.String) {
                mPageView.pageUrl(payload.getString("pageUrl"));
            }

            if (payload.hasKey("pageTitle") && payload.getType("pageTitle") == ReadableType.String) {
                mPageView.pageTitle(payload.getString("pageTitle"));
            }

            if (payload.hasKey("referrer") && payload.getType("referrer") == ReadableType.String) {
                mPageView.referrer(payload.getString("referrer"));
            }

            if (payload.hasKey("userId") && payload.getType("userId") == ReadableType.Map) {
                ReadableMap userId = payload.getMap("userId");
                if (userId.hasKey("user") && userId.getType("user") == ReadableType.String) {
                    if (userId.hasKey("loggedIn") && userId.getType("loggedIn") == ReadableType.Boolean) {
                        mPageView.userId(userId.getString("user"), userId.getBoolean("loggedIn"));
                    } else {
                        mPageView.userId(userId.getString("user"));
                    }
                }
            }

            if (payload.hasKey("section") && payload.getType("section") == ReadableType.String) {
                mPageView.section(payload.getString("section"));
            }

            if (payload.hasKey("author") && payload.getType("author") == ReadableType.String) {
                mPageView.author(payload.getString("author"));
            }

            if (payload.hasKey("pageType") && payload.getType("pageType") == ReadableType.String) {
                mPageView.pageType(payload.getString("pageType"));
            }

            if (payload.hasKey("articlePublishTime") && payload.getType("articlePublishTime") == ReadableType.Map) {
                ReadableMap articlePublishTime = payload.getMap("articlePublishTime");
                if (articlePublishTime.hasKey("time") && articlePublishTime.getType("time") == ReadableType.String
                        && articlePublishTime.hasKey("timeZone") && articlePublishTime.getType("timeZone") == ReadableType.String
                        && articlePublishTime.hasKey("format") && articlePublishTime.getType("format") == ReadableType.String) {
                    mPageView.articlePublishTime(
                            articlePublishTime.getString("time"),
                            articlePublishTime.getString("timeZone"),
                            articlePublishTime.getString("format")
                    );
                }
            }

            if (payload.hasKey("premium") && payload.getType("premium") == ReadableType.Boolean) {
                mPageView.premium(payload.getBoolean("premium"));
            }

            if (payload.hasKey("metered") && payload.getType("metered") == ReadableType.String) {
                mPageView.metered(payload.getString("metered"));
            }

            if (payload.hasKey("publication") && payload.getType("publication") == ReadableType.String) {
                mPageView.publication(payload.getString("publication"));
            }

            if (payload.hasKey("categories") && payload.getType("categories") == ReadableType.Array) {
                ReadableArray categories = payload.getArray("categories");

                mPageView.categories(ConvertReadableToMap.getArrayOfStrings(categories));
            }

            if (payload.hasKey("appName") && payload.getType("appName") == ReadableType.String) {
                mPageView.appName(payload.getString("appName"));
            }

            if (payload.hasKey("referenceNav") && payload.getType("referenceNav") == ReadableType.String) {
                mPageView.referenceNav(payload.getString("referenceNav"));
            }

            if (payload.hasKey("articleId") && payload.getType("articleId") == ReadableType.String) {
                mPageView.articleId(payload.getString("articleId"));
            }

            if (payload.hasKey("articleUpdateTime") && payload.getType("articleUpdateTime") == ReadableType.Map) {
                ReadableMap articleUpdateTime = payload.getMap("articleUpdateTime");
                if (articleUpdateTime.hasKey("time") && articleUpdateTime.getType("time") == ReadableType.String
                        && articleUpdateTime.hasKey("timeZone") && articleUpdateTime.getType("timeZone") == ReadableType.String
                        && articleUpdateTime.hasKey("format") && articleUpdateTime.getType("format") == ReadableType.String) {
                    mPageView.articleUpdateTime(
                            articleUpdateTime.getString("time"),
                            articleUpdateTime.getString("timeZone"),
                            articleUpdateTime.getString("format")
                    );
                }
            }

            if (payload.hasKey("hierarchy") && payload.getType("hierarchy") == ReadableType.Array) {
                ReadableArray hierarchy = payload.getArray("hierarchy");
                mPageView.hierarchy(ConvertReadableToMap.getArrayOfStrings(hierarchy));
            }

            if (payload.hasKey("email") && payload.getType("email") == ReadableType.String) {
                mPageView.email(payload.getString("email"));
            }

            if (payload.hasKey("articleSource") && payload.getType("articleSource") == ReadableType.String) {
                mPageView.articleSource(payload.getString("articleSource"));
            }

            if (payload.hasKey("mediaType") && payload.getType("mediaType") == ReadableType.String) {
                mPageView.mediaType(payload.getString("mediaType"));
            }

            if (payload.hasKey("articleType") && payload.getType("articleType") == ReadableType.String) {
                mPageView.articleType(payload.getString("articleType"));
            }

            if (payload.hasKey("characterCount")) {
                if (payload.getType("characterCount") == ReadableType.String) {
                    mPageView.characterCount(payload.getString("characterCount"));
                } else if (payload.getType("characterCount") == ReadableType.Number) {
                    mPageView.characterCount(payload.getInt("characterCount"));
                }
            }

            if (payload.hasKey("wordCount")) {
                if (payload.getType("wordCount") == ReadableType.String) {
                    mPageView.wordCount(payload.getString("wordCount"));
                } else if (payload.getType("wordCount") == ReadableType.Number) {
                    mPageView.wordCount(payload.getInt("wordCount"));
                }
            }

            if (payload.hasKey("paragraphCount")) {
                if (payload.getType("paragraphCount") == ReadableType.String) {
                    mPageView.paragraphCount(payload.getString("paragraphCount"));
                } else if (payload.getType("paragraphCount") == ReadableType.Number) {
                    mPageView.paragraphCount(payload.getInt("paragraphCount"));
                }
            }

            if (payload.hasKey("scrollPercent")) {
                if (payload.getType("scrollPercent") == ReadableType.String) {
                    mPageView.scrollPercent(payload.getString("scrollPercent"));
                } else if (payload.getType("scrollPercent") == ReadableType.Number) {
                    mPageView.scrollPercent(payload.getInt("scrollPercent"));
                }
            }

            if (payload.hasKey("pageNumber")) {
                if (payload.getType("pageNumber") == ReadableType.String) {
                    mPageView.pageNumber(payload.getString("pageNumber"));
                } else if (payload.getType("pageNumber") == ReadableType.Number) {
                    mPageView.pageNumber(payload.getInt("pageNumber"));
                }
            }

            if (payload.hasKey("addCtxSection") && payload.getType("addCtxSection") == ReadableType.Map) {
                ReadableMap addCtxSection = payload.getMap("addCtxSection");
                if (addCtxSection.hasKey("name") && addCtxSection.getType("name") == ReadableType.String
                        && addCtxSection.hasKey("value") && addCtxSection.getType("value") == ReadableType.Map) {
                    mPageView.addCtxSection(
                            addCtxSection.getString("name"),
                            addCtxSection.getMap("value")
                    );
                }
            }

            if (payload.hasKey("userDB") && payload.getType("userDB") == ReadableType.Map) {
                mPageView.userDB(getUserDB(payload.getMap("userDB"), mListener));
            }

            mListener.track(mPageView.build());
        }
    }

    @ReactMethod
    public void trackAction(String accountName, String accountNumber, ReadableMap payload) {
        MListener mListener = getMListener(accountName, accountNumber);

        if (mListener != null) {
            MActionEvent.Builder mActionEvent = new MActionEvent.Builder();
            if (payload.hasKey("type") && payload.getType("type") == ReadableType.String) {
                mActionEvent.type(payload.getString("type"));
            }
            if (payload.hasKey("category") && payload.getType("category") == ReadableType.String) {
                mActionEvent.category(payload.getString("category"));
            }
            if (payload.hasKey("action") && payload.getType("action") == ReadableType.String) {
                mActionEvent.action(payload.getString("action"));
            }
            if (payload.hasKey("custom") && payload.getType("custom") == ReadableType.Map) {
                ReadableMap custom = payload.getMap("custom");
                if (custom.hasKey("name") && custom.getType("name") == ReadableType.String
                        && custom.hasKey("value") && custom.getType("value") == ReadableType.String) {
                    mActionEvent.custom(custom.getString("name"), custom.getString("value"));
                }
            }
            if (payload.hasKey("offers") && payload.getType("offers") == ReadableType.Array) {
                if (payload.getArray("offers").size() == 1) {
                    if (payload.getArray("offers").getMap(0).getString("offerId") != null && payload.getArray("offers").getMap(0).getString("offerName") != null) {
                        MUtil.MapDef offer1 = new MUtil.MapDef();
                        offer1.put("offerId", payload.getArray("offers").getMap(0).getString("offerId"));
                        offer1.put("offerName", payload.getArray("offers").getMap(0).getString("offerName"));
                        mActionEvent.addOffer(offer1);
                    }
                } else if (payload.getArray("offers").size() > 1) {
                    List<MUtil.MapDef> list = new ArrayList<>();

                    for (int i = 0; i < payload.getArray("offers").size(); i++) {
                        if (payload.getArray("offers").getMap(i).getString("offerId") != null && payload.getArray("offers").getMap(i).getString("offerName") != null) {
                            MUtil.MapDef offer = new MUtil.MapDef();
                            offer.put("offerId", payload.getArray("offers").getMap(i).getString("offerId"));
                            offer.put("offerName", payload.getArray("offers").getMap(i).getString("offerName"));
                            list.add(offer);
                        }
                    }
                    if (list.size() >= 1) {
                        mActionEvent.offers(list);
                    }
                } else {
                    System.out.println("No data");
                }
            }
            mListener.track(mActionEvent.build());
        }
    }

    @ReactMethod
    public void trackImpression(String accountName, String accountNumber, ReadableMap payload) {
        MListener mListener = getMListener(accountName, accountNumber);

        if (mListener != null) {
            MUnstructured.Builder mUnstructured = new MUnstructured.Builder();
            if (payload.hasKey("eaid") && payload.getType("eaid") == ReadableType.String) {
                mUnstructured.eaid(payload.getString("eaid"));
            }
            if (payload.hasKey("ebuy") && payload.getType("ebuy") == ReadableType.String) {
                mUnstructured.ebuy(payload.getString("ebuy"));
            }
            if (payload.hasKey("eadv") && payload.getType("eadv") == ReadableType.String) {
                mUnstructured.eadv(payload.getString("eadv"));
            }
            if (payload.hasKey("ecid") && payload.getType("ecid") == ReadableType.String) {
                mUnstructured.ecid(payload.getString("ecid"));
            }
            if (payload.hasKey("epid") && payload.getType("epid") == ReadableType.String) {
                mUnstructured.epid(payload.getString("epid"));
            }
            if (payload.hasKey("esid") && payload.getType("esid") == ReadableType.String) {
                mUnstructured.esid(payload.getString("esid"));
            }
            if (payload.hasKey("custom") && payload.getType("custom") == ReadableType.Map) {
                ReadableMap custom = payload.getMap("custom");
                if (custom.hasKey("name") && custom.getType("name") == ReadableType.String
                        && custom.hasKey("value") && custom.getType("value") == ReadableType.String) {
                    mUnstructured.custom(custom.getString("name"), custom.getString("value"));
                }
            }
            mListener.track(mUnstructured.build());
        }
    }

    private MUserDB getUserDB(ReadableMap userDB, MListener mListener) {
        MUserDB.Builder newUserDB = new MUserDB.Builder(mListener);
        if (userDB.hasKey("minPageViews")) {
            if (userDB.getType("minPageViews") == ReadableType.Number) {
                newUserDB.minPageViews(userDB.getInt("minPageViews"));
            } else if (userDB.getType("minPageViews") == ReadableType.String) {
                try {
                    newUserDB.minPageViews(Integer.parseInt(userDB.getString("minPageViews")));
                } catch (NumberFormatException e) {
                    // do nothing
                }
            }
        }
        if (userDB.hasKey("timeoutMs")) {
            if (userDB.getType("timeoutMs") == ReadableType.Number) {
                newUserDB.timeoutMs(userDB.getInt("timeoutMs"));
            } else if (userDB.getType("timeoutMs") == ReadableType.String) {
                try {
                    newUserDB.timeoutMs(Integer.parseInt(userDB.getString("timeoutMs")));
                } catch (NumberFormatException e) {
                    // do nothing
                }
            }
        }
        if (userDB.hasKey("noCache") && userDB.getType("noCache") == ReadableType.Boolean) {
            newUserDB.noCache(userDB.getBoolean("noCache"));
        }
        if (userDB.hasKey("userDBUrl") && userDB.getType("userDBUrl") == ReadableType.String) {
            newUserDB.userDBUrl(userDB.getString("userDBUrl"));
        }

        return newUserDB.build();
    }

    @Override
    public void onHostResume() {
        for (MListener mListener : mListenerList.values()) {
            mListener.onResume();
        }
    }

    @Override
    public void onHostPause() {
        for (MListener mListener : mListenerList.values()) {
            mListener.onPause();
        }
    }

    @Override
    public void onHostDestroy() {
        for (MListener mListener : mListenerList.values()) {
            mListener.onDestroy();
        }
    }
}
