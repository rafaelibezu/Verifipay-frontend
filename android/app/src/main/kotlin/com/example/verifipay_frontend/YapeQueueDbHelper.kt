package com.example.verifipay_frontend

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import java.math.BigDecimal

class YapeQueueDbHelper(
    context: Context
) : SQLiteOpenHelper(
    context,
    DATABASE_NAME,
    null,
    DATABASE_VERSION
) {

    companion object {
        private const val DATABASE_NAME =
            "verifipay_queue.db"

        private const val DATABASE_VERSION = 1

        private const val TABLE =
            "pending_yape_events"
    }

    override fun onCreate(
        db: SQLiteDatabase
    ) {

        db.execSQL(
            """
            CREATE TABLE $TABLE (
                source_event_id TEXT PRIMARY KEY,
                sender TEXT,
                amount TEXT NOT NULL,
                security_code TEXT,
                occurred_at INTEGER NOT NULL,
                retry_count INTEGER NOT NULL DEFAULT 0,
                created_at INTEGER NOT NULL
            )
            """.trimIndent()
        )
    }

    override fun onUpgrade(
        db: SQLiteDatabase,
        oldVersion: Int,
        newVersion: Int
    ) {
        // Primera versión.
    }

    fun insertIfAbsent(
        event: PendingYapeEvent
    ) {

        val values =
            ContentValues().apply {

                put(
                    "source_event_id",
                    event.sourceEventId
                )

                put(
                    "sender",
                    event.sender
                )

                put(
                    "amount",
                    event.amount.toPlainString()
                )

                put(
                    "security_code",
                    event.securityCode
                )

                put(
                    "occurred_at",
                    event.occurredAt
                )

                put(
                    "retry_count",
                    event.retryCount
                )

                put(
                    "created_at",
                    System.currentTimeMillis()
                )
            }

        writableDatabase.insertWithOnConflict(
            TABLE,
            null,
            values,
            SQLiteDatabase.CONFLICT_IGNORE
        )
    }

    fun findAllPending():
            List<PendingYapeEvent> {

        val events =
            mutableListOf<PendingYapeEvent>()

        readableDatabase.query(
            TABLE,
            null,
            null,
            null,
            null,
            null,
            "created_at ASC"
        ).use { cursor ->

            val sourceIndex =
                cursor.getColumnIndexOrThrow(
                    "source_event_id"
                )

            val senderIndex =
                cursor.getColumnIndexOrThrow(
                    "sender"
                )

            val amountIndex =
                cursor.getColumnIndexOrThrow(
                    "amount"
                )

            val securityIndex =
                cursor.getColumnIndexOrThrow(
                    "security_code"
                )

            val occurredIndex =
                cursor.getColumnIndexOrThrow(
                    "occurred_at"
                )

            val retryIndex =
                cursor.getColumnIndexOrThrow(
                    "retry_count"
                )

            while (cursor.moveToNext()) {

                events.add(
                    PendingYapeEvent(
                        sourceEventId =
                            cursor.getString(
                                sourceIndex
                            ),

                        sender =
                            if (
                                cursor.isNull(
                                    senderIndex
                                )
                            ) {
                                null
                            } else {
                                cursor.getString(
                                    senderIndex
                                )
                            },

                        amount =
                            BigDecimal(
                                cursor.getString(
                                    amountIndex
                                )
                            ),

                        securityCode =
                            if (
                                cursor.isNull(
                                    securityIndex
                                )
                            ) {
                                null
                            } else {
                                cursor.getString(
                                    securityIndex
                                )
                            },

                        occurredAt =
                            cursor.getLong(
                                occurredIndex
                            ),

                        retryCount =
                            cursor.getInt(
                                retryIndex
                            )
                    )
                )
            }
        }

        return events
    }

    fun countPending(): Int {

        readableDatabase.rawQuery(
            "SELECT COUNT(*) FROM $TABLE",
            null
        ).use { cursor ->

            return if (cursor.moveToFirst()) {
                cursor.getInt(0)
            } else {
                0
            }
        }
    }

    fun delete(
        sourceEventId: String
    ) {

        writableDatabase.delete(
            TABLE,
            "source_event_id = ?",
            arrayOf(sourceEventId)
        )
    }

    fun incrementRetry(
        sourceEventId: String
    ) {

        writableDatabase.execSQL(
            """
            UPDATE $TABLE
            SET retry_count = retry_count + 1
            WHERE source_event_id = ?
            """.trimIndent(),
            arrayOf(sourceEventId)
        )
    }

    
    fun exists(
        sourceEventId: String
    ): Boolean {

        readableDatabase.query(
            TABLE,
            arrayOf("source_event_id"),
            "source_event_id = ?",
            arrayOf(sourceEventId),
            null,
            null,
            null,
            "1"
        ).use { cursor ->

            return cursor.moveToFirst()
        }
    }
}
