%%δ���

clear;
clc;
%%initialize PSAT and datafile.
dataFile='dataIEEE39'; %ϵͳ�����ļ�
initpsat;
%initLog(['log-',dataFile,'-',datestr(clock,30),'.txt'],1000,'apparent');
clpsat.readfile=0;
clpsat.mesg=0;
runpsat(dataFile,'data');
%%
%%modify operation condition and do power flow
runpsat('pf');
flag=1;

Settings.tf=4;%����ʱ��Ϊ4s
Settings.fixt=1;%����������
Settings.tstep=0.005;%ѡ�񲽳�Ϊ0.005s

casenum=2;%i1*i2*i3 ����һ��database�ļ����������
idx = 0;
for CT = 0.2:0.005:0.8%
    
    filename=strcat('database',num2str(flag));
    
    runpsat('pf');
    runpsat('td');
    
    
    for i2=1:35  %��35����·��ѭ����ÿһ����·������ĸ�������·�����·���г�
        Breaker.store(1)=i2;%���ù�����·
        Breaker.store(3:4)=Line.con(i2,3:4);
        for i3=1:2  %������ĸ�߷ֱ�����·
            faulttype=(i2-1)*2+i3;
            Fault.store(1)=Line.con(i2,i3);%����ʱ��ĸ��
            Breaker.store(2)=Line.con(i2,i3);
            Breaker.store(7)=CT;
            Fault.store(5)=0.1;
            Fault.store(2:3)=Line.con(i2,3:4);%
            Fault.store(6)=CT;%����ʱ�䴢��
            
            caseindex=2*(i2-1)+i3;
            
            runpsat('pf'); %�㳱��
            
            
            %             disp('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
            %             caseindex
            %             caseindex
            %             caseindex
            %             caseindex
            %             disp('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
            %%
            %ָ����̬�ȶ������
            indexGen=[31 30 32 33 34 35 36 37 38 39];%����������
            indexLoad=[3,4,7,8,12,15,16,18,20,21,23,24,25,26,27,28,29,31,39];%���ɵ����
            indexOmega=Syn.omega;
            
            StateVariable=1:1:DAE.n;%״̬����
            ActivePowerInjection=(DAE.n+DAE.m+1):1:(DAE.n + DAE.m + Bus.n);%�ڵ��й�ע��
            ReActivePowerInjection=(DAE.n + DAE.m + Bus.n+1):1:(DAE.n + DAE.m + 2*Bus.n);%�ڵ��޹�ע��
            ActivePower_ij=(DAE.n + DAE.m + 2*Bus.n+1):1:(DAE.n + DAE.m + 2*Bus.n+Line.n);%��·�й�
            ReActivePower_ij=(DAE.n + DAE.m + 2*Bus.n+2*Line.n+1):1:(DAE.n + DAE.m + 2*Bus.n+3*Line.n);%��·�޹�
            VoltageAngles=(DAE.n+1):(DAE.n+Bus.n);%�ڵ��ѹ��ֵ
            VoltageMagnitudes=(DAE.n+Bus.n+1):(DAE.n+2*Bus.n);%�ڵ��ѹ���
            %=========================================================================%
            
            %���������˳��Ϊ���������ת�ӽǡ������ת�١���������й�ע�롢��������޹�ע�롢��·�й�����·�޹���ĸ�ߵ�ѹ��ĸ����ǡ��ڵ��й����ɡ��ڵ��޹�����
            %ָ����ʱ��Ӧ����������
            Varname.fixed=0;
            % Varname.idx=[StateVariable(indexOmega)-1,StateVariable(indexOmega),ActivePowerInjection(indexGen),ReActivePowerInjection(indexGen),ActivePower_ij,ReActivePower_ij,VoltageMagnitudes,VoltageAngles,ActivePowerInjection(indexLoad),ReActivePowerInjection(indexLoad)]';
            Varname.idx=[StateVariable(Syn.delta),VoltageMagnitudes,VoltageAngles]';
            
            %%
            runpsat('td');%��̬���㿪ʼ
            
            % for jjudge=1:length(Varout.t)
            % if Varout.t(jjudge)>=CT
            % % record=Varout.vars(jjudge,:);
            % break;
            % end
            % end
            
            
            
            %�ж������Ƿ��ȶ�
            theta_final=Varout.vars(end,1:10);%��������ǵ���ֵ
            % for ijudge=1:9
            % deltatheta(ijudge)=theta_final(ijudge+1)-theta_final(1);
            % end
            deltatheta = [];
            for i = 1:10
                for j = 1:10
                    deltatheta(end+1)=theta_final(i)-theta_final(j);
                end
            end
            % if Varout.t(end)>3.8
            %       if sum(abs(deltatheta)>6.28)>0
            %           ifstable=-1;
            %       else
            %           ifstable=1;
            %       end
            % %      dlmwrite('Test.txt',[Varout.t(jjudge) Varout.vars(jjudge,:) ifstable ],'delimiter',' ','newline','pc','-append');
            %      dlmwrite('Test_CT11_CT14_ieee2psat_Faultinfo_0331.txt',[faulttype Varout.t(jjudge) Varout.vars(jjudge,:) ifstable ],'delimiter',' ','-append');
            %      dlmwrite('Test_CT11_CT14_ieee2psat_theta_Faultinfo_0331.txt',[faulttype Varout.t(jjudge) theta_final],'delimiter',' ','-append');
            % elseif sum(abs(deltatheta)>6.28)>0 && Varout.t(end)>Varout.t(jjudge)
            %     ifstable=-1;
            %     dlmwrite('Test_CT11_CT14_ieee2psat_Faultinfo_0331.txt',[faulttype Varout.t(jjudge) Varout.vars(jjudge,:) ifstable ],'delimiter',' ','-append');
            %     dlmwrite('Test_CT11_CT14_ieee2psat_theta_Faultinfo_0331.txt',[faulttype Varout.t(jjudge) theta_final],'delimiter',' ','-append');
            % end
            
            if Varout.t(end)>3.8
                if sum(abs(deltatheta)>6.28)>0
                    ifstable=-1;
                    disp([num2str(idx),' unstable'])
                    dlmwrite(strcat('./data_unstable/',num2str(CT),'_',num2str(i2),'_',num2str(i3)),[Varout.vars],'delimiter',',');
                else
                    ifstable=1;
                    disp([num2str(idx),' stable'])
                    dlmwrite(strcat('./data_stable/',num2str(CT),'_',num2str(i2),'_',num2str(i3)),[Varout.vars],'delimiter',',');
                end
            end
            idx = idx + 1;
        end
    end
end
%%

