package com.rgnets.rgnets_fdk

import android.util.Log
import androidx.annotation.Keep

class Iperf3Bridge(private val progressHandler: Iperf3ProgressHandler?) {
    companion object {
        private const val TAG = "Iperf3Bridge"
        private var libraryLoaded = false
        private var loadError: String? = null

        init {
            try {
                // Load the native library
                System.loadLibrary("iperf3_jni")
                libraryLoaded = true
                Log.i(TAG, "Successfully loaded iperf3_jni native library")
            } catch (e: UnsatisfiedLinkError) {
                libraryLoaded = false
                loadError = "Failed to load iperf3_jni library: ${e.message}"
                Log.e(TAG, loadError, e)
            } catch (e: Exception) {
                libraryLoaded = false
                loadError = "Unexpected error loading iperf3_jni library: ${e.message}"
                Log.e(TAG, loadError, e)
            }
        }

        fun isLibraryLoaded(): Boolean = libraryLoaded
        fun getLoadError(): String? = loadError
    }

    // Store reference for native callbacks
    private var nativeHandle: Long = 0

    private fun checkLibraryLoaded() {
        if (!libraryLoaded) {
            throw RuntimeException("Native library not loaded: ${loadError ?: "Unknown error"}")
        }
    }

    // Native method declarations - these will be implemented in C/C++ via JNI
    private external fun nativeRunClient(
        host: String,
        port: Int,
        duration: Int,
        parallel: Int,
        reverse: Boolean,
        useUdp: Boolean,
        bandwidth: Long
    ): Map<String, Any>

    private external fun nativeCancelClient()
    private external fun nativeStartServer(port: Int, useUdp: Boolean): Boolean
    private external fun nativeStopServer(): Boolean
    private external fun nativeGetVersion(): String

    // Kotlin wrapper methods
    fun runClient(
        host: String,
        port: Int,
        duration: Int,
        parallel: Int,
        reverse: Boolean,
        useUdp: Boolean = true,  // Default to UDP
        bandwidthBps: Long = 0  // Bandwidth in bits/sec (0 = use iperf3 default)
    ): Map<String, Any> {
        checkLibraryLoaded()
        return nativeRunClient(host, port, duration, parallel, reverse, useUdp, bandwidthBps)
    }

    fun cancelClient() {
        checkLibraryLoaded()
        nativeCancelClient()
    }

    fun startServer(port: Int, useUdp: Boolean = true): Boolean {  // Default to UDP
        checkLibraryLoaded()
        return nativeStartServer(port, useUdp)
    }

    fun stopServer(): Boolean {
        checkLibraryLoaded()
        return nativeStopServer()
    }

    fun getVersion(): String {
        checkLibraryLoaded()
        return nativeGetVersion()
    }

    // Called from JNI to send progress updates
    // RTT is for TCP, jitter is for UDP
    @Keep
    @Suppress("unused")
    fun onProgress(interval: Int, bytesTransferred: Long, bitsPerSecond: Double, jitter: Double, lostPackets: Int, rtt: Double) {
        val progressData = mutableMapOf<String, Any>(
            "interval" to interval,
            "bytesTransferred" to bytesTransferred,
            "bitsPerSecond" to bitsPerSecond,
            "mbps" to (bitsPerSecond / 1000000.0)
        )

        // Add protocol-specific metrics
        if (rtt > 0) {
            // TCP mode: include RTT
            progressData["rtt"] = rtt
        }
        if (jitter > 0) {
            // UDP mode: include jitter
            progressData["jitter"] = jitter
            progressData["lostPackets"] = lostPackets
        }

        progressHandler?.sendProgress(progressData)
    }
}
