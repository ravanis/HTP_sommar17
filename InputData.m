function InputData()
% Opens window to enter input data

prompt = {'Model type:','Number of E-fields:','Antenna power limit (% of 150 W):','Frequency(ies), MHz, one per row:'};
title = 'Inputs';
num_lines = [1,1,1,5];
defaultans = {'duke_tongue_salt','16','100','450'};
options.Resize = 'on';
[input] = inputdlg(prompt,title,num_lines,defaultans,options);

modelType = input{1};
nbrEfields = str2num(input{2});
PwrLimit = str2num(input{3})/100;
frequencies = input{4};
f = size(frequencies);
if f(1)==1
    freq = str2num(frequencies);
elseif f(1)>1
    for j = 1:f(1)
    freq_vec(j) = str2num(frequencies(j,:));
    end
end
