//+------------------------------------------------------------------+
//|                                                   utilString.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Arrays\ArrayString.mqh>
#define NROWS_SWAP 5217
#define NCOLS_SWAP  4
class UtilReader
  {
private : 
   static int        getRawLastDateTime(CArrayString &objects_in[],datetime dt_in);

public :
   static bool       read_swap_file(CArrayString &objects[]);
   static void       filter_swap_array(CArrayString &objects_in[],CArrayString &objects_out[],string in_symbol);
   static int        getSizeBeforeNULL(CArrayString &objects_in[]);
   static bool       checkIfRange(CArrayString &objects_in[],datetime in_dt);
   static double     getSwapValue(CArrayString &objects_in[],datetime dt_in,bool isSwapLong);
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
void UtilReader::filter_swap_array(CArrayString &objects_in[],CArrayString &objects_out[],string in_symbol)
  {
  int count = 0;
  ArrayResize(objects_out,ArraySize(objects_in));
   for(int i=0 ; i < ArraySize(objects_in) ; i++)
     {
     CArrayString r = objects_in[i];
         if(objects_in[i].At(1) == in_symbol)
         {
          objects_out[count] = r;
          count++;
         }
   
     }
     int j=1;
     return;
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
