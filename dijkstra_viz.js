var mazeWidth = 15; //number of blocks in width
var mazeHeight = 15; //number of blocks in length
var begin = {
    startX: 0,
    startY: 0,
    finishX: mazeWidth - 1,
    finishY: mazeHeight -1
};

/**
 * Dijkstra pathfinding algorithm
 */

var Queue = function() {
  this.nodes = [];

  this.enqueue = function (priority, x, y) {
    this.nodes.push({
        xCoord: x,
        yCoord: y,
        priority: priority
    });
    this.sort(this.nodes[this.nodes.length-1].priority);
  };
  this.dequeue = function () {
    return {
        x: this.nodes[0].xCoord,
        y: this.nodes.shift().yCoord
    };
  };
  this.sort = function () {
    this.nodes.sort(function (a, b) {
      return a.priority - b.priority;
    });
  };
  this.isEmpty = function () {
    if (this.nodes.length === 0) {
        return true;
    }
    else {return false;}
  };
};

// Pathfinding
var Graph = function(){
  var INFINITY = 1/0;
  this.nodes = []; //array for storing nodes

  //initialize into two-dimensional array
  for(var i=0; i<=mazeWidth; i++) {
      this.nodes[i]=[];
  }

  this.addNode = function(x, y, north, south, east, west){
    this.nodes[x][y] = {
        N: north,
        S: south,
        E: east,
        W: west
    };
  };

  this.shortestPath = function (startX, startY, finishX, finishY, tiles) {
    var nodes = new Queue(),
        distances = [], //distance from current node to player node
        previous = [], //previous node in path
        path = [], //optimal path
        start = {
            x: startX,
            y: startY
        },
        finish = {
            x: finishX,
            y: finishY
        },
        smallest, alt, wall, neighborX, neighborY;

    for(var i=0; i<=mazeWidth; i++) { //initialize into two dimensional array
      distances[i]=[];
      previous[i]=[];
    }

    //initialize nodes
    for(var i=0; i<mazeWidth; i++) {
        for(var j=0; j<mazeHeight; j++) {
            //start node
            if(i === start.x && j === start.y) {
                distances[i][j] = 0;
                nodes.enqueue(0, i, j);
            }
            //all other nodes
            else {
                distances[i][j] = INFINITY;
                nodes.enqueue(INFINITY, i, j);
            }

            previous[i][j] = null;
        }
    }

    //iterate through each node
    while(!nodes.isEmpty()) {
        smallest = nodes.dequeue();
        //check if we found the finish node
        if(smallest.x === finish.x && smallest.y === finish.y) {
            while(previous[smallest.x][smallest.y]) {
                path.push(smallest);
                smallest = previous[smallest.x][smallest.y];
            }

            break;
        }

        if(!smallest || distances[smallest.x][smallest.y] === INFINITY){
                continue;
        }

        //iterate through each wall in the block
        for(wall in this.nodes[smallest.x][smallest.y]) {
            //if no wall, obtain neighbor's coordinates
            if(!this.nodes[smallest.x][smallest.y][wall]) {
                switch(wall) {
                    case 'N':
                        neighborX = smallest.x;
                        neighborY = smallest.y - 1;
                        break;
                    case 'S':
                        neighborX = smallest.x;
                        neighborY = smallest.y + 1;
                        break;
                    case 'E':
                        neighborX = smallest.x + 1;
                        neighborY = smallest.y;
                        break;
                    case 'W':
                        neighborX = smallest.x - 1;
                        neighborY = smallest.y;
                        break;
                    default:
                        break;
                }
                //calculate distance from start to neighbor
                alt = distances[smallest.x][smallest.y] + 1;
                //if less than neighbor's previous distance, replace it
                if(alt < distances[neighborX][neighborY]) {
                    distances[neighborX][neighborY] = alt;
                    previous[neighborX][neighborY] = smallest;
                    nodes.enqueue(alt, neighborX, neighborY);
                }
            }
        }
    }

    // update all tile distances
    for(var i=0; i<mazeWidth; i++) {
        for(var j=0; j<mazeHeight; j++) {
            tiles[i][j].update(distances[i][j]);
        }
    }

    path.push({x: startX, y: startY});
    path.reverse();
    return path;
  };
};
