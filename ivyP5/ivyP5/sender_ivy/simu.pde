import fr.dgac.ivy.*;

Ivy bus;

void setup() {
  size(400, 300);
  textSize(18);
  try {
    bus = new Ivy("SimulateurVocal", "Simulateur SRA5 prêt", null);
    bus.start("127.255.255.255:2010");
  } catch (IvyException ie) {
    println("Erreur Ivy : " + ie.getMessage());
  }
}

void draw() {
  background(50);
  
  // Dessin des boutons
  fill(200);
  rect(50, 40, 300, 50, 10);
  rect(50, 120, 300, 50, 10);
  rect(50, 200, 300, 50, 10);
  
  // Textes des boutons (Mots de la grammaire)
  fill(0);
  text("Dire : 'créer rectangle'", 120, 72);
  text("Dire : 'rouge'", 150, 152);
  text("Dire : 'ici'", 165, 232);
}

void mousePressed() {
  try {
    // Vérifier sur quel bouton on a cliqué
    if (mouseX > 50 && mouseX < 350) {
      if (mouseY > 40 && mouseY < 90) {
        bus.sendMsg("sra5 Parsed='créer rectangle' Confidence=0.8 NP=0 Num_A=0");
      } 
      else if (mouseY > 120 && mouseY < 170) {
        bus.sendMsg("sra5 Parsed='rouge' Confidence=0.9 NP=0 Num_A=0");
      } 
      else if (mouseY > 200 && mouseY < 250) {
        bus.sendMsg("sra5 Parsed='ici' Confidence=0.9 NP=0 Num_A=0");
      }
    }
  } catch (IvyException ie) {
    println("Erreur d'envoi");
  }
}
