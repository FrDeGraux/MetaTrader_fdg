//+------------------------------------------------------------------+
//|                                             RectanglePicture.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
class RectanglePicture
{
   public :
      RectanglePicture(datetime time1,double price1,datetime time2,double price2);
      void drawRectangle();
      void deleteRectangle();
     private : 
     datetime x1;
     datetime x2;
     double y1;
     double y2;
     string name;
     int chartID;
};
RectanglePicture::RectanglePicture(datetime time1,double price1,datetime time2,double price2) : chartID(0),x1(time1),x2(time2),y1(price1),y2(price2),name("rectangle")
{
}
void RectanglePicture::drawRectangle()
{

//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,0,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
}
void RectanglePicture::deleteRectangle()
{
//--- reset the error value
   ResetLastError();
//--- delete rectangle
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   ChartRedraw();
   return(true);
}