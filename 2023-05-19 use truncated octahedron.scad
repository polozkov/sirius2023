//Шаг сетки для решётки из усечённых октаэдров (межцентровое расстояние)
MM_GRID_STEP = 20;
//диаметр отвертия (диаметр описанной окружности около многоугольника детализации)
//если диаметр = 0, то отверстий нет, 2.2 = диаметр зубочистки
MM_HOLE_DIAMETER = 2.2;

//true либо false параметр, показывающия исходный ромбододекаэдр без скоса
//для подсветки и разработки делай true, для 3Д-печати делай false
WILL_SHOW_CORE = false;
//показывать цвета
WILL_SHOW_COLOR = true;
//надо ли класть фигуру на шестиугольную грань?
WILL_PUT_ON_FACE = true;
//true - показать несколько элементов, false - показать один элемент 
WILL_SHOW_GRID_NOT_UNIT_ELEMENT = false;

//ось поворота - это граница цветов 
CUBE_AND_OCTAHEDRON_CUT_RATIO = [0.5, 1.0];
//синее море внизу и белое небо сверху, если угол положительный
CUBE_AND_OCTAHEDRON_CUT_DEGREE = [10, 10];

//такой n-угольник для детализации отверстия
HOLE_DETALISATION_IS_N_POLYGON = 24;


//ДАЛЬШЕ НИЧЕГО НЕ МЕНЯТЬ, НЕ ПРОКОНСУЛЬТИРОВАВШИСЬ 
//С Полозковым Серегеем Сергеевичем
dihedral_angle_hex_square = -acos(-sqrt(3)/3);
//грани, которы надо показывать
ARR_SHOW_FACES = [0,1,2,3,4,5, 6,7,8,9,10,11,12,13];
SELECTED_BASE_FACE = 11;

//определим тип оси поворота, (квадратная или шестиугольная грань)
function f_cut_ratio(i_face, cut_pair_ratio = CUBE_AND_OCTAHEDRON_CUT_RATIO) = cut_pair_ratio[(ARR_SHOW_FACES[i_face] < 6) ? 0 : 1];
//определим тип угла поворота, (квадратная или шестиугольная грань)
function f_cut_degree(i_face, cut_pair_degree = CUBE_AND_OCTAHEDRON_CUT_DEGREE) = cut_pair_degree[(ARR_SHOW_FACES[i_face] < 6) ? 0 : 1];

//пирамида по всем вершинам, точка номер ноль - апексная вершина
module m_pyramid(apex_and_base) {
    p3 = [[0,1,2],[0,2,3],[0,3,1],[3,2,1]];
    p4 = [[0,1,2],[0,2,3],[0,3,4],[0,4,1],[4,3,2,1]];
    p5 = [[0,1,2],[0,2,3],[0,3,4],[0,4,5],[0,5,1],[5,4,3,2,1]];
    p6 = [[0,1,2],[0,2,3],[0,3,4],[0,4,1],[0,5,6],[0,6,1],[6,5,4,3,2,1]];
    faces_arr = [p3,p4,p5,p6];
    faces_indexes = faces_arr[len(apex_and_base) - 4];
    polyhedron(points=apex_and_base, faces=faces_indexes);
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
//my_scale - во сколько раз раздувать (масштабировать)
function f_polygon_extend(any_polygon, my_scale) =
    //центр тяжести треугольника или четырёх точек
    let (c = f_center(any_polygon))
    //функцция раздувания трёх или четырёх точек с сохранением чентра тяжести
    let (f = function (i) f_n01(c, any_polygon[i % len(any_polygon)], my_scale))
    let (p3 = [f(0), f(1), f(2)])
    let (p4 = [f(0), f(1), f(2), f(3)])
    let (p5 = [f(0), f(1), f(2), f(3), f(4)])
    let (p6 = [f(0), f(1), f(2), f(3), f(4), f(5)])
    let (p_any = [p3, p4, p5, p6])
p_any[len(any_polygon) - 3];

//полупространство как треугольная или четырёхугольная пирамида
//берём основание и строим пирамиду с вершиной в нуле
//раздуваем основание; если scale_pyramid_ratio = 1, то сохраняем пропорции
//если scale_pyramid_ratio = 2, то вытягиваем пирамиду по высоте в два раза
function f_half_space(old_base, scale_base, scale_pyramid_ratio) =
    //раздутое основание
    let (new_base = f_polygon_extend(old_base, scale_base))
    //вершина пирамиды
    let (p_apex = f_n01(f_center(old_base), [0,0,0], scale_base * scale_pyramid_ratio))
concat([p_apex], new_base);

//координаты вершин усечённого октаэдра
X_Y = [2,1,0]; X_y = [2,-1,0]; X_Z = [2,0,1]; X_z = [2,0,-1];
x_Y = [-2,1,0]; x_y = [-2,-1,0]; x_Z = [-2,0,1]; x_z = [-2,0,-1];
Y_X = [1,2,0]; Y_x = [-1,2,0]; Y_Z = [0,2,1]; Y_z = [0,2,-1];
y_X = [1,-2,0]; y_x = [-1,-2,0]; y_Z = [0,-2,1]; y_z = [0,-2,-1];
Z_X = [1,0,2]; Z_x = [-1,0,2]; Z_Y = [0,1,2]; Z_y = [0,-1,2];
z_X = [1,0,-2]; z_x = [-1,0,-2]; z_Y = [0,1,-2]; z_y = [0,-1,-2];

//вершины каждой грани по часовой стрелке, если смотреть снаружи
//СУММА ПРОТИВОПОЛОЖНЫХ ГРАНЕЙ = 11
//tip - солнце (к какой вершине повёрнута верхняя часть плоскости сечения)

//грани куба по положительным направлениям осей XYZ
face_0 = [X_Z, X_Y, X_z, X_y]; tip_0 = 0;
face_1 = [Y_X, Y_Z, Y_x, Y_z]; tip_1 = 0;
face_2 = [Z_Y, Z_X, Z_y, Z_x]; tip_2 = 0;
//грани куба по отрицательным направлениям осей XYZ
face_3 = [x_y, x_z, x_Y, x_Z]; tip_3 = 0;
face_4 = [y_z, y_x, y_Z, y_X]; tip_4 = 0;
face_5 = [z_x, z_y, z_X, z_Y]; tip_5 = 0;
//четыре грани октаэдра с положительными Х-координатами
face_6 = [Y_X, X_Y, X_Z, Z_X, Z_Y, Y_Z]; tip_6 = 0;
face_7 = [z_X, X_z, X_Y, Y_X, Y_z, z_Y]; tip_7 = 0;
face_8 = [y_X, X_y, X_z, z_X, z_y, y_z]; tip_8 = 0;
face_9 = [Z_X, X_Z, X_y, y_X, y_Z, Z_y]; tip_9 = 0;
//четыре грани октаэдра с отрицательными Х-координатами
face_10 = [z_x, x_z, x_y, y_x, y_z, z_y]; tip_10 = 0;
face_11 = [Y_x, x_Y, x_z, z_x, z_Y, Y_z]; tip_11 = 0;
face_12 = [Z_x, x_Z, x_Y, Y_x, Y_Z, Z_Y]; tip_12 = 0;
face_13 = [y_x, x_y, x_Z, Z_x, Z_y, y_Z]; tip_13 = 0;

//массивы кончиков стрелок, указывающих наверх (на солнце)
tip_indexes_all = [tip_0, tip_1, tip_2, tip_3, tip_4, tip_5, tip_6, tip_7, tip_8, tip_9, tip_10, tip_11, tip_12, tip_13];
face_all = [face_0, face_1, face_2, face_3, face_4, face_5, face_6, face_7, face_8, face_9, face_10, face_11, face_12, face_13];

function f_face_iALL(i) = face_all[i];

module m_face(i_face, scale_triangle, scale_pyramid_ratio) {
    p_base_polygon = f_face_iALL(i_face);
    m_pyramid(f_half_space(p_base_polygon, scale_triangle, scale_pyramid_ratio));
}

function f_axis_p4(p4, my_ratio) = [f_n01(p4[0], p4[1], my_ratio), f_n01(p4[2], p4[3], my_ratio)];
function f_star_of_david(p6, i_a, i_b) = let (c = f_center(p6)) p6[i_a] + p6[i_b] - c;
function f_axis_p6(p6, my_ratio) = f_axis_p4([p6[0], f_star_of_david(p6,1,2), p6[3], f_star_of_david(p6,4,5)], my_ratio);
function f_axis(p4_or_p6, my_ratio) = (len(p4_or_p6) == 4) ? f_axis_p4(p4_or_p6, my_ratio) : f_axis_p6(p4_or_p6, my_ratio);

module m_my_rotation_on_axis(i_face, cut_pair_ratio, cut_pair_degree, sign_rotation = 1) {
    base_polygon = f_face_iALL(i_face);
    ab = f_axis(base_polygon, f_cut_ratio(i_face, cut_pair_ratio));
    translate(ab[1])
        rotate(a = f_cut_degree(i_face, cut_pair_degree) * sign_rotation, v = ab[1] - ab[0])
            translate(ab[1] * (-1))
                children();
    if (i_face == SELECTED_BASE_FACE) {
        echo("m_my_rotation_on_axis", base_polygon,  SELECTED_BASE_FACE);
        echo("m_my_rotation_on_axis", cut_pair_ratio, ab);
        }
}

module m_rotated_face(i_face, cut_pair_ratio, cut_pair_degree) {
    if (i_face == SELECTED_BASE_FACE) {
        echo("m_rotated_face", cut_pair_ratio);
    }
    m_my_rotation_on_axis(i_face, cut_pair_ratio, cut_pair_degree)
        m_face(i_face, 8, 1);
}


B = [0,0,0.7]; W = [1,1,1];
ARR_COLORS = 
[[0.5,0,0],[0.5,0,0],[0.5,0,0], [1,1,0],[1,1,0],[1,1,0], //012345
 B,B,B,B, W,"Green",W,W]; //6789 10 11 12 13


module m_ALL_faces(will_show_not_rotated_core, cut_pair_ratio, cut_pair_degree) {
    echo("m_ALL_faces", cut_pair_ratio, cut_pair_degree);
    intersection_for(n = ARR_SHOW_FACES){
        if (WILL_SHOW_COLOR) {
            color(ARR_COLORS[n]) 
                hull() m_rotated_face(n, cut_pair_ratio, cut_pair_degree);
        }
        else 
            hull() m_rotated_face(n, cut_pair_ratio, cut_pair_degree);
    }
    
    if (will_show_not_rotated_core)
        #for(tn = ARR_SHOW_FACES) {
            m_face(tn, 1, 1);
    }
}

module m_cylinder(rotate_axe=[0,0,1], rotate_deg=45, d=MM_HOLE_DIAMETER, half_h=(MM_GRID_STEP * 0.5) * 4.2) {
    rotate (a=rotate_deg, v=rotate_axe)
        cylinder(h=half_h*2, d=d, center=true, $fn=HOLE_DETALISATION_IS_N_POLYGON);
}

module m_all_cylinders() {
    deg = 180 - dihedral_angle_hex_square;
    
    if (MM_HOLE_DIAMETER > 0) {
        m_cylinder([1,0,0], 90);
        m_cylinder([0,1,0], 90);
        m_cylinder([0,0,1], 90);
         
        m_cylinder([1,1,0], deg);
        m_cylinder([1,1,0], -deg);
        m_cylinder([1,-1,0], deg);
        m_cylinder([1,-1,0], -deg);
    }
}

module m_difference_for_holes(show_core = WILL_SHOW_CORE, signes = [1,1], cut_pair_ratio = CUBE_AND_OCTAHEDRON_CUT_RATIO, cut_pair_degree = CUBE_AND_OCTAHEDRON_CUT_DEGREE) {            
    signed_degree = [cut_pair_degree[0]*signes[0],cut_pair_degree[1]*signes[1]];
    echo("m_difference_for_holes", "SIGNEG_DEGREE", signed_degree);
    difference () {       
        scale ((MM_GRID_STEP / 2) / 2) 
            m_ALL_faces(show_core, cut_pair_ratio, signed_degree);
        m_all_cylinders();   
    }
}

//===========================================

module m_final(cut_pair_ratio = CUBE_AND_OCTAHEDRON_CUT_RATIO, cut_pair_degree = CUBE_AND_OCTAHEDRON_CUT_DEGREE, show_core = WILL_SHOW_CORE) {
    echo("m_final", cut_pair_ratio, cut_pair_degree);
    
    rotate(v = [1,1,0], a = 180 - dihedral_angle_hex_square)
        m_my_rotation_on_axis(SELECTED_BASE_FACE, cut_pair_ratio, cut_pair_degree, -1) 
            m_difference_for_holes(show_core, [1,1], cut_pair_ratio, cut_pair_degree);
    
    echo("m_final", SELECTED_BASE_FACE);
    echo("m_final", cut_pair_ratio);
}


module m_element(n_xyz, rot_vector, rot_angle, sign_pair) {
    translate(n_xyz * MM_GRID_STEP)
        rotate(a = rot_angle, v = rot_vector)
            m_difference_for_holes(false, sign_pair);
}

module m_grid(arr__shift_rotationV_rotationA_signPair) {
    t = arr__shift_rotationV_rotationA_signPair;
    for (i = [0 : len(t) - 1])
        m_element(t[i][0], t[i][1], t[i][2], t[i][3]);
};

t_gap = 1.3;
grid_definition = [
    [[0,0,0]*t_gap,[0,0,1],0,[1,1]],
    [[1,0,0]*t_gap,[0,0,1],0,[-1,1]],
    [[0,1,0]*t_gap,[0,0,1],0,[1,-1]],
    [[1,1,0]*t_gap,[0,0,1],0,[-1,-1]]
];

//rotate(15) translate([0,0, -MM_GRID_STEP]) cube(size = [MM_GRID_STEP, MM_GRID_STEP, MM_GRID_STEP], center = true);
if (WILL_SHOW_GRID_NOT_UNIT_ELEMENT) m_grid(grid_definition); else m_final();