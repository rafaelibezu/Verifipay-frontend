package com.example.verifipay_frontend

import java.math.BigDecimal

object YapeNotificationParser {
    private val amountRegex =
        Regex("""S/\s*([0-9]+(?:[.,][0-9]{1,2})?)""", RegexOption.IGNORE_CASE)

    private val securityCodeRegex =
        Regex("""seguridad\s+es:\s*([0-9]+)""", RegexOption.IGNORE_CASE)

    private val senderRegex =
        Regex(
            """^(.+?)\s+te\s+envi(?:ó|o|Ã³|ÃƒÂ³)\s+un\s+pago""",
            RegexOption.IGNORE_CASE,
        )

    fun parse(text: String): YapeNotificationData? {
        val amountMatch = amountRegex.find(text) ?: return null
        val amountText = amountMatch.groupValues[1].replace(",", ".")
        val amount = amountText.toBigDecimalOrNull() ?: return null
        val securityCode = securityCodeRegex.find(text)?.groupValues?.getOrNull(1)
        val sender = senderRegex.find(text)?.groupValues?.getOrNull(1)?.trim()

        return YapeNotificationData(
            sender = sender,
            amount = amount,
            securityCode = securityCode,
        )
    }
}

data class YapeNotificationData(
    val sender: String?,
    val amount: BigDecimal,
    val securityCode: String?,
)

