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
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCyan
#property indicator_style1  STYLE_SOLID

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_style2 STYLE_DOT

#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_style3 STYLE_DOT

//--- input parameters
input int   hysteresisParameter = 7;
input int            IntMALongPeriod=21;         // Period
input int            IntMALongPeriod = 13;
input int            InpMAShift=0;           // Shift
input ENUM_MA_METHOD InpMAMethod=MODE_SMA;  // Method

//input color          InpColor=clrYellow;       // Color
///input color          InpColor=clrGreen;
//--- indicator buffers

double               ExtLineBuffer[];
double               ExtLineDownBuffer[];
double               ExtLineUpBuffer[];
double buffer_MA[];
double wedge[];
int MA_handle;

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

         ExtLineDownBuffer[i]=0.0;;
         ExtLineUpBuffer[i]=0.0;;
        }
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin; i<limit; i++)
         firstValue+=price[i];
      firstValue/=InpMAPeriod;
      ExtLineBuffer[limit-1]=firstValue;
      ExtLineDownBuffer[limit-1]=firstValue;
      ExtLineUpBuffer[limit-1]=firstValue;
     }
   else
      limit=prev_calculated-1;
//--- main loop
   int copy=CopyBuffer(MA_handle,0,0,rates_total,buffer_MA);




   double values_to_look [];
   double max = 0;
   double min = 0;
   for(i=limit; i<rates_total && !IsStopped(); i++)
   {
      max = 0;
      min = 0;
   ArrayFree(values_to_look);
   ArrayResize(values_to_look,hysteresisParameter);
   ArrayCopy(values_to_look,buffer_MA,0,i-hysteresisParameter,hysteresisParameter);
   max = values_to_look[ArrayMaximum(values_to_look)];
   min = values_to_look[ArrayMinimum(values_to_look)];
   ExtLineBuffer[i]=ExtLineBuffer[i-1]+(price[i]-price[i-InpMAPeriod])/InpMAPeriod;
// ExtLineUpBuffer[i] = buffer_MA[i];
   ExtLineUpBuffer[i] = max;
   ExtLineDownBuffer[i]= min;

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
//--- indicator buffers mapping
   MA_handle=iCustom(NULL,0,"Examples\\Custom Moving Average Input Color_White",
                     21,
                     0,
                     MODE_SMA,
                     PRICE_CLOSE);
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineDownBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineUpBuffer,INDICATOR_DATA);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpMAPeriod);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,InpMAShift);
//--- color line
//   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpColor);
//--- name for DataWindow
   string short_name="unknown ma";
   switch(InpMAMethod)
     {
      case MODE_EMA :
         short_name="EMA";
         break;
      case MODE_LWMA :
         short_name="LWMA";
         break;
      case MODE_SMA :
         short_name="SMA";
         break;
      case MODE_SMMA :
         short_name="SMMA";
         break;
     }
     IndicatorSetString(INDICATOR_SHORTNAME,"Fast MA (+hysteresis) " + IntegerToString(InpMAPeriod) + " ( " + EnumToString(InpMAMethod) + ")" );
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
