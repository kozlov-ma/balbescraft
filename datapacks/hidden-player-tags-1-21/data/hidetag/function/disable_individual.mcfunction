# Usage: /function hidetag:disable_individual @p

# Add the player to a team with hidden nametags
team add hiddenTags
team modify hiddenTags nametagVisibility never
team join hiddenTags @s

# Set the player's individual tag visibility to 2 (invisible)
scoreboard players set @s individualTag 2
tellraw @p [{"text":"Player now has an invisible name","color":"green"}]