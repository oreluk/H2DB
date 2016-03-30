function strOut = viewH2Data(strIn)
%  outputXMLstring = viewCoalData(inputXMLstring)
% Modified: 2015.08.25 Jim Oreluk
% diagnoizing issues with PWA and application

NET.addAssembly('System.Xml');
import System.Xml.*;

try
    % Initialize Component
    docIn = System.Xml.XmlDocument;
    docIn.LoadXml(strIn);
    currDir = pwd;
    outputNode = docIn.GetElementsByTagName('outputDir');
    outputDir = char(outputNode.Item(0).GetAttribute('value'));
    cd(outputDir);
    
    %% Component Code
    if exist(fullfile(outputDir, 'h2Table.mat')) == 2
        fig = H2DB(outputDir);
    else
        updateDatabase([], [], outputDir) % handle and data empty
        fig = H2DB(outputDir);
    end
    
    drawnow;
    waitfor(fig);
    close all % plotFig
    
    statusValue = '1';
    errorMessage = '';
catch ME
    statusValue = '0';
    errorMessage = getReport(ME);
end
createOutputString()
    function createOutputString()
        % create the output xml file
        docOut = System.Xml.XmlDocument;
        docOut.AppendChild(docOut.CreateElement('outputData'));
        addNewNode('status',statusValue);
        addNewNode('errorMessage',errorMessage);
        addNewNode('nodeCaption','');
        
        function addNewNode(nodeName,nodeValue)
            % add a new node, nodeName, to the XML document
            newNode = docOut.CreateElement(nodeName);
            newNode.AppendChild(docOut.CreateTextNode(nodeValue));
            docOut.DocumentElement.AppendChild(newNode);
        end
        strOut = char(docOut.OuterXml);
    end
end