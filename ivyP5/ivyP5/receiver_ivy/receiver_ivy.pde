/*
 *  demo_ivy-> Demonstration with ivy middleware
 * v. 1.0
 * 
 * (c) Ph. Truillet, April 2014
 * Last Revision: 09/04/2014
 */
 
import fr.dgac.ivy.*;

// data

Ivy bus;
PFont f;
String message= "";

void setup()
{
  size(400,140);
  fill(255);
  f = loadFont("SketchNice-48.vlw");
  textFont(f,24);
  background(0);
  try
  {
    bus = new Ivy("demo", " demo_processing is ready", null);
    bus.start("127.255.255.255:2010");
    
    bus.bindMsg("^Demo_Processing Command=(.*)", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = args[0];
        try
        {
          bus.sendMsg("Demo_Processing Feedback=ok");
        }
        catch (IvyException ie) {}  
      }        
    });
    
  }
  catch (IvyException ie)
  {
  }
}

void draw()
{
    background(0);
    text(message, 20, 80);
}
