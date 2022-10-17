#include <fxsaber\MultiTester\MultiTester.mqh> // Множественные прогоны/оптимизации в Тестере.

sinput bool Period_M1 = false;         // Включить M1
sinput bool Period_M5 = false;         // Включить M5
sinput bool Period_M15 = false;        // Включить M15
sinput bool OnlyCustomSymbols = false; // Только кастомные символы

// Эта функция отвечает за формирование списка заданий.
void SetTesterSettings()
{
  // Перебираем все символы из Обзора рынка.
  for (int i = SymbolsTotal(true) - 1; i >= 0; i--)
  {
    const string Name = SymbolName(i, true);

    if (!OnlyCustomSymbols || SymbolInfoInteger(Name, SYMBOL_CUSTOM))
    {
      if (Period_M1)
        TesterSettings.Add(NULL, Name, PERIOD_M1);  // Если M1-задан, добавляем каждый символ с таким ТФ.

      if (Period_M5)
        TesterSettings.Add(NULL, Name, PERIOD_M5);  // Если M1-задан, добавляем каждый символ с таким ТФ.

      if (Period_M15)
        TesterSettings.Add(NULL, Name, PERIOD_M15); // Если M15-задан, добавляем каждый символ с таким ТФ.

      if (!Period_M1 && !Period_M5 && !Period_M15)  // Если ни один ТФ не задан, запустим на ТФ советника.
        TesterSettings.Add(NULL, Name);
    }
  }
}