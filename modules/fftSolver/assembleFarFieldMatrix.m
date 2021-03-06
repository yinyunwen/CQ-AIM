% assembleFarFieldMatrix.m
% Created on 02-03-2017 by JDR in Newark
% Last Modified:
% 
% Inputs: farFieldGrid - nGx2 vector of rectangular mesh points
%         P            - Nx(M+1)^2 interpolation matrix from triangular mesh to
%                        rectangular mesh 
%         N            - Number of finite elements
%         rectangularElements - the rectangles in the near field
%         i/jElements  - Locations of near field elements
%
% Outputs: farFieldElements - NxN sparse matrix of far field matrix components
%
% Generates the elements of the far field matrix corresponding to given
% points (i,j). In particular, uses Afar = V G V^T, where V is the
% interpolation matrix from a finite element mesh to a rectangular mesh and
% G is the Green function evaluated at each of the rectangular mesh points.
% Only generates elements which are needed (to cancel out equivilent
% components in near field). 

function farFieldElements = assembleFarFieldMatrix(waveNumber,  flatP, N,...
    rectangularElementsX, rectangularElementsY, iElements, jElements,...
    rectangularLocations, GD)

kMax = length(nonzeros(iElements));

% The fundamental solution for 2D. Note that this will output as something
% the size of its input and if the input is zero, the output will be zero
% up to machine precision. This is to avoid any issues with near field NaNs
% not canceling out below. 

fundamentalSolution=@(x)(reshape(1i/4*besselh(0,1,1i*waveNumber*((x~=0).*x+(abs(x)<1E-14).*1E300)),size(x)));
sElements = zeros(kMax,1);
% Question: Can this be done without the loop? This is about half my total
% time!!!
% D = sqrt(bsxfun(@plus,dot(X',X',1),dot(X',X',1)')-(2*(X*X')));
% GD = fundamentalSolution(D);
% A_{i,j} = a_{i-j} in a toeplitz matrix like GD. Hence, since GD is a 1xnG
% vector and the matrix version is symmetric, the element (i,j) is in
% location GD(abs(1-j)). 
for j=1:kMax
    % build distance matrix between each expansion box element.
   expBoxI = [rectangularElementsX(iElements(j),:)',rectangularElementsY(iElements(j),:)'];
   expBoxJ = [rectangularElementsX(jElements(j),:)',rectangularElementsY(jElements(j),:)'];
   D = sqrt(bsxfun(@plus,full(dot(expBoxI',expBoxI',1)),full(dot(expBoxJ',expBoxJ',1))')-full(2*(expBoxJ*expBoxI')));

%       toeplitzRows = reshape(GD(abs(1-(rectangularLocations(iElements(j),1)-rectangularLocations(jElements(j),:)))),3,3).';
%       tRR = real(toeplitzRows); tRI = imag(toeplitzRows);
%       A = toeplitz(tRR(1,:))+1i*toeplitz(tRI(1,:)); 
%       B = toeplitz(tRR(2,:))+1i*toeplitz(tRI(2,:)); 
%       C = toeplitz(tRR(3,:))+1i*toeplitz(tRI(3,:));
%       GDCurrent = [A, B, C; B, A, B; C, B, A];
     
    GDCurrent = fundamentalSolution(D);
    sElements(j) = flatP(iElements(j),:)*...
        (GDCurrent*flatP(jElements(j),:).');
end

farFieldElements = sparse(iElements, jElements, sElements, N,N);

end