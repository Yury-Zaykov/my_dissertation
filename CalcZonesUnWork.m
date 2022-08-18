% Функция установки нежелательных зон работы для каждого ГА
function CalcZonesUnWork(cnt_HU, Nom_P_HU)

    global ZoneUnWork_Pct ZoneUnWork cntZoneUnw
    
    % Заполняем массив в %
%     for k = 1:1:cnt_HU
%         ZoneUnWork_Pct(1, k) = 5 / 100;
%         ZoneUnWork_Pct(2, k) = 25 / 100;
%         ZoneUnWork_Pct(3, k) = 35 / 100;
%         ZoneUnWork_Pct(4, k) = 55 / 100;
%         ZoneUnWork_Pct(5, k) = 65 / 100;
%         ZoneUnWork_Pct(6, k) = 80 / 100;
%         ZoneUnWork_Pct(7, k) = 88 / 100;
%         ZoneUnWork_Pct(8, k) = 100 / 100;
%     end
    
    %--------------------------------------------------------------
    %                         Мойнакская ГЭС (H = 400м)
    % 1ГА
%     ZoneUnWork(1, 1) = 40;
%     ZoneUnWork(2, 1) = 52.1;
%     ZoneUnWork(3, 1) = 64;
%     ZoneUnWork(4, 1) = 72.1;
%     ZoneUnWork(5, 1) = 86;
%     ZoneUnWork(6, 1) = 102.1;
%     ZoneUnWork(7, 1) = 128;
%     ZoneUnWork(8, 1) = 150;
%     
%     % 2ГА
%     ZoneUnWork(1, 2) = 40;
%     ZoneUnWork(2, 2) = 50.1;
%     ZoneUnWork(3, 2) = 63;
%     ZoneUnWork(4, 2) = 72.1;
%     ZoneUnWork(5, 2) = 88;
%     ZoneUnWork(6, 2) = 101.1;
%     ZoneUnWork(7, 2) = 121;
%     ZoneUnWork(8, 2) = 150;
%-----------------------------------------------------------------------------------------
%                                 УСТЬ-ХАНТАЙСКАЯ ГЭС (50 м)
%-----------------------------------------------------------------------------------------
    % 1ГА
    ZoneUnWork(1, 1) = 0;
    ZoneUnWork(2, 1) = 31.5;
    ZoneUnWork(3, 1) = 31.5;
    ZoneUnWork(4, 1) = 63;
    
    % 2ГА
    ZoneUnWork(1, 2) = 0;
    ZoneUnWork(2, 2) = 31.5;
    ZoneUnWork(3, 2) = 42.5;
    ZoneUnWork(4, 2) = 67.5;


    % 3ГА
    ZoneUnWork(1, 3) = 0;
    ZoneUnWork(2, 3) = 31.5;
    ZoneUnWork(3, 3) = 42.5;
    ZoneUnWork(4, 3) = 67.5;


    % 4ГА
    ZoneUnWork(1, 4) = 0;
    ZoneUnWork(2, 4) = 31.5;
    ZoneUnWork(3, 4) = 42.5;
    ZoneUnWork(4, 4) = 67.5;


    % 5ГА
    ZoneUnWork(1, 5) = 0;
    ZoneUnWork(2, 5) = 31.5;
    ZoneUnWork(3, 5) = 42.5;
    ZoneUnWork(4, 5) = 67.5;

    
    % 6ГА
    ZoneUnWork(1, 6) = 0;
    ZoneUnWork(2, 6) = 31.5;
    ZoneUnWork(3, 6) = 31.5;
    ZoneUnWork(4, 6) = 63;
    
    % 7ГА
    ZoneUnWork(1, 7) = 0;
    ZoneUnWork(2, 7) = 31.5;
    ZoneUnWork(3, 7) = 42.5;
    ZoneUnWork(4, 7) = 67.5;


%     % Заполняем массив в и.е.
%     for k = 1:1:cnt_HU 
%         for j = 1:1:max(cntZoneUnw) * 2 + 2
%             ZoneUnWork(j, k) = ZoneUnWork_Pct(j, k) * Nom_P_HU(1, k);
%         end       
%     end
    
    
 
end