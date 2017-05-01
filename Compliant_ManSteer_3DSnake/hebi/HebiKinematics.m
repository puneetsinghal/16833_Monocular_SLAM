classdef (Sealed) HebiKinematics
    % HebiKinematics provides simple kinematic methods for HEBI modules
    %
    %   This API is still experimental and may change in minor revisions.
    %   At the moment, only serial chains are supported.
    %
    %   HebiKinematics Methods (setup):
    %      addBody              -  adds a body to the end of the chain
    %      getNumBodies         -  number of bodies
    %      getNumDoF            -  number of degrees of freedom
    %      getBodyMasses        -  a vector of all body masses [kg]
    %      setBaseFrame         -  relationship from world to first body
    %
    %   HebiKinematics Methods (kinematics):
    %      getForwardKinematics -  calculates the configuration of bodies
    %      getJacobian          -  relates joint to body velocities
    %      getInverseKinematics -  positions for a desired configuration
    %      getGravCompTorques   -  compensates graviational accelerations
    %
    %   Example
    %      % Setup a simple 3 dof arm made of X5 modules
    %      kin = HebiKinematics();
    %      kin.addBody('X5Joint');
    %      kin.addBody('X5Bracket');
    %      kin.addBody('X5Joint');
    %      kin.addBody('X5Link', 'extension', 0.350);
    %      kin.addBody('X5Joint');
    %
    %   Example
    %      % Calculate forward kinematics with random inputs
    %      positions = rand(kin.getNumDoF, 1);
    %      frames = kin.getForwardKinematics('output', positions);
    %
    %   See also HebiGroup
    
    %   Copyright 2014-2016 HEBI Robotics, LLC.
    
    % Public API
    methods(Access = public)
        
        function this = addBody(this, varargin)
            % addBody adds a body to the end of the chain
            %
            %   This method creates a serial chain of bodies that describe
            %   the kinematic relation of a robot. A 'body' can be a rigid
            %   link as well as a dynamic element.
            %
            %   The 'Type' argument specifies the type of module or body
            %   that should be added. Currently implemented types include:
            %
            %       'FieldableElbowJoint'
            %       'FieldableElbowLink'    (ext1,twist1,ext2,twist2)
            %       'FieldableStraightLink' (ext,twist)
            %       'FieldableGripper'
            %       'X5Joint'
            %       'X5Bracket'
            %       'X5Link'                (ext)
            %       'GenericLink'           (com,out,mass)
            %
            %   Some types may require a set of parameters. Parameters
            %   that are not required by the specified type are ignored.
            %   Potential parameters include:
            %
            %       Parameter      Units    Synonyms
            %       'Extension'    [m]      ('ext','ext1')
            %       'Extension2'   [m]      ('ext2')
            %       'Twist'        [rad]    ('twist1')
            %       'Twist2'       [rad]
            %       'Mass'         [kg]
            %       'CoM'          [4x4]
            %       'Output'       [4x4]    ('out')
            %
            %   Example
            %      % Setup a common 4 dof 'Fieldable' arm
            %      inch2m = 0.0254;
            %      kin = HebiKinematics();
            %      kin.addBody('FieldableElbowJoint');
            %      kin.addBody('FieldableElbowJoint');
            %      kin.addBody('FieldableElbowLink', ...
            %          'ext1', 4 * inch2m, 'twist1', pi/2, ...
            %          'ext2', 0.5 * inch2m, 'twist2', pi);
            %      kin.addBody('FieldableElbowJoint');
            %      kin.addBody('FieldableStraightLink', ...
            %          'ext', 6 * inch2m, 'twist', -pi/2);
            %      kin.addBody('FieldableElbowJoint');
            %      kin.addBody('FieldableGripper');
            %
            %   Example
            %      % Setup a common 5 dof 'X' arm
            %      kin = HebiKinematics();
            %      kin.addBody('X5Joint');
            %      kin.addBody('X5Bracket');
            %      kin.addBody('X5Joint');
            %      kin.addBody('X5Link', 'extension', 0.350);
            %      kin.addBody('X5Joint');
            %      kin.addBody('X5Link', 'extension', 0.250);
            %      kin.addBody('X5Joint');
            %      kin.addBody('X5Bracket');
            %      kin.addBody('X5Joint');
            %
            %   See also HebiKinematics
            addBody(this.obj, varargin{:});
        end
        
        function out = getNumBodies(this, varargin)
            % getNumBodies returns the total number of bodies
            %
            %   This method returns the total number of bodies of the
            %   current configuration. This number includes all static
            %   and dynamic elements.
            out = getNumBodies(this.obj, varargin{:});
        end
        
        function out = getNumDoF(this, varargin)
            % getNumDoF returns the number of degrees of freedom
            %
            %   This method returns the number of degrees of freedom that
            %   are within the current configuration. This is also the
            %   length of the expected position vector for the kinematics.
            out = getNumDoF(this.obj, varargin{:});
        end
        
        function out = getBodyMasses(this, varargin)
            % getBodyMasses returns a vector of the masses of all links
            %
            %   This method returns a mass vector that contains the weight
            %   for each body in [kg].
            out = getBodyMasses(this.obj, varargin{:});
        end
        
        function this = setBaseFrame(this, varargin)
            % setBaseFrame sets the relationship between the world and the
            % first body.
            %
            %   This method expects a 4x4 homogeneous transform that
            %   describes the relationship between the world frame and the
            %   frame of the first body. All kinematics are expressed in
            %   the base frame.
            setBaseFrame(this.obj, varargin{:});
        end
        
        function out = getForwardKinematics(this, varargin)
            % getForwardKinematics calculates the configuration of bodies
            %
            %   This method computes the configuration of a chain of bodies
            %   in the base frame from specified values for the joint
            %   parameters.
            %
            %   'FrameType' Argument
            %      'Output'      calculates the transforms to the output
            %                    of each body ('out')
            %      'CoM'         calculates the transforms to the center of
            %                    mass of each body
            %      'EndEffector' calculates the transform to only the
            %                    output frame of the last body, e.g.,
            %                    a gripper
            %
            %   'Position' Argument
            %      A vector of numDof length that specifies the position
            %      of each degree of freedom. Depending on the type of DoF,
            %      the units can be either [rad] or [m].
            %
            %   Example
            %      % Forward kinematics using group feedback
            %      fbk = group.getNextFeedback();
            %      frames = kin.getFK('output', fbk.position);
            %
            %   See also HebiKinematics
            out = getForwardKinematics(this.obj, varargin{:});
        end
        
        function out = getFK(this, varargin)
            % getFK is an abbreviation for getForwardKinematics
            %
            %   See also getForwardKinematics
            out = getFK(this.obj, varargin{:});
        end
        
        function out = getInverseKinematics(this, varargin)
            % getInverseKinematics calculates positions for a desired end
            % effector configuration
            %
            %   This method computes the joint positions associated to a
            %   desired end-effector configuration. There are a variety of
            %   optimization criteria that can be combined depending on the
            %   application. Available parameters include:
            %
            %      Parameter       EndEffector Target     Synonyms
            %      'Xyz'           xyz position
            %      'TipAxis'       z-axis orientation     ('axis')
            %      'SO3'           3-dof orientation
            %
            %   'MaxIterations' ('MaxIter') sets the maximum allowed
            %   iterations of the numerical optimization before giving up.
            %
            %   'InitialPositions' ('Initial') provides the seed for the
            %   numerical optimization. By default the  optimization seeds
            %   with zeros.
            %
            %   Example
            %      % Inverse kinematics on carthesian coordinates
            %      xyz = [0 0 0];
            %      waypoints = kin.getInverseKinematics('xyz', xyz);
            %
            %      % Inverse kinematics for full 6 dof
            %      xyz = [0 0 0];
            %      so3 = eye(3);
            %      positions = kin.getIK('xyz', xyz, 'so3', so3);
            %
            %   See also HebiKinematics
            out = getInverseKinematics(this.obj, varargin{:});
        end
        
        function out = getIK(this, varargin)
            % getIK is an abbreviation for getInverseKinematics
            %
            %   See also getInverseKinematics
            out = getIK(this.obj, varargin{:});
        end
        
        function out = getJacobian(this, varargin)
            %getJacobian relates joint to body velocities
            %
            %   This method calculates the time derivative of the
            %   kinematics equation, which relates the joint rates to
            %   the linear and angular velocity of a body.
            %
            %   This method expects the same arguments as
            %   getForwardKinematics
            %
            %   See also HebiKinematics, getForwardKinematics
            out = getJacobian(this.obj, varargin{:});
        end
        
        function out = getGravCompTorques(this, varargin)
            % getGravCompTorques compensates graviational acceleration
            %
            %   This method computes the torques that are required to
            %   cancel out accelerations induced by gravity.
            %
            %   'Positions' argument expects a vector of positions of
            %   all degrees of freedom.
            %
            %   'GravityVector' argument expects an xyz vector of the
            %   direction of gravity in the base frame. Note that this
            %   direction vector is not required to be unit length.
            %
            %   Example
            %      % Compensate gravity at current position
            %      fbk = group.getNextFeedback();
            %      gravity = [0 0 1];
            %      torques = kin.getGravCompTorques(fbk.position, gravity);
            %
            %   See also HebiKinematics
            out = getGravCompTorques(this.obj, varargin{:});
        end
        
    end
    
    methods(Access = public, Hidden = true)
        
        function this = HebiKinematics()
            % constructor
            this.obj = javaObject(HebiKinematics.className);
        end
        
        function disp(this)
            % custom display
            disp(this.obj);
        end
        
    end
    
    properties(Access = private, Hidden = true)
        obj
    end
    
    properties(Constant, Access = private, Hidden = true)
        className = hebi_load('HebiKinematics');
    end
    
    % Non-API Static methods for MATLAB compliance
    methods(Access = public, Static, Hidden = true)
        
        function varargout = methods(varargin)
            instance = javaObject(HebiKinematics.className);
            switch nargout
                case 0
                    methods(instance, varargin{:});
                    varargout = {};
                otherwise
                    varargout{:} = methods(instance, varargin{:});
            end
        end
        
        function varargout = fields(varargin)
            instance = javaObject(HebiKinematics.className);
            switch nargout
                case 0
                    fields(instance, varargin{:});
                    varargout = {};
                otherwise
                    varargout{:} = fields(instance, varargin{:});
            end
        end
        
    end
    
end