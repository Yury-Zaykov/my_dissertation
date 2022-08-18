% Функция определения тренда (направления мощности станции, на загрузку 
% или разгрузку). Если загружаем, то 1. Разгружаем - 0.
function CalcDefTrend(cnt_HU, ctl_PP, i)

    global trend ctlHU_P
    
    
       if (ctl_PP(1, i) >= ctlHU_P(1, cnt_HU + 1)) 
           trend(1, i) = 1;
       else
           trend(1, i) = 0; 
       end 
end