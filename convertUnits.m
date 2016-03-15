function y = convertUnits(inputValue, inputType)
% Unit Conversion
%
% Jim Oreluk 2015.03.15
%
%  Purpose: Convert temperature and pressure from inputType into an output 
%  where temperature is in Kelvin and pressure is in atm.
%  

switch inputType
    case 'Pa'
        y = inputValue * (9.8692e-6);
        
    case 'bar'
        y = inputValue * 0.98692;
        
    case 'Torr'
        y = inputValue * (1.315789E-3);
        
    case 'atm' 
        y = inputValue;
        
    case 'ºF'
        y = (inputValue + 459.67) * (5/9);
        
    case 'ºC'
        y = inputValue + 273.15;
        
    case 'K'
        y = inputValue;
        
    otherwise
        warning('convertUnits: inputType was not found. Unit conversion was not completed.')
        y = inputValue;    
end


        