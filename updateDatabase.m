function updateDatabase(hh, dd, curDir)
%% Download List of Experimental Records

h = waitbar(0);
waitbar(0,h,sprintf('Searching PrIMe Warehouse for H2 Data'))
s = ReactionLab.Util.PrIMeData.ExperimentDepot.PrIMeExperiments;
[h2List, ~] = s.warehouseSearch({'initialComposition_component_primeID', 's00009809'});
close(h)

%% Create PrimeExperiment Object for Each Record
h = waitbar(0);
n = length(h2List);
h2Data = ReactionLab.Util.PrIMeData.ExperimentDepot.PrIMeExperiments.empty(0,n);
h = waitbar(0);
for i = 1:n
    if i == 1
        tic
    end
    h2Data(i) = ReactionLab.Util.PrIMeData.ExperimentDepot.PrIMeExperiments(h2List{i});
    if i == 10
        a = toc;
    end
    if i < 10
        waitbar(0,h,sprintf('Downloading experiments from PrIMe Warehouse \n 0%% complete'))
        
    else
        p = round(i/n,3);
        waitbar(p,h,sprintf('Downloading experiments from PrIMe Warehouse \n %.1f%% complete (%.1f sec)',p*100, (n-i)*a/10))
        
    end
end
close(h)

%% Preallocate Space

n = length(h2Data);
dGCount = 0;
for i = 1:n
    dG = h2Data(i).Doc.GetElementsByTagName('dataGroup');
    dGCount = dGCount + dG.Count;
end

bibPrimeID  = cell(1,dGCount);
bibPrefKey  = cell(1,dGCount);
initialO2   = cell(1,dGCount);
commonP = cell(1,dGCount);
commonTemp  = cell(1,dGCount);
dataPoints  = cell(1,dGCount);
gasMixture  = cell(1,dGCount);
expPrimeID = cell(1,dGCount);
dataGroupID = cell(1,dGCount);

%% Process Data
dGCount = 0;
h = waitbar(0);
for i = 1:n
    if i == 1
        tic
    end
    xmlDocument = h2Data(i).Doc;
    dG = xmlDocument.GetElementsByTagName('dataGroup');
    for dList = 1:dG.Count
        dGCount = dGCount + 1;
        dataGroupID{dGCount} = char(dG.Item(dList-1).GetAttribute('id'));
        if dList == 1
            bibNode = xmlDocument.GetElementsByTagName('bibliographyLink');
            % Using first listed bibliographyLink
            bibPrimeID{dGCount} = char(bibNode.Item(0).GetAttribute('primeID'));
            % Some exp pref Keys had misc information
            bibDOM = ReactionLab.Util.gate2primeData('getDOM',{'primeID', bibPrimeID{dGCount}});
            bibPrefKey{dGCount} = char(bibDOM.GetElementsByTagName('preferredKey').Item(0).InnerText);
            expPrimeID{dGCount} = h2Data(i).PrimeId;
            
            % Get O2 Volume Fraction from XML
            sLinks = xmlDocument.GetElementsByTagName('speciesLink');
            for sList = 1:sLinks.Count
                if sLinks.Item(sList-1).Attributes.Item(0).Value == 'O2'
                    if isempty(sLinks.Item(sList-1).NextSibling) % if there is no amount node
                        initialO2{dGCount} = '-';
                    else
                        o2String = char(sLinks.Item(sList-1).NextSibling.InnerText);
                        o2String = str2double(o2String) * 100;
                        initialO2{dGCount} = num2str(round( o2String, 3 ));
                    end
                end
            end
            
            % Get Common Temperature // Gas Mixture
            commonProp = xmlDocument.GetElementsByTagName('commonProperties');
            for cList = 1:commonProp.Count
                prop = commonProp.Item(cList-1).GetElementsByTagName('property');
                for pList = 1:prop.Count
                    switch char(prop.Item(pList-1).GetAttribute('name'))
                        
                        case 'temperature'
                            tUnits = char(prop.Item(pList-1).GetAttribute('units'));
                            tValue = str2double(char(prop.Item(pList-1).ChildNodes.Item(0).InnerXml));
                            tValue = convertUnits(tValue, tUnits);
                            commonTemp{dGCount} = round(tValue, 3);
                            
                            
                        case 'initial composition'
                            compNodes = prop.Item(pList-1).GetElementsByTagName('component');
                            for i1 = 1:double(compNodes.Count)
                                item = compNodes.Item(i1-1);
                                pKey = char(item.GetElementsByTagName('speciesLink').Item(0).GetAttribute('preferredKey'));
                                if str2double(char(item.InnerText)) ~= 0
                                    gasMixture{dGCount}{end+1} =  pKey;
                                end
                            end
                            
                        case 'pressure'
                            pUnits = char(prop.Item(pList-1).GetAttribute('units'));
                            pValue = str2double(char(prop.Item(pList-1).ChildNodes.Item(0).InnerXml));
                            pValue = convertUnits(pValue, pUnits);
                            commonP{dGCount} = round(pValue, 3);
                            
                    end
                end
            end
            if isempty(commonTemp{dGCount}) == 1
                commonTemp{dGCount} = '-';
            elseif isempty(gasMixture{dGCount}) == 1
                gasMixture{dGCount} = '-';
            elseif isempty(commonP{dGCount}) == 1
                commonP{dGCount} = '-';
            end
        else
            % Copy if Repeat
            bibPrimeID{dGCount} = bibPrimeID{dGCount-1};
            bibPrefKey{dGCount} = bibPrefKey{dGCount-1};
            initialO2{dGCount} = initialO2{dGCount-1};
            commonP{dGCount} = commonP{dGCount-1};
            commonTemp{dGCount} = commonTemp{dGCount-1};
            gasMixture{dGCount} = gasMixture{dGCount-1};
            expPrimeID{dGCount} = expPrimeID{dGCount-1};
        end
        
        
        % Pull Data Node Information
        prop = dG.Item(dList-1).GetElementsByTagName('property');
        for pList = 1:prop.Count
            propDescription = char(prop.Item(pList-1).GetAttribute('description'));
            propUnits = char(prop.Item(pList-1).GetAttribute('units'));
            propId = char(prop.Item(pList-1).GetAttribute('id'));
            if isempty(propDescription)
                propDescription = char(prop.Item(pList-1).GetAttribute('label'));
            end
            dataPoints{dGCount}{1,pList} = propDescription;
            dataPoints{dGCount}{2,pList} = propUnits;
            dataPoints{dGCount}{3,pList} = propId;
        end
        
        % Marker for HDF or XML Storage
        if strcmpi(char(dG.Item(dList-1).GetAttribute('dataPointForm')), 'HDF5')
            for j = 1:size(dataPoints{dGCount},2)
                dataPoints{dGCount}{4,j} = 'dataInHDF';
            end
        else
            for j = 1:size(dataPoints{dGCount},2)
                dataPoints{dGCount}{4,j} = 'dataInXML';
            end
        end
        if i == 10
            a = toc;
        end
    end
    if i < 10
        waitbar(0,h,sprintf('Processing Data \n 0%% complete'))
    else
        p = round(i/n,3);
        waitbar(p,h,sprintf('Processing Data \n %.1f%% complete (%.1f sec)',p*100, (n-i)*a/10))
    end
end
close(h)

%% Table Data

formattedGasMix = cell(1,dGCount);
propertyName = cell(1,dGCount);
% Create Strings for gas Mixture display & properties
for i = 1:length(gasMixture)
    sGasMix = sort(gasMixture{i});
    if  size(sGasMix,2) > 1
        formattedGasMix{i} = strjoin(sGasMix, ' / ');
    else
        formattedGasMix{i} = sGasMix;
    end
    propertyName{i} = strjoin(dataPoints{i}(1,1:end),', ');
end

checkBoxData = zeros(1,length(initialO2)); checkBoxData = num2cell(logical(checkBoxData));

tableData = [checkBoxData', bibPrefKey', propertyName', formattedGasMix', initialO2', commonTemp', commonP'];
onClickData =   [checkBoxData', bibPrimeID', expPrimeID', tableData(:,4), tableData(:,5), tableData(:,6), tableData(:,7), dataGroupID' ];

h2App.tableData = tableData;
h2App.onClickData = onClickData;
h2App.dataPoints = dataPoints;
h2App.gasMixture = gasMixture;

%%

save(fullfile(curDir, 'h2Table.mat'), 'h2App')

%% Restart Application
close(gcf)
H2DB;