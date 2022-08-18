clear all;
clc;

cnt_HU = 4;
%--------------------------------------------------------------------------
% для 1 этапа
global DefUpZone DefDownZone TransferHU SortHU
DefUpZone(1, 1:cnt_HU) = [1 1 1 1];
DefDownZone(1, 1:cnt_HU) = [0 0 0 0];
TransferHU(1, 1:cnt_HU) = [0 0 0 0];
SortHU(3, cnt_HU) = 0;
%--------------------------------------------------------------------------
% для 2 этапа
global priority ZoneUnWork CheckZoneHU Nom_P_HU outChangeZup outChangeZdown ctlHU_P

ctlHU_P(1:1, 1:cnt_HU+1) = [32 32 32 32 0]; 
ctlHU_P(1,cnt_HU+1) = sum(ctlHU_P(1,1:cnt_HU));

priority(2, 1:cnt_HU) = [4 3 2 1];
priority(1, 1:cnt_HU) = 1:cnt_HU;
    
ZoneUnWork(1:8, 1:cnt_HU) = 0;
ZoneUnWork(1, :) = 20;
ZoneUnWork(2, :) = 30;
ZoneUnWork(3, :) = 50;
ZoneUnWork(4, :) = 60;
ZoneUnWork(5, :) = 80;
ZoneUnWork(6, :) = 90;
ZoneUnWork(7, :) = 100;
ZoneUnWork(8, :) = 0;

Nom_P_HU(1, 1:cnt_HU) = [100 100 100 100];

CheckZoneHU(1, 1:cnt_HU) = [2 2 2 2];

outChangeZup = 0;

outChangeZdown = 1;


if (outChangeZup)
    
    % Матрица для сортировки ГА, пригодных к переводу в след зону работы
    SortHU(3, cnt_HU) = 0;
    % Цикл заполнения ГА, которые не работают в самой верхней зоне и не
    % находятся в режиме перехода
    k = 1;
    for i = 1:1:cnt_HU
        if (DefUpZone(1, i) == 0 && TransferHU(1, i) == 0)
            SortHU(1, k) = i;
            k = k + 1;
        end 
    end
    % Заполняем 2 строку, означающую зону работы каждого ГА в
    % конкретный момент времени
    for i = 1:1:cnt_HU
        if (SortHU(1,i) ~= 0)
            SortHU(2, i) = CheckZoneHU(1, SortHU(1, i));
        end
    end
    % Удаляем нулевые значения, оставшиеся в матрице, т.к. они нам больше не
    % нужны
    for i = 1:1:cnt_HU
        if (SortHU(1, i) == 0)
            SortHU(:, i:cnt_HU) = [];
            break;
        end
    end
    % Узнаем длину текущего массива
    sz = length(SortHU(1, :));
    if (sz == 1) 
        FindHU_up(cnt_HU);
    else
        % Сортируем массив по возрастанию относительно 2 строки (зоны работы)
        for j = 1:1:sz   
            num_min = j;   
            for i = j:1:sz  
                if (SortHU(2, i) < SortHU(2, num_min))
                   num_min = i;
                end
            end

            tempHU = SortHU(1, j);     
            tempZone = SortHU(2, j);

            SortHU(2, j) = SortHU(2, num_min);       
            SortHU(1, j) = SortHU(1, num_min);

            SortHU(2, num_min) = tempZone;        
            SortHU(1, num_min) = tempHU;

        end
        % Присваеваем каждому ГА приоритет смены зоны работы ГА
        for i = 1:1:sz
            for j = 1:1:cnt_HU
                if (SortHU(1, i) == priority(1, j))            
                    SortHU(3, i) = priority(2, j);            
                end 
            end
        end
        % Переменная, необходимая для цикла while (см. в цикле for, который ниже)
        r = 1;
        % Сортируем массив HUandNumZone по приоритету, с учетом зоны работы ГА
        % Возможно стоит заменить cntZoneUnw + 1 на maxZone
        for zn = 1:1:max(CheckZoneHU)
            temp (1:3, 1:cnt_HU) = 0;  
            k = 1;
            % Заполняем промежуточную матрицу, в которой содержатся ГА только из
            % идентичных зон
            for g = 1:1:sz        
                if (SortHU(2, g) == zn)
                    temp(1, k) = SortHU(1, g);
                    temp(2, k) = SortHU(2, g);
                    temp(3, k) = SortHU(3, g);            
                    k = k + 1;            
                end        
            end
            % Удаляем пустые значения в матрице (если они есть)
            for b = 1:1:cnt_HU
                if (temp(1, b) == 0)

                    temp(:, b:cnt_HU) = [];
                    break;
                end   
            end

            lgh_t = length(temp(1, :));
            % Сортируем этот массив относительно 3 строки (по приоритету) 
            for j = 1:1:lgh_t
                num_min = j;
                for i = j:1:lgh_t
                    if (temp(3, i) < temp(3, num_min))
                       num_min = i;
                    end
                end

                tempZone = temp(3, j);
                tempHU = temp(1, j);

                temp(3, j) = temp(3, num_min);
                temp(1, j) = temp(1, num_min);

                temp(3, num_min) = tempZone;
                temp(1, num_min) = tempHU;
            end

            i = 1;
            % Меняем массив HUandNumZone для конкретной зоны работы относительно
            % приоритета (с помощью матрицы temp)
            while (lgh_t ~= 0 && r <= sz && SortHU(2, r) == temp(2,1))

                SortHU(1, r) = temp(1, i);
                SortHU(3, r) = temp(3, i);

                r = r + 1;
                i = i + 1;
            end
        end
        % Вызываем функцию определения ГА, необходимого к переводу в след. зону
        FindHU_up(cnt_HU);
    end
end
% Если есть запрос на разрузку ГА
if (outChangeZdown)
    % Матрица для сортировки ГА, пригодных к переводу в след зону работы
    SortHU(3, cnt_HU) = 0;
    % Цикл заполнения ГА, которые не работают в самой нижней зоне и не
    % находятся в режиме перехода
    k = 1;
    for i = 1:1:cnt_HU
        if (DefDownZone(1, i) == 0 && TransferHU(1, i) == 0)
            SortHU(1, k) = i;
            k = k + 1;
        end
    end
    % Заполняем 2 строку, озн-ую зону работы каждого ГА в конкретный момент времени
    for i = 1:1:cnt_HU
        if (SortHU(1,i) ~= 0)
            SortHU(2, i) = CheckZoneHU(1, SortHU(1, i));
        end
    end
    % Удаляем нулевые значения, оставшиеся в матрице, т.к. они нам больше не нужны
    for i = 1:1:cnt_HU
        if (SortHU(1, i) == 0)
            SortHU(:, i:cnt_HU) = [];
            break;
        end
    end
    % Узнаем длину текущего массива
    sz = length(SortHU(1, :));
    if (sz == 1) 
        FindHU_down(cnt_HU);
    else
        % Сортируем массив по возрастанию относительно 2 строки (зоны работы)
        for j = 1:1:sz   
            num_max = j;   
            for i = j:1:sz  
                if (SortHU(2, i) > SortHU(2, num_max))
                   num_max = i;
                end
            end

            tempHU = SortHU(1, j);     
            tempZone = SortHU(2, j);

            SortHU(2, j) = SortHU(2, num_max);       
            SortHU(1, j) = SortHU(1, num_max);

            SortHU(2, num_max) = tempZone;        
            SortHU(1, num_max) = tempHU;

        end
        % Присваеваем каждому ГА приоритет смены зоны работы ГА
        for i = 1:1:sz
            for j = 1:1:cnt_HU
                if (SortHU(1, i) == priority(1, j))            
                    SortHU(3, i) = priority(2, j);            
                end 
            end
        end
        % Переменная, необходимая для цикла while (см. в цикле for, который ниже)
        r = 1;
        % Сортируем массив SortHU по приоритету, с учетом зоны работы ГА
        for zn = 1:1:max(CheckZoneHU)
            temp (1:3, 1:cnt_HU) = 0;  
            k = 1;
            % Заполняем промежуточную матрицу, в которой содержатся ГА только из
            % идентичных зон
            for g = 1:1:sz        
                if (SortHU(2, g) == zn)
                    temp(1, k) = SortHU(1, g);
                    temp(2, k) = SortHU(2, g);
                    temp(3, k) = SortHU(3, g);            
                    k = k + 1;            
                end        
            end
            % Удаляем пустые значения в матрице (если они есть)
            for b = 1:1:cnt_HU
                if (temp(1, b) == 0)
                    temp(:, b:cnt_HU) = [];
                    break;
                end   
            end

            lgh_t = length(temp(1, :));
            % Сортируем этот массив относительно 3 строки (по приоритету) 
            for j = 1:1:lgh_t
                num_min = j;
                for i = j:1:lgh_t
                    if (temp(3, i) < temp(3, num_min))
                       num_min = i;
                    end
                end

                tempZone = temp(3, j);
                tempHU = temp(1, j);

                temp(3, j) = temp(3, num_min);
                temp(1, j) = temp(1, num_min);

                temp(3, num_min) = tempZone;
                temp(1, num_min) = tempHU;
            end

            i = 1;
            % Меняем массив SortHU для конкретной зоны работы относительно
            % приоритета (с помощью матрицы temp)
            while (lgh_t ~= 0 && r <= sz && SortHU(2, r) == temp(2,1))

                SortHU(1, r) = temp(1, i);
                SortHU(3, r) = temp(3, i);

                r = r + 1;
                i = i + 1;
            end
        end
        % Вызываем функцию определения ГА, необходимого к переводу в другую зону
        FindHU_down(cnt_HU);
    end
end
