//+------------------------------------------------------------------+
//|                                                       CiRAVI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "CiCustom_Enhanced.mqh"

#define INITIAL_BUFFER_SIZE 2048

//https://stackoverflow.com/questions/52769369/mql5-pass-indicator-as-parameter
#include <MqlParams.mqh>
#include <expstatistics_class.mqh>

enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};
class CICustomMA : public CiCustom_Enhanced
  {

private : 
string ind_Name;                 
public:
                     CICustomMA(string _indName,int nBuffers = 1);
                    ~CICustomMA();
                    int MAPeriod;
                    int nBuffers;  
                    double            Main(const int index) const;
                    double computeVolatility();
                    double computeATR();
                    void setMAPeriod(int);
                    bool Create(const string symbol,const ENUM_TIMEFRAMES period,
               const int ma_period,const int ma_shift,
               const ENUM_MA_METHOD ma_method,const int applied);
                            
                       bool     Initialize(const string symbol, 
                              const ENUM_TIMEFRAMES period, 
                              const int num_params,const int nBuffers, 
                              const MqlParam &params[]);

  }; 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA::CICustomMA(string _indName,int _nBuffers )  : ind_Name(_indName),nBuffers(_nBuffers)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA::~CICustomMA()
  {
  } 
//+----------------------------------------

void CICustomMA::setMAPeriod(int _MAPeriod)
{
   MAPeriod = _MAPeriod;
}

//+------------------------------------------------------------------+
    
double CICustomMA::Main(const int index) const
  {
   CIndicatorBuffer *buffer=At(index);
//--- check
   if(buffer==NULL) 
      return(EMPTY_VALUE);
//---
   return(buffer.At(0));
  }
//+---
bool CICustomMA::Create(const string symbol,const ENUM_TIMEFRAMES period,
               const int ma_period,const int ma_shift,
               const ENUM_MA_METHOD ma_method,const int applied)
{  
CMqlParams params;
   // #1 Setu p the MQL params array for the custom indicator.

  
   
            if(params.Total() == 0) 
               params.Set(this.ind_Name, TYPE_STRING); // set first pramc with value ind_name

         params.Set(ma_period, TYPE_UCHAR);
       
         params.Set(ma_method, TYPE_UCHAR);
 // set extra Hysteresis Parameter for MM
       
       
       
   int handle = -1;
   long nCharts = -1;
   
    if(!ChartGetInteger(0,CHART_WINDOWS_TOTAL,0,nCharts))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
   // #2 Call the parent Create method with the params
   if (!Create(symbol, period, IND_CUSTOM, params.Total(), params.params))
         return false; 
   ChartIndicatorAdd(0,0,handle);
   // #3 Resize the buffer to the desired initial size
    if(!Initialize(symbol,0,params.Total(),nBuffers,params.params))
          return false;
    return true;

}
bool CICustomMA::Initialize(const string symbol, 
                              const ENUM_TIMEFRAMES period, 
                              const int num_params,const int _nBuffers, 
                              const MqlParam &params[]
) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(_nBuffers))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom_Enhanced::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}