package com.example.verifipay_frontend

import android.content.Context
import android.util.Log
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

class YapeEventSender(
    context: Context
) {

    companion object {

        private const val TAG =
            "VerifiPaySender"

        /*
         * Un solo hilo para los envíos inmediatos.
         */
        private val executor =
            Executors.newSingleThreadExecutor()

        /*
         * Evita que WorkManager y el sender
         * drenen la cola al mismo tiempo.
         */
        private val queueLock =
            ReentrantLock()

        /*
         * Evita programar 20 tareas cuando
         * llegan 20 Yapes seguidos.
         */
        private val processing =
            AtomicBoolean(false)
    }

    private val appContext =
        context.applicationContext

    private val database =
        YapeQueueDbHelper(
            appContext
        )

    fun enqueueAndSend(
        event: PendingYapeEvent
    ) {

        /*
         * SIEMPRE guardamos primero.
         */
        database.insertIfAbsent(
            event
        )

        Log.d(
            TAG,
            "Evento guardado localmente"
        )

        /*
         * WorkManager queda como respaldo
         * si falla el envío inmediato.
         */
        YapeRetryScheduler.schedule(
            appContext
        )

        /*
         * Intentamos procesar la cola ahora.
         */
        scheduleQueueProcessing()
    }

    private fun scheduleQueueProcessing() {

        /*
         * Solo una llamada puede cambiar:
         *
         * false -> true
         *
         * Si ya existe un procesamiento activo,
         * los demás eventos simplemente quedan
         * guardados en SQLite.
         */
        if (
            !processing.compareAndSet(
                false,
                true
            )
        ) {

            Log.d(
                TAG,
                "Procesamiento ya programado"
            )

            return
        }

        executor.execute {

            var completed =
                false

            try {

                completed =
                    processPendingQueue()

            } finally {

                processing.set(false)

                /*
                 * Solo volvemos a programar
                 * inmediatamente si:
                 *
                 * 1. El procesamiento terminó bien.
                 * 2. Llegaron eventos nuevos mientras
                 *    estábamos procesando.
                 *
                 * Si falló por falta de internet
                 * o backend caído, NO hacemos loop.
                 * WorkManager se encargará.
                 */
                if (
                    completed &&
                    database
                        .findAllPending()
                        .isNotEmpty()
                ) {

                    scheduleQueueProcessing()
                }
            }
        }
    }

    fun processPendingQueue():
            Boolean {

        return queueLock.withLock {

            val events =
                database.findAllPending()

            if (events.isEmpty()) {

                Log.d(
                    TAG,
                    "Cola local vacía"
                )

                return@withLock true
            }

            Log.d(
                TAG,
                "Procesando ${events.size} evento(s) pendientes"
            )

            for (event in events) {

                /*
                 * Puede que otro proceso haya
                 * eliminado el evento antes de
                 * que lleguemos aquí.
                 */
                if (
                    !database.exists(
                        event.sourceEventId
                    )
                ) {
                    continue
                }

                val success =
                    sendOnce(
                        event
                    )

                /*
                 * Si un request falla, paramos.
                 *
                 * Si sabemos que backend/red
                 * no responde, no tiene sentido
                 * lanzar otros 19 requests.
                 */
                if (!success) {

                    Log.d(
                        TAG,
                        "Procesamiento detenido. La cola queda pendiente."
                    )

                    return@withLock false
                }
            }

            val remaining =
                database.findAllPending()

            if (remaining.isEmpty()) {

                Log.d(
                    TAG,
                    "Cola procesada completamente"
                )

                true

            } else {

                Log.d(
                    TAG,
                    "Quedan ${remaining.size} evento(s) pendientes"
                )

                false
            }
        }
    }

    private fun sendOnce(
        event: PendingYapeEvent
    ): Boolean {

        var connection:
                HttpURLConnection? = null

        try {

                val deviceToken =
                    DeviceTokenStorage(
                    appContext
                ).getToken()

                if (
                    deviceToken.isNullOrBlank()
                ) {

                Log.e(
                    TAG,
                    "Device token no configurado"
                )

                database.incrementRetry(
                    event.sourceEventId
                )

                return false
            }

            val url =
                URL(
                    "${BuildConfig.VERIFIPAY_API_URL}" +
                        "/api/v1/device/payment-events/yape"
                )

            connection =
                url.openConnection()
                        as HttpURLConnection

            connection.requestMethod =
                "POST"

            connection.connectTimeout =
                10_000

            connection.readTimeout =
                10_000

            connection.doOutput =
                true

            connection.setRequestProperty(
                "Content-Type",
                "application/json"
            )

            connection.setRequestProperty(
                "Accept",
                "application/json"
            )

            connection.setRequestProperty(
                "X-Device-Token",
                deviceToken
            )

            val body =
                JSONObject().apply {

                    put(
                        "amount",
                        event.amount
                            .toPlainString()
                    )

                    event.securityCode
                        ?.let {
                            put(
                                "securityCode",
                                it
                            )
                        }

                    event.sender
                        ?.let {
                            put(
                                "sender",
                                it
                            )
                        }

                    put(
                        "occurredAtEpochMillis",
                        event.occurredAt
                    )

                    put(
                        "sourceEventId",
                        event.sourceEventId
                    )
                }

            connection.outputStream.use {
                output ->

                output.write(
                    body
                        .toString()
                        .toByteArray(
                            Charsets.UTF_8
                        )
                )
            }

            val statusCode =
                connection.responseCode

            Log.d(
                TAG,
                "Backend respondio status=$statusCode"
            )

            /*
             * Si backend responde 2xx,
             * ya posee/controla el evento.
             *
             * También sirve si responde
             * duplicate=true.
             */
            if (
                statusCode in 200..299
            ) {

                database.delete(
                    event.sourceEventId
                )

                Log.d(
                    TAG,
                    "Evento confirmado"
                )

                return true
            }

            database.incrementRetry(
                event.sourceEventId
            )

            return false

        } catch (
            ex: Exception
        ) {

            database.incrementRetry(
                event.sourceEventId
            )

            Log.e(
                TAG,
                "Backend no disponible. Evento queda pendiente"
            )

            return false

        } finally {

            connection?.disconnect()
        }
    }
}
