function [TransModFrame,ModFrame,V,animateStruct] = SEASnakeVC(animateStruct,snakeData,fbk,V)

moduleLen = snakeData.moduleLen;
halfLen = moduleLen/2;
numModules = snakeData.num_modules;

T_Front = zeros(4,4,numModules+1);
T_Back = zeros(4,4,numModules+1);
T_Full = zeros(4,4,numModules+1);

ModFrame = zeros(4,4,numModules);
ModFrame(:,:,1) = eye(4);
TransModFrame = zeros(4,4,numModules);

if V == 0
    oldV = eye(3);
else
    oldV = V;
end

%%%%%%%%%%%%%%%%%%%%%%
% Forward Kinematics %
%%%%%%%%%%%%%%%%%%%%%%
% Transforming angles to the inertial frame based off the head module frame
angles = -anglesSEAtoU(snakeData,fbk.position);
%

%Forward Kinematics via Translations and Euler angles
%(angles as seen in the inertial frame)

for i = 1:numModules
    T_Front(:,:,i) = eye(4);
    T_Back(:,:,i) = eye(4);
    
    if mod(i,2) %First module rotation considered to be about y-axis
        cangle = cos(angles(i));
        sangle = sin(angles(i));
        Rot = [ cangle        0       sangle;
                    0         1          0;
               -sangle       0       cangle];
    else % Second module rotation considered to be about the x-axis
        cangle = cos(angles(i));
        sangle = sin(angles(i));
        Rot = [ 1        0             0;
                0       cangle      -sangle;
                0       sangle       cangle];
    end

    %Translating down the first half of the module
    T_Front(1:3,4,i) = [0; 0; -halfLen];

    %Rotating at the joint and translating the remaining half
    T_Back(1:3,1:3,i) = Rot;
    T_Back(1:3,4,i) = [0;0;-halfLen];

    %Combining the two transformation matrices
    T_Full(:,:,i) = T_Back(:,:,i)*T_Front(:,:,i);

    %Offsetting the previous module frame by the new transformation
    %All module frames are in reference to the inertial frame from the
    %head of the snake
    ModFrame(:,:,i+1) = ModFrame(:,:,i)*T_Full(:,:,i);
    %(numModules+1)
end

%Pulling out the translations to get the 3D positions from head to
%tail (numModules+1)
points = squeeze(ModFrame(1:3,4,:))';

%Getting the center of mass for use as the new inertial frame
CoM = mean(points);     %Treating the modules as equivalent point masses
avg_points = points - repmat(CoM,size(points,1),1);

%%%%%%%%%%%%%%%%%%%
% Virtual Chassis %
%%%%%%%%%%%%%%%%%%%
% Performing SVD to isolate the principal rotation axes
[~,S,V] = svd(avg_points);

% Aligning the sign of 1st principal rotation axis to the head module
if dot(V(:,1),avg_points(1,:)) < 0
    V(:,1) = -V(:,1);
end
% Aligning the sign of  2nd principal axis to its previous value
if dot(V(:,2),oldV(:,2)) < 0
    V(:,2) = -V(:,2);
end
%Creating the 3rd principal axis as the cross product of the first two
%to keep the right-handed nature
V(:,3) = cross(V(:,1), V(:,2));

%Buiding the virtual chassis transformation matrix
VC = eye(4);
VC(1:3,1:3) = V;    %Rotation to the 1st principal rotation axis
VC(1:3,4) = CoM';   %Translation of the snake to the center of mass;

T = inv(VC);

%Transforming the module frames to the CoM and aligned with the 1st and
%2nd principal axes
for i=1:size(ModFrame,3)
    TransModFrame(:,:,i) = VC\ModFrame(:,:,i);
    %Pulling out only the translations for the new points
    newpoints = squeeze(TransModFrame(1:3,4,:))';
end

%The center of mass is now located at the origin
newCoM = [0 0 0];


%%%%%%%%%%%%%%%%%
% Things To Add %
%%%%%%%%%%%%%%%%%

%[animateStruct, drawInfo] = animate_snake(animateStruct,TransModFrame,snakeInfo,drawInfo);

hfig = figure(42);
set(hfig, 'Color', [1 1 1]);

[ animateStruct ] = draw_snake(animateStruct,TransModFrame,snakeData.moduleLen,snakeData.moduleDia);


end

