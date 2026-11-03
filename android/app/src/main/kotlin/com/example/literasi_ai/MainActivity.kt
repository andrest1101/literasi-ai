package com.example.literasi_ai

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingSharePayload: Map<String, Any?>? = null
    private var shareEvents: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHARE_TARGET_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "fetchInitialShare" -> {
                    val payload = pendingSharePayload
                    pendingSharePayload = null
                    result.success(payload)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHARE_TARGET_EVENTS_CHANNEL,
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    shareEvents = events
                }

                override fun onCancel(arguments: Any?) {
                    shareEvents = null
                }
            },
        )

        pendingSharePayload = parseShareIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val payload = parseShareIntent(intent) ?: return
        val sink = shareEvents
        if (sink != null) {
            sink.success(payload)
        } else {
            pendingSharePayload = payload
        }
    }

    private fun parseShareIntent(intent: Intent?): Map<String, Any?>? {
        val sourceIntent = intent ?: return null
        if (
            sourceIntent.action != Intent.ACTION_SEND &&
            sourceIntent.action != Intent.ACTION_SEND_MULTIPLE
        ) {
            return null
        }

        val id = System.currentTimeMillis()
        // Teks diprioritaskan: browser biasanya meng-share URL sebagai
        // text/plain lengkap dengan judul dan URL.
        val text = sourceIntent.getStringExtra(Intent.EXTRA_TEXT)?.trim()
        if (!text.isNullOrEmpty()) {
            return mapOf(
                "id" to id,
                "text" to text.take(MAX_TEXT_LENGTH),
            )
        }

        val imageUri = streamUri(sourceIntent) ?: return mapOf(
            "id" to id,
            "error" to "unsupported_type",
        )
        val mime = resolveMimeType(sourceIntent, imageUri)?.let {
            if (it == "image/jpg") "image/jpeg" else it
        }
        if (mime !in ALLOWED_IMAGE_MIME_TYPES) {
            return mapOf(
                "id" to id,
                "error" to "unsupported_type",
            )
        }

        val bytes = readImageBytes(imageUri)
        if (bytes == null) {
            return mapOf(
                "id" to id,
                "error" to "unreadable",
            )
        }
        if (bytes.size > MAX_IMAGE_BYTES) {
            return mapOf(
                "id" to id,
                "error" to "too_large",
            )
        }

        return mapOf(
            "id" to id,
            "imageBytes" to bytes,
            "fileName" to displayName(imageUri, mime),
            "mimeType" to mime,
        )
    }

    private fun streamUri(intent: Intent): Uri? {
        if (intent.action == Intent.ACTION_SEND) {
            return parcelableUriExtra(intent, Intent.EXTRA_STREAM)
        }

        val uris = parcelableUriListExtra(intent, Intent.EXTRA_STREAM)
        return uris?.firstOrNull()
    }

    @Suppress("DEPRECATION")
    private fun parcelableUriExtra(intent: Intent, name: String): Uri? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(name, Uri::class.java)
        } else {
            intent.getParcelableExtra(name)
        }
    }

    @Suppress("DEPRECATION")
    private fun parcelableUriListExtra(
        intent: Intent,
        name: String,
    ): List<Uri>? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableArrayListExtra(name, Uri::class.java)
        } else {
            intent.getParcelableArrayListExtra(name)
        }
    }

    private fun resolveMimeType(intent: Intent, uri: Uri): String? {
        val fromIntent = intent.type?.lowercase()?.takeIf { it.isNotBlank() }
        if (fromIntent != null) return fromIntent

        return contentResolver.getType(uri)?.lowercase()
    }

    private fun readImageBytes(uri: Uri): ByteArray? {
        // Jangan baca terlebih dahulu bila provider sudah melaporkan ukuran.
        val reportedSize = querySize(uri)
        if (reportedSize != null && reportedSize > MAX_IMAGE_BYTES) {
            return ByteArray(MAX_IMAGE_BYTES + 1)
        }

        return try {
            contentResolver.openInputStream(uri)?.use { stream ->
                val buffer = java.io.ByteArrayOutputStream()
                val chunk = ByteArray(8 * 1024)
                while (true) {
                    val read = stream.read(chunk)
                    if (read < 0) break
                    if (buffer.size() + read > MAX_IMAGE_BYTES) {
                        // Baca satu byte lagi agar pemanggil tahu ini terlalu
                        // besar, tanpa memuat seluruh file ke memori.
                        buffer.write(0)
                        return buffer.toByteArray()
                    }
                    buffer.write(chunk, 0, read)
                }
                buffer.toByteArray()
            }
        } catch (_: SecurityException) {
            null
        } catch (_: java.io.IOException) {
            null
        }
    }

    private fun querySize(uri: Uri): Long? {
        return try {
            contentResolver
                .query(
                    uri,
                    arrayOf(OpenableColumns.SIZE),
                    null,
                    null,
                    null,
                )
                ?.use { cursor ->
                    if (!cursor.moveToFirst()) return@use null
                    val index = cursor.getColumnIndex(OpenableColumns.SIZE)
                    if (index < 0) return@use null
                    val value = cursor.getLong(index)
                    value.takeIf { it >= 0 }
                }
        } catch (_: Exception) {
            null
        }
    }

    private fun displayName(uri: Uri, mime: String?): String {
        val name = try {
            contentResolver
                .query(
                    uri,
                    arrayOf(OpenableColumns.DISPLAY_NAME),
                    null,
                    null,
                    null,
                )
                ?.use { cursor ->
                    if (!cursor.moveToFirst()) return@use null
                    val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (index < 0) return@use null
                    cursor.getString(index)
                }
        } catch (_: Exception) {
            null
        }

        return name
            ?.substringAfterLast('/')
            ?.substringAfterLast('\\')
            ?.replace(Regex("[\\\\/:*?\"<>|]"), "_")
            ?.takeIf { it.isNotBlank() }
            ?: fallbackFileName(mime)
    }

    private fun fallbackFileName(mime: String?): String {
        return when (mime) {
            "image/jpeg" -> "gambar-dibagikan.jpg"
            "image/png" -> "gambar-dibagikan.png"
            "image/webp" -> "gambar-dibagikan.webp"
            else -> "gambar-dibagikan"
        }
    }

    companion object {
        private const val SHARE_TARGET_CHANNEL = "literasi_ai/share_target"
        private const val SHARE_TARGET_EVENTS_CHANNEL =
            "literasi_ai/share_target/events"
        private const val MAX_IMAGE_BYTES = 5 * 1024 * 1024
        private const val MAX_TEXT_LENGTH = 10_000

        private val ALLOWED_IMAGE_MIME_TYPES = setOf(
            "image/jpeg",
            "image/jpg",
            "image/png",
            "image/webp",
        )
    }
}
