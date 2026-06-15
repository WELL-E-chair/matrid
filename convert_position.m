function r = convert_position(video,position)

cow_dataset = [];

frames = position(:,1)';
BB = position(:,2:5);

% interpolate over missing frames
all_frames = frames(1):frames(end);
Nall = length(all_frames);

% mark sequences of missed frames and prepare BB for interpolation
% (need to insert nan at missed frames)
tmp = nan(Nall,1);
BBl = nan(Nall,4);
Nf = length(frames);
for ii=1:Nf
    pos = find(all_frames==frames(ii));
    tmp(pos) = 1;
    BBl(pos,:) = BB(ii,:);
end

% do the interpolation here
nanx = isnan(tmp);
times = 1:numel(tmp);
% BB parameter one at a time
for ii=1:4
    x = BBl(:,ii);
    x(nanx) = interp1(times(~nanx), x(~nanx), times(nanx));
    BBl(:,ii) = x;
end

% and low pass filter
fps = video.FrameRate;
dt = 1/fps;
Fs = 1/dt;
f_high = 1;
Wn = (2*f_high)/Fs;
n_butter = 1;
[b,a] = butter(n_butter,Wn,'low');

N = height(BBl);
% make sure we have enough points to do the filtering
if N>(2*n_butter+1)
    BBf = filtfilt(b,a,BBl);
else
    BBf = nan(N,4);
end

cow_dataset.frames = frames;
cow_dataset.all_frames = all_frames;
cow_dataset.BBl = BBl;
cow_dataset.BBf = BBf;

r = cow_dataset;

end