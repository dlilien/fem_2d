Qo=4e5/31556926;
Ho=1.0e3;
rho=910;
rho_w=1028;
a=0.3/31556926;
Bo=1.4688e8;
g=9.81;
Z=a^ (1/4)*(4*Bo)^ (3/4)/(rho*g*(1-rho/rho_w))^ (3/4);
UonL=(rho*g*Z*(1 - rho/rho_w)/(4*Bo))^ 3;
U=400/31556926;
L=Z*U/a;
qo=Qo/(U*Z);
ho=Ho/Z;
imax=21;
jmax=17;
nodes=imax*jmax;
nel=(imax-1)*(jmax-1)*2;
nrows=23040;
row=zeros(nrows,1);
col=zeros(nrows,1);
value=zeros(nrows,1);
phi=zeros(3,3);
% Initialize at zero ice velocity
ugrid=zeros(imax,jmax);
vgrid=zeros(imax,jmax);
u=zeros(nodes*2,1);
% Initialize
h=10^ 3/Z*ones(nodes,1);
havg=10^ 3/Z;
% Create the interpolation functions.
area=zeros(nel,1);
alpha=zeros(nel,3);
beta=zeros(nel,3);
count=0;
%
for n=1:nel
%
[lowtri, uptri]=lu([[xy(index(n,1),1) xy(index(n,2),1) xy(index(n,3),1)]'...
[xy(index(n,1),2) xy(index(n,2),2) xy(index(n,3),2)]' ones(3,1)]);
phi(:,1)=uptri\(lowtri\ [1 0 0]');
phi(:,2)=uptri\(lowtri\ [0 1 0]');
phi(:,3)=uptri\(lowtri\ [0 0 1]');
for k=1:3
alpha(n,k)=phi(1,k);
beta(n,k)=phi(2,k);
end
%
area(n)=abs(.5*det([1 1 1
xy(index(n,1),1) xy(index(n,2),1) xy(index(n,3),1)
xy(index(n,1),2) xy(index(n,2),2) xy(index(n,3),2)]));
% Perform loading of row and col arrays
for i=1:3
for j=1:3
row(count+1)=index(n,j)*2-1;
col(count+1)=index(n,i)*2-1;
row(count+2)=index(n,j)*2-1;
col(count+2)=index(n,i)*2;
row(count+3)=index(n,j)*2;
col(count+3)=index(n,i)*2-1;
row(count+4)=index(n,j)*2;
col(count+4)=index(n,i)*2;
count=count+4;
end
end
%
end
%


c=ones(nel,1);
c_old=zeros(nel,1);
loop=0;
while max((abs(c-c_old)./c)) > 0.01 && loop <50
loop=loop+1;
%
value=zeros(nrows,1);
F=zeros(2*nodes,1);
count=0;

for n=1:nel
%
% Effective diffusivity:
%
if loop==1
c_old(n)=c(n);
ux=0;
uy=0;
vx=0;
vy=0;
for i=1:3
ux=ux+u(index(n,i)*2-1)*alpha(n,i);
uy=uy+u(index(n,i)*2-1)*beta(n,i);
vx=vx+u(index(n,i)*2)*alpha(n,i);
vy=vy+u(index(n,i)*2)*beta(n,i);
end
if (ux^ 2+vy^ 2+((uy+vx)^ 2)/4 +ux*vy ) > 10^ (-15)
c(n)=havg*(ux^ 2+vy^ 2+((uy+vx)^ 2)/4 +ux*vy )^ (-1/3);
else
c(n)=havg*10^ 5;
end
end
hsq=area(:).*(h(index(:,1)).^2+h(index(:,2)).^2+h(index(:,3)).^2)/6;
for m=1:3
for n1=1:nel
F(index(n1,m)*2-1)=F(index(n1,m)*2-1)+alpha(n1,m)*rho*g/2*(1-rho/rho_w)*hsq(n1);
F(index(n1,m)*2)=F(index(n1,m)*2)+beta(n1,m)*rho*g/2*(1-rho/rho_w)*hsq(n1);
end
end
%
% Load matrix:
%
for i=1:3
for j=1:3
value(count+1)=area(n)*c(n)*(alpha(n,i)*alpha(n,j)+beta(n,i)*beta(n,j)/4);
value(count+2)=area(n)*c(n)*(beta(n,i)*alpha(n,j)/2+alpha(n,i)*beta(n,j)/4);
value(count+3)=area(n)*c(n)*(alpha(n,i)*beta(n,j)/2+beta(n,i)*alpha(n,j)/4);
value(count+4)=area(n)*c(n)*(beta(n,i)*beta(n,j)+alpha(n,i)*alpha(n,j)/4);
count=count+4;
end
end
% End loop over elements
end
D=sparse(row,col,value);
% Boundary conditions
bxcount=0;
bycount=0;
for j=1:(jmax-1) % left side
bxcount=bxcount+1;
D(Boundu(bxcount)*2-1,Boundu(bxcount)*2-1)=10^ 12;
F(Boundu(bxcount)*2-1)=0;
bycount=bycount+1;
D(Boundv(bycount)*2,Boundv(bycount)*2)=10^ 12;
F(Boundv(bycount)*2)=0;
end
for i=1:imax % top side
bxcount=bxcount+1;
bycount=bycount+1;
D(Boundu(bxcount)*2-1,Boundu(bxcount)*2-1)=10^ 12;
F(Boundu(bxcount)*2-1)=0;
D(Boundv(bycount)*2,Boundv(bycount)*2)=10^ 12;
F(Boundv(bycount)*2)=0;
end
for j=1:(jmax-1) % right side
bxcount=bxcount+1;
D(Boundu(bxcount)*2-1,Boundu(bxcount)*2-1)=10^ 12;
F(Boundu(bxcount)*2-1)=0;
end
F(gamma(18,17)*2)=-10^ 12;
F(gamma(19,17)*2)=-10^ 12;
F(gamma(20,17)*2)=-10^ 12;
F(gamma(21,17)*2)=-10^ 12;
% Solve the system for new velocity
u=D\F;
for i=1:imax
for j=1:jmax
ugrid(i,j)=u(gamma(i,j)*2-1);
vgrid(i,j)=u(gamma(i,j)*2);
end
end
sprintf('Iteration %d completed',loop)
end % end While statement
figure(1)
contourf(flipud(rot90(ugrid)))
figure(2)
contourf(flipud(rot90(vgrid)))
figure(3)
contourf(flipud(rot90(sqrt(ugrid.^2+vgrid.^2))))





