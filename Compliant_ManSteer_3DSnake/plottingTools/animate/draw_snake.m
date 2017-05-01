function [ animate_struct ] = draw_snake( animate_struct, ...
                                module_frame, module_len, module_dia)
% DRAW_SNAKE Draws a representation of the snake robot using capped
% cylinders.
%   
% [ animate_struct ] = draw_snake(animate_struct, 
%                                module_frames, module_len, module_dia)
%
%   module_frames
%       4x4xN set of transforms.  N is the number of modules.
%
%   module_len
%       Module length (in inches) for drawing the modules.
%
%   module_dia
%       Module diameter (in inches) for drawing the modules
%
%   animate_struct 
%       Struct with info about drawing the snake.  You can pass in a blank
%       struct the first time, by passing in struct() and the necessary
%       information will get filled in the first time thru.
%
%   animate_struct.fig
%       The handle to the figure that the snake gets drawn in.  If you
%       want, you can create a figure manually and save the handle here.
%
% Dave Rollinson
% 2010 - 2013 


%   THESE PROPERTIES BELOW GET SET INTERNALLY.  You probably don't need 
%   to worry about them.
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
%



    num_faces = 20; % Resolution of the cyclinder
    face_trim = .7; % Amount to shorten the cyclinder walls 
    faces = 1:num_faces+1;
    lo_res_mask = rem(faces,2)==1;

    % Get a unit cylinder at the origin, shift to be the center of the
    % module.
    [X_cylinder,Y_cylinder,Z_cylinder] = cylinder(module_dia/2, num_faces);      
    Z_cylinder = face_trim * module_len * Z_cylinder - (face_trim * module_len)/2; 
    
    % Get a unit sphere at the origin, scale it to the module diameter, 
    % and split it to become endcaps on either end of the cylinder.
    [X_sphere,Y_sphere,Z_sphere] = sphere(num_faces);
    X_sphere = -module_dia/2 * X_sphere(lo_res_mask,:);
    Y_sphere = -module_dia/2 * Y_sphere(lo_res_mask,:);
    Z_sphere = module_dia/2 * Z_sphere(lo_res_mask,:);
    
    % Split the sphere into hemispheres
    bottom_pts = find(Z_sphere(:,1)<=0);
    top_pts = find(Z_sphere(:,1)>=0);
    
    % Shift the hemispheres to the end of the cylinder
    X_sphere_bottom = X_sphere(bottom_pts,:);
    Y_sphere_bottom = Y_sphere(bottom_pts,:);
    Z_sphere_bottom = Z_sphere(bottom_pts,:) - (face_trim*module_len)/2;
    X_sphere_top = X_sphere(top_pts,:);
    Y_sphere_top = Y_sphere(top_pts,:);
    Z_sphere_top = Z_sphere(top_pts,:) + (face_trim*module_len)/2;
    
    % Concatenate the points into one set
    X_init = [X_sphere_bottom; X_cylinder; X_sphere_top];
    Y_init = [Y_sphere_bottom; Y_cylinder; Y_sphere_top];
    Z_init = [Z_sphere_bottom; Z_cylinder; Z_sphere_top];
    
    % Preallocate stuff for the transformations
    one_vector_cyl = ones( 1, size(X_init,2) );
    X = zeros(size(X_init));
    Y = zeros(size(Y_init));
    Z = zeros(size(Z_init));
    
    % If a figure handle is not yet specified, make a new figure
    if ~isfield(animate_struct,'fig')
        animate_struct.fig = figure(42);
    elseif ~isfield(animate_struct,'h')
        set(0,'CurrentFigure',animate_struct.fig);
    end
    
    % If there are no surface handles, plot everything from scratch
    if ~isfield(animate_struct,'h');
        
%         % Nuke other axes just in case
%         if isfield(animate_struct,'x')
%             animate_struct = rmfield(animate_struct,'x');
%         end
%         if isfield(animate_struct,'body_x')
%             animate_struct = rmfield(animate_struct,'body_x');
%         end
        
        for module = 1:size(module_frame,3)   
            
            % Transform the cylinder to the module's position and
            % orientation.
            T = module_frame(:,:,module);
            for i=1:size(X_init,1)
                rot_temp = T * [X_init(i,:); Y_init(i,:); Z_init(i,:); one_vector_cyl];
                X(i,:) = rot_temp(1,:);
                Y(i,:) = rot_temp(2,:);
                Z(i,:) = rot_temp(3,:);
            end

            % Draw the surface and store the surface handle
            animate_struct.h(module) = surf(X,Y,Z);
            
%             % Settings to speed up the animations
%             set( animate_struct.h(module), ...
%                  'FaceColor', 'Texture' );
 
            % If this is the head, make the module a different color
            if module==1
                color_new = zeros(size(get(animate_struct.h(module),'CData')));
                color_new(:,:) = repmat(.01,size(color_new,1),size(color_new,2));
                color_new(1,1:2) = .1;
                color_new(:,1) = .03;
                %color_new(:,:,1) = 1; color_new(:,:,2) = 0; color_new(:,:,3) = 0;
               % keyboard
                set(animate_struct.h(module),'CData',color_new);
%             elseif module > 11 
%                 color_new = zeros(size(get(animate_struct.h(module),'CData')));
%                 color_new(:,:) = repmat(.01,size(color_new,1),size(color_new,2));
%                 color_new(:,:,1) = 1; color_new(:,:,2) = 1; color_new(:,:,3) = 0;
%                 set(animate_struct.h(module),'CData',color_new);
%             elseif module == 11 % just for now! 'cause headLookLen = 10
%                 color_new = zeros(size(get(animate_struct.h(module),'CData')));
%                 color_new(:,:) = repmat(.01,size(color_new,1),size(color_new,2));
%                 color_new(:,:,1) = 0; color_new(:,:,2) = 1; color_new(:,:,3) = 1;
%                 set(animate_struct.h(module),'CData',color_new);
            else
                % Create a uniquely colored stripe so that the 'twist' of 
                % the modules is apparent.
                color_new = zeros(size(get(animate_struct.h(module),'CData')));
                color_new(:,1) = .03;
                set(animate_struct.h(module),'CData',color_new);
            end 
            
            if module==1
                hold on;
            end
         
        end

        animate_struct.ax = gca;
        axis equal;
        hold off;
        
    else

       for module = 1:size(module_frame,3)
            
            % Transform the cylinder to the module's position and
            % orientation.
            T = module_frame(:,:,module);
            for i=1:size(X_init,1)
                rot_temp = T * [X_init(i,:); Y_init(i,:); Z_init(i,:); one_vector_cyl];
                X(i,:) = rot_temp(1,:);
                Y(i,:) = rot_temp(2,:);
                Z(i,:) = rot_temp(3,:);
            end

            % Set the new positions of each cylinder
            set(animate_struct.h(module),'XData',X,'YData',Y,'ZData',Z);
        end    
    end

end
