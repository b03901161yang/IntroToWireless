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
 
x_BS = sqrt(3)*[0,0,     -250, 250, -500,  0  , 500 , -250, 250, -500, 500, -250, 250, -500, 0,  500,-250, 250,   0];
y_BS =         [0,-1000, -750, -750, -500,-500, -500, -250, -250, 0  , 0  , 250, 250 , 500, 500, 500, 750, 750, 1000];
%location of 19 BS

xv = zeros(7,19);
yv = zeros(7,19);
xq = zeros(19,50);
yq = zeros(19,50);


hold on
for i = 1:19
    [xv(:,i),yv(:,i), xq(i,:) , yq(i,:)] =get_cell( x_BS(i) , y_BS(i) );
    plot( xv(:,i), yv(:,i) )
    axis equal
    
    plot(x_BS(i),y_BS(i),'k*')
    plot(xq(i,:),yq(i,:),'ro')
end
title('figure B-1') 
xlabel('x(m)')
ylabel('y(m)')
hold off

%----------------------------------------
d_nearest_BS = zeros(19,50);

for i =1:19
    for j = 1:50
        d_nearest_BS(i,j) = sqrt( (xq(i,j)- x_BS(i) )^2 + (yq(i,j) - y_BS(i) )^2 );
    end
end

BS_RCpower = g_of_d(BSheight, MSheight , d_nearest_BS).*GT.*GR.*MSpower;
BS_RCpower_db = linear_to_db(BS_RCpower);


figure,plot(d_nearest_BS , BS_RCpower_db ,'bo'); %received power in dB
xlabel('distance(m)');  
ylabel('received power(dB)')  
title('figure B-2');  

%calculate interference from 19*50-1 points
xq_temp = reshape(xq ,1,19*50);
yq_temp = reshape(yq ,1,19*50);
d = zeros(19,19*50);
my_power = zeros(19,50);
for i=1:19
    for j =1:19*50
        d(i,j) =  sqrt( (xq_temp(j)- x_BS(i) )^2 + ( yq_temp(j) - y_BS(i) )^2 );
    end
end

total_power_matrix = g_of_d(BSheight, MSheight , d).*GT.*GR.*MSpower;
total_power = sum(total_power_matrix,2);
total_power = repmat(total_power , 1 ,50);
I = total_power - BS_RCpower;

N = repmat(N,19,50);
figure,plot(d_nearest_BS , mySINR(BS_RCpower ,N , I),'bo'); %SINR in dB
xlabel('distance(m)');  
ylabel('SINR(dB)')  
title('figure B-3'); 