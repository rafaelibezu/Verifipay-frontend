package com.example.verifipay_frontend

import java.math.BigDecimal

data class PendingYapeEvent(
    val sourceEventId: String,
    val sender: String?,
    val amount: BigDecimal,
    val securityCode: String?,
    val occurredAt: Long,
    val retryCount: Int = 0
)