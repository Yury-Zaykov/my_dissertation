function GeneralAlgorithmGRARM(cnt_HU, ctl_PP, i, j, tStep, Ta)

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
    CalcTransferHU(cnt_HU);
    
    % Фунция статического задатчика мощности (СЗМ)   
    StaticSetterPower(cnt_HU, ctl_PP, i);
    
    % Фунция динамического задатчика мощности (ДЗМ)
    DynamicSetterPower(cnt_HU, j, tStep, Ta);
        
end