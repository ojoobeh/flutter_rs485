package com.example.untitled4


import android.util.Log
import java.io.File
import java.io.FileDescriptor
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream

class SerialPort {
    private var mFd: FileDescriptor? = null
    private var mFileInputStream: FileInputStream? = null
    private var mFileOutputStream: FileOutputStream? = null
    private var mInputStream: InputStream? = null
    private var mOutputStream: OutputStream? = null

    val inputStream: InputStream?
        get() = mInputStream

    val outputStream: OutputStream?
        get() = mOutputStream

    constructor(device: File, baudrate: Int) {
        try {
            mFd = open(device.absolutePath, baudrate, 0)
        } catch (e: SecurityException) {
            Log.e(TAG, "You do not have permission to open the serial port")
            throw e
        } catch (e: IOException) {
            Log.e(TAG, "Error opening serial port: ${e.message}")
            throw e
        } catch (e: Exception) {
            Log.e(TAG, "Error opening serial port: ${e.message}")
            throw e
        }

        if (mFd == null) {
            Log.e(TAG, "Native open returns null")
            throw IOException()
        }

        mFileInputStream = FileInputStream(mFd)
        mFileOutputStream = FileOutputStream(mFd)
        mInputStream = mFileInputStream
        mOutputStream = mFileOutputStream
    }

    fun close() {
        try {
            mInputStream?.close()
            mOutputStream?.close()
        } catch (e: IOException) {
            Log.e(TAG, "Error closing serial port: ${e.message}")
        } finally {
            mInputStream = null
            mOutputStream = null
            mFileInputStream = null
            mFileOutputStream = null

            mFd?.let {
                close(it)
                mFd = null
            }
        }
    }

    private external fun open(path: String, baudrate: Int, flags: Int): FileDescriptor
    private external fun close(fd: FileDescriptor)

    companion object {
        private const val TAG = "SerialPort"

        init {
            System.loadLibrary("serial_port")
        }
    }
}