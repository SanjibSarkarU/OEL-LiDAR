%% only take corrected LiDAR data
% fileToOpen = 'QP2Datacorrected_withoutMotionData.bin';
fileToOpen = 'QP2Datacorrected.bin';
fid = fopen(fileToOpen);
maxLinesToRead = 742;
lineSize = 2883584; % one line size of the corrected data in bytes
% for line = 1:maxLinesRead
j= 1;
tic
while (~feof(fid)&&(j<maxLinesToRead))
    srtngPosition = ftell(fid);
    header = fread(fid,8,'uint16','l');
    lineNumber = header(3);
    pulsesPerLine = header(5);
    samplesPerPulse = header(6);
    for i = 1:pulsesPerLine
        fseek(fid,2,'cof');
        pulseNumber(j,i) = fread(fid,1,'uint16','l'); % pulse number
        timeStamp(j,i) = (fread(fid,1,'uint16','l'))* 2^16 + fread(fid,1,'uint16','l');
        AA(j,i,:) = max(fread(fid,samplesPerPulse,'uint16','l')); %read pulse data chA  
        BB(j,i,:) = max(fread(fid,samplesPerPulse,'uint16','l')); %read pulse data chB
    end
    endLinePosition = ftell(fid);
    sze = endLinePosition - srtngPosition;
    seek_size = lineSize-sze;  
    fseek(fid,seek_size,'cof');
    j = j+1
end
fclose(fid );
lidarTimeStampPlot(timeStamp); 

figure()
% subplot(3,1,1)
imagesc(AA);
xlabel('pulses')
ylabel('lines')

title('corrected file');
colormap gray
toc

