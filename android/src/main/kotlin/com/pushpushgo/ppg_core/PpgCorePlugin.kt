package com.pushpushgo.ppg_core

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import androidx.annotation.NonNull
import com.google.firebase.FirebaseApp
import com.pushpushgo.core_sdk.sdk.client.PpgCoreClient
import com.pushpushgo.core_sdk.sdk.utils.PermissionState
import com.pushpushgo.core_sdk.sdk.utils.PermissionsUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** PpgCorePlugin */

enum class MethodIdentifier {
  initialize,
  registerForNotifications,
  onToken;
  companion object {
    fun create(name: String): MethodIdentifier {
      return values().find { it.name.equals(name, ignoreCase = true) }
        ?: throw IllegalArgumentException("Invalid process state: $name")
    }
  }

}

class PpgCorePlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.NewIntentListener, PluginRegistry.RequestPermissionsResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var ppgCoreClient: PpgCoreClient
  private lateinit var context: Context
  private lateinit var activity: Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.pushpushgo/core")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (MethodIdentifier.create(call.method)) {
      MethodIdentifier.initialize -> {
        FirebaseApp.initializeApp(context.applicationContext)
        ppgCoreClient = PpgCoreClient(activity)
        Log.d("Initialize", "Initialize")
      }
      MethodIdentifier.registerForNotifications -> {
        when (PermissionsUtils.check(activity)) {
          PermissionState.ALLOWED -> {
            ppgCoreClient.getSubscription {
              channel.invokeMethod(MethodIdentifier.onToken.toString(), it.toJSON())
            }
            result.success("granted")
          }
          PermissionState.ASK -> {
            PermissionsUtils.requestPermissions(activity)
            result.success("prompt")
          }
          PermissionState.DENIED -> {
            result.success("denied")
          }
          PermissionState.RATIONALE -> {
            result.success("prompt")
          }
        }
      }
      else -> result.notImplemented()
    }

  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    binding.addRequestPermissionsResultListener(this)
    binding.addOnNewIntentListener(this)
    activity = binding.activity
    ppgCoreClient = PpgCoreClient(activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    ppgCoreClient = PpgCoreClient(activity)
  }

  override fun onDetachedFromActivity() {

  }

  override fun onNewIntent(intent: Intent): Boolean {
    ppgCoreClient.onReceive(context, intent)
    return true
  }

  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<out String>,
    grantResults: IntArray
  ): Boolean {
    return when (requestCode) {
      PermissionsUtils.PERMISSION_REQUEST_CODE -> {
        if(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
          ppgCoreClient.getSubscription {
            channel.invokeMethod(MethodIdentifier.onToken.toString(), it.toJSON())
          }
        }
        return true
      }
      else -> false
    }
  }
}
