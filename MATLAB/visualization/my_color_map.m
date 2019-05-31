function c_vect = my_color_map
N      = 256;
C1     = colorcet('D1', 'N', N);
C2     = C1( end:-1:1, :);
C3     = colorcet('D2', 'N', N);
C4     = C3( end:-1:1, :); 
c_vect = {C1, C2, C3, C4};