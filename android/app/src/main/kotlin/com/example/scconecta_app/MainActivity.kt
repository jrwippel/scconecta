package com.example.scconecta_app

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import android.telephony.euicc.EuiccManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.scconecta.app/roaming"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkEsimSupport" -> {
                    val euiccManager = getSystemService(Context.EUICC_SERVICE) as? EuiccManager
                    val isSupported = euiccManager?.isEnabled ?: false
                    val eid = if (isSupported) euiccManager?.eid ?: "Não disponível" else "N/A"
                    result.success(mapOf("isSupported" to isSupported, "eid" to eid))
                }
                "getLinesInfo" -> {
                    try {
                        val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                        val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                        val activeSubscriptions = sm.activeSubscriptionInfoList
                        val linesList = mutableListOf<Map<String, Any>>()

                        activeSubscriptions?.forEach { info ->
                            val specificTm = tm.createForSubscriptionId(info.subscriptionId)
                            // CORREÇÃO: Verifica se a CHAVE de roaming está ligada no Android
                            val isRoamingConfigEnabled = (info.dataRoaming == SubscriptionManager.DATA_ROAMING_ENABLE)
                            
                            linesList.add(mapOf(
                                "carrierName" to info.displayName.toString(),
                                "isEsim" to info.isEmbedded,
                                "networkType" to getNetworkTypeName(specificTm.dataNetworkType),
                                "roamingEnabled" to isRoamingConfigEnabled, // Agora retorna se a CHAVE está ON
                                "roamingAllowed" to isRoamingConfigEnabled,
                                "slotIndex" to info.simSlotIndex,
                                "isLineActive" to true
                            ))
                        }
                        
                        // Simulação SC CONECTA
                        linesList.add(mapOf(
                            "carrierName" to "SC CONECTA TRAVEL",
                            "isEsim" to true,
                            "networkType" to "5G",
                            "roamingEnabled" to false,
                            "roamingAllowed" to false,
                            "slotIndex" to 1,
                            "isLineActive" to true
                        ))

                        result.success(linesList)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "openRoamingSettings" -> {
                    val intent = Intent(Settings.ACTION_DATA_ROAMING_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                "openSimSettings" -> {
                    val simIntent = Intent("android.settings.NETWORK_OPERATOR_SETTINGS")
                    simIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    try {
                        startActivity(simIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        val generalIntent = Intent(Settings.ACTION_WIRELESS_SETTINGS)
                        generalIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(generalIntent)
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getNetworkTypeName(type: Int): String {
        return when (type) {
            TelephonyManager.NETWORK_TYPE_NR -> "5G"
            TelephonyManager.NETWORK_TYPE_LTE -> "4G"
            else -> "4G"
        }
    }
}