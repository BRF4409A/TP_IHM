import fr.dgac.ivy.*;

Ivy bus;
String messageBrut = "En attente...";

void setup() {
  size(600, 200);
  
  try {
    bus = new Ivy("MoteurFusion", "Moteur de fusion prêt", null);
    bus.start("127.255.255.255:2010"); 
    
    // ÉCOUTE GLOBALE : On attrape tout ce qui commence par "sra5 "
    bus.bindMsg("^sra5 (.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        messageBrut = args[0];
        println("MESSAGE BRUT REÇU : " + messageBrut);
      }
    });

  } catch (IvyException ie) {
    println("Erreur d'initialisation d'Ivy : " + ie.getMessage());
  }
}

void draw() {
  background(40);
  fill(255);
  textSize(14);
  text("Message exact envoyé par sra5 :", 20, 40);
  
  fill(255, 255, 0);
  text(messageBrut, 20, 80);
}
