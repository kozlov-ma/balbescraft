# hidetag:change

execute as @p[scores={sovereignTag=1, sovereignValue=0}] run scoreboard players set @s sovereignValue 1
execute as @p[scores={sovereignTag=1, sovereignValue=1}] run scoreboard players set @s sovereignValue 0
execute as @p[scores={sovereignTag=1, sovereignValue=2}] run scoreboard players set @s sovereignValue 1
execute as @p[scores={sovereignTag=1, sovereignValue=1}] run tellraw @s [{"text":"Nametag visibility disabled","color":"aqua"}]
execute as @p[scores={sovereignTag=1, sovereignValue=0}] run tellraw @s [{"text":"Nametag visibility enabled","color":"dark_aqua"}]