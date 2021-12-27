
%% Select the file need to be corrected
if exist('filePath','var') && ischar(filePath)
    % test if valid path:
    % isempty(regexp(filePath, '^(?:[a-zA-Z]\:|\\\\[\w\.]+\\[\w.$]+)\\(?:[\w]+\\)*\w([\w.])+$', 'once'))
    [InputFile,filePath] = uigetfile('*.bin','Select bin file',filePath);
else
    [InputFile,filePath] = uigetfile('*.bin','Select bin file');
end
%%
[~,OutputFile,Extension] = fileparts(InputFile); % Splits the input file into path-name-extension
% corrected_file_name = [filePath,OutputFile];
corrected_file_name = [OutputFile,'corrected',Extension];

fileToOpen = fullfile(filePath,InputFile);
fid_r = fopen(fileToOpen);
lineSize = 2883584; % 1 line size in bytes
%% Reading  
srtOfLns = find(fread(fid_r, 200000*4,'uint32','l')==(hex2dec('00000050')))-1;
fclose(fid_r);
fid_r = fopen(fileToOpen);
fseek(fid_r,(srtOfLns)*4,'bof'); %first 80
endOfFile = 1;
maxLineToRead = 743;
lineNumberIndex = 1; % lineNumber
while (~feof(fid_r))&&(lineNumberIndex<maxLineToRead)
    srtngPosition = ftell(fid_r);
    h1_80(lineNumberIndex) = fread(fid_r,1,'uint16','l'); % 80
    h2_Rfu(lineNumberIndex) = fread(fid_r,1,'uint16','l'); % RFU
    h3_lnNmbr(lineNumberIndex) = fread(fid_r,1,'uint16','l'); %
    h4_Rfu2(lineNumberIndex) = fread(fid_r,1,'uint16','l');
    h5_plssPrLn(lineNumberIndex) = fread(fid_r,1,'uint16','l');
    h6_smpsPrPls(lineNumberIndex) = fread(fid_r,1,'uint16','l');
    h7_TmMs(lineNumberIndex) = fread(fid_r,1,'uint16','l');
    h8_TmLs(lineNumberIndex) = fread(fid_r,1,'uint16','l');
    pulsesPerLine = h5_plssPrLn(lineNumberIndex);
    samplesPerPulse = h6_smpsPrPls(lineNumberIndex);

    for pulseNumberIndex = 1:pulsesPerLine
        chA_nme(lineNumberIndex,pulseNumberIndex) = fread(fid_r,1,'uint8'); % Channel name A
        chB_nme(lineNumberIndex,pulseNumberIndex) = fread(fid_r,1,'uint8'); % Channel name B
        pulseNumber(lineNumberIndex,pulseNumberIndex) = fread(fid_r,1,'uint16','l');
        time_MSW_p(lineNumberIndex,pulseNumberIndex) = fread(fid_r,1,'uint16','l');
        time_LSW_p(lineNumberIndex,pulseNumberIndex) = fread(fid_r,1,'uint16','l');
        ch_a(lineNumberIndex,pulseNumberIndex,:) = fread(fid_r,samplesPerPulse,'uint16','l');
        ch_b(lineNumberIndex,pulseNumberIndex,:) = fread(fid_r,samplesPerPulse,'uint16','l');
        
    end   
    % add motion data
    position = ftell(fid_r);
    motion_data_size = lineSize-(position- srtngPosition); 
    motionData(lineNumberIndex,:) = fread(fid_r,motion_data_size);
    
    endLinePosition = ftell(fid_r);  
    sze = endLinePosition - srtngPosition;
    seek_size = lineSize-sze;
    fseek(fid_r,seek_size,'cof');
%     srtOfLns = srtOfLns + 720896 ;
%     endOfFile = fseek(fid_r,(srtOfLns)*4,'bof');
    lineNumberIndex = lineNumberIndex+1
end
%% Correction
[~, ps] = max(pulseNumber(1,:)==0);
%pulse Number correction
pn = pulseNumber.';
pulseNumber_crtd=reshape([pn(ps:end), NaN(1, ps-1)], size(pn)).' ; 
%channelA name correction
chA_nme = chA_nme.';
chA_nme_crtd = reshape([chA_nme(ps:end), NaN(1, ps-1)], size(chA_nme)).' ; 
%channelB name correction
chB_nme = chB_nme.';
chB_nme_crtd = reshape([chB_nme(ps:end), NaN(1, ps-1)], size(chB_nme)).' ; 
%time_MSW_p correction
time_MSW_p = time_MSW_p.';
time_MSW_p_crtd = reshape([time_MSW_p(ps:end), NaN(1, ps-1)], size(time_MSW_p)).' ;
%time_LSW_p correction
time_LSW_p = time_LSW_p.';
time_LSW_p_crtd = reshape([time_LSW_p(ps:end), NaN(1, ps-1)], size(time_LSW_p)).' ;
%cha data correction
% [~, ~, x] = size(ch_a);
x =  size(ch_a,3)
for j  = 1:x
    ch_aa = ch_a(:,:,j);
    ch_aa  = ch_aa.';
    ch_a_crtd(:,:,j)= reshape([ch_aa(ps:end), NaN(1, ps-1)], size(ch_aa)).' ;
end
% [~, ~, y] = size(ch_b);
y = size(ch_b,3);
for k  = 1:y
    ch_bb = ch_b(:,:,k);
    ch_bb  = ch_bb.';
    ch_b_crtd(:,:,k)= reshape([ch_bb(ps:end), NaN(1, ps-1)], size(ch_bb)).' ;
end
%% Writing
[fid_w, errmsg_w] = fopen(corrected_file_name,'w');
l= 1;
for l = 1:maxLineToRead-1
    fwrite(fid_w,h1_80(l),'uint16','l');
    fwrite(fid_w,h2_Rfu(l),'uint16','l');
    fwrite(fid_w,h3_lnNmbr(l),'uint16','l');
    fwrite(fid_w,h4_Rfu2(l),'uint16','l');
    fwrite(fid_w,h5_plssPrLn(l),'uint16','l');
    fwrite(fid_w,h6_smpsPrPls(l),'uint16','l');
    fwrite(fid_w,h7_TmMs(l),'uint16','l');
    fwrite(fid_w,h8_TmLs(l),'uint16','l');
    for pulseNumberIndex = 1:pulsesPerLine
        fwrite(fid_w,chA_nme_crtd(l,pulseNumberIndex),'uint8','l');
        fwrite(fid_w,chB_nme_crtd(l,pulseNumberIndex),'uint8','l');
        fwrite(fid_w,pulseNumber_crtd(l,pulseNumberIndex),'uint16','l');
        fwrite(fid_w,time_MSW_p_crtd(l,pulseNumberIndex),'uint16','l');
        fwrite(fid_w,time_LSW_p_crtd(l,pulseNumberIndex),'uint16','l');
        fwrite(fid_w,ch_a_crtd(l,pulseNumberIndex,:),'uint16','l');
        fwrite(fid_w,ch_b_crtd(l,pulseNumberIndex,:),'uint16','l');
    end
%     fwrite(fid_w,motionData(l,:),'uint16','l');
    fwrite(fid_w,motionData(l,:));   
    l = l+1;

end

%%
fclose('all');

