class Particle2float {

  PVector velocity;
  float lifespan;
  //  float lifespan = random(2550,4000);
  
  PShape part;
  float partSize;

  PVector gravity = new PVector(0, -0.01);
  
  PVector absoluteLocation = new PVector(0, 0);
  boolean needToWrap = false;
  
  Particle2float() {
    float a = random(TWO_PI);
    float speed = random(0.001, 0.1);
    velocity = new PVector(cos(a), sin(a));
    velocity.mult(speed);
    partSize = random(5, 15); // was 10, 20
    part = createShape();
    part.beginShape(QUAD);
    part.noStroke();
    part.texture(sprite2);
    part.normal(0, 0, 1);
    part.vertex(-partSize/2, -partSize/2, 0, 0);
    part.vertex(+partSize/2, -partSize/2, sprite.width, 0);
    part.vertex(+partSize/2, +partSize/2, sprite.width, sprite.height);
    part.vertex(-partSize/2, +partSize/2, 0, sprite.height);
    part.endShape();

    rebirth();
    lifespan = random(255);
  }

  PShape getShape() {
    return part;
  }

  void rebirth() {
    float a = random(TWO_PI);
    float speed = random(0.001, 0.1);
    velocity = new PVector(cos(a), sin(a));
    velocity.mult(speed);
    lifespan = 255;   
    part.resetMatrix();
    absoluteLocation = new PVector(random(width), random(height));
    part.translate(absoluteLocation.x, absoluteLocation.y);
  }

  boolean isDead() {
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }


  public void update() {
    
    screenWrap();

    float tempBrightness = 255-abs((lifespan*2)-255);
    lifespan = lifespan - 1 - abs(int(sv3d2*(random(10)+10))); // 100 here is factor
  //  lifespan = lifespan - 1 - abs(int(sv3d2*(random(10)+100))); // recent version
    //    lifespan = lifespan - 1;
    velocity.add(mouseD);
    velocity.mult((tempBrightness/510)+.5);
    velocity.mult(random(.5, 1.5)); // make 1 for non-acceleration
    velocity.add(gravity);
    part.setTint(color(255, tempBrightness)); // fade 0 to 255 to 0 over lifespan
    part.translate(velocity.x, velocity.y);
    absoluteLocation.add(velocity);
  //  println(absoluteLocation.x + " " + absoluteLocation.y + " - " + velocity.x + " " + velocity.y);
    
  }
  
  void screenWrap() {
 //   println(absoluteLocation.x + " " + absoluteLocation.y);
    if(absoluteLocation.x > width + 5) {
      absoluteLocation.x = 0 - 1;
      needToWrap = true;
    } else if (absoluteLocation.x < 0 - 5) {
      absoluteLocation.x = width + 1;
      needToWrap = true;
    }
    if (absoluteLocation.y > height + 5) {
      absoluteLocation.y = 0 - 1;
      needToWrap = true;
    } else if (absoluteLocation.y < 0 - 5) {
      absoluteLocation.y = height + 1;
      needToWrap = true;
    }
    
    if (needToWrap)
    {
      part.resetMatrix();
      part.translate(absoluteLocation.x, absoluteLocation.y);
    }
  }
}
