% generateUSHat.m
% Created on: 02-17-2017 by JDR in Newark
% Last Modified:
%
% Inputs: 
%
% Outputs:
%
% Generates the scattered field corresponding to a wavenumber k, an index
% of refraction defined by c and the shape D, and an incident field ui.
% This is just a time harmonic scattered field. However, it is computed in
% the near field with a P0-Galerkin approximation to the Lippmann-Schwinger
% equation and in the far field with a FFT-based techinque, using
% delta-function 'basis functions' defined on a rectangular grid. 
%
% Algorithm: 1) Calculate near field based on previously-computed near
%               field grid. 
%            2) Compute RHS
%            3) Use CG to solve for US in D, using 1) and far field
%               computed during iterations
%            4) Find solution in exterior. 

function usHat = generateUSHat()







end

% aFarX applies operator Afar to a vector x. Output is approximation to Ax
% evaluated back on finite element mesh through the interpolation matrix. 
function AfarX = applyFarField()


end