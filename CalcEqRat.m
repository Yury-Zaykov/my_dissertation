% Функция расчета долевых коэффициентов
function CalcEqRat(cnt_HU, Nom_P_HU, maxNom_PP)

    global EqRatio
    
    for i = 1:1:cnt_HU
        EqRatio(1, i) = Nom_P_HU(1, i) / maxNom_PP;
    end
end