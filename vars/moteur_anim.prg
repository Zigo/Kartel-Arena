
process jambes(distx_cuisse,sens)
private

	depy; 
	fget_angle_x1;    
	vit1; 
	angle_hurtmove;    
	c_position; 
	
	cou_pied;

Begin
            
   file=father.file;         
	ctype=c_scroll;    
	cnumber=c_0;		// il n'est que dans le scroll principale
	graph=father.graph+1;
	cuisse(); 
	angle1=distx_cuisse*36000/2;  
	priority=father.priority-1; 
	
	fto=graphic_info(file,graph,G_WIDTH);	// sauvegarde la largeur initiale  
	
	
  
  
loop   

   
   alpha=father.alpha;
   
   
                   
	if(sens==0)
		flags=father.flags;
	end           

                                 
                                 
	if(sens==1)
		if(father.flags=0)
			flags=2;  
		end    
		if(father.flags=2)
			flags=0;  
		end
	end

         

	switch(flags):
		
		case 0:  

			pos_px=father.atf+distx_cuisse;
			pos_py=father.atf2; 
 
			if(father.sol)
				angle1-=father.x_speed*3000;
			end   

			father.vari_hjambes=+abs(father.atf-prx)-53;

			prx=father.atf+10+get_distx(angle1,abs(father.x_speed/3)+7)*3;              
			
			if(prx<father.atf-40)prx=father.atf-40;
				if(nct02)
					if(father.sol)  
						father.vit_vit_dep=-3;  
					end
					nct02=0;  
				end
			else
				nct02=1;
			end

			pry=father.atf2+father.hauteur_jambes-5+get_disty(angle1,15); 
			
			if(pry>father.atf2+father.hauteur_jambes)pry=father.atf2+father.hauteur_jambes;
				if(nct01)  
					nct01=0;  
				end
			else
				nct01=1;
			end

			fget_angle_x1=father.atf+get_distx(angle1,40)+40;
			
			if(fget_angle_x1>father.atf+30)
				fget_angle_x1=father.atf+30;
			end 

			angle=fget_angle(prx,pry,fget_angle_x1,father.atf2+father.hauteur_jambes/2+get_disty(angle1,25)/3-10);
 			size_x=fget_dist(prx,pry,fget_angle_x1,father.atf2+father.hauteur_jambes/2+get_disty(angle1,25)/3-10)*100/fto;
     
			if(father.x_speed==0) 			
				if(distx_cuisse<0)angle1=220000; end
				if(distx_cuisse>0)angle1=290000;end  
				c_position=1;
			else
				if(c_position)
					if(distx_cuisse<0)angle1=500000; end
					if(distx_cuisse>0)angle1=320000;end  
					c_position=0;
				end
			end   

		end  
		
		
		case 2:

			pos_px=father.atf+distx_cuisse;
			pos_py=father.atf2;

			if(father.sol)
 				angle1+=father.x_speed*3000;
			end      

			father.vari_hjambes=-abs(father.atf-prx)-30;  
  
			prx=father.atf-10-get_distx(angle1,abs(father.x_speed/3)+7)*3;              

			if(prx>father.atf+40)prx=father.atf+40;
				if(nct02)
					if(father.sol)  
						father.vit_vit_dep=-3;  
					end
					nct02=0;  
				end
			else
				nct02=1;
			end

			pry=father.atf2+father.hauteur_jambes-5+get_disty(angle1,15);
			
			if(pry>father.atf2+father.hauteur_jambes)pry=father.atf2+father.hauteur_jambes;
				if(nct01)
					nct01=0;  
				end
			else
				nct01=1;
			end 

			fget_angle_x1=father.atf-get_distx(angle1,40)-40;

			if(fget_angle_x1<father.atf-30)
				fget_angle_x1=father.atf-30;
			end
			
			//if(father._saute==true) cou_pied=-50000; end 
			if(cou_pied<1) // COUP DE PIED 
            angle=cou_pied+fget_angle(prx,pry,fget_angle_x1,father.atf2+father.hauteur_jambes/2+get_disty(angle1,25)/3-10);
			   cou_pied+=5000;
			else  
				angle=fget_angle(prx,pry,fget_angle_x1,father.atf2+father.hauteur_jambes/2+get_disty(angle1,25)/3-10);
			end    
			
			size_x=fget_dist(prx,pry,fget_angle_x1,father.atf2+father.hauteur_jambes/2+get_disty(angle1,25)/3-10)*100/fto;
         
         
     	if(father.x_speed==0) 
				c_position=1;
				if(distx_cuisse>0)angle1=220000; end
				if(distx_cuisse<0)angle1=290000;end 
			else
				if(c_position)
					if(distx_cuisse>0)angle1=500000; end
					if(distx_cuisse<0)angle1=320000;end  
					c_position=0;
				end
			end           

		end  
		

	end      // END SWITCH FLAGS //



	/*if(angle_touché<>0)
	father.angle_touché=angle_touché;
		//vit1=10;   
		*//*if(angle_touché<90000 and angle_touché>-90000)
			father.dist_choc=2;
		end 
		if(angle_touché>90000 and angle_touché<270000)
			father.dist_choc=-2;
		end */ /*
		//angle_hurtmove=angle_touché;
		angle_touché=0;
	end  */

    /*
	if(vit1>0)
		prx-=get_distx(-angle_hurtmove,vit1*2);  
		pry-=get_disty(-angle_hurtmove,vit1/2);
		vit1--; 
	end        */
  
   
  x=prx+distx_cuisse;
  y=pry;                               
               
  
	get_real_point(1,&x1,&y1);
	
	fto2=collision(type objet_muniton); 
  	if(fto2>0) father.fto2=fto2; end   
	


		frame(frame_timeu);
	end  
end                      

 
 
PROCESS cuisse();
private

angle_hurtmove;
vit1;
Begin 
 
file=father.file;
z=father.z;
ctype=c_scroll; 
cnumber=c_0;		// il n'est que dans le scroll principale 
graph=father.graph+1;  
priority=father.priority-1;
//size_x=150;              

fto=graphic_info(file,graph,G_WIDTH);	// sauvegarde la largeur initiale
                                   
loop    

alpha=father.alpha;

flags=father.flags;
prx=father.pos_px;
pry=father.pos_py;

angle=fget_angle(prx+distx_cuisse,pry,father.x1,father.y1)+180000;    

sol=fget_dist(prx+distx_cuisse,pry,father.x1,father.y1); 
if(sol<50)       // evite que les jambes soient trop longuent
   size_x=sol*100/fto;
   /*say(sol);*/
end

if(flags==0);
if(prx>father.father.x)z=father.father.z+2;father.z=father.father.z+2;end     
if(prx<father.father.x)z=father.father.z-1;father.z=father.father.z-1;end     
end      

if(flags==2);
if(prx<father.father.x)z=father.father.z+2;father.z=father.father.z+2;end     
if(prx>father.father.x)z=father.father.z-1;father.z=father.father.z-1;end     
end

/*if(angle_touché<>0)
vit1=10;
if(angle_touché<90000 and angle_touché>-90000)father.father.dist_choc=2;end 
if(angle_touché>90000 and angle_touché<270000)father.father.dist_choc=-2;end
angle_hurtmove=angle_touché;angle_touché=0;
end  */ 
    /*
if(angle_touché<>0)
	father.father.angle_touché=angle_touché+180000;
		//vit1=10;   
	
		//angle_hurtmove=angle_touché;
		/angle_touché=0;
	end   */

   /*
if(vit1>0)

prx+=get_distx(-angle_hurtmove,vit1);  
pry+=get_disty(-angle_hurtmove,vit1/2);
vit1--; end  */
                  
x=prx;
  y=pry; 
  
  fto2=collision(type objet_muniton); 
  if(fto2>0) father.father.fto2=fto2; end                             
                                 
                  
frame(frame_timeu);
end
end   

PROCESS bras_tete(numero_joueur_papa/*_utiliser*/);
     /*
Private
	 
  id_supp;
  angle_effet_arme;  
     
  sur_arme;   */
  
Begin        


	ctype=c_scroll; 
	
	cnumber=c_0;		// il n'est que dans le scroll principale

	z=father.z-2;   
	
	//file=father.file;
	
	priority=father.priority-1;
 
   atf=-1;	// pour qu'il actualise l'arme  
     
	loop    
	
		x=father.x1-get_distx(angle,father.dist_choc/2);
		y=father.y1-get_disty(angle,father.dist_choc/2); 

		if(father.dist_choc>0)father.dist_choc--;end
	   
	   if(infos_JOUEURS[numero_joueur_papa].vie!=0)      // lorsqu'il meurt
	      //nct05=fget_angle(infos_JOUEURS[numero_joueur_papa].coord_mouse.x/*+scroll.x0*/,infos_JOUEURS[numero_joueur_papa].coord_mouse.y/*+scroll.y0*/,father.x,father.y);
			//if(flags==0)
			angle=fget_angle(infos_JOUEURS[numero_joueur_papa].coord_mouse.x,infos_JOUEURS[numero_joueur_papa].coord_mouse.y,x,y)+180000;//+angle_effet_arme;       
			/*else
			angle=fget_angle(y,x,infos_JOUEURS[numero_joueur_papa].coord_mouse.y,infos_JOUEURS[numero_joueur_papa].coord_mouse.x)+90000;
			end*/
		end
		     
	   //flags=father.flags; 
	   alpha=father.alpha; 
	     
	   // --------- NOM JOUEUR ----------
	   if(exists(atf2))
	   	atf2.x=x;
	   	atf2.y=y-65; 
	   else      
	   	atf3=get_text_color();
	      set_text_color(couleurs[numero_joueur_papa]);
      	atf2=objet2(0,0,z-10,0,write_in_map(0,infos_JOUEURS[numero_joueur_papa].pseudo,4),0,170,170,0,0,240,1);  // affiche le nom
	   	set_text_color(atf3);	// remet la couleur du texte
	   	atf2.ctype=c_scroll;
	   	atf2.cnumber=c_0;
      end             
      // ----------- ARMES -------------
      if(atf<>get_joueur_arme(numero_joueur_papa))  // si on change d'arme, actualise l'image
      	unload_map(0,graph);  
      	graph=map_clone(father.file,father.graph-1);    
      	prX=graphic_info(father.file,father.graph-1,G_WIDTH);
      	prY=graphic_info(father.file,father.graph-1,G_HEIGHT);
      	atf=/*ARMES_CHOISIS[infos_JOUEURS[numero_joueur_papa].arme_en_cour]*/get_joueur_arme(numero_joueur_papa);
         get_point(0,graph,1,&x1,&y1);                              
         if(prX<x1+graphic_info(FPG_armes,atf*10+1,G_WIDTH))  // si l'image peut pas contenir l'arme
      		atf3=new_map(x1+graphic_info(FPG_armes,atf*10+1,G_WIDTH),prY,16);   // on l'agrandi
      		get_point(0,graph,0,&x1,&y1); 
      		map_put(0,atf3,graph,x1,y1);
      		set_point(0,atf3,0,x1,y1);  
      		get_point(0,graph,1,&x1,&y1);
      		set_point(0,atf3,1,x1,y1);          
      		get_point(0,graph,2,&x1,&y1);
      		set_point(0,atf3,2,x1,y1);                                                                
      		unload_map(0,graph);
      		graph=atf3;		
      	end
      	get_point(0,graph,1,&x1,&y1);
      	map_xput(FPG_armes,graph,atf*10+1,x1,y1,0,100,0);   // arme  
      	// ----- 
      	from fto=1 to donnees_armes[atf].nb2trou;         // point de l'arme qui tire
      		get_point(FPG_armes,atf*10+1,fto,&x1,&y1);
      		pos_px=x1;pos_py=y1;
      		get_point(FPG_armes,atf*10+1,0,&x1,&y1);
      		pos_px-=x1;pos_py-=y1;
      		pos_px=pos_px;pos_py=pos_py;
      		get_point(0,graph,1,&x1,&y1);
      		pos_px+=x1;pos_py+=y1;     		
      		set_point(0,graph,10+fto,pos_px,pos_py);	
      	end     
      	// -----
      	get_point(0,graph,2,&x1,&y1); 
      	map_block_copy(father.file,graph,0,y1,father.graph-1,0,y1,x1,prY-y1,0);         // bras gauche par dessus l'arme   
      	// -----
      	//infos_JOUEURS[numero_joueur_papa].munition[infos_JOUEURS[numero_joueur_papa].arme_en_cour]+=donnees_armes[atf].munition_depart; // plein de munition
      end                            
      
      get_real_point(10+1+nct02%donnees_armes[atf].nb2trou,&sx,&sy);	// pour l'explosion au bout du fusil 
      
      // -------- ON TIRE !! -----------
      if(father._tire)   
      	if(get_joueur_munition_arme(numero_joueur_papa,-1)>0)	// si on a encore des munitions  
	      	if(nct01++>=donnees_armes[atf].delai_tir)           	// tir non continu 
	      		nct01=0;
	      		nct02++;         
	      		infos_JOUEURS[numero_joueur_papa].munition[infos_JOUEURS[numero_joueur_papa].arme_en_cour]--; // moins une munition
	      		father.dist_choc=donnees_armes[atf].puissance;		// recul 
	      		taily=1+nct02%donnees_armes[atf].nb2trou;                            // tir un trou apres l'autre
	      		get_real_point(10+taily,&x1,&y1);       // tir un trou apres l'autre 
	      		tailx=angle+rand_tous_pareil(-donnees_armes[atf].precision,donnees_armes[atf].precision)*500; 			// angle de tir
	      		projectile(donnees_armes[atf].graph_balle,x1,y1,tailx,donnees_armes[atf].vit_tir,donnees_armes[atf].type_tir);
	      		// ---- EFFET ----            
	      		switch(donnees_armes[atf].type_tir)
	      			case 0:                              // balles
	      				eclat(FPG_jeu,10,40,z+1,0,255,150,150,c_scroll,c_0,taily);     
	      				douille(x1,y1,z-1);
	      			end
	      			case 1:                              // plasma
	      				eclat(FPG_jeu,20,-25,z+1,16,255,200,200,c_scroll,c_0,taily);	
	      			end  
	      			case 2:                              // blaster lazer
	      					
	      			end
	      		end   
	      		// ---------------
	      		JOUEUR_PROFIL.nb_balle++;
	      		// --------------- 
	      	end
	      	if(nct02>=donnees_armes[atf].munition_par_chargeur && donnees_armes[atf].munition_par_chargeur!=-1)   // chargeur vide
	      	   nct01=-DONNEE_duree_rechargement;
	      	   nct02=0;
	      		// SON RECHARGE
	      	end  
	      else  // plus de muntion
	      	// SON CLIC CLIC 
	      end
      else
      	if(nct01<donnees_armes[atf].delai_tir)
      		nct01++;	
      	end
      end
      // -------------------------------   
      
      fto2=collision(type objet_muniton); 
  		if(fto2>0) father.fto2=fto2; end  
       
      /*if(angle_touché<>0)          // si on se prend un tir baby
			father.angle_touché=angle_touché;
			angle_touché=0;
		end   */
      
      
//type_arme=father.type_arme;
//texte2=write_int(0,140,450,4,&jette_arme);

/*switch(type_arme);

 
CASE 0:    */
     
    /* end

CASE 1:        // lazer a energie
  graph=65;
  
  	if(flags==0)
			x1=x+get_distx(angle-23000,30);
			y1=y+get_disty(angle-23000,30);
			end
			
			if(flags==2)
			x1=x+get_distx(angle+23000,30);
			y1=y+get_disty(angle+23000,30);
	 end
  
  if(nct01<>0)
  //boule_blanche(x1+rand(+nct01,-nct01)/50,y1+rand(+nct01,-nct01)/50,nct01+20);
  //vrille_blanche(x1+rand(+nct01,-nct01)/50,y1+rand(+nct01,-nct01)/50,nct04,200,nct01+20);
  end
  
  if(nct01==0)nct02=1;end
  if(nct01>80)nct01=80;end
  
	if(mouse.left and nct02==1)
		nct01+=2;
		nct04+=8000;
		nct03=1;
		
		//angle_effet_arme=rand(+nct01,-nct01)*20;
		//father.dist_choc=rand(+nct01,-nct01)/80;
	else
		nct01-=20;  
		//angle_effet_arme=0;
		//father.dist_choc=0;
		if(nct03)father.dist_choc=nct01/10+2;
		tir(x1*100,y1*100,nct01);nct03=0;end
		
		if(nct01<0)nct02=1;nct01=0;else nct02=0;end
		
			end  
	
	 
	
end  

CASE 2:
  graph=65;

	if(mouse.left)
		if(nct01++>1)
		father.dist_choc=2;   
			get_real_point(1,&x1,&y1);
			explo2(x1,y1,50);
		  tir(x1*100,y1*100,0);
			//PLAY_WAV ( son_fire1, 0 ); 
		nct01=0;
		end
		else
		nct01=1;
	end  
	
	 
	
end  

CASE 3:
  
  graph=65; 
  
  
  	if(flags==0)
			x1=x+get_distx(angle-20000,20);
			y1=y+get_disty(angle-20000,20);
			end
			
			if(flags==2)
			x1=x+get_distx(angle+20000,20);
			y1=y+get_disty(angle+20000,20);
	 end
  
  nct02--;
		if(nct02<0)nct02=0;end
  
	if(mouse.left)
		//if(nct01)
		if(nct02<1)
		father.dist_choc=5;   
			//get_real_point(1,&x1,&y1);
			explo2(x1,y1,50);
			tir(x1*100,y1*100,0);
		  
			//PLAY_WAV ( son_fire2, 0 ); 
			nct02=60;
	 end	
		
	//	nct01=0;
	//	end
		else   
		
		
		nct01=1;
	end  
	
	 
	
end  

CASE 4:
  graph=65;

	if(mouse.left)
		if(nct01++>3)
		father.dist_choc=2;   
			//get_real_point(1,&x1,&y1);
		
			if(flags==0)
			x1=x+get_distx(angle-26000,40);
			y1=y+get_disty(angle-26000,40);
			end
			
			if(flags==2)
			x1=x+get_distx(angle+26000,40);
			y1=y+get_disty(angle+26000,40);
			end
			
			explo2(x1,y1,50);
		  tir(x1*100,y1*100,0);
			//PLAY_WAV ( son_plasma1, 0 ); 
		nct01=0;
		end
		else
		nct01=1;
	end  
	
	 
	
end               

CASE 5:
  graph=65;

	if(mouse.left)
		if(nct01++>1)
	
		
		father.dist_choc=2;   
		
			if(flags==0)
			x1=x+get_distx(angle-26000+nct02*30000,35-nct02*5);
			y1=y+get_disty(angle-26000+nct02*30000,35-nct02*5);
			end
			
			if(flags==2)
			x1=x+get_distx(angle+26000-nct02*30000,35-nct02*5);
			y1=y+get_disty(angle+26000-nct02*30000,35-nct02*5); 
			end
			
			explo2(x1,y1,50);
		  tir(x1*100,y1*100,0);
			//PLAY_WAV ( son_plasma1, 0 ); 
		nct01=0; 
		nct02+=1; 
		if(nct02>1)nct02=0;end	
		end
		else
		nct01=1;
	end  
	
	 
end	

end	*/  

    /*
  //texte1=write_int(0,100,100,0,& test);

while(id_arme=get_id(type arme)); 


	
		if(fget_dist(father.x,y+hauteur_jambes+40,id_arme.x,id_arme.y)<80 and id_arme.sol==true and id_arme.type_arme<>type_arme)
		if(id_arme.pose_arme==arme_au_sol)	
		
		
			//texte1=write(0,400,300,4,"Appuyez sur 0 pour prendre "+nom_arme[id_arme.type_arme]);
		 
		  if(key(_utiliser))  
		
		  id_arme.id_arme=id; 
		  jette_arme=true;
		  id_arme.pose_arme=arme_dep_main;
		
		
		  end
		  
	
		end 
	
		 
		end
     end
   

         */
         
	/*if(key(_utiliser))
	if(nct_arme);
		while(id_arme=get_id(type arme));   
			if(fget_dist(x,y+hauteur_jambes+40,id_arme.x,id_arme.y)<80 and id_arme.sol==true and id_arme.type_arme<>type_arme)
		    check_distance(); 
		    	if(cont_dist_arme>fget_dist(x,y+hauteur_jambes+40,id_arme.x,id_arme.y))
		    		cont_dist_arme=fget_dist(x,y+hauteur_jambes+40,id_arme.x,id_arme.y);
		    	end
		  	if(id_arme.pose_arme==arme_au_sol)
		  	  id_arme.id_arme=id; 
		  		jette_arme=true;
		  		id_arme.pose_arme=arme_dep_main;
		  	end
		  end 
		end    
		nct_arme=0;
		end
		else
		cont_dist_arme=0;
		nct_arme=1;
	end */  
	            
      /*if(numero_joueur_papa==joueur_num)          // si c'est notre perso
         if(x<mouse.x+scroll.x0)flags=0;else flags=2;end  // sens du perso
			if(angle<>(fget_angle(mouse.x+scroll.x0,mouse.y+scroll.y0,x,y)+180000+angle_effet_arme))  // angle du persos
				envoie_message(16,numero_joueur_papa,(fget_angle(mouse.x+scroll.x0,mouse.y+scroll.y0,x,y)+180000+angle_effet_arme),flags);
			end  
		end   */
      

		
		
		frame(frame_timeu);  //delete_text(texte1);  delete_text(texte2);
	end     
end 

int get_joueur_arme(atf)                 // (num_joueur)
begin
	return ARMES_CHOISIS[infos_JOUEURS[atf].arme_en_stock[infos_JOUEURS[atf].arme_en_cour]];
end
int get_joueur_arme_autre(atf,atf2)                 // (num_joueur,num_arme)
begin
	return ARMES_CHOISIS[infos_JOUEURS[atf].arme_en_stock[atf2]];
end   

int get_joueur_munition_arme(atf,atf2)    // (num_joueur,num_arme_joueur)  -1=arme en cour
begin     
	if(atf2==-1) atf2=infos_JOUEURS[atf].arme_en_cour; end
	return infos_JOUEURS[atf].munition[atf2];
end 

int get_joueur_armes_dispo(atf)    // (num_joueur)  return le plus proche vide
begin     
	from fto=0 to DONNEE_nb_max_armes-1; 
		if(infos_JOUEURS[atf].arme_en_stock[fto]==0) break; end	
	end
	return fto;
end              

int get_joueur_tel_armes(atf,atf2)    // (num_joueur,arme)   return >=0 si le joueur possede l'arme sinon -1
begin
	from fto=0 to DONNEE_nb_max_armes-1; 
		if(ARMES_CHOISIS[infos_JOUEURS[atf].arme_en_stock[fto]]==ARMES_CHOISIS[atf2]) return fto; end	
	end                                                      
	return -1;
end

// /--------------------------------------------------------------------\
// \--------------------- MOTEUR COLLISION -----------------------------/   
// /--------------------------------------------------------------------\   
process moteur_collision_grew()            // celui de grew specialement adapté pour les persos (celui de jvc n'etant pas adapté)
private previtesse;
begin
	
	/*file = 0;  */
	
	previtesse=father.x_speed;
   IF (previtesse<>0)
   	atf=previtesse/abs(previtesse);
   	father.atf3=atf;	// pour la gravité                     
       WHILE (previtesse<>0)
                     
       	IF( map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y+father.hauteur_jambes-20)/*==0*/<>COULEUR_COLLISION and 
         	map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y-60)/*==0*/<>COULEUR_COLLISION and
            map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y-50)/*==0*/<>COULEUR_COLLISION and
            map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y-40)/*==0*/<>COULEUR_COLLISION and
            map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y-30)/*==0*/<>COULEUR_COLLISION and
            map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y-20)/*==0*/<>COULEUR_COLLISION and 
            map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y-10)/*==0*/<>COULEUR_COLLISION and
            map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y-00)/*==0*/<>COULEUR_COLLISION and 
            map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y+father.hauteur_jambes/2-20)/*==0*/<>COULEUR_COLLISION and
            map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y+father.hauteur_jambes/4-20)/*==0*/<>COULEUR_COLLISION and
            map_get_pixel(FPG_COL,MAP_COLLISION,(father.x+atf*30),CORRIGE_HAUTEUR_PERSOS+father.y+father.hauteur_jambes/4*3-20)/*==0*/<>COULEUR_COLLISION)
            father.x+=atf;
         END
             
      	previtesse-=atf;
   	END
	END   
	
end   

PROCESS gravitee_grew(dist_sol,dist_plafond,force,resol);
/*PRIVATE
v_gravitee; */    // remplacé par atf

BEGIN       
	   
	/*file = 0; */
	
	father.sol=false;
	atf=(father.vit_vit_dep+=1);
	if (atf>force)
		father.vit_vit_dep=force;
		atf=force;
	End
	
	IF (atf<0)
		WHILE (atf++!=0)
			if (map_get_pixel(FPG_COL,MAP_COLLISION,(father.x/resol)+5,(father.y/resol)-dist_plafond+CORRIGE_HAUTEUR_PERSOS)<>COULEUR_COLLISION/*==0*/
			and map_get_pixel(FPG_COL,MAP_COLLISION,(father.x/resol)-5,(father.y/resol)-dist_plafond+CORRIGE_HAUTEUR_PERSOS)<>COULEUR_COLLISION/*==0*/
			and map_get_pixel(FPG_COL,MAP_COLLISION,(father.x/resol),(father.y/resol)-dist_plafond+CORRIGE_HAUTEUR_PERSOS)<>COULEUR_COLLISION/*==0*/
			and map_get_pixel(FPG_COL,MAP_COLLISION,(father.x/resol)+father.atf3*24,(father.y/resol)-dist_plafond+CORRIGE_HAUTEUR_PERSOS)<>COULEUR_COLLISION/*==0*/)
				//father.sol=false;
				father.y--;
				//father.sol=false;
			ELSE  
			   
				father.vit_vit_dep=0;
				BREAK;
			End
		End
	ELSE
		father.y+=atf*resol;
		FROM atf=-16 TO 7 STEP 1;
			if (map_get_pixel(FPG_COL,MAP_COLLISION,(father.x/resol),(father.y/resol)+atf+father.hauteur_jambes)==COULEUR_COLLISION/*<>0*/
			or  map_get_pixel(FPG_COL,MAP_COLLISION,(father.x/resol)+5,(father.y/resol)+atf+father.hauteur_jambes)==COULEUR_COLLISION/*<>0*/
			or  map_get_pixel(FPG_COL,MAP_COLLISION,(father.x/resol)-5,(father.y/resol)+atf+father.hauteur_jambes)==COULEUR_COLLISION/*<>0*/)
				//if(father.vit_vit_dep>25)father.vie-=father.vit_vit_dep/2;end
				father.sol=true;
				BREAK;
			End
		END
		if (atf<8)
			father.y+=atf*resol;
			father.tailx=father.vit_vit_dep;
			father.vit_vit_dep=0;
		End
	END

End

PROCESS moteur_collision(string tipe)       // moteur collision par JVC, amélioré par Zigo et moteur physique par Zigo
PRIVATE
  app;//colx;coly;
  map;xi[2];yi[2]; ok;
BEGIN  
    
    angle1=father;
    
    // MAP DE COLLISION
    file = FPG_COL;
    map  = MAP_COLLISION; 
    // ----------------      
    
    //father.tailx = Graphic_Info(father.file,father.graph,G_WIDE)/2; // moitié pour la largeur
    //father.taily = Graphic_Info(father.file,father.graph,G_HEIGHT);
    
    priority=father.priority-1;
    
    LOOP 
    
       sy = father.taily/2;
  
      //Cherche le sens du mouvement (-1 = gauche et 1 = droite)
       IF(father.x_speed/*+father.x_speed2*/<>0)  //Si la variable x_speed du pere n'est pas nul (bouge)
         xi=(father.x_speed/*+father.x_speed2*/)/abs(father.x_speed/*+father.x_speed2*/);  //xi=1 Si x_speed du pere>0 (positif) ou xi=-1 Si x_speed du pere<0 (n‚gatif)
       END

       IF(father.y_speed/*+father.y_speed2*/<>0)  //Si la variable y_speed du pere n'est pas nul (bouge)
         yi=(father.y_speed/*+father.y_speed2*/)/abs(father.y_speed/*+father.y_speed2*/);  //yi=1 Si y_speed du pere>0 (positif) ou yi=-1 Si y_speed du pere<0 (n‚gatif)
       END
      //----------------------------------------------------

      xi[1]=father.x_speed/*+father.x_speed2*/;    //xi[1] (variable comme ‡a) = x_speed du perso
      yi[1]=father.y_speed/*+father.y_speed2*/;    //yi[1] (variable comme ‡a) = y_speed du perso

      x1=0;y1=0;

      //Bouge le personnage
       REPEAT
   
           IF(xi[1]<>0)            //Si la vitesse x n'est pas nul
            ok=1;                  
            if(tipe=="tir") pos_px=get_distx(father.angle,father.tailx); else pos_px=father.tailx; end
            FOR(fto=-father.taily;fto<=0;fto+=1)      
               if(tipe=="tir") pos_py=get_disty(father.angle,fto); else pos_py=fto; end  

              //Vérifie s'il n'y a pas une plateformes immobiles qui gene l'avancée
               IF(map_get_pixel(file,map,father.x+xi*pos_px,father.y+sy+pos_py)/*<>0*/==COULEUR_COLLISION)
                  ok=0;  y1++;
                  if(tipe=="tir")
                  	signal(father,s_kill); 
                  	return;
                  end
               END
              //----------------------------------------

              //Vérifie les plateformes mobiles pour voir si le perso peut avancer horizontalement
             /*  WHILE(id2=get_id(TYPE plateforme_mobile))
                 IF(map_get_pixel(0,id2.graph,father.x+xi*father.taillex-id2.x+graphic_info(0,id2.graph,g_center_x),father.y-id2.y+graphic_info(0,id2.graph,g_center_y)+fromto)==36)
                   ok=0;
                 END
               END   */
              //-----------------------------------------------------------------
              FRAME 0;
            END

             IF(ok) //Si le perso peut bouger horizontalement avec x (pas d'obstacle)
               father.x+=xi;  //Le perso avance avec x   
             END
             xi[1]-=xi;  //xi[1] s'approche du zéro (voir le WHILE)
           END
           IF(yi[1]<>0)            //Si la vitesse y n'est pas nul

             ok=1;
             IF(yi[1]<0)app=father.taily; //Si le perso est en train de sauter, on vérifie au niveau du haut du perso (la tête)
             ELSE app=1;END //Mais s'il est en train de chuter, on vérifie au niveau des pieds   
             
             if(tipe=="tir") pos_py=get_disty(father.angle,app); else pos_py=app; end      
             
             FOR(fto=-father.tailx+1;fto<=father.tailx-1;fto++)
               //Vérifie s'il n'y a pas une plateformes immobiles qui gene le mouvement
                if(tipe=="tir") pos_px=get_distx(father.angle,fto); else pos_px=fto; end
              
                IF(map_get_pixel(file,map,father.x+pos_px,father.y+sy+yi*pos_py)/*<>0*/==COULEUR_COLLISION)
                  ok=0; x1++;
                  if(tipe=="tir")
                  	signal(father,s_kill);
                  	return;
                  end
                END
               //-----------------------------------------------------

               //Vérifie les plateformes mobiles pour voir si le perso peut bouger verticalement
               /* WHILE(id2=get_id(TYPE plateforme_mobile))
                  IF(map_get_pixel(0,id2.graph,father.x+fromto-id2.x+graphic_info(0,id2.graph,g_center_x),father.y-id2.y+graphic_info(0,id2.graph,g_center_y)+yi*app)==36)
                    ok=0;
                  END
                END  */
               //---------------------------------------------------------------------
               FRAME 0;
             END

             IF(ok) //Si le perso peut bouger verticalement avec y (pas d'obstacle)
               father.y+=yi;  //Le perso avance avec y   
               if(app==1)
              		father._saute=0;   
               end
             ELSE
             	if(app==1)     // si on touche le sol
             		father._saute=1;
             	end   
             END 
             yi[1]-=yi;  //yi[1] s'approche du zéro (voir le WHILE)
           END



           //Regarde toutes les plateformes mobiles pour voir si le perso n'est pas dessus
           /* WHILE(id2=get_id(TYPE plateforme_mobile))
              FOR(fromto=-father.taillex+1;fromto<=father.taillex-1;fromto++)
                IF(father.y_speed=>0)
                   SWITCH(map_get_pixel(0,id2.graph,father.x+fromto-id2.x+graphic_info(0,id2.graph,g_center_x),father.y-id2.y+graphic_info(0,id2.graph,g_center_y)+1))
                    CASE 36:
                     id2.ok=1;father.xi[1]=id2;father.y_speed=0;BREAK;
                    END
                   END
                ELSE
                   SWITCH(map_get_pixel(0,id2.graph,father.x+fromto-id2.x+graphic_info(0,id2.graph,g_center_x),father.y-id2.y+graphic_info(0,id2.graph,g_center_y)+app*yi))
                    CASE 36:father.y_speed=-father.y_speed/2;yi[1]=0;END
                   END
                END
              END
            END  */
           //-----------------------------------------------------------------------------
          FRAME 0;
       UNTIL((xi[1]==0 AND yi[1]==0))
      //----------------------------------------------
      
      // ------ rebond ------
      if(tipe == "balle")
         if(x1>1) // si il y a eu collision avec un mur horizontale
            father.y_speed = -(father.y_speed*(father.elasticite));
            elseif(father.y_speed == 0 && father.x_speed<>0 && father.elasticite<1) father.x_speed-=xi; // ralenti sa vitesse a cause du frotements
         end
         if(y1>1) // si il y a eu collision avec un mur verticale
            father.x_speed = -(father.x_speed*(father.elasticite));
         end

      end
      // --------------------
      
      if(!exists(angle1)) return; end
      
      FRAME;
    END
END 

/*function smap_get_pixel(file,map,x,y)    // map get pixel special pour le jeu
begin
 
 	if(COULEUR_COLLISION==-1)
 		return (map_get_pixel(file,map,x,y)!=0);   
 	else
 		return (map_get_pixel(file,map,x,y)==COULEUR_COLLISION);
 	end
	
end      */
