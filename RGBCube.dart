/**
 * RGB colors define a discrete cube of size 256. Choosing a RGB color is choosing
 *  a point in that cube.
 *  This example show you an original version of the RGB cube exploration :
 *  We travel along the main diagonal of the cube via the slider element, 
 *  and see the intersection of the cube with the plane that is perpendicular 
 *  to this diagonal at the considered point.
 *  If we click inside the intersection, we pick a color and see it.
 *  
 *  This is not a perfect representation of the cube, because of some approximations :
 *  If we choose a point on one edge, we have a plane that is perpendicular to the diagonal
 *  and contains this point. But we are not sure that this plane also contains a
 *  point on the diagonal (we are in a discrete space !).
 *  Anyway, I decide to represent the intersection between the cube and the plane,
 *  and fill it with appropriate colors (calculated as a barycenter), without considering
 *  if the point really exists. So this is just an approximative representation...
 */
#import('dart:html');
#import('dart:math');

void main() {
  var cube = new ColorCube();
  query('#container').nodes.add(cube.canvas);
}

class ColorCube {
  var A1, B1, C1, pA1, pB1, pC1,
      A2, D2, M2, N2, pA2, pB2, pD2, pE2, pM2, pN2,
      A3, B3, C3, pA3, pB3, pC3;
  int k;
  int size;
  CanvasElement canvas;
  static double SQRT3 = sqrt(3);

  canvasCoord(var x, var y){
    return [(x + size~/2).round().toInt(), (size~/2-y).round().toInt()];
  }

  ColorCube(){
    size = 600;
    canvas = new CanvasElement(size,size);
    canvas.attributes['style'] = 'border : 1px black solid';
    var context = canvas.context2d;

    InputElement slider = query('#slider');
    k = int.parse(slider.value);

    init(k);

    draw(context, k);
    drawSmallWiredCube(context, k);

    slider.on.change.add((Event e) {
      k = int.parse(slider.value);
      query('#sliderValue').text = "$k";
      init(k);
      draw(context, k);
      drawSmallWiredCube(context, k);
    }, true);

    pickColor(k);
  }

  void draw(CanvasRenderingContext2D c, int k){
    if (k <= 255){
      draw1(c, k);
    }
    if (k > 255 && k <510) {
      draw2(c, k);
    }
    if (k >= 510) {
      draw3(c, k);
    }

  }
  /**
   * Draw an equilateral triangle.
   * The 3 points [p1], [p2] and [p3] define the vertex of the complete triangle ;
   * [A], [B] and [C] are vertex's colors.
   * The drawing has a horizontal basis ([p1.x], [p1.y]) --> ([p2.x], [p1.y]).
   * When [orientation] is true, the triangle is drawn above his basis,
   * else it's drawn below the basis.
   * To draw a complete triangle set [ymax] = [p3.y].
   * To truncate the triangle, set [ymax] < [p3.y] (if [orientation] is true).
   */
  void drawColorTriangle(ImageData imgData, int a,
                         Point p1, Point p2, Point p3,
                         List A, List B, List C,
                         var ymax,
                         bool orientation){
    var delta, compare;
    if (orientation){
      delta = -1;
      compare = (var u, var v) => u >= v;
    }
    else {
      delta = 1;
      compare = (var u, var v) => u <= v;
    }
    var color, p;
    var x1 = p1.x;
    var x2 = p2.x;
    var y = p1.y;
    var d = 0.134; // ~1-sqrt(3)/2
    while (compare(y, ymax)) {
      for (var x=x1; x<=x2; x++){
        p = new Point(x,y);
        color = colorAtPoint(p, p1, p2, p3,
            A[0], A[1], A[2],
            B[0], B[1], B[2],
            C[0], C[1], C[2]);
        imgData.data[4*(x+size*y)] = color[0];
        imgData.data[4*(x+size*y)+1] = color[1];
        imgData.data[4*(x+size*y)+2] = color[2];
        imgData.data[4*(x+size*y)+3] = 255;
      }
      if (d>0){
        d = d - 0.732;
        x1++;
        y = y + delta;
        x2--;
      }
      else{
        d++;
        y = y + delta;
      }
    }
  }

  canvasCoordPoint(var x, var y){
    return new Point((x + size~/2).round().toInt(), (size~/2-y).round().toInt());
  }

  void init(var a){
//------------------------------------------
///      C
///     /\
///    /__\
///  B      A
    A1 = [a, 0, 0];
    B1 = [0, a, 0];
    C1 = [0, 0, a];

    pB1 = canvasCoordPoint(-a/SQRT2,-a/(SQRT2*SQRT3));
    pA1 = canvasCoordPoint(a/SQRT2,-a/(SQRT2*SQRT3));
    pC1 = canvasCoordPoint(0,a*SQRT2/SQRT3);
//------------------------------------------
///     M
///   C __ B
///  D /  \ A
///    \__/
///   E    F
///     N

// M and N are fictive points so that triangles AMD and AND are equilateral

    A2 = [255, 0, a-255];
    D2 = [0, 255, a-255];
    M2 = [0, 0, a];
    N2 = [255, 255, a-510];

    pA2 = canvasCoordPoint(255/SQRT2, SQRT2/SQRT3*a-SQRT3/SQRT2*255);
    pB2 = canvasCoordPoint(SQRT1_2*(a-255), SQRT3/SQRT2*(255-a/3));
    pD2 = canvasCoordPoint(-255/SQRT2, SQRT2/SQRT3*a-SQRT3/SQRT2*255);
    pE2 = canvasCoordPoint(a/SQRT2-255*SQRT2, -a/(SQRT2*SQRT3));
    pM2 = canvasCoordPoint(0, SQRT2*SQRT3*a/3);
    pN2 = canvasCoordPoint(0, SQRT2*SQRT3*(a/3-255));

// -----------------------------------------
///  B __ A
///   \  /
///    \/
///    C

    C3 = [255, 255, a-510];
    A3 = [255, a-510, 255];
    B3 = [a-510, 255, 255];

    pC3 = canvasCoordPoint(0,-(765-a)*SQRT2/SQRT3);
    pA3 = canvasCoordPoint((765-a)/SQRT2, (765-a)/(SQRT2*SQRT3));
    pB3 = canvasCoordPoint(-(765-a)/SQRT2, (765-a)/(SQRT2*SQRT3));

  }

  void draw1(CanvasRenderingContext2D c, int a){
    c.clearRect(0, 0, size, size);
    var imgData = c.createImageData(size, size);
    drawColorTriangle(imgData, a, pB1, pA1, pC1, B1, A1, C1, pC1.y, true);
    c.putImageData(imgData, 0, 0);
  }

  void draw2(CanvasRenderingContext2D ctx, int a){
    ctx.clearRect(0, 0, size, size);
    var imgData = ctx.createImageData(size, size);
    drawColorTriangle(imgData, a, pD2, pA2, pM2, D2, A2, M2, pB2.y, true);
    drawColorTriangle(imgData, a, pD2, pA2, pN2, D2, A2, N2, pE2.y, false);
    ctx.putImageData(imgData, 0, 0);
  }

  void draw3(CanvasRenderingContext2D c, int a){
    c.clearRect(0, 0, size, size);
    var imgData = c.createImageData(size, size);
    drawColorTriangle(imgData, a, pB3, pA3, pC3, B3, A3, C3, pC3.y, false);
    c.putImageData(imgData, 0, 0);
  }

  /**
   * Define the color of a point [p], calculated as the barycenter
   * of points [p1], [p2] and [p3].
   * Each of these three points have its color defined by RGB values.
   * Return a list of RGB values for [p].
   */
  colorAtPoint(Point p, Point p1, Point p2, Point p3,
               var r1, var g1, var b1,
               var r2, var g2, var b2,
               var r3, var g3, var b3){
    var alpha, beta, gamma;
    alpha = ((p.x-p3.x)*(p2.y-p3.y)-(p.y-p3.y)*(p2.x-p3.x))/((p1.x-p3.x)*(p2.y-p3.y)-(p1.y-p3.y)*(p2.x-p3.x));
    beta = ((p.x-p3.x)-alpha*(p1.x-p3.x))/(p2.x-p3.x);
    gamma = 1-alpha-beta;
    int red = (alpha*r1 + beta*r2 + gamma*r3).round().toInt();
    int green = (alpha*g1 + beta*g2 + gamma*g3).round().toInt();
    int blue = (alpha*b1 + beta*b2 + gamma*b3).round().toInt();
    return [red, green, blue];
  }

  void drawSmallWiredCube(CanvasRenderingContext2D c, int k){
    var size = 100;
    var diagSize = 40;
    var angle = PI/6;

    var xdiag = diagSize*cos(angle);
    var ydiag = diagSize*sin(angle);

    c.translate(c.canvas.width-size-diagSize-20, c.canvas.height-20);

    drawSmallWiredCubeIntersection(c, k, size, diagSize, angle);
    
    c.beginPath();
    c.moveTo(0, 0);
    c.strokeStyle = '#F00';
    c.lineTo(size, 0);
    c.stroke();
    
    c.beginPath();
    c.moveTo(size, 0);
    c.strokeStyle = '#000';
    c.lineTo(size, -size);
    c.lineTo(0, -size);
    c.stroke();
    
    c.beginPath();
    c.moveTo(0, -size);
    c.strokeStyle = '#00F';
    c.lineTo(0, 0);
    c.stroke();
    
    c.beginPath();
    c.moveTo(0, 0);
    c.strokeStyle = '#0F0';
    c.lineTo(xdiag, -ydiag);
    c.stroke();
    
    c.beginPath();
    c.moveTo(xdiag, -ydiag);
    c.strokeStyle = '#000';
    c.lineTo(xdiag, -size-ydiag);
    c.lineTo(size+xdiag, -size-ydiag);
    c.lineTo(size+xdiag, -ydiag);
    c.lineTo(xdiag, -ydiag);

    c.moveTo(0,-size);
    c.lineTo(xdiag, -size-ydiag);

    c.moveTo(size,0);
    c.lineTo(size+xdiag, -ydiag);

    c.moveTo(size,-size);
    c.lineTo(size+xdiag, -size-ydiag);
    c.lineTo(0,0);

    c.stroke();

    c.translate(-c.canvas.width+size+diagSize+20, -c.canvas.height+20);
  }

  void drawSmallWiredCubeIntersection(CanvasRenderingContext2D c, int k, int size, int diagSize, num angle){
    if (k <= 255){
      drawSmallWiredCubeIntersection1(c, k, size, diagSize, angle);
    } else if (k > 255 && k < 510){
      drawSmallWiredCubeIntersection2(c, k, size, diagSize, angle);
    } else {
      drawSmallWiredCubeIntersection3(c, k, size, diagSize, angle);
    }
  }

  void drawSmallWiredCubeIntersection1(CanvasRenderingContext2D c, int k, int size, int diagSize, num angle){
    c.beginPath();
    var xdiag = diagSize*cos(angle);
    var ydiag = diagSize*sin(angle);
    c.moveTo(0, -size*k/255);
    c.lineTo(size*k/255, 0);
    c.lineTo(diagSize*k/255*cos(angle), -diagSize*k/255*sin(angle));
    c.closePath();
    c.fillStyle = '#DDD';
    c.fill();
    c.stroke();
    c.fillStyle = '#000';
    c.fillRect(k/255*(size+xdiag)/3-1, -k/255*(size+ydiag)/3-1, 2, 2);
  }

  void drawSmallWiredCubeIntersection2(CanvasRenderingContext2D c, int k, int size, int diagSize, num angle){
    c.beginPath();
    var xdiag = diagSize*cos(angle);
    var ydiag = diagSize*sin(angle);
    c.moveTo(size, -(k-255)/255*size);
    c.lineTo(size*(k-255)/255, -size);
    c.lineTo(xdiag*(k-255)/255, -size-ydiag*(k-255)/255);
    c.lineTo(xdiag, -ydiag-size*(k-255)/255);
    c.lineTo(xdiag+size*(k-255)/255, -ydiag);
    c.lineTo(size+xdiag*(k-255)/255, -ydiag*(k-255)/255);
    c.closePath();
    c.fillStyle = '#DDD';
    c.fill();
    c.stroke();
    c.fillStyle = '#000';
    c.fillRect(k/255*(size+xdiag)/3-1, -k/255*(size+ydiag)/3-1, 2, 2);
  }

  void drawSmallWiredCubeIntersection3(CanvasRenderingContext2D c, int k, int size, int diagSize, num angle){
    c.beginPath();
    var xdiag = diagSize*cos(angle);
    var ydiag = diagSize*sin(angle);
    c.moveTo(size + xdiag, -ydiag-(k-510)/255*size);
    c.lineTo(size*(k-510)/255 + xdiag, -size-ydiag);
    c.lineTo(size + xdiag*(k-510)/255, -size-ydiag*(k-510)/255);
    c.closePath();
    c.fillStyle = '#DDD';
    c.fill();
    c.stroke();
    c.fillStyle = '#000';
    c.fillRect(k/255*(size+xdiag)/3-1, -k/255*(size+ydiag)/3-1, 2, 2);
  }

  List getColor(CanvasElement canvas, int x, int y){
    var context = canvas.context2d;
    var imgData = context.getImageData(0, 0, canvas.width, canvas.height);
    var red = imgData.data[4*(x+size*y)];
    var green = imgData.data[4*(x+size*y)+1];
    var blue = imgData.data[4*(x+size*y)+2];
    var alpha = imgData.data[4*(x+size*y)+3];
    if (alpha != 255){ // points outside the drawing must be whites
      red = 255;
      green = 255;
      blue = 255;
    }
    return [red, green, blue];

  }


  void pickColor(int k){
    ClickHandler clickHandler = new ClickHandler(canvas, drawColorSample);
  }

  drawColorSample(CanvasElement canvas, var x, var y){
    var color = getColor(canvas, x.toInt(), y.toInt());
    print('color : [${color[0]}, ${color[1]}, ${color[2]}]');
    var c = canvas.context2d;
    c.translate(20, canvas.width-20-40);
    var rgbColor = toHexString(color[0] << 16 | color[1] << 8 | color[2]);
    c.clearRect(0, 0, 180, 40);
    c.fillStyle = '#$rgbColor';
//    c.setFillColorRgb(color[0], color[1], color[2]);
    c.fillRect(0, 0, 40, 40);
    c.fillStyle = '#000';
    c.font = '16px Open Sans';
    c.fillText('[${color[0]}, ${color[1]}, ${color[2]}]', 60, 16);
    c.fillText('#$rgbColor', 60, 40);
    c.translate(-20, -canvas.width+20+40);
  }

  String toHexString(int n){
    String s = n.toRadixString(16);
    while (s.length < 6){
      s = '0$s';
    }
    return s;
  }
}

class Point {
  final num x;
  final num y;
  Point(this.x, this.y);
}

class ClickHandler{
  CanvasElement canvas;
  Point clientBoundingRect;
  Future<ElementRect> futureRect;
  Function callback;

  ClickHandler(this.canvas, this.callback){
    futureRect = canvas.rect;
    futureRect.then((ElementRect rect) {
      clientBoundingRect = new Point(rect.bounding.left, rect.bounding.top);
    });
    canvas.on.click.add((e){
        var point = getXandY(e);
        callback(this.canvas, point.x, point.y);
    });
  }

  Point getXandY(e) {
    num x = e.clientX - clientBoundingRect.x;
    num y = e.clientY - clientBoundingRect.y;
    return new Point(x, y);
  }


}
