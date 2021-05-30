/*
 BROWNIE POINTS:
 - Add new button so that turrets can be missiles can be launched <not done>
 - Asteroid Health Bar and increasing health for progessive difficulty <done>
 - Button to add turrets and the progressive price <done> 
 - Game over screen <done>
 
 EXTRA FEATURES:
 - Small asteroids generating when big one is destroyed; deteriorating <done>
 - Explosions (super class) <done>
 - Turret (super class) <done>
 - Health drop to add health to the planet (super class) <done>
 - 500 credits drop to help player (super class) <done>
 
 TO DO:
 - Put in logical time intervals to drop ^those powerups then done. <done>
 */

ArrayList<lasers> laser = new ArrayList<lasers>();
ArrayList<enemies> ast = new ArrayList<enemies>();
ArrayList<smallAst> smolAst = new ArrayList<smallAst>();
ArrayList<stars> Stars = new ArrayList<stars>();
ArrayList<missiles> Missiles = new ArrayList<missiles>();
ArrayList<turret> turrets =  new ArrayList<turret>();
ArrayList<Explosions> exp = new ArrayList<Explosions>();
ArrayList<Health> hp = new ArrayList<Health>();
ArrayList<Credits> cred = new ArrayList<Credits>();

button addTurret;

int badguys = 5, score, score2, levels = 1, coolDown = 300, maxthrust= 10, planetHealth = 100, spacing = 0, credits = 500, AstHealth = 1;
int pwrUp_score, pwrUp_score2; //the first is for health drops and #2 is for credit drops so they drop in logical time intervals 

void setup() {
  size(640, 480);
  for (int i = 0; i < badguys; i++) ast.add(new enemies(random(30, 610), 0, random(-1, 1), random(1)));
  for (int i = 0; i < 30; i++) Stars.add( new stars(random(width), random(0, 450), -random(1, 5)));
  addTurret = new button(500, 10, 125, 50, "ADD TURRET");
}

void draw() {
  background(0);
  levels = score2/50;
  if (pwrUp_score2 >= 3000) {
    cred.add(new Credits(random(width), 0, random(-4, 4), random(0.5)));
    pwrUp_score2 = 0;
  }
  if (pwrUp_score >= 2000) {
    hp.add(new Health(random(width), 0, random(-4, 4), random(0.5)));
    pwrUp_score = 0;
  }
  if (ast.size() == 0) {
    AstHealth = 1 + floor(0.05 * levels);
    badguys = floor(0.2 * levels)+1; //Simple equation for progressive difficulty 
    for (int j = 0; j < badguys; j++) ast.add(new enemies(random(30, 610), 0, random(-1, 1), random(1))); // Respawning
  } 
  for (int i = 0; i < Stars.size(); i ++) Stars.get(i).output();
  for (int i = 0; i < laser.size(); i++) laser.get(i).output();
  for (int i = 0; i < ast.size(); i++) ast.get(i).output();
  for (int i = 0; i < smolAst.size(); i++) smolAst.get(i).output();
  for (int i = 0; i < Missiles.size(); i++) Missiles.get(i).output();
  for (int i = 0; i < turrets.size(); i++) turrets.get(i).output();
  for (int i = 0; i < exp.size(); i++) exp.get(i).output();
  for (int i = 0; i < hp.size(); i++) hp.get(i).output();
  for (int i = 0; i < cred.size(); i++) cred.get(i).output();
  addTurret.output();
  if (planetHealth <= 0)GameOver(); //Reset game when planet is "destroyed" 
  if (coolDown < 300) coolDown ++; //for missile cool down; so that player cannot spam the button, and also for the recharging bar
 
  fill(173, 216, 255); 
  ellipse(width/2, height - 45, 40, 40);  //All user interface display/graphics 
  fill(255); 
  rect(width/2 - 20, height - 50, 40, 40);
  fill(255);
  rect(10, 70, 100, 10);
  fill(255, 0, 0);
  rect(10, 70, coolDown/3, 10);
  textSize(20);
  fill(255);
  text("CREDITS: "+score, 10, 20);
  text("LEVELS: "+levels, 10, 40);
  text("PLANET HEALTH:" +planetHealth, 10, 60);
  textSize(15);
  text("TURRET PRICE: "+credits, 490, 80);
  fill(19, 98, 7);
  rect(0, 460, width, 30);
  fill(101, 67, 33);
  rect(0, 468, width, 20);
}

void mousePressed() {
  if (addTurret.Clicking() == false) laser.add(new lasers(width/2, 480, mouseX, mouseY));
  if (credits <= score) {
    if (addTurret.Clicking()) {
      turrets.add(new turret(10, 450, spacing)); //way turrets are added using the button 
      spacing ++;
      score -= credits;
      credits = 500 + (spacing * 500);
    }
  }
}
void keyPressed() {
  if (coolDown == 300) {
    if (keyCode == UP) {
      Missiles.add(new missiles(width/2, height, 0.01, 0.01)); //missile mechanism so player cannot spam them
      coolDown = 0;
    }
  }
}


class Move {
  float x, y, sx, sy;
  Move(float xc, float yc, float speedX, float speedY) { //base code move class 
    this.x = xc;
    this.y = yc;
    this.sx = speedX;
    this.sy = speedY;
  }
  void move() {
    this.x += this.sx;
    this.y += this.sy;
  }
}

class lasers extends Move {
  lasers enemies;
  lasers(float sx, float sy, float dx, float dy) {
    super(sx, sy, 12 *((dx-sx)/dist(sx, sy, dx, dy)), 12 *((dy-sy)/dist(sx, sy, dx, dy))); //base code laser 
  }
  void output() {
    stroke(255, 0, 0);
    line(this.x, this.y, this.x + (2 *this.sx), this.y + (2* this.sy));
    stroke(0);
    for (int i = 0; i < laser.size(); i++) {
      if (this.x < 0 || this.y < 0)laser.remove(this); //Garbage collector
    }
    this.move();
  }
}

class enemies extends Move {
  int health;
  enemies(float startX, float startY, float speedX, float speedY) { //base code laser 
    super(startX, startY, speedX, speedY);
    this.health = AstHealth;
  }
  void output() {

    if (this.sx == 0) this.sx = random(1); 
    if (this.x + 15 > width) this.sx = -this.sx;
    else if (this.x - 15 < 0) this.sx = -1 * this.sx; //screen bouncing of asteroids 

    if (this.y > 460) {  //health system of the "planet"; if asteroid hits it then lose points
      ast.remove(this);
      planetHealth -= 10;
      score += 5;
      score2 += 5;
      pwrUp_score += 5;
      pwrUp_score2 += 5;
    }
    for (int i = 0; i < laser.size(); i++) {
      if (dist(this.x, this.y, laser.get(i).x, laser.get(i).y) < 30) { //standard collision detection, but involving health
        exp.add(new Explosions(this.x - 5, this.y + 15, 1.0));
        laser.remove(i);
        this.health --;
        score+=5;
        score2+=5;
        pwrUp_score += 5;
        pwrUp_score2 += 5;
      }
    }
    if (this.health <= 0) {
      ast.remove(this);
      for (int j = 0; j < 2; j++) smolAst.add( new smallAst(this.x, this.y, random(-1, 1), random(1))); //garbage collection/"deterioration" of asteroid
    }
    if (this.health < AstHealth) { 
      fill(255);
      rect(this.x - 20, this.y -45, ((AstHealth * 10)/AstHealth) * 5, 5);
      fill(0, 255, 0);  // ^ kind of a stroke of genius LOL: make it so the asteroid health bar is the same length regardless of actual health size
      rect(this.x - 20, this.y - 45, ((this.health * 10)/AstHealth) * 5, 5);
    }

    fill(120);
    ellipse(this.x, this.y, 60, 60); //display 
    this.move();
  }
}

//small asteroid for "deterioration" effect when bigger asteroid is destroyed, two smaller ones will appear
class smallAst extends Move {
  smallAst(float startX, float startY, float speedX, float speedY) { 
    super(startX, startY, speedX, speedY);
  }
  void output() {
    if (this.x + 15 > width) this.sx = -this.sx;
    else if (this.x - 15 < 0) this.sx = -1 * this.sx; //same screen bouncing 

    for (int i = 0; i < laser.size(); i++) {
      if (dist(this.x, this.y, laser.get(i).x, laser.get(i).y) < 15) { //standard hit detection 
        exp.add(new Explosions(this.x, this.y, 1.0));
        laser.remove(i);
        smolAst.remove(this);
        score += 5;
        score2 += 5;
        pwrUp_score += 5;
        pwrUp_score2 += 5;
      }
    }
    if (this.y > 460) {
      smolAst.remove(this); //same planet health deal with smalller, same as big asteroid 
      planetHealth -= 5;
      score += 5;
      pwrUp_score += 5;
      score2 += 5;
      pwrUp_score2 += 5;
    }
    fill(120);
    ellipse(this.x, this.y, 30, 30);//display 
    this.move();
  }
}

class stars extends Move { 
  stars(float startX, float startY, float speedX) { //base code background star business 
    super(startX, startY, speedX, 0);
  }
  void output() {
    if (this.x < 0) this.x = width;
    fill(255);
    ellipse(this.x, this.y, this.sx, this.sx);
    this.move();
  }
}

class missiles extends Move { //base code missile stuff 
  enemies target;
  int fuel = 500;
  missiles(float startX, float startY, float speedX, float speedY) {
    super(startX, startY, speedX, speedY);
    this.target = null;
  }
  void output() { 
    while (this.target == null && ast.size() > 0) this.target = ast.get(floor(random(ast.size()))); //finding target
    if (this.target != null) {
      if (this.x < this.target.x) this.sx += maxthrust; //homing to said target 
      else this.sx -= maxthrust;
      if (this.y > this.target.y) this.sy -= maxthrust;
      else this.sy += maxthrust;
      if (this.x == this.target.x) this.sx = 0;
    }
    if (this.sx > 2) this.sx = maxthrust;  //so it doesnt accelerate too fast
    if (this.sy > 2) this.sy = maxthrust;
    if (this.sx < -2) this.sx = -maxthrust; //so it doesnt accelerate too fast
    if (this.sy < -2) this.sy = -maxthrust;

    this.fuel --;
    if (this.fuel == 0) Missiles.remove(this);

    if (this.target != null) {
      if (dist(this.x, this.y, this.target.x, this.target.y) < 30) { //standard hit detection and garbage collection combined
        exp.add(new Explosions(this.x, this.y, 1.0));
        Missiles.remove(this);
        ast.remove(this.target);
        score += 5;
        score2 += 5;
        pwrUp_score += 5;
        pwrUp_score2 += 5;
      }
    }
    fill(0, 255, 0);
    ellipse(this.x, this.y, 10, 10); //display 
    this.move();
  }
}

class Explosions extends Move { //explosions for when laser hits asteroid 
  Explosions(float xc, float yc, float fade) {
    super(xc, yc, fade, fade);
  }
  void output() {
    if (this.sx > 0.02) this.sx -= 0.02; //the explosion fading 

    fill(255 * this.sx, 69 * this.sx, 0);
    ellipse(this.x, this.y, 50 * this.sx, 50 * this.sx); //orange and yellow circles to make explosions more realistic 
    fill(255 * this.sx, 211 * this.sx, 0);
    ellipse(this.x, this.y, 25*this.sx, 25*this.sx);
    fill(255);

    if (this.sx <= 0.02)exp.remove(this); //very quick garbage collector
  }
}
// By far hardest part of my program to code:
class turret extends Move { //turret that makes it like "monkey ballon tower defense"
  enemies target;
  int laser_coolDown = 10;
  turret(float startX, float startY, int s) { //int s is important for spacing of the turrets when you add a new one
    super(startX, startY, s, 0);
  }
  void output() {
    this.x = 20+(60*this.sx); //spacing mechanism 
    if (ast.size() > 0) { //make sure there are asteroid to pick a target from, otherwise the program is gonna start to panick
      if (this.target == null) this.target = ast.get(floor(random(ast.size())));
    }

    if (this.target != null) {
      if (laser_coolDown == 10) {
        laser.add(new lasers(this.x, this.y, this.target.x, this.target.y)); //fetching laser stuff and cooldown business 
        laser_coolDown = 0;
      }
      if (laser_coolDown < 10) laser_coolDown++;
    }
    if (ast.contains(this.target) == false)this.target = null; //when the asteroid is destroyed then make it move to another target
    fill(120);
    rect(this.x-10, this.y, 40, 40); //display 
  }
}

class Health extends Move { // Simple health powerup 
  Health(float startX, float startY, float speedX, float speedY) { 
    super(startX, startY, speedX, speedY);
  }  
  void output() {
    if (this.x > width) this.x = 0; 
    else if (this.x < 0) this.x =  width; //used screen warping this time 


    for (int  i = 0; i < laser.size(); i++) {
      if (dist(this.x, this.y, laser.get(i).x, laser.get(i).y) < 15) { //standard hit detection 
        laser.remove(i);
        planetHealth += 10; //Adding planet health 
        hp.remove(this);
      }
    }

    fill(255);
    ellipse(this.x, this.y, 30, 30); //display 
    this.move();
  }
}

class Credits extends Move { //Simple credit drop (gives 500 free credits)
  Credits(float startX, float startY, float speedX, float speedy) { //same business as health drop basically 
    super(startX, startY, speedX, speedy);
  }
  void output() {
    if (this.x > width) this.x = 0;
    else if (this.x < 0) this.x = width;

    for (int i = 0; i < laser.size(); i++) {
      if (dist(this.x, this.y, laser.get(i).x, laser.get(i).y) < 15) {
        laser.remove(i);
        cred.remove(this);
        score += 500;
      }
    }

    fill(0,0,255);
    ellipse(this.x, this.y, 30, 30);
    this.move();
  }
}


class button { //base code for button, nothing special 
  int x, y, w, h, colour;
  String title;
  boolean hover;
  button(int xc, int yc, int wid, int heig, String t) {
    this.x = xc;
    this.y = yc;
    this.w = wid;
    this.h= heig;
    this.title = t;
    this.colour = 150;
    this.hover = false;
  }
  void output() {

    if (mouseX > this.x && mouseX < this.x + this.w && mouseY > this.y && mouseY < this.y + this.h) {
      this.hover = true;
      if (this.hover == true) this.colour = 200;
    } else this.hover = false;
    if (this.hover == false) this.colour = 150;

    fill(this.colour);
    stroke(255);
    rect(this.x, this.y, this.w, this.h, 10);
    fill(0);
    textSize(10);
    text(this.title, this.x + this.w/2 - textWidth(this.title)/2, this.y + this.h/2 + 5);
    stroke(0);
  }
  boolean Clicking() {
    boolean result;
    if (mouseX > this.x && mouseX < this.x + this.w && mouseY > this.y && mouseY < this.y + this.h) result = true;
    else result = false;
    return result;
  }
}

void GameOver() { //reseting game function when planetHealth < 0, so basically the planet is destroyed LOL
  score = 0;
  score2 = 0;
  spacing = 0;
  badguys = 5;
  levels = 1;
  credits = 500;
  planetHealth = 100;
  pwrUp_score = 0;
  pwrUp_score2 = 0;
  AstHealth = 1;
  ast.clear();
  hp.clear();
  cred.clear();
  smolAst.clear();
  laser.clear();
  turrets.clear();
  exp.clear();
  for (int i = 0; i < badguys; i++) ast.add(new enemies(random(30, 610), 0, random(-1, 1), random(1)));
}
