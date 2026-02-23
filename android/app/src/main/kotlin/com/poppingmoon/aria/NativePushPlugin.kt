package com.poppingmoon.aria

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class NativePushPlugin : FlutterPlugin {
    companion object {
        const val TAG = "NativePushPlugin"
        const val METHOD_CHANNEL = "com.poppingmoon.aria/push"
        const val EVENT_CHANNEL = "com.poppingmoon.aria/poll_event"
    }

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var context: Context? = null

    private val pollReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            Log.d(TAG, "Received poll broadcast")
            eventSink?.success("poll")
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startKeepAlive" -> {
                    context?.let { KeepAliveService.start(it) }
                    result.success(true)
                }
                "stopKeepAlive" -> {
                    context?.let { KeepAliveService.stop(it) }
                    result.success(true)
                }
                "isKeepAliveRunning" -> {
                    // Check if service is running
                    val running = isServiceRunning()
                    result.success(running)
                }
                "startPolling" -> {
                    val interval = call.argument<Long>("intervalMinutes") ?: 15L
                    context?.let { NotificationPollWorker.schedule(it, interval) }
                    result.success(true)
                }
                "stopPolling" -> {
                    context?.let { NotificationPollWorker.cancel(it) }
                    result.success(true)
                }
                "isPollingScheduled" -> {
                    val scheduled = context?.let { NotificationPollWorker.isScheduled(it) } ?: false
                    result.success(scheduled)
                }
                else -> result.notImplemented()
            }
        }

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                eventSink = sink
                // Register broadcast receiver
                val filter = IntentFilter("com.poppingmoon.aria.POLL_NOTIFICATIONS")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    context?.registerReceiver(
                        pollReceiver,
                        filter,
                        Context.RECEIVER_NOT_EXPORTED
                    )
                } else {
                    context?.registerReceiver(pollReceiver, filter)
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                try {
                    context?.unregisterReceiver(pollReceiver)
                } catch (e: Exception) {
                    Log.e(TAG, "Error unregistering receiver", e)
                }
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        try {
            context?.unregisterReceiver(pollReceiver)
        } catch (e: Exception) {
            // Ignore
        }
        context = null
    }

    private fun isServiceRunning(): Boolean {
        val manager = context?.getSystemService(Context.ACTIVITY_SERVICE) as? android.app.ActivityManager
        @Suppress("DEPRECATION")
        return manager?.getRunningServices(Int.MAX_VALUE)
            ?.any { it.service.className == KeepAliveService::class.java.name } == true
    }
}
