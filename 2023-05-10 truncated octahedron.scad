/*
Усечённый октаэдр с отверстиями для креплений
С настраиваемыми параметрами в программе OpenSCAD.

Программист: Полозков Сергей.
Смена в Сириусе "самозаклинивающиеся структуры" в 2023 году.
*/

//Шаг сетки для решётки из усечённого октаэдра (межцентровое расстояние)
MM_GRID_STEP = 20.0;


//диаметр отвертия (диаметр описанной окружности около многоугольника детализации)
//если диаметр = 0, то отверстий нет, 2.2 = диаметр зубочистки
MM_HOLE_DIAMETER = 2.2;


//такой n-угольник для детализации крепления
HOLE_DETALISATION_IS_N_POLYGON = 24;


module m_square_pyramid_with_zero_apex_point(half = MM_GRID_STEP * 0.25, h = MM_GRID_STEP * 0.5) {
polyhedron(
  points=[ [half,0,h],[0,-half,h],[-half,-0,h],[0,half,h], // the four points at base
           [0,0,0]  ],                                 // the apex point 
  faces=[ [0,1,4],[1,2,4],[2,3,4],[3,0,4],              // each triangle side
              [0,1,2,3] ]                         //square base
 );
}

module m_square_pyramid_rotate(v = [0,0,1], a = 0) {
    rotate(v=v, a=a)
        m_square_pyramid_with_zero_apex_point();
}

module m_cylinder(rotate_axe=[0,0,1], rotate_deg=0, d=MM_HOLE_DIAMETER, half_h=(MM_GRID_STEP * 0.5) * 1.1) {
    rotate (a=rotate_deg, v=rotate_axe)
        cylinder(h=half_h*2, d=d, center=true, $fn=HOLE_DETALISATION_IS_N_POLYGON);
}


module m_all_cylinders() {
    deg = 180 - acos(-sqrt(3)/3);
    
    if (MM_HOLE_DIAMETER > 0) {
        union() {
            m_cylinder([0,+1,0], 090);
            m_cylinder([0,+1,0], 270);
        
            m_cylinder([+1,0,0], 000);
            m_cylinder([+1,0,0], 090);
            m_cylinder([+1,0,0], 180);
            m_cylinder([+1,0,0], 270);
        
  
            m_cylinder([+1,+1,0], +deg);
            m_cylinder([+1,+1,0], -deg);
            m_cylinder([+1,-1,0], +deg);
            m_cylinder([+1,-1,0], -deg);
        }
    }
}

module m_truncated_octahedron() {
    hull() {
        m_square_pyramid_rotate([0,1,0],090);
        m_square_pyramid_rotate([0,1,0],270);
    
        m_square_pyramid_rotate([1,0,0],000);
        m_square_pyramid_rotate([1,0,0],090);
        m_square_pyramid_rotate([1,0,0],180);
        m_square_pyramid_rotate([1,0,0],270);
    }
}

difference() {
    m_truncated_octahedron();
    m_all_cylinders();
}