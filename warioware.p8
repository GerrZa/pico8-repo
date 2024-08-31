pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
function _init()
	mode="s"
	suc=false
	deft=140
	t=0
	sb=0
	updateg=
	
	slotg={
		t=0
		r=0.2
	}
end


function _update()
	if mode=="s" then
		updates()
	elseif mode=="game"
		updateg()
	end
end


function _draw()
	if mode=="s" then
		draws()
	end
end
-->8
--update
function updates()
	sb+=0.0925
	if btnp(4) or btnp(5) then mode="w" end
end

function dug()
	t-=1
end

function uslot()
	
end
-->8
--draw

function draws()
	cls(1)
	print("press 🅾️/❎ to start",24,64,1+flr(sb%2)*11)
end

function draww()
	cls()
	
end
-->8
--etc

function sgame()
	t=deft
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
