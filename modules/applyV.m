% applyV.m
% Created by: JDR on 02-20-2017 in Newark
% Last Modified:
% 
% Inputs: x    - The Nx1 vector we apply V to
%         K    - NxN sparse matrix of near field componebnts 
%         Ng   - Number of points in the Cartesian grid
%         N    - Number of points in the FEM grid
%         fftG - NgxNg matrix of the fft of the fundamental solution
%                evaluated at Cartesian grid points
%         P    - The NgxN interpolation matrix
%
% Outputs: Vx - An Nx1 vector of the result of Vx
%
% Uses the AIM scheme to apply the operator V, which is the discrete
% version of the Lippmann-Schwinger integral operator. Note that this does
% NOT apply the identity matrix component of the operator! 

function Vx = applyV(x,K,N,fftG, P, waveNumber, c0, farFieldStruct)

% % %% Begin by computing Vfar*x
% 
% % Interpolate x onto Cartesian grid as xhat
% % !!!! Check: !!!! Why are we not just matrix multiplying? The order of P
% % is strange, but it might not matter? 
% Ng = length(fftG);
% xhat = P*x;
% 
% 
% % Do the convolution with ffts. 
% % BIG TODO!!!
% % !!!! Note: !!!! Need to do this in a way that doesn't screw up the
% % aliasing. Look at CQ code for the correct way. 
% xhatLong = [xhat; zeros(length(xhat),1)];
% yhatLong = ifft2(fftG*fft2(xhatLong));
% size(yhatLong)
% yhat = yhatLong(1:Ng/2);
% 
% % Interpolate convolution operator back onto FEM grid
% % y is now Vfarx.
% y = P'*yhat;
y = generateFullFarFieldMatrix(x,farFieldStruct,P, waveNumber);


% Now add in the near field components. 
Vx = K*x+waveNumber^2*y;


end