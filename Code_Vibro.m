clc; 
close all; 
clear;


url = 'http://vibrolco.dyndns.org/pub/getrealtimetjvalues.asp';
datastring = urlread(url);

 % Dossier de déplacement fichiers SONO
    % Les variables
    Requete = 'HTTP';
    Name_ouvrage = 'LCO';
    donnee = 'Données_30s';
    Vibrometre = 'Vibro1'
    Id = strcat(Name_ouvrage,'_',Vibrometre); 
    DIR_Output_TOA5 = '\\192.168.0.202\DonneesExternes\CodesMatlab_Vibro\FichierMesures\';
    FILE_Name_Output_TXT = strcat(Requete, '_',Name_ouvrage,'_',donnee,'.txt');
    FILE_Name_Output_TOA5 = strcat(Requete, '_',Name_ouvrage,'_',Vibrometre,'.dat');
   
   % Est ce que le fichier existe??
   FILE_Output_exist =[];
   file_name_full = fullfile(DIR_Output_TOA5, FILE_Name_Output_TXT);
    FILE_liste_VDV = dir (file_name_full);
    if isempty(FILE_liste_VDV)
    disp('Le fichier TXT est inexistant')
    FILE_Output_exist = 0;
    elseif length(FILE_liste_VDV) == 1
    disp('   Le fichier TXT existe')
    FILE_Output_exist = 1;
    end

    % Dossier de déplacement fichiers SONO
    if exist(DIR_Output_TOA5, 'dir') == 7
    else
        disp(['Création dossier:', DIR_Output_TOA5 ])
        status = mkdir(DIR_Output_TOA5);
    end 
    
    
%% Exploiter les données de la requete HTTP
Format_Date_TOA5_Out_string = 'yyyy-mm-dd HH:MM:SS';

data_x_ind = strfind(datastring,'PPVjx');
data_xs = datastring(data_x_ind(1)+11:data_x_ind(2)-3);

data_y_ind = strfind(datastring,'PPVjy');
data_ys = datastring(data_y_ind(1)+11:data_y_ind(2)-3);

data_z_ind = strfind(datastring,'PPVjz');
data_zs = datastring(data_z_ind(1)+11:data_z_ind(2)-3);

data_date_ind = strfind(datastring,'TjLocalTime');
data_date = datastring(data_date_ind(1)+12:data_date_ind(2)-3);
 

data_date(find(data_date == 'T')) = ' ';
data_date = strcat(data_date, ';');
DATA = [data_date data_xs data_ys data_zs];
Data_Vibro = textscan(DATA,'%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ','Delimiter',';');

time_requete = Data_Vibro{:,1};

Data_Vibro(:,17) = [];
Data_Vibro(:,16) = [];
Data_Vibro(:,15) = [];
Data_Vibro(:,11) = [];
Data_Vibro(:,10) = [];
Data_Vibro(:,6) = [];
Data_Vibro(:,5) = [];

Data_tab = zeros(1, 10);
for i = 2 : 10
Data_tab(1,i) = cell2mat(Data_Vibro(1,i));
end
%% Ecrire les données dans un fichier TXT

size = size((Data_Vibro));
NB_line = size(1);
NB_Champ = size(2);


if FILE_Output_exist == 1
    fid = fopen(file_name_full, 'a');
elseif FILE_Output_exist == 0
    fid = fopen(file_name_full, 'w');
end

for i_time = 1 : NB_line
% Le TIMESTAMP
fprintf(fid,'"')
fprintf(fid,'%s', datestr(Data_Vibro{i_time, 1}, Format_Date_TOA5_Out_string));
fprintf(fid,'",'); 


    for i_calcul = 2 : NB_Champ
        fprintf(fid, '%s ', num2str(Data_tab(i_time,i_calcul)));

         if i_calcul < NB_Champ
            fprintf(fid,',');
        else
         end
    end
    fprintf(fid, '\r\n');
end

%%
        % Script 2 
            % Mettre 
            DataSet_10min = 20;
            fid = fopen(file_name_full);
            out = textscan(fid, '%s %f %f %f %f %f %f %f %f %f','Delimiter',',');
            n = length(out{1});        
            r = mod(n,20);
            m = (n-r)*(1/20);
            Max_PPV_X = zeros(n,1);
            Max_PPV_Y = zeros(n,1);
            Max_PPV_Z = zeros(n,1);
%             +DataSet_10min*(m-1)
%             if r == 0  
%                 PPV_X = [];
%                 PPV_Y = [];    
%      Data_OT = zeros(DataSet_10min, 10);
    di_line = 0;
%     Data_OT = [];
                for i_line = 1 + DataSet_10min *(m-1): DataSet_10min : 20*m 
%                     
                    A = out{4}(i_line:i_line+DataSet_10min-1)| out{7}(i_line:i_line+DataSet_10min-1)| out{10}(i_line:i_line+DataSet_10min-1);
                    
                     for i=1:20
                               if A(i) == 1

                                 di_line = di_line +1;
                                 disp('Dépassement enregistré');
                                     for j = 1 : 10       
                                         Data_OT{di_line,j} = out{j}(20*(m-1)+i) ;  
                                     end
                                    else
                                end

                      end
                            Max_PPV_X = max(out{2}(i_line:i_line+DataSet_10min-1));                         
                            Max_PPV_Y = max(out{5}(i_line:i_line+DataSet_10min-1));
                            Max_PPV_Z = max(out{8}(i_line:i_line+DataSet_10min-1));
                            
                            Time_data = out{1}(20*(m));
                            disp(['la date de mesure est le ', datestr(out{1}(20*(m)))]);
                            
                            % indice des valeurs Max en (X, Y, Z)
                            [Indmax_X] = find ( out{2}(i_line:i_line+DataSet_10min-1) == Max_PPV_X);
                            disp(['Le MAX en X est :',' ',num2str(Max_PPV_X),' ', ' indice ', num2str(Indmax_X)]);
                            Data_X = [ out{2}(20*(m-1)+Indmax_X) out{3}(20*(m-1)+Indmax_X) out{4}(20*(m-1)+Indmax_X)];
                            
                            [Indmax_Y] = find (out{5}(i_line:i_line+DataSet_10min-1)== Max_PPV_Y);
                            disp(['Le MAX en Y est : ', ' ', num2str(Max_PPV_Y), ' indice ', num2str(Indmax_Y)]);
                            Data_Y = [out{5}(20*(m-1)+Indmax_Y) out{6}(20*(m-1)+Indmax_Y) out{7}(20*(m-1)+Indmax_Y)];
                            
                            [Indmax_Z] = find (out{8}(i_line:i_line+DataSet_10min-1)== Max_PPV_Z);
                            disp(['Le MAX en Z est :', ' ', num2str(Max_PPV_Z), ' indice ', num2str(Indmax_Z)])
                            Data_Z = [out{8}(20*(m-1)+Indmax_Z) out{9}(20*(m-1)+Indmax_Z) out{10}(20*(m-1)+Indmax_Z)];
                            
                            Data_Export = {Time_data Data_X(1) Data_X(2) Data_X(3) Data_Y(1) Data_X(2) Data_Y(3) Data_Z(1) Data_Z(2) Data_Z(3)} ;
                       
                              Data_Export = [Data_Export; Data_OT];                         
                end
%                    Data_Export = {Data_X(1) Data_X(2) Data_X(3) Data_Y(1) Data_X(2) Data_Y(3) Data_Z(1) Data_Z(2) Data_Z(3)}    
                            

fclose(fid);
%%
      
    %Export Data in file
    Process_Vibro_Fmax_ExportTOA5_2019();
   % disp('Fonction Export .... ok !')
   
   
   