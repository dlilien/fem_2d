Point(1) = {0, 0, 0, 2.5};
Point(2) = {0, 10, 0, 2.5};
Point(3) = {10, 10, 0, 2.5};
Point(4) = {10, 0, 0, 2.5};
Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,1};
Physical Line(1) = {1};
Physical Line(2) = {2};
Physical Line(3) = {3};
Physical Line(4) = {4};
Line Loop(9) = {2, 3, 4, 1};
Plane Surface(10) = {9};
Physical Surface(11) = {10};
