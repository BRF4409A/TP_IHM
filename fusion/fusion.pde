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
  final int ETAT_ATTENTE_CLIC = 2;             // Pour Créer
  final int ETAT_ATTENTE_SELECTION_MOVE = 3;   // Pour Déplacer
  final int ETAT_ATTENTE_DESTINATION_MOVE = 4; // Pour Déplacer
  final int ETAT_ATTENTE_DELETE = 5;           // Pour Supprimer
  final int ETAT_ATTENTE_COLOR = 6;            // Pour Changer de couleur
  
  void reinitialiser() {
    action = "none";
    forme = "none";
    couleur = "none";
    positionRequise = false;
    x = -1; y = -1;
    etatCourant = ETAT_INIT;
  }
  
  void verifierExecution() {
    // Si on a capté une forme seule sans action explicite, on suppose CREATE
    if (!forme.equals("none") && action.equals("none")) {
      action = "CREATE"; 
    }

    if (!action.equals("none")) {
      
      // 1. CRÉATION
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
      
      // 2. DÉPLACEMENT
      else if (action.equals("MOVE") && etatCourant != ETAT_ATTENTE_SELECTION_MOVE && etatCourant != ETAT_ATTENTE_DESTINATION_MOVE) {
        etatCourant = ETAT_ATTENTE_SELECTION_MOVE;
        try { bus.sendMsg("Palette ModeDeplacement"); } catch (IvyException e) { }
      }
      
      // 3. SUPPRESSION
      else if (action.equals("DELETE") && etatCourant != ETAT_ATTENTE_DELETE) {
        etatCourant = ETAT_ATTENTE_DELETE;
        try { bus.sendMsg("Palette ModeSuppression"); } catch (IvyException e) { }
      }
      
      // 4. CHANGER COULEUR
      else if (action.equals("CHANGE_COLOR") && !couleur.equals("none") && etatCourant != ETAT_ATTENTE_COLOR) {
        etatCourant = ETAT_ATTENTE_COLOR;
        try { bus.sendMsg("Palette ModeCouleur couleur=" + couleur); } catch (IvyException e) { }
      }
    }
  }
  
  void afficherEtat() {
    text("Action : " + action, 40, 100);
    text("Forme : " + forme, 40, 140);
    text("Couleur : " + couleur, 40, 180);
    text("Position : " + (x != -1 ? x + " , " + y : (positionRequise ? "Attente Clic souris..." : "Aleatoire")), 40, 220);
    
    String nomEtat = "INIT (Attente commande)";
    if (etatCourant == ETAT_ATTENTE_INFO) nomEtat = "ATTENTE INFO";
    if (etatCourant == ETAT_ATTENTE_CLIC) nomEtat = "ATTENTE CLIC POUR CRÉER";
    if (etatCourant == ETAT_ATTENTE_SELECTION_MOVE) nomEtat = "ATTENTE SÉLECTION FORME";
    if (etatCourant == ETAT_ATTENTE_DESTINATION_MOVE) nomEtat = "ATTENTE DESTINATION";
    if (etatCourant == ETAT_ATTENTE_DELETE) nomEtat = "ATTENTE CLIC POUR SUPPRIMER";
    if (etatCourant == ETAT_ATTENTE_COLOR) nomEtat = "ATTENTE CLIC POUR COLORIER";
    text("Etat : " + nomEtat, 40, 260);
    
    // TEXTES D'INSTRUCTIONS
    textSize(20);
    if (etatCourant == ETAT_ATTENTE_CLIC && !forme.equals("none")) {
      fill(255, 255, 0); 
      text(">>> CRÉATION : CLIQUE OÙ TU VEUX POSER LA FORME <<<", 40, 310);
      dessinerFormeVibrante();
    }
    else if (etatCourant == ETAT_ATTENTE_SELECTION_MOVE) {
      fill(255, 150, 0); 
      text(">>> DÉPLACEMENT : CLIQUE SUR LA FORME <<<", 40, 310);
    }
    else if (etatCourant == ETAT_ATTENTE_DESTINATION_MOVE) {
      fill(255, 255, 0); 
      text(">>> DÉPLACEMENT : CLIQUE SUR LA NOUVELLE POSITION <<<", 40, 310);
      dessinerFormeVibrante();
    }
    else if (etatCourant == ETAT_ATTENTE_DELETE) {
      fill(255, 50, 50); // Rouge clair
      text(">>> SUPPRESSION : CLIQUE SUR LA FORME À DÉTRUIRE <<<", 40, 310);
    }
    else if (etatCourant == ETAT_ATTENTE_COLOR) {
      fill(50, 255, 255); // Cyan
      text(">>> COULEUR : CLIQUE SUR LA FORME À PEINDRE <<<", 40, 310);
    }
  }

  void dessinerFormeVibrante() {
      pushMatrix();
      translate(325 + random(-4, 4), 410 + random(-4, 4)); 
      
      if (couleur.equals("RED")) fill(255, 0, 0);
      else if (couleur.equals("GREEN")) fill(0, 255, 0);
      else if (couleur.equals("BLUE")) fill(50, 150, 255);
      else if (couleur.equals("YELLOW")) fill(255, 255, 0);
      else if (couleur.equals("ORANGE")) fill(255, 165, 0);
      else if (couleur.equals("PURPLE")) fill(150, 0, 255);
      else if (couleur.equals("DARK")) fill(0);
      else fill(180); 
      
      noStroke();
      rectMode(CENTER);
      if (forme.equals("RECTANGLE")) rect(0, 0, 120, 70);
      else if (forme.equals("SQUARE")) rect(0, 0, 90, 90);
      else if (forme.equals("CIRCLE") || forme.equals("CERCLE")) ellipse(0, 0, 90, 90);
      else if (forme.equals("TRIANGLE")) triangle(-45, 45, 0, -45, 45, 45);
      else if (forme.equals("DIAMOND")) quad(0, -50, 45, 0, 0, 50, -45, 0);
      rectMode(CORNER);
      popMatrix();
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
    bus.bindMsg("^sra5 Parsed=\"?action=([^ ]+) where=([^ ]+) form=([^ ]+) color=([^ ]+) localisation=([^ \"]+)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String actionVocale = args[0];
        String whereVocale  = args[1]; 
        String formVocale   = args[2];
        String colorVocale  = args[3];
        String locVocale    = args[4]; 
        
        println("\n--- VOIX REÇUE (Sémantique) ---");
        println("Action:" + actionVocale + " | Forme:" + formVocale + " | Couleur:" + colorVocale + " | Loc:" + locVocale);
        
        // --- CORRECTION DU BUG : SWITCH DEVIENT CHANGE_COLOR ---
        if (!actionVocale.equals("none")) {
            if (actionVocale.equals("SWITCH")) cmd.action = "CHANGE_COLOR";
            else cmd.action = actionVocale;
        }
        
        if (!formVocale.equals("none")) cmd.forme = formVocale;
        if (!colorVocale.equals("none")) cmd.couleur = colorVocale;
        
        if (locVocale.equals("THERE") || whereVocale.equals("THIS")) {
          cmd.positionRequise = true;
          cmd.etatCourant = cmd.ETAT_ATTENTE_CLIC;
        } 
        else if (cmd.action.equals("CREATE") && !cmd.forme.equals("none")) {
          cmd.x = int(random(100, 700));
          cmd.y = int(random(100, 500));
          cmd.positionRequise = false;
        } 
        else if (!cmd.action.equals("none")) {
          if (!cmd.action.equals("MOVE") && !cmd.action.equals("DELETE") && !cmd.action.equals("CHANGE_COLOR")) {
             cmd.etatCourant = cmd.ETAT_ATTENTE_INFO;
          }
        }
        
        cmd.verifierExecution(); 
      }
    });

    // --- B. ÉCOUTE DES GESTES (OneDollarIvy) ---
    bus.bindMsg("^OneDollarIvy Template=([^ ]+) Confidence=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String geste = args[0];
        println("\n--- GESTE REÇU : " + geste + " ---");
        
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
        
        if (cmd.action.equals("CREATE") && !cmd.positionRequise && cmd.x == -1) {
             cmd.x = int(random(100, 700));
             cmd.y = int(random(100, 500));
             cmd.positionRequise = false;
        }

        cmd.verifierExecution(); 
      }
    });

    // --- C. ÉCOUTE DE LA PALETTE (RETOURS D'ACTIONS) ---
    bus.bindMsg("^Palette FormeSelectionnee type=(.*) couleur=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        cmd.forme = args[0];
        cmd.couleur = args[1];
        cmd.etatCourant = cmd.ETAT_ATTENTE_DESTINATION_MOVE;
      }
    });
    
    bus.bindMsg("^Palette ActionTerminee", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        cmd.reinitialiser();
      }
    });

    // --- D. ÉCOUTE DES CLICS SOURIS ---
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
    try { bus.sendMsg("Palette AnnulerAction"); } catch(Exception e){}
    println("--- AUTOMATE RÉINITIALISÉ ---");
  }
}
