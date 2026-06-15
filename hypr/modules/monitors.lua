hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = "1.25",
})



for i = 1,5, 1 do
    hl.workspace_rule({workspace= tostring(i) ,monitor= "eDP-1", persistent= true})

end

--
hl.monitor({
    output   = "DP-1",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
})
for i = 6, 10, 1 do
    hl.workspace_rule({workspace = tostring(i), monitor = "DP-1"})
end

