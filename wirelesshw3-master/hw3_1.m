temperature = 300; % 27,300k 
bw = 10*10^6; % 10M
%I = 0;
N = myNoise(300,bw);
GT_db = 14;
GR_db = 14;
BSpower_db = 33-30; % 33dBm
MSpower_db = 23-30; % 23dBm

GT = db_to_linear(GT_db);
GR = db_to_linear(GR_db);
BSpower = db_to_linear(BSpower_db);
MSpower = db_to_linear(MSpower_db);

BSheight = 51.5; %1.5+ 50
MSheight = 1.5;

n = 1;%number of ms

minSpeed = 1;
maxSpeed = 15;
minT = 1;
maxT = 6;

testTime = 900;
%location of 19 BS (modified from hw2)
x_BS = sqrt(3)*[-500, -500, -500, -250, -250, -250, -250,    0,   0,  0,    0,     0, 250,  250,  250,  250, 500, 500,  500];
y_BS =         [500 ,    0, -500,  750,  250, -250, -750, 1000, 500,  0, -500, -1000, 750 , 250, -250, -750, 500,   0, -500];

outer_x_BS = sqrt(3)*[-750, -750 , -750, -750, -500,  -500, -250 , -250,    0,    0,  250,  250,  500,  500, 750, 750, 750, 750];
outer_y_BS =         [ 750,  250 , -250, -750, 1000, -1000, 1250 ,-1250, 1500,-1500, 1250,-1250, 1000,-1000, 750, 250,-250,-750];

xv = zeros(7,19);
yv = zeros(7,19); %vertice of hexagon

outer_xv = zeros(7,18);
outer_yv = zeros(7,18);

%center cell
figure
hold on
%[~ , ~ , xq , yq] = get_cell( 0 , 0 , n);
xq(1) = 250;
yq(1) = 0;

for i = 1:19
    %use get_cell to get every ms in a cell
    [xv(:,i),yv(:,i), ~ , ~] = get_cell( x_BS(i) , y_BS(i) , n);
    
    plot( xv(:,i), yv(:,i))
    axis equal
    plot(x_BS(i),y_BS(i),'k*')  
end

for i = 1:19
    %label each cell with id
    mytext = text(x_BS(i)+15,y_BS(i)+15,int2str(i));
    mytext.FontSize = 12;
end
title('figure 3-1') 
xlabel('x(m)')
ylabel('y(m)')
hold off

%---------------------end 3-1

figure
hold on
for i = 1:19
    plot( xv(:,i), yv(:,i))
    axis equal
    plot(x_BS(i),y_BS(i),'k*')  
end

for i = 1:18
    [outer_xv(:,i),outer_yv(:,i), ~ , ~] = get_cell( outer_x_BS(i) , outer_y_BS(i) , n);
%     plot( outer_xv(:,i), outer_yv(:,i))
%     axis equal
%     plot(outer_x_BS(i),outer_y_BS(i),'k*')  
end

for i = 1:19
    mytext = text(x_BS(i)+15,y_BS(i)+15,int2str(i));
    mytext.FontSize = 12;
end

% for i = 1:18
%     %label each outer cell with id
%     mytext = text(outer_x_BS(i)+15,outer_y_BS(i)+15,int2str(i+19));
%     mytext.FontSize = 12;
% end

moving_time = ceil( unifrnd( minT-1 , maxT ,1)); %integer
mydir = unifrnd(0, 2*pi, 1); %my direction
speed = unifrnd(minSpeed,maxSpeed , 1); %double
connected_bs = 10; %id of connected bs

record = [0 10 10];

for t = 1:testTime
    if moving_time ~= 0
        speed_x = speed.*cos(mydir);
        speed_y = speed.*sin(mydir);
    else
        moving_time = ceil( unifrnd( minT-1 , maxT ,1)); %integer
        mydir = unifrnd(0, 2*pi, 1); %my direction
        speed_x = speed.*cos(mydir);
        speed_y = speed.*sin(mydir);
    end
    
    
        
    [next_connected_bs,xq,yq] = update_with_coordinates(xv,yv, outer_xv, outer_yv, x_BS , y_BS,outer_x_BS, outer_y_BS, xq , yq , speed_x , speed_y);
    if next_connected_bs ~= connected_bs
        disp_str = strcat( 'At t = ' , int2str(t)  , ',from cell:'  , int2str(connected_bs) , ' to cell:' , int2str(next_connected_bs));
        %disp_str = "at t = " + int2str(t)+ ", from cell " + int2str(connected_bs)+" to "+int2str(next_connected_bs); 
        %only for matlab2017
        disp(disp_str);
        record(:,:,size(record,3)+1 ) = [t connected_bs next_connected_bs];
        connected_bs = next_connected_bs;
    end
    
    hold on
    plot(xq,yq,'r.')
    hold off
    %pause(0.1)
    axis tight
    moving_time = moving_time - 1;
end

title('moving simlation') 
xlabel('x(m)')
ylabel('y(m)')
hold off

number_of_handovers = size(record,3)-1;

record_print = reshape(record,size(record,2),size(record,3));
record_print = record_print';
xlswrite('3-1',record_print)