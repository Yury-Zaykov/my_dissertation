% Функция расчета ГА, необходимого для перевода в след зону работы
function CalcTransferHU(cnt_HU, i)

    global CtlCheckZoneHU priority SortHU DefUpZone DefDownZone
    global outChangeZup outChangeZdown 
    
    if (outChangeZup)
    
        % Матрица для сортировки ГА, пригодных к переводу в след зону работы
        SortHU(1:3, 1:cnt_HU) = 0;
        % Цикл заполнения ГА, которые не работают в самой верхней зоне и не
        % находятся в режиме перехода
        k = 1;
        for p = 1:1:cnt_HU
            if (DefUpZone(1, p) == 0)
                SortHU(1, k) = p;
                k = k + 1;
            end
        end
        % Заполняем 2 строку, означающую зону работы каждого ГА
        for p = 1:1:cnt_HU
            if (SortHU(1,p) ~= 0)
                SortHU(2, p) = CtlCheckZoneHU(1, SortHU(1, p));
            end
        end
        % Удаляем нулевые значения, оставшиеся в матрице, т.к. они нам больше не
        % нужны
        for p = 1:1:cnt_HU
            if (SortHU(1, p) == 0)
                SortHU(:, p:cnt_HU) = [];
                break;
            end
        end
        % Узнаем длину текущего массива
        sz = length(SortHU(1, :));
        if (sz == 1) 
            FindHU_up(cnt_HU, i);
        else
            % Сортируем массив по возрастанию относительно 2 строки (зоны работы)
            for j = 1:1:sz   
                num_min = j;   
                for p = j:1:sz  
                    if (SortHU(2, p) < SortHU(2, num_min))
                       num_min = p;
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
            for p = 1:1:sz
                for j = 1:1:cnt_HU
                    if (SortHU(1, p) == priority(1, j))            
                        SortHU(3, p) = priority(2, j);            
                    end 
                end
            end
            % Переменная, необходимая для цикла while (см. в цикле for, который ниже)
            r = 1;
            % Сортируем массив по приоритету, с учетом зоны работы ГА
            for zn = 1:1:max(CtlCheckZoneHU)
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
                    for p = j:1:lgh_t
                        if (temp(3, p) < temp(3, num_min))
                           num_min = p;
                        end
                    end

                    tempZone = temp(3, j);
                    tempHU = temp(1, j);

                    temp(3, j) = temp(3, num_min);
                    temp(1, j) = temp(1, num_min);

                    temp(3, num_min) = tempZone;
                    temp(1, num_min) = tempHU;
                end

                p = 1;
                % Меняем массив HUandNumZone для конкретной зоны работы относительно
                % приоритета (с помощью матрицы temp)
                while (lgh_t ~= 0 && r <= sz && SortHU(2, r) == temp(2,1))

                    SortHU(1, r) = temp(1, p);
                    SortHU(3, r) = temp(3, p);

                    r = r + 1;
                    p = p + 1;
                end
            end
            % Вызываем функцию определения ГА, необходимого к переводу в след. зону
            FindHU_up(cnt_HU, i);
        end
    end
    % Если есть запрос на разрузку ГА
    if (outChangeZdown)
        % Матрица для сортировки ГА, пригодных к переводу в след зону работы
        SortHU(1:3, 1:cnt_HU) = 0;
        % Цикл заполнения ГА, которые не работают в самой нижней зоне и не
        % находятся в режиме перехода
        k = 1;
        for p = 1:1:cnt_HU
            if (DefDownZone(1, p) == 0) % && TransferHU(1, i) == 0)
                SortHU(1, k) = p;
                k = k + 1;
            end
        end
        % Заполняем 2 строку, озн-ую зону работы каждого ГА в конкретный момент времени
        for p = 1:1:cnt_HU
            if (SortHU(1,p) ~= 0)
                SortHU(2, p) = CtlCheckZoneHU(1, SortHU(1, p));
            end
        end
        % Удаляем нулевые значения, оставшиеся в матрице, т.к. они нам больше не нужны
        for p = 1:1:cnt_HU
            if (SortHU(1, p) == 0)
                SortHU(:, p:cnt_HU) = [];
                break;
            end
        end
        % Узнаем длину текущего массива
        sz = length(SortHU(1, :));
        if (sz == 1) 
            FindHU_down(cnt_HU, i);
        else
            % Сортируем массив по возрастанию относительно 2 строки (зоны работы)
            for j = 1:1:sz   
                num_max = j;   
                for p = j:1:sz  
                    if (SortHU(2, p) > SortHU(2, num_max))
                       num_max = p;
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
            for p = 1:1:sz
                for j = 1:1:cnt_HU
                    if (SortHU(1, p) == priority(1, j))            
                        SortHU(3, p) = priority(2, j);            
                    end 
                end
            end
            % Переменная, необходимая для цикла while (см. в цикле for, который ниже)
            r = 1;
            % Сортируем массив SortHU по приоритету, с учетом зоны работы ГА
            for zn = 1:1:max(CtlCheckZoneHU)
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
                    for p = j:1:lgh_t
                        if (temp(3, p) < temp(3, num_min))
                           num_min = p;
                        end
                    end

                    tempZone = temp(3, j);
                    tempHU = temp(1, j);

                    temp(3, j) = temp(3, num_min);
                    temp(1, j) = temp(1, num_min);

                    temp(3, num_min) = tempZone;
                    temp(1, num_min) = tempHU;
                end

                p = 1;
                % Меняем массив SortHU для конкретной зоны работы относительно
                % приоритета (с помощью матрицы temp)
                while (lgh_t ~= 0 && r <= sz && SortHU(2, r) == temp(2,1))

                    SortHU(1, r) = temp(1, p);
                    SortHU(3, r) = temp(3, p);

                    r = r + 1;
                    p = p + 1;
                end
            end
            % Вызываем функцию определения ГА, необходимого к переводу в другую зону
            FindHU_down(cnt_HU, i);
        end
    end
end