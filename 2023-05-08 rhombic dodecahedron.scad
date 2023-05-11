/*
Ромбический додекаэдр + сквозные отверстия для креплений.
С настраиваемыми параметрами в программе OpenSCAD.

Программист: Полозков Сергей.
Смена в Сириусе "самозаклинивающиеся структуры" в 2023 году.
*/

//Шаг сетки для решётки из ромбододекаэдров (межцентровое расстояние)
MM_GRID_STEP = 20.0;

//диаметр отвертия (диаметр описанной окружности около многоугольника детализации)
//если диаметр = 0, то отверстий нет, 2.2 = диаметр зубочистки
MM_HOLE_DIAMETER = 2.2;

//такой n-угольник для детализации отверстия
HOLE_DETALISATION_IS_N_POLYGON = 24;


CUBE_SIDE = MM_GRID_STEP / sqrt(2);

module m_square_pyramid(square_side = CUBE_SIDE, dz = 0, pyramid_height = CUBE_SIDE * 0.5) {
    translate([0,0,dz])
        rotate(45)
            cylinder(h = pyramid_height, r1 = square_side * 0.5 * sqrt(2), r2 = 0, $fn = 4);
}

module m_two_pyramids(square_side = CUBE_SIDE) {
    hull() {
        m_square_pyramid(square_side, square_side * 0.5, square_side * 0.5);
        mirror(v = [0,0,1])
            m_square_pyramid(square_side, square_side * 0.5, square_side * 0.5);
    }
}

module m_cylinder(rotate_axe=[0,0,1], rotate_deg=45, d=MM_HOLE_DIAMETER, half_h=(MM_GRID_STEP * 0.5) * 1.1) {
    rotate (a=rotate_deg, v=rotate_axe)
        cylinder(h=half_h*2, d=d, center=true, $fn=HOLE_DETALISATION_IS_N_POLYGON);
}

module m_all_cylinders() {
    if (MM_HOLE_DIAMETER > 0) {
        m_cylinder([+1,0,0], +45); m_cylinder([+1,0,0], -45); 
        m_cylinder([0,+1,0], +45); m_cylinder([0,+1,0], -45);
        m_cylinder([+1,+1,0], 90); m_cylinder([+1,-1,0], 90);
    }
}

module m_ball_12_with_no_holes() {
    hull() {
        rotate ([90,0,0]) m_two_pyramids();
        rotate ([0,90,0]) m_two_pyramids();
        rotate ([0,0,90]) m_two_pyramids();
    }
}

rotate(a = 45, v=[1,0,0])
    difference () {
        m_ball_12_with_no_holes();
        m_all_cylinders();
    }