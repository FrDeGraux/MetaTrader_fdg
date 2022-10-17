#include <fxsaber\MultiTester\MultiTester.mqh> // Множественные прогоны/оптимизации в Тестере.

// Эта функция отвечает за формирование списка заданий.
void SetTesterSettings()
{
  static const string ExpertNames[] = {"Examples\\Moving Average\\Moving Average.ex5",
                                       "Examples\\MACD\\MACD Sample.ex5",
                                       "Examples\\Controls\\Controls.ex5",
                                       "Examples\\ChartInChart\\ChartInChart.ex5"};

  const int Size = ArraySize(ExpertNames);

  for (int i = 0; i < Size; i++)
    TesterSettings.Add(ExpertNames[i]);
}