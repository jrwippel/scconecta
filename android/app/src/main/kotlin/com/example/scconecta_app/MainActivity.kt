package com.example.scconecta_app

import android.content.Context
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.scconecta.app/roaming"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getLinesInfo") {
                try {
                    val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                    val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

                    val activeSubscriptions = sm.activeSubscriptionInfoList

                    val linesList = activeSubscriptions?.map { info ->
                        val specificTm = tm.createForSubscriptionId(info.subscriptionId)

                        mapOf(
                            "carrierName" to info.displayName.toString(),
                            "isEsim" to info.isEmbedded,
                            "roamingEnabled" to specificTm.isNetworkRoaming, // rede atual está em roaming?
                            "roamingAllowed" to (info.dataRoaming == SubscriptionManager.DATA_ROAMING_ENABLE), // usuário permitiu roaming?
                            "slotIndex" to info.simSlotIndex,
                            "isActive" to info.isActive
                        )
                    } ?: emptyList<Map<String, Any>>()

                    result.success(linesList)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
