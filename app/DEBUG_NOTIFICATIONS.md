# 🔔 Debug: Notificações Não Funcionam

## Checklist de Permissões Android

### 1. ✅ Permissões no AndroidManifest.xml

Verifique se `android/app/src/main/AndroidManifest.xml` tem:

```xml
<manifest>
    <!-- ADICIONAR estas linhas ANTES de <application> -->
    
    <!-- Notificações básicas (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <!-- Alarmes exatos (Android 12+) -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    
    <!-- Wake lock para notificações -->
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    
    <application>
        ...
        
        <!-- ADICIONAR dentro de <application> -->
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

### 2. 🔧 Testar Permissões Manualmente

Após instalar o app, vá em:
```
Configurações do Android → Apps → Pesandinho → Permissões
```

Verifique se está ativado:
- ✅ **Notificações** 
- ✅ **Alarmes e lembretes** (Android 12+)

### 3. 🐛 Debug no Console

Adicione isto no `reminder_section.dart` após agendar (linha ~95):

```dart
await svc.scheduleWeeklyReminders(...);

// DEBUG
print('✅ Lembretes agendados!');
final pending = await ref.read(reminderServiceProvider).hasActiveReminders();
print('📱 Tem lembretes ativos? $pending');
// FIM DEBUG

await _loadSavedConfig();
```

Execute `flutter run` e veja o console após configurar.

### 4. 🔍 Verificar Notificações Pendentes

Adicione um botão temporário de debug em `reminder_section.dart`:

```dart
// Adicionar após os botões principais
TextButton(
  onPressed: () async {
    final plugin = ref.read(reminderPluginProvider);
    final pending = await plugin.pendingNotificationRequests();
    print('📋 Notificações pendentes: ${pending.length}');
    for (final p in pending) {
      print('  - ID ${p.id}: ${p.title}');
    }
  },
  child: const Text('DEBUG: Ver Pendentes'),
),
```

### 5. ⚠️ Problemas Comuns

**Nada acontece ao clicar "Confirmar":**
- ✅ Check: Console mostra erros?
- ✅ Check: Permissões concedidas no Android?
- ✅ Check: `hasActiveReminders()` retorna true?

**Lembretes não disparam:**
- ⏰ Pode levar até 15min no modo inexato
- 🔋 Battery saver pode bloquear
- 📱 Algumas fabricantes (Xiaomi, Huawei) bloqueiam por padrão

### 6. 🧪 Teste Rápido

Para testar se notificações funcionam, adicione isto temporariamente:

```dart
// Testar notificação imediata
final plugin = ref.read(reminderPluginProvider);
await plugin.show(
  999,
  'Teste',
  'Se você vê isso, notificações funcionam!',
  const NotificationDetails(
    android: AndroidNotificationDetails(
      'test',
      'Test Channel',
      importance: Importance.high,
    ),
  ),
);
```

---

## 📝 Próximos Passos

1. **Verificar AndroidManifest.xml** (adicionar permissões)
2. **Recompilar o app** (`flutter clean && flutter run`)
3. **Conceder permissões manualmente** nas configurações do Android
4. **Testar novamente**

Se ainda não funcionar após adicionar as permissões, me envie o que aparece no console!
