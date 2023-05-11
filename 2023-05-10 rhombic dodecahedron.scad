/*
Ромбический додекаэдр + крепления.
С настраиваемыми параметрами в программе OpenSCAD.

Программист: Полозков Сергей.
Смена в Сириусе "самозаклинивающиеся структуры" в 2023 году.
*/

//Шаг сетки для решётки из ромбододекаэдров (межцентровое расстояние)
MM_GRID_STEP = 20.0;

//глубина штырька
MM_RHOMBUS_DEPTH = 4.0;
MM_RHOMBUS_INSCRIBE_DIAMETER = 6.0;

//диаметр отвертия (диаметр описанной окружности около многоугольника детализации)
//если диаметр = 0, то отверстий нет, 2.2 = диаметр зубочистки
MM_HOLE_DIAMETER = 2.2;

//такой n-угольник для детализации крепления
HOLE_DETALISATION_IS_N_POLYGON = 24;


CUBE_SIDE = MM_GRID_STEP / sqrt(2);

module m_square_pyramid(square_side = CUBE_SIDE, dz = 0, pyramid_height = CUBE_SIDE * 0.5) {
    translate([0,0,dz])
        rotate(45)
            cylinder(h = pyramid_height, r1 = square_side * 0.5 * sqrt(2), r2 = 0, $fn = 4);
}

module m_rhombus(square_side = CUBE_SIDE, h_depth = MM_RHOMBUS_DEPTH, d_inscribe_in_rhombus = MM_RHOMBUS_INSCRIBE_DIAMETER, h_extra = 1) {
    p4 = [[0,sqrt(2)],[1,0],[0,-sqrt(2)],[-1,0]];
    inscribe_circle_scale = d_inscribe_in_rhombus / 2 / sqrt(2/3);
    
    translate([0,0,square_side / sqrt(2) - h_depth])
        scale([ inscribe_circle_scale,  inscribe_circle_scale, h_depth + h_extra])
             linear_extrude(height = 1, center = false)
                 polygon(p4);
    
    //sphere(d = d_inscribe_in_rhombus, $fn = 60);
}

module m_cylinder_connector(square_side = CUBE_SIDE, h_depth = MM_RHOMBUS_DEPTH, d_inscribe_in_rhombus = MM_RHOMBUS_INSCRIBE_DIAMETER, h_extra = 1) {
    p4 = [[0,sqrt(2)],[1,0],[0,-sqrt(2)],[-1,0]];
    inscribe_circle_scale = d_inscribe_in_rhombus / 2 / sqrt(2/3);
    
    translate([0,0,square_side / sqrt(2) - h_depth])
        scale([ inscribe_circle_scale,  inscribe_circle_scale, h_depth + h_extra])
             linear_extrude(height = 1, center = false)
                 polygon(p4);
    
    //sphere(d = d_inscribe_in_rhombus, $fn = 60);
}

module m_rhombus_rotate(rotate_axe=[0,0,1], rotate_deg=90) {
    rotate(a = rotate_deg, v = rotate_axe)
        m_rhombus();
}

module m_11_rhombus() {
    //m_rhombus_rotate([1,0,0], 0);
    m_rhombus_rotate([1,0,0], 90);
    m_rhombus_rotate([1,0,0], -90);
    m_rhombus_rotate([1,0,0], 180);
    
    m_rhombus_rotate([0,1,1], 90);
    m_rhombus_rotate([0,1,1], -90);
    m_rhombus_rotate([0,-1,1], 90);
    m_rhombus_rotate([0,-1,1], -90);
    
    rotate(a = 90, v = [0,1,1]) m_rhombus_rotate([1,0,0], 180);
    rotate(a = -90, v = [0,1,1]) m_rhombus_rotate([1,0,0], 180);
    rotate(a = 90, v = [0,-1,1]) m_rhombus_rotate([1,0,0], 180);
    rotate(a = -90, v = [0,-1,1]) m_rhombus_rotate([1,0,0], 180);
}

//m_rhombus_rotate([0,0,1], 0);




module m_two_pyramids(square_side = CUBE_SIDE) {
    hull() {
        m_square_pyramid(square_side, square_side * 0.5, square_side * 0.5);
        mirror(v = [0,0,1])
            m_square_pyramid(square_side, square_side * 0.5, square_side * 0.5);
    }
}


module m_ball_12_with_no_holes() {
    hull() {
        rotate ([90,0,0]) m_two_pyramids();
        rotate ([0,90,0]) m_two_pyramids();
        rotate ([0,0,90]) m_two_pyramids();
    }
}

difference() {
    rotate(a = 45, v=[1,0,0]) m_ball_12_with_no_holes();
    m_11_rhombus();
}