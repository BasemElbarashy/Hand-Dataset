function displayGenerateData
% This function displays training data with annotations overlaid. Other
% datasets could be seen in the same way by changing the paths of image
% and annotation directories
uf = dir('training_data/images/*.jpg');
posCounter = 0;
negCounter = 0;
length(uf)
minArea = 1200;
ExpSize = [60 60];
showExtractedImage = 0;

for i = 555:length(uf)
    if(mod(i,30) == 0)
        display(i)
    end
    dot = strfind(uf(i).name,'.');
    imname = uf(i).name(1:dot-1);
    
    load(['training_data/annotations/' imname '.mat']);
    im = imread(['training_data/images/' uf(i).name]);
    if(showExtractedImage)
        figure(1);  imshow(im);
    end
    
    k=0;
    
    for j = 1:length(boxes)
        box = boxes{j};
        area = norm(box.a - box.b)* norm(box.b - box.c);
        if(area > minArea)
            k=k+1;
            p1x  = min([ box.a(1) box.b(1) box.c(1) box.d(1) ] );
            p2x  = max([ box.a(1) box.b(1) box.c(1) box.d(1) ] );
            p1y  = min([ box.a(2) box.b(2) box.c(2) box.d(2) ] );
            p2y  = max([ box.a(2) box.b(2) box.c(2) box.d(2) ] );
            centerPointX = (p1x + p2x)/2;
            centerPointY = (p1y + p2y)/2;
            hight = p2y-p1y;
            width = p2x-p1x;
            BoxLength = max([hight width]);
            I2 = imcrop(im,[centerPointY-(BoxLength/2) centerPointX-(BoxLength/2)...
                            BoxLength BoxLength]);
            I2 = imresize(I2,ExpSize);
            %BoxLength
            if(showExtractedImage)
                disp('Press any key to move onto the next image');
                figure(1)
                line([box.a(2) box.b(2)]',[box.a(1) box.b(1)]','LineWidth',3,'Color','y');
                line([box.b(2) box.c(2) box.d(2) box.a(2)]',[box.b(1) box.c(1) box.d(1) box.a(1)]','LineWidth',3,'Color','r');                
                figure(2); imshow(I2); pause;
            end
            imwrite(I2,strcat('pos/pos_',num2str(posCounter),'.png'));
            posCounter = posCounter+1;
            %disp(round(area))
        end
    end
    
    for j = 1:k
        
        for trial = 1:100
            isNeg = 1;
            px = (size(im,1)-ExpSize(1)).*rand(1,1) + ExpSize(1);
            py = (size(im,2)-ExpSize(1)).*rand(1,1) + ExpSize(1);
            
            for l = 1:length(boxes)
                box = boxes{l};
                th  = 2*max([ norm(box.a - box.b) norm(box.b - box.c) ]);
                if ( norm([px py] - (box.a+box.c)/2 ) < th ) 
                    isNeg = 0;
                end
            end
            
            if isNeg==1
                break;
            end
        end
        
        I3 = imcrop(im,[py px ExpSize(1) ExpSize(2)]);
        I3 = imresize(I3,ExpSize);
        imwrite(I3,strcat('neg/neg_',num2str(negCounter),'.png'));
        negCounter = negCounter+1;
        if(showExtractedImage)
            disp('Press any key to move onto the next image');
            figure(3);imshow(I3); pause;        
        end
    end

end