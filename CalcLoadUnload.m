% Функция расчета мощности на загрузку и разгрузку всех ГА
function CalcLoadUnload(cnt_HU)
    
    global ZoneUnWork ToLoad ToUnload ctlHU_P CtlCheckZoneHU
    
    maxZone = max(CtlCheckZoneHU(1, 1:cnt_HU));
    
    % Цикл перебора каждого ГА
    for i = 1:1:cnt_HU
        v = 1;
        u = 2;
        for c = 1:1:maxZone
            if (CtlCheckZoneHU(1, i) == c)
                ToLoad(1, i) = ZoneUnWork(u, i) - ctlHU_P(1, i);
                ToUnload(1, i) = ctlHU_P(1, i) - ZoneUnWork(v, i);
                break;
            end
            v = v + 2;
            u = u + 2;
        end
    end
    ToLoad(1, cnt_HU + 1) = sum(ToLoad(1, 1:cnt_HU));
    ToUnload(1, cnt_HU + 1) = sum(ToUnload(1, 1:cnt_HU));
end