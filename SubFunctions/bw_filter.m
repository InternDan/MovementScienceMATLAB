function [smooth] = bw_filter(data,Fs,Fc,type,order)

% bw_filter.m is a butterworth digital filter.
%
% ------
%
% Calling convention:
%
%   [smooth]=bw_filter(data,Fs,Fc,type,order)
% -------
%
% Inputs:
%
%   data - array raw data. However, the array can have no more than 3 dimensions.
%
%   Fs - sample frequency
%
%   Fc - cut-off frequency
%
%   type - filter type low, high, bandpass
%   
%   order - represents order of the filter (e.g., 2, 3, 4, etc)
% -------
%
% Outputs:
%
%   smooth - array of fitlered data the same size as the input data.
% -------
%
% Dependencies: None
% -------
%
% Original Author: Brian Umberger, ASU
% Modified By: Dan Leib
% Last modified: 7/6/10

if nargin == 3
   type = 'low';
   order = 2;
elseif nargin == 4
   order = 2;
end

Fs=Fs./2;       
Fc=Fc/(sqrt(2)-1)^(0.5/order); 
type = lower(type);

TF = strcmpi(type,'low');

if TF == 1
    [B,A]=butter(order,Fc/Fs);              % low-pass filter.
elseif TF == 0
    [B,A]=butter(order,Fc/Fs,'high');       % high-pass filter. 
else
    [B,A]=butter(order,Fc/Fs);              % bandpass filter.
end

[rows columns layers]=size(data);
for j=1:columns
  for k=1:layers 
    smooth(:,j,k) = filtfilt(B,A,data(:,j,k));
  end
end