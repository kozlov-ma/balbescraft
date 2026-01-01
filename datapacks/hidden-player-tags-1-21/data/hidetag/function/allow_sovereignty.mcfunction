# hidetag:allow_sovereignty

execute as @a[scores={sovereignTag=0}] run scoreboard players set @s sovereignTag 1
execute as @a[scores={sovereignTag=1}] run scoreboard players set @s sovereignTag 0
execute as @a[scores={sovereignTag=2}] run scoreboard players set @s sovereignTag 1
execute as @p[scores={sovereignTag=1}] run tellraw @s [{"text":"Freedom to change visibility of own playertag enabled","color":"aqua"}]
execute as @p[scores={sovereignTag=0}] run tellraw @s [{"text":"Freedom to change visibility of own playertag disabled","color":"dark_aqua"}]