% Returns tissue data and tissue name vector from a specified tissue file

function [data, tissueNames]=importTissueFile(tissueFilePath)

file=importdata(tissueFilePath);



% Remove numbers from name column and putting it in tissue index column
for i=1:size(file.textdata,1)
    temp1=sscanf(file.textdata{i},'%*s %d', [1,inf]);
    if isempty(temp1)~=1
        file.textdata(i)=strrep(file.textdata(i),num2str(temp1),'');
        temp2=file.data(i,1);
        strTemp=strcat(int2str(temp1),int2str(temp2));
        file.data(i,1)=str2double(strTemp);
    end
end

% Remove . and spaces
for i=1:size(file.textdata,1)
    file.textdata(i)=strrep(file.textdata(i),' ','');
    file.textdata(i)=strrep(file.textdata(i),'.','');
end

data=file.data;
tissueNames=file.textdata;

end