function D = CalculateFlowMatrix(prevFrame, currFrame)

if length(size(currFrame)) == 2
    I0 = im2double(prevFrame);
    I1 = im2double(currFrame);
else
    I0 = im2double(rgb2gray(prevFrame));
    I1 = im2double(rgb2gray(currFrame));
end

I0 = single((I0-min(I0(:))) ./ (max(I0(:)) - min(I0(:))));
I1 = single((I1-min(I1(:))) ./ (max(I1(:)) - min(I1(:))));

[M,N] = size(I0);
levels = [4,2,1];
um = zeros(2,2,'single'); 
vm = um;
pli = zeros(2,2,'single');

for gp = levels
    fs = fspecial('gaussian',[5 5],0.8);

    wI0 = imresize( conv2(double(I0),fs,'same'),size(I0)/gp,'bilinear');
    wI1 = imresize( conv2(double(I1),fs,'same'),size(I0)/gp,'bilinear');
    [M,N] = size(wI0);

    p11 = imresize(pli,size(I0)/gp,'bilinear');
    p12 = p11; p21 = p11; p22 = p11;

    [ um,vm ] = resizeFlow( um,vm,ceil(size(I0)./gp) );

    for warped = 1:10
        D=zeros(M,N,2);
        D(:,:,1) = um; D(:,:,2) = vm;
        Iw1 = imwarp(wI1,D); % the effect of bound.

        residual = sqrt((Iw1-wI0).^2+1e-10);
        dd = (Iw1-wI0)./sqrt((Iw1-wI0).^2+1e-10);
        [g1x,g1y] = gradient(Iw1);
        Iw1x = g1x .*dd;
        Iw1y = g1y .*dd;

        grad = Iw1x.*Iw1x+Iw1y.*Iw1y;
        rho_c = (residual - Iw1x.*um-Iw1y.*vm);
        [um,vm,p11,p12,p21,p22] = tvl1_optimization(um,vm,grad,rho_c,Iw1x,Iw1y,p11,p12,p21,p22);    
    end

end
D = zeros(M,N,2);
D(:,:,1)=um; 
D(:,:,2)=vm;    
end
