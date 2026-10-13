import java.awt.Point;
import fr.dgac.ivy.*;

ArrayList<Forme> formes;
ArrayList<String> typesFormes;     
ArrayList<String> couleursFormes;  

// Les modes internes de la Palette
final int MODE_INITIAL = 0;
final int MODE_AFFICHER = 1;
final int MODE_DEPLACER_SEL = 2;
final int MODE_DEPLACER_DEST = 3;
final int MODE_SUPPRIMER = 4;
final int MODE_CHANGER_COULEUR = 5;

int mode_palette = MODE_INITIAL;
int indice_forme = -1;         
int indice_forme_glissee = -1; 
String couleur_en_attente = ""; // Pour mémoriser la couleur à appliquer

Ivy bus;

void setup() {
  size(800, 600);
  surface.setResizable(true);
  surface.setTitle("Palette multimodale");
  
  formes = new ArrayList<Forme>();
  typesFormes = new ArrayList<String>();
  couleursFormes = new ArrayList<String>();
  
  noStroke();
  
  try {
    bus = new Ivy("Palette", "Palette prête", null);
    bus.start("127.255.255.255:2010");

    // 1. CRÉER
    bus.bindMsg("^Palette CreerObjet type=(.*) x=(.*) y=(.*) couleur=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String typeForme = args[0];
        int cx = int(args[1]);
        int cy = int(args[2]);
        String couleurForme = args[3];
        
        Point p = new Point(cx, cy);
        Forme nouvelleForme = null;
        
        if (typeForme.equals("RECTANGLE")) nouvelleForme = new Rectangle(p);
        else if (typeForme.equals("CIRCLE")) nouvelleForme = new Cercle(p);
        else if (typeForme.equals("TRIANGLE")) nouvelleForme = new Triangle(p);
        else if (typeForme.equals("DIAMOND")) nouvelleForme = new Losange(p);
        else if (typeForme.equals("SQUARE")) nouvelleForme = new Rectangle(p); 
        
        if (nouvelleForme != null) {
          applyColorToForme(nouvelleForme, couleurForme);
          formes.add(nouvelleForme);
          typesFormes.add(typeForme);
          couleursFormes.add(couleurForme);
          mode_palette = MODE_AFFICHER;
        }
      }
    });
    
    // 2. MODES SPÉCIAUX (Moteur -> Palette)
    bus.bindMsg("^Palette ModeDeplacement", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) { mode_palette = MODE_DEPLACER_SEL; }
    });
    
    bus.bindMsg("^Palette ModeSuppression", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) { mode_palette = MODE_SUPPRIMER; }
    });
    
    bus.bindMsg("^Palette ModeCouleur couleur=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) { 
        couleur_en_attente = args[0];
        mode_palette = MODE_CHANGER_COULEUR; 
      }
    });
    
    bus.bindMsg("^Palette AnnulerAction", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        mode_palette = MODE_AFFICHER;
        indice_forme = -1;
      }
    });

  } catch (IvyException ie) {}
}

void applyColorToForme(Forme f, String c) {
  if (c.equals("RED")) f.setColor(color(255, 0, 0));
  else if (c.equals("GREEN")) f.setColor(color(0, 255, 0));
  else if (c.equals("BLUE")) f.setColor(color(0, 0, 255));
  else if (c.equals("YELLOW")) f.setColor(color(255, 255, 0));
  else if (c.equals("ORANGE")) f.setColor(color(255, 165, 0));
  else if (c.equals("PURPLE")) f.setColor(color(128, 0, 128));
  else if (c.equals("DARK")) f.setColor(color(0, 0, 0));
}

void applyFillFromString(String c) {
  if (c.equals("RED")) fill(255, 0, 0);
  else if (c.equals("GREEN")) fill(0, 255, 0);
  else if (c.equals("BLUE")) fill(0, 0, 255);
  else if (c.equals("YELLOW")) fill(255, 255, 0);
  else if (c.equals("ORANGE")) fill(255, 165, 0);
  else if (c.equals("PURPLE")) fill(128, 0, 128);
  else if (c.equals("DARK")) fill(0);
  else fill(150);
}

void draw() {
  background(255);
  if (mode_palette == MODE_INITIAL) {
    fill(0); textSize(16);
    text("Attente de la fusion multimodale...", 50, 50);
    return;
  }
  
  // Dessin des formes
  for (int i = 0; i < formes.size(); i++) {
    (formes.get(i)).update();
  }
  
  // Textes et indications visuelles en haut
  fill(0);
  textSize(20);
  if (mode_palette == MODE_DEPLACER_SEL) {
    fill(255, 100, 100);
    text("MODE DÉPLACEMENT : Cliquez sur la forme à déplacer", 20, 30);
  } 
  else if (mode_palette == MODE_DEPLACER_DEST) {
    fill(0, 150, 0);
    text("FORME SÉLECTIONNÉE : Cliquez à l'endroit où vous voulez la poser", 20, 30);
    
    // DESSINE L'APERÇU
    if (indice_forme != -1 && indice_forme < typesFormes.size()) {
      pushMatrix();
      translate(100, 90); 
      String t = typesFormes.get(indice_forme);
      String c = couleursFormes.get(indice_forme);
      applyFillFromString(c);
      noStroke(); rectMode(CENTER);
      if (t.equals("RECTANGLE")) rect(0, 0, 60, 35);
      else if (t.equals("SQUARE")) rect(0, 0, 45, 45);
      else if (t.equals("CIRCLE")) ellipse(0, 0, 45, 45);
      else if (t.equals("TRIANGLE")) triangle(-20, 20, 0, -20, 20, 20);
      else if (t.equals("DIAMOND")) quad(0, -25, 20, 0, 0, 25, -20, 0);
      rectMode(CORNER);
      popMatrix();
    }
  }
  else if (mode_palette == MODE_SUPPRIMER) {
    fill(255, 0, 0); // Rouge !
    text("MODE SUPPRESSION : Cliquez sur une forme pour la détruire", 20, 30);
  }
  else if (mode_palette == MODE_CHANGER_COULEUR) {
    fill(0, 150, 255); // Bleu
    text("MODE PEINTURE : Cliquez sur une forme pour la colorier", 20, 30);
  }
}

void mousePressed() { 
  Point p = new Point(mouseX, mouseY);
  
  try { if (bus != null) bus.sendMsg("Palette MouseClicked x=" + mouseX + " y=" + mouseY); } catch (Exception e) {}
  
  // A. VOCAL : Sélection de la forme (Clic 1)
  if (mode_palette == MODE_DEPLACER_SEL) {
    for (int i = formes.size() - 1; i >= 0; i--) { 
      if ((formes.get(i)).isClicked(p)) {
        indice_forme = i;
        mode_palette = MODE_DEPLACER_DEST;
        try { bus.sendMsg("Palette FormeSelectionnee type=" + typesFormes.get(i) + " couleur=" + couleursFormes.get(i)); } catch (Exception e) {}
        return; 
      }
    }
  }
  // B. VOCAL : Dépôt de la forme (Clic 2)
  else if (mode_palette == MODE_DEPLACER_DEST) {
    if (indice_forme != -1) {
      (formes.get(indice_forme)).setLocation(p);
      indice_forme = -1; 
    }
    mode_palette = MODE_AFFICHER; 
    try { bus.sendMsg("Palette ActionTerminee"); } catch (Exception e) {}
  }
  
  // C. VOCAL : Suppression
  else if (mode_palette == MODE_SUPPRIMER) {
    for (int i = formes.size() - 1; i >= 0; i--) { 
      if ((formes.get(i)).isClicked(p)) {
        formes.remove(i);
        typesFormes.remove(i);
        couleursFormes.remove(i);
        mode_palette = MODE_AFFICHER;
        try { bus.sendMsg("Palette ActionTerminee"); } catch (Exception e) {}
        return;
      }
    }
  }
  
  // D. VOCAL : Changer Couleur
  else if (mode_palette == MODE_CHANGER_COULEUR) {
    for (int i = formes.size() - 1; i >= 0; i--) { 
      if ((formes.get(i)).isClicked(p)) {
        applyColorToForme(formes.get(i), couleur_en_attente);
        couleursFormes.set(i, couleur_en_attente); // Met à jour la mémoire
        mode_palette = MODE_AFFICHER;
        try { bus.sendMsg("Palette ActionTerminee"); } catch (Exception e) {}
        return;
      }
    }
  }
  
  // E. MANUEL : Glisser-déposer sans la voix
  else {
    indice_forme_glissee = -1;
    for (int i = formes.size() - 1; i >= 0; i--) { 
      if ((formes.get(i)).isClicked(p)) {
        indice_forme_glissee = i; break;
      }
    }
  }
}

void mouseDragged() {
  if (mode_palette == MODE_AFFICHER && indice_forme_glissee != -1) {
    (formes.get(indice_forme_glissee)).setLocation(new Point(mouseX, mouseY));
  }
}

void mouseReleased() {
  if (indice_forme_glissee != -1) indice_forme_glissee = -1;
}
