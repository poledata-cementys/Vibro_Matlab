
NB_output_file = 1;
file_name_full = fullfile(DIR_Output_TOA5, NAME_Output_Fichier);

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
EXPORT_Name_Colonne = DATA_fieldnames;
NB_variables_Export = length(EXPORT_Name_Colonne);  
disp(['il y a ', num2str(NB_variables_Export), ' variables'])
Table_Header_Output = '';
for i_col = 1:NB_variables_Export
    Table_Header_Output = [Table_Header_Output ,'"',EXPORT_Name_Colonne{i_col},'"'];
    if i_col < NB_variables_Export
        Table_Header_Output = [Table_Header_Output ,','];
    else
    end
    
end

%% Ecriture Fichier 1
% Ecriture du header
if FILE_Output_exist == 1
    fid = fopen(file_name_full, 'a');
elseif FILE_Output_exist == 0
    fid = fopen(file_name_full, 'w');
    
    VAR_Ligne_num_1 = strcat('"TOA5","FonctionVibrometre","Input:', NAME_Input_Fichier,'","Output',NAME_Output_Fichier,'"');
    
    fprintf(fid,VAR_Ligne_num_1);
    fprintf(fid, '\r\n');
    fprintf(fid,Table_Header_Output);
    fprintf(fid, '\r\n');

    fprintf(fid, '"TS","RN",');
    for j = 1:NB_variables_Export-2
        fprintf(fid, '""');
        if j < NB_variables_Export-2
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
NB_line_To_Write = length(Data_Vibro);

for i_line = 1: NB_line_To_Write
    fprintf(fid,'"');
    fprintf(fid,'%s', datestr(Data_Vibro{i_line}, Format_Date_TOA5_Out_string));
    fprintf(fid,'",');

    for i_calcul = 1 : NB_variables_Export-1
        Var_Temp_out = [];
        if Data_Vibro(i_line,i_calcul) == VAR_erreur || isnan(Data_Vibro(i_line,i_calcul))
%             fprintf(fid,'"NAN"');
            Var_Temp_out = [Var_Temp_out '"NAN"'];
        else
            fprintf(fid,num2str(Data_Vibro(i_line,i_calcul)));
            Var_Temp_out = [Var_Temp_out num2str(Data_Vibro(i_line,i_calcul))];
%         end
        
        fprintf(fid,Var_Temp_out);
        
        if i_calcul < NB_variables_Export-1
            fprintf(fid,',');
        else
        end
    end
    

    fprintf(fid, '\r\n');
    disp([num2str(i_line), '/', num2str(NB_line_To_Write), ' - ', char(Data_Vibro{i_line})])
end
fclose(fid);

