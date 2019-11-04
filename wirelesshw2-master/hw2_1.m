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
 
x_BS = sqrt(3)*[0,     -250, 250, -500,  0  , 500 , -250, 250, -500, 500, -250, 250, -500, 0,  500,-250, 250,   0];
y_BS =         [-1000, -750, -750, -500,-500, -500, -250, -250, 0  , 0  , 250, 250 , 500, 500, 500, 750, 750, 1000];
%location of other 18 BS

[xv,yv,xq,yq]=get_cell(0,0);
figure

plot(xv,yv) % polygon
axis equal

hold on
plot(0,0,'k*') % points inside
plot(xq,yq,'ro') % points inside
title('figure 1-1')
xlabel('x(m)')
ylabel('y(m)')
hold off

d_central_BS = sqrt( (xq-0).^2+(yq-0).^2 );
RCpower = g_of_d(BSheight, MSheight , d_central_BS).*GT.*GR.*BSpower;
RCpower_db = linear_to_db(RCpower);

%calculate interference
xq_rep = repmat(xq' , 1, 18)';
yq_rep = repmat(yq' , 1, 18)';
x_BS_rep = repmat(x_BS' , 1 , 50);
y_BS_rep = repmat(y_BS' , 1 , 50);

d_matrix =  sqrt( ( (xq_rep-x_BS_rep).^2 + (yq_rep-y_BS_rep).^2 ));
N = repmat(N,1,50);

I_matrix = g_of_d(BSheight, MSheight , d_matrix).*GT.*GR.*BSpower;
I = sum(I_matrix);
I_db = linear_to_db(I);

figure,plot(d_central_BS , RCpower_db ,'o'); %received power in dB
xlabel('distance(m)');  
ylabel('received power(dB)')  
title('figure 1-2');  

figure,plot(d_central_BS , mySINR(RCpower ,N , I),'o'); %SINR in dB
xlabel('distance(m)');  
ylabel('SINR(dB)')  
title('figure 1-3'); 