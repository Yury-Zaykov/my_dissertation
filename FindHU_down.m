% Функция расчета (выбора) ГА, подходящего к переводу в другую рабочую зону.
% Используется в функции CalcTransferHU
function FindHU_down(cnt_HU, i)
    
    global ZoneUnWork ctlHU_P Nom_P_HU SortHU  
    global dP_cm_zon_con CtlCheckZoneHU priority ctl_PP
    
    maxZone = max(CtlCheckZoneHU) + 1;

    for m = 1:1:length(SortHU(1, :))
        %Матрица, хранящая осток мощности от разницы между тем, что посчитали и
        %текущей границей работы ГА
        Leftover(1, 1:cnt_HU + 1) = 0;
        %Матрица, хранящая значения для ГА, вышедших за допустимую зону работы при
        %промежуточных расчетах
        UnZone(1, 1:cnt_HU) = 0;
        
        NumHU = SortHU(1, 1);
        temp_ctlHU_P = ctlHU_P(1, NumHU);
        % В зависимости от зоны работы ГА, узнаем, в какую следующую зону 
        % нужно перевести ГА
        v = 2;
        for c = 2:1:maxZone
            if (SortHU(2, 1) == c)
                temp_CtlCheckZoneHU = CtlCheckZoneHU(1, NumHU);
                CtlCheckZoneHU(1, NumHU) = c - 1;
                ctlHU_P(1, NumHU) = ZoneUnWork(v , NumHU) * 0.995;
                break;
            end
            v = v + 2;
        end
        ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));

        % Находим остаток мощности, необходимый к распределению
        Leftover(1, cnt_HU+1) = ctl_PP(1, i) - ctlHU_P(1, cnt_HU+1);
        
        % Если разница между заданной и текущей статичекой мощностью велика, 
        % то идем по алгоритму, а иначе ничего не делаем
        if (Leftover(1, cnt_HU+1) > 0)

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
                    z = 1;
                    v = 2;
                    for c = 1:1:maxZone
                        if (CtlCheckZoneHU(1, j) == c)
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
                                if(ctlHU_Pg(1, j) < ZoneUnWork(z, j))

                                end

                                if (c == 1 && ctlHU_Pg(1, j) < ZoneUnWork(1, j))
                                    ctlHU_P_temp(1, j) = ZoneUnWork(1, j);
                                    Leftover(1, j) = 0;
                                    break;
                                else
                                    ctlHU_P_temp(1, j) = ctlHU_Pg(1, j);
                                    Leftover(1, j) = ctlHU_Pg(1, j) - ctlHU_P_temp(1, j);
                                    break;                                   
                                end
                            end
                        end
                        v = v + 2;
                        z = z + 2;
                    end
                end
               % Находим суммы для этих матриц (т.е. для всей станции)
                Leftover(1, cnt_HU + 1)     = sum(Leftover(1, 1:cnt_HU));
                ctlHU_P_temp(1, cnt_HU + 1) = sum(ctlHU_P_temp(1, 1:cnt_HU));
            end
        end
        %---------------------------------------------------------------------------------
        % Если разгружаем
        if (Leftover(1, cnt_HU+1) < 0)

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
                    v = 1;
                    for c = 1:1:maxZone
                        if (CtlCheckZoneHU(1, j) == c)                            
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
        end
        
        %Инициализируем массив, хранящий данные на загрузку по ГА
        toLoad(1, 1:cnt_HU + 1) = 0;
        % В зависимости от зоны работы ГА, рассчитываем мощность ГА на загрузку
        for k = 1:1:cnt_HU     
            % В зависимости от зоны работы ГА, рассчитываем мощность ГА на
            % загрузку
            if (k ~= NumHU)
                % Переменная счетчик, для алгоритма
                v = 2;
                % Проверяем для всех возможных зон для данного ГА
                for c = 1:1:maxZone
                    if (CtlCheckZoneHU(1, k) == c)
                        toLoad(1, k) = ZoneUnWork(v, k) - ctlHU_P_temp(1, k);
                        break;
                    end
                    v = v + 2;
                end
            end
        end
        % Находим сумму на разгрузку при данных раскладах
        toLoad(1, cnt_HU + 1) = sum(toLoad(1, 1:cnt_HU));
        % Сравниваем с уставкой
        if (toLoad(1, cnt_HU + 1) < dP_cm_zon_con)
            SortHU(:, 1) = [];
            ctlHU_P(1, NumHU) = temp_ctlHU_P;
            ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
            CtlCheckZoneHU(1, NumHU) = temp_CtlCheckZoneHU;
        else
            for j = 1:1:cnt_HU
                ctlHU_P(1, j) = ctlHU_P_temp(1, j);
            end
            ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
            break;
        end
    end
    % Меняем приоритет, для того, чтобы нагрузка на ГА была равномерной
    for pio = 1:1:cnt_HU-1
        k = pio + 1;
        temp = priority(2, pio);
        priority(2, pio) = priority(2, k);
        priority(2, k) = temp;
    end
end