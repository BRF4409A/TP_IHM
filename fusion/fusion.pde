import fr.dgac.ivy.*;

// =========================================================
// 1. STRUCTURE DE DONNÉES ET MACHINE À ÉTATS
// =========================================================
class CommandeMultimodale {
  String action = "none";     
  String forme = "none";      
  String couleur = "none";    
  boolean positionRequise = false;
  int x = -1, y = -1;         
  
  int etatCourant = 0;
  final int ETAT_INIT = 0;
  final int ETAT_ATTENTE_INFO = 1;
  final int ETAT_ATTENTE_CLIC = 2;
  
  void reinitialiser() {
    action = "none";
    forme = "none";
    couleur = "none";
    positionRequise = false;
    x = -1; y = -1;
    etatCourant = ETAT_INIT;
  }
  
  void verifierExecution() {
    if (!action.equals("none")) {
      
      // FUSION RÉUSSIE (Création avec position connue, cliquée ou aléatoire)
      if (action.equals("CREATE") && !forme.equals("none") && x != -1 && y != -1) {
        try {
          String ordre = "Palette CreerObjet type=" + forme + " x=" + x + " y=" + y + " couleur=" + couleur;
          bus.sendMsg(ordre);
          println(">>> ORDRE ENVOYÉ À LA PALETTE : " + ordre);
        } catch (IvyException e) {
          println("Erreur d'envoi Ivy : " + e.getMessage());
        }
        reinitialiser();
      }
    }
  }
  
  void afficherEtat() {
    text("Action : " + action, 40, 100);
    text("Forme : " + forme, 40, 140);
    text("Couleur : " + couleur, 40, 180);
    text("Position : " + (x != -1 ? x + " , " + y : (positionRequise ? "Attente Clic souris..." : "Aleatoire")), 40, 220);
    
    String nomEtat = "INIT (Attente commande)";
    if (etatCourant == ETAT_ATTENTE_INFO) nomEtat = "ATTENTE INFO (Manque forme/couleur)";
    if (etatCourant == ETAT_ATTENTE_CLIC) nomEtat = "ATTENTE CLIC";
    text("Etat : " + nomEtat, 40, 260);
    
    // --- LE GROS MESSAGE ET LA FORME QUI VIBRE ---
    if (etatCourant == ETAT_ATTENTE_CLIC && !forme.equals("none")) {
      fill(255, 255, 0); // Jaune pétant
      textSize(20);
      
      String nomAffiche = forme;
      if (forme.equals("SQUARE")) nomAffiche = "CARRÉ";
      if (forme.equals("RECTANGLE")) nomAffiche = "RECTANGLE";
      if (forme.equals("CIRCLE")) nomAffiche = "CERCLE";
      if (forme.equals("TRIANGLE")) nomAffiche = "TRIANGLE";
      if (forme.equals("DIAMOND")) nomAffiche = "LOSANGE";
      
      text(">>> CLIQUE DANS LA PALETTE OÙ TU VEUX TON " + nomAffiche + " <<<", 40, 310);
      
      // Animation de la vibration
      pushMatrix();
      translate(325 + random(-4, 4), 410 + random(-4, 4)); // Centre en bas + vibration aléatoire
      
      // Application de la bonne couleur
      if (couleur.equals("RED")) fill(255, 0, 0);
      else if (couleur.equals("GREEN")) fill(0, 255, 0);
      else if (couleur.equals("BLUE")) fill(50, 150, 255);
      else if (couleur.equals("YELLOW")) fill(255, 255, 0);
      else if (couleur.equals("ORANGE")) fill(255, 165, 0);
      else if (couleur.equals("PURPLE")) fill(150, 0, 255);
      else if (couleur.equals("DARK")) fill(0);
      else fill(180); // Gris par défaut si pas de couleur
      
      noStroke();
      rectMode(CENTER);
      
      // Dessin du bon aperçu
      if (forme.equals("RECTANGLE")) rect(0, 0, 120, 70);
      else if (forme.equals("SQUARE")) rect(0, 0, 90, 90);
      else if (forme.equals("CIRCLE")) ellipse(0, 0, 90, 90);
      else if (forme.equals("TRIANGLE")) triangle(-45, 45, 0, -45, 45, 45);
      else if (forme.equals("DIAMOND")) quad(0, -50, 45, 0, 0, 50, -45, 0);
      
      rectMode(CORNER);
      popMatrix();
    }
  }
}

// =========================================================
// 2. PROGRAMME PRINCIPAL (MOTEUR DE FUSION)
// =========================================================
Ivy bus;
CommandeMultimodale cmd;

void setup() {
  size(650, 500); 
  cmd = new CommandeMultimodale();
  
  try {
    bus = new Ivy("MoteurFusion", "Moteur prêt", null);
    bus.start("127.255.255.255:2010"); 
    
    // --- A. ÉCOUTE DE LA VOIX (SÉMANTIQUE) ---
    // Cette regex capture : action=... where=... form=... color=... localisation=...
    bus.bindMsg("^sra5 Parsed=\"?action=([^ ]+) where=([^ ]+) form=([^ ]+) color=([^ ]+) localisation=([^ \"]+)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String actionVocale = args[0];
        String whereVocale  = args[1]; // "THIS" ou "none"
        String formVocale   = args[2];
        String colorVocale  = args[3];
        String locVocale    = args[4]; // "THERE" ou "none"
        
        println("\n--- VOIX REÇUE (Sémantique) ---");
        println("Action:" + actionVocale + " | Forme:" + formVocale + " | Couleur:" + colorVocale + " | Loc:" + locVocale);
        
        // Transfert des données sémantiques vers l'automate
        if (!actionVocale.equals("none")) cmd.action = actionVocale;
        if (!formVocale.equals("none")) cmd.forme = formVocale;
        if (!colorVocale.equals("none")) cmd.couleur = colorVocale;
        
        // LA LOGIQUE MAGIQUE ADAPTÉE :
        // Si l'utilisateur a dit "ici", "là", "à cet endroit" (THERE) ou "ce/cette" (THIS)
        if (locVocale.equals("THERE") || whereVocale.equals("THIS")) {
          cmd.positionRequise = true;
          cmd.etatCourant = cmd.ETAT_ATTENTE_CLIC;
        } 
        else if (cmd.action.equals("CREATE") && !cmd.forme.equals("none")) {
          // L'utilisateur n'a PAS dit "ici", on génère aléatoirement !
          cmd.x = int(random(100, 700));
          cmd.y = int(random(100, 500));
          cmd.positionRequise = false;
        } 
        else if (!cmd.action.equals("none")) {
          cmd.etatCourant = cmd.ETAT_ATTENTE_INFO;
        }
        
        cmd.verifierExecution(); 
      }
    });

    // --- B. ÉCOUTE DES GESTES (OneDollarIvy) ---
    bus.bindMsg("^OneDollarIvy Template=([^ ]+) Confidence=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String geste = args[0];
        println("\n--- GESTE REÇU : " + geste + " ---");
        
        // Mapping du nom du modèle tracé vers les formes système
        if (geste.equalsIgnoreCase("rectangle") || geste.equalsIgnoreCase("rect")) {
            cmd.forme = "RECTANGLE";
        } else if (geste.equalsIgnoreCase("circle") || geste.equalsIgnoreCase("cercle")) {
            cmd.forme = "CIRCLE";
        } else if (geste.equalsIgnoreCase("triangle")) {
            cmd.forme = "TRIANGLE";
        } else if (geste.equalsIgnoreCase("diamond") || geste.equalsIgnoreCase("losange")) {
            cmd.forme = "DIAMOND";
        } else if (geste.equalsIgnoreCase("square") || geste.equalsIgnoreCase("carre")) {
            cmd.forme = "SQUARE";
        }
        
        // Logique Magique (Partie Geste) : Si la voix a déjà dit "Créer" sans dire "Ici", 
        // et qu'on vient de tracer la forme, on génère la position aléatoire.
        if (cmd.action.equals("CREATE") && !cmd.positionRequise && cmd.x == -1) {
             cmd.x = int(random(100, 700));
             cmd.y = int(random(100, 500));
             cmd.positionRequise = false;
        }

        cmd.verifierExecution(); // Tentative de fusion
      }
    });

    // --- C. ÉCOUTE DES CLICS SOURIS ---
    bus.bindMsg("^Palette MouseClicked x=(.*) y=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        cmd.x = int(args[0]);
        cmd.y = int(args[1]);
        println("\n--- CLIC REÇU : X=" + cmd.x + " Y=" + cmd.y + " ---");
        
        cmd.verifierExecution(); 
      }
    });

  } catch (IvyException ie) {
    println("Erreur Ivy : " + ie.getMessage());
  }
}

void draw() {
  background(40);
  fill(100, 255, 100);
  textSize(18);
  text("MOTEUR DE FUSION MULTIMODALE", 40, 40);
  
  fill(255);
  textSize(18);
  cmd.afficherEtat();
  
  fill(150);
  textSize(14);
  text("(Appuie sur 'R' pour annuler et réinitialiser l'état)", 40, 480);
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    cmd.reinitialiser();
    println("--- AUTOMATE RÉINITIALISÉ ---");
  }
}
