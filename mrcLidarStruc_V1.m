clc
tic;
% dataDir = 'C:\Users\w10122210\The University of Southern Mississippi\Ocean Exploration Lab - Documents\LIDAR\Data\2021\20210124 Blue Heron Raw\iverDiveG29-20m-2020-1216-gtg-closer_002';
% dataDir = 'C:\Users\w10122210\OneDrive - The University of Southern Mississippi\Documents\LIdar\LIDAR\Data\2021\20210124 Blue Heron Raw\iverDiveG29-20m-2020-1216-gtg-closer_002';
% fileName = 'QP2Data.bin';
% fileToOpen = [dataDir '\' fileName];
fileToOpen = 'QP2Datacorrected.bin';

fid = fopen(fileToOpen);

maxLineToRead = 740;
line = 1; % lineNumber
lineSize = 2883584; % one line size of uncorrected and corrected in bytes
%lineSize = 2904912; % one line size of the corrected data in bytes

lineHeader = struct('header',{},'ch_nmes',{},'pulseNumber',{},'timeStamp_pulse',{},...
                    'ch_A_pulseMax',{},'ch_B_pulseMax',{});

while (~feof(fid)&&(line<maxLineToRead))
    srtngPosition = ftell(fid);
    
    lineHeader(line).header = fread(fid,8,'uint16','l');
    pulsesPerLine = lineHeader(line).header(5); % 1780 pulses/line
    samplesPerPulse = lineHeader(line).header(6); % 400 samples/pulse
    for pulses= 1:pulsesPerLine
        lineHeader(line).ch_nmes(pulses,:) = fread(fid,2,'uint8');
%         lineHeader(line).ch_nme2(pulses) = fread(fid,1,'uint8');
        lineHeader(line).pulseNumber(pulses) = fread(fid,1,'uint16','l');
        lineHeader(line).timeStamp_pulse(pulses) = (fread(fid,1,'uint16','l'))* 2^16 + fread(fid,1,'uint16','l');
        
        [lineHeader(line).ch_A_pulseMax(:,pulses), lineHeader(line).ch_A_pulseMax_pos(:,pulses)] = max(fread(fid,samplesPerPulse,'uint16','l'));
        [lineHeader(line).ch_B_pulseMax(:,pulses), lineHeader(line).ch_B_pulseMax_pos(:,pulses)] = max(fread(fid,samplesPerPulse,'uint16','l'));

    end
    
    endLinePosition = ftell(fid);
   
    sze = endLinePosition - srtngPosition;
    seek_size = lineSize-sze;  
    lineHeader(line).motionData = fread(fid,seek_size);
    line = line+1
%     fseek(fid,seek_size,'cof');
end
fclose(fid);

lineHeader(line-1) = []; %lastt line emptty


A = vertcat(lineHeader.ch_A_pulseMax);
B = vertcat(lineHeader.ch_A_pulseMax_pos);

distance = ((B./2.5E9)*3E8/1.33)/2;
imagesc(A);
colormap gray
% figure()
% imagesc(B);

% x = B ;
% y = 1:741;
% z = distance 
% scatter3(x,y,z)

%% plot timeStamp
tme = vertcat(lineHeader.timeStamp_pulse);
lidarTimeStampPlot(tme)
toc