function [m] = lidarTimeStampPlot(timeStamp)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
figure()
% timeStamp = timeStamp';
% x = timeStamp(:);
% % time_stp= timeStamp(2)- timeStamp(1);
% % jump = find(diff([0; x]) > time_stp,'first'); 
% % disp(jump)
% % xx = x(1775:1785);
% plot(x)
%%
[line,pulse] = size(timeStamp);

for i = 1:line
%     drawnow
    plot(1:pulse,timeStamp(i,:),'r');    

end
m = 'done';
end

