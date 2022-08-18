% Функция для построения графиков
function CalcSchedules (cnt_HU, j, tStep, count_seconds)
    
    global Array_P cntZoneUnw ZoneUnWork

    %Создаем шкалу времени
    %t = 0:seconds(0.005):minutes(30);
    t = 0:tStep:count_seconds;
    Nul(1, 1:count_seconds/tStep + 1) = 0;

    % Создаем структуру массивов, хранящую линии нежелательных зон работы ГА
    LimLineHU = struct('HUS', {});

    % Инициализируем структуру массивов 0
    for i = 1:1:cnt_HU
        LimLineHU(i).HUS = zeros(j, cntZoneUnw(1, i) * 2 + 2);
    end

    % Заполняем структуру массивов линиями нежелательных зон работы ГА
    for i = 1:1:cnt_HU
        for j = 1:1:max(cntZoneUnw) * 2 + 2
            LimLineHU(i).HUS(:, j) = ZoneUnWork(j, i);   
        end
    end

    %--------------------------------------------------------------------------
    %Рисуем графики

    % Конструкция - 'Name','XXX' позволяет дать имя окну figure
    % Конструкция - 'Position', [200 100 1500 800] позволяет вывести окно в 
    % в заданых масштабах и в заданной области экрана
    %figure('Name','Изменения мощности всех ГА', 'Position', [200 100 1500 800]);

    % Данная запись позволяет вставить в одно окно figure несколько вкладок
    % tab1 = uitab('Title','HU 1');
    % ax1 = axes(tab1);
    %--------------------------------------------------------------------------
    figure('Name','1, 2 HU');
        clf;
        
    %----------------------------------------------------------------------       
    % 1 ГА
%         tab1 = uitab('Title','HU 1');
%         ax1 = axes(tab1);
%         hold on;
%         %subplot(111)
%         plot(t, Array_P(:, 1), 'Color', '#544ECC', 'LineWidth', 2);
%             grid on;
%             xlabel('Время, с');
%             ylabel('P, МВт');
%             %legend({'1_Г_А' '2 ГА'},'Location','southeast');
%             title('Изменение мощности 1 ГА');
%             ytickformat('%g МВт')
% 
%         % Линии, отображающие зоны нежелательной работы для 1 ГА
%         for q = 2:1:cntZoneUnw(1,1) * 2 + 1
%             plot(t, LimLineHU(1).HUS(:, q), 'Color', '#A8372A', 'LineWidth', 1)
%         end
% 
%         % Отображаем линии ограничения в двух вариантах. 1 - при наличии нижней границе, 2
%         % без нее
%         if (ZoneUnWork(1,1) == 0)
%             plot(t, LimLineHU(1).HUS(:, 1),'Color', '#33EB6A');
%         else
%             plot(t, Nul,'Color', '#33EB6A', 'LineWidth', 1);
%             plot(t, LimLineHU(1).HUS(:, 1),'Color', '#A8372A', 'LineWidth', 1);
%         end
%         
%         % Линия, указывающая масимум выработки мощности 1 ГА
%         plot(t, LimLineHU(1).HUS(:, cntZoneUnw(1,1) * 2 + 2),...
%             'Color', '#33EB6A', 'LineWidth', 1);
% %         x0 = min(t);
% %         y0 = 64;
% %         x1 = max(t);
% %         y1 = 64;
% %         fill([x0, t],[y0, LimLineHU(1).HUS(:, 3)],'g');
%         
%         
%         
%         hold off;
%     %--------------------------------------------------------------------------    
%     % 2 ГА
%         tab2 = uitab('Title','HU 2');
%         ax2 = axes(tab2);
%         % subplot(111)
%         plot(t, Array_P(:, 2),...
%             'Color', '#544ECC',...
%             'LineWidth',2);
%             %'DurationTickFormat','mm:ss');
%             grid on;
%             xlabel('Время, с');
%             ylabel('P, МВт');
%             %legend({'P_2'},'Location','southeast');
%             title('Изменение мощности 2 ГА');
%             ytickformat('%g МВт')
% 
%         hold on;
% 
%         % Линии, указывающие зоны нежелательной работы
%         for q = 2:1:cntZoneUnw(1, 2) * 2 + 1
%             plot(t, LimLineHU(2).HUS(:, q), 'Color', '#A8372A', 'LineWidth', 1)
%         end
%         
%         % Отображаем линии ограничения в двух вариантах. 1 - при наличии нижней границе, 2
%         % без нее
%         if (ZoneUnWork(1,2) == 0)
%             plot(t, LimLineHU(2).HUS(:, 1),'Color', '#33EB6A');
%         else
%             plot(t, Nul,'Color', '#33EB6A', 'LineWidth', 1);
%             plot(t, LimLineHU(2).HUS(:, 1),'Color', '#A8372A', 'LineWidth', 1);
%         end
% 
%         % Линия, указывающая масимум выработки мощности 2 ГА
%         plot(t, LimLineHU(2).HUS(:, cntZoneUnw(1,2) * 2 + 2),...
%             'Color', '#33EB6A', 'LineWidth', 1);
% 
%         hold off;
%     %--------------------------------------------------------------------------
%     % 3 ГА
%         tab3 = uitab('Title','HU 3');
%         ax3 = axes(tab3);
%         % subplot(111)
%         plot(t, Array_P(:, 3),...
%             'Color', '#544ECC',...
%             'LineWidth',2);
%             grid on;
%             xlabel('Время, с');
%             ylabel('P, МВт');
%             %legend({'P_H_U_3'},'Location','southeast');
%             title('Изменение мощности 3 ГА');
%             ytickformat('%g МВт')
% 
%         hold on;
% 
%         % Линии, указывающие зоны нежелательной работы
%         for q = 2:1:cntZoneUnw(1, 3) * 2 + 1
%             plot(t, LimLineHU(3).HUS(:, q), 'Color', '#A8372A', 'LineWidth', 1)
%         end
% 
%         % Отображаем линии ограничения в двух вариантах. 1 - при наличии нижней границе, 2
%         % без нее
%         if (ZoneUnWork(1,3) == 0)
%             plot(t, LimLineHU(3).HUS(:, 1),'Color', '#33EB6A');
%         else
%             plot(t, Nul,'Color', '#33EB6A', 'LineWidth', 1);
%             plot(t, LimLineHU(3).HUS(:, 1),'Color', '#A8372A', 'LineWidth', 1);
%         end
%         
%         % Линия, указывающая масимум выработки мощности 1 ГА
%         plot(t, LimLineHU(3).HUS(:, cntZoneUnw(1,3) * 2 + 2),...
%             'Color', '#33EB6A', 'LineWidth', 1);
% 
%         hold off;
% %     %--------------------------------------------------------------------------
%     % 4 ГА
%         tab4 = uitab('Title','HU 4');
%         ax4 = axes(tab4);
%         % subplot(111)
%         plot(t, Array_P(:, 4),...
%             'Color', '#544ECC',...
%             'LineWidth',2);
%             grid on;
%             xlabel('Время, с');
%             ylabel('P, МВт');
%             %legend({'P_4'},'Location','southeast');
%             title('Изменение мощности 4 ГА');
%             ytickformat('%g МВт')
% 
%         hold on;
% 
%         % Линии, указывающие зоны нежелательной работы
%         for q = 2:1:cntZoneUnw(1, 4) * 2 + 1
%             plot(t, LimLineHU(4).HUS(:, q), 'Color', '#A8372A', 'LineWidth', 1)
%         end
% 
%         % Отображаем линии ограничения в двух вариантах. 1 - при наличии нижней границе, 2
%         % без нее
%         if (ZoneUnWork(1,4) == 0)
%             plot(t, LimLineHU(4).HUS(:, 1),'Color', '#33EB6A');
%         else
%             plot(t, Nul,'Color', '#33EB6A', 'LineWidth', 1);
%             plot(t, LimLineHU(4).HUS(:, 1),'Color', '#A8372A', 'LineWidth', 1);
%         end
%          
%         % Линия, указывающая масимум выработки мощности 1 ГА
%         plot(t, LimLineHU(4).HUS(:, cntZoneUnw(1,4) * 2 + 2),...
%             'Color', '#33EB6A', 'LineWidth', 1);
% 
%         hold off;
% %     %--------------------------------------------------------------------------
% %     % 5 ГА
%         tab5 = uitab('Title','HU 5');
%         ax5 = axes(tab5);
%         % subplot(111)
%         plot(t, Array_P(:, 5),...
%             'Color', '#544ECC',...
%             'LineWidth',2);
%             grid on;
%             xlabel('Время, с');
%             ylabel('P, МВт');
%             %legend({'P_4'},'Location','southeast');
%             title('Изменение мощности 4 ГА');
%             ytickformat('%g МВт')
% 
%         hold on;
% 
%         % Линии, указывающие зоны нежелательной работы
%         for q = 2:1:cntZoneUnw(1, 5) * 2 + 1
%             plot(t, LimLineHU(5).HUS(:, q), 'Color', '#A8372A', 'LineWidth', 1)
%         end
% 
%         % Отображаем линии ограничения в двух вариантах. 1 - при наличии нижней границе, 2
%         % без нее
%         if (ZoneUnWork(1,1) == 0)
%             plot(t, LimLineHU(5).HUS(:, 1),'Color', '#33EB6A');
%         else
%             plot(t, Nul,'Color', '#33EB6A', 'LineWidth', 1);
%             plot(t, LimLineHU(5).HUS(:, 1),'Color', '#A8372A', 'LineWidth', 1);
%         end
%          
%         % Линия, указывающая масимум выработки мощности 5 ГА
%         plot(t, LimLineHU(5).HUS(:, cntZoneUnw(1,5) * 2 + 2),...
%             'Color', '#33EB6A', 'LineWidth', 1);
% 
%         hold off;
% %         
% %     %--------------------------------------------------------------------------
% %     % 6 ГА
%         tab6 = uitab('Title','HU 6');
%         ax6 = axes(tab6);
%         % subplot(111)
%         plot(t, Array_P(:, 6),...
%             'Color', '#544ECC',...
%             'LineWidth',2);
%             grid on;
%             xlabel('Время, с');
%             ylabel('P, МВт');
%             %legend({'P_4'},'Location','southeast');
%             title('Изменение мощности 4 ГА');
%             ytickformat('%g МВт')
% 
%         hold on;
% 
%         % Линии, указывающие зоны нежелательной работы
%         for q = 2:1:cntZoneUnw(1, 6) * 2 + 1
%             plot(t, LimLineHU(6).HUS(:, q), 'Color', '#A8372A', 'LineWidth', 1)
%         end
% 
%         % Отображаем линии ограничения в двух вариантах. 1 - при наличии нижней границе, 2
%         % без нее
%         if (ZoneUnWork(1,6) == 0)
%             plot(t, LimLineHU(6).HUS(:, 1),'Color', '#33EB6A');
%         else
%             plot(t, Nul,'Color', '#33EB6A', 'LineWidth', 1);
%             plot(t, LimLineHU(6).HUS(:, 1),'Color', '#A8372A', 'LineWidth', 1);
%         end
%          
%         % Линия, указывающая масимум выработки мощности 1 ГА
%         plot(t, LimLineHU(6).HUS(:, cntZoneUnw(1,6) * 2 + 2),...
%             'Color', '#33EB6A', 'LineWidth', 1);
% 
%         hold off;
%     %--------------------------------------------------------------------------
%     % Все ГА на одном графике
%         tab3 = uitab('Title','HU PS');
%         ax3 = axes(tab3);
%         hold on;
%         %subplot(111)
%         plot(t, Array_P(:, 1),...
%             'Color', '#968766',...
%             'LineWidth', 2);
%             %'DurationTickFormat','mm:ss');
%         plot(t, Array_P(:, 2),...
%             'Color', '#FADF47',...
%             'LineWidth', 2);
%             %'DurationTickFormat','mm:ss');
% %         plot(t, Array_P(:, 3), 'Color', '#29D4A7', 'LineWidth', 2);
% %         plot(t, Array_P(:, 4), 'Color', '#CC76E8', 'LineWidth', 2);
% %         plot(t, Array_P(:, 5), 'Color', '#07EB12', 'LineWidth', 2);
% %         plot(t, Array_P(:, 6), 'Color', '#F2185E', 'LineWidth', 2);
%             grid on;
%             xlabel('Время, с');
%             ylabel('P, МВт');
%             legend({'1ГА' '2ГА'},'Location','southeast');
%             title('Изменение мощности всех ГА');
%             ytickformat('%g МВт')
% 
%         
% 
% %         % Линии, отображающие зоны нежелательной работы для 1 ГА
% %         for q = 2:1:cntZoneUnw(1,1) * 2 + 1
% %             plot(t, LimLineHU(1).HUS(:, q), 'Color', '#A8372A', 'LineWidth', 1)
% %         end
% % 
% %         % Отображаем линии ограничения в двух вариантах. 1 - при наличии нижней границе, 2
% %         % без нее
% %         if (ZoneUnWork(1,1) == 0)
% %             plot(t, LimLineHU(1).HUS(:, 1),'Color', '#33EB6A');
% %         else
% %             plot(t, Nul,'Color', '#33EB6A', 'LineWidth', 1);
% %             plot(t, LimLineHU(1).HUS(:, 1),'Color', '#A8372A', 'LineWidth', 1);
% %         end
% %         
% %         % Линия, указывающая масимум выработки мощности 1 ГА
% %         plot(t, LimLineHU(1).HUS(:, cntZoneUnw(1,1) * 2 + 2),...
% %             'Color', '#33EB6A', 'LineWidth', 1);
% 
%         hold off;
%     %----------------------------------------------------------------------    
%     % Все ГА
%         tab4 = uitab('Title','ALL HU');
%         ax4 = axes(tab4);
%         %subplot(111)
%         plot(t, Array_P(:, 3),...
%             'Color', '#66BCE8',...
%             'LineWidth',2,...);
%             %'DurationTickFormat','mm:ss');
%             grid on;
%             xlabel('Время, с'); 
%             ylabel('Мощность, МВт');
%             legend({'P_A_l_l'},'Location','southeast');
%             title('Изменение мощности станции');
%             ytickformat('%g МВт')
%             %xtickangle(15);
%     
%             
            
        
    % С помощью этой команды, можно самому задавать значения X, которые мы
    % хотим видеть на графике (именно отображение)
    %xticklabels({'100'});
%-----------------------------------------------------------------------------------------
%                            ДЛЯ УСТЬ-ХОНТАЙСКОЙ ГЭС
%-----------------------------------------------------------------------------------------
        % 2, 3, 4, 5, 7 ГА
        tab1 = uitab('Title','HU 2-5, 7');
        ax1 = axes(tab1);
        hold on;
        % subplot(111)
        plot(t, Array_P(:, 2),...
            'Color', '#19F69A',...
            'LineWidth',2);
        plot(t, Array_P(:, 3),...
            'Color', '#D4D419',...
            'LineWidth',2);
        plot(t, Array_P(:, 4),...
            'Color', '#EB8529',...
            'LineWidth',2);
        plot(t, Array_P(:, 5),...
            'Color', '#D424BC',...
            'LineWidth',2);
        plot(t, Array_P(:, 7),...
            'Color', '#9E675C',...
            'LineWidth',2);
                   
            grid on;
            xlabel('Время, с');
            ylabel('P, МВт');
            legend({'2 ГА' '3 ГА' '4 ГА' '5 ГА' '7 ГА'},'Location','southeast','FontSize',12);
            legend('boxoff');
            %title('Изменение мощности 2 3 4 5 7 ГА');
            ytickformat('%g МВт')

        % Линии, указывающие зоны нежелательной работы
        for q = 2:1:cntZoneUnw(1, 2) * 2 + 1
            plot(t, LimLineHU(2).HUS(:, q), 'Color', '#A8372A', 'LineWidth', 1)
        end
        
        % Отображаем линии ограничения в двух вариантах. 1 - при наличии нижней границе, 2
        % без нее
        if (ZoneUnWork(1,2) == 0)
            plot(t, LimLineHU(2).HUS(:, 1),'Color', '#33EB6A');
        else
            plot(t, Nul,'Color', '#33EB6A', 'LineWidth', 1);
            plot(t, LimLineHU(2).HUS(:, 1),'Color', '#A8372A', 'LineWidth', 1);
        end

        % Линия, указывающая масимум выработки мощности 2 ГА
        plot(t, LimLineHU(2).HUS(:, cntZoneUnw(1,2) * 2 + 2),...
            'Color', '#33EB6A', 'LineWidth', 1);

        hold off;
%-----------------------------------------------------------------------------------------
        % 1, 6 ГА
        tab2 = uitab('Title','HU 1, 6');
        ax2 = axes(tab2);
        hold on;
        % subplot(111)
        plot(t, Array_P(:, 1),...
            'Color', '#EB983F',...
            'LineWidth',2,...
            'DisplayName','cos(x)');
        plot(t, Array_P(:, 6),...
            'Color', '#7E6F9E',...
            'LineWidth',2);

            grid on;
            xlabel('Время, с');
            ylabel('P, МВт');
            legend({'1 ГА' '6 ГА'},'Location','southeast','FontSize',12);
       
            legend('boxoff');
            %title('Изменение мощности 1 6 ГА');
            ytickformat('%g МВт')
            
        % Линии, отображающие зоны нежелательной работы для 1 ГА
%         for q = 2:1:cntZoneUnw(1,1) * 2 + 1
%             plot(t, LimLineHU(1).HUS(:, q), 'Color', '#A8372A', 'LineWidth', 1)
%         end


        % Отображаем линии ограничения в двух вариантах. 1 - при наличии нижней границе, 2
        % без нее
        if (ZoneUnWork(1,1) == 0)
            plot(t, LimLineHU(1).HUS(:, 1),'Color', '#33EB6A');
        else
            plot(t, Nul,'Color', '#33EB6A', 'LineWidth', 1);
            plot(t, LimLineHU(1).HUS(:, 1),'Color', '#A8372A', 'LineWidth', 1);
        end
        
        % Линия, указывающая масимум выработки мощности 1 ГА
        plot(t, LimLineHU(1).HUS(:, cntZoneUnw(1,1) * 2 + 2),...
            'Color', '#33EB6A', 'LineWidth', 1);
%-----------------------------------------------------------------------------------------
        % Все ГА
        tab3 = uitab('Title','ALL HU');
        ax3 = axes(tab3);
        %subplot(111)
        plot(t, Array_P(:, 8),...
            'Color', '#66BCE8',...
            'LineWidth',2);
            %'DurationTickFormat','mm:ss');
            grid on;
            xlabel('Время, с'); 
            ylabel('Мощность, МВт');
            legend({'P_A_l_l'},'Location','southeast','FontSize',14);
            legend('boxoff');
            %title('Изменение мощности станции');
            ytickformat('%g МВт')
 
end