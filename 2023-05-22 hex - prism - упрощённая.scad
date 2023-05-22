//Шаг сетки для решётки из усечённых октаэдров (межцентровое расстояние)
MM_GRID_HEX_STEP = 20; //тогда сторона шестиугольника = MM_GRID_HEX_STEP / КОРЕНЬ(3)
MM_GRIG_TOP_STEP_ON_Y_COORDINATE = MM_GRID_HEX_STEP / sqrt(3) * 2;

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

//ДАЛЬШЕ НИЧЕГО НЕ МЕНЯТЬ, НЕ ПРОКОНСУЛЬТИРОВАВШИСЬ 
//С Полозковым Серегеем Сергеевичем
//такой n-угольник для детализации отверстия
HOLE_DETALISATION_IS_N_POLYGON = 24;
//грани, которы надо показывать
ARR_SHOW_FACES = [0,1,2,3,4,5];
BIG = (MM_GRID_HEX_STEP + MM_GRIG_TOP_STEP_ON_Y_COORDINATE) * 10;

//как срезаем боковые грани призмы (0.5 - ось по средней линии)
C_CUT_RATIO = 0.5;
//меняем знаки углов наклонов
SIGNES_DEGREE = [1, -1, 1, -1, 1, -1];
//срезаем боковые грани призмы на этот угол
C_CUT_DEGREE = 10;

//срезаем шетиугольны грани призмы на этот угол (верхнюю и нижнюю)
C_HEX_CUT_DEGREE = 10;
//ecли знаки разные, то срезаем параллельноб; если одинаковые, то сходятся 
SIGNES_HEX_DEGREE = [1, 1]; 
//поворот по вертикальной плоскости (от 0 до 360) отси наклона
C_HEX_CUT_DEGREE_Z_ROTATE = 30;

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

function f_sum_3(p) = p[0] + p[1] + p[2];
function f_sum_4(p) = f_sum_3(p) + p[3];
function f_sum_6(p) = f_sum_4(p) + p[4] + p[5];
function f_sum(p) = let (L=len(p)) (L == 6) ? f_sum_6(p) : (L == 4) ? f_sum_4(p) : f_sum_3(p);

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

//координаты вершин призмы
S60 = sin(60);
function f60(i, h_sign = 1) = let (ratio_hex = MM_GRID_HEX_STEP / sqrt(3))
    [cos(i*60) * ratio_hex, sin(i*60) * ratio_hex, h_sign * MM_GRIG_TOP_STEP_ON_Y_COORDINATE / 2]; 
function f6(i) = [f60(i), f60(i,-1), f60(i+1,-1),f60(i+1)];
face_6 = [f60(0),f60(1),f60(2), f60(3),f60(4),f60(5)];
face_7 = [f60(0,-1),f60(1,-1), f60(2,-1),f60(3,-1),f60(4,-1),f60(5,-1)];
face_all = [f6(0), f6(1), f6(2), f6(3), f6(4), f6(5), face_6, face_7];

function f_face_iALL(i) = face_all[i];

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



module m_face(i_face, scale_triangle, scale_pyramid_ratio) {
    p_base_polygon = f_face_iALL(i_face);
    m_pyramid(f_half_space(p_base_polygon, scale_triangle, scale_pyramid_ratio));
}

function f_axis(p4, my_ratio) = [f_n01(p4[0], p4[1], my_ratio), f_n01(p4[2], p4[3], my_ratio)];


module m_my_rotation_on_ab_and_degree(ab, degree) {
    translate(ab[1])
        rotate(a = degree, v = ab[1] - ab[0])
            translate(ab[1] * (-1))
                children();
}

module m_my_rotation_on_axis(i_face, cut_ratio, cut_degree, sign_rotation = 1) {
    ab = f_axis(f_face_iALL(i_face), cut_ratio);
    m_my_rotation_on_ab_and_degree(ab, cut_degree * sign_rotation)
        children();
}

module m_rotated_face(i_face, cut_ratio, cut_degree) {
    m_my_rotation_on_axis(i_face, cut_ratio, cut_degree * SIGNES_DEGREE[i_face])
        m_face(i_face, 8, 1);
}

ARR_COLORS = 
["Red","Orange","Yellow","Green","Cyan","Blue", "White", "Black"];


module m_ALL_faces(will_show_not_rotated_core, cut_ratio, cut_degree) {
    intersection_for(n = ARR_SHOW_FACES){
        if (WILL_SHOW_COLOR) {
            color(ARR_COLORS[n]) 
                hull() m_rotated_face(n, cut_ratio, cut_degree);
        }
        else 
            hull() m_rotated_face(n, cutratio, cut_degree);
    }
    
    if (will_show_not_rotated_core)
        #for(tn = ARR_SHOW_FACES) {
            m_face(tn, 1, 1);
    }
}

module m_x_cylinder(a_z = 0, d=MM_HOLE_DIAMETER, half_h=(max(MM_GRIG_TOP_STEP_ON_Y_COORDINATE, MM_GRID_HEX_STEP) * 0.5) * 4.2) {
    rotate (a_z)
        rotate ([90,0,0])
            cylinder(h=half_h*2, d=d, center=true, $fn=HOLE_DETALISATION_IS_N_POLYGON);
}

module m_all_cylinders() {
    if (MM_HOLE_DIAMETER > 0) {
        m_x_cylinder();
        m_x_cylinder(60);
        m_x_cylinder(-60);
        rotate ([-90,0,0])
            m_x_cylinder();
    }
}

module m_top_bottom_cover(half_h) {
    p4 = [[0,0,-BIG], [BIG,BIG,half_h], [BIG,-BIG,half_h], [-BIG,-BIG,half_h], [-BIG,BIG,half_h]];
    hull()
        m_pyramid(p4);
}
module m_top_bottom(half_h, degree_on_z, degree_cut, is_reflex) {
    ab = [[0,0,half_h], [0,1,half_h]];
    rotate (degree_on_z)
        mirror(is_reflex ? [0,0,1] : [0,1,0]) 
            m_my_rotation_on_ab_and_degree(ab, degree_cut)
                m_top_bottom_cover(half_h);
}

module m_difference_for_holes(show_core = WILL_SHOW_CORE, cut_ratio = C_CUT_RATIO, cut_degree = C_CUT_DEGREE) { 
    half_h = MM_GRIG_TOP_STEP_ON_Y_COORDINATE / 2;
    ab_bottom = [[0,0,-half_h], [cos(C_HEX_CUT_DEGREE_Z_ROTATE + 90), sin(C_HEX_CUT_DEGREE_Z_ROTATE + 90),-half_h]];
    
    m_my_rotation_on_ab_and_degree(ab_bottom, C_HEX_CUT_DEGREE * SIGNES_HEX_DEGREE[1] * (WILL_PUT_ON_FACE ? 1 : 0))
    intersection () {
        color (ARR_COLORS[6])
            m_top_bottom(half_h, C_HEX_CUT_DEGREE_Z_ROTATE, C_HEX_CUT_DEGREE * SIGNES_HEX_DEGREE[0], false);
        color (ARR_COLORS[7]) //черная грань с отражением, поэтому внизу плоскость сечения
            m_top_bottom(half_h, C_HEX_CUT_DEGREE_Z_ROTATE, C_HEX_CUT_DEGREE * SIGNES_HEX_DEGREE[1], true);
        difference () {       
            m_ALL_faces(show_core, cut_ratio, cut_degree);
            m_all_cylinders();   
        }
    }
}

m_difference_for_holes(WILL_SHOW_CORE, C_CUT_RATIO, C_CUT_DEGREE);