package com.example.verifipay_frontend

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import java.math.BigDecimal

class YapeNotificationParserTest {

    @Test
    fun parsesValidUtf8Notification() {
        val result =
            YapeNotificationParser.parse(
                "Maria Perez te envió un pago por S/ 42.50. Tu codigo de seguridad es: 123"
            )

        assertEquals("Maria Perez", result?.sender)
        assertEquals(BigDecimal("42.50"), result?.amount)
        assertEquals("123", result?.securityCode)
    }

    @Test
    fun parsesMojibakeNotificationVariant() {
        val result =
            YapeNotificationParser.parse(
                "Maria Perez te enviÃ³ un pago por S/ 42,50. Tu codigo de seguridad es: 123"
            )

        assertEquals("Maria Perez", result?.sender)
        assertEquals(BigDecimal("42.50"), result?.amount)
        assertEquals("123", result?.securityCode)
    }

    @Test
    fun returnsNullForInvalidNotification() {
        val result =
            YapeNotificationParser.parse(
                "Tienes una promocion disponible"
            )

        assertNull(result)
    }
}

