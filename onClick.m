function onClick(h, d, data)
NET.addAssembly('System.Xml');
if size(d.Indices,1) == 1
    if all(d.Indices(2) ~= [1, 4, 5, 6, 7])
        ReactionLab.Util.gate2primeData('show',{'primeId',data.click{d.Indices(1),d.Indices(2)}});
    end
end
