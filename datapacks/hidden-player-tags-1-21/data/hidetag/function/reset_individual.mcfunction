# Usage: /function hidetag:reset_individual @p

execute if entity @s[team=hiddenTags] run team leave @s
execute if entity @s[team=visibleTags] run team leave @s
execute if entity @s[team=no_display_tag_running] run team leave @s
execute if entity @s[team=no_display_tag] run team leave @s

scoreboard players set @s individualTag 0

tellraw @p [{"text":"Player returned to server default","color":"blue"}]