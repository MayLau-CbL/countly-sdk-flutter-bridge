import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';


enum LogLevel {INFO, DEBUG, VERBOSE, WARNING, ERROR}
class Countly {
  static const MethodChannel _channel = const MethodChannel('countly_flutter');

  // static variable
  static bool isDebug = false;
  static bool enableCrashReportingFlag = false;
  static bool isInit = false;
  static Map<String, Object> messagingMode = {
    "TEST": "1",
    "PRODUCTION": "0",
    "ADHOC": "2"
  };
  static Map<String, Object> deviceIDType = {
    "TemporaryDeviceID": "TemporaryDeviceID"
  };


  static Future<String> init(String serverUrl, String appKey,
      [String deviceId]) async {
    if (Platform.isAndroid) {
      messagingMode = {"TEST": "2", "PRODUCTION": "0"};
    }
    List<String> args = [];
    args.add(serverUrl);
    args.add(appKey);
    if (deviceId != null) {
      args.add(deviceId);
    }


    final String result = await _channel
        .invokeMethod('init', <String, dynamic>{'data': json.encode(args)});
    isInit = result == "initialized.";
    if (isDebug) {
      print(result);
    }
    return result;
  }

  ///
  ///Follow flutter_countly latest partten, for easier adopting their fix version in future.
  ///
  static Future<bool> isInitialized() {
    return Future.value(isInit);
  }

  static Future<String> recordEvent(Map<String, Object> options) async {
    if (isInit) {
      List<String> args = [];
      var segmentation = {};

      if (options["key"] == null) {
        options["key"] = "default";
      }
      args.add(options["key"].toString());

      if (options["count"] == null) {
        options["count"] = 1;
      }
      args.add(options["count"].toString());

      if (options["sum"] == null) {
        options["sum"] = "0";
      }
      args.add(options["sum"].toString());

      if (options["duration"] == null) {
        options["duration"] = "0";
      }
      args.add(options["duration"].toString());

      if (options["segmentation"] != null) {
        segmentation = options["segmentation"];
        segmentation.forEach((k, v) {
          args.add(k.toString());
          args.add(v.toString());
        });
      }


      final String result = await _channel.invokeMethod(
          'recordEvent', <String, dynamic>{'data': json.encode(args)});
      if (isDebug) {
        print(json.encode(args));
        print(result);
      }
      return result;
    } else {
      return Future.value('[Countly] Not Initailized!');
    }
  }

  ////// 001
  static Future<String> recordView(String view) async {
    if (isInit) {
      List<String> args = [];
      args.add(view);
      final String result = await _channel.invokeMethod(
          'recordView', <String, dynamic>{'data': json.encode(args)});
      if (isDebug) {
        print(result);
      }
      return result;
    } else {
      return Future.value('[Countly] Not Initailized!');
    }

  }

  static Future<String> setUserData(Map<String, Object> options) async {
    List<String> args = [];
    if (options["name"] == null) {
      options["name"] = "";
    }
    if (options["username"] == null) {
      options["username"] = "";
    }
    if (options["email"] == null) {
      options["email"] = "";
    }
    if (options["organization"] == null) {
      options["organization"] = "";
    }
    if (options["phone"] == null) {
      options["phone"] = "";
    }
    if (options["picture"] == null) {
      options["picture"] = "";
    }
    if (options["picturePath"] == null) {
      options["picturePath"] = "";
    }
    if (options["gender"] == null) {
      options["gender"] = "";
    }
    if (options["byear"] == null) {
      options["byear"] = "0";
    }

    args.add(options["name"]);
    args.add(options["username"]);
    args.add(options["email"]);
    args.add(options["organization"]);
    args.add(options["phone"]);
    args.add(options["picture"]);
    args.add(options["picturePath"]);
    args.add(options["gender"]);
    args.add(options["byear"]);


    final String result = await _channel.invokeMethod(
        'setuserdata', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  /// This method will ask for permission, enables push notification and send push token to countly server.
  /// Should be call after Countly init
  static Future<String> askForNotificationPermission() async {
    List<String> args = [];
    final String result = await _channel.invokeMethod(
        'askForNotificationPermission',
        <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  /// Set Push notification messaging mode and callbacks for push notifications
  /// Should be call after Countly init
  static Future<String> pushTokenType(String tokenType) async {
    List<String> args = [];
    args.add(tokenType);
    final String result = await _channel.invokeMethod(
        'pushTokenType', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  /// Set callback to receive push notifications
  /// @param { callback listner } callback
static Future<String> onNotification(Function callback) async {
    List <String> args = [];
    listenerCallback = callback;
    log("registerForNotification");
    _channel.invokeMethod('registerForNotification', <String, dynamic>{
      'data': json.encode(args)
    }).then((value){
      listenerCallback(value.toString());
      onNotification(callback);
    }).catchError((error){
      listenerCallback(error.toString());
    });
    return "";
  }

  static Future<String> start() async {
    if (isInit) {
      List<String> args = [];
      final String result = await _channel
          .invokeMethod('start', <String, dynamic>{'data': json.encode(args)});
      if (isDebug) {
        print(result);
      }
      return result;
    } else {
      return Future.value('[Countly] Not Initailized!');
    }
  }

  static Future<String> manualSessionHandling() async {
    List<String> args = [];
    final String result = await _channel.invokeMethod(
        'manualSessionHandling', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  static Future<String> stop() async {

    if (isInit) {
      List<String> args = [];
      final String result = await _channel
          .invokeMethod('stop', <String, dynamic>{'data': json.encode(args)});
      if (isDebug) {
        print(result);
      }
      return result;
    } else {
      return Future.value('[Countly] Not Initailized!');
    }
  }

  static Future<String> updateSessionPeriod() async {
    List<String> args = [];
    final String result = await _channel.invokeMethod(
        'updateSessionPeriod', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  static Future<String> eventSendThreshold() async {
    List<String> args = [];
    final String result = await _channel.invokeMethod(
        'updateSessionPeriod', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> storedRequestsLimit() async {

    List<String> args = [];
    final String result = await _channel.invokeMethod(
        'storedRequestsLimit', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> setOptionalParametersForInitialization(
      Map<String, Object> options) async {
    List<String> args = [];

    String city = options["city"];
    String country = options["country"];
    String latitude = options["latitude"];
    String longitude = options["longitude"];
    String ipAddress = options["ipAddress"];


    if (city == null) {
      city = "";
    }
    if (country == null) {
      country = "";
    }
    if (latitude == null) {
      latitude = "0.00";
    }
    if (longitude == null) {
      longitude = "0.00";
    }
    if (ipAddress == null) {
      ipAddress = "0.0.0.0";
    }

    if (!latitude.contains(".")) {
      latitude = latitude + ".00";
    }
    if (!latitude.contains(".")) {
      latitude = latitude + ".00";

    }

    args.add(city);
    args.add(country);
    args.add(latitude);
    args.add(longitude);
    args.add(ipAddress);


    final String result = await _channel.invokeMethod(
        'setOptionalParametersForInitialization',
        <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }
  
  /// Get currently used device Id.
  /// Should be call after Countly init
  static Future<String> getCurrentDeviceId() async {
    isInitialized().then((bool isInitialized) async {
      if(!isInitialized) {
        log('getCurrentDeviceId, init must be called before getCurrentDeviceId',logLevel: LogLevel.WARNING);
        return "init must be called before getCurrentDeviceId";
      }
      List <String> args = [];
      final String result = await _channel.invokeMethod('getCurrentDeviceId', <String, dynamic>{
        'data': json.encode(args)
      });
      log(result);
      return result;
    });
  }

  static Future<String> changeDeviceId(
      String newDeviceID, bool onServer) async {
    List<String> args = [];
    String onServerString;
    if (onServer == false) {
      onServerString = "0";
    } else {

      onServerString = "1";
    }
    newDeviceID = newDeviceID.toString();
    args.add(newDeviceID);
    args.add(onServerString);

    final String result = await _channel.invokeMethod(
        'changeDeviceId', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> addCrashLog(String logs) async {
    List<String> args = [];
    args.add(logs);
    final String result = await _channel.invokeMethod(
        'addCrashLog', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }
  /// Set to true if you want to enable countly internal debugging logs
  /// Should be call before Countly init
  static Future<String> setLoggingEnabled(bool flag) async {

    List<String> args = [];
    isDebug = flag;
    args.add(flag.toString());
    final String result = await _channel.invokeMethod(
        'setLoggingEnabled', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  /// Set the optional salt to be used for calculating the checksum of requested data which will be sent with each request, using the &checksum field
  /// Should be call before Countly init
  static Future<String> enableParameterTamperingProtection(String salt) async {

    List<String> args = [];
    args.add(salt);
    final String result = await _channel.invokeMethod(
        'enableParameterTamperingProtection',
        <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }


  static Future<String> setHttpPostForced(bool isEnabled) async {
    List<String> args = [];
    args.add(isEnabled.toString());

    final String result = await _channel.invokeMethod(
        'setHttpPostForced', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> setLocation(String latitude, String longitude) async {

    List<String> args = [];
    args.add(latitude);
    args.add(longitude);
    final String result = await _channel.invokeMethod(
        'setLocation', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  static Future<String> setProperty(String keyName, String keyValue) async {
    List<String> args = [];
    args.add(keyName);
    args.add(keyValue);
    final String result = await _channel.invokeMethod(
        'userData_setProperty', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> increment(String keyName) async {

    List<String> args = [];
    args.add(keyName);
    final String result = await _channel.invokeMethod(
        'userData_increment', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> incrementBy(String keyName, int keyIncrement) async {

    List<String> args = [];
    args.add(keyName);
    args.add(keyIncrement.toString());
    final String result = await _channel.invokeMethod(
        'userData_incrementBy', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> multiply(String keyName, int multiplyValue) async {

    List<String> args = [];
    args.add(keyName);
    args.add(multiplyValue.toString());
    final String result = await _channel.invokeMethod(
        'userData_multiply', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> saveMax(String keyName, int saveMax) async {

    List<String> args = [];
    args.add(keyName);
    args.add(saveMax.toString());
    final String result = await _channel.invokeMethod(
        'userData_saveMax', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> saveMin(String keyName, int saveMin) async {

    List<String> args = [];
    args.add(keyName);
    args.add(saveMin.toString());
    final String result = await _channel.invokeMethod(
        'userData_saveMin', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  static Future<String> setOnce(String keyName, int setOnce) async {
    List<String> args = [];
    args.add(keyName);
    args.add(setOnce.toString());
    final String result = await _channel.invokeMethod(
        'userData_setOnce', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  static Future<String> pushUniqueValue(
      String type, String pushUniqueValue) async {
    List<String> args = [];
    args.add(type);
    args.add(pushUniqueValue);
    final String result = await _channel.invokeMethod(
        'userData_pushUniqueValue',
        <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> pushValue(String type, String pushValue) async {

    List<String> args = [];
    args.add(type);
    args.add(pushValue);
    final String result = await _channel.invokeMethod(
        'userData_pushValue', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> pullValue(String type, String pullValue) async {

    List<String> args = [];
    args.add(type);
    args.add(pullValue);
    final String result = await _channel.invokeMethod(
        'userData_pullValue', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  /// Set that consent should be required for features to work.
  /// Should be call before Countly init
  static Future<String> setRequiresConsent(bool flag) async {
    List<String> args = [];
    args.add(flag.toString());

    final String result = await _channel.invokeMethod(
        'setRequiresConsent', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);

    }
    List <String> args = consents;
    log(args.toString());
    final String result = await _channel.invokeMethod('giveConsentInit', <String, dynamic>{
      'data': json.encode(args)
    });
    log(result);
    return result;
  }


  static Future<String> giveConsent(List<String> consents) async {
    List<String> args = consents;
    final String result = await _channel.invokeMethod(
        'giveConsent', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  static Future<String> removeConsent(List<String> consents) async {
    List<String> args = consents;
    final String result = await _channel.invokeMethod(
        'removeConsent', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }


  static Future<String> giveAllConsent() async {
    List<String> args = [];


    final String result = await _channel.invokeMethod(
        'giveAllConsent', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> removeAllConsent() async {
    List<String> args = [];

    final String result = await _channel.invokeMethod(
        'removeAllConsent', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  static Future<String> setRemoteConfigAutomaticDownload(
      Function callback) async {
    List<String> args = [];
    final String result = await _channel.invokeMethod(
        'setRemoteConfigAutomaticDownload',
        <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    callback(result);
    return result;
  }

  static Future<String> remoteConfigUpdate(Function callback) async {
    List<String> args = [];


    final String result = await _channel.invokeMethod(
        'remoteConfigUpdate', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    callback(result);
    return result;
  }

  static Future<String> updateRemoteConfigForKeysOnly(
      List<String> args, Function callback) async {
    final String result = await _channel.invokeMethod(
        'updateRemoteConfigForKeysOnly',
        <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    callback(result);
    return result;
  }

  static Future<String> updateRemoteConfigExceptKeys(
      Object keys, Function callback) async {
    List<String> args = [];

    final String result = await _channel.invokeMethod(
        'updateRemoteConfigExceptKeys',
        <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    callback(result);
    return result;
  }

  static Future<String> remoteConfigClearValues(Function callback) async {

    List<String> args = [];
    final String result = await _channel.invokeMethod('remoteConfigClearValues',
        <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    callback(result);
    return result;
  }

  static Future<String> getRemoteConfigValueForKey(
      String key, Function callback) async {
    List<String> args = [];
    args.add(key);
    final String result = await _channel.invokeMethod(
        'getRemoteConfigValueForKey',
        <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    callback(result);
    return result;
  }

  static Future<String> askForStarRating() async {

    List<String> args = [];
    final String result = await _channel.invokeMethod(
        'askForStarRating', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  static Future<String> askForFeedback(
      String widgetId, String closeButtonText) async {
    List<String> args = [];
    args.add(widgetId);
    args.add(closeButtonText);
    final String result = await _channel.invokeMethod(
        'askForFeedback', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> startEvent(String key) async {

    List<String> args = [];
    args.add(key);
    final String result = await _channel.invokeMethod(
        'startEvent', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  static Future<String> endEvent(Map<String, Object> options) async {
    List<String> args = [];
    var segmentation = {};


    if (options["key"] == null) {
      options["key"] = "default";

    }
    args.add(options["key"].toString());

    if (options["count"] == null) {
      options["count"] = 1;
    }
    args.add(options["count"].toString());

    if (options["sum"] == null) {
      options["sum"] = "0";
    }
    args.add(options["sum"].toString());

    if (options["segmentation"] != null) {
      segmentation = options["segmentation"];
      segmentation.forEach((k, v) {
        args.add(k.toString());
        args.add(v.toString());
      });
    }

    final String result = await _channel
        .invokeMethod('endEvent', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }

    return result;
  }

  /// Call used for testing error handling
  /// Should not be used 
  static Future<String> throwNativeException() async {
    List <String> args = [];
    log(args.toString());
    final String result = await _channel.invokeMethod('throwNativeException', <String, dynamic>{
      'data': json.encode(args)
    });
    log(result);
    return result;
  }

  /// Enable crash reporting to report uncaught errors to Countly.
  /// Should be call before Countly init
  static Future<String> enableCrashReporting() async {

    FlutterError.onError =
        (FlutterErrorDetails details, {bool forceReport = false}) {
      try {
        Countly.logException(
            "${details.exception} \n ${details.stack}", true, {});
      } catch (e) {
        print('Sending report to sentry.io failed: $e');
      } finally {
        FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
      }
    };
    List<String> args = [];
    enableCrashReportingFlag = true;
    final String result = await _channel.invokeMethod(
        'enableCrashReporting', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);
    }
    return result;
  }

  static Future<String> logException(
      String execption, bool nonfatal, Map<String, Object> segmentation) async {
    List<String> args = [];

    args.add(execption);

    args.add(nonfatal.toString());
    if (segmentation != null) {
      segmentation.forEach((k, v) {
        args.add(k.toString());
        args.add(v.toString());
      });
    }

    final String result = await _channel.invokeMethod(
        'logException', <String, dynamic>{'data': json.encode(args)});
    if (isDebug) {
      print(result);

    }
    log(args.toString());
    final String result = await _channel.invokeMethod('setCustomCrashSegment', <String, dynamic>{
      'data': json.encode(args)
    });
    log(result);
    return result;
  }
  static Future<String> startTrace(String traceKey) async {
    List <String> args = [];
    args.add(traceKey);
    log(args.toString());
    final String result = await _channel.invokeMethod('startTrace', <String, dynamic>{
      'data': json.encode(args)
    });
    log(result);
    return result;
  }

  static Future<String> cancelTrace(String traceKey) async {
    List <String> args = [];
    args.add(traceKey);
    log(args.toString());
    final String result = await _channel.invokeMethod('cancelTrace', <String, dynamic>{
      'data': json.encode(args)
    });
    log(result);
    return result;
  }

  static Future<String> clearAllTraces() async {
    List <String> args = [];
    final String result = await _channel.invokeMethod('clearAllTraces', <String, dynamic>{
      'data': json.encode(args)
    });
    log(result);
    return result;
  }
  static Future<String> endTrace(String traceKey, Map<String, int> customMetric) async {
    List <String> args = [];
    args.add(traceKey);
    if(customMetric != null){
      customMetric.forEach((k, v){
        args.add(k.toString());
        args.add(v.toString());
      });
    }
    log(args.toString());
    final String result = await _channel.invokeMethod('endTrace', <String, dynamic>{
      'data': json.encode(args)
    });
    log(result);
    return result;
  }
  static Future<String> recordNetworkTrace(String networkTraceKey, int responseCode, int requestPayloadSize, int responsePayloadSize, int startTime, int endTime) async {
    List <String> args = [];
    args.add(networkTraceKey);
    args.add(responseCode.toString());
    args.add(requestPayloadSize.toString());
    args.add(responsePayloadSize.toString());
    args.add(startTime.toString());
    args.add(endTime.toString());
    log(args.toString());
    final String result = await _channel.invokeMethod('recordNetworkTrace', <String, dynamic>{
      'data': json.encode(args)
    });
    log(result);
    return result;
  }

  /// Enable APM features, which includes the recording of app start time.
  /// Should be call before Countly init
  static Future<String> enableApm() async {
    List <String> args = [];
    log(args.toString());
    final String result = await _channel.invokeMethod('enableApm', <String, dynamic>{
            'data': json.encode(args)
    });
    log(result);
    return result;
  }
  /// Report a handled or unhandled exception/error to Countly.
  ///
  /// The exception is provided with an [Exception] object
  /// If no stack trace is provided, [StackTrace.current] will be used
  ///
  /// [String exception] - the exception that is recorded
  /// [bool nonfatal] - reports if the exception was fatal or not
  /// [StackTrace stacktrace] - stacktrace for the crash
  /// [Map<String, Object> segmentation] - allows to add optional segmentation
  static Future<String> logExceptionEx(Exception exception, bool nonfatal, {StackTrace stacktrace, Map<String, Object> segmentation}) async {
    stacktrace ??= StackTrace.current ?? StackTrace.fromString('');
    logException("${exception.toString()}\n\n$stacktrace", nonfatal, segmentation).then((String result) {
      return result;
    });
  }

  /// Report a handled or unhandled exception/error to Countly.
  ///
  /// The exception/error is provided with a string message
  /// If no stack trace is provided, [StackTrace.current] will be used
  ///
  /// [String message] - the error / crash information sent to the server
  /// [bool nonfatal] - reports if the error was fatal or not
  /// [StackTrace stacktrace] - stacktrace for the crash
  /// [Map<String, Object> segmentation] - allows to add optional segmentation
  static Future<String> logExceptionManual(String message, bool nonfatal, {StackTrace stacktrace, Map<String, Object> segmentation}) async {
    stacktrace ??= StackTrace.current ?? StackTrace.fromString('');
    logException("$message\n\n$stacktrace", nonfatal, segmentation).then((String result) {
      return result;
    });
  }

  /// Internal callback to record "FlutterError.onError" errors
  ///
  /// Must call [enableCrashReporting()] to enable it
  static Future<void> _recordFlutterError(FlutterErrorDetails details) async {
    log('_recordFlutterError, Flutter error caught by Countly:');
    if(!_enableCrashReportingFlag) {
      log('_recordFlutterError, Crash Reporting must be enabled to report crash on Countly',logLevel: LogLevel.WARNING);
      return;
    }

    _internalRecordError(details.exceptionAsString(), details.stack);
  }

  /// Callback to catch and report Dart errors, [enableCrashReporting()] must call before [init] to make it work.
  ///
  /// This callback has to be provided when the app is about to be run.
  /// It has to be done inside a custom Zone by providing [Countly.recordDartError] in onError() callback.
  ///
  /// ```
  /// void main() {
  ///   runZonedGuarded<Future<void>>(() async {
  ///     runApp(MyApp());
  ///   }, Countly.recordDartError);
  /// }
  ///
  static Future<void> recordDartError(dynamic exception, StackTrace stack, {dynamic context}) async {
    log('recordError, Error caught by Countly :');
    if(!_enableCrashReportingFlag) {
      log('recordError, Crash Reporting must be enabled to report crash on Countly',logLevel: LogLevel.WARNING);
      return;
    }
    _internalRecordError(exception, stack);
  }

  /// A common call for crashes coming from [_recordFlutterError] and [recordDartError]
  ///
  /// They are then further reported to countly
  static Future<void> _internalRecordError(dynamic exception, StackTrace stack) async {
    isInitialized().then((bool isInitialized){
      if(!isInitialized) {
        log('_internalRecordError, countly is not initialized',logLevel: LogLevel.WARNING);
        return;
      }

      log('_internalRecordError, Exception : ${exception.toString()}');
      if (stack != null) log('\n_internalRecordError, Stack : $stack');

      stack ??= StackTrace.fromString('');
      try {
        logException('${exception.toString()}\n\n$stack', true);
      } catch (e) {
        log('Sending crash report to Countly failed: $e');
      }
    });
  }
  /// Enable campaign attribution reporting to Countly.
  /// Should be call before Countly init
  static Future<String> enableAttribution() async {
    List <String> args = [];
    final String result = await _channel.invokeMethod('enableAttribution', <String, dynamic>{
      'data': json.encode(args)
    });
    log(result);
    return result;
  }
}
