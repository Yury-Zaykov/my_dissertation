clc;
clear all;
%% Входные данные (аргументы функции)

cnt_HU = 4;

ctl_PP = [280 120 350 220];

i = 1;

global SortHU SortHUs 

SortHU(1, :) = [1 2 3 4];
SortHU(2, :) = [2 2 2 3]; % - это текущие значения зон работы ГА
SortHU(3, :) = [1 1 2 2];

SortHUs(1, :) = SortHU(1, :);
SortHUs(2, :) = SortHU(2, :); % - это текущие значения зон работы ГА
SortHUs(3, :) = SortHU(3, :);

dP_cm_zon_con = 10;

%% Входные данные (глобальные переменные)
global ZoneUnWork ctlHU_P CheckZoneHU TransferHU
    
ZoneUnWork(1:8, 1:cnt_HU) = 0;
ZoneUnWork(1, :) = 0;
ZoneUnWork(2, :) = 20;
ZoneUnWork(3, :) = 30;
ZoneUnWork(4, :) = 50;
ZoneUnWork(5, :) = 60;
ZoneUnWork(6, :) = 80;
ZoneUnWork(7, :) = 90;
ZoneUnWork(8, :) = 100;
ZoneUnWork(9, :) = 0;

ctlHU_P(1, 1:cnt_HU + 1) = 0;
ctlHU_P(1, 1) = 49;
ctlHU_P(1, 2) = 49;
ctlHU_P(1, 3) = 49;
ctlHU_P(1, 4) = 79;
ctlHU_P(1, cnt_HU + 1) = sum(ctlHU_P);

global Nom_P_HU CtlCheckZoneHU
Nom_P_HU(1:1, 1:cnt_HU) = 0; %МВт

% Можно менять значения массива номинальных мощностей генераторов
Nom_P_HU(:, 1) = 100;
Nom_P_HU(:, 2) = 100;
Nom_P_HU(:, 3) = 100;
Nom_P_HU(:, 4) = 100;

CheckZoneHU(1, 1:cnt_HU) = 0;
CheckZoneHU(1, 1) = 2;
CheckZoneHU(1, 2) = 2;
CheckZoneHU(1, 3) = 2;
CheckZoneHU(1, 4) = 3;

CtlCheckZoneHU(1, 1:cnt_HU) = 0;
CtlCheckZoneHU(1, 1) = 2;
CtlCheckZoneHU(1, 2) = 2;
CtlCheckZoneHU(1, 3) = 2;
CtlCheckZoneHU(1, 4) = 3;


maxZone = max(CheckZoneHU);

TransferHU(1, 1:cnt_HU) = [0 0 0 0];
TransferHU(2, 1:cnt_HU) = [0 0 0 0];

%%                      Сам алгоритм

soda = length(SortHU(1, :));

for j = 1:1:length(SortHU(1, :))

    NumHU = SortHU(1, 1);

    % В зависимости от зоны работы ГА, узнаем, в какую следующую зону 
    % нужно перевести ГА
    v = 3;
    for c = 1:1:maxZone
        if (SortHU(2, 1) == c)
            Need_P_Tfr = ZoneUnWork(v , NumHU) * 1.015;
            break;
        end
        v = v + 2;
    end

    % Остаток мощности, необходмый к распределнию на другие ГА
    Residue_P_Tfr = ctlHU_P(1, cnt_HU + 1) - Need_P_Tfr;

    % Остаток мощности, до перевода данного ГА ()
    Residue_P_NoTfr = sum(ctlHU_P(1, 1:cnt_HU)) - ctlHU_P(1, NumHU);


    P_Down(1, 1:cnt_HU + 1) = 0; 
    % Небаланс, который получится при переводе данного ГА, без
    % корректировки оставшихся
    P_Down(1, cnt_HU + 1) = Residue_P_NoTfr - Residue_P_Tfr;

    % Матрица долевых коэффициентов, в которой ГА, производящий переход в
    % следующую зону работы имеет 0 коэф участия, т.к. мы насильно
    % переводим его в след зону работы без какого либо учета его долевого
    % коэф
    EqRatio_temp(1, 1:cnt_HU) = 0;

    % Находим мax мощность, исключая ГА перевода
    maxPP = sum(Nom_P_HU) - Nom_P_HU(1, NumHU);

    % Находим долевые коэф
    for k = 1:1:cnt_HU
        if (k ~= NumHU)
            EqRatio_temp(1, k) = Nom_P_HU(1, k) / maxPP;
        end
    end

    % Небаланс для каждого ГА, с учетом долевых коэф
    for k = 1:1:cnt_HU
        P_Down(1, k) = EqRatio_temp(1, k) * P_Down(1, cnt_HU + 1);
    end

    % Инициализируем матрицу статического задачика мощности, в которую
    % запишем значения, необходимые для перевода в след зону работы
    ctlHU_P_Tfr(1, 1:cnt_HU + 1) = 0; 

    % Заполним эту матрицу, с учетом переводимого ГА 
    for k = 1:1:cnt_HU
        if (k == NumHU)
            ctlHU_P_Tfr(1,k) = Need_P_Tfr;
        else
            ctlHU_P_Tfr(1,k) = ctlHU_P(1, k) - P_Down(1, k);
        end
    end
    % Проходимся по всем значениям статической задачи мощности и если она
    % ниже границ рабочей зоны, то устанавливаем статическое задание ГА
    % равным границе этой зоны
    for k = 1:1:cnt_HU
        % Производим проверку только для ГА-ов без перехода
        if (k ~= NumHU)
            % Переменная счетчик, для алгоритма
            v = 1;
            % Проверяем для всех возможных зон для данного ГА
            for c = 1:1:maxZone                    
                if (CheckZoneHU(1, k) == c)
                    if (ctlHU_P_Tfr(1, k) < ZoneUnWork(v, k))
                        ctlHU_P_Tfr(1, k) = ZoneUnWork(v, k);
                        break;
                    end
                end
                v = v + 2;                      
            end
        end
    end
    %Инициализируем массив, хранящий данные на разгрузку по ГА
    toUnload(1, 1:cnt_HU + 1) = 0;
    % В зависимости от зоны работы ГА, рассчитываем мощность ГА на
    % загрузку и разгрузку
    for k = 1:1:cnt_HU     
        % В зависимости от зоны работы ГА, рассчитываем мощность ГА на
        % загрузку и разгрузку
        if (k ~= NumHU)
            % Переменная счетчик, для алгоритма
            v = 1;
            % Проверяем для всех возможных зон для данного ГА
            for c = 1:1:maxZone
                if (CheckZoneHU(1, k) == c)
                    toUnload(1, k) = ctlHU_P_Tfr(1, k) - ...
                        ZoneUnWork(v, k);
                    break;
                end
                v = v + 2;
            end
        end
    end
    % Находим сумму на разгрузку при данных раскладах
    toUnload(1, cnt_HU + 1) = sum(toUnload(1, 1:cnt_HU));

    ctlHU_P_Tfr(1, cnt_HU + 1) = sum(ctlHU_P_Tfr(1, 1:cnt_HU));

    % Сравниваем с уставкой
    if (toUnload(1, cnt_HU + 1) < dP_cm_zon_con)
        SortHU(:, 1) = [];
    else
        TransferHU(1, NumHU) = 1;
        % 0 - ГА не производит переход
        % 1 - ГА переходит из высшей зоны в низшую
        % 10 - ГА переходит из низшей зоны в высшию
        TransferHU(2, NumHU) = 10;
        CtlCheckZoneHU(1, NumHU) =  CtlCheckZoneHU(1, NumHU) + 1;
        break;
    end
end


disp("XXX_Complite_XXX");
