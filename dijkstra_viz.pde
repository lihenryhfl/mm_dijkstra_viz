/** Left click sets start point, right click sets end point. Left click start point again to reset player. Click on the blank spaces between tiles to turn them into walls. */
//The corner of each tile displays the distance from the player block to the end block. Here I use the term "player" loosely.
//The maze solving algorithm is based on Dijkstra's algorithm. To learn more go to http://en.wikipedia.org/wiki/Dijkstra's_algorithm
//Note that the displayed distance is sometimes infinity despite being a viable path for the player (i.e. being not blocked off). This is because infinity is the default initialized value for each block. To maximize efficiency the algorithm stops as soon as it finds the end block. All other blocks are thus ignored and left at their default values.
/* @pjs preload="sprite.png"; */

//buttons *note that this is not actually used in the demo
var Button = function(x,y,width,height,text) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.label = text;

    this.draw = function() {
        fill(0, 234, 255);
        rect(this.x, this.y, this.width, this.height, 5);
        fill(0, 0, 0);
        textSize(19);
        textAlign(LEFT, TOP);
    };

    this.isMouseInside = function() {
    return mouseX > this.x &&
           mouseX < (this.x + this.width) &&
           mouseY > this.y &&
           mouseY < (this.y + this.height);
    };

    this.handleMouseClick = function(character) {
        if (this.isMouseInside) {
            character.reset();
        }
    };
};

// interactive floor tiles
var Tile = function(blockX, blockY, state, width) {
    this.blockX = blockX;
    this.blockY = blockY;
    this.state = state || 0;
    this.width = width || 35;
    this.x = this.blockX*40 + 5;
    this.y = this.blockY*40 + 5;
    if (this.blockX === begin.startX && this.blockY === begin.startY) {
        this.state = 1;
    }
    if (this.blockX === begin.finishX && this.blockY === begin.finishY) {
        this.state = 2;
    }
    this.distance = 1/0; //initiate all distances at infinity

    this.update = function(distance) {
        this.distance = distance;
    };

    this.draw = function() {
        var strDist;
        if (this.distance === 1/0) {
            strDist = "∞";
        }
        else {
            strDist = this.distance;
        }
        switch(this.state) {
            case 0: //off
                fill(158, 155, 158);
                break;
            case 1: //start
                fill(25, 209, 129);
                break;
            case 2: //finish
                fill(247, 84, 84);
                break;
        }
        rect(this.x, this.y, this.width, this.width);
        fill(235, 245, 243);
        text(strDist+"", this.x + 1, this.y+10);
    };

    this.isMouseInside = function() {
        return mouseX > this.x &&
               mouseX < (this.x + this.width) &&
               mouseY > this.y &&
               mouseY < (this.y + this.width);
    };

    this.handleMouseClick = function(tileArray, character) {
        var mouseInside = this.isMouseInside();
        var newState = 0;
        if (mouseInside) {
            switch(mouseButton) {
                case LEFT:
                    if (this.state === 0) {
                        newState = 1;
                        character.update({
                            startX: this.blockX,
                            startY: this.blockY,
                            finishX: character.finish.x,
                            finishY: character.finish.y
                        });
                    }
                    else if (this.blockX===character.start.x && this.blockY===character.start.y) {
                        newState = 1;
                    }
                    break;
                case RIGHT:
                    newState = 2;
                    character.update({
                        startX: character.start.x,
                        startY: character.start.y,
                        finishX: this.blockX,
                        finishY: this.blockY
                    });
                    break;
            }
            for (var i=0; i<mazeWidth; i++) {
                for (var j=0; j<mazeHeight; j++) {
                    if (tileArray[i][j].state === newState) {
                        tileArray[i][j].state = 0;
                    }
                }
            }
            this.state = newState;
            character.reset();
            return true;
        }
    };
};

var Wall = function(x,y,orientation,vdrawn,hdrawn) { //generates the wall with its attributes
    this.hwidth = 5;
    this.hheight = 35;
    this.vwidth = 35;
    this.vheight = 5;
    this.vx = (x || 0)+5;
    this.vy = (y || 0);
    this.hx = (x || 0);
    this.hy = (y || 0)+5;

    this.orientation = orientation;
    this.vdrawn = vdrawn || false;
    this.hdrawn = hdrawn || false;

    //renders the wall grey if it exists
    this.draw = function() {
        switch(orientation) {
            case "vertical":
                if(this.vdrawn) {fill(105, 104, 105);}
                else {fill(252, 242, 242);}
                rect(this.vx, this.vy, this.vwidth, this.vheight);
                break;
            case "horizontal":
                if(this.hdrawn) {fill(105, 104, 105);}
                else {fill(252, 242, 242);}
                rect(this.hx, this.hy, this.hwidth, this.hheight);
                break;
            case "both":
                if(this.vdrawn) {fill(105, 104, 105);}
                else {fill(252, 242, 242);}
                rect(this.vx, this.vy, this.vwidth, this.vheight);
                if(this.hdrawn) {fill(105, 104, 105);}
                else {fill(252, 242, 242);}
                rect(this.hx, this.hy, this.hwidth, this.hheight);
                break;
            case "none":
                break;
        }
    };


    this.toggle = function() {
        this.drawn = !this.drawn;
    };

    //checks when cursor is on a wall
    this.isMouseInside = function() {
        if(mouseX > this.hx - 5 &&
           mouseX < (this.hx + 5 + this.hwidth) &&
           mouseY > this.hy - 5 &&
           mouseY < (this.hy + 5 + this.hheight)){
            return "h";
           }
        else if(mouseX > this.vx - 5 &&
            mouseX < (this.vx + 5 + this.vwidth) &&
            mouseY > this.vy - 5 &&
            mouseY < (this.vy + 5 + this.vheight)){
        return "v";
        }
        else {
            return false;
        }
    };

    //toggles wall when isMouseInside returns true
    this.handleMouseClick = function() {
        var mouseInside = this.isMouseInside();
        if (mouseInside) {
            if (mouseInside === "v") {
                this.vdrawn = !this.vdrawn;
            }
            else if (mouseInside ==="h") {
                this.hdrawn = !this.hdrawn;
            }
        }
    };
};

var GameCharacter = function(blockX, blockY, orientation) {
    this.blockX = blockX;
    this.blockY = blockY;
    this.orientation = orientation;
    this.img = loadImage("sprite.png");
    this.start = {
        x: begin.startX,
        y: begin.startY
    };
    this.finish = {
        x: begin.finishX,
        y: begin.finishY
    };

    this.update = function(config) {
        this.start.x = config.startX;
        this.start.y = config.startY;
        this.finish.x = config.finishX;
        this.finish.y = config.finishY;
    };

    this.reset = function() {
        this.blockX = this.start.x;
        this.blockY = this.start.y;
    };

    this.draw = function() {
        this.x = this.blockX*40+13;
        this.y = this.blockY*40+5;
        image(this.img, this.x, this.y, 20, 35);
    };

    this.move = function(blockX, blockY) {
        this.blockX = blockX;
        this.blockY = blockY;
    };

    //detects and reports walls next to character
    this.detectWalls = function(walls) {
        var wall = [];
        wall.N = false;
        wall.S = false;
        wall.E = false;
        wall.W = false;
        if(walls[this.blockX][this.blockY].vdrawn === true) {
            wall.N = true;
        }
        if(walls[this.blockX][this.blockY].hdrawn === true) {
            wall.W = true;
        }
        if(walls[this.blockX][this.blockY+1].vdrawn === true) {
            wall.S = true;
        }
        if(walls[this.blockX+1][this.blockY].hdrawn === true) {
            wall.E = true;
        }
        return wall;
    };
};

/**
 * Maze Initialization
 */

var walls = []; //array for storing wall objects
var tiles = []; //array for storing tile objects

for(var i=0; i<=mazeWidth; i++) { //initialize into two dimensional arrays
    walls[i] = [];
    tiles[i] = [];
}
var m = new Graph();
var northVal = false,
    southVal = false,
    eastVal = false,
    westVal = false;
var player1 = new GameCharacter(begin.startX, begin.startY);

for(var i=0; i<=mazeWidth; i++) { //initialize walls, tiles, and pathfinding nodes
    for (var j=0; j<=mazeHeight; j++) {
        // initialize walls
        if(i===mazeWidth && j===mazeHeight) { //rightmost & bottommost block has no wall
            walls[i][j] = new Wall(mazeWidth*40, mazeHeight*40, "none", false, false);
        }
        else if(i===mazeWidth) { //rightmost blocks have extra wall on right
            walls[i][j] = new Wall(i*40, j*40, "horizontal", false, true);
        }
        else if(j===mazeHeight){ //bottommost blocks have extra wall on bottom
            walls[i][j] = new Wall(i*40, j*40, "vertical", true, false);
        }
        else if(i===0 && j===0) { //top left block has both walls
            walls[i][j] = new Wall(i*40, j*40, "both", true, true);
        }

        else if(i===0){ //leftmost blocks have wall by default
            walls[i][j] = new Wall(i*40, j*40, "both", false, true);
        }
        else if(j===0){ //topmost blocks have wall by default
            walls[i][j] = new Wall(i*40, j*40, "both", true, false);
        }
        else { //all other walls
            walls[i][j] = new Wall(i*40, j*40, "both");
        }

        //initialize tiles and pathfinding nodes
        if(i!==mazeWidth && j!==mazeHeight) {
            tiles[i][j] = new Tile(i, j);
            if(j===0) {northVal = true;} else {northVal = false;}
            if(j===mazeHeight-1) {southVal = true;} else {southVal = false;}
            if(i===0) {westVal = true;} else {westVal = false;}
            if(i===mazeWidth-1) {eastVal = true;} else {eastVal = false;}
            m.addNode(i, j, northVal, southVal, eastVal, westVal);
        }
    }
}


mouseClicked = function() { //detects mouse click, toggles wall, and redraws walls
    var tileClickTrue;
    for(var i=0; i<=mazeWidth; i++) {
        for (var j=0; j<=mazeHeight; j++) {
            walls[i][j].handleMouseClick();
            if(i!==mazeWidth && j!==mazeHeight) {
                tileClickTrue = tiles[i][j].handleMouseClick(tiles, player1);
                if(tileClickTrue) {
                    break;
                }
            }
        }
    }
};

void setup() {
  size(mazeWidth*40+5,mazeHeight*40+5);
  background(94, 48, 48);
  frameRate(5);
}


draw = function() {
    //detect walls around character's position
    var newWalls = player1.detectWalls(walls);

    //update these walls in the pathfinding algorithm
    m.addNode(player1.blockX, player1.blockY, newWalls.N, newWalls.S, newWalls.E, newWalls.W);

    //run the algorithm
    var ourPath = m.shortestPath(player1.blockX, player1.blockY, player1.finish.x, player1.finish.y, tiles);

    //render all walls and tiles
    for(var i=0; i<=mazeWidth; i++) {
        for (var j=0; j<=mazeHeight; j++) {
            walls[i][j].draw();
            if(i!==mazeWidth && j!==mazeHeight) {
                tiles[i][j].draw();
            }
        }
    }

    //render player
    player1.draw();

    //move player
    if(ourPath.length > 1) {
        player1.move(ourPath[1].x, ourPath[1].y);
    }
    else {
        player1.move(ourPath[0].x, ourPath[0].y);
    }
};
