classdef MicroMachine < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        img_car;
        
        last_plot = [];
        
        location = zeros(2,1);
        velocity = 1;
        
%         angle=0;
%         step_angle = pi/8;
        
        % space [0, 2pi] in discretized in n_a discrete angles
        n_a = 16; 
        angles_vec;
        angle_idx = 1;
        angle;
        
    end
    
    methods
        
        % ----- Constructor
        function obj = MicroMachine(car_image_path, starting_location)
            
            % Load car image
            obj.img_car = imread(car_image_path);
            
            % Initialize location
            obj.location = starting_location;
            
            % Initialize angle
            obj.angles_vec = linspace(0, 2*pi, obj.n_a+1);
            obj.angles_vec(end) = []; % 2pi and 0 are the same
            obj.angle = obj.angles_vec(obj.angle_idx);
        end
        
        % ----- Move
        function [new_location, new_angle_idx] = move(obj)
            
            dis_x = obj.velocity * cos(obj.angle);
            dis_y = obj.velocity * sin(obj.angle);
            
            new_location = obj.location + [dis_x; dis_y];
            new_location = round(new_location);
            
            obj.location = new_location;
            
            new_angle_idx = obj.angle_idx;
        end
        
        % ----- Display car
        function h = display_car(obj)
            
            % delete last image
            if(~isempty(obj.last_plot))
                delete(obj.last_plot);
            end
            
            % rotate car according to current angle
            img_car_rot = imrotate(obj.img_car, -rad2deg(obj.angle), 'crop');
            
            % compute foreground in the rotated image
            foreground_mask = any(img_car_rot,3); 
            
            % offset in necessary for centering the image
            offset = round(size(img_car_rot,1)/2);
            
            % display foreground only (car) in current circuit
            obj.last_plot = image(obj.location(1)-offset,obj.location(2)-offset,img_car_rot, 'AlphaData', foreground_mask);
            
            h = obj.last_plot;
        end
        
        
        % ----- Car Action: Accelerate
        function accelerate(obj)
            obj.velocity = obj.velocity; %+ 1;
        end
        
        % ----- Car Action: Break
        function breaking(obj)
            obj.velocity = obj.velocity; %- 1;
        end
        
        % ----- Car Action: Steer Right
        function steer_right(obj)
            
            obj.angle_idx = obj.angle_idx + 1;
            if(obj.angle_idx > numel(obj.angles_vec))
                obj.angle_idx = 1;
            end
            
            obj.angle = obj.angles_vec(obj.angle_idx);
        end
        
        % ----- Car Action: Steer Left
        function steer_left(obj)
            
            obj.angle_idx = obj.angle_idx - 1;
            if(obj.angle_idx == 0)
                obj.angle_idx = numel(obj.angles_vec);
            end
            
            obj.angle = obj.angles_vec(obj.angle_idx);
            
        end
        
    end
    
end
