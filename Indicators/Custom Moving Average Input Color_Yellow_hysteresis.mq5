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
#property indicator_color4  clrGray
#property indicator_style4 STYLE_DOT
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
input int            InpMAPeriod=20;
input int InpMAMethod = 1;         // Period
          // Shift
int InpMAShift = 0;
//input color          InpColor=clrYellow;       // Color
///input color          InpColor=clrGreen;
//--- indicator buffers
double               ExtLineBuffer[];
double               ExtLineUpBuffer[];
double               ExtLineDownBuffer[];
double               ExtLineLongMA[];
double buffer_MA[];

int MA_handle;
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
void CalculateSimpleMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
     {
      limit=InpMAPeriod+begin;
      //--- set empty value for first limit bars
      for(i=0; i<limit-1; i++)
        {
         ExtLineBuffer[i]=0.0;
         ExtLineLongMA[i]=0.0;
         ExtLineUpBuffer[i]=0.0;
         
         ExtLineDownBuffer[i]=0.0;
        }
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin; i<limit; i++)
         firstValue+=price[i];
      firstValue/=InpMAPeriod;
      ExtLineBuffer[limit-1]=firstValue;
      ExtLineUpBuffer[limit-1]=firstValue;
      ExtLineLongMA[limit-1] = firstValue;
       ExtLineDownBuffer[limit-1] = firstValue;

     }
   else
      limit=prev_calculated-1;
//--- main loop
   int copy=CopyBuffer(MA_handle,0,0,rates_total,buffer_MA);




   double values_slow_MA [];
   double gap_slow_fast_ma [];
   double values_fast [];
   double max = 0;
   double min = 0;
   for(i=limit; i<rates_total && !IsStopped(); i++)
   {
      max = 0;
      min = 0;
   ArrayFree(values_slow_MA);
   ArrayResize(values_slow_MA,window_backward);
   
   ArrayCopy(values_slow_MA,buffer_MA,0,i-1-window_backward,window_backward);
   ArrayCopy(values_fast,ExtLineBuffer,0,i-1-window_backward,window_backward);
   
   ArrayFree(gap_slow_fast_ma);
   ArrayResize(gap_slow_fast_ma,window_backward);


   ExtLineBuffer[i]=ExtLineBuffer[i-1]+(price[i]-price[i-InpMAPeriod])/InpMAPeriod;
    for (int j = 0 ; j < window_backward ; j++)
   {
   gap_slow_fast_ma[j] = MathAbs(values_slow_MA[j]-values_fast[j]);
   }
      max = gap_slow_fast_ma[ArrayMaximum(gap_slow_fast_ma)];

    ExtLineLongMA[i] = buffer_MA[i];
    
   ExtLineUpBuffer[i] = ExtLineBuffer[i]+max;
   ExtLineDownBuffer[i] = ExtLineBuffer[i]-max;

  }

}
//---

  
//+------------------------------------------------------------------+
//|  exponential moving average                                      |
//+------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int    i,limit;
   double SmoothFactor=2.0/(1.0+InpMAPeriod);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=InpMAPeriod+begin;
      ExtLineBuffer[begin]=price[begin];
      for(i=begin+1; i<limit; i++)
         ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(i=limit; i<rates_total && !IsStopped(); i++)
      ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);

//---
  }
//+------------------------------------------------------------------+
//|  linear weighted moving average                                  |
//+------------------------------------------------------------------+
void CalculateLWMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int        i,limit;
   static int weightsum;
   double     sum;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      weightsum=0;
      limit=InpMAPeriod+begin;
      //--- set empty value for first limit bars
      for(i=0; i<limit; i++)
         ExtLineBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin; i<limit; i++)
        {
         int k=i-begin+1;
         weightsum+=k;
         firstValue+=k*price[i];
        }
      firstValue/=(double)weightsum;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(i=limit; i<rates_total && !IsStopped(); i++)
     {
      sum=0;
      for(int j=0; j<InpMAPeriod; j++)
         sum+=(InpMAPeriod-j)*price[i-j];
      ExtLineBuffer[i]=sum/weightsum;
     }
//---
  }
//+------------------------------------------------------------------+
//|  smoothed moving average                                         |
//+------------------------------------------------------------------+
void CalculateSmoothedMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=InpMAPeriod+begin;
      //--- set empty value for first limit bars
      for(i=0; i<limit-1; i++)
         ExtLineBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin; i<limit; i++)
         firstValue+=price[i];
      firstValue/=InpMAPeriod;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(i=limit; i<rates_total && !IsStopped(); i++)
      ExtLineBuffer[i]=(ExtLineBuffer[i-1]*(InpMAPeriod-1)+price[i])/InpMAPeriod;
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {

   MA_handle=iCustom(NULL,0,"Examples\\Custom Moving Average Input Color_White",
                     IntMALongPeriodBackWard,
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
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpMAPeriod);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,InpMAShift);
   IndicatorSetString(INDICATOR_SHORTNAME,"Fast MA Hysteresis " + IntegerToString(InpMAPeriod) + " ( " + EnumToString(input_to_type(InpMAMethod)) + ")" + "MA LONG" + IntegerToString(IntMALongPeriodBackWard) +  "("  + EnumToString(input_to_type(MALongType)));
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
   if(rates_total<InpMAPeriod-1+begin)
      return(0);// not enough bars for calculation
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
      ArrayInitialize(ExtLineBuffer,0);
//--- sets first bar from what index will be draw
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpMAPeriod-1+begin);

//--- calculation
   switch(InpMAMethod)
     {
      case MODE_EMA:
         CalculateEMA(rates_total,prev_calculated,begin,price);
         break;
      case MODE_LWMA:
         CalculateLWMA(rates_total,prev_calculated,begin,price);
         break;
      case MODE_SMMA:
         CalculateSmoothedMA(rates_total,prev_calculated,begin,price);
         break;
      case MODE_SMA:
         CalculateSimpleMA(rates_total,prev_calculated,begin,price);
         break;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
