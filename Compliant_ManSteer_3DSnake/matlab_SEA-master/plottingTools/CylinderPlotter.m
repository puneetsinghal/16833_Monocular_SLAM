classdef CylinderPlotter < handle
%CYLINDERPLOTTER visualize modular kinematics chains as cylinders
%
%   This wraps draw_snake to provide a simple interface to 
%    plot snakes (SEA-snake) as cylinders.
%
%   CylinderPlotter Methods (constructor):
%      CylinderPlotter  - constructor
%
%   CylinderPlotter Methods:
%      plot             - plots the robot in the specified
%                         configuration
%      setBaseFrame     - sets the frame of the first link
%
%    Examples:
%        plt = CylinderPlotter();
%        plt.plt([.1,.1]);
    
    methods(Access = public)
        %Constructor
        function this=CylinderPlotter(varargin)
            p = inputParser;
            expectedFrames = {'Base', 'VC', 'gravity'};
            
            addParameter(p, 'frame', 'Base', ...
                         @(x) any(validatestring(x, expectedFrames)));
            parse(p, varargin{:});
            
            this.moduleData.length = .0639;
            this.moduleData.diameter = 0.0540;
            this.firstRun = true;
            this.kin = HebiKinematics();
            this.frameType = p.Results.frame;
            
        end
        
        function plot(this, anglesOrFbk)
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
        end
        
        function setBaseFrame(this, frame)
            this.kin.setBaseFrame(frame);
        end
    end
    
    methods(Access = private, Hidden = true)
        
        function updatePlot(this, angles, fbk)
            fk = this.kin.getFK('Output', angles);
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
                tailInGravity_screwConvention = tailInGravity* ...
                                            this.rotz(-pi+length(fk)*pi/2);
                this.setBaseFrame(tailInGravity_screwConvention);
            end
            fk = this.kin.getForwardKinematics('Output', angles);
            fk = fk(:,:,end:-1:1);
            
            this.animateStruct = ...
                draw_snake(this.animateStruct,fk,...
                           this.moduleData.length, ...
                           this.moduleData.diameter); 
            drawnow();
            axis([-inf inf -inf inf -inf inf]);
            
        end
        
        function initialPlot(this, angles, fbk)

            for i=1:length(angles)
                this.kin.addBody('FieldableElbowJoint');
            end
            this.frame = eye(4);
            updatePlot(this, angles, fbk);

        end
        
        function m = rotz(this, theta)
        %Homogeneous transform matrix for a rotation about z
            m = [cos(theta),  -sin(theta) , 0, 0;
                 sin(theta),  cos(theta),   0, 0;
                 0,             0,          1, 0;
                 0,           0, 0,          1];
        end
    end
    
    properties(Access = private, Hidden = true)
        moduleData;
        animateStruct;
        firstRun;
        kin;
        frame;
        frameType;
        CF;
    end
    
end
