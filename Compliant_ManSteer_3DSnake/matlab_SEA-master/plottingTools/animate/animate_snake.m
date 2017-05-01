function [ animateStruct, drawInfo ] = animate_snake( animateStruct, ...
                                    moduleFrames, snakeInfo, drawInfo)
% DRAW_SNAKE
% [ animateStruct ] = animate_snake(animateStruct, 
%                                moduleFrames, snakeInfo, drawInfo);
%
%   animateStruct.fig
%       The handle to the figure object.
%
%   animateStruct.ax
%       The handle to the axis object.
%
%   animateStruct.h
%       An array of axes handles to all the surfaces in the snake.  Updated
%       internally to draw_snake.m.
%
%   animateStruct.frame_num
%       A counter that ticks up the number of images saved for this figure.
%       This number will get appended to the file with leading zeros,
%       allowing them to be stitched together later, with tools like 
%       ffmpeg or Quicktime.
%
%   animateStruct.body_x
%   animateStruct.body_y
%   animateStruct.body_z
%       Handles for the body coordinate frames.  Updated internally to
%       draw_bodyframe_axes.m.
%
%   animateStruct.x
%   animateStruct.y
%   animateStruct.z
%       Handles for the module coordinate frames.  Updated internally to
%       draw_axes.m.
%
%   moduleFrames
%       4x4xNxT set of transforms.  N is the number of modules.  T is the
%       number of timesteps to animate.
%
%   snakeInfo
%       .moduleLen
%           Length of each module
%
%       .moduleDia
%           Diameter of each module
%
%       .axisVC
%           [3xT] set of the magnitudes of the body frame axes for plotting
%           at each point in time
%
%       .axisPerm
%           Permutation axis for the body frame, used to rotate the virtual
%           chassis to a desired orientation w.r.t. principal shape axes.
%
%       .snakePose
%           4x4xT set of transform used to move the snake thru the world.
%       
%   drawInfo
%       .drawModules
%           [true / false] to draw the modules.
%           Defaults to true if not specified.
%
%       .drawBodyFrame
%           [true / false] to draw the body frame of the snake.
%           Defaults to false if not specified.
%
%       .drawModuleFrames
%           [true / false] to draw the modules frames.
%           Defaults to false if not specified.
%
%       .isFirstDraw
%           [true / false] flag to determine whether to do an initial setup
%           on the plots or just updated a few things with a call to set.
%
%       .niceBoxing
%           [true / false] to format the plot area with no tick marks or
%           grid lines.  Good for making figs for papers / presentations.
%           Defaults to false if not specified.
%
%       .view
%           'iso' for isometric view
%           'front' to view down the x-axis
%           'side' to view down the y-axis
%           'top' to view down the z-axis  
%           Defaults to 'iso' if not specified.
%
%       .viewInfo
%           If 'custom' is specified for .view, then this is a 1x2 matrix
%           specifying the azimuth and elevation.
%
%       .numLoops
%           Number of times to repeat the gait cycle.
%           Defaults to 1 if not specified.
%
%       .mexCode
%           [true / false] run the MEX versions of functions if possible.
%           This may not work on all computers.  Defaults to false.
%
%       .axisTitle
%           Handle to the figure title, so that it can be quickly set in
%           calls after the initial plotting.
%
%       .saveFrames
%           [true / false] to save images to unique file names for
%           stitching together into a movie.
%           Defaults to false if not specified.
%
%       .fileName
%           If saving images to disk, this string will be used to name the
%           files.  Otherwise "untitled_animation" is used.

    % If a whole set of snake shapes have been handed in...
    % Calculate each step's position in the gait cycle.
    % Assumes the shapes are evely spaced from [0 to 1]
    if size(moduleFrames,4) > 1
        gaitPos = (1:size(moduleFrames,4)) / size(moduleFrames,4);
    end
    
    % Otherwise check if position was specified in drawInfo
    if isfield(drawInfo,'gaitPos')
        gaitPos = drawInfo.gaitPos;
    end
    
    % Number of times to cycle thru the animation
    % Defaults to 1 if not specified
    if ~isfield(drawInfo,'numLoops')
        numLoops = 1;
    else
        numLoops = drawInfo.numLoops;
    end
    
    for loop=1:numLoops

        % Iterate through all the frames that are passed in.
        for i=1:size(moduleFrames,4)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Correct for the actual pose of the snake %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isfield(snakeInfo,'snakePose')
                
                invSnakePose = inv(snakeInfo.snakePose(:,:,i));
                
                if isfield(drawInfo,'mexCode') && drawInfo.mexCode
                    % MEX CODE (faster)%   
                    moduleFrames(:,:,:,i) = ...
                        transform_snake_fast( moduleFrames(:,:,:,i),...
                                              invSnakePose );                      
                else
                    % MATLAB CODE %
                    moduleFrames(:,:,:,i) = ...
                        transform_snake( moduleFrames(:,:,:,i),...
                                         invSnakePose );
                end
            end
            
            
            %%%%%%%%%%%%%%%%%%
            % Draw the snake %
            %%%%%%%%%%%%%%%%%%
            
            % Defaults to true
            if ~isfield(drawInfo,'drawModules') || drawInfo.drawModules
                animateStruct = ...
                    draw_snake( animateStruct, moduleFrames(:,:,:,i),...
                                snakeInfo.moduleLen, snakeInfo.moduleDia );
                            
            % If there are module frames leftover, but we're not drawing,
            % reset the animation.
            elseif isfield( animateStruct, 'h' );
                [ animateStruct, drawInfo ] = ...
                    resetAnimation( animateStruct, drawInfo );
            end
                
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Draw the module frames %
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Defaults to false
            if isfield(drawInfo,'drawModuleFrames') && drawInfo.drawModuleFrames
                animateStruct = ...
                    draw_axes( animateStruct, moduleFrames(:,:,:,i),...
                               snakeInfo.moduleDia*ones(3,1) );   
            % If there are module frames leftover, but we're not drawing,
            % reset the animation.
            elseif isfield( animateStruct, 'x' );
                [ animateStruct, drawInfo ] = ...
                    resetAnimation( animateStruct, drawInfo );
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % Draw the body frames %
            %%%%%%%%%%%%%%%%%%%%%%%%
            defaultAxisLengths = .1; % inches
            defaultAxisLengths = .1; % meters

            % Defaults to false
            if isfield(drawInfo,'drawBodyFrame') && drawInfo.drawBodyFrame
                if isfield(snakeInfo,'axisPerm') && isfield(snakeInfo,'axisVC')

                    % Turn permutation matrix into a full 4x4 transform
                    bodyFrame = eye(4);
                    bodyFrame(1:3,1:3) = snakeInfo.axisPerm;
                    axisLengths = snakeInfo.axisVC(:,i);
                else
                    % Default body frame is identity matrix at origin
                    bodyFrame = eye(4);
                    axisLengths = defaultAxisLengths*ones(3,1);
                end
                
                % If the snake's pose is specified, transform body frame
                if isfield(snakeInfo,'snakePose')
                    bodyFrame = snakeInfo.snakePose * bodyFrame;
                end
                
                % Draw the body frame
                animateStruct = ...
                    draw_bodyframe_axes( animateStruct, ...
                                         bodyFrame,...
                                         axisLengths );
                                     
            % If there's a body frame leftover, but we're not drawing it,
            % reset the animation.
            elseif isfield( animateStruct, 'body_x' );
                [ animateStruct, drawInfo ] = ...
                    resetAnimation( animateStruct, drawInfo );
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Adjust the Figure Parameters %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Set up the plotting area the first time around
            if ~isfield(drawInfo,'isFirstDraw') || drawInfo.isFirstDraw
                
                % Handle to the surface plot axis
                ax = animateStruct.ax;

                % Amount to pad the bounding box
                padding = .05; % meters
                padding = .05; % inches

                % Fix the viewing area.  This pads the default size that
                % was made in the first timestep by some amount, so that
                % hopefully the snake doesn't wander out of the frame.
                xlim(ax, [min(min(moduleFrames(1,4,:,:)))-padding ...
                      max(max(moduleFrames(1,4,:,:)))+padding ]);
                ylim(ax, [min(min(moduleFrames(2,4,:,:)))-padding ...
                      max(max(moduleFrames(2,4,:,:)))+padding ]);
                zlim(ax, [min(min(moduleFrames(3,4,:,:)))-padding ...
                      max(max(moduleFrames(3,4,:,:)))+padding ]);

%                 % Make the viewing area wide.  This is useful if the snake
%                 % is being rotated due to state estimation.
%                 xlim(ax, [min(min(min(moduleFrames(:,4,:,:))))-padding ...
%                       max(max(max(moduleFrames(:,4,:,:))))+padding ]);
%                 ylim(ax, [min(min(min(moduleFrames(:,4,:,:))))-padding ...
%                       max(max(max(moduleFrames(:,4,:,:))))+padding ]);
%                 zlim(ax, [min(min(min(moduleFrames(:,4,:,:))))-padding ...
%                       max(max(max(moduleFrames(:,4,:,:))))+padding ]);
                
                % hold on;
                grid(ax,'on');

                % Pick view based on input.
                % Defaults to whatever the view is currently
                if isfield(drawInfo,'view')
                    switch drawInfo.view
                        case 'iso'
                            view(ax,30,30);  % iso view
                        case 'top'
                            view(ax,0,90);  % top view
                        case 'side'
                            view(ax,0,0);   % side view
                        case 'front'
                            view(ax,90,0);   % front view
                        case 'custom'
                            view(ax, drawInfo.viewInfo(1), ...
                            drawInfo.viewInfo(2) );     % user-specified
                    end
                end
                
                % Make a nice clean axis layout, if specified
                if isfield(drawInfo,'niceBoxing') ...
                        && drawInfo.niceBoxing

                    % Minimalist boxing parameters
                    set(ax, 'XTick', get(ax,'XLim'));
                    set(ax, 'YTick', get(ax,'YLim'));
                    set(ax, 'ZTick', get(ax,'ZLim'));

                    set(ax, 'XTickLabel', {[],[]});
                    set(ax, 'YTickLabel', {[],[]});
                    set(ax, 'ZTickLabel', {[],[]});

                    set(ax, 'TickLength', [0 0]);
                    set(ax, 'GridLineStyle', '-');
                    
                    % Axis labels
                    xlabel(ax, '');
                    ylabel(ax, '');
                    zlabel(ax, '');
                else
                    
                    % Default boxing parameters
                    set(ax, 'XTickMode', 'auto');
                    set(ax, 'YTickMode', 'auto');
                    set(ax, 'ZTickMode', 'auto');

                    set(ax, 'XTickLabelMode', 'auto');
                    set(ax, 'YTickLabelMode', 'auto');
                    set(ax, 'ZTickLabelMode', 'auto');

                    set(ax, 'TickLength', [0.01 0.025]);
                    set(ax, 'GridLineStyle', ':');
                
                    % Axis labels
                    xlabel(ax, 'x (in)');
                    ylabel(ax, 'y (in)');
                    zlabel(ax, 'z (in)');
                end
                
                % Title
                if exist('gaitPos','var')
                    drawInfo.axisTitle = title( ...
                                ax, [ 'Gait Phase Position: ' ...
                                num2str(gaitPos(i),'%3.3f') ] );
                end
                
                % Set the isFirstDraw flag, so that we just set the title
                % on later calls (makes animations faster).
                drawInfo.isFirstDraw = false;
            else
                if exist('gaitPos','var')
                    set( drawInfo.axisTitle, 'String', ...
                         [ 'Gait Phase Position: ' num2str(gaitPos(i), ...
                         '%3.3f') ] );
                end
            end

            drawnow;
            % hold(animateStruct.ax,'off');

            % Save the images
            if isfield(drawInfo,'saveFrames') && drawInfo.saveFrames
                
                % Assign the file name for saved images.  Defaults to
                % 'untitled_animation if nothing is specified in drawInfo.
                if ~isfield(drawInfo,'fileName')
                    fileName = 'untitled_animation';
                else
                    fileName = drawInfo.fileName;
                end
                
                % DPI for saving the images
                dpi = 100;
                
                % Save the current animation frame to disk.
                animateStruct = save_frame_to_file(animateStruct, ...
                    fileName, dpi );
            end
        end

    end
end

% Helper function for reseting the figures after deciding to no longer plot
% something (snake, module axes, body frame axes)
function [animateStruct,drawInfo] = resetAnimation( animateStruct,...
                                                    drawInfo )
    % Nuke the axis and start over
    cla(animateStruct.ax);
    
    % Clear the fields for the modules
    if isfield(animateStruct,'h') 
        animateStruct = rmfield(animateStruct,'h');
    end
    
    % Clear the fields for the module axes
    if isfield(animateStruct,'x') 
        animateStruct = rmfield(animateStruct,{'x','y','z'});
    end
    
    % Clear the fields for the body frame axes
    if isfield(animateStruct,'body_x')
        animateStruct = rmfield(animateStruct,{'body_x',...
                                               'body_y',...
                                               'body_z'});
    end
    drawInfo.isFirstDraw = true;
end