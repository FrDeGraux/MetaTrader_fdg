//+------------------------------------------------------------------+
//|                                                   utilString.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Arrays\ArrayString.mqh>
class utilDateTime
  {
private :
   static long       computeHourAdjustment(ENUM_TIMEFRAMES in_tf);
public :
   static datetime   GetTimeLocal();
   static datetime   timeFrameToDateTime(ENUM_TIMEFRAMES in_tf);
   static datetime   roundToDay(datetime in_dt);
   static datetime   computeUltimateDate(datetime in_dt,ENUM_TIMEFRAMES in_tf);
   static int        getYear(datetime in);

  };
//+------------------------------------------------------------------+
//|                                                               |
//+------------------------------------------------------------------+
int utilDateTime::getYear(datetime in)
{
  MqlDateTime str1;
   TimeToStruct(in,str1);
   return str1.year;
   
}
long utilDateTime::computeHourAdjustment(ENUM_TIMEFRAMES in_tf)
  {
   long res;
   if(timeFrameToDateTime(in_tf) < (2*60*60))
      res = (2*60*60)+timeFrameToDateTime(in_tf);
   else
      res =  timeFrameToDateTime(in_tf);

   return res;
  }
//+------------------------------------------------------------------+
//|    Compute the ultimate day of trade from a final datetime (used for swap)                                                            |
//+------------------------------------------------------------------+
datetime utilDateTime::computeUltimateDate(datetime dt_final_date_input,ENUM_TIMEFRAMES in_tf)
  {
   datetime dt_ultimate_date;


   MqlDateTime mql_end_date;
   TimeToStruct(dt_final_date_input,mql_end_date);

   int week_day = mql_end_date.day_of_week;
   int hour = mql_end_date.hour;
   if(week_day ==  6)
      dt_ultimate_date = utilDateTime::roundToDay(dt_final_date_input)-(computeHourAdjustment(in_tf));
     

   else
   {
      if(week_day == 0)
         dt_ultimate_date = utilDateTime::roundToDay(dt_final_date_input)-(24*60*60)-(computeHourAdjustment(in_tf));
      else
      {
         if(week_day == 1)
            dt_ultimate_date = utilDateTime::roundToDay(dt_final_date_input)-(2*24*60*60)-(computeHourAdjustment(in_tf));  //If final date is Mon, last trade occurs on Fri
         else
            dt_ultimate_date = dt_final_date_input - utilDateTime::timeFrameToDateTime(in_tf);
      }
}
   return dt_ultimate_date;

  }
// Day of week (0-Sunday, 1-Monday, ... ,6-Saturday)
datetime utilDateTime::timeFrameToDateTime(ENUM_TIMEFRAMES in_tf)
  {

   switch(in_tf)

     {
      
      case PERIOD_M1:
         return(60);

      case PERIOD_M5:
         return(60*5);

      case PERIOD_M15:
         return(60*15);

      case PERIOD_M30:
         return(60*30);

      case PERIOD_H1:
         return(60*60);

      case PERIOD_H4:
         return(60*60*4);

      case PERIOD_D1:
         return(60*60*24);

      case PERIOD_W1:
         return(60*60*24*7);

      case PERIOD_MN1:
         return(60*60*24*7*4);

      default:
         return(-1);

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime utilDateTime::roundToDay(datetime in_dt)
  {

   datetime res = ((long)in_dt/86400)*86400;
   return res;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime utilDateTime::GetTimeLocal(void)
  {
   string tmpFileName      = "_TEMP_FILE";
   int handleTmpFile       = FileOpen(tmpFileName, FILE_WRITE);
   if(handleTmpFile==INVALID_HANDLE);
   datetime now            = (datetime)FileGetInteger(handleTmpFile, FILE_CREATE_DATE);


   FileClose(handleTmpFile);
   FileDelete(tmpFileName);
   return now;
  }


//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
