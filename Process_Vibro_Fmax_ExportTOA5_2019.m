NB_output_file = 1;
file_name_full = fullfile(DIR_Output_TOA5, FILE_Name_Output_TOA5);

%% Fichier 1
FILE_Output_exist =[];

% Est ce que le fichier existe??
FILE_liste_VDV = dir (file_name_full);
if isempty(FILE_liste_VDV)
    disp('Le fichier VDV est inexistant')
    FILE_Output_exist = 0;
elseif length(FILE_liste_VDV) == 1
    disp('   Le fichier VDV existe')
    FILE_Output_exist = 1;
end

% Construction header names

% Ajout Timestamp STR + Record
% ppv;df;type;date;kurt;over
Table_Header_Output = [];
Table_Header_Output = ['"TIMESTAMP"',',','"RECORD"',',','"' Id, '_', 'PPVX","' Id, '_', 'FrequenceX_Max","' Id, '_', 'type_X","' Id, '_', 'PPVY","' Id, '_', 'FrequenceY_Max","' Id, '_', 'type_Y","' Id, '_', 'PPVZ","' Id, '_', 'FrequenceZ_Max","' Id, '_', 'type_Z"', Table_Header_Output]
out = textscan(Table_Header_Output,'%s', 'delimiter', ',');
NB_variables_Export = length(out{1});
disp(['il y a ', num2str(NB_variables_Export), ' variables'])

%% Ecriture Fichier 1
% Ecriture du header
if FILE_Output_exist == 1
    fid = fopen(file_name_full, 'a');
elseif FILE_Output_exist == 0
    fid = fopen(file_name_full, 'w');
    fprintf(fid,strcat('"TOA5","Vibrometre","Cementys","xxxxx","xxxxx","xxxxx","xxxxx","Mesures"'));
    fprintf(fid, '\r\n');
    fprintf(fid,Table_Header_Output);
    fprintf(fid, '\r\n');

    fprintf(fid, '"TS","RN",');
    for j = 1:NB_variables_Export
        fprintf(fid, '""');
        if j < NB_variables_Export
            fprintf(fid, ',');
        else
        end
    end
    fprintf(fid, '\r\n');

    fprintf(fid, '"","",');
    for j = 1:NB_variables_Export-2
        fprintf(fid, '"Smp"');
        if j < NB_variables_Export-2
            fprintf(fid, ',');
        else
        end
    end
    fprintf(fid, '\r\n');
else
    disp('### Probleme de savoir si le fichier existe')
end


%% Ecriture des données du fichier
% La date de la rêquete 
% [NB_line,NB_champ]  = size(EXPORT_TS);

EXPORT_DATA_Vibro = Data_Export;
NB_line = length(EXPORT_DATA_Vibro(:,1));
NB_Champ = length(EXPORT_DATA_Vibro);

VAR_erreur = 99999;
%% Ecriture des données du fichier
for i_line = 1: NB_line
       
          % Le TIMESTAMP
          fprintf(fid,'"');
            fprintf(fid,'%s', datestr( EXPORT_DATA_Vibro{i_line,1}, Format_Date_TOA5_Out_string) );
          fprintf(fid,'",');    
          
          % Record
          fprintf(fid,num2str(i_line));fprintf(fid,',');
          
         
          % Les Data vibro Vitesses, Frequences, ...
     for  i_calcul = 2 : NB_Champ

       % Data_Vibro = Data_Vibro_Time(1,2:end) ; 
       % Mat = cell2mat(Data_Vibro)  ;
       
       fprintf(fid, num2str(EXPORT_DATA_Vibro{i_line, i_calcul}));
                 
       if i_calcul < NB_variables_Export-1
            fprintf(fid,',');
        else
        end
    end
    

    fprintf(fid, '\r\n');
    disp([num2str(i_line), '/', num2str(NB_line), ' - ', char(EXPORT_DATA_Vibro{i_line,1})])
end
fclose(fid);

