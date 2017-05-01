classdef (Sealed) HebiPoseFilter
    %HebiPoseFilter is a simple filter that uses accel and gyro measurements to estimate the pose
    %
    %   This api is highly experimental and may change at any time.
    %
    %   HebiPoseFilter Methods:
    %      setMaxAccelNormDev - max deviation from the norm
    %      setAccelNormBias   - accel norm when idle
    %      setMaxAccelWeight  - trust in accelerometers [0-1]
    %      setGyroScale       - trust multiplier for gyros [>0]
    %      resetYaw           - resets dead-reackoned yaw (rotation about z in world)
    %      update             - input: 3x accel [g], 3x gyro [rad/s], abs time [s]
    %      getPose            - out: 4x4 transform matrix
    
    %   Copyright 2014-2016 HEBI Robotics, LLC.
    
    % Public API
    methods(Access = public)
        
        function this = setMaxAccelNormDev(this, varargin)
            %setMaxAccelNormDev max deviation from the norm
            setMaxAccelNormDev(this.obj, varargin{:});
        end
        
        function this = setAccelNormBias(this, varargin)
            %setAccelNormBias accel norm when idle
            setAccelNormBias(this.obj, varargin{:});
        end
        
        function this = setMaxAccelWeight(this, varargin)
            %setMaxAccelWeight trust in accelerometers [0-1]
            setMaxAccelWeight(this.obj, varargin{:});
        end
        
        function this = setGyroScale(this, varargin)
            %setGyroScale trust multiplier for gyros [>0]
            setGyroScale(this.obj, varargin{:});
        end
        
        function this = resetYaw(this, varargin)
            %resetYaw resets dead-reackoned yaw (rotation about z in world)
            resetYaw(this.obj, varargin{:});
        end
        
        function this = update(this, varargin)
            %update input: 1x3 accel [g], 1x3 gyro [rad/s], abs time [s]
            update(this.obj, varargin{:});
        end
        
        function out = getPose(this, varargin)
            % getPose returns the current pose in a transform matrix
            out = getPose(this.obj, varargin{:});
        end
        
    end
    
    properties(Access = private, Hidden = true)
        obj
    end
    
    properties(Constant, Access = private, Hidden = true)
        className = hebi_load('HebiPoseFilter');
    end
    
    % Non-API Methods for MATLAB compliance
    methods(Access = public, Hidden = true)
        
        function this = HebiPoseFilter()
            this.obj = javaObject(HebiPoseFilter.className);
        end
        
        function disp(this)
            disp(this.obj);
        end
        
    end
    
    % Non-API Static methods for MATLAB compliance
    methods(Access = public, Static, Hidden = true)
        
        function varargout = methods(varargin)
            instance = javaObject(HebiPoseFilter.className);
            switch nargout
                case 0
                    methods(instance, varargin{:});
                    varargout = {};
                otherwise
                    varargout{:} = methods(instance, varargin{:});
            end
        end
        
        function varargout = fields(varargin)
            instance = javaObject(HebiPoseFilter.className);
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