import fr.dgac.ivy.*;

// =========================================================
// 1. STRUCTURE DE DONNÉES ET MACHINE À ÉTATS
// =========================================================
class CommandeMultimodale {
  String action = "none";     // CREATE, MOVE, DELETE...
  String forme = "none";      // RECTANGLE, CIRCLE, TRIANGLE, SQUARE...
  String couleur = "none";    // RED, BLUE, GREEN...
  boolean positionRequise = false;
  int x = -1, y = -1;         // Coordonnées du clic
  
  // États de l'automate
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
  
  // Méthode appelée à chaque nouveau message pour voir si on peut exécuter l'action
  void verifierExecution() {
    if (!action.equals("none")) {
      // FUSION RÉUSSIE POUR CRÉER (on tolère que la couleur soit optionnelle ou absente)
      if (action.equals("CREATE") && !forme.equals("none") && x != -1 && y != -1) {
        try {
          // On envoie l'ordre précis à la Palette
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
    text("Position : " + (x != -1 ? x + " , " + y : (positionRequise ? "Attente Clic souris..." : "none")), 40, 220);
    
    String nomEtat = "INIT (Attente commande)";
    if (etatCourant == ETAT_ATTENTE_INFO) nomEtat = "ATTENTE INFO (Manque forme/couleur ou clic)";
    if (etatCourant == ETAT_ATTENTE_CLIC) nomEtat = "ATTENTE CLIC (Manque position)";
    text("Etat : " + nomEtat, 40, 260);
  }
}

// =========================================================
// 2. PROGRAMME PRINCIPAL (MOTEUR DE FUSION)
// =========================================================
Ivy bus;
CommandeMultimodale cmd;

void setup() {
  size(500, 350);
  cmd = new CommandeMultimodale();
  
  try {
    bus = new Ivy("MoteurFusion", "Moteur prêt", null);
    bus.start("127.255.255.255:2010"); 
    
    // --- A. ÉCOUTE DE LA VOIX (Le nouveau format SRA5 !) ---
    bus.bindMsg("^sra5 Text=(.*) Confidence=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String phrase = args[0].toLowerCase().trim();
        
        println("\n--- VOIX REÇUE : " + phrase + " ---");
        
        // 1. Détection de l'action
        if (phrase.contains("créer") || phrase.contains("dessiner") || phrase.contains("tracer")) cmd.action = "CREATE";
        if (phrase.contains("supprimer") || phrase.contains("effacer")) cmd.action = "DELETE";
        if (phrase.contains("déplacer") || phrase.contains("bouger")) cmd.action = "MOVE";
        
        // 2. Détection de la forme
        if (phrase.contains("rectangle")) cmd.forme = "RECTANGLE";
        if (phrase.contains("cercle")) cmd.forme = "CIRCLE";
        if (phrase.contains("triangle")) cmd.forme = "TRIANGLE";
        if (phrase.contains("losange")) cmd.forme = "DIAMOND";
        if (phrase.contains("carré") || phrase.contains("carre")) cmd.forme = "SQUARE";
        
        // 3. Détection de la couleur
        if (phrase.contains("rouge")) cmd.couleur = "RED";
        if (phrase.contains("vert")) cmd.couleur = "GREEN";
        if (phrase.contains("bleu")) cmd.couleur = "BLUE";
        if (phrase.contains("jaune")) cmd.couleur = "YELLOW";
        if (phrase.contains("noir")) cmd.couleur = "DARK";
        if (phrase.contains("orange")) cmd.couleur = "ORANGE";
        if (phrase.contains("violet")) cmd.couleur = "PURPLE";
        
        // 4. Gestion de la position demandée à la voix ("ici" ou "là")
        if (phrase.contains("ici") || phrase.contains("là") || phrase.contains("endroit")) {
          cmd.positionRequise = true;
          cmd.etatCourant = cmd.ETAT_ATTENTE_CLIC;
        } else if (!cmd.action.equals("none")) {
          cmd.etatCourant = cmd.ETAT_ATTENTE_INFO;
        }
        
        cmd.verifierExecution(); // Tentative de fusion
      }
    });

    // --- B. ÉCOUTE DES REJETS VOCAUX ---
    bus.bindMsg("^sra5 Event=Speech_Rejected(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        println("Rejet SRA5 : Mot hors grammaire ou bafouillage.");
      }
    });

    // --- C. ÉCOUTE DES GESTES (OneDollarIvy) ---
    bus.bindMsg("^OneDollarIvy Recognized=(.*) Confidence=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String geste = args[0];
        println("\n--- GESTE REÇU : " + geste + " ---");
        
        if (geste.equalsIgnoreCase("rectangle")) cmd.forme = "RECTANGLE";
        if (geste.equalsIgnoreCase("circle")) cmd.forme = "CIRCLE";
        if (geste.equalsIgnoreCase("triangle")) cmd.forme = "TRIANGLE";
        
        cmd.verifierExecution();
      }
    });

    // --- D. ÉCOUTE DES CLICS SOURIS (Palette graphique) ---
    bus.bindMsg("^Palette MouseClicked x=(.*) y=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        cmd.x = int(args[0]);
        cmd.y = int(args[1]);
        println("\n--- CLIC REÇU : X=" + cmd.x + " Y=" + cmd.y + " ---");
        
        cmd.verifierExecution(); // On tente la fusion finale après le clic
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
  text("(Appuie sur 'R' pour réinitialiser l'état)", 40, 320);
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    cmd.reinitialiser();
    println("--- AUTOMATE RÉINITIALISÉ ---");
  }
}
