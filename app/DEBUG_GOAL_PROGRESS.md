# 🐛 Debug: Goal Progress Not Working

## Possíveis Causas:

### 1. ❌ Nenhuma Meta Cadastrada
**Sintoma:** Card não aparece
**Solução:**
1. Vá em Settings
2. Role até "Goal" / "Meta"
3. Preencha:
   - Target Weight (ex: 75.0)
   - Target Date (opcional)
4. Clique "Set New Goal"

### 2. ❌ Sem Peso Atual
**Sintoma:** Card não aparece
**Solução:**
1. Adicione pelo menos 1 entrada de peso
2. Use o botão "+" no dashboard

### 3. ❌ chartDataProvider Não Tem Métricas
**Debug:** Adicione isso temporariamente no dashboard_page.dart

Após a linha 117 (`chartDataAsync.when(`), adicione:

```dart
// DEBUG - remover depois
print('DEBUG chartData: hasGoal=${chartData.hasGoal}, metrics=${chartData.metrics != null}');
if (chartData.metrics != null) {
  print('  deltaToGoal=${chartData.metrics!.deltaToGoal}');
  print('  etaDays=${chartData.metrics!.etaDays}');
}
// FIM DEBUG
```

Então rode `flutter run` e veja no console o que está printando.

### 4. ❌ ChartCalculator Não Calcula Métricas

Verifique se `ChartCalculator.calculate()` está retornando métricas.

---

## Teste Rápido:

1. **Criar Meta:**
   ```
   Settings → Goal
   Target: 70.0 kg
   Date: [qualquer data futura]
   Clique "Set New Goal"
   ```

2. **Adicionar Peso:**
   ```
   Dashboard → Botão +
   Peso: 75.0 kg
   Salvar
   ```

3. **Verificar:**
   - Volte ao Dashboard
   - O card "Goal Progress" deve aparecer entre "Goal" e "Weight Trend"

---

## Se Ainda Não Funcionar:

Envie screenshot do console após adicionar os prints de debug acima.
