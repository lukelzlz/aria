package com.poppingmoon.aria

import android.content.Context
import android.util.Log
import androidx.work.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class NotificationPollWorker(
    context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    companion object {
        const val TAG = "NotificationPollWorker"
        const val WORK_NAME = "aria_notification_poll"
        const val CHANNEL = "com.poppingmoon.aria/push"

        fun schedule(context: Context, intervalMinutes: Long = 15) {
            val workRequest = PeriodicWorkRequestBuilder<NotificationPollWorker>(
                intervalMinutes,
                TimeUnit.MINUTES
            )
                .setConstraints(
                    Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build()
                )
                .setBackoffCriteria(
                    BackoffPolicy.LINEAR,
                    WorkRequest.MIN_BACKOFF_MILLIS,
                    TimeUnit.MILLISECONDS
                )
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                workRequest
            )
            Log.d(TAG, "Scheduled notification polling every $intervalMinutes minutes")
        }

        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
            Log.d(TAG, "Cancelled notification polling")
        }

        fun isScheduled(context: Context): Boolean {
            val workInfos = WorkManager.getInstance(context)
                .getWorkInfosForUniqueWork(WORK_NAME)
                .get()
            return workInfos.any { 
                it.state == WorkInfo.State.RUNNING || 
                it.state == WorkInfo.State.ENQUEUED 
            }
        }
    }

    override fun doWork(): Result {
        Log.d(TAG, "Polling for notifications...")
        
        try {
            // Send broadcast to Flutter to check notifications
            // Flutter side will handle the actual API call
            val intent = android.content.Intent("com.poppingmoon.aria.POLL_NOTIFICATIONS")
            intent.setPackage(applicationContext.packageName)
            applicationContext.sendBroadcast(intent)
            
            return Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "Error polling notifications", e)
            return Result.retry()
        }
    }
}
