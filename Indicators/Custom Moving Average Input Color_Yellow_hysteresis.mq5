//+------------------------------------------------------------------+
//|                            Custom Moving Average Input Color.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.001"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_style2 STYLE_DOT

#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_style3 STYLE_DOT

#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4 STYLE_SOLID
int InpMAShift = 0;
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
//--- input parameters
input int   window_backward = 7;
input int    IntMALongPeriodBackWard = 65;
input int     MALongType = ma_sma;
input int            InpMAFastPeriod=20;
input int InpMAMethod = 0;         // Period
// Shift

//input color          InpColor=clrYellow;       // Color
///input color          InpColor=clrGreen;
//--- indicator buffers
double               ExtLineBuffer[];
double               ExtLineUpBuffer[];
double               ExtLineDownBuffer[];
double               ExtLineLongMA[];
double buffer_MA_fast[];
double buffer_MA_slow[];

int MA_fast_handle;
int MA_slow_handle;
ENUM_MA_METHOD input_to_type(int mode)
  {
   switch(mode)
     {
      case ma_sma:
         return (MODE_SMA);
      case ma_ema:
         return(MODE_EMA);
      case ma_smma:
         return(MODE_SMMA);
      case ma_lwma:
         return(MODE_LWMA);
      default :
         Alert("Custom White indicicator no input to type conversion");
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {

   int limit;
   if(prev_calculated==0)
      limit=IntMALongPeriodBackWard+begin;
   else
      limit=prev_calculated-1;

   int toCopy = rates_total - limit;


   int copy_slow=CopyBuffer(MA_slow_handle,0,0,toCopy,buffer_MA_slow); // copy the last values
   int copy_fast=CopyBuffer(MA_fast_handle,0,0,toCopy,buffer_MA_fast);

//ArraySetAsSeries(buffer_MA_slow,true);
// ArraySetAsSeries(buffer_MA_fast,true);



//--- first calculation or number of bars was changed


   double values_slow_MA [];
   double gap_slow_fast_ma [];
   double values_fast_MA [];
   double max = 0;
   double min = 0;
   int startCopy = 0;
   for(int i=limit; i<rates_total && !IsStopped(); i++)
     {
      max = 0;
      min = 0;
      ArrayFree(values_slow_MA);
      ArrayResize(values_slow_MA,window_backward);
      ArrayFree(values_fast_MA);
      ArrayResize(values_fast_MA,window_backward);
      int startCopy;
     // startCopy = i-1-window_backward; // I will start copy from 65 + 7 
      if(i >= ( IntMALongPeriodBackWard + window_backward-1)) // starting at i = 71
        {
            startCopy = i - (IntMALongPeriodBackWard + window_backward - 1);
         ArrayCopy(values_slow_MA,buffer_MA_slow,0,startCopy,window_backward);
         ArrayCopy(values_fast_MA,buffer_MA_fast,0,startCopy,window_backward);

         ArrayFree(gap_slow_fast_ma);
         ArrayResize(gap_slow_fast_ma,window_backward);



         for(int j = 0 ; j < window_backward ; j++)
           {
            gap_slow_fast_ma[j] = MathAbs(values_slow_MA[j]-values_fast_MA[j]);
           }
         max = gap_slow_fast_ma[ArrayMaximum(gap_slow_fast_ma)];
        }
      else
         max = 0;
      // ArrayReverse(buffer_MA_slow);
      // ArrayReverse(buffer_MA_fast);
      //ExtLineBuffer[i] =buffer_MA_fast[i-limit]; // update of MA
      //  ExtLineLongMA[i] = buffer_MA_slow[i-limit];
      ExtLineBuffer[i] =buffer_MA_fast[i-limit]; // update of MA
      ExtLineLongMA[i] = buffer_MA_slow[i-limit];
      ///   max = 0;
      ExtLineUpBuffer[i] = ExtLineBuffer[i]+max;
      ExtLineDownBuffer[i] = ExtLineBuffer[i]-max;

     }

  }
//---

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {

   MA_slow_handle=iCustom(NULL,0,"Examples\\Custom Moving Average Input Color_White",
                          IntMALongPeriodBackWard,
                          0,
                          InpMAMethod,
                          PRICE_CLOSE);
   MA_fast_handle=iCustom(NULL,0,"Examples\\Custom Moving Average Input Color_White",
                          InpMAFastPeriod,
                          0,
                          InpMAMethod,
                          PRICE_CLOSE);



   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineDownBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineLongMA,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpMAMethod);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,InpMAShift);
   IndicatorSetString(INDICATOR_SHORTNAME,"Fast MA Hysteresis " + IntegerToString(InpMAFastPeriod) + " ( " + EnumToString(input_to_type(InpMAMethod)) + ")" + "MA LONG" + IntegerToString(IntMALongPeriodBackWard) +  "("  + EnumToString(input_to_type(MALongType)));
//-
//--- color line
//   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpColor);
//--- name for DataWindow

//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- initialization done
  }
//+------------------------------------------------------------------+
//|  Moving Average                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- check for bars count
   if(rates_total<IntMALongPeriodBackWard-1+begin)
      return(0);// not enough bars for calculation
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
      ArrayInitialize(ExtLineBuffer,0);
//--- sets first bar from what index will be draw
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,IntMALongPeriodBackWard-1+begin);


   CalculateMA(rates_total,prev_calculated,begin,price);


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
