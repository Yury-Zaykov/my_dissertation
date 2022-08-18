% Статический задатчик мощности
function StaticSetterPower(cnt_HU, ctl_PP, i)
    %% Входные данные (глобальные переменные)
    global ctlHU_P ZoneUnWork Nom_P_HU outChangeZup outChangeZdown CtlCheckZoneHU 
    %% Собственные переменные фунции

    maxZone = max(CtlCheckZoneHU);

    %Матрица, хранящая значения для ГА, вышедших за допустимую зону работы при
    %промежуточных расчетах
    UnZone(1, 1:cnt_HU) = 0;

    %Матрица, хранящая осток мощности от разницы между тем, что посчитали и
    %текущей границей работы ГА
    Leftover(1, 1:cnt_HU + 1) = 0;
    
    %% CЗМ
    %---------------------------------------------------------------------------------
    % У нас имеется мощность задання на всю станцию (в конкретный момент времени) 
    % и текущая мощность, вырабатываемая станцией. Найдя разницу между ними, найдем
    % разницу(небаланс) между тем, что нужно выработать и тем что уже вырабатываем
    %---------------------------------------------------------------------------------

    Leftover(1, cnt_HU+1) = ctl_PP(1, i) - ctlHU_P(1, cnt_HU+1);
      
    % Если разница между заданной и текущей статичекой мощностью велика, 
    % то идем по алгоритму, а иначе ничего не делаем
    if (Leftover(1, cnt_HU+1) > 0.001 && ~outChangeZup) % && ~outChangeZdown)

        % Присвоим временной матрице текущую задачу статической мощности
        for j = 1:1:cnt_HU
            ctlHU_P_temp(1, j) = ctlHU_P(1, j);
        end
        
        % Производим расчет, пока небаланс не станет оптимальным или
        % все ГА станут ограничены зоной своей работы
        while(sum(UnZone) < cnt_HU && Leftover(1, cnt_HU+1) > 0.1)

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

        % Если небаланс при расчетах уменьшился или все ГА вышли за зоны своей работы,
        % в этом случае, записываем в СЗМ рассчитанную мощность
        for j = 1:1:cnt_HU
            ctlHU_P(1, j) = ctlHU_P_temp(1, j);
        end
        ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
    end
    %---------------------------------------------------------------------------------
    % Если разгружаем
    if (Leftover(1, cnt_HU+1) < -0.001 && ~outChangeZdown) % && ~outChangeZup)

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

        for j = 1:1:cnt_HU
            ctlHU_P(1, j) = ctlHU_P_temp(1, j);
        end
        ctlHU_P(1, cnt_HU+1) = sum(ctlHU_P(1, 1:cnt_HU));
     end
end