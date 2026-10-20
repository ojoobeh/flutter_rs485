//package com.example.untitled4
//
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity : FlutterActivity()
package com.example.untitled4

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL = "com.example.untitled4/serial"
    private val EVENT_CHANNEL = "com.example.untitled4/serial_data"

    private var serialPort: SerialPort? = null
    private var inputStream: InputStream? = null
    private var outputStream: OutputStream? = null
    private var eventSink: EventChannel.EventSink? = null

    private var isReading = false
    private val executor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method Channel برای دستورات
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "open" -> {
                    val port = call.argument<String>("port") ?: "/dev/ttyS8"
                    val baudRate = call.argument<Int>("baudRate") ?: 57600
                    val success = openSerialPort(port, baudRate)
                    result.success(success)
                }
                "write" -> {
                    val data = call.argument<List<Int>>("data")
                    if (data != null) {
                        val success = writeData(data.map { it.toByte() }.toByteArray())
                        result.success(success)
                    } else {
                        result.success(false)
                    }
                }
                "close" -> {
                    closeSerialPort()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Event Channel برای دریافت داده‌ها
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                startReading()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                stopReading()
            }
        })
    }

    private fun openSerialPort(port: String, baudRate: Int): Boolean {
        return try {
            serialPort = SerialPort(File(port), baudRate)
            inputStream = serialPort?.inputStream
            outputStream = serialPort?.outputStream
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun writeData(data: ByteArray): Boolean {
        return try {
            outputStream?.write(data)
            outputStream?.flush()
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun startReading() {
        if (isReading) return
        isReading = true

        executor.execute {
            val buffer = ByteArray(5)
            var index = 0
            var lastByteTime = System.nanoTime()
            val timeoutNs = 4_000_000L // 4 میلی‌ثانیه

            try {
                while (isReading) {
                    val available = inputStream?.available() ?: 0
                    if (available > 0) {
                        val b = inputStream?.read() ?: -1
                        if (b != -1) {
                            buffer[index++] = b.toByte()
                            lastByteTime = System.nanoTime()

                            if (index == 5) {
                                val packet = buffer.clone()
                                index = 0
                                sendToFlutter(packet)
                            }
                        }
                    } else {
                        if (index > 0 && (System.nanoTime() - lastByteTime) > timeoutNs) {
                            index = 0
                        }
                        Thread.sleep(1)
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun sendToFlutter(data: ByteArray) {
        mainHandler.post {
            eventSink?.success(data)
        }
    }

    private fun stopReading() {
        isReading = false
    }

    private fun closeSerialPort() {
        stopReading()
        try {
            inputStream?.close()
            outputStream?.close()
            serialPort?.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
        serialPort = null
        inputStream = null
        outputStream = null
    }

    override fun onDestroy() {
        closeSerialPort()
        executor.shutdown()
        super.onDestroy()
    }
}