classdef ComplementaryFilter < handle
% A complimentary filter for the snake robot.  The goal of this is
% to get a state estimate for the pose of the snake robot in an inertial
% frame with its origin at the CoG of the snake with gravity along the
% negative z-axis
    
    methods(Access = public)
        %Constructor
        function this = ComplementaryFilter(varargin)
        %COMPLEMENTARYFILTER
        %Arguments:
        %   snakeData
        %
        %Optional Parameters:
        %  'mexCode'           - 'true' (default), 'false' 
        
        p = inputParser;
        expectedMexCode = {'true', 'false'};
        
        addRequired(p, 'snakeData' ,@isstruct);
        addParameter(p, 'mexCode', 'true', ...
                     @(x) any(validatestring(x, ...
                                             expectedMexCode)));     
        addParameter(p, 'accelOffsets', []);
        addParameter(p, 'gyroOffsets', []);
        addParameter(p, 'gyrosTrustability', []);
        addParameter(p, 'accTrustability', []);

                                         
        parse(p, varargin{:});
        
        this.snakeData = p.Results.snakeData;
        this.miscData.mexCode = strcmpi(p.Results.mexCode, 'true');
        
        this.accelOffset = p.Results.accelOffsets;
        this.gyroOffset = p.Results.gyroOffsets;
        
        if isempty(this.accelOffset)
            this.accelOffset = zeros(3, this.snakeData.num_modules);
        else
            assert(size(this.accelOffset,1)==3);
            assert(size(this.accelOffset,2)==this.snakeData.num_modules);
        end
        
        if isempty(this.gyroOffset)
            this.gyroOffset = zeros(3, this.snakeData.num_modules);
        else
            assert(size(this.gyroOffset,1)==3);
            assert(size(this.gyroOffset,2)==this.snakeData.num_modules);
        end

        this.firstRun = true;  
        this.everUpdated = false;
        
        this.gyro_x = [];
        this.gyro_y = [];
        this.gyro_z = [];
        
        this.accelResidual = [];
        
        if isempty(p.Results.gyrosTrustability)
            this.gyrosTrustability = ones(1, this.snakeData.num_modules);
        else
            this.gyrosTrustability = abs(anglesSEAtoU(this.snakeData, p.Results.gyrosTrustability));
        end
        
        if isempty(p.Results.accTrustability)
            this.accTrustability = ones(1, this.snakeData.num_modules);
        else
            this.accTrustability = abs(anglesSEAtoU(this.snakeData, p.Results.accTrustability));
        end        
        
        end
        
        function update (this, fbk)
            if ~isempty(fbk)
                
                fbk = this.removeGyroOffset(fbk);
                fbk = this.removeAccelOffset(fbk);
                fbk = fbkSEAtoU(this.snakeData,fbk);
                                
                if this.firstRun
                    this.previousAngles = fbk.position;
                    this.previousTime = fbk.time;
                    this.firstRun = false;
                end
                    
                if (fbk.time-this.previousTime)>0.01
                    updateFilter(this, fbk);
                    this.everUpdated = true;
                end
            end
        end
             
        function T = getInGravity (this, varargin)
        %getInGravity
        %
        %Arguments:
        %   object      - 'tail', 'VC', 'head'     
            
        p = inputParser;
        expectedObject = {'tail', 'VC', 'head','wholeBody', 'accelerations','VC_magnitudes'};
        addRequired(p, 'object', @(x) any(validatestring(x, ...
                                             expectedObject)));
        parse(p, varargin{:});
          
        if (this.everUpdated)
            if strcmpi(p.Results.object, 'tail')
                tailWrtHead = this.snakeShape(:,:,end);
                T =  this.headWrtGravity*tailWrtHead;
            elseif strcmpi(p.Results.object, 'head')
                T = this.headWrtGravity;
            elseif strcmpi(p.Results.object, 'VC')
                VCWrtHead = this.VC;
                T = this.headWrtGravity*VCWrtHead;
            elseif strcmpi(p.Results.object, 'wholeBody');
                bodyWrtHead =this.snakeShape;
                for i=1:size(bodyWrtHead,3)
                    T(:,:,i) = this.headWrtGravity * bodyWrtHead(:,:,i);
                end
            elseif strcmpi(p.Results.object, 'accelerations');
                accWrtHead = this.accelerationAvg;
                T = this.headWrtGravity(1:3,1:3)*accWrtHead;
            elseif strcmpi(p.Results.object, 'VC_magnitudes');
                T = this.VC_magnitudes;
            end
        else
            T  =  [];
        end
        
        end
        
    end
        
    methods(Access = private, Hidden = true)
        
        function updateFilter(this, fbk)
            

            
            %%%%%%%%%
            % SETUP %
            %%%%%%%%%    
            
            % Weight on accelerometer correction term
%              accelWeight = 1;
%             accelWeight = 0;
            accelWeight = 0.5;

            
            %%%%%%%%%%%%%%%%%%%%
            % SNAKE KINEMATICS %
            %%%%%%%%%%%%%%%%%%%%
            
            angles.x_angle = fbk.position;%(this.snakeData.x_ang_mask);
            angles.y_angle = fbk.position;%(this.snakeData.y_ang_mask);
            
            % Get the snake's kinematics in the VC
            snakeKinematics = angles2snakeVC( angles, this.snakeData, this.miscData );
            
            % Rotate the snake back into head frame
            headFrame = snakeKinematics.snakeShape(:,:,1);
            snakeKinematics.snakeShape = transform_snake_fast( ...
                                        snakeKinematics.snakeShape, ...
                                        headFrame );
            this.snakeShape = snakeKinematics.snakeShape;
            this.VC_magnitudes = snakeKinematics.S;
            this.VC = snakeKinematics.T;
            
            %%%%%%%%%%%%
            % VELOCITY %
            %%%%%%%%%%%%
            
            dt = fbk.time - this.previousTime;
            dt = max( min( dt, 1 ), .01 );
            
            velocity = -(this.previousAngles - fbk.position)/dt;
            xAngVels = velocity;%(this.snakeData.x_ang_mask);
            yAngVels = velocity;%(this.snakeData.y_ang_mask);
            
            %%%%%%%%%%%%%%%%%%
            % ACCELEROMETERS %
            %%%%%%%%%%%%%%%%%%
            
            accelVecModule = [  fbk.accelX; fbk.accelY; fbk.accelZ ];
            
            % Rotate accelerometer vectors into the body frame
            accelVecBody = zeros(size(accelVecModule));

            for i=1:this.snakeData.num_modules
                accelVecBody(:,i) = this.snakeShape(1:3,1:3,i+1) * ...
                                    accelVecModule(:,i);
            end
%             sqrt(sum(accelVecBody.^2))
            % Average accelerometers
            % Ignoring S017 and accelerometer because it had bad reading
%             accelVecAvg = mean( accelVecBody(:,[1:end-2 end]), 2 );   %TODO remove hack! 
%             this.accTrustability
            accelVecAvg = mean( accelVecBody(:, this.accTrustability>0), 2 ); 
            this.accelerationAvg = accelVecAvg;
            
            %%%%%%%%%
            % GYROS %
            %%%%%%%%%
            
            gyroVecModule = [ fbk.gyroX; fbk.gyroY; fbk.gyroZ];
            this.gyro_x(end+1,:) = gyroVecModule(1,:);
            this.gyro_y(end+1,:) = gyroVecModule(2,:);
            this.gyro_z(end+1,:) = gyroVecModule(3,:);
            
            % Rotate gyros into the body frame, taking into account joint angle
            % velocities.
            gyroVecBody = zeros(size(gyroVecModule));
            gyroAngVelComp = 0;            
            for i=1:this.snakeData.num_modules
                % X-Axis   
                if mod(i,2)==1
                    gyroAngVelComp = gyroAngVelComp + ...
                               snakeKinematics.snakeShape(1:3,1:3,i+1) * ...
                               [ xAngVels(i); 0; 0];
                % Y-Axis
                else
                    gyroAngVelComp = gyroAngVelComp + ...
                               snakeKinematics.snakeShape(1:3,1:3,i+1) * ...
                               [ 0; yAngVels(i); 0];
                end
                gyroVecBody(:,i) = (snakeKinematics.snakeShape(1:3,1:3,i+1) * ...
                                    gyroVecModule(:,i)) + gyroAngVelComp;
            end
            
            % Average gyros
            % Ignoring gyro reading of SA015 (head) cause it's bad
            gyroVecAvg = mean( gyroVecBody(:,this.gyrosTrustability>0), 2 );
%             disp(['I am using ', num2str(size(gyroVecBody(:,this.gyrosTrustability>0),2)),' gryos']);
%             gyroVecAvg = mean( gyroVecBody(:,2:end-1), 2 );
            %TODO REMOVE HACK
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % CALCULATE THE ORIENTATION %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % ACCELEROMETER GRAVITY VECTOR
            gravityVec = accelVecAvg / norm(accelVecAvg);
            upVec = [0; 0; 1];
            
            if (this.everUpdated == false)
                
                  accelAxis = cross( upVec, gravityVec );
                  accelAxis = accelAxis / norm(accelAxis);

                  accelAngle = rad2deg( acos( dot(upVec,gravityVec) ) );

                  this.q = SpinCalc( 'EVtoQ', ...
                             [accelAxis', accelAngle], ...
                             1E6, 0 )';
            end
            
            % ESTIMATE NEW ORIENTATION BY FORWARD INTEGRATING GYROS
            w_x = gyroVecAvg(1);
            w_y = gyroVecAvg(2);
            w_z = gyroVecAvg(3);

            q_from_gyros = quat_rotate( w_x, w_y, w_z, this.q, dt );    
            orientDCM = SpinCalc('QtoDCM',  q_from_gyros', 1E6, 0 )';
            
            %gravityVec
            accelGravity = orientDCM' * gravityVec;

            accelAxis = cross( upVec, accelGravity );
            accelAxis = accelAxis / norm(accelAxis);
            accelAngle = rad2deg( acos( dot(upVec,accelGravity) ) );
            
            % MESS W/ THE ACCEL WEIGHT

            % Scale down if gyro readings are large
            gyroMag = norm(gyroVecAvg);
            gyroScale = 1;

            accelWeight = accelWeight / (1 + gyroScale * gyroMag);

            % Scale down if accelerometers deviate from 1g.
            accelMag = norm(accelVecAvg);
            accelThresh = 1; %0.1

%             if (this.accelIsCompensated)
%                 accelThresh = 0.25;
%             else
%                 accelThresh = 1;
%             end
                
%             this.accelResidual(end+1) = abs(accelMag - 9.81);   
%             plot(this.accelResidual);
            
%             abs(accelMag - 9.81)
            accelDev = abs(accelMag - 9.81) > accelThresh;
%             accelDev = abs(accelMag - 1.01*9.81) > accelThresh;

            if accelDev
                accelWeight = 0;
            else
                accelWeight = accelWeight * (1 - accelDev/accelThresh);
            end   
%             accelWeight = 1
            
            R_error = SpinCalc( 'EVtoDCM', ...
                          [-accelAxis', accelWeight * accelAngle], ...
                           1E6, 0 );  
                       
            updatedDCM = R_error' * orientDCM';  
            
            this.R = updatedDCM;
            this.q = SpinCalc( 'DCMtoQ', ...
                                 updatedDCM, ...
                                 1E6, 0 )';
            this.q = this.q / norm(this.q);               
            this.previousAngles = fbk.position;
            this.previousTime = fbk.time;
            this.miscData.T_last = this.VC;
            
            this.headWrtGravity = eye(4);
            this.headWrtGravity(1:3,1:3) = this.R;
            this.headWrtGravity(1:3,4) = -this.R*this.VC(1:3,4);               
            
        end
        
        function fbkFixed = fix_old_firmware_accelerometers(this, fbk)
        % This function fixes the accelerometer reading from the old-firmware
        % modules
        % That is, changes  the accelerometer of the old firmware SEA modules
        % unity of measures from g to m/s.^2

        snake_firmware = this.snakeData.firmwareType;
        
        if ~isempty(fbk)
            fbkFixed.time = fbk.time;


            for i=1:length(fbk.accelX)

                if strcmpi(snake_firmware{i}, 'SEA_C01')
                    fbkFixed.accelX(i) = fbk.accelX(i) * 9.81;
                    fbkFixed.accelY(i) = fbk.accelY(i) * 9.81;
                    fbkFixed.accelZ(i) = fbk.accelZ(i) * 9.81;
                else
                    fbkFixed.accelX(i) = fbk.accelX(i);
                    fbkFixed.accelY(i) = fbk.accelY(i);
                    fbkFixed.accelZ(i) = fbk.accelZ(i);       
                end

            end

            fbkFixed.position = fbk.position;
            fbkFixed.gyroX = fbk.gyroX;
            fbkFixed.gyroY = fbk.gyroY;
            fbkFixed.gyroZ = fbk.gyroZ;
        else
            fbkFixed = 0;
        end
        end
        
        function fbkFixed = removeGyroOffset(this, fbk)

            fbkFixed.gyroX = fbk.gyroX - this.gyroOffset(1,:);
            fbkFixed.gyroY = fbk.gyroY - this.gyroOffset(2,:);
            fbkFixed.gyroZ = fbk.gyroZ - this.gyroOffset(3,:);
            
            fbkFixed.accelX = fbk.accelX;
            fbkFixed.accelY = fbk.accelY;          
            fbkFixed.accelZ = fbk.accelZ; 
            
            fbkFixed.position = fbk.position;
            fbkFixed.time = fbk.time;
        end
        
        function fbkFixed = removeAccelOffset(this, fbk)

            fbkFixed.gyroX = fbk.gyroX;
            fbkFixed.gyroY = fbk.gyroY;
            fbkFixed.gyroZ = fbk.gyroZ;
            
            fbkFixed.accelX = fbk.accelX - this.accelOffset(1,:);
            fbkFixed.accelY = fbk.accelY - this.accelOffset(2,:);          
            fbkFixed.accelZ = fbk.accelZ - this.accelOffset(3,:); 
            
            fbkFixed.position = fbk.position;
            fbkFixed.time = fbk.time;
        end    
    end
    
    properties(Access = private, Hidden = true) 
        mexCode;
        snakeData;
        firstRun;
        everUpdated;                
        miscData;
        previousAngles;
        previousTime;      
        q;
        R;        
        VC;                 %virtual chassis in the head frame
        snakeShape;         %modules in the head frame
        headWrtGravity;     %head in the gravity frame
        gyro_x;
        gyro_y;
        gyro_z;
        gyroOffset;
        accelOffset;
        accelResidual;
        gyrosTrustability;
        accTrustability;
        accelerationAvg;
        VC_magnitudes;
    end
        
end
