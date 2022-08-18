clc;
clear all;
%% Входные данные (аргументы функции)

cnt_HU = 4;

ctl_PP(1, 1:cnt_HU) = [140 30 40 50];

% Переменная счетчик изменения управляющих воздействий
i = 1;

global TransferHU
% Номер ГА, необходимыe к переходу
TransferHU = [1 0 0 0];

% Зона, в которую необходимо перевести ГА
NeedZone = 2;

outChangeZ = 1;

ctlHU_P_Tfr(1, 1:cnt_HU + 1) = [49.5,60.6,30.300000000000000,15.233333333333334,76];
%% Входные данные (глобальные переменные)

global ctlHU_P EqRatio ZoneUnWork cntZoneUnw CheckZoneHU HU_Pow Nom_P_HU trend CtlCheckZoneHU 




trend(1, 1:cnt_HU+1) = [1 1 1 1 0];

Nom_P_HU(1:1, 1:cnt_HU) = 0; %МВт

% Можно менять значения массива номинальных мощностей генераторов
 Nom_P_HU(:, 1) = 100;
 Nom_P_HU(:, 2) = 100;
 Nom_P_HU(:, 3) = 100;
 Nom_P_HU(:, 4) = 100;
 
HU_Pow(1, 1:cnt_HU + 1) = [61 35 35 35 0];
HU_Pow(1, cnt_HU + 1) = sum(HU_Pow);

CheckZoneHU(1, 1:cnt_HU) = [1 1 1 1];


cntZoneUnw(1, 1:cnt_HU) = [3 3 3 3];

ctlHU_P(1, 1:cnt_HU + 1) = [20 20 20 20 0];
%ctlHU_P(1, 1:cnt_HU+1) = [10 15 30 15 0];
% ctlHU_P(1, 1) = 15;
% ctlHU_P(1, 2) = 15;
% ctlHU_P(1, 3) = 15;
% ctlHU_P(1, 4) = 15;
ctlHU_P(1, cnt_HU + 1) = sum(ctlHU_P);


EqRatio(1, 1:cnt_HU) = 0;
EqRatio(1, 1) = 0.25;
EqRatio(1, 2) = 0.25;
EqRatio(1, 3) = 0.25;
EqRatio(1, 4) = 0.25;

ZoneUnWork(1:8, 1:cnt_HU) = 0;
ZoneUnWork(1, :) = 20;
ZoneUnWork(2, :) = 30;
ZoneUnWork(3, :) = 50;
ZoneUnWork(4, :) = 60;
ZoneUnWork(5, :) = 80;
ZoneUnWork(6, :) = 90;
ZoneUnWork(7, :) = 100;
ZoneUnWork(8, :) = 0;

%% Собственные переменные фунции

maxZone = max(CheckZoneHU);

%Матрица, хранящая значения для ГА, вышедших за допустимую зону работы при
%промежуточных расчетах
UnZone(1, 1:cnt_HU) = 0;

%Матрица, хранящая осток мощности от разницы между тем, что посчитали и
%текущей границей работы ГА
Leftover(1, 1:cnt_HU + 1) = 0;


outChangeZdown = 1;
outChangeZup = 0;
%% Сам алгоритм
hold = false;
%--------------------------------------------------------------------------
% Если есть необходимость в переводе ГА
if (sum(TransferHU) ~= 0 && (outChangeZup == true || outChangeZdown == true))
    hold = true;
end
%--------------------------------------------------------------------------
% Если есть необходимость в переводе или удержании ГА
if (hold == true)  

    % Установка СЗМ в первом приблежении
    for j = 1:1:cnt_HU
        if (TransferHU(1, j) == 1)
            ctlHU_P(1, j) = ctlHU_P_Tfr(1, j);
            Leftover(1, cnt_HU + 1) = ctl_PP - ctlHU_P(1, j);
        end
    end

    %----------------------------------------------------------------------
    % Найдем разность, которую нужно покрыть в случае изменения
    % задаваемой мощности. Считаем, что значение на переводимом ГА в
    % каждый момент времени перевода статична и ровна заданной выше

    

    
    
    
    
    
    
    
    
    
    
    
    
    %-------------------------------------------------------------------------------------
    %=====================================================================================
    %-------------------------------------------------------------------------------------
    
    % Находим разницу Р, при переходе ГА, исключая ГА производящие переход
    difference_P = ctl_PP(1, i) - HU_Pow(1, cnt_HU + 1);
    for j = 1:1:cnt_HU
        if (TransferHU(1, j) == 1)
            difference_P = difference_P + HU_Pow(1, j) - ctlHU_P(1, j);
        end
    end
    % Отмечаем ГА, находящиеся в переходе
    for j = 1:1:cnt_HU
        if (TransferHU(1, j) == 1)
           UnZone(1, j) = 1;
       end
    end

    % Если разница между заданной и текущей мощностью велика, то идем по
    % алгоритму, а иначе ничего не делаем
    if (difference_P > 0.001)

        % Матрица долевых коэффициентов, в которой ГА, ограниченные зоной
        % работы или переходом в другую зону имеют 0 коэф долевого участия
        EqRatio_temp(1, 1:cnt_HU) = 0;

        % Находим мax мощность, исключая ГА, ограниченные зоной работы
        maxPP = 0;
        for j = 1:1:cnt_HU
            if (UnZone(1, j) == 0)
                maxPP = maxPP + Nom_P_HU(1, j);
            end
        end

        % Находим долевые коэф для ГА, неограниченных зоной работы и не
        % находящиеся в переходе
        for j = 1:1:cnt_HU
            if (UnZone(1, j) == 0)
                EqRatio_temp(1, j) = Nom_P_HU(1, j) / maxPP;
            end
        end

        % Зная этот остаток, найдем, сколько нужно "набросить" на каждый ГА сверху
        % чтобы задача на станцию и сама выработка станцией мощности сравнялись
        for j = 1:1:cnt_HU
            if (TransferHU(1, j) == 0)
                ctlHU_Pup(1, j) = EqRatio_temp(1, j) * difference_P;
                % Сделаем предварительный расчет, набросим на текущую мощность ГА, ту,
                % что посчитали на предыдущем шаге и получим суммарную мощность, которую
                % нужно выработать станции (без учета ограничений)
                ctlHU_Pss1(1, j) = HU_Pow(1, j) + ctlHU_Pup(1, j);
            else
                ctlHU_Pss1(1, j) = ctlHU_P(1, j);
            end
        end
        % Найдем сумму на всю станцию
        ctlHU_Pss1(1, cnt_HU + 1) = sum(ctlHU_Pss1(1, 1:cnt_HU));

        % Покольку у ГА есть зоны нежелательной работы, необходимо уточнить, не
        % зашел ли ГА в эту зону. Если зашел, то ограничить мощность зоной
        % желательной работы (зная в какой зоне работает данный ГА)
        for j = 1:1:cnt_HU
            if (TransferHU(1, j) == 0)
                v = 1;
                for c = 1:1:maxZone
                    if (CheckZoneHU(1, j) == c)
                        if (ctlHU_Pss1(1, j) > ZoneUnWork(v, j))
                            %Если ГА вышел за границу зоны работы, то регистрируем
                            %это в отдельной матрице (необх для дальнейших расчетов)
                            UnZone(1, j) = 1;

                            % Промежуточная матрица, для записи в статический задатчик
                            % мощности, с учетом зон нежелатной работы ГА
                            ctlHU_P_temp(1, j) = ZoneUnWork(v, j);

                            % В эту матрицу записываем разницу, между необходимой
                            % выработкой мощности данного ГА и огрниченной его зоной
                            % работы (остаток, который нужно перебросить на другие ГА, 
                            % не ограниченные зоной нежелательной работы)
                            Leftover(1, j) = ctlHU_Pss1(1, j) - ctlHU_P_temp(1, j); 
                            break;
                        else
                            ctlHU_P_temp(1, j) = ctlHU_Pss1(1, j);
                            break;
                        end
                    end
                    v = v + 2;
                end
            else
                ctlHU_P_temp(1, j) = ctlHU_Pss1(1, j);
            end
        end

        % Находим суммы для этих матриц (т.е. для всей станции)
        Leftover(1, cnt_HU + 1)     = sum(Leftover(1, 1:cnt_HU));
        ctlHU_P_temp(1, cnt_HU + 1) = sum(ctlHU_P_temp(1, 1:cnt_HU));

        % Найдем небаланс, после наших ограничений
        unbalance1 = abs(ctlHU_Pss1(1, cnt_HU+1) - ctlHU_P_temp(1, cnt_HU+1));

        % Если небаланс велик, то идем далее по алгоритму, иначе задаем СЗМ
        % расчитанные параметры
        if (unbalance1 > 0.001)
            unbalance2 = 2;
            while(sum (UnZone) < cnt_HU && unbalance2 > 0.01)

                % Матрица долевых коэффициентов, в которой ГА, ограниченные зоной
                % работы имеют 0 коэф долевого участия
                EqRatio_temp(1, 1:cnt_HU) = 0;

                % Находим мax мощность, исключая ГА, ограниченные зоной работы
                maxPP = 0;
                for j = 1:1:cnt_HU
                    if (UnZone(1, j) == 0)
                        maxPP = maxPP + Nom_P_HU(1, j);
                    end
                end

                % Находим долевые коэф для ГА, неограниченных зоной работы
                for j = 1:1:cnt_HU
                    if (UnZone(1, j) == 0)
                        EqRatio_temp(1, j) = Nom_P_HU(1, j) / maxPP;
                    end
                end

                for j = 1:1:cnt_HU
                    ctlHU_Pup2(1, j) = EqRatio_temp(1, j) * Leftover(1, cnt_HU + 1);
                    ctlHU_Pg(1, j) = ctlHU_P_temp(1, j) + ctlHU_Pup2(1, j);   
                end

                ctlHU_Pg(1, cnt_HU + 1) = sum(ctlHU_Pg(1, 1:cnt_HU)); 

                for j = 1:1:cnt_HU
                    if (TransferHU(1, j) == 0)
                        v = 1;
                        for c = 1:1:maxZone
                            if (CheckZoneHU(1, j) == c)
                                if (ctlHU_Pg(1, j) > ZoneUnWork(v, j))
                                    %Если ГА вышел за границу зоны работы, то регистрируем
                                    %это в отдельной матрице (необх для дальнейших расчетов)
                                    UnZone(1, j) = 1;

                                    % Промежуточная матрица, для записи в статический задатчик
                                    % мощности, с учетом зон нежелатной работы ГА
                                    ctlHU_P_temp(1, j) = ZoneUnWork(v, j);

                                    % В эту матрицу записываем разницу, между необходимой
                                    % выработкой мощности данного ГА и огрниченной его зоной
                                    % работы (остаток, который нужно перебросить на другие ГА, 
                                    % не ограниченные зоной нежелательной работы)
                                    Leftover(1, j) = ctlHU_Pg(1, j) - ctlHU_P_temp(1, j); 
                                    break;
                                else
                                    ctlHU_P_temp(1, j) = ctlHU_Pg(1, j);

                                    Leftover(1, j) = ctlHU_Pg(1, j) - ctlHU_P_temp(1, j);

                                    break
                                end
                            end
                            v = v + 2;
                        end
                    else
                        ctlHU_P_temp(1, j) = ctlHU_P(1, j);
                    end
                end

               % Находим суммы для этих матриц (т.е. для всей станции)
                Leftover(1, cnt_HU + 1)     = sum(Leftover(1, 1:cnt_HU));
                ctlHU_P_temp(1, cnt_HU + 1) = sum(ctlHU_P_temp(1, 1:cnt_HU));

                unbalance2 = abs(ctlHU_P_temp(1, cnt_HU + 1) - ctlHU_Pg(1, cnt_HU + 1));
            end

            for j = 1:1:cnt_HU
                ctlHU_P(1, j) = ctlHU_P_temp(1, j);
            end
            ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
        else
            for j = 1:1:cnt_HU
                ctlHU_P(1, j) = ctlHU_P_temp(1, j);
            end
            ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
        end    
    end

    % Если разница отрицательна (необходимо уменшить мощность, по сравнению с текущей)
    if (difference_P < -0.001)

        difference_P = abs(difference_P);
        % Матрица долевых коэффициентов, в которой ГА, ограниченные зоной
        % работы или переходом в другую зону имеют 0 коэф долевого участия
        EqRatio_temp(1, 1:cnt_HU) = 0;

        % Находим мax мощность, исключая ГА, ограниченные зоной работы
        maxPP = 0;
        for j = 1:1:cnt_HU
            if (UnZone(1, j) == 0)
                maxPP = maxPP + Nom_P_HU(1, j);
            end
        end

        % Находим долевые коэф для ГА, неограниченных зоной работы и не
        % находящиеся в переходе
        for j = 1:1:cnt_HU
            if (UnZone(1, j) == 0)
                EqRatio_temp(1, j) = Nom_P_HU(1, j) / maxPP;
            end
        end

        % Зная этот остаток, найдем, сколько нужно "набросить" на каждый ГА сверху
        % чтобы задача на станцию и сама выработка станцией мощности сравнялись
        for j = 1:1:cnt_HU
            if (TransferHU(1, j) == 0)
                ctlHU_Pdown(1, j) = EqRatio_temp(1, j) * difference_P;
                % Сделаем предварительный расчет, набросим на текущую мощность ГА, ту,
                % что посчитали на предыдущем шаге и получим суммарную мощность, которую
                % нужно выработать станции (без учета ограничений)
                ctlHU_Pss1(1, j) = HU_Pow(1, j) - ctlHU_Pdown(1, j);
            else
                ctlHU_Pss1(1, j) = ctlHU_P(1, j);
            end
        end
        % Найдем сумму на всю станцию
        ctlHU_Pss1(1, cnt_HU + 1) = sum(ctlHU_Pss1(1, 1:cnt_HU));

        % Покольку у ГА есть зоны нежелательной работы, необходимо уточнить, не
        % зашел ли ГА в эту зону. Если зашел, то ограничить мощность зоной
        % желательной работы (зная в какой зоне работает данный ГА)
        for j = 1:1:cnt_HU
            if (TransferHU(1, j) == 0)
                v = 0;
                for c = 1:1:maxZone
                    if (CheckZoneHU(1, j) == c)
                        if (c == 1 && ctlHU_Pss1(1, j) < 0)
                            UnZone(1, j) = 1;
                            ctlHU_P_temp(1, j) = 0;
                            Leftover(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pss1(1, j); 
                            break;
                        end
                        if (c == 1)
                            ctlHU_P_temp(1, j) = ctlHU_Pss1(1, j);
                            break;
                        end

                        if (ctlHU_Pss1(1, j) < ZoneUnWork(v, j))
                            %Если ГА вышел за границу зоны работы, то регистрируем
                            %это в отдельной матрице (необх для дальнейших расчетов)
                            UnZone(1, j) = 1;

                            % Промежуточная матрица, для записи в статический задатчик
                            % мощности, с учетом зон нежелатной работы ГА
                            ctlHU_P_temp(1, j) = ZoneUnWork(v, j);

                            % В эту матрицу записываем разницу, между необходимой
                            % выработкой мощности данного ГА и огрниченной его зоной
                            % работы (остаток, который нужно перебросить на другие ГА, 
                            % не ограниченные зоной нежелательной работы)
                            Leftover(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pss1(1, j); 
                            break;
                        else
                            ctlHU_P_temp(1, j) = ctlHU_Pss1(1, j);
                            break;
                        end
                    end
                    v = v + 2;
                end
            else
                ctlHU_P_temp(1, j) = ctlHU_Pss1(1, j);
            end
        end

        % Находим суммы для этих матриц (т.е. для всей станции)
        Leftover(1, cnt_HU + 1)     = sum(Leftover(1, 1:cnt_HU));
        ctlHU_P_temp(1, cnt_HU + 1) = sum(ctlHU_P_temp(1, 1:cnt_HU));

        % Найдем небаланс, после наших ограничений
        unbalance1 = abs(ctlHU_Pss1(1, cnt_HU+1) - ctlHU_P_temp(1, cnt_HU+1));

        % Если небаланс велик, то идем далее по алгоритму, иначе задаем СЗМ
        % расчитанные параметры
        if (unbalance1 > 0.01)
            unbalance2 = 2;
            while(sum (UnZone) < cnt_HU && unbalance2 > 0.01)

                % Матрица долевых коэффициентов, в которой ГА, ограниченные зоной
                % работы имеют 0 коэф долевого участия
                EqRatio_temp(1, 1:cnt_HU) = 0;

                % Находим мax мощность, исключая ГА, ограниченные зоной работы
                maxPP = 0;
                for j = 1:1:cnt_HU
                    if (UnZone(1, j) == 0)
                        maxPP = maxPP + Nom_P_HU(1, j);
                    end
                end

                % Находим долевые коэф для ГА, неограниченных зоной работы
                for j = 1:1:cnt_HU
                    if (UnZone(1, j) == 0)
                        EqRatio_temp(1, j) = Nom_P_HU(1, j) / maxPP;
                    end
                end

                for j = 1:1:cnt_HU

                    ctlHU_Pdown2(1, j) = EqRatio_temp(1, j) * Leftover(1, cnt_HU + 1);

                    ctlHU_Pg(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pdown2(1, j);   
                end

                ctlHU_Pg(1, cnt_HU + 1) = sum(ctlHU_Pg(1, 1:cnt_HU)); 

                for j = 1:1:cnt_HU
                    if (TransferHU(1, j) == 0)
                        v = 0;
                        for c = 1:1:maxZone
                            if (CheckZoneHU(1, j) == c)
                                if (c == 1 && ctlHU_Pg(1, j) < 0)
                                    UnZone(1, j) = 1;
                                    ctlHU_P_temp(1, j) = 0;
                                    Leftover(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pg(1, j); 
                                    break;
                                end
                                if (c == 1)
                                    ctlHU_P_temp(1, j) = ctlHU_Pg(1, j);
                                    Leftover(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pg(1, j); 
                                    break;
                                end

                                if (ctlHU_Pg(1, j) < ZoneUnWork(v, j))
                                    %Если ГА вышел за границу зоны работы, то регистрируем
                                    %это в отдельной матрице (необх для дальнейших расчетов)
                                    UnZone(1, j) = 1;

                                    % Промежуточная матрица, для записи в статический задатчик
                                    % мощности, с учетом зон нежелатной работы ГА
                                    ctlHU_P_temp(1, j) = ZoneUnWork(v, j);

                                    % В эту матрицу записываем разницу, между необходимой
                                    % выработкой мощности данного ГА и огрниченной его зоной
                                    % работы (остаток, который нужно перебросить на другие ГА, 
                                    % не ограниченные зоной нежелательной работы)
                                    Leftover(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pg(1, j); 
                                    break;
                                else
                                    ctlHU_P_temp(1, j) = ctlHU_Pg(1, j);

                                    Leftover(1, j) = ctlHU_Pg(1, j) - ctlHU_P_temp(1, j);

                                    break
                                end
                            end
                            v = v + 2;
                        end
                    else
                        ctlHU_P_temp(1, j) = ctlHU_P(1, j);
                    end
                end

               % Находим суммы для этих матриц (т.е. для всей станции)
                Leftover(1, cnt_HU + 1)     = sum(Leftover(1, 1:cnt_HU));
                ctlHU_P_temp(1, cnt_HU + 1) = sum(ctlHU_P_temp(1, 1:cnt_HU));

                unbalance2 = abs(ctlHU_P_temp(1, cnt_HU + 1) - ctlHU_Pg(1, cnt_HU + 1));
            end

            for j = 1:1:cnt_HU
                ctlHU_P(1, j) = ctlHU_P_temp(1, j);
            end
            ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
        else
            for j = 1:1:cnt_HU
                ctlHU_P(1, j) = ctlHU_P_temp(1, j);
            end
            ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
        end
    end
end
%-------------------------------------------------------------------------------------
% Если необходимости в переводе и удержании мощности переводимого ГА нет,
% то пользуемся стандартным алгоритмом
%-------------------------------------------------------------------------------------
if (hold == false)
    % Алгоритм работы СДМ, при работе в обычнчом режиме (без переходов)

    %---------------------------------------------------------------------------------
    % У нас имеется мощность задання на всю станцию (в конкретный момент времени) 
    % и текущая мощность, вырабатываемая станцией. Найдя разницу между ними, найдем
    % разницу(небаланс) между тем, что нужно выработать и тем что уже вырабатываем
    %---------------------------------------------------------------------------------

    Leftover(1, cnt_HU+1) = ctl_PP(1, i) - ctlHU_P(1, cnt_HU+1);

    % Если разница между заданной и текущей статичекой мощностью велика, 
    % то идем по алгоритму, а иначе ничего не делаем
    if (Leftover(1, cnt_HU+1) > 0.001)

        % Присвоим временной матрице текущую задачу статической мощности
        for j = 1:1:cnt_HU
            ctlHU_P_temp(1, j) = ctlHU_P(1, j);
        end

        % Производим расчет, пока небаланс не станет оптимальным или
        % все ГА станут ограничены зоной своей работы
        while(sum(UnZone) < cnt_HU && Leftover(1, cnt_HU+1) > 0.001)

            % Матрица долевых коэффициентов, в которой ГА, ограниченные 
            % зоной работы имеют 0 коэф долевого участия
            EqRatio_temp(1, 1:cnt_HU) = 0;    

            % Находим мax мощность, исключая ГА, ограниченные зоной работы
            maxPP = 0;
            for j = 1:1:cnt_HU
                if (UnZone(1, j) == 0)
                    maxPP = maxPP + Nom_P_HU(1, j);
                end
            end

            % Находим долевые коэф для ГА, неограниченных зоной работы
            for j = 1:1:cnt_HU
                if (UnZone(1, j) == 0)
                    EqRatio_temp(1, j) = Nom_P_HU(1, j) / maxPP;
                end
            end

            % Посчитав остаток, найдем, сколько нужно "набросить" на каждый ГА сверху
            % чтобы задача на станцию и сама выработка станцией мощности сравнялись
            for j = 1:1:cnt_HU
                ctlHU_Pup(1, j) = EqRatio_temp(1, j) * Leftover(1, cnt_HU+1);
                ctlHU_Pg(1, j) = ctlHU_P_temp(1, j) + ctlHU_Pup(1, j);   
            end

            % Найдем сумму на всю станцию
            ctlHU_Pg(1, cnt_HU + 1) = sum(ctlHU_Pg(1, 1:cnt_HU));

            % Покольку у ГА есть зоны нежелательной работы, необходимо уточнить, не
            % зашел ли ГА в эту зону. Если зашел, то ограничить мощность зоной
            % желательной работы (зная в какой зоне работает данный ГА)
            for j = 1:1:cnt_HU
                v = 1;
                for c = 1:1:maxZone
                    if (CheckZoneHU(1, j) == c)
                        if (ctlHU_Pg(1, j) > ZoneUnWork(v, j))
                            %Если ГА вышел за границу зоны работы, то регистрируем
                            %это в отдельной матрице (необх для дальнейших расчетов)
                            UnZone(1, j) = 1;
                            % Промежуточная матрица, для записи в статический задатчик
                            % мощности, с учетом зон нежелатной работы ГА
                            ctlHU_P_temp(1, j) = ZoneUnWork(v, j);
                            % В эту матрицу записываем разницу, между необходимой
                            % выработкой мощности данного ГА и огрниченной его зоной
                            % работы (остаток, который нужно перебросить на другие ГА, 
                            % не ограниченные зоной нежелательной работы)
                            Leftover(1, j) = ctlHU_Pg(1, j) - ctlHU_P_temp(1, j); 
                            break;
                        else
                            ctlHU_P_temp(1, j) = ctlHU_Pg(1, j);
                            Leftover(1, j) = ctlHU_Pg(1, j) - ctlHU_P_temp(1, j);
                            break;
                        end
                    end
                    v = v + 2;
                end
            end
           % Находим суммы для этих матриц (т.е. для всей станции)
            Leftover(1, cnt_HU + 1)     = sum(Leftover(1, 1:cnt_HU));
            ctlHU_P_temp(1, cnt_HU + 1) = sum(ctlHU_P_temp(1, 1:cnt_HU));

        end

        % Если небаланс при расчетах уменьшился или все ГА вышли за зоны своей работы,
        % в этом случае, записываем в СЗМ рассчитанную мощность
        for j = 1:1:cnt_HU
            ctlHU_P(1, j) = ctlHU_P_temp(1, j);
        end
        ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
    end
    %---------------------------------------------------------------------------------
    % Если разгружаем
    if (Leftover(1, cnt_HU+1) < -0.001)

        Leftover(1, cnt_HU+1) = abs(Leftover(1, cnt_HU+1));

        for j = 1:1:cnt_HU
            ctlHU_P_temp(1, j) = ctlHU_P(1, j);
        end

        while(sum(UnZone) < cnt_HU && Leftover(1, cnt_HU+1) > 0.001)

            EqRatio_temp(1, 1:cnt_HU) = 0;

            maxPP = 0;
            for j = 1:1:cnt_HU
                if (UnZone(1, j) == 0)
                    maxPP = maxPP + Nom_P_HU(1, j);
                end
            end

            for j = 1:1:cnt_HU
                if (UnZone(1, j) == 0)
                    EqRatio_temp(1, j) = Nom_P_HU(1, j) / maxPP;
                end
            end

            for j = 1:1:cnt_HU
                ctlHU_Pdown(1, j) = EqRatio_temp(1, j) * Leftover(1, cnt_HU + 1);
                ctlHU_Pg(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pdown(1, j);   
            end

            ctlHU_Pg(1, cnt_HU + 1) = sum(ctlHU_Pg(1, 1:cnt_HU)); 

            for j = 1:1:cnt_HU
                v = 0;
                for c = 1:1:maxZone
                    if (CheckZoneHU(1, j) == c)
                        if (c == 1 && ctlHU_Pg(1, j) < 0)
                            UnZone(1, j) = 1;
                            ctlHU_P_temp(1, j) = 0;
                            Leftover(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pg(1, j); 
                            break;
                        end
                        if (c == 1)
                            ctlHU_P_temp(1, j) = ctlHU_Pg(1, j);
                            Leftover(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pg(1, j); 
                            break;
                        end
                        if (ctlHU_Pg(1, j) < ZoneUnWork(v, j))
                            UnZone(1, j) = 1; 
                            ctlHU_P_temp(1, j) = ZoneUnWork(v, j);
                            Leftover(1, j) = ctlHU_P_temp(1, j) - ctlHU_Pg(1, j); 
                            break;
                        else
                            ctlHU_P_temp(1, j) = ctlHU_Pg(1, j);
                            Leftover(1, j) = ctlHU_Pg(1, j) - ctlHU_P_temp(1, j);
                            break;
                        end
                    end
                    v = v + 2;
                end
            end
            Leftover(1, cnt_HU + 1)     = sum(Leftover(1, 1:cnt_HU));
            ctlHU_P_temp(1, cnt_HU + 1) = sum(ctlHU_P_temp(1, 1:cnt_HU));
        end

        for j = 1:1:cnt_HU
            ctlHU_P(1, j) = ctlHU_P_temp(1, j);
        end
        ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
     end
end
%----------------------------------------------------------------------

% Если переводимый ГА достиг своей зоны работы, то отключаем
% удерживание и переводим все ГА в режим обычного регулировния
for j = 1:1:cnt_HU
    if (TransferHU(1, j) == 1 && TransferHU(2, j) == 10)
        if (HU_Pow(1, j) >= ctlHU_P(1, j) * 0.995)
            TransferHU(1, j) = 0;
            TransferHU(2, j) = 0;
        end
    end
    if (TransferHU(1, j) == 1 && TransferHU(2, j) == 1)
        if (HU_Pow(1, j) <= ctlHU_P(1, j) * 1.005)
            TransferHU(1, j) = 0;
            TransferHU(2, j) = 0;
        end       
    end
end
if (sum(TransferHU(1, :)) == 0)
    hold = false;
end