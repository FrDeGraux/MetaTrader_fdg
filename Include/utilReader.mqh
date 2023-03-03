//+------------------------------------------------------------------+
//|                                                   utilString.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Arrays\ArrayString.mqh>
#include "utilDateTime.mqh"
#define NROWS_SWAP 5217
#define NCOLS_SWAP  4


#define NROWS_COM_CALIB = 10
#define NCOLS_COM_CALIB = 3

#define NROWS_FIXED_HYSTERESIS 81
#define NCOLS_FIXED_HYSTERESIS 3
 


class UtilReader
  {
private : 
   static int        getRawLastDateTime(CArrayString &objects_in[],datetime dt_in);

public :
   static bool       read_swap_file(CArrayString &objects[]);
   static bool       read_commissions_calibration(CArrayString &res[]);
   static bool       filter_swap_array(CArrayString &objects_in[],CArrayString &objects_out[],string in_symbol);
   static bool       filter_array_on_column_value(CArrayString &objects_in[],CArrayString &objects_out[],int col_to_filter,string in_value_to_look_after);
   static int        getSizeBeforeNULL(CArrayString &objects_in[]);
   static bool       get_values_from_commissions_calib_array(CArrayString &objects_in[],string in_symbol,double& mu,double& sigma);
   static bool       checkIfRange(CArrayString &objects_in[],datetime in_dt);
      static bool       checkIfRange_Year(CArrayString &objects_in[],datetime in_dt);
   static double     getSwapValue(CArrayString &objects_in[],datetime dt_in,bool isSwapLong);
      static double     getFixedHysteresisValue_InPoints(CArrayString &objects_in[],datetime dt_in);
   static bool read_fixed_hysteresis_file(CArrayString &res[],string sFilePath);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool UtilReader::checkIfRange(CArrayString &objects_in[],datetime in_dt)
{
datetime start_dt = StringToTime(objects_in[0].At(0));
datetime end_dt = StringToTime(objects_in[ArraySize(objects_in)-1].At(0));

if(in_dt < start_dt)
   return false;
if(in_dt > end_dt)
   return false;
return true;
}
bool UtilReader::checkIfRange_Year(CArrayString &objects_in[],datetime in_dt)
{
int start_year = utilDateTime::getYear(StringToTime(objects_in[1].At(0)));
int end_year = utilDateTime::getYear(StringToTime(objects_in[ArraySize(objects_in)-1].At(0)))+1;
int current_year = utilDateTime::getYear(in_dt);
if(current_year < start_year)
   return false;
if(current_year > end_year)
   return false;
return true;
}

double UtilReader::getFixedHysteresisValue_InPoints(CArrayString &objects_in[],datetime dt_in)
{
if(!UtilReader::checkIfRange_Year(objects_in, dt_in))
   Alert(" UtilReader::getFixedHysteresisValue " + objects_in[0].At(1) + " Datetime is not in range");
int index_col = 2;
int raw_next = getRawLastDateTime(objects_in,dt_in);
if (raw_next == 0)
   return objects_in[1].At(index_col);
 if (raw_next == ArraySize(objects_in))
   return objects_in[raw_next-2].At(index_col);
   
 return objects_in[raw_next-2].At(index_col);
}



double UtilReader::getSwapValue(CArrayString &objects_in[],datetime dt_in,bool isSwapLong)
{
if(!UtilReader::checkIfRange(objects_in, dt_in))
   Alert(" UtilReader::getSwapValue " + objects_in[0].At(1) + " Datetime is not in range");
int index_col = 2 + (1-isSwapLong);
int raw_next = getRawLastDateTime(objects_in,dt_in);
if (raw_next == 0)
   return objects_in[0].At(index_col);
 if (raw_next == ArraySize(objects_in))
   return objects_in[raw_next-1].At(index_col);
   

int raw_last = raw_next-1;

long dt_deltas = -(StringToTime(objects_in[raw_last].At(0)) - StringToTime(objects_in[raw_next].At(0)));
long dt_deltas_previous =  -(StringToTime(objects_in[raw_last].At(0)) - dt_in);
long dt_deltas_next = StringToTime(objects_in[raw_next].At(0)) - dt_in;

float dt_deltas_previous_weighted = float(dt_deltas_previous)/dt_deltas;
float dt_deltas_next_weighted =  float(dt_deltas_next)/ dt_deltas;


long part_previous = dt_deltas_previous/dt_deltas;
long part_next = dt_deltas_next/dt_deltas;

double swap_previous =  StringToDouble(objects_in[raw_last].At(index_col));
double swap_next = StringToDouble(objects_in[raw_next].At(index_col));  

return (swap_previous*dt_deltas_next_weighted + swap_next*dt_deltas_previous_weighted);
}
int UtilReader::getSizeBeforeNULL(CArrayString &objects_in[])
{
   for(int i=0 ; i < ArraySize(objects_in) ; i++)
     {
         if(objects_in[i].Total() == 0)
               return i;
     }
return ArraySize(objects_in);
}
int UtilReader::getRawLastDateTime(CArrayString &objects_in[],datetime dt_in)
{
   for (int i=0; i < ArraySize(objects_in) ; i++)
   {
         if(StringToTime(objects_in[i].At(0)) > dt_in )
            return i;
   }
 return ArraySize(objects_in);
}
bool UtilReader::filter_array_on_column_value(CArrayString &objects_in[],CArrayString &objects_out[],int col_to_filter,string in_value_to_look_after)
{
int count = 0;
  ArrayResize(objects_out,ArraySize(objects_in));
   for(int i=0 ; i < ArraySize(objects_in) ; i++)
     {
     CArrayString r = objects_in[i];
         if(objects_in[i].At(col_to_filter) == in_value_to_look_after)
         {
          objects_out[count] = r;
          count++;
         }
   
     }
if (count == 0)
   return false;
 return true;
}
bool UtilReader::filter_swap_array(CArrayString &objects_in[],CArrayString &objects_out[],string in_symbol)
  {

return(UtilReader::filter_array_on_column_value(objects_in,objects_out, 1, in_symbol));
  }
bool UtilReader::get_values_from_commissions_calib_array(CArrayString &objects_in[],string in_symbol,double& mu,double& sigma)
  {
 // array of CArrStr
  CArrayString outs[];
if(!UtilReader::filter_array_on_column_value(objects_in,outs, 0, in_symbol))
   return false;
  CArrayString res = outs[0];
  
mu = StringToDouble(res.At(1));
sigma = StringToDouble(res.At(2));
return true;
  }
bool UtilReader::read_fixed_hysteresis_file(CArrayString &res[],string sFilePath)
{
  string data[NROWS_FIXED_HYSTERESIS][NCOLS_FIXED_HYSTERESIS];
   string separator = ";";
   int m_handle=-1;
   ArrayResize(res,NROWS_FIXED_HYSTERESIS);
   string m_filename=sFilePath;
   m_handle=FileOpen(m_filename,FILE_CSV | FILE_READ| FILE_ANSI|FILE_COMMON,separator);
   if(m_handle<0)
   {
    Print("UtilReader" + " unable to read file : " + sFilePath);
       return false;
   }



   for(int i = 0; i<NROWS_FIXED_HYSTERESIS; i++)
     {
      CArrayString toInsert;

      for(int j=0 ; j < NCOLS_FIXED_HYSTERESIS ; j++)
         toInsert.Add(FileReadString(m_handle,15));
      toInsert.Resize(NCOLS_FIXED_HYSTERESIS);
      res[i] = toInsert;   
     }

   FileClose(m_handle);
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool UtilReader::read_swap_file(CArrayString &res[])
  {

   string data[NROWS_SWAP][NCOLS_SWAP];
   string separator = ";";
   int m_handle=-1;
   ArrayResize(res,NROWS_SWAP);
   string m_filename="Swaps_Processed.csv";
   m_handle=FileOpen(m_filename,FILE_CSV | FILE_READ| FILE_ANSI|FILE_COMMON,separator);
   if(m_handle<0)
   {
    Print("UtilReader" + " unable to read swap files");
       return false;
   }

   for(int i = 0; i<NROWS_SWAP; i++)
     {
      CArrayString toInsert;

      for(int j=0 ; j < NCOLS_SWAP ; j++)
         toInsert.Add(FileReadString(m_handle,10));
      toInsert.Resize(NCOLS_SWAP);
      res[i] = toInsert;   
     }

   FileClose(m_handle);
   return true;
  }
//+------------------------------------------------------------------+

bool UtilReader::read_commissions_calibration(CArrayString &res[])
{


   string data[10][3];

   string separator = ";";
   int m_handle=-1;
   ArrayResize(res,10);
   string m_filename="Commissions_Calibrations.csv";
   m_handle=FileOpen(m_filename,FILE_CSV | FILE_READ| FILE_ANSI|FILE_COMMON,separator);
   if(m_handle<0)
   {
    Print("UtilReader" + " unable to read swap files");
       return false;
   }

   for(int i = 0; i<10; i++)
     {
      CArrayString toInsert;

      for(int j=0 ; j < 3 ; j++)
         toInsert.Add(FileReadString(m_handle,10));
      toInsert.Resize(3);
      res[i] = toInsert;   
     }

   FileClose(m_handle);
   return true;
   
}
