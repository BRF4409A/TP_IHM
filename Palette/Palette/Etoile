public class Etoile extends Forme {
  
  int rayonExt;
  int rayonInt;
  
  public Etoile(Point p) {
    super(p);
    this.rayonExt = 40; // Pointe de l'étoile
    this.rayonInt = 15; // Creux de l'étoile
  }
   
  public void update() {
    fill(this.c);
    pushMatrix();
    // L'origine est au centre de l'étoile
    translate((float) this.origin.getX(), (float) this.origin.getY());
    
    beginShape();
    // Une étoile à 5 branches nécessite 10 sommets
    for (int i = 0; i < 10; i++) {
      // -HALF_PI permet à l'étoile de pointer vers le haut
      float angle = i * PI / 5 - HALF_PI; 
      float r = (i % 2 == 0) ? this.rayonExt : this.rayonInt;
      vertex(cos(angle) * r, sin(angle) * r);
    }
    endShape(CLOSE);
    popMatrix();
  }  
  
  boolean isClicked(Point p) {
    // Calcul de la distance entre le clic et le centre de l'étoile
    float distance = dist((float) p.getX(), (float) p.getY(), (float) this.origin.getX(), (float) this.origin.getY());
    
    // Si le clic est dans le rayon de l'étoile, on considère qu'elle est cliquée
    if (distance <= this.rayonExt)
      return true;
    else
      return false;
  }
  
  protected double perimetre() {
    // Distance d'un segment entre une pointe et un creux multipliée par 10
    float x1 = cos(-HALF_PI) * this.rayonExt;
    float y1 = sin(-HALF_PI) * this.rayonExt;
    float x2 = cos(PI/5 - HALF_PI) * this.rayonInt;
    float y2 = sin(PI/5 - HALF_PI) * this.rayonInt;
    return 10 * dist(x1, y1, x2, y2);
  }
  
  protected double aire() {
    // Approximation simple
    return (this.rayonExt * this.rayonInt * 5);
  }
}
