package com.example.verifipay_frontend

import android.content.Context
import android.util.Base64
import java.nio.charset.StandardCharsets
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties

class DeviceTokenStorage(
    context: Context
) {

    companion object {

        private const val KEY_ALIAS =
            "verifipay_device_token_key"

        private const val PREFS_NAME =
            "verifipay_secure_storage"

        private const val PREF_ENCRYPTED_TOKEN =
            "device_token"

        private const val PREF_IV =
            "device_token_iv"

        private const val ANDROID_KEYSTORE =
            "AndroidKeyStore"
    }

    private val prefs =
        context.applicationContext
            .getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )

    fun saveToken(
        token: String
    ) {

        require(token.isNotBlank()) {
            "El token del dispositivo no puede estar vacío"
        }

        val cipher =
            Cipher.getInstance(
                "AES/GCM/NoPadding"
            )

        cipher.init(
            Cipher.ENCRYPT_MODE,
            getOrCreateSecretKey()
        )

        val encryptedBytes =
            cipher.doFinal(
                token
                    .trim()
                    .toByteArray(
                        StandardCharsets.UTF_8
                    )
            )

        val encryptedToken =
            Base64.encodeToString(
                encryptedBytes,
                Base64.NO_WRAP
            )

        val iv =
            Base64.encodeToString(
                cipher.iv,
                Base64.NO_WRAP
            )

        prefs.edit()
            .putString(
                PREF_ENCRYPTED_TOKEN,
                encryptedToken
            )
            .putString(
                PREF_IV,
                iv
            )
            .apply()
    }

    fun getToken():
            String? {

        val encryptedToken =
            prefs.getString(
                PREF_ENCRYPTED_TOKEN,
                null
            ) ?: return null

        val iv =
            prefs.getString(
                PREF_IV,
                null
            ) ?: return null

        return try {

            val cipher =
                Cipher.getInstance(
                    "AES/GCM/NoPadding"
                )

            val spec =
                GCMParameterSpec(
                    128,
                    Base64.decode(
                        iv,
                        Base64.NO_WRAP
                    )
                )

            cipher.init(
                Cipher.DECRYPT_MODE,
                getSecretKey(),
                spec
            )

            val decryptedBytes =
                cipher.doFinal(
                    Base64.decode(
                        encryptedToken,
                        Base64.NO_WRAP
                    )
                )

            String(
                decryptedBytes,
                StandardCharsets.UTF_8
            )

        } catch (
            exception: Exception
        ) {

            null
        }
    }

    fun hasToken():
            Boolean {

        return !getToken()
            .isNullOrBlank()
    }

    fun clearToken() {

        prefs.edit()
            .remove(
                PREF_ENCRYPTED_TOKEN
            )
            .remove(
                PREF_IV
            )
            .apply()
    }

    private fun getOrCreateSecretKey():
            SecretKey {

        val keyStore =
            KeyStore.getInstance(
                ANDROID_KEYSTORE
            ).apply {
                load(null)
            }

        val existingKey =
            keyStore.getKey(
                KEY_ALIAS,
                null
            )

        if (
            existingKey is SecretKey
        ) {
            return existingKey
        }

        val keyGenerator =
            KeyGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_AES,
                ANDROID_KEYSTORE
            )

        val keySpec =
            KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or
                    KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(
                    KeyProperties.BLOCK_MODE_GCM
                )
                .setEncryptionPaddings(
                    KeyProperties.ENCRYPTION_PADDING_NONE
                )
                .build()

        keyGenerator.init(
            keySpec
        )

        return keyGenerator
            .generateKey()
    }

    private fun getSecretKey():
            SecretKey {

        val keyStore =
            KeyStore.getInstance(
                ANDROID_KEYSTORE
            ).apply {
                load(null)
            }

        return keyStore.getKey(
            KEY_ALIAS,
            null
        ) as SecretKey
    }
}