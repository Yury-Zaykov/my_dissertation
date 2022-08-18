clc;
clear all;
%%                      ДЛЯ ОТЛАДКИ

%% Параметры ГА

% Количесвто ГА
cnt_HU = 7;

%Матрица номинальных мощностей ГА
global Nom_P_HU
Nom_P_HU(1:1, 1:cnt_HU) = [63 73 73 73 73 63 73]; %МВт

% Максимальная мощность станции
maxNom_PP = 0;
for pp = 1:1:cnt_HU
    maxNom_PP = maxNom_PP + Nom_P_HU(1, pp);
end

% Минимальная мощность станции
minNom_PP = 0.1 * maxNom_PP;

%% Параметры зон нежелательной работы

%Количество зон Нежелательной работы ()
global cntZoneUnw
cntZoneUnw(1, 1:cnt_HU) = [1 1 1 1 1 1 1];

%Количество зон Желательной работы
%cntZoneW = max(cntZoneUnw) + 1;

% Массивы, хранящие значения нежелательных зон работы в %
global ZoneUnWork_Pct
ZoneUnWork_Pct(1:max(cntZoneUnw) * 2 + 2, 1:cnt_HU) = 0;

% Массивы, хранящие значения нежелательных зон работы в и.е.
global ZoneUnWork 
ZoneUnWork(1:max(cntZoneUnw) * 2 + 3,1:cnt_HU) = 0;

% Вызываем функцию расчета зон нежелательной работы
CalcZonesUnWork(cnt_HU)

%% УСТАВКИ и Разные матрицы
global dt_cm_zon dP_cm_zon dP_cm_zon_con dP_SL

% Уставка по времени, через которое необходимо начать перевод ГА
dt_cm_zon = 2;
% Уставка по мощности, при P(загр) < dP_cm_zon начинается отсчет таймера
dP_cm_zon = maxNom_PP * 0.02;
% Уставка по мощности, при  dP_cm_zon_con < P(разгр) перевод в следующую
% зону работы ГА разрешается
dP_cm_zon_con = maxNom_PP * 0.04; 
% Уставка, ограничевающая скорость набора мощности ГА
dP_SL = 1; % МВт / с

% Переменная - таймер (для функции CalcOutChangeZone)
global t_CZup t_CZdown
t_CZup = 0;
t_CZdown = 0;

% Переменная, указывающая на необходимость смены зоны ГА
global outChangeZup outChangeZdown
outChangeZup = false;
outChangeZdown = false;
% Переменная, указывающая "тренд", т.е набираем мы в сумме мощность или 
% наоборот снижаем ее (для всей станции). Если 1, то набираем, 0 снижаем
global trend
trend(1, 1:cnt_HU + 1) = 1;

% Массив приоритетов (max 10), переводов ГА через зону неж. раб.
global priority
priority(1, 1:cnt_HU) = 1:cnt_HU;
priority(2, 1:cnt_HU) = [1 2 3 4 5 6 7];
% Матрица для отслеживания текущих переходов ГА. 1 - переход есть, 0 нету
global TransferHU

TransferHU(1:2, 1:cnt_HU) = 0;

% Флаг удерживания мощности при переходе
global hold T_e T_b ctl_PP
hold = false;
%% Блок управления мощностью

% количество изменений управления
count_ctl_P = 10;

% массив значений для упр-ия мощностью станции в разные промежутки времени 
% по активной мощности
%control_P = minNom_PP + (maxNom_PP - minNom_PP)*rand(1,count_ctl_P);

% Для отладки
ctl_PP = [281 44 238 410 437 154 41 277 353 115];

i = 1; % переменная счетчик изменений управления

T_e = 8; % постоянная времени регулирования для конечного этапа регулирования

T_b = 3; % постоянная времени регулирования для начального этапа регулирования

%% Инициализация матрицы ГА (матрица текущих значений мощности)
% В первой строке активная мощность ГА
% Во второй реактивная мощность ГА
global HU_Pow
HU_Pow(1:2, 1:cnt_HU + 1) = 0; % инициализация матрицы нулями
HU_Pow(1, 1:cnt_HU ) = [63 67 67 67 67 63 67];
HU_Pow(1, cnt_HU + 1) = sum(HU_Pow(1, 1:cnt_HU));

%% Параметры найстройки цикла управления
tStep = 0.005; % шаг управления САУ ГА, с
count_seconds = 60 * 30; % временной интервал регулирования, с

% Создаем массив для записи изменений мощностей
% В столбце count_HU + 1 записана суммарная мощность станции
global Array_P
Array_P(1:(count_seconds / tStep), 1:cnt_HU + 1) = 0;

for w = 1:1:cnt_HU + 1
    Array_P(1, w) = HU_Pow(1, w);
end



interval_time = count_seconds / count_ctl_P; % временные интервалы, через 
% которые мы будем менять значение задаваемой мощности
%% Инициализация матрицы долевых коэффициентов + их расчет
global EqRatio
EqRatio (1, 1:cnt_HU) = 0;

% Вызываем функцию расчета удельных коэффициентов
CalcEqRat(cnt_HU, Nom_P_HU, maxNom_PP);
%% Инициализация матрицы контроля зон работы ГА
global CheckZoneHU
CheckZoneHU(1, 1:cnt_HU) = 1; % инициализация матрицы 1


%Матрица для проверки контроля изменения зон
global CtlCheckZoneHU
CtlCheckZoneHU(1, 1:cnt_HU) = 2;

% Матрицы определения работы ГА в верхней зоне и нижней зонах
global DefUpZone DefDownZone
DefUpZone(1, 1:cnt_HU) = false;
DefDownZone(1, 1:cnt_HU) = true;

%% Инициализация матрицы задатчика активной мощности
global ctlHU_P
ctlHU_P(1, 1:cnt_HU + 1) = 63;

%% Инициализация матрицы контроля загрузки ГА и разгрузки 

global ToLoad ToUnload

% Последний столбец - это сумма всех загрузок/разгрузок ГА
ToLoad(1, 1:cnt_HU + 1) = 0;

ToUnload(1, 1:cnt_HU + 1) = 0;

%% Цикл управления
j = 1;
for duration = 0.005 : tStep : count_seconds
    
    if (duration == 819.575)
        ffff = 5;
    end
    
    %----------------------------------------------------------------------
    % Переменная, необходимая для перемещения по строкам в массиве array_P
    j = j + 1;
    %----------------------------------------------------------------------
    % 1 интервал регулирования
    if (duration >= 0 && duration < interval_time)
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы 
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)           
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    % 2 интервал регулирования
    if (duration >= interval_time && duration < 2 * interval_time)  
        % Фиксатор изменения интервала регулирования
        if (i == 1)
            i = i + 1;    
        end
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию определения тренда мощности
        CalcDefTrend(cnt_HU, ctl_PP, i);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы 
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)   
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    % 3 интервал регулирования
    if (duration >= 2 * interval_time && duration < 3 * interval_time)
        % Фиксатор изменения интервала регулирования
        if (i == 2)
            i = i + 1;    
        end
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию определения тренда мощности
        CalcDefTrend(cnt_HU, ctl_PP, i);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)   
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    % 4 интервал регулирования
    if (duration >= 3 * interval_time && duration <= 4 * interval_time)        
        % Фиксатор изменения интервала регулирования
        if (i == 3)
            i = i + 1;    
        end
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию определения тренда мощности
        CalcDefTrend(cnt_HU, ctl_PP, i);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы 
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)   
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    % 5 интервал регулирования
    if (duration >= 4 * interval_time && duration <= 5 * interval_time)        
        % Фиксатор изменения интервала регулирования
        if (i == 4)
            i = i + 1;    
        end
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию определения тренда мощности
        CalcDefTrend(cnt_HU, ctl_PP, i);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы 
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)   
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    % 6 интервал регулирования
    if (duration >= 5 * interval_time && duration <= 6 * interval_time)        
        % Фиксатор изменения интервала регулирования
        if (i == 5)
            i = i + 1;    
        end
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию определения тренда мощности
        CalcDefTrend(cnt_HU, ctl_PP, i);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы 
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)   
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    % 7 интервал регулирования
    if (duration >= 6 * interval_time && duration <= 7 * interval_time)        
        % Фиксатор изменения интервала регулирования
        if (i == 6)
            i = i + 1;    
        end
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию определения тренда мощности
        CalcDefTrend(cnt_HU, ctl_PP, i);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы 
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)   
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    % 8 интервал регулирования
    if (duration >= 7 * interval_time && duration <= 8 * interval_time)        
        % Фиксатор изменения интервала регулирования
        if (i == 7)
            i = i + 1;    
        end
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию определения тренда мощности
        CalcDefTrend(cnt_HU, ctl_PP, i);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы 
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)   
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    % 9 интервал регулирования
    if (duration >= 8 * interval_time && duration <= 9 * interval_time)        
        % Фиксатор изменения интервала регулирования
        if (i == 8)
            i = i + 1;    
        end
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию определения тренда мощности
        CalcDefTrend(cnt_HU, ctl_PP, i);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы 
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)   
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    % 10 интервал регулирования
    if (duration >= 9 * interval_time && duration <= 10 * interval_time + 0.005)        
        % Фиксатор изменения интервала регулирования
        if (i == 9)
            i = i + 1;    
        end
        % Вызываем функцию определения и записи зон работы каждого ГА
        CalcCheckZone(cnt_HU);

        % Вызываем функцию расчета мощности на загрузку и разгрузку
        CalcLoadUnload(cnt_HU);

        % Вызываем функцию определения агрегатов в верхней и нежней зонах работы 
        CalcDefUpDownZone(cnt_HU);

        % Вызываем функцию определения тренда мощности
        CalcDefTrend(cnt_HU, ctl_PP, i);

        % Вызываем функцию для определения необходимости смены зон для ГА
        CalcOutChangeZone(cnt_HU, tStep);

        % Вызываем функцию, для расчета ГА, который необ-мо перевести в другую зону работы 
        CalcTransferHU(cnt_HU, i);

        % Фунция статического задатчика мощности (СЗМ)
        StaticSetterPower(cnt_HU, ctl_PP, i);

        % Фунция динамического задатчика мощности (ДЗМ)
        DynamicSetterPower(cnt_HU, j, tStep);
        
        %GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta);
    end
    %----------------------------------------------------------------------
    %Считаем суммарную мощность станции в конкретный момент времени
    for poi = 1:1:cnt_HU
        Array_P(j, cnt_HU + 1) = Array_P(j, cnt_HU + 1) + Array_P(j, poi);
    end
end
%% Графики

% Вызываем функцию построения графиков
CalcSchedules (cnt_HU, j, tStep, count_seconds);