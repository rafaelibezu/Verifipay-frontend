package com.example.verifipay_frontend

import android.content.Context
import androidx.work.BackoffPolicy
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

object YapeRetryScheduler {

    private const val WORK_NAME =
        "verifipay_yape_pending_events"

    fun schedule(
        context: Context
    ) {

        val constraints =
            Constraints.Builder()
                .setRequiredNetworkType(
                    NetworkType.CONNECTED
                )
                .build()

        val request =
            OneTimeWorkRequest.Builder(
                YapeRetryWorker::class.java
            )
                /*
                 * Damos tiempo al intento inmediato.
                 * Si funciona, cuando este Worker corra
                 * ya no encontrará nada pendiente.
                 */
                .setInitialDelay(
                    15,
                    TimeUnit.SECONDS
                )
                .setConstraints(
                    constraints
                )
                .setBackoffCriteria(
                    BackoffPolicy.EXPONENTIAL,
                    30,
                    TimeUnit.SECONDS
                )
                .build()

        WorkManager
            .getInstance(
                context.applicationContext
            )
            .enqueueUniqueWork(
                WORK_NAME,
                ExistingWorkPolicy.KEEP,
                request
            )
    }
}