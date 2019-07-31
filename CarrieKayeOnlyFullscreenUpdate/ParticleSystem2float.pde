class ParticleSystem2float {
  ArrayList<Particle2float> particles2float;

  PShape particleShape;

  ParticleSystem2float(int n) {
    particles2float = new ArrayList<Particle2float>();
    particleShape = createShape(PShape.GROUP);

    for (int i = 0; i < n; i++) {
      Particle2float p = new Particle2float();
      particles2float.add(p);
      particleShape.addChild(p.getShape());
    }
  }

  void update() {
    for (Particle2float p : particles2float) {
      p.update();
      if (p.isDead()) {
        p.rebirth();
      }
    }
  }

  void display() {
 //   kayeParticlesGraphics.shape(particleShape);
    shape(particleShape);
  }
}
