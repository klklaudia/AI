clear, clc;

% 1. Wczytanie obrazów
a = imread('KS.tif');
a0 = imread('KS0.tif');
a30 = imread('KS30.tif');
a60 = imread('KS60.tif');
a90 = imread('KS90.tif');
a120 = imread('KS120.tif');
a150 = imread('KS150.tif');
a180 = imread('KS180.tif');

% 2. Przygotowanie maski wspólnego obszaru
[M, N, ~] = size(a);
common_area = true(M, N);
for k = 0:30:180
    rotated = imrotate(true(M, N), k, 'crop');
    common_area = common_area & rotated;
end


% 3. Biotyt
% wyróżnia się
binb = a(:,:,1) > 40 & a(:,:,1) < 150 & a(:,:,2) < 100 & a(:,:,3) < 40;
binb = bwareaopen(binb,4000);
SE = ones(20);
binb = imclose(binb, SE);
binb = imerode(binb, ones(10));
%imshow(uint8(binb).*a)


% 4. Nieprzezrozyste
images = {a0, a30, a60, a90, a120, a150, a180};
angles = 0;
SE = strel('disk', 5);
binn = ones(M, N); % do iloczynu logicznego
bink = zeros(M, N);

for i = 1:length(images)
    % ważna informacja ode mnie dla mnie:
    % jeśli zacznę przeglądać pliki to ich obracanie czy powiększanie
    % automatycznie się zapisuje i zmienia tutaj
    images{i} = imrotate(images{i}, angles, 'nearest', 'crop');
    background = imrotate(ones(M, N), angles, 'nearest', 'crop');
    background = uint8(1-background*255);
    angles = angles - 30;
    images{i}(:,:,1) = images{i}(:,:,1)+background*255;
    
    % nieprzezroczyste
    gray = rgb2gray(images{i}); 
    %subplot(4,2,i), imshow(images{i})
    tmp = gray < 30;
    binn = binn & tmp;
    binn(~common_area) = 0;
    %hsv = rgb2hsv(images{i});
    %subplot(2,4,i), imshow(hsv)    
end

% 5. Kwarc

hsv = rgb2hsv(images{6});
tmp_org = hsv(:,:,1) < 0.28 & hsv(:,:,2) < 0.1 & hsv(:,:,3) > 0.85;
% tmp = imreconstruct(tmp, tmp_org);
tmp = bwareaopen(tmp_org, 8000);
bink = bink | tmp;
tmp_rgb = uint8(bink).*a0;

%subplot(121), imshow(tmp_gray)
binszare = bink < 15 & tmp_rgb(:,:,3) > 160;
binszare = bwareaopen(binszare, 4000);
binczarne = bink & (tmp_rgb(:,:,1) + tmp_rgb(:,:,2) + tmp_rgb(:,:,3) > 0) & tmp_rgb(:,:,1) < 60;
binczarne = imclose(binczarne, SE);
binczarne = imfill(binczarne, 'holes');
binczarne = bwareaopen(binczarne, 4000);
bink = binczarne | binszare;

hsv = rgb2hsv(images{2});
% bez spoiwa i bez czarnych el.
tmp_org = hsv(:,:,2) < 0.15 & hsv(:,:,2) > 0.01; 
% alt. na pozostały kwarc
tmp_org = tmp_org | (hsv(:,:,1) > 0.2 & hsv(:,:,2) < 0.5 & hsv(:,:,2) > 0.2);
% poprawki
tmp_org = tmp_org | hsv(:,:,3) == 1;

tmp = imopen(tmp_org, SE);
tmp = imreconstruct(tmp, tmp_org);
tmp = bwareaopen(tmp, 8000);

tmp = medfilt2(tmp, [3 3]);
tmp = wiener2(tmp, [3 3]);
tmp = bwareaopen(tmp, 4000);
% edges = edge(tmp, 'Sobel');
% tmp = tmp & ~edges;
tmp_rgb = uint8(tmp).*a0;
tmp_rgb = abs(tmp_rgb(:,:,2) - tmp_rgb(:,:,3)) < 30 & (tmp_rgb(:,:,1) + tmp_rgb(:,:,2) + tmp_rgb(:,:,3) > 0); 
SE = strel('disk', 8);
tmp_org = tmp_rgb;
tmp_rgb = imclose(tmp_rgb, SE);
tmp_rgb = imreconstruct(tmp_rgb, tmp_org);
bink = bink | tmp_rgb;
bink(~common_area) = 0;

% kw = uint8(bink).*a0;
% imshow(kw)

% 6. Łączenie wyników
binn = bwareaopen(binn, 4000);
nieprzezroczyste = zeros(M, N, 3);
nieprzezroczyste(:,:,3) = binn;
%imshow(nieprzezroczyste)

bink = bwareaopen(bink, 4000);
kwarc = zeros(M, N, 3);
kwarc(:,:,2) = bink;

binb = bwareaopen(binb, 4000);
biotyt = zeros(M, N, 3);
biotyt(:,:,1) = binb;

wynik = nieprzezroczyste + kwarc + biotyt;
imshow(wynik)

imwrite(wynik,"C:\Users\PC\13powód\obrazy\406814\kamienie.jpg")
wynik = imread("C:\Users\PC\13powód\obrazy\406814\kamienie.jpg");

% 7. Nakładanie markerów
oryginal = a;
oryginal = oryginal - 50;
oryginal = uint8(common_area).*oryginal;
alpha = 0.5;
wynik2 = labeloverlay(oryginal, binb, 'Colormap', [1 0 0], 'Transparency', alpha);
wynik2 = labeloverlay(wynik2, binn, 'Colormap', [0 0 1], 'Transparency', alpha);
wynik2 = labeloverlay(wynik2, bink, 'Colormap', [0 1 0], 'Transparency', alpha);

figure;
imshow(wynik2);
imwrite(wynik2,"C:\Users\PC\13powód\obrazy\406814\kamienie2.jpg")

% 8. Obliczenie pól
skala = 200 / 180;

pole_kwarcu = bwarea(bink);
obszar_kwarc_mikrometry_kwadratowe = pole_kwarcu * skala^2;

pole_nieprzezroczystych = bwarea(binn);
obszar_nieprzezroczyste_mikrometry_kwadratowe = pole_nieprzezroczystych * skala^2;

pole_biotyt = bwarea(binb);
obszar_biotyt_mikrometry_kwadratowe = pole_biotyt * skala^2;