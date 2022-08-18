function DynamicSetterPower(cnt_HU, j, tStep)
    
    global HU_Pow ctlHU_P Array_P dP_SL T_e T_b dt_b

    for hu = 1:1:cnt_HU
        
        Ps = (ctlHU_P(1, hu) - HU_Pow(1, hu)) / T_e;
        
        if (Ps > 0)
            if (Ps > dP_SL)
                HU_Pow(1, hu) =  HU_Pow(1, hu) + ...
                   dP_SL * tStep;
                %Запись текущего значения мощности в массив (для графиков)
                Array_P(j, hu) = HU_Pow(1, hu);

            else
                %Расчет текущего значения мощности
                HU_Pow(1, hu) =  HU_Pow(1, hu) + ...
                    (ctlHU_P(1, hu) - HU_Pow(1, hu)) * tStep / T_e; 
                %Запись текущего значения мощности в массив (для графиков)
                Array_P(j, hu) = HU_Pow(1, hu);
            end
        else
            if (abs(Ps) > dP_SL) 
                HU_Pow(1, hu) =  HU_Pow(1, hu) - ...
                   dP_SL * tStep; 
                %Запись текущего значения мощности в массив (для графиков)
                Array_P(j, hu) = HU_Pow(1, hu);

            else
                %Расчет текущего значения мощности
                HU_Pow(1, hu) =  HU_Pow(1, hu) + ...
                    (ctlHU_P(1, hu) - HU_Pow(1, hu)) * tStep / T_e; 
                %Запись текущего значения мощности в массив (для графиков)
                Array_P(j, hu) = HU_Pow(1, hu);
            end
        end
    end
    HU_Pow(1, cnt_HU+1) = sum(HU_Pow(1, 1:cnt_HU));
    %----------------------------------------------------------------
    % Вариант работы при задаче мощности меньшей, чем текущая мощность
% for hu = 1:1:cnt_HU
% 
%     Ps = (ctlHU_P(1, hu) - HU_Pow(1, hu)) / T_e;
%     
%     if (Ps > 0)
%         
%         P0 = dP_SL * exp(-dt_b / T_b);
% 
%         P_end_max = (ctlHU_P(1, hu) - HU_Pow(1, hu)) / T_b;
% 
%         P_din = (ctlHU_P(1, hu) - HU_Pow(1, hu)) / T_e;
% 
%         P_max = dP_SL;
% 
%         if (P_din < P0)
%             P_din = 1.05 * P0;
%         else
%             if (P_din < P_max)
%                 P_din = P_din * exp(tStep / T_b);
%             else
%                 if (P_din > P_max)
%                     P_din = P_max;
%                 else
%                     if (P_din > P_end_max)
%                         P_din = P_end_max;
%                     end
%                 end
%             end
%         end
% 
%         
%          HU_Pow(1, hu) =  HU_Pow(1, hu) + P_din * tStep;
%          Array_P(j, hu) = HU_Pow(1, hu);
%         
%     else
%         
%     
%         P0 = dP_SL * exp(-dt_b / T_b);
% 
%         P_end_max = (HU_Pow(1, hu) - ctlHU_P(1, hu)) / T_b;
% 
%         P_din = (HU_Pow(1, hu) - ctlHU_P(1, hu)) / T_e;
% 
%         P_max = dP_SL;
% 
%         if (P_din < P0)
%             P_din = 1.05 * P0;
%         else
%             if (P_din < P_max)
%                 P_din = P_din * exp(tStep / T_b);
%             else
%                 if (P_din > P_max)
%                     P_din = P_max;
%                 else
%                     if (P_din > P_max)
%                         P_din = P_max;
%                     else
%                         if (P_din > P_end_max)
%                             P_din = P_end_max;
%                         end
%                     end
%                 end
%             end
%         end
%         HU_Pow(1, hu) =  HU_Pow(1, hu) - P_din * tStep; 
%         Array_P(j, hu) = HU_Pow(1, hu);
%     end
%     
% end
% HU_Pow(1, cnt_HU+1) = sum(HU_Pow(1, 1:cnt_HU));
end