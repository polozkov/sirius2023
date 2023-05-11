/*
Элемент самозаклинивающейся структуры Канель-Белова.
Скошенный по шести граням куб + сквозные отверстия для креплений.
С настраиваемыми параметрами в программе OpenSCAD.

Программист: Полозков Сергей.
Смена в Сириусе "самозаклинивающиеся структуры" в 2023 году.
*/

//Шаг сетки (межцентровое расстояние)
STEP_GRID = 20;

//угол для грани (наклон по диагонали)
DEG = 20;

//такой n-угольник для детализации отверстия
HOLE_DETALISATION = 24;

//диаметр отвертия (диаметр описанной окружности около многоугольника детализации)
//если диаметр = 0, то отверстий нет, 2.2 = диаметр зубочистки
HOLE_DIAMETR = 2.2;



//50% of grid cube side
HALF = STEP_GRID * 0.5;

//auxiliary variables (for correct cutting)
SCALE_FOR_CORE = 6;
SIZES_EXTRA = [HALF * SCALE_FOR_CORE, HALF * SCALE_FOR_CORE, HALF * SCALE_FOR_CORE];
BIG = HALF * 20;

//orts for 6 directions
P_X = [1,0,0]; M_X = [-1,0,0]; 
P_Y = [0,1,0]; M_Y = [0,-1,0];
P_Z = [0,0,1]; M_Z = [0,0,-1];

//three cyliners for holes for connection
module m_cross_holes(fn = HOLE_DETALISATION, d = HOLE_DIAMETR, half_h_total = STEP_GRID) {
    if (HOLE_DIAMETR > 0) {
        rotate([90,0,0]) cylinder(h = half_h_total * 2, d = d, $fn = fn, center = true);
        rotate([0,90,0]) cylinder(h = half_h_total * 2, d = d, $fn = fn, center = true);
        rotate([0,0,90]) cylinder(h = half_h_total * 2, d = d, $fn = fn, center = true);
    }
}

//rotated and translated (shifted) cube, that cut face of core cube
module m_cube(rotate_v = [1,1,0], rotate_a = 20, ORT = [0, 0, 1]) {
    dx = ORT[0]; dy = ORT[1]; dz = ORT[2];
    
    //center of the rotation line segment is equal cutting face
    translate(v = [dx * HALF, dy * HALF, dz * HALF])
        //rotate on axe this cutting face (on the big cube)
        rotate (v = rotate_v, a = rotate_a)
            //make big cube's face on zero level
            translate(v = [dx * BIG  / 2, dy * BIG  / 2, dz * BIG  / 2])  
                cube ([BIG, BIG, BIG], center = true);
}

//cut 6 faces of the core cube
module m_element(CENTER = [0,0,0], rotate_a = 0, rotate_v = [0,0,1], DEG = DEG) {
    translate ([CENTER[0] * HALF * 2, CENTER[1] * HALF * 2, CENTER[2] * HALF * 2])
        rotate (v = rotate_v, a = rotate_a)
            difference () {
                cube (SIZES_EXTRA, center = true);
                
                //cut ooposite faces
                m_cube([1,1,0], -DEG, P_Z); m_cube([1,1,0], DEG, M_Z);
                m_cube([0,1,1], -DEG, P_X); m_cube([0,1,1], DEG, M_X);
                m_cube([1,0,1], -DEG, P_Y);  m_cube([1,0,1], DEG, M_Y);
                
                m_cross_holes();
           }
}

rotate (v = [1,1,0], a = -DEG)
    m_element();
