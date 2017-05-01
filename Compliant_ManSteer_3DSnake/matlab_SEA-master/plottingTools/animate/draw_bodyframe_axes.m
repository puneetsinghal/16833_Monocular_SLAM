function [ animate_struct ] = draw_bodyframe_axes( animate_struct, ...
                                axis_frames, axis_lengths )
% DRAW_BODYFRAME_AXES
% [ animate_struct ] = draw_bodyframe_axes(animate_struct, 
%                                axis_frames, axis_lengths);
%
%   animate_struct.h
%       An array of axes handles to all the surfaces in the snake.
%
%   animate_struct.fig
%       The handle to the figure.
%
%   animate_struct.frame_num
%       A counter that ticks up the number of images saved for this figure.
%       This number will get appended to the file with leading zeros,
%       allowing them to be stitched together later.
%
%   animate_struct.body_x
%   animate_struct.body_y
%   animate_struct.body_z
%       Variables for the body coordinate frames.  Updated internally to
%       draw_snake
%
%   animate_struct.x
%   animate_struct.y
%   animate_struct.z
%       Variables for the module coordinate frames.  Updated internally to
%       draw_snake

% Inputs: Axis positions in a world frame.  It plots the snake based on
% these module positions, using cylinders and the parameters specified.

    % If a figure handle is not yet specified, make a new figure
    if ~isfield(animate_struct,'fig')
        animate_struct.fig = figure(42);
    elseif ~isfield(animate_struct,'body_x')
        set(0,'CurrentFigure',animate_struct.fig);
    end

    if  ~isfield(animate_struct,'body_x')

        for module = 1:size(axis_frames,3)   
            
            % Transform the cylinder to the module's position and
            % orientation.
            T = axis_frames(:,:,module);
              
            %%%%%%%%%%%%%%%
            % Module Axes %
            %%%%%%%%%%%%%%%

            % Transform principle axes to the position / orientation of
            % each module.
            axes_T = T * [diag(axis_lengths); ones(1,3)];
            orig_T = T * [zeros(3); ones(1,3)];
            
            animate_struct.body_x(module) = line( [orig_T(1,1) axes_T(1,1)],...
                                        [orig_T(2,1) axes_T(2,1)],...
                                        [orig_T(3,1) axes_T(3,1)],...
                                        'Color', 'r', 'LineWidth', 3);
            animate_struct.body_y(module) = line( [orig_T(1,2) axes_T(1,2)],...
                                        [orig_T(2,2) axes_T(2,2)],...
                                        [orig_T(3,2) axes_T(3,2)],...
                                        'Color', 'g', 'LineWidth', 3);
            animate_struct.body_z(module) = line( [orig_T(1,3) axes_T(1,3)],...
                                        [orig_T(2,3) axes_T(2,3)],...
                                        [orig_T(3,3) axes_T(3,3)],...
                                        'Color', 'b', 'LineWidth', 3);
            
            if module==1
                hold on;
            end
        end
        
        hold off;
        animate_struct.ax = gca;
        axis equal;
        
    else

        for module = 1:size(axis_frames,3)
            
            % Transform the cylinder to the module's position and
            % orientation.
            T = axis_frames(:,:,module);

            %%%%%%%%%%%%%%%
            % Module Axes %
            %%%%%%%%%%%%%%%

            % Transform principle axes to the position / orientation of
            % each module.
            axes_T = T * [diag(axis_lengths); ones(1,3)];
            orig_T = T * [zeros(3); ones(1,3)];
            
            set( animate_struct.body_x(module), 'XData', [orig_T(1,1) axes_T(1,1)],...
                                      'YData', [orig_T(2,1) axes_T(2,1)],...
                                      'ZData', [orig_T(3,1) axes_T(3,1)] );
            set( animate_struct.body_y(module), 'XData', [orig_T(1,2) axes_T(1,2)],...
                                      'YData', [orig_T(2,2) axes_T(2,2)],...
                                      'ZData', [orig_T(3,2) axes_T(3,2)] );
            set( animate_struct.body_z(module), 'XData', [orig_T(1,3) axes_T(1,3)],...
                                      'YData', [orig_T(2,3) axes_T(2,3)],...
                                          'ZData', [orig_T(3,3) axes_T(3,3)] );


        end    
    end

end
