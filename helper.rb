class Drum
	Radius=285.mm
	Inside_height=840.mm
	Lid_height=20.mm
	#Lid_
	#total height=Lid_height+Height+Lid_height
	
end
class Geom::Transformation
	def test
		puts 'test'
	end
	def to_s
		return self.to_a[0..3].join(" ,")+"\n"+
		self.to_a[4..7].join(" ,")+"\n"+
		self.to_a[8..11].join(" ,")+"\n"+
		self.to_a[12..15].join(" ,")
	end

end

def merge(grp_0,grp_1)
	#groups have to be exploded first	
	e=[grp_0.entities.to_a,grp_1.entities.to_a].flatten
	grp_0.explode
	grp_1.explode
	return Sketchup.active_model.entities.add_group(Sketchup.active_model.entities.select{|x| e.include? x})
end


def drum
	lid=[0,0,0],
	[0,0,Drum::Radius-1.mm],
	[-20.mm,0,Drum::Radius-1.mm],
	[-20.mm,0,Drum::Radius+9.mm],
	[-20.mm+9.mm,0,Drum::Radius+9.mm],
	[-20.mm+9.mm,0,Drum::Radius]
	ridge=[[-35.mm,0,0],[-20.mm,0,-5.mm],[0,0,5.mm],[20.mm,0,-5.mm],[35.mm,0,0]]
	# Create the 2-D shape
	c=lid.map{|x| x.offset([-Drum::Inside_height/2,0,0])}+
	ridge.map{|x| x.offset([-140.mm,0,Drum::Radius])}+
	ridge.map{|x| x.offset([140.mm,0,Drum::Radius])}+
	lid.reverse.map{|x| [-x.x,x.y,x.z].offset([Drum::Inside_height/2,0,0])}+[[-Drum::Inside_height/2,0,0]]
	drum=Sketchup.active_model.entities.add_group
	curve=drum.entities.add_curve(c)
	curve_face=drum.entities.add_face curve
	path =Sketchup.active_model.entities.add_circle [0,0,0],[1,0,0],Drum::Radius,36
	curve_face.followme path
	Sketchup.active_model.entities.erase_entities path
	return drum	
end
#digital_drum(285.mm,230.mm,24*Math::PI/180,404.mm,111.6.mm,15*Math::PI/180)
def digital_drum(sc_x=285.0.mm,sc_y=215.0.mm,sc_angle=24.0*Math::PI/180,kb_x=404.0.mm,kb_y=120.0.mm,kb_angle=12.0*Math::PI/180,stock_width=20.0.mm)
	d=drum
	w,reference=wedge(sc_x,sc_y,sc_angle,kb_x,kb_y,kb_angle,stock_width)
	print 'reference:',Math.sqrt(reference.y*reference.y+reference.z*reference.z)*2.54,' mm ',Math.atan(reference.z/reference.y)*180.0/Math::PI," deg\n"
	r,d=intersect(d,w)
	r_1,d=intersect(d,w.transform!(Geom::Transformation.scaling(1,-1,1)))
	w.erase!
	r_1.erase!
	#keyboard
	k=kb_panel(kb_x,kb_y,stock_width)
	k.transform! Geom::Transformation.translation([-kb_x/2-stock_width,kb_y/2+stock_width,0])
	k.transform! Geom::Transformation.rotation([0,0,0],[1,0,0],-kb_angle)
	k.transform! Geom::Transformation.translation([reference.x+420.mm,reference.y,reference.z])
	#!!!! not mirror image: keyboard is not symetrical!
	#k.copy.transform!(Geom::Transformation.scaling(1,-1,1))
	k=kb_panel(kb_x,kb_y,stock_width)
	#k.transform!(Geom::Transformation.scaling(-1,1,1)) # rotation PI
	k.transform! Geom::Transformation.rotation([0,0,0],[0,0,1],Math::PI)
	k.transform! Geom::Transformation.translation([-(kb_x/2+stock_width),-(kb_y/2+stock_width),0])
	k.transform! Geom::Transformation.rotation([0,0,0],[1,0,0],kb_angle)
	k.transform! Geom::Transformation.translation([420.mm,-reference.y,reference.z])
	#screen
	s=sc_panel(sc_x,sc_y,stock_width,kb_x)
	s.transform! Geom::Transformation.scaling(1,1,-1) #mirror image
	s.transform! Geom::Transformation.translation([-kb_x/2-stock_width,sc_y/2+stock_width,0])
	s.transform! Geom::Transformation.rotation([0,0,0],[1,0,0],Math::PI/2+sc_angle)
	s.transform! Geom::Transformation.translation([420.mm,reference.y,reference.z])
	s.copy.transform!(Geom::Transformation.scaling(1,-1,1))
	#p=pane
	#p.transform! Geom::Transformation.translation([-kb_x/2-stock_width,sc_y/2+stock_width, 1.mm])
	#p.transform! Geom::Transformation.rotation([0,0,0],[1,0,0],Math::PI/2+sc_angle)
	#p.transform! Geom::Transformation.translation([420.mm,reference.y,reference.z])
	#pp=p.copy.transform!(Geom::Transformation.scaling(1,-1,1))
	#material is not copied
	#pp.material=p.material
	
	
	#side wall
	puts r.transformation.origin
	rr=0.9
	alpha=Math::PI*0.3
	p=[0,Math.cos(alpha)*Drum::Radius*rr,Math.sin(alpha)*Drum::Radius*rr]
	print 'hole:',p.x*25.4,' ',p.y*2.54,' ',p.z*2.54,"\n"
	r=side_wall(r,p)
	r.transform! Geom::Transformation.translation([-kb_x-2*stock_width,0,0])
	#bolt
	bolt.transform! Geom::Transformation.translation([20.mm,-p.y,p.z])
		
	#sp=special(10.mm,100.mm)
	#sp.transform! Geom::Transformation.scaling(-1,1,1) #mirror image
	#sp.transform! Geom::Transformation.translation(p)
	#r=merge(sp,r)	
	#g,h=intersect(r,sp)
	#puts g
	r.copy.transform!(Geom::Transformation.scaling(1,-1,1))
	#Sketchup.active_model.selection.add  g.entities.to_a
	#remove back end
	wall=Sketchup.active_model.entities.add_group
	wall.entities.add_face [0,1,1],[0,1,-1],[0,-1,-1],[0,-1,1]
	wall.transform! Geom::Transformation.scaling(2*Drum::Radius)
	ww=200.mm
	wall.transform! Geom::Transformation.translation([-ww,0,0])
	b,d=intersect(d,wall)
	wall.erase!
	#pics the wrong one
	#d.erase!
	lid(d,p)
	#add a stud for closing	
	#k=bar.transform! Geom::Transformation.scaling(0.45)
	#k.transform! Geom::Transformation.translation([-ww+0.5+11.mm,0,-Drum::Radius])
	#k.material='red'
end
def special(radius=1.0,height=1.0)
	s=Sketchup.active_model.entities.add_group
	f=s.entities.add_face(s.entities.add_circle([0,0,0],[1,0,0],radius,10))
	f.pushpull height
	s.entities.add_circle([height,0,0],[1,0,0],radius/2,10)
	s.entities.erase_entities f
	s.entities.erase_entities s.entities.to_a.last
	return s
end
def test
	s=special(0.5,2)
	w=Sketchup.active_model.entities.add_group
	w.entities.add_face [1,1,1],[1,1,-1],[1,-1,-1],[1,-1,1]
	#w.entities.each{|x| puts x}	
	#b,w=intersect(w,s)
	#puts
	#w.entities.each{|x| puts x}	
	#puts
	return merge(s,w)
end

def pipe
	radius=25.mm/2 # inside diameter must clear 17 mm socket (~25 mm diameter)
	height=20.mm
	g=Sketchup.active_model.entities.add_group
	f=g.entities.add_face(g.entities.add_circle([0,0,0],[1,0,0],radius,10))
	f.pushpull height
	f.erase!
	return g

end

def side_wall(r,p)
	#remove material
	Sketchup.active_model.entities.erase_entities r.entities.to_a.select{|x| 
		((x.typename=='Edge')&&
		#numeric precision
		((x.start.position.x+r.transformation.origin.x<Drum::Inside_height*0.49)||
		(x.end.position.x+r.transformation.origin.x<Drum::Inside_height*0.49)))
	}
	#sp=special(10.mm,100.mm)
	print "side wall:",r.transformation.origin,"\n"
	sp=pipe
	sp.transform! Geom::Transformation.scaling(-1,1,1) #mirror image
	sp.transform! Geom::Transformation.translation([Drum::Inside_height/2+20.mm,p.y,p.z]) #sticking out slightly for locking
	r=merge(sp,r)	
	g=Sketchup.active_model.entities.add_group
	f=g.entities.add_face(g.entities.add_circle([Drum::Inside_height/2,p.y,p.z],[1,0,0],10.mm/2))	
	r=merge(g,r)
	f.erase!
	#put bolt for visualization
	return r
end

def lid(r,p)
	#would be nice to change axis...
	Sketchup.active_model.entities.erase_entities r.entities.to_a.select{|x| 
		((x.typename=='Edge')&&
		((x.start.position.x+r.transformation.origin.x>-Drum::Inside_height/2)||
		(x.end.position.x+r.transformation.origin.x>-Drum::Inside_height/2)))
	}
	#add nuts
	#nut is welded behind plate
	n=nut#.transform!(Geom::Transformation.scaling(0.5))
	r=merge(r,n.copy.transform!(Geom::Transformation.translation([-Drum::Inside_height/2, p.y,p.z])))
	r=merge(r,n.copy.transform!(Geom::Transformation.translation([-Drum::Inside_height/2,-p.y,p.z])))
	n.erase!
	#add holes for wall attachment
	#r.entities.add_circle([-Drum::Inside_height/2,0,p.z],[1,0,0],5.mm)	
	#r.entities.add_circle([0,0,0],[1,0,0],5)	
	#add hook	
	g=hook#.transform!(Geom::Transformation.scaling(0.5))
	g.transform!(Geom::Transformation.translation([-Drum::Inside_height/2,0,-Drum::Radius*0.99]))
	#g.material='red'
	r=merge(r,g)
	return r
end
def hook
	g=Sketchup.active_model.entities.add_group	
	g.entities.add_face([14.mm,10.mm,0],[0,10.mm,0],[0,-10.mm,0],[14.mm,-10.mm,0])
	#add a small bolt to it
	b=bolt_5
	b.transform!(Geom::Transformation.rotation([0,0,0],[0,1,0],-Math::PI/2))
	b.transform!(Geom::Transformation.translation([7.mm,0,0]))
	g=merge(g,b)
	return g
end	
def pane(sc_x=285.0.mm,sc_y=215.mm,width=20.mm)
	g=Sketchup.active_model.entities.add_group	
	x=sc_x/2+width
	y=sc_y/2+width
	g.entities.add_face([x,y,0],[x,-y,0],[-x,-y,0],[-x,y,0]).pushpull 3.mm
	g.material='gray'
	g.material.alpha=0.5
	#g.entities.each{|x| 
	#	x.material='red'
	#	x.material.alpha=0.5
	#}
	return g	
end
	
=begin
def hook
	g=Sketchup.active_model.entities.add_group	
	g.entities.add_face([ 2, 1, 1],[ 2, 1,-1],[ 2,-1,-1],[ 2,-1,1])
	g.entities.add_face([ 2,-1, 1],[ 2,-1,-1],[-0,-1,-1],[-0,-1,1])
	g.entities.add_face([ 2, 1, 1],[ 2, 1,-1],[-0, 1,-1],[-0, 1,1])
	return g
end

def bar
	g=Sketchup.active_model.entities.add_group	
	g.entities.add_face([1,1,0],[1,-1,0],[-1,-1,0],[-1,1,0]).pushpull -2
	return g
end
=end
def wedge(sc_x=285.0.mm,sc_y=215.0.mm,sc_angle=24.0*Math::PI/180,kb_x=405.0.mm,kb_y=120.0.mm,kb_angle=12.0*Math::PI/180,stock_width=20.0.mm)
	kb_panel_x=(2*stock_width+kb_x)/Drum::Radius #normalized
	kb_panel_y=(2*stock_width+kb_y)/Drum::Radius #normalized
	sc_panel_x=(2*stock_width+sc_x)/Drum::Radius #normalized
	sc_panel_y=(2*stock_width+sc_y)/Drum::Radius #normalized
	wedge=Sketchup.active_model.entities.add_group
	tot_angle=sc_angle+Math::PI/2+kb_angle
	rope_2=kb_panel_y*kb_panel_y + sc_panel_y*sc_panel_y-2*kb_panel_y*sc_panel_y*Math.cos(tot_angle)
	alpha=Math.acos((rope_2+kb_panel_y*kb_panel_y-sc_panel_y*sc_panel_y)/(2*Math.sqrt(rope_2)*kb_panel_y))
	theta=Math.acos(1-rope_2/2)
	beta=(Math::PI-theta)/2
	gamma=beta-alpha
	f=[0,Drum::Radius,0],
	[0,Drum::Radius*Math.cos(theta),Drum::Radius*Math.sin(theta)],
	[0,Drum::Radius*(1-kb_panel_y*Math.cos(gamma)),Drum::Radius*kb_panel_y*Math.sin(gamma)]
	w=wedge.entities.add_face f
	w.pushpull 2*[kb_x,sc_x].max
	reference=f[2].transform Geom::Transformation.rotation([0,0,0],[1,0,0],gamma-kb_angle)
	#puts reference
	wedge.transform! Geom::Transformation.scaling(f[2],2)#transformation about point f[2]
	wedge.transform! Geom::Transformation.rotation([0,0,0],[1,0,0],gamma-kb_angle)
	#need to know the width of keyboard panel
	wedge.transform! Geom::Transformation.translation([Drum::Inside_height/2-kb_panel_x*Drum::Radius+11.mm,0,0])
	return wedge,reference
end
def stud(radius,height)
	s=Sketchup.active_model.entities.add_group
	s.entities.add_face(s.entities.add_circle([0,0,0],[0,0,1],radius,10)).pushpull height
	return s
end
def kb_panel(width=405.mm,height=120.mm,stock_width=20.mm)
	panel=Sketchup.active_model.entities.add_group
	x=width/2+stock_width
	y=height/2+stock_width
	panel.entities.add_face [-x,-y,0],[x,-y,0],[x,y,0],[-x,y,0]
	x=width/2
	y=height/2
	panel.entities.erase_entities panel.entities.add_face([-x,-y,0],[x,-y,0],[x,y,0],[-x,y,0])
	# mounting studs
	s=stud(2.5.mm,20.mm)
	m=[ 182.mm, 132.mm, 82.mm, 32.mm,-18.mm,-68.mm,-122.mm,-182.mm]
	n=[-53.mm,0,53.mm]
	entities=panel.explode,
	m.map{|t| s.copy.transform!(Geom::Transformation.translation([t, 66.mm,0])).explode},
	m.map{|t| s.copy.transform!(Geom::Transformation.translation([t,-66.mm,0])).explode},
	n.map{|t| s.copy.transform!(Geom::Transformation.translation([-210.mm,t,0])).explode},
	n.map{|t| s.copy.transform!(Geom::Transformation.translation([ 210.mm,t,0])).explode}
	s.erase!
	return Sketchup.active_model.entities.add_group(Sketchup.active_model.entities.to_a.select{|x| entities.flatten.include? x}) 
end
def sc_panel(width,height,stock_width,kb_width) #the keyboard will usually be wider than screen
	panel=Sketchup.active_model.entities.add_group
	x=kb_width/2+stock_width
	y=height/2+stock_width
	panel.entities.add_face [-x,-y,0],[x,-y,0],[x,y,0],[-x,y,0]
	x=width/2
	y=height/2
	panel.entities.erase_entities panel.entities.add_face([-x,-y,0],[x,-y,0],[x,y,0],[-x,y,0])
	# mounting studs
	m=[-width*0.25,width*0.25]
	n=[-height*0.25,height*0.25]
	s=stud(2.5.mm,20.mm)
	entities=panel.explode,	
	m.map{|t| s.copy.transform!(Geom::Transformation.translation([t,-(height/2+stock_width/2),0])).explode},
	m.map{|t| s.copy.transform!(Geom::Transformation.translation([t,+(height/2+stock_width/2),0])).explode},
	n.map{|t| s.copy.transform!(Geom::Transformation.translation([-(width/2+stock_width/2),t,0])).explode},
	n.map{|t| s.copy.transform!(Geom::Transformation.translation([+(width/2+stock_width/2),t,0])).explode}
	s.erase!
	#camera?
	#pane
	g=Sketchup.active_model.entities.add_group(Sketchup.active_model.entities.to_a.select{|x| entities.flatten.include? x})
	#does not work
	g=merge(g,pane.transform!(Geom::Transformation.translation([0,0,-1.mm]))) #inherits the material
	return g
end

def nut
	#17 mm nut size, 10 mm inside, 8 mm height
	r=17.mm/2
	r=r/Math.cos(Math::PI/6)	
	n=Sketchup.active_model.entities.add_group
	f=n.entities.add_face((0..5).map{|x| angle=x*Math::PI/3;[0,r*Math.cos(angle),r*Math.sin(angle)]})
	n.entities.add_circle([0,0,0],[1,0,0],10.mm/2,20)
	n.entities.erase_entities n.entities.to_a.last
	f.pushpull -8.mm #risky is the reference still good?
	n.material='red'
	return n
end
def bolt
	r=17.mm/2
	r=r/Math.cos(Math::PI/6)	
	n=Sketchup.active_model.entities.add_group
	f=n.entities.add_face((0..5).map{|x| angle=x*Math::PI/3;[0,r*Math.cos(angle),r*Math.sin(angle)]})
	f.pushpull 6.mm
	n.entities.add_circle([0,0,0],[1,0,0],10.mm/2,20)
	n.entities.to_a.last.pushpull 200.mm
	n.material='red'
	return n	
end
def bolt_5
	r=10.mm/2
	r=r/Math.cos(Math::PI/6)	
	n=Sketchup.active_model.entities.add_group
	f=n.entities.add_face((0..5).map{|x| angle=x*Math::PI/3;[0,r*Math.cos(angle),r*Math.sin(angle)]})
	f.pushpull 3.mm
	n.entities.add_circle([0,0,0],[1,0,0],5.mm/2,20)
	n.entities.to_a.last.pushpull 10.mm
	n.material='red'
	return n	
end

def info(ent)
	case ent.typename
	when 'Vertex'
		print ent," ",ent.position,"\n"
	#when 'Face'
	#	puts 'Face'
	#	ent.vertices.each{|x| info x}
	when 'Edge'
		#puts 'Edge'
		ent.vertices.each{|x| info x}
	when 'Group'
		puts ent.bounds.center
		info ent.entities[0]
	else
		#ent.vertices.each{|x| info x}
		puts ent.typename
	end
	return
end
def remove_1(start_edge,s_intersect)
#def remove_1(start_edge,s_intersect,s_remove)
	s_remove=Set.new	#entities to be removed
	stack=[start_edge]
	while(!stack.empty?)
		edge=stack.delete_at(0)
		if((!s_remove.include?(edge))&&(!s_intersect.include?(edge)))
			s_remove.insert edge
			edge.faces.each{|face| 
				s_remove.insert face
				face.edges.each{|next_edge| stack.push(next_edge)}
		}
		end
	end
	return s_remove
end
#should be made a method of group
def intersect(grp_0,grp_1)
	intersection=Sketchup.active_model.entities.add_group
	grp_0.entities.intersect_with false,grp_0.transformation,intersection.entities,Geom::Transformation.new,false,[grp_1]
	s_intersect=Set.new #edges in the intersection
	#s_remove=Set.new	#entities to be removed
	intersection.entities.transform_entities(grp_0.transformation.inverse,intersection.entities.to_a)
	puts grp_0.entities.length
	intersection.entities.each{|x| s_intersect.insert grp_0.entities.add_edges(x.start,x.end)[0]}
	puts grp_0.entities.length
	Sketchup.active_model.selection.add intersection.entities.to_a 
	print s_intersect.length," edges in the intersection\n"
	#we can be smart here
	start_entity=grp_0.entities.to_a.last #a good guess for entity within
	if(start_entity.typename=='Face')
		start_entity=start_entity.edges[0]	
	end
	#remove_1(start_entity,s_intersect,s_remove)
	s_remove=remove_1(start_entity,s_intersect)
	if(s_remove.empty?)
		s_remove.insert grp_0.entities.to_a.last
	end
	print s_remove.length," entities to remove\n"
	Sketchup.active_model.entities.erase_entities intersection
	l=grp_0.explode #grp_0 does not exist anymore, all the entities are now in Sketchup.active_model.entities
	a=Sketchup.active_model.entities.add_group s_remove.to_a
	b=Sketchup.active_model.entities.add_group Sketchup.active_model.entities.to_a.select{|x| (!s_remove.include?(x)&&l.include?(x))}
	return a,b
end
