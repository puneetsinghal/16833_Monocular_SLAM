function [ animate_struct ] = save_frame_to_file( animate_struct, ...
    base_file_name, pixels_per_inch, file_type )
%SAVE_FRAME_TO_FILE Is a function designed to save files from a figure
%window that is passed in.  The file name is saved based on the
%base_file_name and is appended with a number that increments every time
%that figure is incremented.  This allows frames to be stitched into a
%movie using tools like ffmpeg.
%
%   animate_struct.is_new
%       A flag to indicate whether we create a new figure, or if we're
%       setting values on one that alread exists.  Not used by this
%       function, but used in draw_snake.m
%
%   animate_struct.h
%       An array of surface handles to all the surfaces in the snake.  Not
%       used by this function, but used in draw_snake.m
%
%   animate_struct.fig
%       The handle to the figure.  This is the figure that will be printed.
%       It is part of animate_struct so that that its easy to associate the
%       frame number counter with the proper figure.
%
%   animate_struct.frame_num
%       A counter that ticks up the number of images saved for this figure.
%       This number will get appended to the file with leading zeros,
%       allowing them to be stitched together later.  Each time a figure
%       gets called with this function, it will increment the counter by 1.
%
%
%   base_file_name 
%       The name of the file that will have frame numbers appended to it.
%       The file name will be base_file_name and for digits padded by
%       leading zeros.
%
%
%   pixels_per_inch 
%       The resolution of the saved image.  If you care about the actual
%       image size (in inches), it should be set before running this
%       function.
%
%
%   file_type
%       The file format to save as.  This should be a string in the form
%       that the print command uses, such as '-dpng' for PNG or '-depsc'
%       for EPS.
%
%   Dave Rollinson - Jan 2011


    %%%%%%%%%%%%%%%%%
    % Figure handle %
    %%%%%%%%%%%%%%%%%
    figure_flag = ['-f' num2str(animate_struct.fig)];

    
    %%%%%%%%%%%%%%%%%%
    % Default format %
    %%%%%%%%%%%%%%%%%%
    if nargin < 4
        file_type = '-dpng';    %PNG
        % file_type = '-depsc';   %EPS
        % file_type = '-dpdf';    %PDF
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Default pixels_per_inch %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 3
        pixels_per_inch = 100;
    end
    pixels_flag = ['-r' num2str(pixels_per_inch)];


    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Increment frame number %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isfield(animate_struct, 'frame_num');
        % If the field doesn't exist, initialize it to 1.
        animate_struct.frame_num = 1;
    else
        % Otherwise, increment by 1.
        animate_struct.frame_num = animate_struct.frame_num + 1;
    end
    
    % Add leading zeros and frame number to the file name
    file_name = strcat( base_file_name, ...
                        num2str(animate_struct.frame_num,'%04d') );
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save to file (finally!) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    print(figure_flag, pixels_flag, file_type, file_name);
    
end

