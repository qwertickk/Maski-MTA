local models = {
    [1950] = {path = "files/models/hockeymask.dff"},
    [1951] = {path = "files/models/hockeymask2.dff"},
    [1952] = {path = "files/models/hockeymask3.dff"},
}

for i,v in pairs(models) do
    local txd = engineLoadTXD("files/models/hockeymask.txd", true)
    engineImportTXD(txd, i)
    local dff = engineLoadDFF(v.path)
    engineReplaceModel(dff, i, true)
end