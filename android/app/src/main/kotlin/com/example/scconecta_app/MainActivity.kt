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
    private val ESIM_CHANNEL = "com.example.scconecta_app/esim"
    private val NEW_ESIM_CHANNEL = "com.scconecta/esim"  // Novo canal para Fase 1
    private var lastKnownLineCount = 0
    
    // Gerenciador de eSIM
    private lateinit var eSimManager: ESimManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Inicializa gerenciador de eSIM
        eSimManager = ESimManager(this)
        
        // Canal original de roaming
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
                            
                            val isRoamingConfigEnabled = (info.dataRoaming == SubscriptionManager.DATA_ROAMING_ENABLE)
                            val mcc = info.mccString ?: "" 
                            val isNetworkRoaming = specificTm.isNetworkRoaming 
                            
                            linesList.add(mapOf(
                                "carrierName" to info.displayName.toString(),
                                "isEsim" to info.isEmbedded,
                                "networkType" to getNetworkTypeName(specificTm.dataNetworkType),
                                "roamingEnabled" to isRoamingConfigEnabled,
                                "mcc" to mcc,
                                "isNetworkRoaming" to isNetworkRoaming,
                                "slotIndex" to info.simSlotIndex,
                                "isLineActive" to true 
                            ))
                        }
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
                    val intent = Intent(Settings.ACTION_WIRELESS_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                "openWifiSettings" -> {
                    val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                
                "checkConnectivity" -> {
                    try {
                        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as android.net.ConnectivityManager
                        val activeNetwork = connectivityManager.activeNetworkInfo
                        val isConnected = activeNetwork?.isConnectedOrConnecting == true
                        val connectionType = when {
                            activeNetwork?.type == android.net.ConnectivityManager.TYPE_WIFI -> "wifi"
                            activeNetwork?.type == android.net.ConnectivityManager.TYPE_MOBILE -> "mobile"
                            else -> "none"
                        }
                        result.success(mapOf(
                            "isConnected" to isConnected,
                            "connectionType" to connectionType
                        ))
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                else -> result.notImplemented()
            }
        }
        
        // Novo canal para detecção de eSIM
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ESIM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkNewESim" -> {
                    try {
                        val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                        val activeSubscriptions = sm.activeSubscriptionInfoList
                        val currentLineCount = activeSubscriptions?.size ?: 0
                        
                        // Verifica se há uma nova linha (eSIM instalado)
                        if (currentLineCount > lastKnownLineCount) {
                            // Encontra o novo eSIM
                            val newESim = activeSubscriptions?.find { it.isEmbedded }
                            if (newESim != null) {
                                lastKnownLineCount = currentLineCount
                                result.success(mapOf(
                                    "hasNewESim" to true,
                                    "carrierName" to newESim.displayName.toString(),
                                    "iccid" to (newESim.iccId ?: ""),
                                    "slotIndex" to newESim.simSlotIndex,
                                    "isEmbedded" to newESim.isEmbedded
                                ))
                                return@setMethodCallHandler
                            }
                        }
                        
                        lastKnownLineCount = currentLineCount
                        result.success(mapOf("hasNewESim" to false))
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                "getAllLines" -> {
                    try {
                        val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                        val activeSubscriptions = sm.activeSubscriptionInfoList
                        val linesList = mutableListOf<Map<String, Any>>()

                        activeSubscriptions?.forEach { info ->
                            linesList.add(mapOf(
                                "carrierName" to info.displayName.toString(),
                                "isEsim" to info.isEmbedded,
                                "iccid" to (info.iccId ?: ""),
                                "slotIndex" to info.simSlotIndex,
                                "subscriptionId" to info.subscriptionId
                            ))
                        }
                        
                        lastKnownLineCount = linesList.size
                        result.success(linesList)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                else -> result.notImplemented()
            }
        }
        
        // NOVO: Canal para Fase 1 - Instalação automática de eSIM
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NEW_ESIM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDeviceSupported" -> {
                    try {
                        val isSupported = eSimManager.isDeviceSupported()
                        result.success(isSupported)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                
                "installESim" -> {
                    try {
                        val lpaString = call.argument<String>("lpaString")
                        if (lpaString == null) {
                            result.error("INVALID_ARGUMENT", "LPA String é obrigatório", null)
                            return@setMethodCallHandler
                        }
                        
                        // Usa o ESimManager real
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                            eSimManager.installESim(lpaString, result)
                        } else {
                            result.success(mapOf(
                                "success" to false,
                                "errorMessage" to "Android 9 ou superior é necessário",
                                "errorType" to "deviceNotSupported"
                            ))
                        }
                    } catch (e: Exception) {
                        result.success(mapOf(
                            "success" to false,
                            "errorMessage" to e.message,
                            "errorType" to "systemError"
                        ))
                    }
                }
                
                "openRoamingSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_DATA_ROAMING_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        // Fallback para configurações gerais
                        val intent = Intent(Settings.ACTION_WIRELESS_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    }
                }
                
                "openLineSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_WIRELESS_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                "openGeneralSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                "getESimStatus" -> {
                    try {
                        val iccid = call.argument<String>("iccid")
                        val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                        val activeSubscriptions = sm.activeSubscriptionInfoList
                        
                        val subscription = activeSubscriptions?.find { it.iccId == iccid }
                        if (subscription != null) {
                            result.success(mapOf(
                                "iccid" to subscription.iccId,
                                "isActive" to true,
                                "isRoamingEnabled" to (subscription.dataRoaming == SubscriptionManager.DATA_ROAMING_ENABLE),
                                "carrierName" to subscription.displayName.toString()
                            ))
                        } else {
                            result.success(null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                
                "getInstalledProfiles" -> {
                    try {
                        val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                        val activeSubscriptions = sm.activeSubscriptionInfoList
                        val profiles = mutableListOf<Map<String, Any>>()
                        
                        activeSubscriptions?.filter { it.isEmbedded }?.forEach { info ->
                            profiles.add(mapOf(
                                "iccid" to (info.iccId ?: ""),
                                "carrierName" to info.displayName.toString(),
                                "isActive" to true
                            ))
                        }
                        
                        result.success(profiles)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
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
            TelephonyManager.NETWORK_TYPE_HSPAP, 
            TelephonyManager.NETWORK_TYPE_HSPA -> "3G"
            else -> "4G"
        }
    }
}