pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--main
function _init()
	startgame()
	
	mode="splash"
	blinkt=1
	sf=0
end


--draw
function _draw()
	if mode=="game" then
		drawgame()
	elseif mode=="start" then
		drawstart()
	elseif mode=="over" then
		drawover()
	elseif mode=="splash" then
		drawsplash()
	end
end


--update
function _update()
 blinkt+=0.7
	if mode=="game" then
		updategame()
	elseif mode=="start" then
		updatestart()
	elseif mode=="over" then
		updateover()
	elseif mode=="splash" then
		updatesplash()
	end
end

--state func
function startgame()
	s={}
	s.y=100
	s.x=60
	s.spdx=0
	s.spdy=0
	s.spr=1
	s.h=8
	s.w=8
	s.scd=0
	
	bo={}
	
	ene={}
	
	ptc={}
	lptc={}
	
	ff=5
	mz=0
	
	score=0
	hp=3
	invul=0
	
	star={}
	for i=1,80 do
		star[i] = {
		x=flr(rnd(128)),
		y=flr(rnd(128)),
		spd=0.5+rnd(1.5)
		}
	end
	
	spawnen()
end
-->8
--etc function
function starfield()
	for i=1,#star do
		local s=star[i]
		if s.spd>1.5 then
			pset(s.x,s.y,7)
		elseif s.spd>1 then
			pset(s.x,s.y,13)
		else
			pset(s.x,s.y,1)
		end
	end
end

function animstar()
	for i=1,#star do
	local s=star[i]
	s.y+=s.spd
	if s.y>128 then s.y=0 end
	end
end

function blink()
	local banim ={5,6,7,6,5}
	if flr(blinkt)>5 then
		blinkt=1
	end
	return banim[flr(blinkt)]
end

function drawspr(o)
	spr(o.spr,o.x,o.y)
end

function col(a,b)
	local al=a.x
	local ar=a.x+7
	local at=a.y
	local ab=a.y+7
	
	local bl=b.x
	local br=b.x+7
	local bt=b.y
	local bb=b.y+7
	
	if at>bb then return false end
	if bt>ab then return false end
	if ar<bl then return false end
	if br<al then return false end
	
	return true
end

function spawnen()
	local myen={}
	myen.x=16+rnd(93)
	myen.y=-8
	myen.spr=12
	myen.f=0
	myen.hp=5
	myen.fl=0
	
	add(ene,myen)
end

function explode(x,y)
	for i=0,1,0.5 do
		local l={}
		l.sx=cos(i)*6
		l.x=x
		l.y=y
		l.t=20
		add(lptc,l)
	end

	local pa={}
	pa.x=x+4
	pa.y=y+4
	pa.sx=0
	pa.sy=0
	pa.t=0
	pa.mt=-1
	pa.s=10
	add(ptc,pa)
	
	for i=1,30 do
		local pa={}
		pa.x=x+4
		pa.y=y+4
		pa.sx=-2+rnd(4)
		pa.sy=-2+rnd(4)
		pa.t=0-rnd(2)
		pa.mt=5+rnd(8)
		pa.s=4+rnd(3)
		add(ptc,pa)
	end
end
-->8
--more update
function updategame()
	--control
	s.x+=s.spdx
	s.y+=s.spdy

	s.spr=1
	s.spdx=0
	if btn(1) then
		s.spdx=2
		s.spr=3
	end
	if btn(0) then
		s.spdx=-2
		s.spr=2
	end
	
	s.spdy=0
	if btn(2) then s.spdy=-2 end
	if btn(3) then s.spdy=2 end
	
	--check edge
	if s.x>128 then s.x=-8 end
	if s.x<-8 then s.x=128 end
	if s.y>120 then s.y=120 end
	if s.y<0 then s.y=0 end
	
	--shoot
	s.scd-=1
	if btn(5) and s.scd<=0 then
	 s.scd=4
	 local mybu={}
	 mybu.x=s.x
	 mybu.y=s.y
	 add(bo,mybu)
	 sfx(0)
	 mz=6
	end
	
	--go backward instead
	for i=#bo,1,-1 do
		bo[i].y-=6
		if bo[i].y<-8 then
			del(bo,bo[i])
		end
	end
	
	--move enemies
	for en in all(ene) do
	 en.y+=1
	 if en.y>128 then
	 	del(ene,en)
	 	spawnen()
	 end
	end
	
	--bullet x ene
	for en in all(ene) do
		for bu in all(bo) do
		 if col(en,bu) then
		 	del(bo,bu)
		 	en.hp-=1
		 	sfx(3)
		 	en.fl=2
		 	if en.hp<=0 then
			 	score+=50
		  	explode(en.x,en.y)
			 	sfx(2)
		  	spawnen()
		 		del(ene,en)
		  end
		 end
		end
	end
	
	--col s x ene
	invul-=1
	if invul<=0 then
		for en in all(ene) do
			if col(en,s) then
				hp-=1
				sfx(1)
				invul=30
			end
		end
	end
	
	--over
	if hp<=0 then
	 mode="over"
	 return
	end
	
	--anim flame&muzzle
	ff+=1
	mz-=1
end

function updatestart()
	if btnp(4) or btnp(5) then
		mode="game"
	end
end

function updateover()
	if btnp(4) or btnp(5) then
		mode="start"
		startgame()
	end
end

function updatesplash()
	if btn(4) or btn(5) then
		mode="start"
		startgame()
	end
end
-->8
--more draw
function drawgame()
	cls(0)
	starfield()
	animstar()
	if invul<=0 then
		spr(s.spr,s.x,s.y)
		spr(5+ff%3,s.x,s.y+8)
	else
		if invul%4<=1 then
			spr(s.spr,s.x,s.y)
			spr(5+ff%3,s.x,s.y+8)
		end
	end
	
	--draw bul
	for i=1,#bo do
		local bul = bo[i]
		spr(16,bul.x,bul.y)
	end
	
	--muzzle
	if mz>0 then
		circfill(s.x+4,s.y-3,mz,7)
	 circfill(s.x+3,s.y-3,mz,7)
	end
	
	--particle
	for l in all(lptc) do
		line(l.x,l.y,l.x+(l.t/45)*6,l.y,7)
		l.x+=l.sx
		l.sx*=0.8
		l.t-=1
		if (l.t<0) del(lptc,l)
	end
	
	for p in all(ptc) do
		local pc=7
	
		if (p.t>2) pc=10
		if (p.t>3) pc=9
		if (p.t>4) pc=8
		if (p.t>6) pc=2
		if (p.t>8) pc=5
		if (p.t>12) pc=1
	
		circfill(p.x,p.y,p.s,pc)
		p.x+=p.sx
		p.y+=p.sy
		p.t+=1
		p.sx*=0.9
		p.sy*=0.9
		
		if p.t>p.mt then
			p.s-=0.5
			if (p.s<0) del(ptc,p)
		end
	end
	
	--draw ene
	for i=#ene,1,-1 do
		local en=ene[i]
		en.f+=0.125
		if en.fl>0 then
			en.fl-=1
			for i=1,15 do
				pal(i,7)
			end
		end
		spr(en.spr+flr(en.f)%2,en.x,en.y)
		pal()
	end
	
	--ui
	print("score: "..score,42,1,12)
	
	for i=1,3 do
		if hp>=i then
		 spr(9,(i-1)*9,0)
		else
			spr(10,(i-1)*9,0)
		end
	end
end

function drawstart()
	cls(1)
	print("★greatest shmup★",28,40,12)
	print("press 🅾️/❎ to start",24,80,blink())
end

function drawover()
	cls(8)
	print("☉gameover☉",40,40,7)
	print("press 🅾️/❎ to continue",20,80,7)
end

function drawsplash()
	cls()
	spr(32,56,56,2,2)
	print("triz",56,56)
	
	local sc={1,1,2,2,2,8,2,2,2,1,1}
	for x=0,127 do
		for y=0,127 do
			if pget(x,y)!=0 then
				pset(x,y,sc[flr(sf)])
			end
		end
	end
	if flr(sf)==6 then
		sf+=0.025
	else
	 sf+=1
	end
	
	if sf>#sc then mode="start" end
end
__gfx__
00000000000220000002200000022000000000000000000000000000000000000000000000000000000000000000000003300330033003300000000000000000
0000000000288200002882000028820000000000007777000007700000077000000000000880088008800880000000003b3333b33b3333b30000000000000000
007007000028820000288200002882000000000000c77c000007700000077000000000008ee88ee88008800800000000bbbbbbbbbbb33bbb0000000000000000
0007700002e88e2000288e2002e8820000000000000cc000000cc00000077000000000008e888e888000000800000000bb7117bbbbbbbbbb0000000000000000
000770002e87c8e2027c88200288c7200000000000000000000cc000000cc000000000008888888880000008000000003b7117b33b7117b30000000000000000
00700700288cc88202cc88200288cc20000000000000000000000000000cc0000000000008888880080000800000000003b77b30037117300000000000000000
0000000002811820021182200228112000000000000cc00000000000000000000000000000888800008008000000000000b00b0000b77b000000000000000000
00000000002a9200002a92000029a200000000000000000000000000000000000000000000088000000880000000000000300300030000300000000000000000
009aa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa7777aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa7777aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009aa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888808808888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088088880880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000005550000000000000155110000000000000000000000000000000000000000000000000000000
00070000000000000070000000000000000008889988000000555558998510000015555555551000000000000000000000000000000000000000000000000000
00077000000000000077009aa9000000000089999998800005555999999555500155585582855510000001000001000000000000000000000000000000000000
000077977a00700000079aaaaaa9070000089aaaaaa988000555999aaa9988500555888582558850000055000000510000000000000000000000000000000000
0000077777a700000009aaaaaaaa70000089aaaaaaa99800555999a7aa9988501558885599158850000555000055051000000000000000000000000000000000
00009777777a0000000aaaa777aa90000889aaaaaaaa990055899aa77aa998001555552299155550001550000015055000000000000000000000000000000000
0000a77777779000009aaa77777aa800089aaaa777aa99800889aaaa7aaa98800525599995198850005500051015510000000000000000000000000000000000
0000a7777777a000009aa777777aa90008aaaa7777aa9980088aaaa777a999800588999991599880015001550510000000000000000000000000000000000000
0000a77777779000009aa777777aa900089aaa7777aa99000889aaa777aa99900888999999558580000005550150000000000000000000000000000000000000
00009777777790000089aa77777a9900008aaaa77aaa990001889aaaaaa999900122288999158550005000000051010000000000000000000000000000000000
000077a7777a00000009aaa777a998000009aaaaaaaa900011889999aaa999801188551829855550000000500015051000000000000000000000000000000000
000770aaaa97000000089aaaaa99900000009aaaa999000055588999a99995805558185122855580000005100005550000000000000000000000000000000000
00700000900070000000899999990000000009999990000005558899999955000555555581555500000000510005500000000000000000000000000000000000
00000000000000000070008998000700000000089900000000511888995555100051185885555110000000150155100000000000000000000000000000000000
00000000000000000700000000000000000000000000000000001000555551100000100055555110000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000155100000000000015510000000000000000000000000000000000000000000000000000
__sfx__
000200002706020060110600906005050000000e0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000034630376503b67037670316702c66027650236401f6401a6301762014620116100e6100c6100960017f0014f0017f001bf0016f0022f001df0013700147001e700237000000000000000000000000000
000100003113014660396702b670196401667014650116400d6400b64009640076300462003620026100161000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100000c62035630225000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
