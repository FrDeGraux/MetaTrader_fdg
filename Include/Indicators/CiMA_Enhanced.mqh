//+------------------------------------------------------------------+
//|                                                CiMA_Enhanced.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Indicator_Enhanced.mqh"

class CiMA_Enhanced : public CIndicator_Enhanced
  {
protected:
   int               m_ma_period;
   int               m_ma_shift;
   ENUM_MA_METHOD    m_ma_method;
   int               m_applied;
   static const int bufferSize;
public:
                     CiMA_Enhanced(void);
                    ~CiMA_Enhanced(void);
   //--- methods of access to protected data
   int               MaPeriod(void)        const { return(m_ma_period); }
   int               MaShift(void)         const { return(m_ma_shift);  }
   ENUM_MA_METHOD    MaMethod(void)        const { return(m_ma_method); }
   int               Applied(void)         const { return(m_applied);   }
   //--- method of creation
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int ma_period,const int ma_shift,
                            const ENUM_MA_METHOD ma_method,const int applied,CMqlParams&);
   //--- methods of access to indicator data
   double            Main(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_MA); }

protected:
   //--- methods of tuning
   virtual bool      Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[]);
   bool Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                      const int ma_period,const int ma_shift,
                      const ENUM_MA_METHOD ma_method,const int applied);
  };
 const int CiMA_Enhanced::bufferSize = 1;
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiMA_Enhanced::CiMA_Enhanced(void) : m_ma_period(-1),
                   m_ma_shift(-1),
                   m_ma_method(WRONG_VALUE),
                   m_applied(-1)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiMA_Enhanced::~CiMA_Enhanced(void)
  {
  }
//+------------------------------------------------------------------+
//| Create indicator "Moving Average"                                |
//+------------------------------------------------------------------+
bool CiMA_Enhanced::Create(const string symbol,const ENUM_TIMEFRAMES period,
                  const int ma_period,const int ma_shift,
                  const ENUM_MA_METHOD ma_method,const int applied,CMqlParams& params)
   //--- methods of access to indicator data)
  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iMA(symbol,period,ma_period,ma_shift,ma_method,applied);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,ma_period,ma_shift,ma_method,applied))
     {
      //--- initialization failed
      IndicatorRelease(m_handle);
      m_handle=INVALID_HANDLE;
      return(false);
     }
     if(!this.BufferResize(bufferSize))
     {
         Print("Error BufferResize Enhanced MA");
      return(false);  
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize the indicator with universal parameters               |
//+------------------------------------------------------------------+
bool CiMA_Enhanced::Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[])
  {
   return(Initialize(symbol,period,(int)params[0].integer_value,(int)params[1].integer_value,
          (ENUM_MA_METHOD)params[2].integer_value,(int)params[3].integer_value));
  }
//+------------------------------------------------------------------+
//| Initialize indicator with the special parameters                 |
//+------------------------------------------------------------------+
bool CiMA_Enhanced::Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                      const int ma_period,const int ma_shift,
                      const ENUM_MA_METHOD ma_method,const int applied)
  {
   if(CreateBuffers(symbol,period,1))
     {
      //--- string of status of drawing
      m_name  ="MA";
      m_status="("+symbol+","+PeriodDescription()+","+
               IntegerToString(ma_period)+","+IntegerToString(ma_shift)+","+
               MethodDescription(ma_method)+","+PriceDescription(applied)+") H="+IntegerToString(m_handle);
      //--- save settings
      m_ma_period=ma_period;
      m_ma_shift =ma_shift;
      m_ma_method=ma_method;
      m_applied  =applied;
      //--- create buffers
      ((CIndicatorBuffer*)At(0)).Name("MAIN_LINE");
      ((CIndicatorBuffer*)At(0)).Offset(ma_shift);
      //--- ok
      return(true);
     }
//--- error
   return(false);
  }
//+------------------------------------------------------------------+
//| Access to buffer of "Moving Average"                             |
//+------------------------------------------------------------------+
double CiMA_Enhanced::Main(const int index) const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }