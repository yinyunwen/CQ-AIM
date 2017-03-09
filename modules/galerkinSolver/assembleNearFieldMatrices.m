% assembleNearFieldMatrices.m
% Created: 02-01-2017 by JDR at UD
% Last Modified: 
%
% Input: triAreas            - Nx1 vector of element areas
%        nearFieldDistances  - NxN sparse matrix of distances between the
%                              near field elements
%        i/jElements         - indices of near field elements
%        centroids           - Nx1 vector of centroids
%        rectangularElements - nGx9 matrix of the rectangular grid squares
%        V                   - NxnG interpolation matrix 
%        c                   - anonymous function speed of sound in medium
%        c0                  - speed of sound in free space
%        s                   - frequency
%        N                   - number of elements
%
% Output: K               - "stiffness" matrix
%         M               - "mass" matrix
%
% Outputs the near field components of the AIM algorithm for computing the
% action of the time-harmonic Lippmann-Schwinger equation on a vector. Uses
% p=0 piecewise constant elements on each element and approximates
% integrals on triangles with an exact formula on an equal area circle. 

function [K,M] = assembleNearFieldMatrices(triAreas, nearFieldDistances, iElements, jElements, centroids, extraFarFieldElements, c,c0,waveNumber,N)

% Contrasts at centroid points
qj =((c0./c(centroids(:,1),centroids(:,2))).^2-ones(N,1));


KElements = zeros(length(iElements),1); % Will hold values of K ('stiffness') matrix
MElements = zeros(length(iElements),1); % Will hold values of M (mass) matrix
%K(diagonal) = -triangleAreas.*(4*1i*c0^2/s^2+(2*pi*1i*c0/s).*H11);
%K(off-diagonal) = triangleAreas(i)*triangleAreas(j)*H01(i,j)
% Only calculate values where we have specified elements to be 'near field'
for k = 1:length(iElements)
    currentNearFieldDistance = nearFieldDistances(iElements(k),jElements(k)); % Needed because Matlab doesn't let 
    currentNearFieldDistance = full(currentNearFieldDistance);                % you input variables from sparse matrices...
    if iElements(k)==jElements(k) % On the diagonal
        KElements(k) = -triAreas(iElements(k))^2.*(4*1i*c0^2/waveNumber^2+(2*pi*1i*c0/waveNumber).*...
            besselh(1,1,1i*waveNumber/c0*sqrt(triAreas(iElements(k))/pi)));
        MElements(k) = triAreas(iElements(k))/qj(iElements(k));
    else
        KElements(k) = triAreas(iElements(k))*triAreas(jElements(k))*...
            besselh(0,1,1i*waveNumber/c0*currentNearFieldDistance);
    end
end

% Create a sparse matrix whose diagonal elements correspond to qj at
% required are exactly the ones
% created above 
M = sparse(iElements,jElements,MElements,N,N);
% Subtract off the extra far field contributions to prevent double counting
% in the near field (order is the same as KElements because i/jElements are
% used to order both.     
K = sparse(iElements,jElements,KElements,N,N);

K = (1i*waveNumber^2)/(4*c0^2)*K-waveNumber^2*extraFarFieldElements;

end