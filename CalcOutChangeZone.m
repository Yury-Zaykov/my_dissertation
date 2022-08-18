% Функция расчета выходного сигнала на смену зоны работы ГА
function CalcOutChangeZone(cnt_HU, tStep)
    
    global DefUpZone DefDownZone ToUnload ToLoad t_CZup t_CZdown  
    global outChangeZdown outChangeZup dP_cm_zon dt_cm_zon 
    
    allHU_UpZone = sum(DefUpZone);
    allHU_DownZone = sum(DefDownZone);
    
    % if для таймера (на загрузку ГА)
    if (allHU_UpZone ~= cnt_HU && ToLoad(1, cnt_HU + 1) < dP_cm_zon && t_CZup <= dt_cm_zon + 0.2)
        t_CZup = t_CZup + tStep;
    else
        t_CZup = 0;
    end
    
    if (allHU_DownZone ~= cnt_HU && ToUnload(1, cnt_HU + 1) < dP_cm_zon && t_CZup <= dt_cm_zon + 0.2)
        t_CZdown = t_CZdown + tStep;
    else
        t_CZdown = 0;
    end
    %-------------------------------------------------------------------------------------
    % if для переменной outChangeZup, которая, при значении true, будет
    % запускать функцию смены зоны работы ГА
    if (t_CZup >= dt_cm_zon)
        outChangeZup = true;
    else
        outChangeZup = false;
    end
    
    if (t_CZdown >= dt_cm_zon)
        outChangeZdown = true;
    else
        outChangeZdown = false;
    end  
end