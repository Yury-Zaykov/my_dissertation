% Функция определения агрегатов в вехней и нижней зонах работы 
function CalcDefUpDownZone(cnt_HU)
    
    global cntZoneUnw DefUpZone DefDownZone CtlCheckZoneHU
    
    for i = 1:1:cnt_HU
        if (CtlCheckZoneHU(1, i) == cntZoneUnw(1, i) + 1)          
            DefUpZone(1, i) = true;
        else
            DefUpZone(1, i) = false;
        end
        
        if (CtlCheckZoneHU(1, i) == 1)
            DefDownZone(1, i) = true;
        else
            DefDownZone(1, i) = false;
        end
    end
end