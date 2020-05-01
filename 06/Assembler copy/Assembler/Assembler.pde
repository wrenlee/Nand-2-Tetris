/*Wren Lee 
 module 6 - assembler
 crcp 2330 - nand 2 tetris
 
 to get started with the assembler, first name your file in the void setup()
 */

//variables
String file;
PrintWriter writer;

Parser p;
Code c;
Symbols s;

StringList binary;

void setup() {
  file = "Max"; 
  file = file + ".asm"; //creates file

  p = new Parser(file);
  c = new Code();
  s = new Symbols();

  //init stringlists
  binary = new StringList();

  s.predefinedSymbols(); //predefined symbols

  noLoop();
}//end setup

void draw() {
  p.readFile(); //adds strings to string list

  firstPass();
 // s.printTable();
  //secondPass();
  //s.printTable();
  //println("--------------------");

  //writeToFile();
}//end draw

void firstPass() {
  println("First");
  String labelName = ""; //label name
  int rom = 0;
  while (p.hasMoreCommands()==true) {
    p.advance();
    if (p.currentString().startsWith("//") == false && p.currentString().isEmpty() == false) {
      if (p.currentType() == "l") {//if it's a label
        println(p.currentString());
        int length = p.currentString().length();
        labelName = p.currentString().substring(1, length-1);//get label name w/o parenthesis
        s.addSymbol(labelName, rom+1); //add label name and ROM address
      }//if it's a label
      else {
        rom++;
      }//if it's a or c command
    }//is not a comment, or white space
  }//more commands
}//first pass

void secondPass() {
  int ram = 16; 
  println("Second");
  while (p.hasMoreCommands()==true) {
    p.advance();

    if (p.currentString().startsWith("//") == false && p.currentString().isEmpty() == true) {

      if (p.currentType() == "a") {
        int length = p.currentString().length();
        String aCommand = p.currentString().substring(1, length);//takes out the @ symbol
        String newAddress = "";
        if (s.hasSymbol(aCommand) == false) {
          s.addSymbol(aCommand, ram);//add symbol
          ram++; //increase ram
        }//if the symbol isn't there
        else {
          newAddress = s.getAddress(aCommand);
        }//if the symbol is there
        binary.append(c.aToBinary(newAddress));
      }//a command

      else if (p.currentType() == "c") {
        //break line up into comp dest and jump
        String[] tempStr = new String[3];
        String comp = "";
        String dest = "";
        String jump = "";
        if (p.currentString().contains("=")==true) { //dest = comp
          tempStr = p.currentString().split("=");
          dest = tempStr[0];
          comp = tempStr[1];
        }//comp + dest
        else {
          dest = "0";
        }//if there is no dest
        if (p.currentString().contains(";")==true) {//comp;jump
          tempStr = p.currentString().split(";");
          comp = tempStr[0];
          jump = tempStr[1];
        }//comp + jump
        else {
          jump = "0";
        }//if there is no jump
        binary.append(c.cToBinary(comp, dest, jump));
      }//c command
    }//if it's not a comment or empty space
  }//more commands
}//second pass

void writeToFile() {
  String finalFile = file;
  finalFile = finalFile + ".hack";
  writer = createWriter(finalFile);

  for (int i = 0; i < binary.size(); i++) {
    writer.println(binary.get(i)); //adds codes to writer
  }//for loop 

  writer.flush(); 
  writer.close();
  println(finalFile + " is published!");
}//write to file
