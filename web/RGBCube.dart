import 'dart:html';
import 'dart:math';

void main() {
  var cube = new ColorCube();
  querySelector('#container').nodes.add(cube.canvas);
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
    canvas = new CanvasElement(width: size, height: size);
    canvas.attributes['style'] = 'border : 1px black solid';
    var context = canvas.context2D;

    InputElement slider = querySelector('#slider');
    k = int.parse(slider.value);
    init1();
    pickColor();

    draw(context);
    drawSmallWiredCube(context);

    slider.onChange.listen((Event e) {
      k = int.parse(slider.value);
      querySelector('#sliderValue').text = "$k";
      draw(context);
      drawSmallWiredCube(context);
    }, cancelOnError: true);

  }

  void draw(CanvasRenderingContext2D c){
    if (k <= 255){
      init1();
      draw1(c);
    }
    if (k > 255 && k <510) {
      init2();
      draw2(c);
    }
    if (k >= 510) {
      init3();
      draw3(c);
    }

  }
  /**
   * Draw an equilateral triangle.
   * The 3 points [p1], [p2] and [p3] define the vertex of the complete triangle ;
   * [A], [B] and [C] are vertex's colors.
   * The drawing has a horizontal basis ([p1[0]], [p1[1]]) --> ([p2[0]], [p1[1]]).
   * When [orientation] is true, the triangle is drawn above his basis,
   * else it's drawn below the basis.
   * To draw a complete triangle set [ymax] = [p3[1]].
   * To truncate the triangle, set [ymax] < [p3[1]] (if [orientation] is true).
   */
  void drawColorTriangle(ImageData imgData,
                         List p1, List p2, List p3,
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
    var x1 = p1[0];
    var x2 = p2[0];
    var y = p1[1];
    var d = 0.134; // ~1-sqrt(3)/2
    while (compare(y, ymax)) {
      for (var x=x1; x<=x2; x++){
        p = [x,y];
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


///      C
///     /\
///    /__\
///  B      A
  void init1(){
    A1 = [k, 0, 0];
    B1 = [0, k, 0];
    C1 = [0, 0, k];

    pB1 = canvasCoord(-k/SQRT2,-k/(SQRT2*SQRT3));
    pA1 = canvasCoord(k/SQRT2,-k/(SQRT2*SQRT3));
    pC1 = canvasCoord(0,k*SQRT2/SQRT3);
    } 

///     M
///   C __ B
///  D /  \ A
///    \__/
///   E    F
///     N
///
/// M and N are fictive points so that triangles AMD and AND are equilateral
  void init2(){
    A2 = [255, 0, k-255];
    D2 = [0, 255, k-255];
    M2 = [0, 0, k];
    N2 = [255, 255, k-510];

    pA2 = canvasCoord(255/SQRT2, SQRT2/SQRT3*k-SQRT3/SQRT2*255);
    pB2 = canvasCoord(SQRT1_2*(k-255), SQRT3/SQRT2*(255-k/3));
    pD2 = canvasCoord(-255/SQRT2, SQRT2/SQRT3*k-SQRT3/SQRT2*255);
    pE2 = canvasCoord(k/SQRT2-255*SQRT2, -k/(SQRT2*SQRT3));
    pM2 = canvasCoord(0, SQRT2*SQRT3*k/3);
    pN2 = canvasCoord(0, SQRT2*SQRT3*(k/3-255));
    } 

///  B __ A
///   \  /
///    \/
///    C
  void init3(){
    C3 = [255, 255, k-510];
    A3 = [255, k-510, 255];
    B3 = [k-510, 255, 255];

    pC3 = canvasCoord(0,-(765-k)*SQRT2/SQRT3);
    pA3 = canvasCoord((765-k)/SQRT2, (765-k)/(SQRT2*SQRT3));
    pB3 = canvasCoord(-(765-k)/SQRT2, (765-k)/(SQRT2*SQRT3));
    }

  void draw1(CanvasRenderingContext2D c){
    c.clearRect(0, 0, size, size);
    var imgData = c.createImageData(size, size);
    drawColorTriangle(imgData, pB1, pA1, pC1, B1, A1, C1, pC1[1], true);
    c.putImageData(imgData, 0, 0);
  }

  void draw2(CanvasRenderingContext2D ctx){
    ctx.clearRect(0, 0, size, size);
    var imgData = ctx.createImageData(size, size);
    drawColorTriangle(imgData, pD2, pA2, pM2, D2, A2, M2, pB2[1], true);
    drawColorTriangle(imgData, pD2, pA2, pN2, D2, A2, N2, pE2[1], false);
    ctx.putImageData(imgData, 0, 0);
  }

  void draw3(CanvasRenderingContext2D c){
    c.clearRect(0, 0, size, size);
    var imgData = c.createImageData(size, size);
    drawColorTriangle(imgData, pB3, pA3, pC3, B3, A3, C3, pC3[1], false);
    c.putImageData(imgData, 0, 0);
  }

  /**
   * Define the color of a point [p], calculated as the barycenter
   * of points [p1], [p2] and [p3].
   * Each of these three points have its color defined by RGB values.
   * Return a list of RGB values for [p].
   */
  colorAtPoint(List p, List p1, List p2, List p3,
               var r1, var g1, var b1,
               var r2, var g2, var b2,
               var r3, var g3, var b3){
    var alpha, beta, gamma;
    alpha = ((p[0]-p3[0])*(p2[1]-p3[1])-(p[1]-p3[1])*(p2[0]-p3[0]))/((p1[0]-p3[0])*(p2[1]-p3[1])-(p1[1]-p3[1])*(p2[0]-p3[0]));
    beta = ((p[0]-p3[0])-alpha*(p1[0]-p3[0]))/(p2[0]-p3[0]);
    gamma = 1-alpha-beta;
    int red = (alpha*r1 + beta*r2 + gamma*r3).round().toInt();
    int green = (alpha*g1 + beta*g2 + gamma*g3).round().toInt();
    int blue = (alpha*b1 + beta*b2 + gamma*b3).round().toInt();
    return [red, green, blue];
  }

  void drawSmallWiredCube(CanvasRenderingContext2D c){
    var size = 100;
    var diagSize = 40;
    var angle = PI/6;

    var xdiag = diagSize*cos(angle);
    var ydiag = diagSize*sin(angle);

    c.translate(c.canvas.width-size-diagSize-20, c.canvas.height-20);

    drawSmallWiredCubeIntersection(c, size, diagSize, angle);
    
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

  void drawSmallWiredCubeIntersection(CanvasRenderingContext2D c, int size, int diagSize, num angle){
    if (k <= 255){
      drawSmallWiredCubeIntersection1(c, size, diagSize, angle);
    } else if (k < 510){
      drawSmallWiredCubeIntersection2(c, size, diagSize, angle);
    } else {
      drawSmallWiredCubeIntersection3(c, size, diagSize, angle);
    }
  }

  void drawSmallWiredCubeIntersection1(CanvasRenderingContext2D c, int size, int diagSize, num angle){
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

  void drawSmallWiredCubeIntersection2(CanvasRenderingContext2D c, int size, int diagSize, num angle){
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

  void drawSmallWiredCubeIntersection3(CanvasRenderingContext2D c, int size, int diagSize, num angle){
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

  void pickColor(){
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
  Rectangle<num> clientBoundingRect;
  Future<ElementRect> futureRect;
  Function callback;

  ClickHandler(this.canvas, this.callback){
    clientBoundingRect = canvas.getBoundingClientRect();
    canvas.onClick.listen((e){
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
