% Функция расчета зоны работы ГА
function CalcCheckZone(cnt_HU)
    
    global CtlCheckZoneHU ZoneUnWork cntZoneUnw ctlHU_P 

    % Цикл перебора каждого ГА, определение зоны ведется относительно заданной мощности
    for i = 1:1:cnt_HU
        % Присваеваем переменной HUP мощность ГА, который рассматриваем
        % в данный момент
        HUP = ctlHU_P(1, i);
        maxZone = cntZoneUnw(1, i) + 1;

        if (HUP >= 0 && HUP < ZoneUnWork(2, i))
            CtlCheckZoneHU(1, i) = 1;
        else
            v = 2;
            u = 4;  
            for c = 2:1:maxZone
                if (HUP > ZoneUnWork(v, i) && HUP < ZoneUnWork(u, i))
                    CtlCheckZoneHU(1, i) = c;
                    break;
                end
                v = v + 2;
                u = u + 2;
            end
        end
    end
end