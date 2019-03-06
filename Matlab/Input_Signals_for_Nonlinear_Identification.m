% INPUT SIGNALS FOR NON-LINEAR IDENTIFICATION

% Initialize Matlab environment
clear, close, clc;

%% INPUT SIGNAL PARAMETERS
N = 500; % Number of samples
Th = 3; % Minimum Hold Time (in percent relative to N)
InputSignalType = 'APRBS'; % Valid values: BS, PRBS, APRBS, WhiteNoise
AmplRange = [-4 4]; % Peak2peak signal amplitude
FreqRange = [1 10]; % Frequency domain
FSpanDepth = 3; % Frequency Span Depth
ASpanDepth = 10; % Amplitude Span Depth

%% AUTOMATIC VARIABLES (do not edit)
Th = 0.01*Th*N; % Percent conversion
% Spans for random functions
FreqSpan = FreqRange(1):abs((FreqRange(2)-FreqRange(1)+1)/FSpanDepth):FreqRange(end); % Frequency Span
AmplSpan = AmplRange(1):abs((AmplRange(2)-AmplRange(1))/ASpanDepth):AmplRange(end); % Amplitude Span

%% INPUT SIGNAL GENERATION

% *************** Generate Signal (PRBS) *********************
SignalPRBS = zeros(N,1); % Initialization
curr = datasample(AmplRange,1); % Initial value
for i = 1:N
    if mod(i,datasample(FreqSpan,1)*Th) == 0
        curr = -1*curr;
    end
    SignalPRBS(i) = curr;
end
% ************************************************************

% **************** Generate Signal (APRBS) *******************
SignalAPRBS = SignalPRBS; % Initialization
curr = datasample(AmplSpan,1);
for i=1:(N-1)
    if SignalPRBS(i) ~= SignalPRBS(i+1)
       curr = datasample(AmplSpan,1);
    end
    SignalAPRBS(i) = curr;
end
SignalAPRBS(N) = SignalAPRBS(N-1);
% ************************************************************

% ******************* Generate Signal (BS) *******************
SignalBS = zeros(N,1); % Initialization
curr = datasample(AmplRange,1); % Initial value
for i = 1:N
    if mod(i,Th) == 0
        curr = -1*curr;
    end
    SignalBS(i) = curr;
end
% ************************************************************

% **************** Generate Signal (WhiteNoise) **************
SignalWhiteNoise = idinput(N,'rgs'); % Random Gaussian Signal
SignalWhiteNoise = SignalWhiteNoise/max(SignalWhiteNoise); % Normalization
SignalWhiteNoise = max(AmplRange)*SignalWhiteNoise; % Scaling
% ************************************************************

%% ASSIGN CHOSEN INPUT SIGNAL
eval(strcat('U = Signal',InputSignalType,';'));

%% DEFINE NON-LINEAR FUNCTION
t = min(U):0.01:max(U);
t = t(1:length(t)-1);
Sat = 1.2*atan(t); % Define non-linear function
Y = 1.2*atan(U); % Get non-linear function output
[Y_rep, Y_explored] = hist(Y,unique(Y)); % Count output occurrances
U_explored = tan(Y_explored/1.2); % Retrieve non-linear function input

%% PLOT VISUALIZATION ADJUSTMENTS
rndOffset_active = 0; % Set to 0 to deactivate random offset (activate for WhiteNoise)
plotSpan = 3.5; % Adjust occurrences plotting span
rndOffsetSpan = 0.5*min(Y):0.1:0.5*max(Y); % Random Offset Span

%% GENERATING OCCURRANCES HISTOGRAM
Y_plot = cell(length(Y_explored),1);
for i = 1:length(Y_explored)
    drct = sign(max(Y) + min(Y) - 2*Y_explored(i)); % Increment Direction
    if drct == 0
        drct = 1; % correct direction if sign function makes it null
    end
    Y_plot_temp = zeros(length(Y_rep(i)),1); % Initialization
    for j = 1:Y_rep(i)
        Y_plot_temp(j) = Y_explored(i) + drct*j*plotSpan/N;
    end
    Y_plot(i) = {Y_plot_temp};
end

%% PLOT INPUT SIGNAL
figure(1), ...
    subplot(2,1,1), plot(U,'k'), ...
    grid, ...
    xlabel('Samples [N]'), ylabel('u(k)'), ...
    title(strcat(InputSignalType,' input signal')), ...
    axis([0 N 1.2*min(U) 1.2*max(U)]);

%% PLOT NON-LINEAR FUNCTION WITH OCCURRENCES
figure(1), ...
    subplot(2,1,2), plot(t,Sat,'k'); % Plot non-linear function
    hold, grid;
    for i = 1:length(Y_explored) % Plot occurrences
        rndOffset = (datasample(rndOffsetSpan,1) + datasample(Y,1))/max(Y);
        plot(U_explored(i), rndOffset_active*rndOffset + cell2mat(Y_plot(i)),'k.');
    end
    clear i;
    xlabel('u(k-1)'), ylabel('y(k-1)'), ...
    title('Nonlinear function'), ...
    legend('Function', 'Explored input values', 'Location', 'northeastoutside');
    axis([1.1*min(U) 1.1*max(U) 1.2*min(Y) 1.2*max(Y)]);

%% CLEANING WORKSPACE
clear Th curr drct i j t Y_plot Sat ...
      rndOffset rndOffset_active FreqSpan ...
      AmplSpan rndOffsetSpan ASpanDepth ...
      FSpanDepth % clearing work variables