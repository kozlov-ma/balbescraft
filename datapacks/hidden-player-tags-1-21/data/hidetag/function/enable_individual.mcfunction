# Usage: /function hidetag:enable_individual @p

# Add the player to a team with visible nametags
team add visibleTags
team modify visibleTags nametagVisibility always
team join visibleTags @s

# Set the player's individual tag visibility to 1 (visible)
scoreboard players set @s individualTag 1
tellraw @p [{"text":"Player now has an visible name","color":"dark_green"}]