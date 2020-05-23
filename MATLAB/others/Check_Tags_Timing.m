clear
close all
clc

num_Rep      = 2000;            % number of tag sending
elapsed_Time = nan(2, num_Rep); % empty array for storing the results
%read_data    = nan(2, num_Rep); % empty array for storing the results

ioObj   = io64;
% initialize the interface to the inpoutx64 system driver
status  = io64(ioObj);

% if status = 0, you are now ready to write and read to a hardware port
% let's try sending the value=1 to the parallel printer's output port (LPT1)
if status ~= 0
    error('inp/outp installation failed');
end
address   = hex2dec('c100'); % standard LPT1 output port address

for iRep = 1 : num_Rep
    
    tic
    
    tag_Value = randi([2 15], 1);
    io64(ioObj , address, tag_Value);   % output command
    elapsed_Time(1, iRep) = toc;
    
    pause(0.4)
    % now, let's read that value back into MATLAB
    tag_Value = 0;
    tic
    io64(ioObj , address, tag_Value);   % output command
    elapsed_Time(2, iRep) = toc;
    
    %     read_data(1, iRep)            = tag_Value;
    %     tic
    %     read_data(2, iRep)            = io64(ioObj, address);
    %     elapsed_Time(2, iRep) = toc;
    
    
end

save(['elapsed_Time_data_4F_' date], 'elapsed_Time')