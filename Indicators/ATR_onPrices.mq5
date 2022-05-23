//+------------------------------------------------------------------+
//|                                                          ATR.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2020, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Average True Range"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrPaleGreen
#property indicator_style1  STYLE_DOT
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrPaleGreen
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrPaleVioletRed
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrPaleVioletRed
//--- input parameters
input int ExtPeriodATR=14;  // ATR period
input double  AtrMultiplier_SL = 3.0; // Atr 1st multiplier
input double  AtrMultiplier_TP = 6; // Atr 2nd multiplier


//--- we will keep the number of values in the Average True Range indicator
int    bars_calculated=0;
//--- indicator buffers


double ExtTRBuffer[],ExtATRBuffer[],ExtTRBuffer_SL_UP[],ExtTRBuffer_SL_DOWN[],ExtTTRBuffer_TP_UP[],ExtTRBuffer_TP_Down[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {

   SetIndexBuffer(0,ExtTRBuffer_SL_UP,INDICATOR_DATA);
   SetIndexBuffer(1,ExtTRBuffer_SL_DOWN,INDICATOR_DATA);
   SetIndexBuffer(2,ExtTTRBuffer_TP_UP,INDICATOR_DATA);
   SetIndexBuffer(3,ExtTRBuffer_TP_Down,INDICATOR_DATA);   
   SetIndexBuffer(4,ExtTRBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtATRBuffer,INDICATOR_DATA);
IndicatorSetString(INDICATOR_SHORTNAME,"ATR Price ( Period" + DoubleToString(ExtPeriodATR) + ")" + "risk/Reward (" + IntegerToString(AtrMultiplier_SL) + ";" + IntegerToString(AtrMultiplier_SL));
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total<=ExtPeriodATR)
      return(0);

   int i,start;
//--- preliminary calculations
   if(prev_calculated==0)
     {
      ExtTRBuffer[0]=0.0;
      ExtATRBuffer[0]=0.0;
      //--- filling out the array of True Range values for each period
      for(i=1; i<rates_total && !IsStopped(); i++)
         ExtTRBuffer[i]=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
      //--- first AtrPeriod values of the indicator are not calculated
      double firstValue=0.0;
      for(i=1; i<=ExtPeriodATR; i++)
        {
         ExtATRBuffer[i]=0.0;
         firstValue+=ExtTRBuffer[i];
        }
      //--- calculating the first value of the indicator
      firstValue/=ExtPeriodATR;
      ExtATRBuffer[ExtPeriodATR]=firstValue;
      start=ExtPeriodATR+1;
     }
   else
      start=prev_calculated-1;
//--- the main loop of calculations
   for(i=start; i<rates_total && !IsStopped(); i++)
     {
      ExtTRBuffer[i]=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
      ExtATRBuffer[i]=ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-ExtPeriodATR])/ExtPeriodATR;
      ExtTRBuffer_SL_UP[i] = close[i]  + AtrMultiplier_SL*ExtATRBuffer[i] ;
      ExtTRBuffer_SL_DOWN[i] = close[i]  - AtrMultiplier_SL*ExtATRBuffer[i] ;
      ExtTTRBuffer_TP_UP[i] = close[i]  + AtrMultiplier_TP*ExtATRBuffer[i] ;
      ExtTRBuffer_TP_Down[i] = close[i]  - AtrMultiplier_TP*ExtATRBuffer[i] ;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }

  
