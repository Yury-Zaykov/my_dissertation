clc;
clear all;
global HU_Pow CheckZoneHU ZoneUnWork cntZoneUnw

cnt_HU = 6;


CheckZoneHU(1, 1:cnt_HU) = [0 0 0 0 0 0];

cntZoneUnw(1, 1:cnt_HU) = [6 3 1 1 3 3];

ZoneUnWork(1:max(cntZoneUnw)*2+3, 1:cnt_HU) = 0;

% 1ГА
ZoneUnWork(1, 1) = 0;
ZoneUnWork(2, 1) = 30;
ZoneUnWork(3, 1) = 35;
ZoneUnWork(4, 1) = 50;
ZoneUnWork(5, 1) = 65;
ZoneUnWork(6, 1) = 78;
ZoneUnWork(7, 1) = 92;
ZoneUnWork(8, 1) = 110;
ZoneUnWork(9, 1) = 120;
ZoneUnWork(10, 1) = 250;
ZoneUnWork(11, 1) = 255;
ZoneUnWork(12, 1) = 267;
ZoneUnWork(13, 1) = 275;
ZoneUnWork(14, 1) = 300;

% 2ГА
ZoneUnWork(1, 2) = 10;
ZoneUnWork(2, 2) = 22;
ZoneUnWork(3, 2) = 28;
ZoneUnWork(4, 2) = 120;
ZoneUnWork(5, 2) = 140;
ZoneUnWork(6, 2) = 180;
ZoneUnWork(7, 2) = 250;
ZoneUnWork(8, 2) = 400;

% 3ГА
ZoneUnWork(1, 3) = 5;
ZoneUnWork(2, 3) = 75;
ZoneUnWork(3, 3) = 90;
ZoneUnWork(4, 3) = 150;

% 4ГА
ZoneUnWork(1, 4) = 20;
ZoneUnWork(2, 4) = 150;
ZoneUnWork(3, 4) = 160;
ZoneUnWork(4, 4) = 200;

% 5ГА
ZoneUnWork(1, 5) = 0;
ZoneUnWork(2, 5) = 20;
ZoneUnWork(3, 5) = 30;
ZoneUnWork(4, 5) = 50;
ZoneUnWork(5, 5) = 60;
ZoneUnWork(6, 5) = 85;
ZoneUnWork(7, 5) = 90;
ZoneUnWork(8, 5) = 100;

% 6ГА
ZoneUnWork(1, 6) = 0;
ZoneUnWork(2, 6) = 20;
ZoneUnWork(3, 6) = 30;
ZoneUnWork(4, 6) = 50;
ZoneUnWork(5, 6) = 60;
ZoneUnWork(6, 6) = 85;
ZoneUnWork(7, 6) = 90;
ZoneUnWork(8, 6) = 100;


HU_Pow(1, 1:cnt_HU + 1) = [290 150 73 180 55 96 0];
HU_Pow(1, cnt_HU+1) = sum(HU_Pow(1, 1:cnt_HU));

% Цикл перебора каждого ГА
for i = 1:1:cnt_HU
    % Присваеваем переменной HUP мощность ГА, который рассматриваем в данный момент
    HUP = HU_Pow(1, i);
    maxZone = cntZoneUnw(1, i) + 1;

    if (HUP >= 0 && HUP < ZoneUnWork(2, i))
        CheckZoneHU(1, i) = 1;
    else
        v = 2;
        u = 4;  
        for c = 2:1:maxZone
            if (HUP >= ZoneUnWork(v, i) && HUP < ZoneUnWork(u, i))
                CheckZoneHU(1, i) = c;
                break;
            end
            v = v + 2;
            u = u + 2;
        end
    end
end