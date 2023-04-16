function simulate_from_shape(save_path, num_particles)
%     [grid, probs, start_radius, description] = start_from_line(19, num_particles);
%     [grid, probs, start_radius, description] = start_from_circle(20, num_particles);
    [grid, probs, start_radius, description] = start_from_modified_circle(20, num_particles);

    hit_points = string(zeros(num_particles, 1));
    parfor j=1:num_particles
        [new_x, new_y] = simulate_single_particle_hit(grid, ...
                start_radius);
        new_key = xy_to_str(new_x, new_y);
        hit_points(j) = new_key;
    end

    for j=1:num_particles
        key = hit_points(j);
        probs(key) = probs(key) + 1/num_particles;
    end
    save(save_path, "probs", "description", '-mat')
end

function str = xy_to_str(x,y)
    str = compose("%d, %d", [x,y]);
end

function [grid, probs, start_radius, description] = start_from_line(length, num_particles)
    N = 4 * length * length;
    grid = zeros(N, N);
    grid(N/2 :N/2 +length, N/2) = 2;

    probs = containers.Map;
    for x=N/2 :N/2 +length
        probs(xy_to_str(x, N/2)) = 0;
    end
    start_radius = 3*length;
    description = ...
        sprintf("starting from line of length %d \n starting_radius %d \n num particles %d", ...
        length, start_radius, num_particles);
end

function [grid, probs, start_radius, description] = start_from_circle(radius, num_particles)
    N = 4 * radius;
    % Create a meshgrid of coordinates
    [x,y] = meshgrid(1:N);
    
    % Define the center of the circle
    center = [N/2 N/2];
    
    % Create a logical mask for points inside the circle
    mask = (x-center(1)).^2 + (y-center(2)).^2 < radius^2;
    
    % Create a matrix of zeros
    grid = zeros(N);
    
    % Set the values inside the circle to 2
    grid(mask) = 2;

    probs_mask = ((x-center(1)).^2 + (y-center(2)).^2 < radius^2) ...
        .* ((x-center(1)).^2 + (y-center(2)).^2 >= (radius-1)^2);
    probs_mask = boolean(probs_mask);
    edge_points = [x(probs_mask) y(probs_mask)];

    probs = containers.Map;
    for i = 1: length(edge_points)
        x = edge_points(i, 1);
        y = edge_points(i, 2);
        probs(xy_to_str(x,y)) = 0;
    end
    start_radius = 3 * radius;
    description = sprintf("circle of radius %d \n grid size of %d \n particles were simulated from radius %d \n num particles %d",...
        radius, N, start_radius, num_particles);
end

function [grid, probs, start_radius, description] = start_from_modified_circle(radius, num_particles)
    N = 4 * radius;
    % Create a meshgrid of coordinates
    [y,x] = meshgrid(1:N);
    
    % Define the center of the circle
    center = [N/2 N/2];
    
    % Create a logical mask for points inside the circle
    mask = (x-center(1)).^2 + (y-center(2)).^2 < radius^2;
    
    % Create a matrix of zeros
    grid = zeros(N);
    
    % Set the values inside the circle to 2
    grid(mask) = 2;

    probs_mask = ((x-center(1)).^2 + (y-center(2)).^2 < radius^2) ...
        .* ((x-center(1)).^2 + (y-center(2)).^2 >= (radius-1)^2);
    
    % add another point on the edge of the circle
    added_x = center(1) + radius;  % 60
    added_y = center(2) + 1;  % 34
    probs_mask(added_x, added_y) = 1;
    grid(added_x, added_y) = 2;
    % continue as before
    probs_mask = boolean(probs_mask);
    edge_points = [x(probs_mask) y(probs_mask)];

    probs = containers.Map;
    for i = 1: length(edge_points)
        x = edge_points(i, 1);
        y = edge_points(i, 2);
        probs(xy_to_str(x,y)) = 0;
    end
    start_radius = 3 * radius;
    description = sprintf("circle of radius %d \n grid size of %d \n particles were simulated from radius %d \n num particles %d \n point added at (%d, %d)",...
        radius, N, start_radius, num_particles, added_x, added_y);
end
