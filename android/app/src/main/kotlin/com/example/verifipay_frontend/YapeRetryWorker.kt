package com.example.verifipay_frontend

import android.content.Context
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters

class YapeRetryWorker(
    appContext: Context,
    workerParameters: WorkerParameters
) : Worker(
    appContext,
    workerParameters
) {

    companion object {
        private const val TAG =
            "VerifiPayRetry"
    }

override fun doWork():
        Result {

    val database =
        YapeQueueDbHelper(
            applicationContext
        )

    val pending =
        database.findAllPending()

    if (pending.isEmpty()) {

        Log.d(
            TAG,
            "No hay eventos Yape pendientes"
        )

        return Result.success()
    }

    Log.d(
        TAG,
        "Reintentando ${pending.size} evento(s)"
    )

    val sender =
        YapeEventSender(
            applicationContext
        )

    val completed =
        sender.processPendingQueue()

    val remaining =
        database.findAllPending()

    return if (
        completed &&
        remaining.isEmpty()
    ) {

        Log.d(
            TAG,
            "Todos los eventos pendientes fueron enviados"
        )

        Result.success()

    } else {

        Log.d(
            TAG,
            "Quedan ${remaining.size} evento(s) pendientes"
        )

        Result.retry()
    }
}
}