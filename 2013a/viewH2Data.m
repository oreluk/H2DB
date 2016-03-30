function strOut = viewH2Data(strIn)
%  outputXMLstring = viewCoalData(inputXMLstring)

NET.addAssembly('System.Xml');
import System.Xml.*;

try
    comp = Component(strIn);
    if exist(fullfile(comp.OutputDirectory, 'h2Table.mat')) == 2
         fig = H2DB(comp);
    else
       updateDatabase([], [], comp) % handle and data empty
        fig = H2DB(comp);
    end
    drawnow;
    waitfor(fig);
    close all % plotFig
    comp.status = '1';
catch ME
    comp = Component();
    comp.status = '0';
    comp.errorMessage = getReport(ME);
end
strOut = comp.OutputString;
end
