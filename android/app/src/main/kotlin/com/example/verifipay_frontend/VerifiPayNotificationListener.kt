package com.example.verifipay_frontend

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import java.math.BigDecimal
import java.security.MessageDigest

class VerifiPayNotificationListener : NotificationListenerService() {

    companion object {
        private const val TAG = "VerifiPayListener"

        private const val YAPE_PACKAGE =
            "com.bcp.innovacxion.yapeapp"
    }

    private lateinit var eventSender:
        YapeEventSender

    override fun onCreate() {
    super.onCreate()

    eventSender =
        YapeEventSender(
            applicationContext
        )
    }

    override fun onNotificationPosted(
        sbn: StatusBarNotification?
    ) {
        if (sbn == null) {
            return
        }

        if (sbn.packageName != YAPE_PACKAGE) {
            return
        }

        val extras =
            sbn.notification.extras

        val title =
            extras.getCharSequence(
                Notification.EXTRA_TITLE
            )?.toString()?.trim()

        val text =
            extras.getCharSequence(
                Notification.EXTRA_BIG_TEXT
            )?.toString()?.trim()
                ?: extras.getCharSequence(
                    Notification.EXTRA_TEXT
                )?.toString()?.trim()

        if (text.isNullOrBlank()) {
            Log.d(
                TAG,
                "Notificación Yape sin texto"
            )
            return
        }

        Log.d(
            TAG,
            "Yape notification: title=$title text=$text"
        )

        val parsed =
            parseYapeNotification(text)

        if (parsed == null) {
            Log.d(
                TAG,
                "No se pudo interpretar la notificación Yape"
            )
            return
        }

        Log.d(
            TAG,
            """
            YAPE PARSED:
            sender=${parsed.sender}
            amount=${parsed.amount}
            securityCode=${parsed.securityCode}
            occurredAt=${sbn.postTime}
            """.trimIndent()
        )

        val sourceEventId =
            createSourceEventId(
                sbn,
                parsed
            )

       val pendingEvent =
        PendingYapeEvent(
        sourceEventId =
            sourceEventId,

        sender =
            parsed.sender,

        amount =
            parsed.amount,

        securityCode =
            parsed.securityCode,

        occurredAt =
            sbn.postTime
    )

eventSender.enqueueAndSend(
    pendingEvent
)
    }

    private fun createSourceEventId(
        sbn: StatusBarNotification,
        parsed: YapeNotificationData
    ): String {

        val raw =
            buildString {

                append(sbn.packageName)
                append("|")

                append(sbn.key)
                append("|")

                append(sbn.postTime)
                append("|")

                append(
                    parsed.amount.toPlainString()
                )
                append("|")

                append(
                    parsed.securityCode ?: ""
                )
            }

        val digest =
            MessageDigest
                .getInstance("SHA-256")
                .digest(
                    raw.toByteArray(
                        Charsets.UTF_8
                    )
                )

        return digest.joinToString("") {
            "%02x".format(it)
        }
    }

    private fun parseYapeNotification(
        text: String
    ): YapeNotificationData? {

        val amountRegex =
            Regex(
                """S/\s*([0-9]+(?:[.,][0-9]{1,2})?)""",
                RegexOption.IGNORE_CASE
            )

        val securityCodeRegex =
            Regex(
                """seguridad\s+es:\s*([0-9]+)""",
                RegexOption.IGNORE_CASE
            )

        val senderRegex =
            Regex(
                """^(.+?)\s+te\s+envió\s+un\s+pago""",
                RegexOption.IGNORE_CASE
            )

        val amountMatch =
            amountRegex.find(text)
                ?: return null

        val amountText =
            amountMatch
                .groupValues[1]
                .replace(",", ".")

        val amount =
            amountText.toBigDecimalOrNull()
                ?: return null

        val securityCode =
            securityCodeRegex
                .find(text)
                ?.groupValues
                ?.getOrNull(1)

        val sender =
            senderRegex
                .find(text)
                ?.groupValues
                ?.getOrNull(1)
                ?.trim()

        return YapeNotificationData(
            sender = sender,
            amount = amount,
            securityCode = securityCode
        )
    }
}

data class YapeNotificationData(
    val sender: String?,
    val amount: BigDecimal,
    val securityCode: String?
)