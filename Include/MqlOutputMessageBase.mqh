//+------------------------------------------------------------------+
//|                                         MqlOutputMessageBase.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
   #include <Arrays\ArrayObj.mqh>
class MqlOutputMessageBase : public CArrayObj
  {
public :
                     MqlOutputMessageBase(int id,datetime _dt,string _symbol,int _type,int _entry,double _price,double _sl,double _tp);

                     MqlOutputMessageBase(int id,datetime _dt,string _symbol,int _type,int _entry,double _price);
                     string getSymbol();
                     datetime getDT();
                     double getPrice();
                     ENUM_DEAL_TYPE getType();
                     ENUM_DEAL_ENTRY getEntry();
        private:
   datetime dt;
   string            symbol;
   ENUM_DEAL_TYPE type;
   ENUM_DEAL_ENTRY entry;
   double            sl;
   double            tp;
   double            price;
   int               id;
  };
MqlOutputMessageBase::MqlOutputMessageBase(int _id,datetime _dt,string _symbol,int _type,int _entry,double _price) : dt(_dt),symbol(_symbol),type(_type),entry(_entry),price(_price),id(_id)

  {
   if(type == ORDER_TYPE_CLOSE_BY)
      Alert("MqlOutputMessageBase::MqlOutputMessageBase opening again for an already open Position");
  }

MqlOutputMessageBase::MqlOutputMessageBase(int _id,datetime _dt,string _symbol,int _type,int _entry,double _price,double _sl,double _tp) : dt(_dt),symbol(_symbol),price(_price),type(_type),tp(_tp),sl(_sl),id(_id)

  {
   if(type == ORDER_TYPE_CLOSE_BY)
      Alert("MqlOutputMessageBase::MqlOutputMessageBase opening again for an already open Position");
  }
  
 string MqlOutputMessageBase::getSymbol()
 {
 return symbol;
 }
  double MqlOutputMessageBase::getPrice()
  {
  return price;
  }

   ENUM_DEAL_TYPE MqlOutputMessageBase::getType()
   {
   return type;
    }  
  ENUM_DEAL_ENTRY MqlOutputMessageBase::getEntry()
   {
   return entry;
   }
     datetime MqlOutputMessageBase::getDT()
  {
  return dt;
  }
//+------------------------------------------------------------------+
