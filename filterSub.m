function filtered = filterSub(varargin)
% Filtering Subroutine
%
% Jim Oreluk 2016.02.22
%
%  Purpose: Repeated task for filtering table information.

data = varargin{1};
expression = varargin{2};
searchTerm = varargin{3};

count = 0;
for i = 1:size(data.table,1)
    if eval(expression)
        count = count + 1;
        for j = 1:size(data.table,2)
            filtered.table{count,j} = data.table{i,j};
            filtered.dp{count} = data.dp{1,i};
            filtered.gas{count} = data.gas{1,i};
            filtered.click{count,j} = data.click{i,j};
            if j == size(data.table,2)
                filtered.click{count,j+1} = data.click{i,j+1};
                filtered.click{count,j+2} = data.click{i,j+2};
            end
        end
    end
end

% Return empty when filter critera does not find any matching data
if ~logical(exist('filtered'))
    filtered.table = {};
    filtered.click = {};
    filtered.dp = {};
    filtered.gas = {};
end

