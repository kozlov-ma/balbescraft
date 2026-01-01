### hidetag
### runs every tick

schedule function hidetag:on_tick 14t

execute if score no_display_tag_running teamInit matches 1 run execute as @a[team=] run team join no_display_tag @s

# Apply individual settings
execute as @a[scores={individualTag=1}] run team join visibleTags @s
execute as @a[scores={individualTag=2}] run team join hiddenTags @s