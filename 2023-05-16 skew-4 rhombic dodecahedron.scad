//Шаг сетки для решётки из ромбододекаэдров (межцентровое расстояние)
MM_GRID_STEP = 20.0;

//диаметр отвертия (диаметр описанной окружности около многоугольника детализации)
//если диаметр = 0, то отверстий нет, 2.2 = диаметр зубочистки
MM_HOLE_DIAMETER = 2.2;

//true либо false параметр, показывающия исходный ромбододекаэдр без скоса
//для подсветки и разработки делай true, для 3Д-печати делай false
WILL_SHOW_CORE = false;

//показывать цвета
WILL_SHOW_COLOR = true;

//длина укороченной чёрной стороны (когда 1 - ось поворта по короткой диагонали)
//ось поворота - это граница цветов 
//синее море внизу и белое небо сверху на видео от Певницкого 15 мая
CUT_RATIO = 1;
//синее море внизу и белое небо сверху, если угол положительный
CUT_DEGREE = 10;

//такой n-угольник для детализации отверстия
HOLE_DETALISATION_IS_N_POLYGON = 24;


CUBE_SIDE = MM_GRID_STEP / sqrt(2);

//тетраэдр по четырём точкам, точка номер ноль - вершина
module m_tetrahedron(p4) {
    polyhedron(points=p4, faces=[[0,1,2],[0,2,3],[0,3,1],[3,2,1]]);
}

//пирамида с четырёхугольноком в основании, точка номер ноль - вершина
module m_p5_pyramid(p5) {
    polyhedron(points=p5, faces=[[0,1,2],[0,2,3],[0,3,4],[0,4,1],[4,3,2,1]]);
}

module m_p4_p5(p4_or_p5) {
    if (len(p4_or_p5) == 4) {m_tetrahedron(p4_or_p5);} else {m_p5_pyramid(p4_or_p5);}
}

//интерполирование по прямой с точками р0(ноль) и р1(один) любым вещественным числом
//массивы (три координаты) тоже можно складывать и умножать на число
function f_n01(p0, p1, n01) = ((p1 - p0) * n01) + p0;

//сумма массива с любым числом точек (рекурсивно)
function f_sum_recursion(array_p, my_result, i) =
    ((i>=len(array_p)) ?
        my_result :
        f_sum_recursion(array_p, my_result + array_p[i], i+1));

//сумма векторов, array_p[0] * 0 - нужно, чтобы получить необходимое число нулей [0,0,0]
function f_sum(array_p) = f_sum_recursion(array_p, array_p[0] * 0, 0);

//центр массива точек
function f_center(array_p) = f_sum(array_p) * (1 / len(array_p));

//синтаксис для переменных (в том числе, функциональных переменных)
function f_three_or_four_points_extend(p3_or_p4, my_scale = 1) =
    let (c = f_center(p3_or_p4))
    let (f = function (i) f_n01(c, p3_or_p4[i], my_scale))
(len(p3_or_p4)==3) ? [f(0), f(1), f(2)] : [f(0), f(1), f(2), f(3)];


function f_half_space(p3_or_p4, scale_triangle = 1, scale_pyramyd_ratio = 1) = 
    let (p3_or_p4 = f_three_or_four_points_extend(p3_or_p4, scale_triangle))
    let (scale_to_apex = scale_triangle * scale_pyramyd_ratio)
    let (p_apex = f_n01(f_center(p3_or_p4), [0,0,0], scale_to_apex))
    let (arr_3 = [p_apex, p3_or_p4[0], p3_or_p4[1], p3_or_p4[2]])
    let (arr_4 = [p_apex, p3_or_p4[0], p3_or_p4[1], p3_or_p4[2], p3_or_p4[3]])
(len(p3_or_p4)==3) ? arr_3 : arr_4;

PX = [2,0,0]; PY = [0,2,0]; PZ = [0,0,2]; MX = [-2,0,0]; MY = [0,-2,0]; MZ = [0,0,-2];
CX = [1,-1,-1]; CY = [-1,1,-1]; CZ = [-1,-1,1]; 
CXY = [1,1,-1]; CYZ = [-1,1,1]; CXZ = [1,-1,1];
CXYZ = [1,1,1]; CMMM = [-1,-1,-1];

//вершины граней против часовой стрелки, если смотреть снаружи
face_0 = [PX, CXZ, PZ, CXYZ]; tip_0 = 1;
face_1 = [PZ, CYZ, PY, CXYZ]; tip_1 = 1;
face_2 = [MX, CYZ, PZ, CZ]; tip_2 = 1;
face_3 = [PZ, CXZ, MY, CZ]; tip_3 = 1;

face_4 = [MX, CMMM, MZ, CY]; tip_4 = 1;
face_5 = [MZ, CMMM, MY, CX]; tip_5 = 1;
face_6 = [PX, CXY, MZ, CX]; tip_6 = 1;
face_7 = [MZ, CXY, PY, CY]; tip_7 = 1;

face_8 = [PY, CXY, PX, CXYZ]; tip_8 = 3;
face_9 = [PY, CYZ, MX, CY]; tip_9 = 3;
face_10 = [MY, CMMM, MX, CZ]; tip_10 = 3;
face_11 = [MY, CXZ, PX, CX]; tip_11 = 3;

tip_indexes_all = [tip_0, tip_1, tip_2, tip_3, tip_4, tip_5, tip_6, tip_7, tip_8, tip_9, tip_10, tip_11];
face_all = [face_0, face_1, face_2, face_3, face_4, face_5, face_6, face_7, face_8, face_9, face_10, face_11];
function f_face_i12_i4(i12, i4) = face_all[i12][(i4 + 4 - tip_indexes_all[i12]) % 4];
function f_face_i12(i) = [f_face_i12_i4(i,0), f_face_i12_i4(i,1), f_face_i12_i4(i,2), f_face_i12_i4(i,3)];

module m_face(i_face, scale_triangle = 1, scale_pyramyd_ratio = 1) {
    p4 = f_face_i12(i_face);
    
    p_rhombus = [p4[0], p4[1], p4[2], p4[3]];
    
    m_p4_p5(f_half_space(p_rhombus, scale_triangle, scale_pyramyd_ratio)); 
}

function f_axis(p4, my_ratio = CUT_RATIO) = [f_n01(p4[0], p4[1], my_ratio), f_n01(p4[2], p4[3], my_ratio)];

module m_my_rotation_on_axis(i_face, a_deg = CUT_DEGREE, my_ratio = CUT_RATIO) {
    ab = f_axis(f_face_i12(i_face), my_ratio);
    translate(ab[1])
        rotate(a = a_deg, v = ab[1] - ab[0])
            translate(ab[1] * (-1))
                children();
} 
 
module m_rotated_face(i_face, a_deg = CUT_DEGREE, my_ratio = CUT_RATIO) {
    m_my_rotation_on_axis(i_face, a_deg, my_ratio)
        m_face(i_face, 8, 1);
}

ARR_COLORS = 
[[0.5,0,0],[0.5,0,0],[0.5,0,0],[0.5,0,0],
[0,0.5,0],[0,0.5,0],[0,0.5,0],[0,0.5,0],
[1,1,0],[1,1,0],[1,1,0],[1,1,0]];

module m_12_faces(will_show_not_rotated_core = WILL_SHOW_CORE, cut_ratio = CUT_RATIO, cut_degree = CUT_DEGREE) {
    intersection_for(n = [0 : 11]){
        if (WILL_SHOW_COLOR) {
            color(ARR_COLORS[n])
                hull() m_rotated_face(n, cut_degree, cut_ratio);
        }
        else
            hull() m_rotated_face(n, cut_degree, cut_ratio);
    }
    
    if (will_show_not_rotated_core)
    #rotate(0){
        m_face(0);m_face(1);m_face(2);m_face(3);
        m_face(4);m_face(5); m_face(6);m_face(7);
        m_face(8);m_face(9);m_face(10);m_face(11);
    }
}


module m_cylinder(rotate_axe=[0,0,1], rotate_deg=45, d=MM_HOLE_DIAMETER, half_h=(MM_GRID_STEP * 0.5) * 4.2) {
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

module m_final(cut_ratio, cut_degree, xyz_n_step = [0,0,0], show_core = WILL_SHOW_CORE) {
    translate(v = xyz_n_step * MM_GRID_STEP)    
        rotate(a = 45, v=[1,0,0])
            m_my_rotation_on_axis(5, -CUT_DEGREE)
            difference () {
                scale (CUBE_SIDE / 2) m_12_faces(show_core, cut_ratio, cut_degree);
                m_all_cylinders();
            }
}

//[1.0 - 0.75], [45 - 15]
//m_final(1 - (1-$t) * 0.25 * 0, 0 + $t*45);

m_final(CUT_RATIO, CUT_DEGREE);
