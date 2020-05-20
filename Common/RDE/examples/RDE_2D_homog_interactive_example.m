% -------------------------------------------------------------------------
% ****************** Tumor Heterogeneity Package **************************
% File:     RDE_2D_homog_interactive_example.m 
% Paper:    Everett et al. 'A tutorial review of mathematical techniques 
%           for quantifying tumor heterogeneity'. Math. Biosci. Eng, 2020
%           doi: 10.3934/mbe.2020207
% Date:     5-2020
% Info:     Demonstrates the 2D reaction diffusion (Fisher-Kolmogorov)
%           solver with spatially constant field parameters (D,rho and k),
%           in a user-interactive mode.  
% Inputs:         
%               
% Contact:  nph@email.arizona.edu, jtnardin@ncsu.edu 
% This software is in the public domain, furnished "as is", without 
% technical support, and with no warranty, express or implied, as to its 
% usefulness for any purpose.
% -------------------------------------------------------------------------
%%
disp('This example script demonstrates the RDE solver capability for spatially uniform coefficient fields (D,rho,kappa).');
close all
plt = input('Would you like to display the figures? (y/n) ','s');
if(strcmp(plt,'y'))
    plotting = 1;  % Display plots during simulation?
else
    plotting = 0; 
end

disp('Creating a default RDE solver')
% Set up the RDE solver object
R = RDE
disp('Now, we will finish setting up the solver by asking some questions.')

%% Set up spatial grid
Ngrid = input('How many spatial grid points (in ea. direction) would you like to use?\n(Hit Enter for default (256)) ');
if(isempty(Ngrid))
    Ngrid = 256;       % Number of grid points in ea. direction
end
xx = linspace(0,1,Ngrid);  
[xg,yg] = meshgrid(xx);  % Uniform grid on [0,1]^2  (Spatial units are cm)
R.grid = {xx,xx}; 

%% Set up time grid
Nt = input('How many time points would you like to use?\n(Hit Enter for default (50)) ');
if(isempty(Nt))
    Nt = 50;        % Number of time points to keep 
end
tmax = input('How many days would you like to simulate?\n(Hit Enter for default (3*365 days)) '); 
if(isempty(tmax))
    tmax = 3*365;   % Time (days)
end
t = linspace(0,tmax,Nt);
%%
disp('Generating initial condition and coefficient fields');
%% Set up initial condition
I0 = input('How many initial cells would you like to use?\n (Hit enter for default (5)) ');
if(isempty(I0))
    I0 = 5;        % Integral of intial cell density ("number of initial cells")
end
s = input('What standard deviation of the initial Gaussian cell distribution would you like to use?\n (Hit enter for default (0.01cm)) '); 
if(isempty(s))
    s  = 0.01;    % Std. dev of initial condition
end
initcond = @(x,y,xc,yc) I0*exp(-((x-xc).^2+(y-yc).^2)/(2*s^2))/(2*pi*s^2);
u0 = initcond(xg,yg,0.5,0.5);
if(plotting)
    thetafig = figure; set(thetafig,'Position',[thetafig.Position(1),thetafig.Position(2),1200,800]);
    subplot(2,2,1);
    imagesc(xx,xx,u0);axis image; set(gca,'YDir','normal'); colorbar;
    set(gca,'Position',[0.05,0.55,0.4,0.4])
    title(sprintf('Initial Condition (I0 = %f)',I0),'FontSize',14);
end
R.u0 = u0; 
%% isotropic diffusion coefficient D(x,y) == D
D = input('What diffusion coefficient would you like to use?\n (Hit enter for default (1e-6)) '); 
if(isempty(D))
    D = 1e-6; 
end
R.D = D*ones(Ngrid); 

if(plotting)
    figure(thetafig);subplot(2,2,2);
    imagesc(xx,xx,R.D);axis image; set(gca,'YDir','normal'); colorbar;
    set(gca,'Position',[0.55,0.55,0.4,0.4])
    title('Sample diffusion coefficient $D(x,y)$ (units cm$^2/$day)','FontSize',14);
end
%% Growth factor rho(x,y) == rho
rho = input('What growth factor would you like to use?\n (Units cells/day; hit enter for default (0.1)) '); 
if(isempty(rho))
    rho = 0.1; 
end
R.rho = rho*ones(Ngrid); 
if(plotting)
    figure(thetafig); subplot(2,2,3); 
    imagesc(xx,xx,R.rho);
    axis image;set(gca,'YDir','normal');colorbar;
    set(gca,'Position',[0.05,0.05,0.4,0.4])
    title('Sample growth rate $\rho(x,y)$ (units cells/day)','FontSize',14); 
end
%% Carrying capacity function kappa(x,y) == kappa
kappa = input('What carrying capacity would you like to use?\n (Units cells; hit enter for default (1e6) '); 
if(isempty(kappa))
    kappa = 1e6; 
end
R.kappa = kappa*ones(Ngrid); 
if(plotting)
    figure(thetafig); subplot(2,2,4);
    imagesc(xx,xx,R.kappa);axis image;set(gca,'YDir','normal');colorbar;
    kappaaxis = gca;
    set(gca,'Position',[0.55,0.05,0.4,0.4]);hold on;
    title('Sample carrying capacity function $\kappa(x,y)$','FontSize',14);
    xlabel('$x$'); ylabel('$y$'); zlabel('$\kappa(x,y)$ (Units cells/cm$^2$)','FontSize',14);
end
%% Solve
disp('Solving the RDE with the specified parameters.  This may take a moment!'); 
n = R.Solve(t);
N = n.TumorBurden; 
%% Plot one solution path and the estimated tumor burden over time

n.plot(1:Nt); 
figure; 
plot(t,N); title('Total tumor burden versus time');
ylabel('\# cells'); 
xlabel('Time (days)'); 
%% Save
fname = input('Enter a file name to save the results, or hit Enter to cancel.\nAccepted formats = .mat, .dat and .npy ','s');
if(~isempty(fname))
    format = fname(end-3:end); 
    if(~strcmp(format,'.mat')&&~strcmp(format,'.dat')&&~strcmp(format,'.npy'))
        error('Incorrect file format!'); 
    end
    if(strcmp(format,'.mat')||strcmp(format,'.dat'))
        save(fname,'n','R','rho','kappa','D','N');
    elseif(strcmp(format,'.npy'))
        % Export to .npy format 
        disp('Saving to .npy file (tumor cell density data only!)')
    end
end

fprintf('Done!\n');