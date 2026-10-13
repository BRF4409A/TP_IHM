import java.awt.Point;
import fr.dgac.ivy.*;

ArrayList<Forme> formes;
FSM mae;
int indice_forme_glissee = -1; // Pour le drag and drop
PImage sketch_icon;

Ivy bus;

void setup() {
  size(800, 600);
  surface.setResizable(true);
  surface.setTitle("Palette multimodale");
  
  formes = new ArrayList<Forme>();
  noStroke();
  mae = FSM.INITIAL;
  
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
        else if (typeForme.equals("SQUARE")) nouvelleForme = new Rectangle(p); // Carré traité comme rectangle pour l'instant
        
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
    text("Attente de la fusion multimodale (Voix + Clic)...", 50, 50);
  } else {
    affiche();
  }
}

void affiche() {
  background(255);
  for (int i = 0; i < formes.size(); i++) {
    (formes.get(i)).update();
  }
}

void mousePressed() { 
  Point p = new Point(mouseX, mouseY);
  
  // 1. Envoyer le clic au Moteur de Fusion (au cas où il attend une position pour créer une forme)
  try {
    if (bus != null) {
      bus.sendMsg("Palette MouseClicked x=" + mouseX + " y=" + mouseY);
      println("--- CLIC ENVOYÉ AU BUS : X=" + mouseX + " Y=" + mouseY);
    }
  } catch (IvyException e) {}
  
  // 2. Vérifier si on a cliqué sur une forme existante pour la glisser
  indice_forme_glissee = -1; // On réinitialise à chaque clic
  
  // On parcourt à l'envers pour attraper la forme qui est dessinée au-dessus des autres
  for (int i = formes.size() - 1; i >= 0; i--) { 
    if ((formes.get(i)).isClicked(p)) {
      indice_forme_glissee = i;
      mae = FSM.DEPLACER_FORMES_DESTINATION;
      break; // On a trouvé notre forme, on arrête de chercher
    }
  }
  
  // Si on clique dans le vide (pas sur une forme)
  if (indice_forme_glissee == -1 && mae == FSM.AFFICHER_FORMES) {
    // Optionnel : tu pourrais garder ici la logique de changer la couleur aléatoirement 
    // sur un simple clic, mais le drag and drop prend généralement le dessus.
  }
}

// Fonction appelée en continu tant que la souris bouge avec le clic maintenu enfoncé
void mouseDragged() {
  // Si on a bien attrapé une forme
  if (indice_forme_glissee != -1) {
    // On met à jour ses coordonnées en temps réel avec la position de la souris
    (formes.get(indice_forme_glissee)).setLocation(new Point(mouseX, mouseY));
  }
}

// Fonction appelée quand on relâche le clic de la souris
void mouseReleased() {
  if (indice_forme_glissee != -1) {
    // La forme est lâchée, on réinitialise l'indice et l'état
    indice_forme_glissee = -1;
    mae = FSM.AFFICHER_FORMES;
    println("Forme relâchée !");
  }
}
