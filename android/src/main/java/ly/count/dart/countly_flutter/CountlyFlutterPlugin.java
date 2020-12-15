package ly.count.dart.countly_flutter;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import ly.count.android.sdk.Countly;
import ly.count.android.sdk.CountlyConfig;
import ly.count.android.sdk.DeviceId;
import ly.count.android.sdk.FeedbackRatingCallback;
import ly.count.android.sdk.RemoteConfig;
import ly.count.android.sdk.CountlyStarRating;
//import ly.count.android.sdk.DeviceInfo;
import java.util.HashMap;
import java.util.Map;
import android.app.Activity;
import android.content.Context;
import org.json.JSONArray;
import org.json.JSONException;
import android.util.Log;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.Arrays;
import java.util.ArrayList;

//Push Plugin
import android.os.Build;
import android.app.NotificationManager;
import android.app.NotificationChannel;

import ly.count.android.sdk.RemoteConfigCallback;
import ly.count.android.sdk.StarRatingCallback;
import ly.count.android.sdk.messaging.CountlyPush;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.firebase.FirebaseApp;

/** CountlyFlutterPlugin */
public class CountlyFlutterPlugin implements MethodCallHandler {
  /** Plugin registration. */
    private Countly.CountlyMessagingMode pushTokenType = Countly.CountlyMessagingMode.PRODUCTION;
    private Context context;
    private Activity activity;
    private Boolean isDebug = false;
    private CountlyConfig config = null;

  public static void registerWith(Registrar registrar) {
      final Activity __activity  = registrar.activity();
      final Context __context = registrar.context();

      final MethodChannel channel = new MethodChannel(registrar.messenger(), "countly_flutter");
      channel.setMethodCallHandler(new CountlyFlutterPlugin(__activity, __context));
  }

  private void setConfig(){
      if(this.config == null){
          this.config = new CountlyConfig();
      }
  }

  public CountlyFlutterPlugin(Activity _activity, Context _context){
    this.activity = _activity;
    this.context= _context;
  }
  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    String argsString = (String) call.argument("data");
      if (argsString == null) {
          argsString = "[]";
      }
      JSONArray args = null;
      try {
          args = new JSONArray(argsString);

          if (isDebug) {
              Log.i("Countly", "Method name: " + call.method);
              Log.i("Countly", "Method arguments: " + argsString);
          }

          if ("init".equals(call.method)) {

              String serverUrl = args.getString(0);
              String appKey = args.getString(1);
              this.setConfig();
              this.config.setContext(context);
              this.config.setServerURL(serverUrl);
              this.config.setAppKey(appKey);
              //may: for fixing the for-llop the null list on Countly sdk
              this.config.setConsentEnabled(new String[]{});
              if (args.length() == 2) {
                  // Countly.sharedInstance().init(context, serverUrl, appKey, null, DeviceId.Type.OPEN_UDID);
                 this.config.setIdMode(DeviceId.Type.OPEN_UDID);
                
              } else if (args.length() == 3) {
                  String yourDeviceID = args.getString(2);
                  if(yourDeviceID.equals("TemporaryDeviceID")){
                    this.config.enableTemporaryDeviceIdMode();
                  }else{
                    this.config.setDeviceId(yourDeviceID);
                  }
                  // Countly.sharedInstance()
                  //        .init(context, serverUrl, appKey, yourDeviceID, null);
              } else {
                  // Countly.sharedInstance()
                  //         .init(context, serverUrl, appKey, null, DeviceId.Type.ADVERTISING_ID);
                  this.config.setIdMode(DeviceId.Type.ADVERTISING_ID);
              }
              Countly.sharedInstance().init(this.config);
              Countly.sharedInstance().onStart(activity);
              //may: sync IOS success msg
              result.success("initialized.");
          } else if ("changeDeviceId".equals(call.method)) {
              String newDeviceID = args.getString(0);
              String onServerString = args.getString(1);
              if(newDeviceID.equals("TemporaryDeviceID")){
                Countly.sharedInstance().enableTemporaryIdMode();
              }else{
                if ("1".equals(onServerString)) {
                    Countly.sharedInstance().changeDeviceIdWithMerge(newDeviceID);
                } else {
                    Countly.sharedInstance().changeDeviceIdWithoutMerge(DeviceId.Type.DEVELOPER_SUPPLIED, newDeviceID);
                }
              }
              result.success("changeDeviceId success!");
          } else if ("enableTemporaryIdMode".equals(call.method)) {
              Countly.sharedInstance().enableTemporaryIdMode();
              result.success("enableTemporaryIdMode This method doesn't exists!");
          } else if ("setHttpPostForced".equals(call.method)) {
              int isEnabled = Integer.parseInt(args.getString(0));
              this.setConfig();
              if (isEnabled == 1) {
                  this.config.setHttpPostForced(true);
              } else {
                  this.config.setHttpPostForced(false);
              }
              result.success("setHttpPostForced");
          } else if ("enableParameterTamperingProtection".equals(call.method)) {
              String salt = args.getString(0);
              this.setConfig();
              this.config.setParameterTamperingProtectionSalt(salt);
              result.success("enableParameterTamperingProtection success!");
          } else if ("setLocation".equals(call.method)) {
              String latitude = args.getString(0);
              String longitude = args.getString(1);
              String latlng = (latitude + "," + longitude);
              Countly.sharedInstance().setLocation(null, null, latlng, null);
              result.success("setLocation success!");
          } else if ("enableCrashReporting".equals(call.method)) {
              this.setConfig();
              this.config.enableCrashReporting();
              // Countly.sharedInstance().enableCrashReporting();
              result.success("enableCrashReporting success!");
          } else if ("addCrashLog".equals(call.method)) {
              String record = args.getString(0);
              Countly.sharedInstance().crashes().addCrashBreadcrumb(record);
              // Countly.sharedInstance().addCrashBreadcrumb(record);
              result.success("addCrashLog success!");
          } else if ("logException".equals(call.method)) {
              String exceptionString = args.getString(0);
              Exception exception = new Exception(exceptionString);

              // Boolean nonfatal = args.getBoolean(1);

              // HashMap<String, Object> segments = new HashMap<String, Object>();
              // for (int i = 2, il = args.length(); i < il; i += 2) {
              //     segments.put(args.getString(i), args.getString(i + 1));
              // }
              // segments.put("nonfatal", nonfatal.toString());
              // this.setConfig();
              // this.config.setCustomCrashSegment(segments);
              // Countly.sharedInstance().setCustomCrashSegments(segments);

              Countly.sharedInstance().crashes().recordHandledException(exception);

              result.success("logException success!");
          } else if ("sendPushToken".equals(call.method)) {
              String token = args.getString(0);
              int messagingMode = Integer.parseInt(args.getString(1));
              if (messagingMode == 0) {
                  // Countly.sharedInstance().sendPushToken(token, Countly.CountlyMessagingMode.PRODUCTION);
              } else {
                  // Countly.sharedInstance().sendPushToken(token, Countly.CountlyMessagingMode.TEST);
              }
              result.success(" success!");
          } else if ("askForNotificationPermission".equals(call.method)) {
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                  String channelName = "Default Name";
                  String channelDescription = "Default Description";
                  NotificationManager notificationManager = (NotificationManager) context.getSystemService(context.NOTIFICATION_SERVICE);
                  if (notificationManager != null) {
                      NotificationChannel channel = new NotificationChannel(CountlyPush.CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_DEFAULT);
                      channel.setDescription(channelDescription);
                      notificationManager.createNotificationChannel(channel);
                  }
              }
              CountlyPush.init(activity.getApplication(), pushTokenType);
              FirebaseApp.initializeApp(context);
              FirebaseInstanceId.getInstance().getInstanceId()
                  .addOnCompleteListener(new OnCompleteListener<InstanceIdResult>() {
                      @Override
                      public void onComplete(Task<InstanceIdResult> task) {
                          if (!task.isSuccessful()) {
                              Log.w("Tag", "getInstanceId failed", task.getException());
                              return;
                          }
                          String token = task.getResult().getToken();
                          CountlyPush.onTokenRefresh(token);
                      }
                  });
              result.success(" askForNotificationPermission!");
          } else if ("pushTokenType".equals(call.method)) {
              String tokenType = args.getString(0);
              if("2".equals(tokenType)){
                  pushTokenType = Countly.CountlyMessagingMode.TEST;
              }else{
                  pushTokenType = Countly.CountlyMessagingMode.PRODUCTION;
              }
              result.success("pushTokenType!");
          } else if ("start".equals(call.method)) {
              Countly.sharedInstance().onStart(activity);
              result.success("started!");
          } else if ("manualSessionHandling".equals(call.method)) {
//              Countly.sharedInstance().manualSessionHandling();
              result.success("deafult!");

          } else if ("stop".equals(call.method)) {
              Countly.sharedInstance().onStop();
              result.success("stoped!");

          } else if ("updateSessionPeriod".equals(call.method)) {
//              Countly.sharedInstance().updateSessionPeriod();
              result.success("default!");

          } else if ("eventSendThreshold".equals(call.method)) {
              int queueSize = Integer.parseInt(args.getString(0));
              this.config.setEventQueueSizeToSend(queueSize);
              result.success("default!");

          } else if ("storedRequestsLimit".equals(call.method)) {
              int queueSize = Integer.parseInt(args.getString(0));
//              Countly.sharedInstance().storedRequestsLimit();
              result.success("default!");

          } else if ("startEvent".equals(call.method)) {
              String startEvent = args.getString(0);
              Countly.sharedInstance().events().startEvent(startEvent);
          } else if ("endEvent".equals(call.method)) {
              String key = args.getString(0);
              int count = Integer.parseInt(args.getString(1));
              float sum = Float.valueOf(args.getString(2)); // new Float(args.getString(2)).floatValue();
              HashMap<String, Object> segmentation = new HashMap<String, Object>();
              if (args.length() > 3) {
                  for (int i = 3, il = args.length(); i < il; i += 2) {
                      segmentation.put(args.getString(i), args.getString(i + 1));
                  }
              }
              Countly.sharedInstance().events().endEvent(key, segmentation, count, sum);
              result.success("endEvent for: " + key);
          } else if ("recordEvent".equals(call.method)) {
              String key = args.getString(0);
              int count = Integer.parseInt(args.getString(1));
              float sum = Float.valueOf(args.getString(2)); // new Float(args.getString(2)).floatValue();
              int duration = Integer.parseInt(args.getString(3));
              HashMap<String, Object> segmentation = new HashMap<String, Object>();
              if (args.length() > 4) {
                  for (int i = 4, il = args.length(); i < il; i += 2) {
                      segmentation.put(args.getString(i), args.getString(i + 1));
                  }
              }
              Countly.sharedInstance().events().recordEvent(key, segmentation, count, sum, duration);
              result.success("recordEvent for: " + key);
          } else if ("setLoggingEnabled".equals(call.method)) {
              String loggingEnable = args.getString(0);
              this.setConfig();
              if (loggingEnable.equals("true")) {
                  this.config.setLoggingEnabled(true);
                  // Countly.sharedInstance().setLoggingEnabled(true);
              } else {
                  this.config.setLoggingEnabled(false);
                  // Countly.sharedInstance().setLoggingEnabled(false);
              }
              result.success("setLoggingEnabled success!");
          } else if ("setuserdata".equals(call.method)) {
              // Bundle bundle = new Bundle();

              Map<String, String> bundle = new HashMap<String, String>();

              bundle.put("name", args.getString(0));
              bundle.put("username", args.getString(1));
              bundle.put("email", args.getString(2));
              bundle.put("organization", args.getString(3));
              bundle.put("phone", args.getString(4));
              bundle.put("picture", args.getString(5));
              bundle.put("picturePath", args.getString(6));
              bundle.put("gender", args.getString(7));
              bundle.put("byear", args.getString(8));

              Countly.userData.setUserData(bundle);
              Countly.userData.save();

              result.success("setuserdata success");
          } else if ("userData_setProperty".equals(call.method)) {
              String keyName = args.getString(0);
              String keyValue = args.getString(1);
              Countly.userData.setProperty(keyName, keyValue);
              Countly.userData.save();
              result.success("userData_setProperty success!");
          } else if ("userData_increment".equals(call.method)) {
              String keyName = args.getString(0);
              Countly.userData.increment(keyName);
              Countly.userData.save();
              result.success("userData_increment success!");
          } else if ("userData_incrementBy".equals(call.method)) {
              String keyName = args.getString(0);
              int keyIncrement = Integer.parseInt(args.getString(1));
              Countly.userData.incrementBy(keyName, keyIncrement);
              Countly.userData.save();
              result.success("userData_incrementBy success!");
          } else if ("userData_multiply".equals(call.method)) {
              String keyName = args.getString(0);
              int multiplyValue = Integer.parseInt(args.getString(1));
              Countly.userData.multiply(keyName, multiplyValue);
              Countly.userData.save();
              result.success("userData_multiply success!");
          } else if ("userData_saveMax".equals(call.method)) {
              String keyName = args.getString(0);
              int maxScore = Integer.parseInt(args.getString(1));
              Countly.userData.saveMax(keyName, maxScore);
              Countly.userData.save();
              result.success("userData_saveMax success!");
          } else if ("userData_saveMin".equals(call.method)) {
              String keyName = args.getString(0);
              int minScore = Integer.parseInt(args.getString(1));
              Countly.userData.saveMin(keyName, minScore);
              Countly.userData.save();
              result.success("userData_saveMin success!");
          } else if ("userData_setOnce".equals(call.method)) {
              String keyName = args.getString(0);
              String minScore = args.getString(1);
              Countly.userData.setOnce(keyName, minScore);
              Countly.userData.save();
              result.success("userData_setOnce success!");
          } else if ("userData_pushUniqueValue".equals(call.method)) {
              String type = args.getString(0);
              String pushUniqueValue = args.getString(1);
              Countly.userData.pushUniqueValue(type, pushUniqueValue);
              Countly.userData.save();
              result.success("userData_pushUniqueValue success!");
          } else if ("userData_pushValue".equals(call.method)) {
              String type = args.getString(0);
              String pushValue = args.getString(1);
              Countly.userData.pushValue(type, pushValue);
              Countly.userData.save();
              result.success("userData_pushValue success!");
          } else if ("userData_pullValue".equals(call.method)) {
              String type = args.getString(0);
              String pullValue = args.getString(1);
              Countly.userData.pullValue(type, pullValue);
              Countly.userData.save();
              result.success("userData_pullValue success!");
          }

          //setRequiresConsent
          else if ("setRequiresConsent".equals(call.method)) {
              Boolean consentFlag = args.getBoolean(0);
              this.setConfig();
              this.config.setRequiresConsent(consentFlag);
              // Countly.sharedInstance().setRequiresConsent(consentFlag);
              result.success("setRequiresConsent!");
          } else if ("giveConsent".equals(call.method)) {
              List<String> features = new ArrayList<>();
              for (int i = 0; i < args.length(); i++) {
                  String theConsent = args.getString(i);
                  if (theConsent.equals("sessions")) {
                      Countly.sharedInstance().consent().giveConsent(new String[]{Countly.CountlyFeatureNames.sessions});
                  }
                  if (theConsent.equals("events")) {
                      Countly.sharedInstance().consent().giveConsent(new String[]{Countly.CountlyFeatureNames.events});
                  }
                  if (theConsent.equals("views")) {
                      Countly.sharedInstance().consent().giveConsent(new String[]{Countly.CountlyFeatureNames.views});
                  }
                  if (theConsent.equals("location")) {
                      Countly.sharedInstance().consent().giveConsent(new String[]{Countly.CountlyFeatureNames.location});
                  }
                  if (theConsent.equals("crashes")) {
                      Countly.sharedInstance().consent().giveConsent(new String[]{Countly.CountlyFeatureNames.crashes});
                  }
                  if (theConsent.equals("attribution")) {
                      Countly.sharedInstance().consent().giveConsent(new String[]{Countly.CountlyFeatureNames.attribution});
                  }
                  if (theConsent.equals("users")) {
                      Countly.sharedInstance().consent().giveConsent(new String[]{Countly.CountlyFeatureNames.users});
                  }
                  if (theConsent.equals("push")) {
                      Countly.sharedInstance().consent().giveConsent(new String[]{Countly.CountlyFeatureNames.push});
                  }
                  if (theConsent.equals("starRating")) {
                      Countly.sharedInstance().consent().giveConsent(new String[]{Countly.CountlyFeatureNames.starRating});
                  }
              }
              result.success("giveConsent!");

          } else if ("removeConsent".equals(call.method)) {
              List<String> features = new ArrayList<>();
              for (int i = 0; i < args.length(); i++) {
                  String theConsent = args.getString(i);
                  if (theConsent.equals("sessions")) {
                      Countly.sharedInstance().consent().removeConsent(new String[]{Countly.CountlyFeatureNames.sessions});
                  }
                  if (theConsent.equals("events")) {
                      Countly.sharedInstance().consent().removeConsent(new String[]{Countly.CountlyFeatureNames.events});
                  }
                  if (theConsent.equals("views")) {
                      Countly.sharedInstance().consent().removeConsent(new String[]{Countly.CountlyFeatureNames.views});
                  }
                  if (theConsent.equals("location")) {
                      Countly.sharedInstance().consent().removeConsent(new String[]{Countly.CountlyFeatureNames.location});
                  }
                  if (theConsent.equals("crashes")) {
                      Countly.sharedInstance().consent().removeConsent(new String[]{Countly.CountlyFeatureNames.crashes});
                  }
                  if (theConsent.equals("attribution")) {
                      Countly.sharedInstance().consent().removeConsent(new String[]{Countly.CountlyFeatureNames.attribution});
                  }
                  if (theConsent.equals("users")) {
                      Countly.sharedInstance().consent().removeConsent(new String[]{Countly.CountlyFeatureNames.users});
                  }
                  if (theConsent.equals("push")) {
                      Countly.sharedInstance().consent().removeConsent(new String[]{Countly.CountlyFeatureNames.push});
                  }
                  if (theConsent.equals("starRating")) {
                      Countly.sharedInstance().consent().removeConsent(new String[]{Countly.CountlyFeatureNames.starRating});
                  }
              }
              result.success("removeConsent!");

          } else if ("giveAllConsent".equals(call.method)) {
              Countly.sharedInstance().consent().giveConsent(new String[]{
                  Countly.CountlyFeatureNames.sessions,
                  Countly.CountlyFeatureNames.events,
                  Countly.CountlyFeatureNames.views,
                  Countly.CountlyFeatureNames.location,
                  Countly.CountlyFeatureNames.crashes,
                  Countly.CountlyFeatureNames.attribution,
                  Countly.CountlyFeatureNames.users,
                  Countly.CountlyFeatureNames.push,
                  Countly.CountlyFeatureNames.starRating
              });
              result.success("giveAllConsent!");
          } else if ("removeAllConsent".equals(call.method)) {

              Countly.sharedInstance().consent().removeConsent(new String[]{
                  Countly.CountlyFeatureNames.sessions,
                  Countly.CountlyFeatureNames.events,
                  Countly.CountlyFeatureNames.views,
                  Countly.CountlyFeatureNames.location,
                  Countly.CountlyFeatureNames.crashes,
                  Countly.CountlyFeatureNames.attribution,
                  Countly.CountlyFeatureNames.users,
                  Countly.CountlyFeatureNames.push,
                  Countly.CountlyFeatureNames.starRating
              });
              result.success("removeAllConsent!");

          } else if ("sendRating".equals(call.method)) {
              String ratingString = args.getString(0);
              int rating = Integer.parseInt(ratingString);

              Map<String, Object> segm = new HashMap<>();
              segm.put("platform", "android");
              segm.put("rating", "" + rating);
              Countly.sharedInstance().events().recordEvent("[CLY]_star_rating", segm, 1);
              result.success("sendRating: " + ratingString);
          } else if ("recordView".equals(call.method)) {
              String viewName = args.getString(0);
              Countly.sharedInstance().views().recordView(viewName);
              result.success("View name sent: " + viewName);
          } else if ("setOptionalParametersForInitialization".equals(call.method)) {
              String city = args.getString(0);
              String country = args.getString(1);
              String latitude = args.getString(2);
              String longitude = args.getString(3);
              String ipAddress = args.getString(4);
              String latlng = latitude + "," + longitude;
              if(city.length() == 0){
                  city = null;
              }
              if(country.length() == 0){
                  country = null;
              }
              if(latitude.equals("0.00")){
                  latitude = null;
              }
              if(longitude.equals("0.00")){
                  longitude = null;
              }
              if(latitude == null && longitude == null){
                  latlng = null;
              }
              if(ipAddress.equals("0.0.0.0")){
                  ipAddress = null;
              }
              Countly.sharedInstance().setLocation(country, city, latlng, ipAddress);

              result.success("setOptionalParametersForInitialization sent.");
          } else if ("setRemoteConfigAutomaticDownload".equals(call.method)) {
              this.setConfig();
              this.config.setRemoteConfigAutomaticDownload(true, new RemoteConfig.RemoteConfigCallback() {
                  @Override
                  public void callback(String error) {
                      if (error == null) {
                          result.success("Success");
                      } else {
                          result.success("Error: " + error.toString());
                      }
                  }
              });

          } else if ("remoteConfigUpdate".equals(call.method)) {
              Countly.sharedInstance().remoteConfig().update(new RemoteConfigCallback() {
                  @Override
                  public void callback(String error) {
                      if (error == null) {
                          result.success("Success");
                      } else {
                          result.success("Error: " + error.toString());
                      }
                  }
              });
          } else if ("updateRemoteConfigForKeysOnly".equals(call.method)) {
              String[] keysOnly = new String[args.length()];
              for (int i = 0, il = args.length(); i < il; i++) {
                  keysOnly[i] = args.getString(i);
                  ;
              }

              Countly.sharedInstance().remoteConfig().updateForKeysOnly(keysOnly, new RemoteConfigCallback() {
                  @Override
                  public void callback(String error) {
                      if (error == null) {
                          result.success("Success");
                      } else {
                          result.success("Error: " + error.toString());
                      }
                  }
              });
          } else if ("updateRemoteConfigExceptKeys".equals(call.method)) {
              String[] exceptKeys = new String[args.length()];
              for (int i = 0, il = args.length(); i < il; i++) {
                  exceptKeys[i] = args.getString(i);
              }

              Countly.sharedInstance().remoteConfig().updateExceptKeys(exceptKeys, new RemoteConfigCallback() {
                  @Override
                  public void callback(String error) {
                      if (error == null) {
                          result.success("Success");
                      } else {
                          result.success("Error: " + error.toString());
                      }
                  }
              });
          } else if ("remoteConfigClearValues".equals(call.method)) {
              Countly.sharedInstance().remoteConfig().clearStoredValues();
              result.success("remoteConfigClearValues: success");
          } else if ("getRemoteConfigValueForKey".equals(call.method)) {
              String getRemoteConfigValueForKeyResult = Countly.sharedInstance().remoteConfig().getValueForKey(args.getString(0)).toString();
              result.success(getRemoteConfigValueForKeyResult);
          } else if ("askForFeedback".equals(call.method)) {
              String widgetId = args.getString(0);
              String closeButtonText = args.getString(1);
              Countly.sharedInstance().ratings().showFeedbackPopup(widgetId, closeButtonText, activity, new FeedbackRatingCallback() {
                  @Override
                  public void callback(String error) {
                      if (error != null) {
                          result.success("Error: Encountered error while showing feedback dialog: [" + error + "]");
                      } else {
                          result.success("Feedback submitted.");
                      }
                  }
              });
          } else if (call.method.equals("askForStarRating")) {
              // Countly.sharedInstance().(context, 5);
              Countly.sharedInstance().ratings().showStarRating(activity, new StarRatingCallback() {
                  @Override
                  public void onRate(int rating) {
                      result.success("Rating: " +rating);
                  }

                  @Override
                  public void onDismiss() {
                      result.success("Rating: Modal dismissed.");
                  }
              });
          } else {
              result.notImplemented();
          }

          // if (call.method.equals("getPlatformVersion")) {
          //   result.success("Android " + android.os.Build.VERSION.RELEASE);
          // } else {
          //   result.notImplemented();
          // }
      } catch (JSONException jsonException) {
          result.success(jsonException.toString());
      }
  }
}