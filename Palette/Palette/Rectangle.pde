public class Rectangle extends Forme {
  
  int largeur;
  int hauteur;
  
  public Rectangle(Point p) {
    super(p);
    this.largeur = 90;
    this.hauteur = 50;
  }
   
  public void update() {
    fill(this.c);
    // On utilise rect() au lieu de square()
    rect((float) this.origin.getX(), (float) this.origin.getY(), this.largeur, this.hauteur);
  }  
  
  boolean isClicked(Point p) {
    int x = (int) p.getX();
    int y = (int) p.getY();
    int x0 = (int) this.origin.getX();
    int y0 = (int) this.origin.getY();
    
    // Vérification avec la largeur et la hauteur
    if ((x > x0) && (x < x0 + this.largeur) && (y > y0) && (y < y0 + this.hauteur))
      return true;
    else  
      return false;
  }
  
  protected double perimetre() {
    return (this.largeur + this.hauteur) * 2;
  }
  
  protected double aire() {
    return (this.largeur * this.hauteur);
  }
}
