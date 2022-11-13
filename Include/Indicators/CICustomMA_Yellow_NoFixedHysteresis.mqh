//+------------------------------------------------------------------+
//|                                         CiCustomMAHysteresis.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "CICustomMA.mqh"
#define INDICATOR_NAME "Custom Moving Average Input Color_Yellow_NoFixedhysteresis"

#define HYSTERESIS_NBUFFERS 5
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CICustomMA_Yellow_NoFixedHysteresis : public CICustomMA
  {
private:
   int               window_backward;
   int               long_ma_period;
   int               method;



public:
                     CICustomMA_Yellow_NoFixedHysteresis(int _window_backward,double _long_ma_period);
                    ~CICustomMA_Yellow_NoFixedHysteresis();
   
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
               const int ma_period,const int ma_shift,
               const ENUM_MA_METHOD ma_method,const int applied,CMqlParams& params);
               
   bool   Initialize(const string symbol, 
                              const ENUM_TIMEFRAMES period, 
                              const int num_params, 
                              const MqlParam &params[]); 
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CICustomMA_Yellow_NoFixedHysteresis::Create(const string symbol,const ENUM_TIMEFRAMES period,
               const int ma_period,const int ma_shift,
               const ENUM_MA_METHOD ma_method,const int applied,CMqlParams& params)
  {
  

   

             if(params.Total() == 0) 
               params.Set(this.ind_Name, TYPE_STRING); // set first pramc with value ind_name
               
            params.Set(window_backward, TYPE_UCHAR);
            params.Set(long_ma_period, TYPE_UCHAR);
                
   if(!CICustomMA::Create(symbol,period,ma_period,ma_shift,ma_method,applied,params))
      return false;
      

     if(!BufferResize(window_backward))
     {
         Print("CICustomMA_Yellow_NoFixedHysteresis Error BufferResizeHysteresis MA");
      return(false);  
     }
//--- ok
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_Yellow_NoFixedHysteresis::CICustomMA_Yellow_NoFixedHysteresis(int _window_backward,double _long_ma_period) :  CICustomMA(INDICATOR_NAME,HYSTERESIS_NBUFFERS)
  {
   window_backward = _window_backward;
   long_ma_period = _long_ma_period;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_Yellow_NoFixedHysteresis::~CICustomMA_Yellow_NoFixedHysteresis()
  {

  }
//+------------------------------------------------------------------+
bool CICustomMA_Yellow_NoFixedHysteresis::Initialize(const string symbol, 
                              const ENUM_TIMEFRAMES period, 
                              const int num_params, 
                              const MqlParam &params[]
) 
{
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(HYSTERESIS_NBUFFERS))
      return false; 
   // #3 Call super.Initialize 
   if (!CICustomMA::Initialize(symbol, period, num_params, params))
      return false;
   return true;
  }