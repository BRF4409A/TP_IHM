import java.awt.Point;
import fr.dgac.ivy.*;

ArrayList<Forme> formes;
FSM mae;
int indice_forme;
PImage sketch_icon;

Ivy bus;

void setup() {
  size(800,600);
  surface.setResizable(true);
  surface.setTitle("Palette multimodale");
  
  formes = new ArrayList();
  noStroke();
  mae = FSM.INITIAL;
  indice_forme = -1;
  
  try {
    bus = new Ivy("Palette", "Palette graphique prête", null);
    bus.start("127.255.255.255:2010");

    // ÉCOUTE DES ORDRES DU MOTEUR DE FUSION
    bus.bindMsg("^Palette CreerObjet type=(.*) x=(.*) y=(.*) couleur=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String typeForme = args[0];
        int cx = int(args[1]);
        int cy = int(args[2]);
        String couleurForme = args[3];
        
        println(">>> PALETTE REÇOIT L'ORDRE : " + typeForme + " " + couleurForme + " en " + cx + "," + cy);
        
        Point p = new Point(cx, cy);
        Forme nouvelleForme = null;
        
        if (typeForme.equals("RECTANGLE")) nouvelleForme = new Rectangle(p);
        else if (typeForme.equals("CIRCLE")) nouvelleForme = new Cercle(p);
        else if (typeForme.equals("TRIANGLE")) nouvelleForme = new Triangle(p);
        else if (typeForme.equals("DIAMOND")) nouvelleForme = new Losange(p);
        
        if (nouvelleForme != null) {
          if (couleurForme.equals("RED")) nouvelleForme.setColor(color(255, 0, 0));
          else if (couleurForme.equals("GREEN")) nouvelleForme.setColor(color(0, 255, 0));
          else if (couleurForme.equals("BLUE")) nouvelleForme.setColor(color(0, 0, 255));
          else if (couleurForme.equals("YELLOW")) nouvelleForme.setColor(color(255, 255, 0));
          else if (couleurForme.equals("ORANGE")) nouvelleForme.setColor(color(255, 165, 0));
          else if (couleurForme.equals("PURPLE")) nouvelleForme.setColor(color(128, 0, 128));
          else if (couleurForme.equals("DARK")) nouvelleForme.setColor(color(0, 0, 0));
          
          formes.add(nouvelleForme);
          mae = FSM.AFFICHER_FORMES;
        }
      }
    });
  } catch (IvyException ie) {
    println("Erreur initialisation Ivy Palette : " + ie.getMessage());
  }
}

void draw() {
  if (mae == FSM.INITIAL) {
    background(255);
    fill(0);
    text("Attente de la fusion multimodale (Voix + Clic)...", 50,50);
  } else {
    affiche();
  }
}

void affiche() {
  background(255);
  for (int i=0;i<formes.size();i++) {
    (formes.get(i)).update();
  }
}

void mousePressed() { 
  Point p = new Point(mouseX,mouseY);
  
  try {
    if (bus != null) {
      bus.sendMsg("Palette MouseClicked x=" + mouseX + " y=" + mouseY);
      println("--- CLIC ENVOYÉ : X=" + mouseX + " Y=" + mouseY);
    }
  } catch (IvyException e) {}
  
  switch (mae) {
    case AFFICHER_FORMES:
      for (int i=0;i<formes.size();i++) { 
        if ((formes.get(i)).isClicked(p)) {
          (formes.get(i)).setColor(color(random(0,255),random(0,255),random(0,255)));
        }
      } 
      break;
      
   case DEPLACER_FORMES_SELECTION:
     for (int i=0;i<formes.size();i++) {      
        if ((formes.get(i)).isClicked(p)) {
          indice_forme = i;
          mae = FSM.DEPLACER_FORMES_DESTINATION;
        }         
     }
     if (indice_forme == -1) mae= FSM.AFFICHER_FORMES;
     break;
     
   case DEPLACER_FORMES_DESTINATION:
     if (indice_forme !=-1) {
       (formes.get(indice_forme)).setLocation(new Point(mouseX,mouseY));
     }
     indice_forme=-1;
     mae=FSM.AFFICHER_FORMES;
     break;
     
    default:
      break;
  }
}
