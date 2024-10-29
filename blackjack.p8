pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
gscene = {
	state="pc",
	stack=0,
	pcard={},
	ecard={},
	esel=1,
	etok={},
	ptok={},
	psel=1,
	ptsel=1,
	phold=0,
	partcd=5,
	camsh=0,
	php=5,
	ehp=5,
	cenpart={
		{x=64,y=64,r=20}
	},
	explode=
	function(s)
		for i=1,4+ceil(rnd(3)) do
		 local ne = {x=64,y=64,r=3+rnd(4),dir=rnd(1),s=4,l=10+ceil(rnd(5)),c=8}
		 ne.x+=cos(ne.dir)*4
		 ne.y+=sin(ne.dir)*8
			add(s.cenpart,ne)
		end
	end,
	
	addcard=
	function(s,ene)
		if ene then
	 	local nc={
		 	x=0,
		 	y=-24,
		 	ax=0,
		 	ay=-24,
		 	yoff=0,
		 	val=ceil(rnd(10))
		 }
	 	add(gscene.ecard,nc)
	 else
			local ncard={
				x=0,
				y=106,
				ax=128,
				ay=106,
				yoff=0,
				val=ceil(rnd(10)),
			}
			add(s.pcard,ncard)
		end
	end,
	
	addtok=
	function(s,ene)
		local tok={v=sgn(1-rnd(2))}
		if tok.v==1 then
			tok.s=39
		else
			tok.s=7
		end
		if ene then
		 add(s.etok,tok)
		else
			tok.x=120
			tok.y=110
			tok.ax=120
			tok.ay=110
			tok.xoff=0
		 add(s.ptok,tok)
		end
	end,
	
	draw=--🐱
	function(s)
		cls()
		if sub(s.state,1,1)=="p" then
			print("⬇️yourturn⬇️",41,92,11)
		elseif sub(s.state,1,1)=="e" then
			print("⬆️enemyturn⬆️",36,30,8)
		end
		//end of state
		
		--drawcard
		for i=1,#s.pcard do
			local pc=s.pcard[i]
			spr(1,pc.ax,pc.ay,3,4)
			if pc.val==1 then
				print("a",pc.ax+2,pc.ay+1,8)
			elseif pc.val==10 then
				print("k",pc.ax+2,pc.ay+1,8)
			else
				print(pc.val,pc.ax+2,pc.ay+1,8)
			end
		end
		
		--drawtok
		for i=1,#s.ptok do
			local pt=s.ptok[i]
			spr(pt.s,pt.ax,pt.ay,2,2)
		end
		
		for i=1,#s.ecard do
			local es=s.ecard[i]
			spr(4,es.ax,es.ay,3,4)
		end
		
		--circ part
		if #s.cenpart > 1 then
			for i=2,#s.cenpart do
				local cp=s.cenpart[i]
				if cp.l > 5 then
					fillp(█)
					circfill(cp.x,cp.y,cp.r,cp.c)
				else
					fillp(░)
					if cp.l < 3 then
						if cp.c==8 then
							cp.c=2
						elseif cp.c==7 then
							cp.c=13
						end
					end
					circfill(cp.x,cp.y,cp.r,cp.c)
				end
			end
		end
		
		fillp(█)
		local cen=s.cenpart[1]
		circfill(cen.x,cen.y,cen.r,7)
		
		local tc=0
		if (s.stack/21)>1 or (s.stack/21)<0 then
			tc=8
		elseif s.stack==21 then
			tc=11
		elseif (s.stack/21)>0.9 then
			tc=9
		elseif (s.stack/21)>0.7 then
			tc=2
		end
		
		if s.stack<0 then
			if s.stack<-9 then
				print(s.stack.."/21",52,62,tc)
			else
				print(s.stack.."/21",54,62,tc)
			end
		elseif s.stack>9 then
			print(s.stack.."/21",55,62,tc)
		else
			print(s.stack.."/21",57,62,tc)
		end
		
		cursor(0,0,1)
		print(" you :".."\*"..s.php.."♥",1,1)
		print("enemy:".."\*"..s.ehp.."♥",1,8)
		
		if s.camsh>0	then
			camera(-2+rnd(4),-2+rnd(4))
		else
			camera(0,0)
		end
		
		--print(s.ptok[s.ptsel].v,0,32,7)
		
	end,
	
	update=--★
	function(s)
		if s.state=="pc" then
			--select card
			if btnp(⬅️) and s.psel>1 then
				s.psel-=1
			elseif btnp(➡️) and s.psel<#s.pcard then
				s.psel+=1
			end
			
			for i=1,#s.pcard do
				if i==s.psel then
					s.pcard[i].yoff=-8
				else
					s.pcard[i].yoff=0
				end
			end
			
			for i=1,#s.ptok do
				s.ptok[i].xoff=0
			end
		
		if btnp(❎) then
			s.phold={s.pcard[s.psel],s.pcard[s.psel].val}
			s.state="pt"
		end
		
		---
		elseif s.state=="pt" then
			
			if btnp(⬇️) and s.ptsel>1 then
				s.ptsel-=1
			elseif btnp(⬆️) and s.ptsel<#s.ptok then
				s.ptsel+=1
			end
			
			for i=1,#s.ptok do
				if i==s.ptsel then
					s.ptok[i].xoff=10
				else
					s.ptok[i].xoff=0
				end
			end
			
			if btnp(❎) then
				s.camsh=5
				s:explode()
				s.state="pc"
				s.stack+=s.phold[2]*s.ptok[s.ptsel].v
				del(s.pcard,s.phold[1])
				del(s.ptok,s.ptok[s.ptsel])
				s.addcard(s,false)
				s.addtok(s,false)
				s.psel=1
				s.ptsel=1
			end
		---
		elseif s.state=="e" then
			for i=1,#s.pcard do
				s.pcard[i].yoff=0
			end
			
			for i=1,#s.ptok do
				s.ptok[i].xoff=0
			end
			
		end
		//end of state
		
		//card pos
		for i=1,#s.pcard do
			local pc=s.pcard[i]
			pc.x=2+(i*8)
			pc.ax+=(pc.x-pc.ax)*0.5
			pc.ay+=((pc.y+pc.yoff)-pc.ay)*0.5
		end
		
		for i=1,#s.ecard do
			local ec=s.ecard[i]
			ec.x=102-(i*4)
			ec.ax+=(ec.x-ec.ax)*0.5
			ec.ay+=((ec.y+ec.yoff)-ec.ay)*0.5
		end
		
		--tok pos
		for i=1,#s.ptok do
			local pt=s.ptok[i]
			pt.y=124-(10*i)
			pt.ax+=((pt.x-pt.xoff)-pt.ax)*0.5
			pt.ay+=(pt.y-pt.ay)*0.5
		end
		
		--circ part
		if s.partcd%5==0 then
			local ncirc={x=64,y=64,l=40+rnd(10),dir=rnd(1),s=0.5,r=6+rnd(4),c=7}
			add(s.cenpart,ncirc)
		end
		
		if #s.cenpart > 1 then
			for i=#s.cenpart,2,-1 do
				local cp = s.cenpart[i]
				cp.x+=cos(cp.dir)*cp.s
				cp.y+=sin(cp.dir)*cp.s
				cp.l-=1
				cp.s=cp.s*0.995
				if cp.l<=0 then
					del(s.cenpart,cp)
				end
			end
		end
		
		s.camsh-=1
		
	end

}

scene = {}
-->8
function _init()
	--init card
	for i=1,5 do
		gscene.addcard(gscene,false)
  gscene.addcard(gscene,true)
  gscene.addtok(gscene,false)
  gscene.addtok(gscene,true)
 end
 
	scene=gscene
end

function _update()
	scene:update()
end

function _draw()
	scene:draw()
end
__gfx__
00000000d7777777777777777777777dd7777777777777777777777d0000088ee880000000000000000000000000000000000000000000000000000000000000
000000007777777777777777777777777777777777777777777777770008888ee888200000000000000000000000000000000000000000000000000000000000
007007007777777dddddddddddddd77777e88888888ee88888888e770088888ee888880000000000000000000000000000000000000000000000000000000000
00077000777777d77777777777777d77778e888888e88e888888e8770ee8822222288ee000000000000000000000000000000000000000000000000000000000
00077000777777d77777777777777d777788e8888e8888e8888e88770eee28888882eee000000000000000000000000000000000000000000000000000000000
00700700777777d77777777777777d7777888e88e888888e88e8887728e2888888882e8800000000000000000000000000000000000000000000000000000000
00000000777777d77777777777777d77778888ee88888888ee888877888288888888288800000000000000000000000000000000000000000000000000000000
00000000777ddd777777777777777d77778888ee88888888ee888877888287777778288800000000000000000000000000000000000000000000000000000000
0000000077d777777777777777777d7777888e88e888888e88e88877888287777778288800000000000000000000000000000000000000000000000000000000
0000000077d777777777777777777d777788e8888e8888e8888e8877888288888888288800000000000000000000000000000000000000000000000000000000
0000000077d77777e888888e77777d77778e888888e88e888888e87728e2888888882e8800000000000000000000000000000000000000000000000000000000
0000000077d777788888888887777d7777e88888888ee88888888e770eee28888882eee000000000000000000000000000000000000000000000000000000000
0000000077d777888888888888777d7777e88888888ee88888888e770ee8822222288ee000000000000000000000000000000000000000000000000000000000
0000000077d77e888888888888e77d77778e888888e88e888888e8770088888ee888880000000000000000000000000000000000000000000000000000000000
0000000077d778888778877888877d777788e8888e8888e8888e88770002888ee888200000000000000000000000000000000000000000000000000000000000
0000000077d778888778877888877d7777888e88e888888e88e888770000028ee820000000000000000000000000000000000000000000000000000000000000
0000000077d778888778877888877d77778888ee88888888ee8888770000033bb330000000000000000000000000000000000000000000000000000000000000
0000000077d778888778877888877d77778888ee88888888ee8888770003333bb333500000000000000000000000000000000000000000000000000000000000
0000000077d778888888888888877d7777888e88e888888e88e888770033333bb333330000000000000000000000000000000000000000000000000000000000
0000000077d7788e77777777e8877d777788e8888e8888e8888e88770bb3355555533bb000000000000000000000000000000000000000000000000000000000
0000000077d77e887777777788e77d77778e888888e88e888888e8770bbb53333335bbb000000000000000000000000000000000000000000000000000000000
0000000077d777888777777888777d7777e88888888ee88888888e7753b5333773335b3300000000000000000000000000000000000000000000000000000000
0000000077d777788888888887777d7777e88888888ee88888888e77333533377333533300000000000000000000000000000000000000000000000000000000
0000000077d77777e888888e77777d77778e888888e88e888888e877333537777773533300000000000000000000000000000000000000000000000000000000
0000000077d777777777777777777d777788e8888e8888e8888e8877333537777773533300000000000000000000000000000000000000000000000000000000
0000000077d777777777777777777d7777888e88e888888e88e88877333533377333533300000000000000000000000000000000000000000000000000000000
0000000077d777777777777777777d77778888ee88888888ee88887753b5333773335b3300000000000000000000000000000000000000000000000000000000
0000000077d777777777777777777d77778888ee88888888ee8888770bbb53333335bbb000000000000000000000000000000000000000000000000000000000
0000000077d777777777777777777d7777888e88e888888e88e888770bb3355555533bb000000000000000000000000000000000000000000000000000000000
00000000777dddddddddddddddddd77777e8e8888e8888e8888e8e770033333bb333330000000000000000000000000000000000000000000000000000000000
000000007777777777777777777777777777777777777777777777770005333bb333500000000000000000000000000000000000000000000000000000000000
00000000d7777777777777777777777dd7777777777777777777777d0000053bb350000000000000000000000000000000000000000000000000000000000000
