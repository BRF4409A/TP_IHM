import fr.dgac.ivy.*;

// =========================================================
// 1. STRUCTURE DE DONNÉES ET MACHINE À ÉTATS
// =========================================================
class CommandeMultimodale {
  String action = "none";     // CREATE, MOVE, DELETE...
  String forme = "none";      // RECTANGLE, CIRCLE, TRIANGLE...
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
      // FUSION RÉUSSIE POUR CRÉER
      if (action.equals("CREATE") && !forme.equals("none") && x != -1 && y != -1) {
        try {
          // On envoie l'ordre précis à la Palette
          String ordre = "Palette CreerObjet type=" + forme + " x=" + x + " y=" + y + " couleur=" + couleur;
          bus.sendMsg(ordre);
          println(">>> ORDRE ENVOYÉ : " + ordre);
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
    if (etatCourant == ETAT_ATTENTE_INFO) nomEtat = "ATTENTE INFO (Manque forme ou couleur)";
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
    
    // --- A. ÉCOUTE DE LA VOIX (SRA5 Parsé) ---
    bus.bindMsg("^sra5 Parsed=action=([^ ]+) where=([^ ]+) form=([^ ]+) color=([^ ]+) localisation=([^ ]+) Confidence=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String actionVocale = args[0];
        String whereVocale  = args[1]; // Pour le pointage "cette forme"
        String formVocale   = args[2];
        String colorVocale  = args[3];
        String locVocale    = args[4];
        
        println("\n--- VOIX REÇUE ---");
        
        // Remplissage de la structure de données
        if (!actionVocale.equals("undefined") && !actionVocale.equals("none")) cmd.action = actionVocale;
        if (!formVocale.equals("undefined") && !formVocale.equals("none")) cmd.forme = formVocale;
        if (!colorVocale.equals("undefined") && !colorVocale.equals("none")) cmd.couleur = colorVocale;
        
        // Gestion de la position ("ici" ou "là")
        if (!locVocale.equals("undefined") && !locVocale.equals("none")) {
          cmd.positionRequise = true;
          cmd.etatCourant = cmd.ETAT_ATTENTE_CLIC;
        } else if (!actionVocale.equals("undefined") && !actionVocale.equals("none")) {
          cmd.etatCourant = cmd.ETAT_ATTENTE_INFO;
        }
        
        cmd.verifierExecution(); // Tentative de fusion
      }
    });

    // --- B. ÉCOUTE DES REJETS VOCAUX ---
    bus.bindMsg("^sra5 Event=Speech_Rejected(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        println("Rejet SRA5 : Mot hors grammaire ou bafouillage.");
        // Tu peux choisir de réinitialiser la commande en cas de rejet :
        // cmd.reinitialiser();
      }
    });

    // --- C. ÉCOUTE DES GESTES (OneDollarIvy) - Préparation ---
    bus.bindMsg("^OneDollarIvy Recognized=(.*) Confidence=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        String geste = args[0];
        println("\n--- GESTE REÇU : " + geste + " ---");
        
        // Si la voix a dit "Créer ici" mais a oublié de dire "Rectangle", le geste peut compléter !
        if (geste.equalsIgnoreCase("rectangle")) cmd.forme = "RECTANGLE";
        if (geste.equalsIgnoreCase("circle")) cmd.forme = "CIRCLE";
        if (geste.equalsIgnoreCase("triangle")) cmd.forme = "TRIANGLE";
        
        cmd.verifierExecution(); // Tentative de fusion
      }
    });

    // --- D. ÉCOUTE DES CLICS SOURIS (Palette graphique) - Préparation ---
    // (Il faudra ajuster cette ligne en fonction du vrai message envoyé par l'outil Palette)
    bus.bindMsg("^Palette MouseClicked x=(.*) y=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        cmd.x = int(args[0]);
        cmd.y = int(args[1]);
        println("\n--- CLIC REÇU : X=" + cmd.x + " Y=" + cmd.y + " ---");
        
        cmd.verifierExecution(); // Tentative de fusion
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

// Permet de nettoyer l'état manuellement au clavier si besoin
void keyPressed() {
  if (key == 'r' || key == 'R') {
    cmd.reinitialiser();
  }
}
