import fr.dgac.ivy.*;

Ivy bus;
String conceptReconnu = "En attente de la voix...";

void setup() {
  size(400, 200);
  textSize(20);
  try {
    bus = new Ivy("MoteurFusion", "Moteur prêt", null);
    bus.start("127.255.255.255:2010");
    
    // Abonnement aux messages vocaux simulés
    bus.bindMsg("^sra5 Parsed='(.*)' Confidence=(.*) NP=(.*) Num_A=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        conceptReconnu = args[0]; // On récupère la valeur du premier (.*), c'est-à-dire le Parsed
      }
    });
    
  } catch (IvyException ie) {
    println("Erreur Ivy : " + ie.getMessage());
  }
}

void draw() {
  background(20);
  fill(0, 255, 0);
  text("Concept sémantique reçu :", 20, 60);
  
  fill(255);
  textSize(24);
  text(conceptReconnu, 20, 110);
}
