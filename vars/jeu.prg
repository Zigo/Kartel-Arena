
#define place_joueur(atf2) envoie_message(11,atf2,0,0)

process game_init(); // initialise le jeu MOUHAHAHA
begin       
   
   gmode=EN_JEU;
   
	fade_off();   
	                
   signal(type fleche,s_kill);       
   signal(type affiche_lobby,s_kill);          
   
   // -------- DECHARGEMENTS DES TRUCS ------------
   // ---- FPGs ---
   unload_fpg(FPG_menu); FPG_menu=-1;
   // ---- FNTs ---
   unload_fnt(FNT_titre); FNT_titre=-1;
   //unload_fnt(FNT_menu); FNT_menu=-1;  
   unload_fnt(FNT_menu_stat); FNT_menu_stat=-1;
   // ---------------------------------------------
                         
	// --------- CHARGEMENTS DES TRUCS -------------
	FPG_jeu=load_fpg("fpg\jeu.fpg");  // graph du jeu
	FPG_armes=load_fpg("fpg\armes.fpg");  // graph des armes    
	//FPG_persos=load_fpg("fpg\persos.fpg"); // contien les personages    
	//FNT_321go = LOAD_TTFAA("fnt\menu.ttf" ,60,16,rgb(0,0,0),rgb(255,255,255));
	FNT_321go = LOAD_FNT("fnt\FNT_321go.fnt");
	FNT_life  = LOAD_TTFAA("fnt\life.ttf" ,36,1,0,0);         
	load_arene(MAPCHOISIS);      // charge la map   
	// ---------------------------------------------
	                         
	// --------- APPARITION DES JOUEURS ------------
	from fto=1 to nb_joueurs;
		id_joueurs[fto] = soldat(fto);  
		// --------------- MUNITIONS -------------------   
		infos_JOUEURS[fto].munition[0]=donnees_armes[ARMES_CHOISIS[1]].munition_depart; // plein de munition pour l'arme de depart
		// ---------------------------------------------
	end        
	// --------------------------------------------- 
	                          
	// ---------- SCROLL ET INTERFACE --------------
	scroll_camera(id_joueurs[joueur_num]);		  // camera suit seulement notre persos   
	interface();          							  // process qui s'occupe de faire bouger notre perso 
	interface_graphique();				// le cadre blanc avec les points de vie     
	objet_mini_arme(1,0);     	  // mini_arme de départ
	// ---------------------------------------------           
	
	place_joueur(joueur_num);           // place son joueur au hasard sur la map   
	                      
	/*objet_muniton(OBJET_ARME,3,20,800,50,0,0,0,0);
	objet_muniton(OBJET_ARME,4,20,750,50,0,0,0,0);
	objet_muniton(OBJET_ARME,1,20,650,50,0,0,0,0); */
	
	// ------------------ OBJETS --------------------
	from fto=1 to NB_RESP_OBJ;          // (type,lequel,combien,x,y,z,angle,flags,attente)
		objet_muniton(OBJET_BONUS,MAP_OBJETS[fto].arm,0,MAP_OBJETS[fto].x,MAP_OBJETS[fto].y,0,0,0,-1); 
	end 
	from fto=1 to NB_RESP_ARM;	// (type,lequel,combien,x,y,z,angle,flags,attente)
	   objet_muniton(OBJET_ARME,MAP_ARMES[fto].arm,donnees_armes[ARMES_CHOISIS[MAP_ARMES[fto].arm]].munition_depart,MAP_ARMES[fto].x,MAP_ARMES[fto].y,0,0,0,-1);
	end   
	// ----------------------------------------------
	            
	fade_on();   
	
	// ----- LIMITE DE LA PARTIE
	if(limite_mode==0)		// si une limite de temps 
		while(timer>100)frame;end	// atten qq secondes (sinon bug avec timer)  
		atf=6000;     
		repeat
			if(timer>(6000*limite.val[limite_mode][limite_mode[1]]-atf) && atf>0) // ...sec left  
				ecran_message("Plus que "+atf/100+" secondes",1000);
				switch(atf)
					case 6000: atf=3000; end
					case 3000: atf=1000; end
					case 1000: atf=-5; end
				end
			end   
			if(timer>(6000*limite.val[limite_mode][limite_mode[1]]-500) && atf<0) // 5,4,3,2,1 0
				ecran_message(itoa(-atf),800);
				atf++;
			end
			frame(nb_fps*100);   // s'actualise toute les secondes
		until(timer>6000*limite.val[limite_mode][limite_mode[1]]); 
		if(leader==1)  
			envoie_message(10,42,42,42);
		end
	end
	// ------------------------- 
	
	loop frame; end            // maintien car utile pour tuer tous el monde avec s_kill_tree
	      
end  
       
// process qui finit une partie       
process game_end()
begin
  
   mouse.graph=0; x=rand(ECRAN_tx/4,3*ECRAN_tx/4);y=rand(ECRAN_ty/4,3*ECRAN_ty/4);
	graph=get_screen(); set_center(0,graph,x,y);z=-200;  
	//---------- 
	gmode=EN_LOBBY;
	//----------
	//let_me_alone();  
	signal(type chat,s_kill_tree);
	signal(type game_init,s_kill_tree);
	signal(type objet_mini_arme,s_kill_tree); 
	signal(type objet_muniton,s_kill);  
	// ---------                  
	clear_screen();
	stop_scroll(0);from fto=0 to (NB_SCROLL-1) step 2;fto2++;stop_scroll(fto2);end    
	//----------
	ecran_message("Partie terminé",5000);
	
	frame(nb_fps*100);	// attend 1sec
	 
	blendop=blendop_new();
	while(fading or atf3<30)
	   blendop_intensity(blendop,1.1);
	   blendop_assign(0,graph,blendop);
		//blur(0,graph,0); 
		atf3+=1;  
		if(!fading && atf3>15)fade(0,0,0,4);end
		size+=10;angle+=1500;
		frame;
	end blendop_free(blendop);            
	fade_on();
	
	write(FNT_menu,ECRAN_tx/2,ECRAN_ty/3,4,"Scores");
	signal(type ecran_message,s_kill);
	unload_map(0,graph); 
	x=affiche_score();put(x.file,x.graph,x.x,x.y);signal(x,s_sleep); 
	// -- Stats profil -- 
	JOUEUR_PROFIL.nb_parties++;
	JOUEUR_PROFIL.precision=JOUEUR_PROFIL.nb_touchés*100/(JOUEUR_PROFIL.nb_balle+(JOUEUR_PROFIL.nb_balle==0)); 
	save("profils\"+fichier[profil_charge],JOUEUR_PROFIL);
	// ----------
	y=text_height(FNT_chat,"Ijb")*1.5;
	x=ECRAN_tx/2;
   write(FNT_chat,x,ECRAN_ty*3/4+y,4,"Nombre total de parties joués: "+JOUEUR_PROFIL.nb_parties);
   write(FNT_chat,x,ECRAN_ty*3/4+2*y,4,"Nombre total de mecs tués: "+JOUEUR_PROFIL.nb_tuer);
   write(FNT_chat,x,ECRAN_ty*3/4+3*y,4,"Nombre total de décès: "+JOUEUR_PROFIL.nb_mort);        
   write(FNT_chat,x,ECRAN_ty*3/4+4*y,4,"Nombre total de balles tirés: "+JOUEUR_PROFIL.nb_balle); 
   write(FNT_chat,x,ECRAN_ty*3/4+5*y,4,"Precision total: "+JOUEUR_PROFIL.precision+" %");
	// ------------------
	
	//---------- libere la mémoire
	unload_fpg(FPG_MAP);
	unload_fpg(FPG_jeu);
	unload_fpg(FPG_armes);  
	FPG_MAP=FPG_jeu=FPG_armes=-1;
	unload_fnt(FNT_321go);
	unload_fnt(FNT_life); 
	FNT_321go=FNT_life=-1;
	if(FPG_COL!=0) unload_fpg(FPG_COL); else unload_map(FPG_COL,MAP_COLLISION); end
	//---------- 
	FPG_menu = load_fpg("fpg\menu.fpg"); 
	FNT_menu_stat = LOAD_TTFAA("fnt\menu_stat.ttf" ,15,16,rgb(190,190,220),0);     
	FNT_titre = LOAD_TTFAA("fnt\titre.ttf",65,16,/*rgb(0,0,200)*//*rgb(94,0,193)*/rgb(30,139,0),0);
	//----------  
	mouse.file = FPG_menu;
   mouse.graph=1; 
   
   z=bouton(FNT_menu,ECRAN_tx/2,ECRAN_ty/4,-99,"Retour");
	
	while(exists(z)); frame; end

   signal(type affiche_score,s_kill);
            
   delete_text(all_text);  
                     
   if(leader==1) serveur(); end   
            
   menu_actuel = 8;
   affiche_menu();      
   fade_off();   // effet de fondu
   fade_on();

end

process interface_graphique()           // INTERFACE graphique  
begin 
              
   file=FPG_jeu;      
   graph=1;
   set_center(file,graph,0,0);
   alpha=100; 
   
   atf2=1;  
   
   get_point(file,graph,1,&x1,&y1);	// l'ecriture des munitions

   loop 
   
   // --- AFFICHAGE VIE ---  
   atf3=infos_JOUEURS[joueur_num].vie; if(atf3<0) atf3=0; end        // evite la vie négative
   objet(55+58,736,z-1,file,write_in_map(FNT_life,atf3+"%",4),0,100,100,0,0,250,1);
   // ---------------------  
   atf+=3*atf2; if(atf>=200 or atf<=0) atf2*=-1; end      // changement de couleur des points de vie (je sais c inutile mais c fun)
   set_text_color(rgb(240,atf,atf));  
   
   // --- AFFICHAGE ARMES ---
   objet(x1-CORRIGE_PLACE_MA,y1,z-1,file,write_in_map(FNT_life,get_joueur_munition_arme(joueur_num,-1),3),0,100,100,0,0,250,1); 
   // -----------------------
   
   	frame(frame_timeu);            
   end
end

process interface()           // INTERFACE UTILISATEUR<->PERSOS + affichage score 
private ide[4];
begin 
   
	loop                    
	
		if(key(_a))  						  // bouger a gauche (1)
			if(_bouge_gauche == false)
				_bouge_gauche=true;
				ide[0]=key_press(_a,1);	
			else
				if(!exists(ide[0])) _bouge_gauche=false; end
			end
		end

		if(key(_d))   						 // bouger a droite  (2)
			if(_bouge_droite == false)
				_bouge_droite=true;
				ide[1]=key_press(_d,2);	
			else
				if(!exists(ide[1])) _bouge_droite=false; end
			end
		end
         
		if(key(_space))   						 // sauter (3)  
			if(_saute == false)
				_saute=true;
				ide[2]=key_press(_space,3);	
			else
				if(!exists(ide[2])) _saute=false; end	
			end
		end
	                             
		if(key(_s))   						 // se baisser (4)  
			if(_baisse_toi == false)
				_baisse_toi=true;
				ide[3]=key_press(_s,4);	
			else
				if(!exists(ide[3])) _baisse_toi=false; end	
			end
		end  
		
		if(mouse.left)   						 // tirer (5)  
			if(_tire == false)
				_tire=true;
				ide[4]=mouse_press(&mouse.left,5);	
			else
				if(!exists(ide[4])) _tire=false; end	
			end
		end
 
		// -----  
		
		if(mouse.wheelup xor mouse.wheeldown)   						 // changer arme 
		  atf=infos_JOUEURS[joueur_num].arme_en_cour+mouse.wheelup-mouse.wheeldown;
			if(atf>=0 && atf<DONNEE_nb_max_armes)                // si on a une arme
				if(infos_JOUEURS[joueur_num].arme_en_stock[atf]!=0)  
      			envoie_message(22,joueur_num,atf,0);	
      		end 
      	end
		end
		
	//	str = "1" + itoa(_bouge_gauche) + itoa(_bouge_droite) + itoa(_saute) + itoa(_baisse_toi) + itoa(_tire);                     
		
		/*if(str!="100000")                                         // si il s'est passé quelquechose
	   	envoie_message(15,joueur_num,atoi(str),0);      // on fait tous passer dans le meme message
	   end */  
	   
	   // ------- AFFICHAGE DU SCORE ------- 
	   signal(type affiche_score,s_kill);
	   if(key(_tab)) // si on appuie sur tab					 
	   	affiche_score();
		end
	   // ----------------------------------
	   
		frame(frame_timeu);
	end
end

process objet_mini_arme(atf,atf3)	// (arme,place)
begin

	get_point(FPG_jeu,1,1,&x,&y);
	get_point(FPG_jeu,1,2,&x1,&y1);
	
	file=FPG_armes;   
	graph=ARMES_CHOISIS[atf]*10+1;
	z=-5;  
	
	atf2=fget_dist(x,y,x1,y1);
	//nct04=fget_angle(x1,y1,x,y); 
	//x1+=get_distx(angle1,atf2/2);
	//y1+=get_disty(angle1,atf2/2);
	
	angle=infos_JOUEURS[joueur_num].arme_en_cour*30000-45000-atf3*30000;      
   
             
	loop
	   
	   angle1=infos_JOUEURS[joueur_num].arme_en_cour*30000-45000-atf3*30000;
	  	angle=near_angle(angle,angle1,4500);
	  	x=x1+CORRIGE_PLACE_MA+get_distx(angle,atf2*2/3);
	  	y=y1-CORRIGE_PLACE_MA+get_disty(angle,atf2*2/3);
	  	// --- Alpha --- 
	  	fto=angle-360000*(angle>180000); if(fto>0) fto2=1; else fto2=-1; end
	  	nct01=255-2*(fto2*45000-fto)/500;
	  	nct02-=1*(nct02>0);                                                  
	  	if(infos_JOUEURS[joueur_num].arme_en_cour!=atf3) nct03=0; else nct03=255; end
	  	if(mouse.wheelup or mouse.wheeldown or nct02>0) 
	  		alpha=near_angle(alpha,nct01,15); 
	  		if(nct02==0) nct02=9; end
	  	else 
	  		alpha=near_angle(alpha,nct03,15);
	  	end            
	  	// --------------
		
		sx=angle;
		angle=sx+45000;	
		frame(frame_timeu);  
		angle=sx;
	end    
end

process affiche_score()		// affiche le score poupé  
private
	textes[7];
begin

	file=FPG_jeu; 
	graph=4;
	alpha=170;
	z=text_z+1;  
	
	x = ECRAN_tx/2;   // centré horizontalement
   y = ECRAN_ty/2;   // centré verticalement   
          
   from fto=1 to nb_joueurs;
   	get_real_point(fto,&x1,&y1);
   	textes[fto-1]=write(FNT_menu,x1,y1,0,infos_JOUEURS[fto].pseudo);   
   	get_real_point(4+fto,&x1,&y1);
   	textes[3+fto]=write(FNT_menu,x1,y1,2,infos_JOUEURS[fto].score);
   end   
   
   frame(frame_timeu);

OnExit
	from fto=1 to nb_joueurs;
   	delete_text(textes[fto-1]);delete_text(textes[3+fto]);
   end
end                

process mouse_press(pointer touche,int dir)
begin       
	str=itoa(joueur_num)+itoa(dir)+itoa(1);
   envoie_message(15,str,id_joueurs[joueur_num].x,id_joueurs[joueur_num].y);
	while(*touche == true)
		frame;
	end    
	str=itoa(joueur_num)+itoa(dir)+itoa(0);
	envoie_message(15,str,id_joueurs[joueur_num].x,id_joueurs[joueur_num].y);
end

process key_press(int touche,int dir)
begin       
	str=itoa(joueur_num)+itoa(dir)+itoa(1);
   envoie_message(15,str,id_joueurs[joueur_num].x,id_joueurs[joueur_num].y);
	while(key(touche))
		frame;
	end    
	str=itoa(joueur_num)+itoa(dir)+itoa(0);
	envoie_message(15,str,id_joueurs[joueur_num].x,id_joueurs[joueur_num].y);
end

process scroll_camera(id_a_suivre)    // ce qui dirige la caméra du scroll
private
	tremble;
begin  

	ctype=c_scroll;
	scroll[0].camera=id;
	
	viseur();      

	loop  
	
	//xadvance(fget_angle(x,y,father.x,father.y),fget_dist(x,y,father.x,father.y)/10);

	x=(id_a_suivre.x+scroll.x0+mouse.x)/2;                // caméra
	y=(id_a_suivre.y+scroll.y0+mouse.y)/2; 
	/*x=(id_a_suivre.x+infos_JOUEURS[id_a_suivre].coord_mouse.x)/2;                // caméra
	y=(id_a_suivre.y+infos_JOUEURS[id_a_suivre].coord_mouse.y)/2;
   */
   // -----------------------
	if(choc_ecran)tremble=20;choc_ecran=0;end             // fait trembler l'écran
	if(tremble>0)tremble--;end 
	x+=rand(tremble,-tremble)/2;   
	y+=rand(tremble,-tremble)/2; 
	// -----------------------  
	
		frame;
	end
end  

process viseur();
begin
   
   mouse.file=FPG_armes;     
	//mouse.flags=4;                 
	                                         
	loop
	   
	   mouse.angle+=donnees_armes[get_joueur_arme(joueur_num)].viseur_tourne/2;  // divisé par 2 parce que frame(50)            
	   mouse.graph=donnees_armes[get_joueur_arme(joueur_num)].graph_viseur;
		mouse.size =donnees_armes[get_joueur_arme(joueur_num)].viseur_size; 
	   
	   if(infos_JOUEURS[joueur_num].coord_mouse.x<>mouse.x+scroll.x0 or infos_JOUEURS[joueur_num].coord_mouse.y<>mouse.y+scroll.y0)    // ACTUALISATION DES COORDONNEES   
			
			envoie_message(16,joueur_num,mouse.x+scroll.x0,mouse.y+scroll.y0);    
			
			infos_JOUEURS[joueur_num].coord_mouse.x=mouse.x+scroll.x0;
         infos_JOUEURS[joueur_num].coord_mouse.y=mouse.y+scroll.y0;
		end
	
		frame(50); //(frame_timeu)
	end
end 

// PLACE UN JOUEUR DANS LA PARTIE LA OU IL Y A LE MOINS DE JOUEURS  
/*process place_joueur(atf2);  // atf2=id du joueur a placer
begin	          
	envoie_message(11,atf2,0,0);

end*/
  
process place_joueur2(atf2,*ax,*ay);  // atf2=id du joueur a placer  
begin     
	// cherche un pts de respawn le plus perdu possible
	nct01=999; 
	from fto=1 to NB_RESPAWNS;   
		nct02=nb_joueur_alentour(MAP_RESPAWNS[fto].x,MAP_RESPAWNS[fto].y,DONNEE_distance_zone_apparition);
		if(nct01>nct02)
			nct01=nct02; 
			atf=fto;
		else	
			fto2++;
		end
	end         
	//say(fto2);say(NB_RESPAWNS);say(atf);
	if(fto2>=NB_RESPAWNS) atf=rand(1,NB_RESPAWNS); end		// si on peut prendre nimporte lequel on prend au pif
	*ax=MAP_RESPAWNS[atf].x;
	*ay=MAP_RESPAWNS[atf].y-DONNEE_hauteur_perso;
end      

// renvoie le nb de joueurs aux alentour d'un points dans un carré de taille donnée (les coordonée=centre du carré,atf=taille cotés)
function int nb_joueur_alentour(x,y,atf)   // atf=taille du carré
begin
   x-=atf/2;y-=atf/2;
   x1=x+atf;y1=y+atf;
   atf2=0;  
   from fto=1 to nb_joueurs;
   	if(id_joueurs[fto].x>x && id_joueurs[fto].x<x1
   	&& id_joueurs[fto].y>y && id_joueurs[fto].y<y1) atf2++; end
   end
	return atf2;
end
                   
// ------------------------------

process Soldat(numero_de_joueur);
private
    
   saut;  
   timesol;    
   choc_saut;    
   croupis;
   //vit1;  

Begin  

	// utilisé: atf,atf2,atf3
	// y_speed, elasticite
	
	file=FPG_persos;
	     
	graph=10*infos_JOUEURS[numero_de_joueur].perso+2;        // graph 2 (buste)
	
	ctype=c_scroll;              
	cnumber=c_0;		// il n'est que dans le scroll principale  
	
	nct01=numero_de_joueur; // on utlise une locale pour sauvegarder son numero de joueur comme ça c recuperable par dautre process
   
   priority=5;
   
	// --------------  
	/*tailx = DONNEE_largeur_perso/2;
	taily = DONNEE_hauteur_perso;*/
	//set_center(file,graph,tailx,taily/2);    
	//elasticite=0;    
	//super_moteur_col(tailx,taily);
	//moteur_collision("persos"); 
	// CORRIGE LE PROBLEME DE HAUTEUR DE JAMBES
	if(graphic_info(file,graph,G_HEIGHT)/2==graphic_info(file,graph,G_CENTER_Y)
	or graphic_info(file,graph,G_HEIGHT)/2+1==graphic_info(file,graph,G_CENTER_Y)
	or graphic_info(file,graph,G_HEIGHT)/2-1==graphic_info(file,graph,G_CENTER_Y))    
	   //say("cx: "+itoa(graphic_info(file,graph,G_CENTER_X)+CORRIGE_HAUTEUR_PERSOS/2));  
		//say("cy: "+itoa(graphic_info(file,graph,G_CENTER_Y)-CORRIGE_HAUTEUR_PERSOS)); 
		//set_center(file,graph,graphic_info(file,graph,G_CENTER_X)+CORRIGE_HAUTEUR_PERSOS/2,graphic_info(file,graph,G_CENTER_Y)-CORRIGE_HAUTEUR_PERSOS); 
		get_point(file,graph,1,&nct02,&nct03);
		set_center(file,graph,nct02,nct03); 
	end 
	// --------------   
	
	// ---- CORP ---- 
	atf=atoi(map_name(file,graph+2));
	nct02=bras_tete(numero_de_joueur);      
	nct03=jambes(-atf,0);   // -6,0 
	nct04=jambes(atf,0);   // 6,0 
	atf=0;
	//hauteur_jambes=50; 
	// --------------   
	
	//write_int(0,800,600+10*numero_de_joueur,4,&flags);
              
	loop
      
      /*if(key(_space))     
      	infos_JOUEURS[numero_de_joueur].vie=0;
      	signal(type tue_ressucite_perso,s_kill);
      	//mort_du_perso(numero_de_joueur,1,1); 
      	tue_ressucite_perso(numero_de_joueur,1,ZTETE,50);
      end  
      if(key(_c))     
      	infos_JOUEURS[numero_de_joueur].vie=0;
      	signal(type tue_ressucite_perso,s_kill);
      	//mort_du_perso(numero_de_joueur,1,-1);
      	tue_ressucite_perso(numero_de_joueur,-1,ZTETE,50); 
      end  */
      
      // ------ SACROUPIR -----
		hauteur_jambes=-vari_hjambes/5+croupis;    

		if(sol==1) 
		
			if(timesol<0)timesol++;end
			if(_baisse_toi==true or timesol<-17) 
				//_baisse_toi=false;
				if(croupis>30)croupis-=4;end
			else
				if(croupis<50 and map_get_pixel(FPG_COL,MAP_COLLISION,(x+atf3*5),y-70-5+CORRIGE_HAUTEUR_PERSOS)/*==0*/<>COULEUR_COLLISION)croupis+=6; end 
			end 
			
		else 
		
 			if(croupis<50 and map_get_pixel(FPG_COL,MAP_COLLISION,(x+atf3*5),y-70-5+CORRIGE_HAUTEUR_PERSOS)/*==0*/<>COULEUR_COLLISION)croupis+=4; end

    		if(timesol>-20)timesol--; end  
       	choc_saut=timesol;
 
		end 

		if(croupis<20)croupis=20;end
      // -----------------------
      
      // ----- DEPLACEMENTS -----         
      if(x<infos_JOUEURS[numero_de_joueur].coord_mouse.x)flags=0;else flags=2;end  // sens du perso
      
      IF (_bouge_droite==true  AND x_speed<10) 
      	//_bouge_droite=false;
      	//x_speed+=1;
      	x_speed+=1;
      ELSE
      	IF (_bouge_gauche==true  AND x_speed>-10)  
      		//_bouge_gauche=false;
         	x_speed-=1;
      	ELSE
         	IF (x_speed>0)
            	x_speed-=1;
         	END
        		IF (x_speed<0)
            	x_speed+=1;
         	END
         END
     	END
             
      moteur_collision_grew();  
      //x+=vitesse;
      
      //Détecte si le perso touche le sol/plafond ou pas
   	/*ok=1;sol=0;
   	for(fto=-tailx+1;fto<=tailx-1;fto++)
      	if(map_get_pixel(FPG_COL,MAP_COLLISION,x,y-(taily/2))==COULEUR_COLLISION)y_speed=-y_speed/2;end //Si plafond
      	if(map_get_pixel(FPG_COL,MAP_COLLISION,x,y+(taily/2)+1)==COULEUR_COLLISION) //Si sol
         	ok=0;sol=1;
         	if(elasticite==0) y_speed=0; end
      	end
   	end*/  
   	//----------------------------------------

   	//Pour monter une pente
   	/*for(fto=-tailx;fto<=tailx;fto++)
      	if(map_get_pixel(FPG_COL,MAP_COLLISION,x+fto,y+(taily/2))==COULEUR_COLLISION AND map_get_pixel(FPG_COL,MAP_COLLISION,x+fto,y+(taily/2)-1)!=COULEUR_COLLISION)
         	y-=2;ok=0;sol=1;
      	end
   	end*/
   	//------------------------------
    
      // ------- SAUTER ------
		/*if(ok) //S'il ne touche pas le sol
      	if(xi[1]>0) //Mais s'il touche une plateforme mobile
         	if(key(_space)) //Il peut sauter en appuyant sur Espace
            	x_speed+=xi[1].x_speed/2;
            	y_speed=-DONNEE_hauteur_saut+xi[1].y_speed/2;
         	end
      	end
      	y_speed+=1; //La vitesse de la chute augmente
   	ELSE //Mais s'il touche le sol
      	if(_saute==true)             
      		hauteur_jambes-=15;
      		y_speed=-DONNEE_hauteur_saut; 
      	end 
   	end*/                   
   	if(_saute==true)
			//if(saut++==4)    
				saut++;
				if(sol)vit_vit_dep=-DONNEE_hauteur_saut;end
			//end   
			if(saut<6 and sol)hauteur_jambes-=8;end   
		else  
			saut=1;
		end
      // -----------------------
      
      // ---- angle du corp ----  
                          
      // calcul de l'angle     
      if(infos_JOUEURS[numero_de_joueur].vie!=0)      // lorsqu'il meurt
			if(x<=infos_JOUEURS[numero_de_joueur].coord_mouse.x/*+scroll.x0*/ )//or x==infos_JOUEURS[numero_de_joueur].coord_mouse.x/*+scroll.x0*/)
				flags=0;
				angle=fget_angle(infos_JOUEURS[numero_de_joueur].coord_mouse.x/*+scroll.x0*/,infos_JOUEURS[numero_de_joueur].coord_mouse.y/*+scroll.y0*/,x,y)/2-90000+dist_choc*3000;
			   //angle=nct02.nct05/2-90000+dist_choc*3000;  
			else 
				flags=2;
				angle=fget_angle(infos_JOUEURS[numero_de_joueur].coord_mouse.x/*+scroll.x0*/,infos_JOUEURS[numero_de_joueur].coord_mouse.y/*+scroll.y0*/,x,y)/2+180000-dist_choc*3000;
			  // angle=nct02.nct05/2+180000-dist_choc*3000;
			end   
		end
		// ----------------------- 
		 
		 
		// -- Choc d'un tir sur notre perso -- 
		if(angle_touché<>0)  
			/*if(angle_touché>90000 and angle_touché<270000)
				dist_choc=rand(5,8);
				if(rand(0,1)==0)
					x_speed=-rand(5,8); 
				end  
			else
				dist_choc=rand(5,8);
				if(rand(0,1)==0)
					x_speed=rand(5,8); 
				end
			end  */     

			dist_choc=rand(5,8);
			if(rand(0,1)==0)
				x_speed=rand(5,8)*angle_touché; 
			end  
			angle_touché=0;  
		end   
      
      
      // -----------------------------------
      
      // ------------- OBJETS --------------  
      nct05=collision(type objet_muniton); 
      if(nct05>0) fto2=nct05; end  								
      if(fto2>0 && timer[numero_de_joueur]>35 && exists(fto2)) 
      	nct05=fto2;  
         switch(nct05.atf)               // suivant ce que c'est
		   	case OBJET_ARME: 
		   		if((fto2=get_joueur_tel_armes(numero_de_joueur,nct05.atf2))>=0)		// si on a deja l'arme, ne prend que les munitions  
		   		
		   			//recupere_objet(nct05,numero_de_joueur);	
		   			if(numero_de_joueur==joueur_num)
		   			   envoie_message(21,0,numero_de_joueur,nct05.fto);   // 0=recup_objet
		   		   end	
		   		   
		   		elseif(fto == 0)  // si on est pas deja entrain de prendre une arme     
		   			if((fto2=get_joueur_armes_dispo(numero_de_joueur))<DONNEE_nb_max_armes) //si on a assez de place
		   			   fto = 1;                        
		   			   //recupere_arme(nct05,fto2,numero_de_joueur);    
		   			   if(numero_de_joueur==joueur_num)
		   			   	envoie_message(21,atoi("1"+itoa(fto2)),numero_de_joueur,nct05.fto);   // 1=recup_arme
		   			   end  
		   			else
		   				if(numero_de_joueur==joueur_num && !exists(nct05.son))			// Si c'est nous et que l'arme est au sol  
			   				ecran_message("Vous n'avez plus d'emplacement libre",0);
			   				ecran_message("E pour remplacer l'arme actuel par '"+donnees_armes[ARMES_CHOISIS[nct05.atf2]].nom+"'",0); 
			   				if(key(_E)) 
			   					envoie_message(21,2,numero_de_joueur,nct05.fto);
			   				end
			   			end
			   			/*if(str=="1") str=""; 
			   				fto = 1;
			   				recupere_arme(nct05,infos_JOUEURS[numero_de_joueur].arme_en_cour,numero_de_joueur);
			   			end */
		   			end 
		   		end
		   	end
		   	case OBJET_BONUS:  
		   		envoie_message(21,0,numero_de_joueur,nct05.fto);
		   	end   
		   end  
		   fto2=0;   
      end     
      //if(str=="1") str=""; end // pour eviter le bug            
		// -----------------------------------              
		
		// -------- ETATS ----------
		if(elasticite==1) 
			if(joueur_num==numero_de_joueur)
				alpha=128;
			else
				alpha=30;
			end 
			if(timer>=y_speed)  
				y_speed=elasticite=0; 
				alpha=255;
			end    
			nct02.alpha=alpha;    // tete_bras  
			nct02.atf2.alpha=alpha;  // nom du joueur
			nct03.alpha=alpha;nct03.son.alpha=alpha;    // jambe + cuisse
			nct04.alpha=alpha;nct04.son.alpha=alpha;    // jambe + cuisse
		end
		// -------------------------
		
		if(infos_JOUEURS[numero_de_joueur].vie!=0)      // lorsqu'il meurt
			gravitee_grew(0/*hauteur_jambes*/,65,32,1); 
		end
		
		// ---- PLACEMENTS DES MEMBRES
		get_real_point(2,&x1,&y1);	   // tete
		get_real_point(1,&atf,&atf2); // jambes 
		// ---------------------------	

		frame(frame_timeu);   
		
		// --- SI ON JARTE DE L'ECRAN (BUG) ---
		if(x<-100 or y<-160 or x>MW+100 or y>MH+160)
			place_joueur(numero_de_joueur); 
			say("ERREUR: joueur "+numero_de_joueur+" a fait une sortie de map ("+MAPCHOISIS+")");
		end 
		// ------------------------------------
		
	End
End       

process projectile(atf2,x1,y1,angle,atf,vari_hjambes)      // ce qui sort des armes 
private

	bool colision=false;
	float x2,y2; 

begin 
	                      
	sol=get_joueur_arme(father.father.nct01);	// sauvegarde de quel arme il provient pour la securité anti triche poupé
	resolution=100;
	     
	if(atf==-1)                     // mode balle rapide                     
	   ctype=c_scroll;cnumber=c_0;  
	   file=FPG_jeu;graph=3;alpha=0;
      x1*=100; x=x1;
      y1*=100; y=y1;
		loop     
			if(x<0 or y<0 or x>MW*100 or y>MH*100) break; end  // si hors map
			if(rand(0,200)==1) trainee_jaune(atf2,x,y,angle+rand(0,200),fget_dist(x,y,x1,y1)/100*rand(1,3),200,0); end 
			advance(100);
			if(map_get_pixel(FPG_COL,MAP_COLLISION,x/100,y/100)/*<>0*/==COULEUR_COLLISION)   // si on touche un mur
         	break;
         end 
         if(fto=collision(type bras_tete))   
         	fto=fto.father;      
         	if(fto.nct01!=father.father.nct01 && infos_JOUEURS[fto.nct01].vie>0) // si le joueur qui tire ne se tire pas dessus ou que on tire pas un cadavre
	         	if(y<fto.y1*100)                   // si on touche la tete
	         		atf3=ZTETE;
	         	else
	         		atf3=ZCORPS;
	         	end   
	         	colision=true;  
	         	break;   
	         end
         end
         if(fto=collision(type soldat)) 
         	if(fto.nct01!=father.father.nct01 && infos_JOUEURS[fto.nct01].vie>0) // si le joueur qui tire ne se tire pas dessus ou que on tire pas un cadavre
	         	if(y<fto.y1*100)                   // si on touche la tete
	         		atf3=ZTETE;
	         	else
	         		atf3=ZCORPS;
	         	end
	         	colision=true;  
	         	break;   
	         end
         end            
         if(fto=collision(type cuisse)) 
         	fto=fto.father.father;   
         	if(fto.nct01!=father.father.nct01 && infos_JOUEURS[fto.nct01].vie>0) // si le joueur qui tire ne se tire pas dessus ou que on tire pas un cadavre
         		atf3=ZJAMBES;       
         		colision=true;  
         		break;  
         	end
         end   
         if(fto=collision(type jambes)) 
         	fto=fto.father;
         	if(fto.nct01!=father.father.nct01 && infos_JOUEURS[fto.nct01].vie>0) // si le joueur qui tire ne se tire pas dessus ou que on tire pas un cadavre
         		atf3=ZJAMBES;       
         		colision=true;  
         		break;  
         	end
         end  
      	frame(1);
   	end                            
   	trainee_jaune(atf2,x,y,angle,fget_dist(x,y,x1,y1)/100*rand(1,3),200,0);   
      
	end
	if(atf>0)                // mode projectile "lent"
	
		file=FPG_armes;
		graph=atf2;atf2=0;
		ctype=c_scroll;
		cnumber=c_0;
		x=x1*100;y=y1*100; 
		
		//bbox(graphic_info(file,graph,G_WIDTH),graphic_info(file,graph,G_HEIGHT),angle,&tailx,&taily);// dimension "reel"
		//tailx/=2;
		/*tailx=abs(get_distx(angle,graphic_info(file,graph,G_WIDTH))/2);  // dimension "reel"
		taily=abs(get_disty(angle,graphic_info(file,graph,G_HEIGHT)));  */     
		/*tailx=graphic_info(file,graph,G_WIDTH);  // dimension "reel"
		taily=graphic_info(file,graph,G_HEIGHT);  
		set_center(file,graph,0,taily/2);
		moteur_collision("tir");  */
		// say(angle);   say(tailx);say(taily); if(tailx==0) debug; end    
	   
	   switch(vari_hjambes)       // selon le type de tir
		   case 2:   // lazer1 (blaster)  
		   	flags=16;   
		   end
		end
	   
		repeat  
         
         frame;
         
		   //x_speed=get_distx(angle,atf);
		   //y_speed=get_disty(angle,atf); 
		   
		   if(x<0 or y<0 or x>MW*100 or y>MH*100) break; end  // si hors map
		   
		   // ---- DEPLACMENT     
		   from fto2=1 to atf; 
		   	x+=cos(angle)*100.0;
		   	y+=-sin(angle)*100.0;    
			   if(map_get_pixel(FPG_COL,MAP_COLLISION,x/100,y/100)==COULEUR_COLLISION)   // si on touche un mur 
			   	atf2=1;
	         	break;  
	         end           
		   	// ---------------
			   if(fto=collision(type bras_tete))   
	         	fto=fto.father;      
	         	if(fto.nct01!=father.father.nct01 && infos_JOUEURS[fto.nct01].vie>0) // si le joueur qui tire ne se tire pas dessus ou que on tire pas un cadavre
		         	if(y<fto.y1*100)                   // si on touche la tete
		         		atf3=ZTETE;
		         	else
		         		atf3=ZCORPS;
		         	end   
		         	colision=true;  
		         	break;   
		         end
	         end
	         if(fto=collision(type soldat)) 
	         	if(fto.nct01!=father.father.nct01 && infos_JOUEURS[fto.nct01].vie>0) // si le joueur qui tire ne se tire pas dessus ou que on tire pas un cadavre
		         	if(y<fto.y1*100)                   // si on touche la tete
		         		atf3=ZTETE;
		         	else
		         		atf3=ZCORPS;
		         	end
		         	colision=true;  
		         	break;   
		         end
	         end            
	         if(fto=collision(type cuisse)) 
	         	fto=fto.father.father;   
	         	if(fto.nct01!=father.father.nct01 && infos_JOUEURS[fto.nct01].vie>0) // si le joueur qui tire ne se tire pas dessus ou que on tire pas un cadavre
	         		atf3=ZJAMBES;       
	         		colision=true;  
	         		break;  
	         	end
	         end   
	         if(fto=collision(type jambes)) 
	         	fto=fto.father;
	         	if(fto.nct01!=father.father.nct01 && infos_JOUEURS[fto.nct01].vie>0) // si le joueur qui tire ne se tire pas dessus ou que on tire pas un cadavre
	         		atf3=ZJAMBES;       
	         		colision=true;  
	         		break;  
	         	end
	         end         
	      	// ------------
	      end           // end du from    

		until(colision==true or atf2==1) 
		  
	end 
	
	if(colision==true)    		// si collision avec un joueur       
		if(angle>90000 and angle<270000) //sens du tir
      	fto2=-1;//gauche
		else
		   fto2=1;//droite
		end    
		fto.angle_touché=fto2;		// choc du tir
   	if(father.father.nct01==joueur_num && atf3<>0) //si c'est nous qui tirons petit patapons 
   		envoie_message(20,joueur_num+"0"+fto.nct01+"0"+atf3+"0"+sol,donnees_armes[sol].degat_tir,fto2);  // c'est le joueur qui se fait touché qui fait le calcul des dégats en verifiant si le degat envoyé corespond a celui de l'arme pour eviter la triche
   		//say("je (joueur "+joueur_num+") touche joueur "+fto.nct01);
   		/*switch(atf3)
   			case(1):        // TETE
   			   envoie_message(20,joueur_num+"0"+fto.nct01+"0"+atf3,sol*DONNEE_degat_tete,fto2);  
   			end 
   			case(2):        // CORPS
   			   envoie_message(20,joueur_num+"0"+fto.nct01+"0"+atf3,sol*DONNEE_degat_corp,fto2);  
   			end
   			case(3):        // JAMBES
   			   envoie_message(20,joueur_num+"0"+fto.nct01+"0"+atf3,sol,fto2);  
   			end
   		end */
      end 
      // IMPACTS (sang+explosion)
      switch(vari_hjambes)       // selon le type de tir
		   case 1:                          // plasma    
		   	vari_hjambes=rand(0,1)*10;	// 2 explosions différentes pour varier
		   	explosion(FPG_jeu,32+vari_hjambes,41+vari_hjambes,x/100,y/100,z-1,255,16,rand(-360,360)*1000,100,100,c_scroll,c_0);
		   end
		end
      
   else
      
      //IMPACTS
   	switch(vari_hjambes)       // selon le type de tir
		   case 0:                          // balle   
		      explosion(FPG_jeu,26,31,x/100,y/100,z-1,255,16,rand(-360,360)*1000,40,40,c_scroll,c_0);
		   end
		   case 1:                          // plasma
		   	/*explosion(FPG_jeu,20,25,x/100,y/100,z-1,255,16,0,120,120,c_scroll,c_0);
		   	explosion(FPG_jeu,20,25,x/100,y/100,z-1,255,16,0,100,100,c_scroll,c_0);*/      
		   	vari_hjambes=rand(0,1)*10;	// 2 explosions différentes pour varier
		   	explosion(FPG_jeu,32+vari_hjambes,41+vari_hjambes,x/100,y/100,z-1,255,16,rand(-360,360)*1000,100,100,c_scroll,c_0);
		   end
		end       
		
   end   
   
   if(vari_hjambes==2) // blaster lazer
   	explosion(FPG_jeu,32,41,x/100,y/100,z-1,255,16,rand(-360,360)*1000,100,100,c_scroll,c_0);
   	from size_x=100 to 0 step -60;
   		frame;
   	end
   end  
	
ONExit   
  
	if(atf>0)
		frame;
	end  
	 
end

process trainee_jaune(graph,x,y,angle,size_x,size_y,flags)
begin  

	file=FPG_armes;
	ctype=c_scroll;
	cnumber=c_0;  
	resolution=100; 
	loop
		alpha-=50;  
		if(alpha<=0) break; end
   	frame(frame_timeu);
   end
end  

process explosion(file,graph,atf,x,y,z,alpha,flags,angle,size_x,size_y,ctype,cnumber)
begin
	
	from graph=graph to atf;
		frame(frame_timeu);
	end
	
end  
process eclat(file,graph,atf,z,atf3,alpha,size_x,size_y,ctype,cnumber,atf2)
begin    
  
   priority=father.priority-1;  
       
   if(atf>0)            // balles
		//advance(3);   
		/*get_point(father.file,father.graph,atf,&x1,&y1);
		tailx=graphic_info(father.file,father.graph,G_CENTER_X);
		taily=graphic_info(father.file,father.graph,G_CENTER_Y);*/  
		for(alpha=alpha;alpha>0;alpha-=atf)
			//advance(2);
			/*x=x1+father.x-tailx;
			y=y1+father.y-taily;  */  
			if(father.taily==atf2)
				x=father.sx;
				y=father.sy; 
				angle=father.angle;       
				flags=father.flags|atf3; // + le flags voulue
			end   
			frame(frame_timeu);
		end       
	elseif(atf<1)       // plasma 
		atf=-atf;
		for(graph=graph;graph<atf;graph+=1)   
			if(father.taily==atf2)
				x=father.sx;
				y=father.sy; 
				angle=father.angle;       
				flags=father.flags|atf3; // + le flags voulue
			end                    
			frame(frame_timeu);
		end
	end
	
end   
process douille(x,y,z)
begin
	
	if(x-scroll.x0<0 or x-scroll.x0>ECRAN_tx or y-scroll.y0<0 or y-scroll.y0>ECRAN_ty) return; end	// si on le voit pas on se fait pas chier
	
	file=FPG_jeu;
	graph=11;size=80;   
	
	ctype=c_scroll;
	cnumber=c_0;  
	
	if(father.flags==2) atf=1; else atf=-1;  end 
	 
	y_speed=-7;
	x_speed=/*father.father.x_speed*/+rand(4,6)*atf;
	elasticite=0.3+rand(0,2)/10.0; 
	tailx=graphic_info(file,graph,G_WIDTH)/2;
	taily=graphic_info(file,graph,G_HEIGHT);  
	moteur_collision("balle");
	
	angle=rand(0,360)*1000;
	xadvance(father.angle,-15);  // vient du centre de l'arme
	
	sx=-10000*atf;
	        
	repeat   
	   pry=y;
		y_speed++; // gravité  
		angle+=sx; 
		if(son.x1>1) sx+=elasticite*10000*atf; end  
		if(x-scroll.x0<0 or x-scroll.x0>ECRAN_tx or y-scroll.y0<0 or y-scroll.y0>ECRAN_ty) return; end
		frame(frame_timeu);
	until(sx*atf>=0 && y==pry)
   from alpha=255 to 0 step -20;  
   	if(x-scroll.x0<0 or x-scroll.x0>ECRAN_tx or y-scroll.y0<0 or y-scroll.y0>ECRAN_ty) return; end
   	frame(frame_timeu);
   end
end     

function int get_donnees_armes_degat(atf)   // pour loby.prg qui n'a pas acces a arene.prg :s
begin
	return donnees_armes[atf].degat_tir;	
end  
function int get_donnees_armes_nom(atf)   // pour loby.prg qui n'a pas acces a arene.prg :s
begin  
	if(atf<1)  
		father.str=" -- "; 
	else
		father.str=donnees_armes[atf].nom;
	end	
end

// tue puis fait reaparaitre notre perso 
process tue_ressucite_perso(atf,atf2,atf3,fto2)     // (id du joueur,sens du tir,partie du corp touché,degat dans sa gueule)
begin

	// --- LA TOMBEE DU HERO ---
	switch(typedemort(fto2)) // selon l'intensité des dégats
		case 1:      // petit
			mort_du_perso(atf,MORT_GENOU,atf2);
		end
		case 2:      // moyen
		   switch(atf3)     	// selon partie du corps touché
				case ZTETE:
            	if(rand(1,2)==1)
            		mort_du_perso(atf,MORT_GENOU,atf2);
            	else	    
            		mort_du_perso(atf,MORT_TETE_GICLE,atf2);
            	end
				end    
				case ZCORPS:
					mort_du_perso(atf,MORT_TOMBE,atf2);	
				end
				case ZJAMBES:
            	if(rand(1,2)==1)
            		mort_du_perso(atf,MORT_GENOU,atf2);
            	else	    
            		mort_du_perso(atf,MORT_TREBUCHE,atf2);
            	end
				end
			end
		end
		case 3:      // grand
			switch(atf3)     	// selon partie du corps touché
				case ZTETE:
            	mort_du_perso(atf,MORT_TETE_GICLE,atf2);
				end    
				case ZCORPS:
					mort_du_perso(atf,MORT_CORPS_GICLE,atf2);	
				end
				case ZJAMBES:    
            	mort_du_perso(atf,MORT_TREBUCHE,atf2);
				end
			end
		end
	end
	// -------------------------
	
	from fto=0 to DONNEE_nb_max_armes-1;  // enleve et vide les armes
		infos_JOUEURS[atf].arme_en_stock[fto]=0;
		infos_JOUEURS[atf].munition[fto]=0;
	end       
                     
	// ---- Arme de départ ----
	infos_JOUEURS[atf].arme_en_cour = 0;      
   infos_JOUEURS[atf].arme_en_stock[0]=1;   
   infos_JOUEURS[atf].munition[0]=donnees_armes[ARMES_CHOISIS[1]].munition_depart; 
	// ------------------------
   
   if(atf!=joueur_num) return; end  // si c'est notre numéro de joueur       	     
	
	angle1=affiche_score();  //	affiche le score 
	signal(angle1,s_freeze);	// le rend durable baby   
	sol=write(FNT_321go,angle1.x,angle1.y+150,4,"Cliquez pour jouer");
	
   repeat frame; until(!mouse.left)
  
	repeat frame; until(mouse.left) 
         
	delete_text(sol);
	mouse.left=false; 		// pour pas tirer en apparaissant
	signal(type interface,s_wakeup);
	signal(type viseur,s_wakeup);    
	place_joueur(atf);// on le replace et on lui remet de la vie 
	
	// --------- mini_arme -------------
   signal(type objet_mini_arme,s_kill);
   objet_mini_arme(ARMES_CHOISIS[1],0);
   // ---------------------------------                                                         
    
end   

process mort_du_perso(atf,sol,atf3)	// (id du joueur,type de mort,sens)   
begin

	fto=id_joueurs[atf]; 	// fto contient l'id du process soldat du joueur 
	sx=atf;               // sauvegarde l'id dans une autre variable car apres atf est utilisé pour le positionnement des jambes
	
	signal(father,s_sleep);	// stop le processus de reaparition
	
	sol=MORT_TOMBE;			// pas encore d'autre morts ^^ (penser a l'enlever)
	
	switch(sol)
		case MORT_TOMBE/*,MORT_TREBUCHE*/:                // MORT TOMBE
			// -------- ENDORT LES ANCIENS --------
			signal(fto,s_sleep);            // buste
			signal(fto.nct02,s_sleep_tree); // tete_bras
			signal(fto.nct03,s_sleep_tree); // jambes
			signal(fto.nct04,s_sleep_tree);
			//objet4(x,y,z,file,graph,region,size_x,size_y,angle,flags,alpha,ctype,cnumber); 
		   if(atf==joueur_num)
				signal(type interface,s_sleep);
				signal(type viseur,s_sleep);
		   end      
         // ---- COPIE DES ELEMENT DU CORPS ----
         file=fto.file;graph=fto.graph;x=fto.x;y=fto.y;z=fto.z;angle=fto.angle;flags=fto.flags;ctype=c_scroll;cnumber=c_0;   // copie du buste
			//nct01=objet4(fto.x,fto.y,fto.z,fto.file,,fto.region,fto.size_x,fto.size_y,fto.angle,fto.flags,fto.alpha,fto.ctype,fto.cnumber); // BUSTE
			//nct03=objet4(fto.nct03.x,fto.nct03.y,fto.nct03.z,fto.nct03.file,fto.nct03.graph,fto.nct03.region,fto.nct03.size_x,fto.nct03.size_y,fto.nct03.angle,fto.nct03.flags,fto.nct03.alpha,fto.nct03.ctype,fto.nct03.cnumber); // JAMBE
         //nct04=objet4(fto.nct04.x,fto.nct04.y,fto.nct04.z,fto.nct04.file,fto.nct04.graph,fto.nct04.region,fto.nct04.size_x,fto.nct04.size_y,fto.nct04.angle,fto.nct04.flags,fto.nct04.alpha,fto.nct04.ctype,fto.nct04.cnumber); // JAMBE
         nct03=jambes_tombe(fto.nct03); // copie des jambes
         nct04=jambes_tombe(fto.nct04); 
         // ---- ARME QUI TOMBE ----  
         get_point(0,fto.nct02.graph,1,&x1,&y1); 
         get_point(0,fto.nct02.graph,0,&prx,&pry);
         objet_muniton(OBJET_ARME,infos_JOUEURS[sx].arme_en_stock[infos_JOUEURS[sx].arme_en_cour],get_joueur_munition_arme(sx,-1),fto.nct02.x+x1-prx,fto.nct02.y+y1-pry,fto.nct02.z-1,fto.nct02.angle,fto.nct02.flags,0);
         // ------------------------
         
         signal(type douille,s_wakeup);     // pour eviter le bg des douilles qui disparaissent ^^ 
     
         vit_vit_dep=2700; 	
         dist_choc=15;			// vitesse angle
			 
			
			/*write_int(0,0,20,0,&angle);    
			say("SENS:"+atf3);
			say("FLAGS="+flags);
			say("ANGLE:"+angle); */ 
			
			sy=moteur_collision("");
			y_speed=6;
			x_speed=15*atf3;  
			tailx=10;
			taily=10; 
			timer[sx]=0;    //say("sx=1"); 
			angle1=fto.nct02.angle;
			repeat 
			   
			   pry=y;			// y précedant
			   
			   angle1-=vit_vit_dep*atf3;       // on tombe
				angle-=vit_vit_dep*atf3;          
				nct03.angle-=vit_vit_dep*atf3;
				nct04.angle-=vit_vit_dep*atf3;
			    
		      if(atf3<0)                            // different suivant le sens du perso et du tir
			     /* if(angle>-30000)
				   	vit_vit_dep=0;	   
				   end  */   
				   if(flags==0)   
				   	if(vit_vit_dep==2700) vit_vit_dep=abs(75000-angle)/dist_choc; end
			   		if(angle>75000)       // OK
					   	vit_vit_dep=0;  
					   end   
					else      
						if(vit_vit_dep==2700) vit_vit_dep=abs(240000-angle)/dist_choc; end
						if(angle>240000)      // OK 
							vit_vit_dep=0;
						end
					end
		   	else   
		   		if(flags==0)    
		   			if(vit_vit_dep==2700) vit_vit_dep=abs(55000-angle)/dist_choc; end
			   		if(angle<-55000)      // OK
					   	vit_vit_dep=0;	   
					   end   
					else        
						if(vit_vit_dep==2700) vit_vit_dep=abs(73000-angle)/dist_choc; end
						if(angle<73000)       // OK
							vit_vit_dep=0;
						end
					end
		   	end 
		   	if(x_speed>0) x_speed--; end
		   	if(x_speed<0) x_speed++; end
		      
		      get_real_point(1,&atf,&atf2);	   // jambes
		    	get_real_point(2,&x1,&y1);	   // tete  
		    	objet3(x1,y1,fto.nct02.z,file,/*map_clone(fto.nct02.file,fto.nct02.graph)*/graph-1,0,100,100,angle1,flags,255,c_scroll,c_0,0); // BRAS TETE   
		    	  
		    	if(timer[sx]>100)            // evite les chutes interminable
		    		timer[sx]=-50000;
		    		signal(father,s_wakeup);  
		    	end
		    	
		   	frame(frame_timeu);
		   until(x_speed==0 && pry==y && vit_vit_dep==0) //say("sx=2 "+sx);   // si immobile  
		   signal(father,s_wakeup);
		   timer[sx]=0;
		   repeat        
		   	get_real_point(1,&atf,&atf2);	   // jambes
		    	get_real_point(2,&x1,&y1);	   // tete 
		   	objet3(x1,y1,fto.nct02.z,file,/*map_clone(fto.nct02.file,fto.nct02.graph)*/graph-1,0,100,100,angle1,flags,255,c_scroll,c_0,0); // BRAS TETE   
		   	frame(frame_timeu);
		   until(timer[sx]>100)        
		   
		   signal(sy,s_kill);        // butte le moteur collision    
		   
		   // bras_tete permanent (immobile) donc objet4
		   nct05=objet4(x1,y1,fto.nct02.z,file,/*map_clone(fto.nct02.file,fto.nct02.graph)*/graph-1,0,100,100,angle1,flags,255,c_scroll,c_0,0); // BRAS TETE   
		      //say("sx=3");
		   repeat           // meurt en disparaissant
				alpha-=5; 
				nct05.alpha=alpha;    // tete_bras
				nct03.alpha=alpha;nct03.son.alpha=alpha;    // jambe + cuisse
				nct04.alpha=alpha;nct04.son.alpha=alpha;    // jambe + cuisse
				frame(DONNEE_vit_disparition_cadavre/*+frame_timeu*/);
			until(alpha<=0) 
			signal(nct05,s_kill);          // detruit bras_tete
			signal(nct03,s_kill_tree);     // detruit les jambes
		   signal(nct04,s_kill_tree);     
		   return;
	      // ---------------------------------------------------
		end    								// end MORT TOMBE
	end      					// end switch

end 

process jambes_tombe(fto)   
begin

	file=fto.file;graph=fto.graph;x=fto.x;y=fto.y;z=fto.z;angle=fto.angle;flags=fto.flags;ctype=fto.ctype;cnumber=fto.cnumber;
	size_x=fto.size_x;size_y=fto.size_y;
	distx_cuisse=fto.distx_cuisse;
	
	cuisse(); 
	
	atf3=father.atf3;
	
	loop 
	  
	  	x+=father.x_speed/2;
	   
	   pos_px=father.atf+distx_cuisse;
		pos_py=father.atf2;
		get_real_point(1,&x1,&y1);
	
		frame(frame_timeu);
	end 
end        

function int typedemort(atf)   
begin
	if(atf<DONNEE_degat_petit)		// petit dégat
		return 1;
	end
	if(atf<DONNEE_degat_moyen)	// moyen degat
	   return 2;
	else	// gros dégat
	   return 3;
	end
end 

process objet_muniton(atf,atf2,atf3,x,y,z,angle,flags,fto2)	// (type,lequel,combien,x,y,z,angle,flags,attente)
begin
                      
   // --- ID de l'objet ---
   fto=nb_objet;
   nb_objet++; 
   // --------------------- 
   prx=x;	//	sauvegarde les coordonées pour reaparaitre
   pry=y;        
   if(fto2>0)   // si en attente    
   	fto2*=fps;
   	frame(fto2);
		fto2=-1;
   end    
   if(fto2==-1)
      // SON APARITION OBJET
   end
   // ---------------------
                    
   switch(atf)
   	case OBJET_ARME: 
   		file=FPG_armes;      
   		graph=ARMES_CHOISIS[atf2]*10+1;
   	end
   	case OBJET_BONUS: 
   		file=FPG_jeu;      
   		graph=100+atf2;  
   	end
   end 
   
   ctype=c_scroll;
   cnumber=c_0; 
   
   //tailx=graphic_info(file,graph,G_WIDTH);
	hauteur_jambes=graphic_info(file,graph,G_HEIGHT)/2-2;     
	//moteur_collision("");    
	//gravitee_grew(dist_sol,dist_plafond,force,resol);
	
	//	------- DECALAGE ------- (pour le moteur collision)      
	/*get_point(file,graph,0,&x1,&y1);
   if(x1!=tailx && y1!=taily/2)
	   x-=x1;y-=y1;
	   set_center(file,graph,tailx,taily/2);   
   end  */
   // ------------------------
	 
                   
	loop           
	
	   gravitee_grew(0,20,32,1); 
	     
	   //if(!_saute) y_speed++; else signal(son,s_kill); end		// gravité sinon butte moteur collision 
	   if(!sol) vit_vit_dep++; end		// gravité 
	   
	   if(sol && atf==OBJET_ARME)        // si touche le sol 
	   	switch(flags)
				case 0:
					angle=near_angle(angle,0-14000,tailx*4000); 
					/*if(angle<>2500)
						get_real_point(1,&x1,&y1);   // bout du canon
						angle1=fget_angle(x,y,x1,y1);
						x+=get_distx(angle1,-2);   // effet "reel"
						y+=get_disty(angle1,2);     
					end   */   
				end 
			   case 2:
			      angle=near_angle(angle,180000+14000,tailx*4000);
			   end
			end
		end

		frame(frame_timeu);
	end   
Onexit
	//set_center(file,graph,x1,y1);
   //if(pouet)say(id);debug;end; 
   if(fto2==-1 && gmode==EN_JEU)	// si on est un objet de la map et que le jeu tourne
		fto2=rand(TEMPS_OBJET-5,TEMPS_OBJET+5)*100;   
		objet_muniton(atf,atf2,atf3,prx,pry,z,0,0,fto2);
	end
end  

// Affiche un message d'info pour le joueur (string message,durée en milisec)
process ecran_message(str,atf)   
begin     
        
   x=DONNEE_X_MESSAGE;y=DONNEE_Y_MESSAGE;
	atf3=write(FNT_chat,x,y+nb_ecran_message*17,4,str); 
	atf2=get_timer();  
	fto=nb_ecran_message; 
	nb_ecran_message++;     
	repeat  
		move_text(atf3,x,y+(fto)*17);
		frame;
	until(get_timer()-atf2>=atf or atf==0) 
Onexit
	delete_text(atf3);  
	nb_ecran_message--; 
	while(atf=get_id(type ecran_message))
		if(atf.fto>fto) atf.fto--; end // si des messages apres nous on les decales hop !
	end
end
    
// donne l'arme a un joueur (id de l'arme,enplacement,num_joueur)
process recupere_arme(atf,atf2,atf3)    
begin
                           
	// ---------------------
	                          
   
   // ----- ANIMATION -----
	//signal(atf.son,s_kill);			// détruit le moteur de collision de l'arme
	signal(atf,s_freeze);         // freeze l'arme par terre pour la deplacer
	    
	if(infos_JOUEURS[atf3].arme_en_stock[atf2]==0)  // SI EMPLACEMENT LIBRE
	
		angle1=000;   
	
	else															// SI EMPLACEMENT PRIS
	
		angle1=id_joueurs[atf3].nct02.angle-(id_joueurs[atf3].nct02.flags==2)*180000;
	   
	end  	
	                   
	y = fget_dist(atf.x,atf.y,id_joueurs[atf3].nct02.x,id_joueurs[atf3].nct02.y);	// distance entre l'arme et le joueur 
	y/=DONNEE_ARME_VITESS; // vitesse en nb de frames 
	//fto = abs(atf.x-id_joueurs[atf3].nct02.x)+abs(atf.y-id_joueurs[atf3].nct02.y); // 2e distance (par soucis de puissance de calcul)    
	
	repeat     
	   angle = fget_angle(atf.x,atf.y,id_joueurs[atf3].nct02.x,id_joueurs[atf3].nct02.y);	// angle entre l'arme et le joueur 
		atf.x+=get_distx(angle,y); 
		atf.y+=get_disty(angle,y);         
		//fto2=fget_dist(atf.x,atf.y,id_joueurs[atf3].x,id_joueurs[atf3].y);    // on utilise une distance simple a calculer
		fto2=abs(atf.x-id_joueurs[atf3].nct02.x)+abs(atf.y-id_joueurs[atf3].nct02.y);
		//elasticite=((float)(fto-fto2))/((float)fto);   // fait tourner l'arme
		//atf.angle=angle1*elasticite; 
		atf.angle=near_angle(atf.angle,angle1,y*150*DONNEE_ARME_VITESS);  // fois vitesse 
		x++;
		frame(frame_timeu);
	until(fto2<=15 or x>DONNEE_ARME_VITESS+1)  
	
	if(infos_JOUEURS[atf3].arme_en_stock[atf2]!=0)  // SI EMPLACEMENT PRIS	
	   // ancienne arme qui retombe par terre  
	   get_point(0,id_joueurs[atf3].nct02.graph,1,&x1,&y1); 
      get_point(0,id_joueurs[atf3].nct02.graph,0,&prx,&pry);
		objet_muniton(OBJET_ARME,infos_JOUEURS[atf3].arme_en_stock[atf2],get_joueur_munition_arme(atf3,atf2),id_joueurs[atf3].nct02.x+x1-prx,id_joueurs[atf3].nct02.y+y1-pry,id_joueurs[atf3].nct02.z-1,id_joueurs[atf3].nct02.angle,id_joueurs[atf3].nct02.flags,0); 
	   // --- supprime l'ancienne mini arme ---
	   while(angle1=get_id(type objet_mini_arme))
			if(angle1.atf3==atf2) signal(angle1,s_kill); end
		end
	   // -------------------------------------
	end 
	  
	infos_JOUEURS[atf3].arme_en_stock[atf2]=atf.atf2;   // on lui donne l'arme
	infos_JOUEURS[atf3].munition[atf2]=atf.atf3;        // et les munitions    
	
	// --- mini arme ---   
	if(atf3==joueur_num)
		objet_mini_arme(atf.atf2,atf2);
	end
	// -----------------
	
	signal(atf,s_kill);                                 // on détruit l'objet
	
	id_joueurs[atf3].fto=0;										 // on a finit de prendre l'arme                  

end      
                
// (id objet, numero de joueur)        
process recupere_objet(atf,atf2)
begin
	
	if(!exists(atf)) say("ERREUR: objet introuvable"); return; end
	signal(atf.son,s_kill);			// détruit le moteur de collision de l'objet    
	            
	switch(atf.atf)
   	case OBJET_ARME:              // si arme ne prend que les munitions   
   		atf3=get_joueur_tel_armes(atf2,atf.atf2); 
   		if(atf3!=-1) 
   			infos_JOUEURS[atf2].munition[atf3]+=atf.atf3;
   		else say("ERREUR: arme introuvable (munition)");
   		end	
   	end
   	case OBJET_BONUS:
   		switch(atf.atf2)	// suivant le type d'objet
   			case 0: // TROUSSE DE SOIN  
   				infos_JOUEURS[atf2].vie+=50;
   			end
   			case 1: // CAISSE DE MUNITION 
		   		infos_JOUEURS[atf2].munition[infos_JOUEURS[atf2].arme_en_cour]+=50;
   			end 
   			case 2: // INVISIBILITE                     			
		   		id_joueurs[atf2].elasticite=1;              
		   		id_joueurs[atf2].y_speed=timer+TEMPS_INVISIBLE*100; 
   			end 
   		end
   	end
   end   
              
   signal(atf,s_kill);      // tue l'objet
	
end
         /*
function bbox(tailx,taily,angle,*px,*py)  
begin

	if(angle==0 or angle==180000)     *px=tailx; *py=taily; return 1; end
	if(angle==90000 or angle==180000) *px=taily; *py=tailx; return 1; end   
	
	graph=new_map(1,1,1);
	
	prX=-1;prY=-1;        // xmax
	pos_px=tailx+taily+1;pos_py=taily+1+tailx; //xmin
	from fto=0 to 3; 
		switch(fto)
			case 0: set_point(0,graph,99,0,0); end
			case 1: set_point(0,graph,99,tailx,0); end
			case 2: set_point(0,graph,99,tailx,taily); end
			case 3: set_point(0,graph,99,0,taily); end
		end
	   get_real_point(99,&x,&y);
		if(x<pos_px) pos_px=x; end
		if(x>prX)    prX=x;    end
		if(y<pos_py) pos_py=y; end
		if(y>prY)    prY=y;    end
	end
   
   *px=abs(prX-pos_px);
   *py=abs(prY-pos_py);
   unload_map(0,graph); 
   return 1;
   
end        */