classdef HebiPlotter < handle
    % HebiPlotter visualize realistic looking HEBI modules
    %
    %   Currently only the HEBI elbow joints (snake links) and pipe
    %   joints can be plotted
    %
    %   HebiPlotter Methods (constructor):
    %      HebiPlotter  - constructor
    %
    %   HebiPlotter Methods:
    %      plot         - plots the robot in the specified configuation
    %      setBaseFrame - sets the frame of the first link
    %
    %   Examples:
    %      plt = HebiPlotter();
    %      plt.plot([.1,.1]);
    %
    %      plt = HebiPlotter(16, 'resolution', 'high');
    %      plt.plot(zeros(16,1));
    
    methods(Access = public)
        %Constructor
        function this = HebiPlotter(varargin)
        %HEBIPLOTTER
        %Arguments:
        %
        %Optional Parameters:
        %  'resolution'        - 'low' (default), 'high' 
        %  'lighting'          - 'on' (default), 'off'
        %  'frame'             - 'base' (default), 'VC', 'gravity'
        %  'JointTypes'        - cell array of joint types
        %
        %Examples:
        %  plt = HebiPlotter()
        %  plt = HebiPlotter('resolution', 'high')
        %
        %  links = {{'FieldableElbowJoint'},
        %           {'FieldableStraightLink', 'ext1', .1, 'twist', 0},
        %           {'Foot', 'ext1', .1, 'twist', 0}};
        %  plt = HebiPlotter('JointTypes', links)  


            p = inputParser;
            expectedResolutions = {'low', 'high'};
            expectedLighting = {'on','off', 'far'};
            expectedFrames = {'Base', 'VC', 'gravity'};
            
            % addRequired(p, 'numLinks', @isnumeric);
            addParameter(p, 'resolution', 'low', ...
                         @(x) any(validatestring(x, ...
                                                 expectedResolutions)));
            addParameter(p, 'frame', 'Base',...
                         @(x) any(validatestring(x, expectedFrames)));

            addParameter(p, 'lighting', 'on',...
                         @(x) any(validatestring(x, ...
                                                 expectedLighting)));
            addParameter(p, 'JointTypes', {});
            addParameter(p, 'drawWhen', 'now');

            parse(p, varargin{:});

            this.lowResolution = strcmpi(p.Results.resolution, 'low');

            this.firstRun = true;
            this.lighting = p.Results.lighting;
            this.setKinematicsFromJointTypes(p.Results.JointTypes);
            this.frameType = p.Results.frame;
            this.drawNow = strcmp(p.Results.drawWhen, 'now');
            
        end
        
        function plot(this, anglesOrFbk)
        % PLOT plots the robot in the configuration specified by
        % angles
                       
            if (isnumeric(anglesOrFbk))
                angles = anglesOrFbk;
                fbk = [];
                if (strcmpi(this.frameType, 'gravity'))
                    error(['Input needs to be a feedback  '...
                        '(you choose gravity frame)']);
                end
            else
                try
                    angles = anglesOrFbk.position;
                    fbk = anglesOrFbk;
                catch
                    error(['Input needs to be either a list of angles ' ...
                           'or feedback']);
                end
            end

            if(this.firstRun)
                snakeData = setupSnakeData( 'SEA Snake', length(angles));
                this.CF = ComplementaryFilter(snakeData);
                initialPlot(this, angles, fbk);
                this.firstRun = false;
            else
                updatePlot(this, angles, fbk);
            end
            if(this.drawNow)
                drawnow
            end
        end
        
        function setBaseFrame(this, frame)
            %SETBASEFRAME sets the frame of the first link in the kinematics
            %chain
            %
            % Arguments:
            % frame (required)    -  a 4x4 homogeneous matrix 
            this.kin.setBaseFrame(frame);
        end
        
    end
    
    methods(Access = private, Hidden = true)
        
        function updatePlot(this, angles, fbk)
        %UPDATEPLOT updates the link patches that were previously plotted
        %by initialPlot. 
            fk = this.kin.getForwardKinematics('CoM',angles);
            [upper, lower, elbow, grip_mobile, grip_static] = this.loadMeshes();

            
            this.computeAndSetBaseFrame(fk, fbk);

            fk = this.kin.getForwardKinematics('CoM', angles);
            fk_out = this.kin.getForwardKinematics('Output',angles);       

            h = this.handles;
            if(~ishandle(h(1,1)))
                error('Plotting window has been closed. Exiting program.');
            end
            angleInd = 1;
            for i=1:this.kin.getNumBodies()
                %For each body, check what type and handle based on that
                %type
                if(strcmp(this.jointTypes{i}{1}, 'FieldableElbowJoint'))
                    fv = this.transformSTL(lower, fk(:,:,i));
                    set(h(i,1), 'Vertices', fv.vertices(:,:));
                    set(h(i,1), 'Faces', fv.faces);

                    fv = this.transformSTL(upper, fk(:,:,i)*this.roty(angles(angleInd)));
                    set(h(i,2), 'Vertices', fv.vertices(:,:));
                    set(h(i,2), 'Faces', fv.faces);
                    angleInd = angleInd + 1;
                elseif(strcmp(this.jointTypes{i}{1}, ...
                        'FieldableStraightLink'))
                    fv = this.transformSTL(this.getCylinder(this.jointTypes{i}),...
                                           fk(:,:,i));
                    set(h(i,1), 'Vertices', fv.vertices(:,:));
                    set(h(i,1), 'Faces', fv.faces);
                elseif(strcmp(this.jointTypes{i}{1},'FieldableElbowLink'))
                    fv = this.transformSTL(elbow, fk_out(:,:,i));
                    set(h(i,1), 'Vertices', fv.vertices(:,:));
                    set(h(i,1), 'Faces', fv.faces);
                elseif(strcmp(this.jointTypes{i}{1}, 'Foot'))
                    fv = this.transformSTL(this.getSphere(this.jointTypes{i}),...
                                           fk_out(:,:,i-1));
                    set(h(i,1), 'Vertices', fv.vertices(:,:));
                    set(h(i,1), 'Faces', fv.faces);
                elseif(strcmp(this.jointTypes{i}{1}, 'FieldableElbowJoint'))
                    fv = this.transformSTL(lower, fk(:,:,i));
                    set(h(i,1), 'Vertices', fv.vertices(:,:));
                    set(h(i,1), 'Faces', fv.faces);
                elseif(strcmp(this.jointTypes{i}{1}, 'FieldableGripper'))
                    fv = this.transformSTL(lower, fk(:,:,i));
                    set(h(i,1), 'Vertices', fv.vertices(:,:));
                    set(h(i,1), 'Faces', fv.faces);

                    fv = this.transformSTL(grip_mobile, fk(:,:,i)*this.roty(angles(angleInd)));
                    set(h(i,2), 'Vertices', fv.vertices(:,:));
                    set(h(i,2), 'Faces', fv.faces);
                    
                    fv = this.transformSTL(grip_static, fk(:,:,i));
                    set(h(i,3), 'Vertices', fv.vertices(:,:));
                    set(h(i,3), 'Faces', fv.faces);
                    angleInd = angleInd + 1;
                end
            end
            axis([-inf inf -inf inf -inf inf]);
        end
        
        function initializeKinematics(this, numLinks)
        %INITIALIZEKINEMATICS creates a default kinematics object
        %if one has not already been assigned.
            if(this.kin.getNumBodies > 0)
                return;
            end
            
            for i=1:numLinks
                this.kin.addBody('FieldableElbowJoint');
                this.jointTypes{i} = {'FieldableElbowJoint'};
            end
        end
        
        function setKinematicsFromJointTypes(this, types)
        %Creates a HebiKinematics object that will be used to calculate the
        %Forward Kinematics when plotting. 
        %types  is a struct of structs. Each struct can be fed into
        %HebiKinematics as a link type with necessary parameters
        %There is a custom type of "Foot" for plotting the end caps.
            this.kin = HebiKinematics();
            this.jointTypes = types;
            if(length(types) == 0)
                return;
            end
            for i = 1:length(types)
                if(strcmp(types{i}{1}, 'Foot'))
                    this.kin.addBody('FieldableStraightLink', ...
                        types{i}{2:end});
                else
                    this.kin.addBody(types{i}{:});
                end
            end
        end

        function this = initialPlot(this, angles, fbk)
        %INITIALPLOT creates patches representing the CAD of the
        %manipulator, sets lighting, and labels graph

            this.initializeKinematics(length(angles));
            n = this.kin.getNumBodies();
            
            this.handles = zeros(n, 3);

            [upper, lower, elbow, grip_mobile, grip_static]...
                            = this.loadMeshes();
            
            fk = this.kin.getForwardKinematics('CoM', angles);
            
            this.frame = eye(4);
            this.computeAndSetBaseFrame(fk, fbk);
            
            fk = this.kin.getForwardKinematics('CoM', angles);
            fk_out = this.kin.getForwardKinematics('Output', angles);

            
            if(strcmp(this.lighting, 'on'))
                light('Position',[0,0,10]);
                light('Position',[5,0,10]);
                light('Position',[-5,0,10]);
                lightStyle = 'gouraud';
                strength = .3;
            elseif(strcmp(this.lighting, 'far'))
                c = [.7,.7,.7];
                light('Position',[0,0,100],'Color',c);
                light('Position',[-100,0,0],'Color',c);
                light('Position',[100,0,0],'Color',c);
                light('Position',[0,-100,0], 'Color',c);
                light('Position',[0,100,0],'Color',c);
                lightStyle = 'flat';
                strength = 1.0;
            else
                lightStyle = 'flat';
                strength = 1.0;
            end
            
            angleInd = 1;
            for i=1:this.kin.getNumBodies
                if(strcmp(this.jointTypes{i}{1}, 'FieldableElbowJoint'))
                    this.handles(i,1:2) = ...
                        this.patchHebiElbow(lower, upper, fk(:,:,i), ...
                                       angles(angleInd), lightStyle, ...
                                            strength);
                    angleInd = angleInd + 1;
                elseif(strcmp(this.jointTypes{i}{1}, 'FieldableElbowLink'))
                    this.handles(i,1) = ...
                        this.patchElbowLink(elbow, fk_out(:,:,i));
                elseif(strcmp(this.jointTypes{i}{1}, ...
                        'FieldableStraightLink'))
                    this.handles(i,1) = ...
                        this.patchCylinder(fk(:,:,i), this.jointTypes{i});
                elseif(strcmp(this.jointTypes{i}{1}, 'Foot'))
                    this.handles(i,1) = ...
                        this.patchSphere(fk(:,:,i), this.jointTypes{i});
                elseif(strcmp(this.jointTypes{i}{1}, 'FieldableGripper'))
                    this.handles(i,:) = ...
                        this.patchHebiGripper(lower,grip_mobile,grip_static, fk(:,:,i), ...
                                       angles(angleInd), lightStyle, ...
                                            strength);
                    angleInd = angleInd + 1;
                end
            end
            axis('image');
            view([45, 35]);
            xlabel('x');
            ylabel('y');
            zlabel('z');
        end
        
        function h = patchHebiElbow(this,lower, upper, fk, angle, ...
                                    lightStyle, strength)
        %Patches (plots) the HebiKinematics elbow joint
            h(1,1) =  ...
                patch(this.transformSTL(lower, fk), ...
                      'FaceColor', [.5,.1,.2],...
                      'EdgeColor', 'none',...
                      'FaceLighting', lightStyle, ...
                      'AmbientStrength', strength);
            h(1,2) = ...
                patch(this.transformSTL(upper, fk*this.roty(angle)), ...
                'FaceColor', [.5,.1,.2],...
                'EdgeColor', 'none',...
                'FaceLighting', lightStyle, ...
                'AmbientStrength', strength);
        end
        
        function h = patchHebiGripper(this,lower,grip_mobile,...
                                    grip_static,fk, angle, ...
                                    lightStyle, strength)
        %Patches (plots) the SEA HebiGripper
            h(1,1) =  ...
                patch(this.transformSTL(lower, fk), ...
                      'FaceColor', [.5,.1,.2],...
                      'EdgeColor', 'none',...
                      'FaceLighting', lightStyle, ...
                      'AmbientStrength', strength);
                  
            h(1,2) = ...
                patch(this.transformSTL(grip_mobile, fk*this.roty(angle)), ...
                'FaceColor', [.5, .5, .5],...
                'EdgeColor', 'none',...
                'FaceLighting', lightStyle, ...
                'AmbientStrength', .1);      
                  
            h(1,3) = ...
                patch(this.transformSTL(grip_static, fk), ...
                'FaceColor', [.5, .5, .5],...
                'EdgeColor', 'none',...
                'FaceLighting', lightStyle, ...
                'AmbientStrength', .1);
        end
        
        function h = patchElbowLink(this,elbow, fk)
        %Patches (plots) the HebiKinematics elbow joint
            h(1,1) =  ...
                patch(this.transformSTL(elbow, fk), ...
                      'FaceColor', [.5,.5,.5],...
                      'EdgeColor', 'none',...
                      'FaceLighting', 'gouraud', ...
                      'AmbientStrength', .1);
                  
        end
        
        function [upper, lower, elbow, grip_mobile, grip_static]...
                 = loadMeshes(this)
        %Returns the relevent meshes
        %Based on low_res different resolution meshes will be loaded
            stldir = [fileparts(mfilename('fullpath')), '/stl'];
            
            if(this.lowResolution)
                meshes = load([stldir, '/FieldableKinematicsPatchLowRes.mat']);
            else
                meshes = load([stldir, '/FieldableKinematicsPatch.mat']);
            end
            lower = meshes.lower;
            upper = meshes.upper;
            elbow = meshes.elbow;
            grip_mobile = meshes.grip_mobile;
            grip_static = meshes.grip_static;
        end
        
        function h = patchCylinder(this, fk, types)
        %patches (plots) a cylinder and returns the handle
            h = patch(this.transformSTL(this.getCylinder(types), fk), ...
                      'FaceColor', [.5, .5, .5],...
                      'EdgeColor', 'none',...
                      'FaceLighting', 'gouraud',...
                      'AmbientStrength',.1);
        end
        
        function cyl = getCylinder(this, types)
        %Returns the patch faces and vertices of a cylinder
            p = inputParser();
            p.addParameter('ext1', .4);
            p.addParameter('twist', 0);
            parse(p, types{2:end});
            r = .025;
            h = p.Results.ext1 + .015; %Add a bit for connection section
            [x,y,z] = cylinder;
            cyl = surf2patch(r*x, r*y, h*(z -.5));
        end
        
        function h = patchSphere(this, fk, types)
        %patches (plots) a sphere and returns the handle
            h = patch(this.transformSTL(this.getSphere(types), fk),...
                      'FaceColor', [0, 0, 0],...
                      'EdgeColor', 'none',...
                      'FaceLighting', 'gouraud',...
                      'AmbientStrength',.1);
        end
        
        function sph = getSphere(this, types)
        %Returns the patch faces and vertices of a sphere
            p = inputParser();
            p.addParameter('ext1', .4);
            p.addParameter('twist', 0);
            parse(p, types{2:end});
            r = p.Results.ext1;
            [x,y,z] = sphere;
            sph = surf2patch(r*x, r*y, r*z );
        end
        
        function fv = transformSTL(this, fv, trans)
        %Transforms from the base frame of the mesh to the correctly
        %location in space
            fv.vertices = (trans * [fv.vertices, ones(size(fv.vertices,1), ...
                                                      1)]')';
            fv.vertices = fv.vertices(:,1:3);

        end
        
        function computeAndSetBaseFrame(this, fk, fbk)
            if(strcmpi(this.frameType, 'VC'))
                this.frame = this.frame*unifiedVC(fk, eye(3), eye(3));
                this.setBaseFrame(inv(this.frame));
            elseif (strcmpi(this.frameType, 'gravity'))
                this.CF.update(fbk);
                tailInGravity = this.CF.getInGravity('tail');
                %The module reference frames in CF are aligned for zero
                %joint angle, while in HebiKinematics they rotate from
                %tail to head of pi/2 per module around the z-axis 
                %(screw convention)
                %There is also an offset of -pi to rotate from one
                %convention to the other                   
                tailInGravity_screwConvention = tailInGravity*...
                                            this.rotz(-pi+length(fk)*pi/2);
                this.setBaseFrame(tailInGravity_screwConvention);
            end
        end
        

        function m = roty(this, theta)
        %Homogeneous transform matrix for a rotation about y
            m = [cos(theta),  0, sin(theta), 0;
                 0,           1, 0,          0;
                 -sin(theta), 0, cos(theta), 0;
                 0,           0, 0,          1];
        end
        
        function m = rotz(this, theta)
        %Homogeneous transform matrix for a rotation about z
            m = [cos(theta), -sin(theta), 0, 0;
                 sin(theta),  cos(theta), 0, 0;
                 0          , 0, 1,          0;
                 0,           0, 0,          1];
        end
    end
    
    properties(Access = private, Hidden = true)
        kin;
        jointTypes;
        handles;
        lowResolution;
        firstRun;
        lighting;
        frameType;
        frame;
        drawNow;
        CF;
    end
end
