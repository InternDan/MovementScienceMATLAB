function [ct] = interpolateAndWriteColorFrames(imgs,measuredTimes,desiredTimes,ct,zers,pth)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Expects imgs to be a cell array of nxmx3 color images. Interpolates using
%%interp1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cls=class(imgs{1});

desiredFramesPerChunk = 5;

measuredTimes = 1:length(measuredTimes);
desiredTimes = 1:length(measuredTimes)/length(desiredTimes):length(measuredTimes);
desiredTimesChunk = round(desiredFramesPerChunk*(length(desiredTimes)/length(measuredTimes)));

c = length(imgs);

for i = 1:desiredFramesPerChunk:c
   
   if i < c-desiredFramesPerChunk%can do full chunk
       clear r g b im
       for j = 1:desiredFramesPerChunk
           r(:,:,j) = imgs{i+(j-1)}(:,:,1);
           g(:,:,j) = imgs{i+(j-1)}(:,:,2);
           b(:,:,j) = imgs{i+(j-1)}(:,:,3);
       end
       r = permute(r,[3 1 2]);
       g = permute(g,[3 1 2]);
       b = permute(b,[3 1 2]);
       r = cast(interp1((i:i+desiredFramesPerChunk-1),double(r),i:length(measuredTimes)/length(desiredTimes):i+desiredFramesPerChunk-1),cls);
       r = permute(r,[2 3 1]);
       g = cast(interp1((i:i+desiredFramesPerChunk-1),double(g),i:length(measuredTimes)/length(desiredTimes):i+desiredFramesPerChunk-1),cls);
       g = permute(g,[2 3 1]);
       b = cast(interp1((i:i+desiredFramesPerChunk-1),double(b),i:length(measuredTimes)/length(desiredTimes):i+desiredFramesPerChunk-1),cls);
       b = permute(b,[2 3 1]);
       [a1 b1 c1] = size(b);
       for j = 1:c1
           clear im;
           im(:,:,1) = r(:,:,j);
           im(:,:,2) = g(:,:,j);
           im(:,:,3) = b(:,:,j);
           ct=ct+1;
           imwrite(im,fullfile(pth,[zers(1:end-length(num2str(ct))) num2str(ct) '.tif']));
       end
   else
       clear r g b im
       co=0;
       for j = i:c
           co=co+1;
           r(:,:,co) = imgs{j}(:,:,1);
           g(:,:,co) = imgs{j}(:,:,2);
           b(:,:,co) = imgs{j}(:,:,3);
       end
       if co > 1
           r = permute(r,[3 1 2]);
           g = permute(g,[3 1 2]);
           b = permute(b,[3 1 2]);
           r = cast(interp1((i:c),double(r),i:length(measuredTimes)/length(desiredTimes):c),cls);
           r = permute(r,[2 3 1]);
           g = cast(interp1((i:c),double(g),i:length(measuredTimes)/length(desiredTimes):c),cls);
           g = permute(g,[2 3 1]);
           b = cast(interp1((i:c),double(b),i:length(measuredTimes)/length(desiredTimes):c),cls);
           b = permute(b,[2 3 1]);
       end
       [a1 b1 c1] = size(b);
       for j = 1:c1
           im(:,:,1) = r(:,:,j);
           im(:,:,2) = g(:,:,j);
           im(:,:,3) = b(:,:,j);
           ct=ct+1;
           imwrite(im,fullfile(pth,[zers(1:end-length(num2str(ct))) num2str(ct) '.tif']));
       end
       
   end
end
