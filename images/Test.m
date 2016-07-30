function Test()
    close all
    I = imread('balloon.jpg');
    I = double(I)/255;      %Convert uint8 to double    
    n = 100;

    J = HorizFuse(I,n);

    Jtag = cat(3, J(:,:,1)', J(:,:,2)', J(:,:,3)'); %Transpose across 2'nd dimension.

    K = HorizFuse(Jtag,n);

    K = cat(3, K(:,:,1)', K(:,:,2)', K(:,:,3)');  %Transpose back

    K = uint8(K*255); %Convert back to uint8
    figure;imshow(K);

%     imwrite(K, 'K.jpg');   
    centerK = K(1+size(I,1)-n:(size(I,1)-n)*2, 1+size(I,2)-n:(size(I,2)-n)*2, :);
    imwrite(centerK, 'K.jpg');   
    R = repmat(centerK, [7, 7]);
    figure;imshow(R);

end


function K = HorizFuse(I,n)
    h = linspace(0,1,n);  %Create ramp from 0 to 1 of 100 elements.

    im_w = size(I, 2); %Image width
    im_h = size(I, 1); %Image height

    Hy = repmat(h, [size(I, 1), 1, 3]); %Replicate h to fit image height.

    J = zeros(im_h, im_w*2-n, 3);
    J(:, 1:im_w-n, :) = I(:, 1:im_w-n, :); %Fill pixels from the left to overlap.
    J(:, im_w+1:end, :) = I(:, n+1:end, :);    %Fill pixels from the right of overlap.

    %Fill overlap with linear intepolation between right side of left image and left side of right image.
    J(:, im_w-n+1:im_w, :) = I(:, end-n+1:end, :).*(1-Hy) + I(:, 1:n, :).*Hy;

    K = zeros(im_h, im_w*3-n*2, 3);
    K(1:size(J,1), 1:size(J,2), :) = J;
    K(1:size(J,1), end-(im_w+n)+1:end, :) = J(1:size(J,1), end-(im_w+n)+1:end, :);
end
