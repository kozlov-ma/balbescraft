Make names invisible. This datapack hides player names. You can hide the nameplate of everyone or any individual player including yourself.


COMMANDS

Switch nametags on or off for everyone:
/function hidetag:start
/function hidetag:stop


You can do this for a single player:


To make the nametag of a player named "Steve" invisible:
/execute as Steve run function hidetag:disable_individual

To make the nametag of a player named "Alex" visible:
/execute as Alex run function hidetag:enable_individual

To reset "Notch" to the server default nametag visibility, you would use the following command:
/execute as Notch run function hidetag:reset_individual


if you want to do this for yourself you can just leave the "/execute as {your name} run " away.



by timisaurus




ps: This is a very simple Pack, don't pay money for it.