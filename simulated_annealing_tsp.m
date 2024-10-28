function simulated_annealing_tsp(tsp_file)  
    % 读取TSP文件  
    data = read_tsp(tsp_file);  
    city_coords = data.COORD_SECTION;  
    num_cities = size(city_coords, 1);  
      
    % 初始化参数  
    max_iter = 50000; % 最大迭代次数  
    temp = 5000; % 初始温度  
    cooling_rate = 0.99; % 降温速率  
      
    % 初始化当前解  
    current_path = randperm(num_cities);  
    current_cost = calculate_cost(current_path, city_coords);  
    best_path = current_path;  
    best_cost = current_cost;  
      
    % 模拟退火算法  
    for iter = 1:max_iter  
        % 生成新解  
        new_path = generate_neighbor(current_path, num_cities);  
        new_cost = calculate_cost(new_path, city_coords);  
          
        % 计算接受概率  
        delta_cost = new_cost - current_cost;  
        if delta_cost < 0 || exp(-delta_cost / temp) > rand  
            current_path = new_path;  
            current_cost = new_cost;  
              
            % 更新最优解  
            if current_cost < best_cost  
                best_path = current_path;  
                best_cost = current_cost;  
            end  
        end  
          
        % 降温  
        temp = temp * cooling_rate;  
          
        % 打印进度  
        if mod(iter, 1000) == 0  
            fprintf('Iteration %d: Best Cost = %.2f\n', iter, best_cost);  
        end  
    end  
      
    % 输出结果  
    disp('Optimal Path:');  
    disp(best_path + 1); % TSPLIB文件中的城市编号从1开始  
    disp(['Optimal Cost: ', num2str(best_cost)]);  
      
    % 绘制路径  
    figure;  
    hold on;  
    plot(city_coords(best_path, 1), city_coords(best_path, 2), 'r-', 'LineWidth', 2);  
    plot(city_coords(best_path(end), 1), city_coords(best_path(end), 2), 'ro'); % 回到起点  
    plot(city_coords(best_path(1), 1), city_coords(best_path(1), 2), 'ro'); % 起点  
    title('Optimal TSP Path');  
    xlabel('X Coordinate');  
    ylabel('Y Coordinate');  
    grid on;  
    hold off;  
end  
  
function data = read_tsp(file)  
    fid = fopen(file, 'r');  
    data = struct();  
    tline = fgetl(fid);  
    while ischar(tline)
        tline1 = split(tline,' ');
        if strcmp(tline1{1}, 'NAME:')  
            data.NAME = tline1{2};  
        elseif strcmp(tline1{1}, 'TYPE:')  
            data.TYPE = tline1{2};  
        elseif strcmp(tline1{1}, 'DIMENSION:')  
            data.DIMENSION = str2double(tline1{2});  
        elseif strcmp(tline1{1}, 'EDGE_WEIGHT_TYPE:')  
            data.EDGE_WEIGHT_TYPE = tline1{2};  
        elseif strcmp(tline, 'NODE_COORD_SECTION')  
            num_cities = data.DIMENSION;  
            data.COORD_SECTION = zeros(num_cities, 2);  
            for i = 1:num_cities  
                tline = fgetl(fid);  
                tokens = strsplit(tline);  
                data.COORD_SECTION(i,:) = [str2double(tokens{2}), str2double(tokens{3})];  
            end  
            break;  
        end  
        tline = fgetl(fid);  
    end  
    fclose(fid);  
end  
  
function cost = calculate_cost(path, coords)  
    num_cities = length(path);  
    cost = 0;  
    for i = 1:num_cities-1  
        cost = cost + pdist2(coords(path(i),:), coords(path(i+1),:));  
    end  
    % 回到起点  
    cost = cost + pdist2(coords(path(end),:), coords(path(1),:));  
end  
  
function new_path = generate_neighbor(path, num_cities)  
    % 交换两个随机城市生成新解  
    idx1 = randi(num_cities);  
    idx2 = randi(num_cities);  
    while idx1 == idx2  
        idx2 = randi(num_cities);  
    end  
    new_path = path;  
    new_path([idx1, idx2]) = new_path([idx2, idx1]);  
end