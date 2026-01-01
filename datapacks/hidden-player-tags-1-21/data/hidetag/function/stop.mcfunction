# hidetag:stop

team modify no_display_tag nametagVisibility always
team remove no_display_tag

scoreboard players set no_display_tag_running teamInit 0

tellraw @p [{"text":"Playertags are now visible","color":"dark_green"}]