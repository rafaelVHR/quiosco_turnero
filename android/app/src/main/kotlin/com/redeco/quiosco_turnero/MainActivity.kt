package com.redeco.quiosco_turnero

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val canal = "com.redeco.turnero/impresora"
    private val accionPermiso = "com.redeco.turnero.USB_PERMISO"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, canal)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "listar" -> result.success(listar())
                    "imprimir" -> imprimir(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun usbManager(): UsbManager =
        getSystemService(Context.USB_SERVICE) as UsbManager

    private fun interfazImpresora(d: UsbDevice): UsbInterface? {
        for (i in 0 until d.interfaceCount) {
            val intf = d.getInterface(i)
            if (intf.interfaceClass == UsbConstants.USB_CLASS_PRINTER) return intf
        }
        return null
    }

    private fun endpointSalida(intf: UsbInterface): UsbEndpoint? {
        for (j in 0 until intf.endpointCount) {
            val e = intf.getEndpoint(j)
            if (e.type == UsbConstants.USB_ENDPOINT_XFER_BULK &&
                e.direction == UsbConstants.USB_DIR_OUT
            ) return e
        }
        return null
    }

    private fun listar(): List<String> {
        return usbManager().deviceList.values.map {
            val marca = if (interfazImpresora(it) != null) " (impresora)" else ""
            "${it.productName} [${it.vendorId}:${it.productId}]$marca"
        }
    }

    private fun imprimir(call: MethodCall, result: MethodChannel.Result) {
        val datos = call.argument<ByteArray>("bytes")
        if (datos == null) {
            result.success("ERROR: no llegaron datos para imprimir")
            return
        }
        val man = usbManager()
        val d = man.deviceList.values.firstOrNull { interfazImpresora(it) != null }
        if (d == null) {
            result.success("ERROR: no hay ninguna impresora USB conectada")
            return
        }
        if (man.hasPermission(d)) {
            ejecutar(d, datos, result)
            return
        }
        pedirPermiso(man, d) { concedido ->
            if (concedido) {
                ejecutar(d, datos, result)
            } else {
                result.success("ERROR: permiso USB denegado")
            }
        }
    }

    private fun pedirPermiso(
        man: UsbManager,
        d: UsbDevice,
        alResponder: (Boolean) -> Unit
    ) {
        val receptor = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                try {
                    unregisterReceiver(this)
                } catch (e: Exception) {
                }
                alResponder(
                    intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                )
            }
        }
        val filtro = IntentFilter(accionPermiso)
        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(receptor, filtro, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(receptor, filtro)
        }
        val intent = Intent(accionPermiso).setPackage(packageName)
        val flags = if (Build.VERSION.SDK_INT >= 31) PendingIntent.FLAG_MUTABLE else 0
        val pi = PendingIntent.getBroadcast(this, 0, intent, flags)
        man.requestPermission(d, pi)
    }

    private fun ejecutar(d: UsbDevice, datos: ByteArray, result: MethodChannel.Result) {
        Thread {
            val r = try {
                escribir(d, datos)
            } catch (e: Exception) {
                "ERROR: ${e.message}"
            }
            runOnUiThread { result.success(r) }
        }.start()
    }

    private fun escribir(d: UsbDevice, datos: ByteArray): String {
        val intf = interfazImpresora(d)
            ?: return "ERROR: el dispositivo no tiene interfaz de impresora"
        val ep = endpointSalida(intf)
            ?: return "ERROR: no se encontró el canal de salida"
        val con = usbManager().openDevice(d)
            ?: return "ERROR: no se pudo abrir el dispositivo"
        try {
            if (!con.claimInterface(intf, true)) {
                return "ERROR: no se pudo reclamar la interfaz"
            }
            var enviado = 0
            while (enviado < datos.size) {
                val n = minOf(16384, datos.size - enviado)
                val r = con.bulkTransfer(ep, datos, enviado, n, 5000)
                if (r <= 0) {
                    return "ERROR: falló el envío tras $enviado de ${datos.size} bytes"
                }
                enviado += r
            }
            con.releaseInterface(intf)
            return "OK: $enviado bytes"
        } finally {
            con.close()
        }
    }
}
