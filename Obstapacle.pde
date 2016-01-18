//imports
import java.util.*;
import java.io.*;
import javax.swing.*;
//variables for pacmans position
int ballPositionX;
int ballPositionY;
//variables for pacmans speed
float ballYThing = 1;
float ballXThing = 1;
//variable used for pacmans mouth
float arco = 0;
//variable for your score
int score = 0;
//variables for pacmans position
int xGhost = 0;
int yGhost = 0;
//variables for the maximum number of objects and the current number of objects
int maxOB = 3000;
int countObjects = 0;
//variable for the ghosts speed
int ghostSpeed = 5;
//more variables for pacmans mouth
boolean thing = false;
float arcB = 2*PI - PI/4;
float arcA = PI/4;
//arrays for the positions of the objects
int[] xPos1Object = new int[maxOB];
int[] yPos1Object = new int[maxOB];
int[] xPos2Object = new int[maxOB];
int[] yPos2Object = new int[maxOB];
//variable for the data file
//VERY IMPORTANT
//VERY IMPORTANT
//VERY IMPORTANT
//Mr. Shaefer change this so that the data file is correct for your computer as relative filepaths are wonky in processing
String data; 
//Variables for various key presses
boolean pressedKeyUp = false, pressedKeyDown = false, pressedKeyLeft = false, pressedKeyRight = false, pressedKeySpace = false;
//variables for various timers (explained later)
int t = 0;
int m = 0;
int c = 0;
int d = 0;
int p = 0;
//randomizer for the entire game
Random r = new Random();
//variables for the position of the food and red pellet
int xFood;
int yFood;
int xRed = -30;
int yRed = -30;
//variable for the next time that the red pellet will spawn (between 20 and 30 seconds)
int limitRed = r.nextInt(11) + 20;
//variables for active menus (the 'menu' variable is inversed in this program)
boolean menu = false, menu1 = false, menu2 = false, menu3 = false, gameOver = false;
//audio player (Creative effort)
import ddf.minim.*;
AudioPlayer player;
Minim minim;//audio context

void setup() {//upon startup of the game
  data = dataPath("") + "\\HighScores.txt";
  //starts playing music
  minim = new Minim(this);
  player = minim.loadFile("Pokemon GS Remix- Game Corner.mp3", 2048);
  player.play();
  //sets the size of the game
  size(1000, 600);
  //sets the initial position of pacman
  ballPositionX = 500;
  ballPositionY = 300;
  //sets the initial position of the food
  yFood = r.nextInt(590) + 5;
  xFood = r.nextInt(995) + 5;
  smooth();//makes the program look nice
}

void draw() {//refreshes 60 times a second

  if (!menu) {//main menu
    //Draws in the background(acts as a refresh)
    background(#000000);
    //draws the menu
    fill(#FFC60A);
    textSize(64);
    text("OBSTAPACLE", 320, 100);
    textSize(64);
    fill(#FC920F);
    text("OBSTAPACLE", 326, 100);
    textSize(32);
    fill(#F71105);
    text("Press 1 to Read the Instructions", 280, 200);
    text("Press 2 to See HighScores", 340, 300);
    text("Press 3 to Play the Arcade Version", 270, 400);
    text("Press 4 to Quit", 410, 500);
  }
  else {
    if (menu1 == true) {//instruction menu (if 1 is pressed) Creative effort
      //shows the instructions
      JOptionPane.showMessageDialog(null, "Welcome to Obsatapacle!\n\nObjective:\nThe objective of the game is to collect as many green food pellets (these respawn every 15 seconds) as possible and to avoid the ghost that is chasing you.\n" +
        "The screen is slowely filled with blue rectangles that you cannot pass through which makes the game more challenging as you progress.\nEventually, the blue rectangles will completely obstruct your path forcing a game over.\n" +
        "To hold off the inevitable, collect red pellets (these spawn randomly and will despawn) which will remove 15 blocks that are on the screen.\n\nControls:\nW - Up\nA - Left\nS - Down\nD - Right");
      //switches off this menu to go back to the main menu
      menu1 = false;
      menu = false;
    }
    else if (menu2 == true) {//displays highscore (Creative effort)
      try {
        //reads in the file
        FileReader fr = new FileReader(data);
        BufferedReader br = new BufferedReader(fr);
        //variables for storing the lines and highscore chart
        String input = "", line = "", output = "";
        boolean eof = false;
        int n = 0;//length of the scores list
        //checks how long the scores list is
        while (eof == false) {
          line = br.readLine();
          if (line == null) {
            eof = true;
          }
          else {
            n+= 1;
          }
        }
        //closes the file
        br.close();
        fr.close();
        //reads the file again
        FileReader fr2 = new FileReader(data);
        BufferedReader br2 = new BufferedReader(fr2);
        int[] highScores = new int[n];//variable for the entire scores list
        for (int x = 0; x < n; x ++) {//reads in all the highscores
          highScores[x] = Integer.parseInt(br2.readLine());
        }
        //sorts them in order
        Arrays.sort(highScores);
        output = "HighScores\n";//header
        int p = 1;//for displaying the correct number of the highscore order
        if (n <= 10) {//if the highscores list is less than 10, display all the scores
          for (int x = n - 1; x >= 0; x --) {
            output += (p) + ". " + highScores[x] + "\n";//makes the highscores list
            p+= 1;
          }
        } 
        else {//if the high scores list is greater than 10, only display the top 10
          
          for (int x = n - 1; x >= n - 10; x --) {
            output += (p) + ". " + highScores[x] + "\n";
            p+= 1;
          }
        }
        JOptionPane.showMessageDialog(null, output);//display the high scores
        //back to main menu
        menu3 = false;
        menu = false;
      }
      catch(IOException e) {//displays an error message if the file can't be found
        System.out.println("System: Lol I can't find the file 0_o");
      }
    }
    else if (menu3 == true) {//actual game
      //Draws in the background(acts as a refresh)
      background(#000000);
      //timers increase
      t+= 1;//timer for food
      m+= 1;//timer for ghosts eyes
      c+= 1;//timer for object spawn
      p+= 1;//timer for red pellet spawn
      //spawns food ever 15 seconds
      if (t >= (15*60)) {
        createFood();
      }
      //spawns red pellet every 20 to 30 seconds
      if (p >= (limitRed * 60)) {
        createRed();
      }
      //makes an obstacle
      if (c >= (60) && countObjects < maxOB) {//once every second
        createObject();
        c = 0;
      }
      //Draws the food
      fill(#56EA1C);
      ellipse(xFood, yFood, 7, 7);
      //Draws the red pellets
      fill(#FA0303);
      ellipse(xRed, yRed, 7, 7);
      //Draws all of the objects
      fill(#5792DE);
      stroke(#5792DE);
      for (int x = 0; x < maxOB; x ++) {
        rect(xPos1Object[x], yPos1Object[x], xPos2Object[x], yPos2Object[x]);
      }
      movePacman();//moves pacman and checks collision
      checkDeath();//checks if the ghost is on pacman and displays a death screen and saves your score if it is

      //if pacman eats the food
      if (Math.abs(ballPositionX - xFood) < 20) {
        if (Math.abs(ballPositionY - yFood) < 20) {
          createFood();
          score += 1;
        }
      }
      //if pacman eats the red pellet
      if (Math.abs(ballPositionX - xRed) < 20) {
        if (Math.abs(ballPositionY - yRed) < 20) {
          p = 0;//reset timer
          //gets rid of the red pellet
          xRed = -30;
          yRed = -30;
          //what all of this does is removes 15 random objects that are on the screen. if an object is not on the screen, it tries another one.
          int numObject;
          boolean killObject = false;
          for (int x = 0; x < 15; x++) {
            while (!killObject) {
              numObject = r.nextInt(countObjects);
              if (xPos1Object[numObject] != 0) {
                xPos1Object[numObject] = 0;
                xPos2Object[numObject] = 0;
                yPos1Object[numObject] = 0;
                yPos2Object[numObject] = 0;
                killObject = true;
              }
            }
            killObject = false;
          }
        }
      }

      animatePacman();//animates Pacman
      drawGhost();//Draws and moves the ghost
      //display score
      fill(#B40F30);
      textSize(12);
      text("Score: " + score, 10, 550);
    }//end of actual game drawing
    else if (gameOver) {//when you die
      //Draws in the background(acts as a refresh)
      background(#000000);
      d+= 1;
      if (d >= (60 * 5)) {//after 5 seconds
        score = 0;//reset score
        gameOver = false;
        menu = false;
        d = 0;
        //reset objects and pacman
        countObjects = 0;
        for (int x = 0; x < maxOB; x ++) {
          xPos1Object[x] = 0;
          yPos1Object[x] = 0;
          xPos2Object[x] = 0;
          yPos2Object[x] = 0;
        }
        ballPositionX = 500;
        ballPositionY = 300;
        //reset timers, positions of the pellets and the position of the ghost
        t= 0;
        m= 0;
        c= 0;
        p= 0;
        xRed = -30;
        yRed = -30;
        createFood();
        xGhost = 0;
        yGhost = 0;
      }


      //display game over screen
      textSize(90);
      fill(#F71105);
      text("GAME OVER", 290, 250);
      textSize(32);
      fill(#F71105);
      text("Your Score was: " + score, 400, 350);
    }
  }
}
public void checkDeath() {
  //if the ghost is on pacman, you die
  if (Math.abs(ballPositionX - (502 + xGhost)) < 25) {
    if (Math.abs(ballPositionY - (485 + yGhost)) < 25) {
      ballPositionX = r.nextInt(995) + 5;
      ballPositionY = r.nextInt(500) + 5;

      try {          
        //most of the same code as before for file reading
        FileReader fr = new FileReader(data);
        BufferedReader br = new BufferedReader(fr);
        String input = "", line = "", output = "";
        boolean eof = false;
        int n = 0;
        while (eof == false) {
          line = br.readLine();
          if (line == null) {
            eof = true;
          }
          else {
            n+= 1;
          }
        }
        br.close();
        fr.close();
        FileReader fr2 = new FileReader(data);
        BufferedReader br2 = new BufferedReader(fr2);
        int[] highScores = new int[n + 1];
        for (int x = 0; x < n; x ++) {
          highScores[x] = Integer.parseInt(br2.readLine());
        }
        highScores[n] = score;//stores the new score in the highscores array
        Arrays.sort(highScores);
        for (int x = n; x >= 0; x --) {
          output = output + highScores[x] + "\n";
        }
        //tries to write to the file
        FileWriter fw = new FileWriter(data);
        BufferedWriter bw = new BufferedWriter(fw);
        //writes every single highscore to the file
        for (int x = 0; x < n + 1; x ++) {
          bw.write(highScores[x] + "");
          bw.newLine();
        }
        bw.close();
        fw.close();
        //closes the file writer
      }
      catch(IOException e) {
        System.out.println("System: Lol I can't find the file 0_o");
      }
      //goes to the game over menu
      gameOver = true;
      menu1 = false;
      menu2 = false;
      menu3 = false;
    }
  }
}
public void movePacman() {//moves pacman based on collision
  //if pacman is not colliding with anything when trying to move up, pacman moves up
  if (pressedKeyUp && !upCollision()) {//if the w key is being pressed
    ballYThing = -5;//pacmans speed is set
    ballPositionY += ballYThing;//pacman moves the distance of the speed
    //pacman changes directions
    arco = -PI/2;
  } 
  //similarly for all the other directions
  else if (pressedKeyDown && !downCollision() ) {
    ballYThing = 5;
    ballPositionY += ballYThing;
    arco = PI/2;
  } 
  else if (pressedKeyLeft && !leftCollision()) {
    ballXThing = -5;
    ballPositionX += ballXThing;
    arco = PI;
  } 
  else if (pressedKeyRight && !rightCollision()) {
    ballXThing = 5;
    ballPositionX += ballXThing;
    arco = 0;
  }
}
public void animatePacman() {
  //all of this moves pacman's jaw up and down
  fill(#E9FA03);
  stroke(#000000);
  arc(ballPositionX, ballPositionY, 25, 25, arcA + arco, arcB + arco);//draws pacman
  if (arcA <= 0) {
    thing = true;
  } 
  else if (arcA >= PI/4) {
    thing = false;
  }
  if (thing == true) {
    arcA += 0.05;
    arcB -= 0.05;
  } 
  else {
    arcA -= 0.05;
    arcB += 0.05;
  }
}
public void drawGhost() {
  //Ghost Follows Pacman based on his postion
  if (yGhost + 485 < ballPositionY) {
    yGhost += 1;
  } 
  else if (yGhost + 485 > ballPositionY) {
    yGhost -= 1;
  }
  if (xGhost + 502 < ballPositionX) {
    xGhost += 1;
  } 
  else if (xGhost + 502 > ballPositionX) {
    xGhost -= 1;
  }
  //draws the ghost's body
  fill(#F70505);
  beginShape();
  vertex(500 + xGhost, 500 + yGhost);
  vertex(504 + xGhost, 500 + yGhost);
  vertex(504 + xGhost, 498 + yGhost);
  vertex(506 + xGhost, 498 + yGhost);
  vertex(506 + xGhost, 496 + yGhost);
  vertex(508 + xGhost, 496 + yGhost);
  vertex(508 + xGhost, 498 + yGhost);
  vertex(510 + xGhost, 498 + yGhost);
  vertex(510 + xGhost, 500 + yGhost);
  vertex(514 + xGhost, 500 + yGhost);
  vertex(514 + xGhost, 498 + yGhost);
  vertex(516 + xGhost, 498 + yGhost);
  vertex(516 + xGhost, 482 + yGhost);
  vertex(514 + xGhost, 482 + yGhost);
  vertex(514 + xGhost, 476 + yGhost);
  vertex(512 + xGhost, 476 + yGhost);
  vertex(512 + xGhost, 474 + yGhost);
  vertex(510 + xGhost, 474 + yGhost);
  vertex(510 + xGhost, 472 + yGhost);
  vertex(506 + xGhost, 472 + yGhost);
  vertex(506 + xGhost, 470 + yGhost);
  vertex(498 + xGhost, 470 + yGhost);
  vertex(498 + xGhost, 472 + yGhost);
  vertex(494 + xGhost, 472 + yGhost);
  vertex(494 + xGhost, 474 + yGhost);
  vertex(492 + xGhost, 474 + yGhost);
  vertex(492 + xGhost, 476 + yGhost);
  vertex(490 + xGhost, 476 + yGhost);
  vertex(490 + xGhost, 482 + yGhost);
  vertex(488 + xGhost, 482 + yGhost);
  vertex(488 + xGhost, 498 + yGhost);
  vertex(490 + xGhost, 498 + yGhost);
  vertex(490 + xGhost, 500 + yGhost);
  vertex(494 + xGhost, 500 + yGhost);
  vertex(494 + xGhost, 498 + yGhost);
  vertex(496 + xGhost, 498 + yGhost);
  vertex(496 + xGhost, 496 + yGhost);
  vertex(498 + xGhost, 496 + yGhost);
  vertex(498 + xGhost, 498 + yGhost);
  vertex(500 + xGhost, 498 + yGhost);
  vertex(500 + xGhost, 500 + yGhost);
  endShape();
  if (m <= 60) {
    //draws the ghost's eyes
    fill(#FFFFFF);
    stroke(#FFFFFF);
    beginShape();
    vertex(500 + xGhost, 480 + yGhost);
    vertex(500 + xGhost, 482 + yGhost);
    vertex(498 + xGhost, 482 + yGhost);
    vertex(498 + xGhost, 484 + yGhost);
    vertex(494 + xGhost, 484 + yGhost);
    vertex(494 + xGhost, 482 + yGhost);
    vertex(492 + xGhost, 482 + yGhost);
    vertex(492 + xGhost, 476 + yGhost);
    vertex(494 + xGhost, 476 + yGhost);
    vertex(494 + xGhost, 474 + yGhost);
    vertex(498 + xGhost, 474 + yGhost);
    vertex(498 + xGhost, 476 + yGhost);
    vertex(500 + xGhost, 476 + yGhost);
    vertex(500 + xGhost, 480 + yGhost);
    endShape();
    beginShape();
    vertex(500 + 14 + xGhost, 480 + yGhost);
    vertex(500 + 14 + xGhost, 482 + yGhost);
    vertex(498 + 12 + xGhost, 482 + yGhost);
    vertex(498 + 12 + xGhost, 484 + yGhost);
    vertex(494 + 12 + xGhost, 484 + yGhost);
    vertex(494 + 12 + xGhost, 482 + yGhost);
    vertex(492 + 12 + xGhost, 482 + yGhost);
    vertex(492 + 12 + xGhost, 476 + yGhost);
    vertex(494 + 12 + xGhost, 476 + yGhost);
    vertex(494 + 12 + xGhost, 474 + yGhost);
    vertex(498 + 12 + xGhost, 474 + yGhost);
    vertex(498 + 12 + xGhost, 476 + yGhost);
    vertex(500 + 14 + xGhost, 476 + yGhost);
    vertex(500 + 14 + xGhost, 480 + yGhost);
    endShape();
    //end eyes
    //draws the ghost's pupils
    fill(#504C4C);
    stroke(#504C4C);
    beginShape();
    vertex(514 + xGhost, 478 + yGhost);
    vertex(514 + xGhost, 482 + yGhost);
    vertex(510 + xGhost, 482 + yGhost);
    vertex(510 + xGhost, 478 + yGhost);
    vertex(514 + xGhost, 478 + yGhost);
    endShape();
    beginShape();
    vertex(514 - 14 + xGhost, 478 + yGhost);
    vertex(514 - 14 + xGhost, 482 + yGhost);
    vertex(510 - 14 + xGhost, 482 + yGhost);
    vertex(510 - 14 + xGhost, 478 + yGhost);
    vertex(514 - 14 + xGhost, 478 + yGhost);
    endShape();
    //end pupils
  } 
  else if (m <= 2*60) {
    //annimate eyes
    fill(#FFFFFF);
    stroke(#FFFFFF);
    beginShape();
    vertex(500 + 12 + xGhost, 480 + yGhost);
    vertex(500 + 12 + xGhost, 482 + yGhost);
    vertex(498 + 12 + xGhost, 482 + yGhost);
    vertex(498 + 12 + xGhost, 484 + yGhost);
    vertex(494 + 12 + xGhost, 484 + yGhost);
    vertex(494 + 12 + xGhost, 482 + yGhost);
    vertex(492 + 12 + xGhost, 482 + yGhost);
    vertex(492 + 12 + xGhost, 476 + yGhost);
    vertex(494 + 12 + xGhost, 476 + yGhost);
    vertex(494 + 12 + xGhost, 474 + yGhost);
    vertex(498 + 12 + xGhost, 474 + yGhost);
    vertex(498 + 12 + xGhost, 476 + yGhost);
    vertex(500 + 12 + xGhost, 476 + yGhost);
    vertex(500 + 12 + xGhost, 480 + yGhost);
    endShape();
    beginShape();
    vertex(500 + xGhost, 480 + yGhost);
    vertex(500 + xGhost, 482 + yGhost);
    vertex(498 + xGhost, 482 + yGhost);
    vertex(498 + xGhost, 484 + yGhost);
    vertex(494 + xGhost, 484 + yGhost);
    vertex(494 + xGhost, 482 + yGhost);
    vertex(492- 2 + xGhost, 482 + yGhost);
    vertex(492 - 2 + xGhost, 476 + yGhost);
    vertex(494 + xGhost, 476 + yGhost);
    vertex(494 + xGhost, 474 + yGhost);
    vertex(498 + xGhost, 474 + yGhost);
    vertex(498 + xGhost, 476 + yGhost);
    vertex(500 + xGhost, 476 + yGhost);
    vertex(500 + xGhost, 480 + yGhost);
    endShape();
    //end animate eyes
    //2nd pupils
    fill(#504C4C);
    stroke(#504C4C);
    beginShape();
    vertex(514 -20 + xGhost, 478 + yGhost);
    vertex(514 - 20 + xGhost, 482 + yGhost);
    vertex(510 - 20 + xGhost, 482 + yGhost);
    vertex(510 - 20 + xGhost, 478 + yGhost);
    vertex(514 -20 + xGhost, 478 + yGhost);
    endShape();
    beginShape();
    vertex(514 - 6 + xGhost, 478 + yGhost);
    vertex(514 - 6 + xGhost, 482 + yGhost);
    vertex(510 - 6 + xGhost, 482 + yGhost);
    vertex(510 - 6 + xGhost, 478 + yGhost);
    vertex(514 - 6 + xGhost, 478 + yGhost);
    endShape();
    //end 2nd pupils
    if (m == 2*60) {
      m = 0;
    }
  }
}
public void createObject() {//creates an new object (doesn't draw it just marks its position) Most of my creative effort is around these objects
  boolean create = false;
  while (create == false) {//while the position is incorrect
    create = true;//assumes correct for now
    //makes a random position and size for the object
    xPos1Object[countObjects] = r.nextInt(950);
    xPos2Object[countObjects] = (r.nextInt(35) + 10);
    yPos1Object[countObjects] = r.nextInt(550);
    yPos2Object[countObjects] = (r.nextInt(35) + 10);
    //if on pacman, a new position must be chosen
    if (Math.abs(ballPositionX - (xPos1Object[countObjects] + (xPos2Object[countObjects]/2))) < (25 + xPos2Object[countObjects]/2)) {
      if (Math.abs(ballPositionY - (yPos1Object[countObjects] + (yPos2Object[countObjects]/2))) < (25 + yPos2Object[countObjects]/2)) {
        create = false;
      }
    } 

    //if on food, a new position must be chosen
    if (Math.abs(xFood - (xPos1Object[countObjects] + (xPos2Object[countObjects]/2))) < (5 + xPos2Object[countObjects]/2)) {
      if (Math.abs(yFood - (yPos1Object[countObjects] + (yPos2Object[countObjects]/2))) < (5 + yPos2Object[countObjects]/2)) {
        create = false;
      }
    }
    //if on red pellet, a new position must be chosen
    if (Math.abs(xRed - (xPos1Object[countObjects] + (xPos2Object[countObjects]/2))) < (5 + xPos2Object[countObjects]/2)) {
      if (Math.abs(yRed - (yPos1Object[countObjects] + (yPos2Object[countObjects]/2))) < (5 + yPos2Object[countObjects]/2)) {
        create = false;
      }
    }
  }
  countObjects += 1;//number of objects goes up
}
//creative effort in collisions

public boolean leftCollision() {//code for the left collision of pacman
  if (ballPositionX <= 0 + 14) {//if pacman is colliding with the left wall, return true
    return true;
  } 
  else {
    for (int x = 0; x < maxOB; x++) {//if pacman is collding with any of the objects on their left side, return true
      if (abs(ballPositionX - 12.5 - xPos1Object[x] - xPos2Object[x]) <= 5 && ballPositionY + 12.5 >= yPos1Object[x] &&  ballPositionY - 12.5  <= (yPos2Object[x] + yPos1Object[x])) {
        return true;
      }
    }
    return false;//if pacman is not collding, return false
  }
}
//similar code for collision in all the other directions
public boolean rightCollision() {
  if (ballPositionX >= 1000 - 14) {
    return true;
  } 
  else {
    for (int x = 0; x < maxOB; x++) {
      if (abs(ballPositionX + 12.5 - xPos1Object[x]) <= 5 && ballPositionY + 12.5 >= yPos1Object[x] &&  ballPositionY - 12.5  <= (yPos2Object[x] + yPos1Object[x])) {
        return true;
      }
    }
    return false;
  }
}
public boolean upCollision() {
  if (ballPositionY <= 0 + 14) {
    return true;
  } 
  else {
    for (int x = 0; x < maxOB; x++) {
      if (abs(ballPositionY - 12.5 - yPos1Object[x] - yPos2Object[x]) <= 5 && ballPositionX + 12.5 >= xPos1Object[x] &&  ballPositionX  - 12.5 <= (xPos2Object[x] + xPos1Object[x])) {
        return true;
      }
    }
    return false;
  }
}
public boolean downCollision() {
  if (ballPositionY >= 600 - 14) {
    return true;
  }
  else {
    for (int x = 0; x < maxOB; x++) {
      if (abs(ballPositionY + 12.5 - yPos1Object[x]) <= 5 && ballPositionX + 12.5 >= xPos1Object[x] &&  ballPositionX  - 12.5 <= (xPos2Object[x] + xPos1Object[x])) {
        return true;
      }
    }
    return false;
  }
}
//end of collision code

void createFood() {//spawns food(doesn't draw it just marks the position)
  boolean create = true;
  while (create == true) {//similar code to the create object
    create = false;
    //makes a random position
    yFood = r.nextInt(590) + 5;
    xFood = r.nextInt(995) + 5;
    for (int x = 0; x < maxOB; x++) {//if the food is on an object, try a new position
      if (Math.abs(xFood - (xPos1Object[x] + (xPos2Object[x]/2))) < (10 + xPos2Object[x]/2)) {
        if (Math.abs(yFood - (yPos1Object[x] + (yPos2Object[x]/2))) < (10 + yPos2Object[x]/2)) {
          create = true;
        }
      }
    }
  }
  t = 0;//resets the timer for spawining the food
}

void createRed() {//spawns a red pellet (almost exact same code as the createFood() method)
  boolean create = true;
  while (create == true) {
    create = false;
    yRed = r.nextInt(590) + 5;
    xRed = r.nextInt(995) + 5;
    for (int x = 0; x < maxOB; x++) {
      if (Math.abs(xRed - (xPos1Object[x] + (xPos2Object[x]/2))) < (10 + xPos2Object[x]/2)) {
        if (Math.abs(yRed - (yPos1Object[x] + (yPos2Object[x]/2))) < (10 + yPos2Object[x]/2)) {
          create = true;
        }
      }
    }
  }
  limitRed = r.nextInt(11) + 20;//makes a new random time for the next pellet to spawn
  p = 0;
}
//if a certain key is pressed (code is self explanatory)
void keyPressed() {
  if (key == 119) {
    pressedKeyUp = true;
  } 
  if (key == 115) {
    pressedKeyDown = true;
  }
  if (key == 97) {
    pressedKeyLeft = true;
  }
  if (key == 100) {
    pressedKeyRight = true;
  }
  if (key == ' ') {
    pressedKeySpace= true;
  }
  //menu navigation
  if (key == '1' && menu == false) {
    menu1 = true;
    menu2 = false;
    menu3 = false;
    menu = true;
  }
  if (key == '2' && menu == false) {
    menu2 = true;
    menu1 = false;
    menu3 = false;
    menu = true;
  }
  if (key == '3' && menu == false) {
    menu3 = true;
    menu1 = false;
    menu2 = false;
    menu = true;
  }
  if (key == '4' && menu == false) {
    System.exit(0);//turns of the game
  }
}
//if a key is released
void keyReleased() {
  if (key == 119) {
    pressedKeyUp = false;
  } 
  if (key == 115) {
    pressedKeyDown = false;
  }
  if (key == 97) {
    pressedKeyLeft = false;
  }
  if (key == 100) {
    pressedKeyRight = false;
  }
}

