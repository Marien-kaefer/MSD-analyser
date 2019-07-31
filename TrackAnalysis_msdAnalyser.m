clear();
close all;
clc;

%%
I = imread('Instructions-Mode-of-transport-options.PNG');
h1 = figure('numbertitle', 'off', 'Name', 'Instructions', 'OuterPosition', [620 600 800 500]);
imshow(I, 'Border', 'tight');
uiwait(msgbox('Please read the information given in the Instructions Window, then click OK to start the analysis'));

addpath('C:/Users/CCI.WIN764-1020150/Fiji.app/scripts');

fprintf('Determination of mode of movement\n');

[file,path] = uigetfile('*.xml');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end

[tracks, md] = importTrackMateTracks(fullfile(path,file), 'clipZ');
% % Debug only - check that tracks are imported
% tracks
% md

ma = msdanalyzer(2, md.spaceUnits, md.timeUnits);
ma = ma.addAll(tracks);
disp(ma)
% % Debug only - Plot trajectories
% figure('numbertitle', 'off', 'Name','Tracks')
% [hps, ha] = ma.plotTracks;
% ma.labelPlotTracks(ha);

ma = ma.computeMSD;
ma.msd

% % Debug only - check individual track MSD
% figure
% ma.plotMSD;

h2 = figure('numbertitle', 'off', 'Name','Mean Squared Distance - gray area: all tracks, black line: average', 'OuterPosition', [25 550 600 500]);
hmsd = ma.plotMeanMSD(gca, true);

% Ask user at which temperature the experiment was run
answer = inputdlg('At what temperature (°C) was the experiment run?', 'Sample', [1 50]);
x = str2double(answer{1})/100;
kT = 1.38064852 * 10^(-23) * (273.15 + x) ;
clear x

% Ask user which analysis method would be appropriate from here onwards
list = {'Brownian Motion','Transported Motion','Confined Motion'};
[indx,tf] = listdlg('PromptString','Which mode of transport does the MSD curve resemble most?',...
            'ListString',list,...
            'ListSize',[400,46],...
            'SelectionMode','single');

% Close instructions window
close(h1);

%% Brownian motion - free diffusion - http://tinevez.github.io/msdanalyzer/tutorial/MSDTuto_brownian.html   
if indx == 1

fprintf('Brownian Motion Analysis\n');

cla
ma.plotMeanMSD(gca, true)

mmsd = ma.getMeanMSD;
t = mmsd(:,1);
x = mmsd(:,2);
dx = mmsd(:,3) ./ sqrt(mmsd(:,4));
errorbar(t, x, dx, 'k')

[fo, gof] = ma.fitMeanMSD;
plot(fo)
ma.labelPlotMSD;
legend off

ma = ma.fitMSD;

good_enough_fit = ma.lfit.r2fit > 0.8;
Dmean = mean( ma.lfit.a(good_enough_fit) ) / 2 / ma.n_dim;
Dstd  =  std( ma.lfit.a(good_enough_fit) ) / 2 / ma.n_dim;

fprintf('Estimation of the diffusion coefficient from linear fit of the MSD curves:\n')
fprintf('D = %.3g ± %.3g (mean ± std, N = %d)\n', ...
    Dmean, Dstd, sum(good_enough_fit));
	
%% transported movements - http://tinevez.github.io/msdanalyzer/tutorial/MSDTuto_directed.html 
elseif indx == 2

fprintf("Transported motion analysis.\n'");   

A = ma.getMeanMSD;
t = A(:, 1); % delay vector
msd = A(:,2); % msd
std_msd = A(:,3); % we will use inverse of the std as weights for the fit
std_msd(1) = std_msd(2); % avoid infinity weight

ft = fittype('a*x + c*x^2');
[fo, gof] = fit(t, msd, ft, 'Weights', 1./std_msd, 'StartPoint', [0 0]);

hold on
plot(fo)
legend off
ma.labelPlotMSD

Dfit = fo.a / 4;
Vfit = sqrt(fo.c);

ci = confint(fo);
Dci = ci(:,1) / 4;
Vci = sqrt(ci(:,2));

fprintf('Parabolic fit of the average MSD curve with 95%% confidence interval:\n')

fprintf('D = %.3g [ %.3g - %.3g ] %s\n', ...
    Dfit, Dci(1), Dci(2), [md.spaceUnits '²/' md.timeUnits]);

fprintf('V = %.3g [ %.3g - %.3g ] %s\n', ...
    Vfit, Vci(1), Vci(2), [md.spaceUnits '/' md.timeUnits]);

%% confined movements - http://tinevez.github.io/msdanalyzer/tutorial/MSDTuto_confined.html 
elseif indx == 3

fprintf("Confined movement Analysis\n'");

ma = msdanalyzer(2, md.spaceUnits, md.timeUnits);
ma = ma.addAll(tracks);

% Debug only
% figure('numbertitle', 'off', 'Name','Mean MSD with linear curve fit for estimating the Diffusion constant')
% hmsd = ma.plotMeanMSD(gca, true);
 
%%% User input requested in line
answer = inputdlg('What percentage of the curve follows a linear increase (approximately)?', 'Sample', [1 50]);
x = str2double(answer{1})/100;
[fo, gof] = ma.fitMeanMSD( x );
plot(fo)
legend off
ma.labelPlotMSD

% ma = ma.fitLogLogMSD(0.5);
% ma.loglogfit
% 
% mean(ma.loglogfit.alpha)
% 
% r2fits = ma.loglogfit.r2fit;
% alphas = ma.loglogfit.alpha;
% 
% R2LIMIT = 0.8;
% 
% % Remove bad fits
% bad_fits = r2fits < R2LIMIT;
% fprintf('Keeping %d fits (R2 > %.2f).\n', sum(~bad_fits), R2LIMIT);
% alphas(bad_fits) = [];
% 
% % T-test
% [htest, pval] = ttest(alphas, 1, 0.05, 'left');
% 
% if ~htest
%     [htest, pval] = ttest(alphas, 1, 0.05);
% end
% 
% % Prepare string
% str = { [ '\alpha = ' sprintf('%.2f ± %.2f (mean ± std, N = %d)', mean(alphas), std(alphas), numel(alphas)) ] };
% 
% if htest
%     str{2} = sprintf('Significantly below 1, with p = %.2g', pval);
% else
%     str{2} = sprintf('Not significantly differend from 1, with p = %.2g', pval);
% end
% 
% figure
% hist(alphas);
% box off
% xlabel('\alpha')
% ylabel('#')
% 
% yl = ylim(gca);
% xl = xlim(gca);
% text(xl(2), yl(2)+2, str, ...
%     'HorizontalAlignment', 'right', ...
%     'VerticalAlignment', 'top', ...
%     'FontSize', 16)
% title('\alpha values distribution', ...
%     'FontSize', 20)
% ylim([0 yl(2)+2])
% 
% gammas = ma.loglogfit.gamma;
% gammas(bad_fits) = []; % discard bad fits, like for alpha
% 
% Dmean = mean( gammas ) / 2 / ma.n_dim;
% Dstd  =  std( gammas ) / 2 / ma.n_dim;
% 
% fprintf('Estimation of the diffusion coefficient from log-log fit of the MSD curves:\n')
% fprintf('D = %.2e ± %.2e (mean ± std, N = %d)\n', ...
%     Dmean, Dstd, numel(gammas));
%%
end

fprintf('All Done.');