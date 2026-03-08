package com.example.scconecta_app

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.telephony.euicc.DownloadableSubscription
import android.telephony.euicc.EuiccManager
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodChannel

/**
 * Gerenciador de eSIM para Android
 * Responsável por instalar e gerenciar perfis eSIM
 */
class ESimManager(private val context: Context) {
    
    companion object {
        const val ACTION_DOWNLOAD_SUBSCRIPTION = "com.example.scconecta_app.DOWNLOAD_SUBSCRIPTION"
        const val EXTRA_ACTIVATION_CODE = "activation_code"
        const val REQUEST_CODE_DOWNLOAD = 1001
    }
    
    private var pendingResult: MethodChannel.Result? = null
    private val euiccManager: EuiccManager? by lazy {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            context.getSystemService(Context.EUICC_SERVICE) as? EuiccManager
        } else {
            null
        }
    }
    
    /**
     * Verifica se o dispositivo suporta eSIM
     */
    fun isDeviceSupported(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            euiccManager?.isEnabled == true
        } else {
            false
        }
    }
    
    /**
     * Obtém o EID (eSIM Identifier) do dispositivo
     */
    @RequiresApi(Build.VERSION_CODES.P)
    fun getEid(): String? {
        return try {
            euiccManager?.eid
        } catch (e: SecurityException) {
            null
        }
    }
    
    /**
     * Instala um perfil eSIM usando LPA String
     * 
     * @param lpaString String no formato: LPA:1$servidor$codigo
     * @param result Callback para retornar resultado ao Flutter
     */
    @RequiresApi(Build.VERSION_CODES.P)
    fun installESim(lpaString: String, result: MethodChannel.Result) {
        if (!isDeviceSupported()) {
            result.success(mapOf(
                "success" to false,
                "errorMessage" to "Dispositivo não suporta eSIM",
                "errorType" to "deviceNotSupported"
            ))
            return
        }
        
        // Valida formato da LPA String
        if (!isValidLpaString(lpaString)) {
            result.success(mapOf(
                "success" to false,
                "errorMessage" to "LPA String inválida",
                "errorType" to "invalidLPA"
            ))
            return
        }
        
        try {
            // Guarda o result para usar no callback
            pendingResult = result
            
            // Cria o DownloadableSubscription
            val subscription = DownloadableSubscription.forActivationCode(lpaString)
            
            // Cria PendingIntent para receber resultado
            val intent = Intent(ACTION_DOWNLOAD_SUBSCRIPTION)
            intent.setPackage(context.packageName)
            
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE_DOWNLOAD,
                intent,
                flags
            )
            
            // Registra receiver para receber resultado
            registerDownloadReceiver()
            
            // Inicia download do perfil eSIM
            euiccManager?.downloadSubscription(
                subscription,
                true, // switchAfterDownload - ativa automaticamente após download
                pendingIntent
            )
            
        } catch (e: Exception) {
            result.success(mapOf(
                "success" to false,
                "errorMessage" to "Erro ao instalar eSIM: ${e.message}",
                "errorType" to "systemError"
            ))
        }
    }
    
    /**
     * Registra BroadcastReceiver para receber resultado da instalação
     */
    private fun registerDownloadReceiver() {
        val filter = IntentFilter(ACTION_DOWNLOAD_SUBSCRIPTION)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(
                downloadReceiver,
                filter,
                Context.RECEIVER_NOT_EXPORTED
            )
        } else {
            context.registerReceiver(downloadReceiver, filter)
        }
    }
    
    /**
     * BroadcastReceiver que recebe resultado da instalação
     */
    private val downloadReceiver = object : BroadcastReceiver() {
        @RequiresApi(Build.VERSION_CODES.P)
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action != ACTION_DOWNLOAD_SUBSCRIPTION) return
            
            val resultCode = resultCode
            val detailedCode = intent.getIntExtra(
                EuiccManager.EXTRA_EMBEDDED_SUBSCRIPTION_DETAILED_CODE,
                0
            )
            
            when (resultCode) {
                EuiccManager.EMBEDDED_SUBSCRIPTION_RESULT_OK -> {
                    // Sucesso!
                    pendingResult?.success(mapOf(
                        "success" to true,
                        "iccid" to null, // ICCID será obtido depois
                        "errorMessage" to null,
                        "errorType" to null
                    ))
                }
                
                EuiccManager.EMBEDDED_SUBSCRIPTION_RESULT_ERROR -> {
                    val errorMessage = getErrorMessage(detailedCode)
                    pendingResult?.success(mapOf(
                        "success" to false,
                        "errorMessage" to errorMessage,
                        "errorType" to "installationError"
                    ))
                }
                
                EuiccManager.EMBEDDED_SUBSCRIPTION_RESULT_RESOLVABLE_ERROR -> {
                    // Erro que pode ser resolvido pelo usuário
                    pendingResult?.success(mapOf(
                        "success" to false,
                        "errorMessage" to "Erro resolvível. Verifique as configurações.",
                        "errorType" to "resolvableError"
                    ))
                }
                
                else -> {
                    pendingResult?.success(mapOf(
                        "success" to false,
                        "errorMessage" to "Erro desconhecido: código $resultCode",
                        "errorType" to "unknownError"
                    ))
                }
            }
            
            // Limpa
            pendingResult = null
            try {
                context?.unregisterReceiver(this)
            } catch (e: Exception) {
                // Receiver já foi removido
            }
        }
    }
    
    /**
     * Converte código de erro em mensagem legível
     */
    @RequiresApi(Build.VERSION_CODES.P)
    private fun getErrorMessage(detailedCode: Int): String {
        return when (detailedCode) {
            EuiccManager.EMBEDDED_SUBSCRIPTION_RESULT_ERROR -> 
                "Erro ao baixar perfil eSIM"
            else -> 
                "Erro na instalação (código: $detailedCode)"
        }
    }
    
    /**
     * Valida formato da LPA String
     * Formato esperado: LPA:1$servidor$codigo
     */
    private fun isValidLpaString(lpaString: String): Boolean {
        if (!lpaString.startsWith("LPA:1$")) {
            return false
        }
        
        val parts = lpaString.split("$")
        if (parts.size < 3) {
            return false
        }
        
        return true
    }
    
    /**
     * Obtém informações de um perfil eSIM instalado
     */
    @RequiresApi(Build.VERSION_CODES.P)
    fun getESimInfo(iccid: String): Map<String, Any?>? {
        // TODO: Implementar busca de informações do perfil
        // Requer permissões adicionais e API mais complexa
        return null
    }
    
    /**
     * Remove um perfil eSIM
     */
    @RequiresApi(Build.VERSION_CODES.P)
    fun removeESim(iccid: String, result: MethodChannel.Result) {
        // TODO: Implementar remoção de perfil
        result.success(mapOf(
            "success" to false,
            "errorMessage" to "Funcionalidade não implementada ainda"
        ))
    }
}
