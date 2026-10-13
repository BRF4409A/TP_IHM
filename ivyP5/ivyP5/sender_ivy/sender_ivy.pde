/*
 *  sender -> Demonstration with ivy middleware
 * v. 1.0
 * 
 * (c) Ph. Truillet, April 2014
 * Last Revision: 10/04/2014
 */
 
import fr.dgac.ivy.*;

// data

Ivy bus;
PFont f;
String message= "";

void setup()
{
  size(400,140);
  fill(0,255,0);
  f = loadFont("SketchNice-48.vlw");
  textFont(f,18);
  try
  {
    bus = new Ivy("sender", " sender_processing is ready", null);
    bus.start("127.255.255.255:2010");
    
    bus.bindMsg("^Demo_Processing Feedback=ok", new IvyMessageListener()
    {
      public void receive(IvyClient client,String[] args)
      {
        message = "message sent successfully!";       
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

void mousePressed()
{
  try
  {
    bus.sendMsg("Demo_Processing Command=Damn ... New message");
  }
  catch (IvyException ie)
  {
  }
}
