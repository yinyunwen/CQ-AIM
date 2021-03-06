% test_generateFarFieldElements.m
% Created by: JDR on 02-24-2017 in Newark
% Last Modified: 02-27-2017
%
% Tests the function ./modules/fftSolver/generateFarFieldElements.m

% Add correct path to get meshes and files-to-test on path
cd ..
addpath(genpath('modules'))
addpath(genpath('demo'))
cd tests
mesh = 'twoCircles';
meshStruct = initialize_mesh(mesh,1); % Initialize mesh (always use p=1 in second argument)
N=meshStruct.nt; % number of centroid points
M=2;
% initialize centroids
centroids = generateCentroids(meshStruct, N);
[midpointsX,midpointsY] = generateMidpoints(meshStruct,N);
% spatial discretization parameter h
h = mesh_size(meshStruct);
%initialize triangle areas
triAreas = generateTriangleAreas(meshStruct, N);
%Generate a Cartesean grid containing D and a little extra with spacing
% h/2. First find largest/smallest centroids.
minX = min(centroids(:,1)); maxX = max(centroids(:,1));
minY = min(centroids(:,2)); maxY = max(centroids(:,2));
[ffX,ffY] = meshgrid(minX-M*h:h/M:maxX+M*h, minY-M*h:h/M:maxY+M*h);
ffX=ffX(:);ffY=ffY(:);
farFieldGrid = [ffX,ffY]; % output is size NGx2.

% %% load variables from generateFarFieldElements.m %% %
[centers, rectangularElementsX, rectangularElementsY, V] = generateFarFieldElements(centroids, M, N, farFieldGrid, h, midpointsX,midpointsY, triAreas);

% Start by testing that rectangularElements (from rectangular mesh) are within M*h of 
% their corresponding centroid (from the FEM mesh) in the 2-norm
k=0;
for i=1:N
    for j=1:9
        if (sqrt((rectangularElementsX(i,j)-centroids(i,1))^2+(rectangularElementsY(i,j)-centroids(i,2))^2))>M*h
            error('generateFarFieldElements Test Line 13: distance between centroids and centers FAILED.')
        else
            k=k+1;
        end
    end
end
if k==N*9
    sprintf('generateFarFieldElements Test: distance between centroids and rectangular grid points PASSED.')
end

% Test that rectangularElementsX/Y are actually in the farFieldGrid. 
k=0;
for i=1:N
    for j=1:9
        Ix=find(abs(rectangularElementsX(i,j)-ffX)<1E-15);
        Iy=find(abs(rectangularElementsY(i,j)-ffY(Ix))<1E-15);
        if isempty(Iy)
            error('generateFarFieldElements Test Line 55: there is an element of rectangularElements not in farFieldGrid FAILED.')
        else
            k=k+1;
        end
    end
end
if k==N*9
    sprintf('generateFarFieldElements Test: distance between centroids and rectangular grid points PASSED.')
end

% V is supposed to map polynomials of order 0<mx,my<M perfectly. Test this.

