# hidetag:start

team add no_display_tag
team modify no_display_tag nametagVisibility never

scoreboard players set no_display_tag_running teamInit 1

tellraw @p [{"text":"Playertags are now invisible","color":"green"}]