
process connection_serveur(atf);  // process qui a pour role d'essayer de se connecter au serveur
begin   

		fade_off();     // efface l'ecran le temps que tout se parametise
      
      fsock_init(0); // Initialise la librairie tcpsock
      
      socket=tcpsock_open();          // ouvre le socket
      fsock_socketset_free(0);
      fsock_socketset_add(0,socket);

      if(tcpsock_connect(socket,ip_serveur,PORT_CONNECTION) <> 0)    // Connection au serveur

            bouton(FNT_menu,ECRAN_tx/2,ECRAN_ty/2,-2,ARC_MENU[menu_actuel].mtexte[0][0]);
            loop frame; end
            
      end
      
      atf2=bouton(FNT_menu,ECRAN_tx/2,ECRAN_ty/2,-2,ARC_MENU[menu_actuel].mtexte[1][0]);     
      
      while(fsock_socketset_check(0,-1,-1,000)<=0) frame; end // Cette ligne de code sert a laisser le temps au serveur d'envoyer le numéro du joueur          
      
      mini_client();      // Process qui reçoi les messages du serveur (très important !!)            

     	if(serveur_est_tu_la==0 && leader==0) // si le serveur est plein
      
     		signal(atf2,s_kill);
     		signal(type mini_client,s_kill);
     		bouton(FNT_menu,ECRAN_tx/2,ECRAN_ty/2,-2,ARC_MENU[menu_actuel].mtexte[3][0]);
         loop frame; end 
      
      end 
      
      fade_on();      
            
      menu_actuel = atf;   // si on réussi
      affiche_menu();      // on affiche le lobby

end 

process affiche_lobby(atf);    // affiche le lobby avec tous les textes ect...
begin      
	
   while(x=get_id(type affiche_lobby)) if(x!=id)return;end end
   
   put_screen(FPG_menu,5);  // fond d'ecran
            
	if(FPG_persos==-1 or !fpg_exists(FPG_persos))FPG_persos=load_fpg("fpg\persos.fpg");end // contient les personages $
	file=FPG_menu; 

	chat();                  // process qui va gerer le chat 
	
	bouton(FNT_menu,ECRAN_tx-80,32,3,"Quitter");   
	
   if(leader==1)
   	//objet(x+10,y+28+100,-9,FPG_menu,4,0,100,100,0,1,150,0);
   	//objet(x+190,y+28+100,-9,FPG_menu,4,0,100,100,0,0,150,0);
   	get_point(file,5,19,&x,&y);	      //map
   	fleche(x+10,y+27+100,-1,2);
   	fleche(x+190,y+27+100,1,2);	
   	get_point(file,5,15,&x,&y);	      //limite
   	fleche(x+180+50,10+y+80+7,-1,4);
   	fleche(x+200+50,10+y+80+7,1,4);    
   	get_point(file,5,14,&x,&y);	      //armes     
   	from fto=0 to 4;
	   	fleche(x-20,y+fto*33+15,-1,10+fto);
	   	fleche(x+190,y+fto*33+15,1,10+fto);  
	   end
   end   
   
   // --- FLECHE POUR CHANGER DE PERSO ---
   get_point(file,5,3+3*(joueur_num-1),&x,&y);
   fleche(x+10,y+50,-1,3);
   fleche(x+90,y+50,1,3);              
   // ------------------------------------    
	  
	while(menu_actuel==atf)  // quitte si on change de menu     
    
      // ------- MAPS -------    
	   get_point(file,5,19,&x,&y);
		objet(x,y,z,0,write_in_map(FNT_menu,ARC_MENU[8].mtexte[1][1],0),0,100,100,0,0,255,1);   
		//get_point(file,5,19,&x,&y);  
		if(substr(MAPCHOISIS,0,7)<>"caca-->" && MAPCHOISIS<>"" && !exists(angle))                                  
			angle=objet2(x+1+100,y+27+100,0,0,super_load_png("Maps\"+MAPCHOISIS+"\apercu.png"),0,100,100,0,0,255,1);   // miniature de la map
		end  
      if(substr(MAPCHOISIS,0,7)=="caca-->")  // SI ON A PAS CETTE MAP
      	if(exists(angle))signal(angle,s_kill);end
         objet(x+100,y+27+95 ,0,0,write_in_map(0,"Vous n'avez pas l'arène:",4),0,100,100,0,0,255,1); 
         objet(x+100,y+27+105,0,0,write_in_map(0,ucase(substr(MAPCHOISIS,7)),4),0,100,100,0,0,255,1);
      end    
      // -------------------- 
             
      // ------ ARMES -------    
	   get_point(file,5,20,&x,&y);
		objet(x,y,z,0,write_in_map(FNT_menu,ARC_MENU[8].mtexte[2][0],0),0,100,100,0,0,255,1);  
		get_point(file,5,14,&x,&y);
		from fto=0 to 4;
			get_donnees_armes_nom(ARMES_CHOISIS[fto+1]);
			objet(x+2,y+fto*33+15,0,0,write_in_map(FNT_chat,str,3),0,100,100,0,0,255,1);
		end 
      // --------------------  
               
      // ------- JOUEURS ------- 
      get_point(file,5,18,&x,&y);
		objet(x,y,0,0,write_in_map(FNT_menu,ARC_MENU[8].mtexte[1][0],0),0,100,100,0,0,255,1);
      fto2=-2;                       
      from fto=1 to nb_joueurs; fto2+=3;  
	   	get_point(file,5,fto2,&x,&y);
			objet(x,y,0,0,write_in_map(FNT_menu,infos_JOUEURS[fto].pseudo,4),0,100,100,0,0,255,1);
         // -- couleurs équipes --
         get_point(file,5,22+fto,&x,&y);
         blendop=new_map(39,39,16); map_clear(0,blendop,couleurs[fto]); set_center(0,blendop,0,0);
         objet(x,y,z,0,blendop,0,100,100,0,0,200,1);    
         // ----------------------
      end   
      // -- Persos des joueurs --
	   if(!exists(type miniperso))  
	      from fto=1 to nb_joueurs;
	         get_point(file,5,3+3*(fto-1),&x,&y);
	         miniperso(fto,x,y);     
	      end 
	   end
      // -----------------------  
                                   
      // ------- INFOS PARTIE ------ 
      get_point(file,5,21,&x,&y);      // titre
		objet(x,y,z,0,write_in_map(FNT_menu,ARC_MENU[8].mtexte[3][0],0),0,100,100,0,0,255,1);   
	   get_point(file,5,15,&x,&y);  
		objet(10+x,10+y,z,0,write_in_map(FNT_menu_stat,ARC_MENU[8].mtexte[0][0]+"("+nb_joueurs+"/"+max_joueur_partie+")",0),0,100,100,0,0,255,1); // nb de joueurs
		objet(10+x,10+y+25,z,0,write_in_map(FNT_menu_stat,ARC_MENU[8].mtexte[0][1]+joueur_num,0),0,100,100,0,0,255,1);                      		// notre numero de joueur
      objet(10+x,10+y+50,z,0,write_in_map(FNT_menu_stat,ARC_MENU[8].mtexte[3][1],0),0,100,100,0,0,255,1);                  				 			// mode de jeu    
	      // ----------------- LIMITE DE LA PARTIE   
	      switch(limite_mode)
	      	case 0: str="min"; end 
	      	case 1: str="pts"; end   
	      end             
	      objet(10+x,10+y+80,z,0,write_in_map(FNT_menu_stat,limite.txt[limite_mode]+": "+limite.val[limite_mode][limite_mode[1]]+" "+str,0),0,100,100,0,0,255,1);        
	      // -------------------------------------
      // ---------------------------     
                     
      // ------- AFFICHAGE CHAT ------   
      get_point(file,5,22,&x,&y);    // titre
		objet(x,y,z,0,write_in_map(FNT_menu,ARC_MENU[8].mtexte[2][1],0),0,100,100,0,0,255,1);
      get_point(file,5,17,&x,&y);  
      if(atf2>=5) //write(0,50,180,0,textee_chat+"_"); 
      	objet(10+x,10+y,z,0,write_in_map(FNT_chat,textee_chat+"_",0),0,100,100,0,0,255,1);
      	if(atf2>=10) atf2=0; end
      else     objet(10+x,10+y,z,0,write_in_map(FNT_chat,textee_chat,0),0,100,100,0,0,255,1); 
      end
      atf2++;  
      from fto=0 to MAX_MSG_CHAT;                // affiche les messages
         get_point(file,5,16,&x,&y);
         objet(10+x,10+y+fto*15,z,0,write_in_map(FNT_chat,substr(mess_chat[fto],1),0),0,100,100,0,0,255,1);
         //write(0,50,120+z*10,0,mess_chat[fto]);
      end 
      // -----------------------------
	            
		frame;
	end 
	
Onexit	

	get_id(type chat).atf=1;	// "endors" le chat
	signal(type miniperso,s_kill);   
	signal(angle,s_kill); // miniature des maps

	map_clear(0,0,0);	// enlève le fond   
	
	if(menu_actuel==3)                               // si on a quitté la partie (bouton quitter)
		signal(type mini_client,s_kill);	// on prévient de notre départ (voir le process)
		while(exists(type mini_client)) frame; end	// attent que le message soit partie
		signal(type chat,s_kill_tree);
		signal(type serveur,s_kill);  
		signal(type mini_serveur,s_kill);    
		// --- Remise a zero des variables ---  
		socket=serveur_est_tu_la=joueur_num=nb_joueurs=mapshoisis2=0;leader=0;
		serveur_NB_MESSAGES=NB_MESSAGES=0;
		MAPCHOISIS="";
		from fto=1 to 4;   
			infos_JOUEURS[fto].pret=false;      
			infos_JOUEURS[fto].pseudo="";
			infos_JOUEURS[fto].perso=1;
			infos_JOUEURS[fto].sock=infos_JOUEURS[fto].arme_en_cour=infos_JOUEURS[fto].score=infos_JOUEURS[fto].nb_de_defeate=0;
		end
		infos_JOUEURS[1].pseudo=JOUEUR_PROFIL.pseudo;
		// ----------------------------------- 
		unload_fpg(FPG_persos);FPG_persos=-1;   
	else
		signal(type bouton,s_kill);
	end

end 

// process pour visualiser un perso
process miniperso(atf,x,y)  // (num_joueur,x,y)
begin
   
   fto=infos_JOUEURS[atf].perso*10+1; 		// le perso du joueur
   get_point(FPG_persos,fto,2,&z,&fto2);
	graph=new_map(graphic_info(FPG_persos,fto,G_WIDTH),fto2,16);
	map_block_copy(FPG_persos,graph,0,0,fto,0,0,graphic_info(FPG_persos,fto,G_WIDTH),fto2,0);
   x+=50;
   y+=50;
	
	z=write(FNT_chat,x,y+48,7,map_name(FPG_persos,fto));
	
	atf2=2;
	loop
	
		size+=atf2;if(size>=110 or size<=90) atf2=-atf2; end
	
		frame;
	end
Onexit	       
	delete_text(z);
   unload_map(0,graph);
end


process charge_maps();               // charge les maps 
begin

	// ------------------- RECUPERE LES DOSSIERS DU REPERTOIRE -------------------------------
	glob(""); // reset glob
	fto=0;
	glob("Maps\*.*");glob("Maps\*.*"); // enleve les deux premiers qui sont les dossiers parents
	repeat                           
	   str = glob("Maps\*.*");                 
		if(str == "." or str=="") break; end 								// si yen a plus (retour au debut) on quitte
		if(verif_map(str,FILEINFO.DIRECTORY)==1)    						// verifie si la map est valide
			Arene_fichiers[fto] = str;        
	 		fto++;
	 	end                          
	until(fto>=(NB_MAX_ARENES-1))  
   // ---------------------------------------------------------------------------------------  
   MAPCHOISIS = Arene_fichiers[0]; 

end    

function int verif_map(string map,int dir)
begin
   if(dir==false /*or len(map)>12*/ or map=="")
   	return -1;
   end              
   if(!file_exists("Maps\"+map+"\apercu.png") or
      !file_exists("Maps\"+map+"\map.png") or
      !file_exists("Maps\"+map+"\config.txt"))
   	return -1;   
   end
   return 1;
end

process chat();     // process qui gere l'envoie de message sur le chat
private

   string mess;

begin
   
   priority = 99;
   
   atf3=texte_input(24,&textee_chat);
   
   x=5;y=5;
   
   loop
   
   	if(atf==0)
	    	// --- ENVOIE DU MESSAGE ---
	    	if(key(_enter))  
	    		atf=gmode;signal(type interface,s_wakeup);     // les touches servent mtn à jouer
	     		if(textee_chat<>"")        // anti flood ^^
	      		mess=textee_chat;
	      		textee_chat="";
	
	      		envoie_message(3,cript_string(Substr(mess,0,4)),cript_string(Substr(mess,4,4)),cript_string(Substr(mess,8,4))); // catégorie 3 (chat) suivit du message séparé en trois parties
	
	      		// Si le message est plus long on envoie le reste
	      		if(len(mess)>12)
	       			envoie_message(3,cript_string(Substr(mess,12,4)),cript_string(Substr(mess,16,4)),cript_string(Substr(mess,20,4))); // catégorie 3 (chat) suivit du message séparé en trois parties
	      		end
	     		end
	    	end
	    	// --------------------------    
		   alpha=255; 
	   else         
	   	if(gmode==EN_JEU)
		   	alpha-=(alpha>180);
		   	signal(atf3,s_sleep);	   	
		   	if(key(_T)) atf=ascii=scan_code=0;signal(atf3,s_wakeup);signal(type interface,s_sleep);  end      // mode chat
		   end
	   end   
	   
	   // --------------------------
    	if(gmode==EN_JEU)  
	      from fto=0 to MAX_MSG_CHAT;                // affiche les messages                   
	      	if(mess_chat[fto]!="")
	         	objet(x,y+fto*15,0,0,write_in_map(FNT_chat,substr(mess_chat[fto],1),0),0,100,100,0,0,alpha,1);
	         end
	      end    
	      if(atf2>=5 && atf==0) 
	      	objet(x,20+y+MAX_MSG_CHAT*15,0,0,write_in_map(FNT_chat,textee_chat+"_",0),0,100,100,0,0,alpha,1);
	      	if(atf2>=10) atf2=0; end
	      else objet(x,20+y+MAX_MSG_CHAT*15,0,0,write_in_map(FNT_chat,textee_chat,0),0,100,100,0,0,alpha,1); 
	      end
	      atf2++;
    	end
	    // --------------------------  

   	frame;
	end
end           

// process qui s'occupe de recevoir les messages du serveur
process mini_client();              
private

  int message[4];
  dword con_test=0;

begin

   repeat

      if (fsock_socketset_check(0,-1,-1,000)>0) // si le serveur envoie une donnée
      
         con_test=tcpsock_recv(socket,&message,sizeof(message)); // On l'enregistre dans la variable message
         
         // ----- PERTE DE LA CONNECTION -----
         if(con_test!=20) 
         	say("WARNING: connection perdue avec le serveur");
         	decript_message(0,99,1,1,0);  // message d'erreur
         	return;
         end
         // ----------------------------------
         
         decript_message(message[0],message[1],message[2],message[3],message[4]);   // on l'execute 

      end    
      
      /*if(key(_space))    
      	say(NB_MESSAGES);
      	say(rand_tous_pareil(50,100));
      end */

      frame(100);  //(frame_timeu)
   until(exit_status==1)	// si le jeu quitte  
Onexit
   envoie_message(99,joueur_num,leader,0);             // on prévient de notre départ 
   /*if(leader) 
	   tcpsock_close(seveur_socket); 
		from x=1 to seveur_nb_joueurs;
			tcpsock_close(infos_JOUEURS[x].sock);
		end   
	end*/
   fsock_socketset_free(0);
   fsock_close(infos_JOUEURS[joueur_num].sock);
	fsock_quit();
	say("Connection au serveur fermé ("+(exit_status==1)+")");
end 

function envoie_unseul_message(atf,mess1,mess2,mess3,mess4);  // envoie un message a un seul joueur (SEULEMENT SI ON EST SERVEUR!!!!)
private int message[4];
begin

	if(leader!=1)return;end
	message[0]=0;
	message[1]=mess1;
	message[2]=mess2;
	message[3]=mess3;
	message[4]=mess4;
 
	tcpsock_send(infos_JOUEURS[atf].sock,&message,sizeof(message)); // envoie au serveur

end 

process decript_message(mess0,mess1,mess2,mess3,mess4); // process qui decripte les message et qui les executes
                       // mess0 est l'id du message
                       // mess1 est la catégorie du message
                       // mess2-4 c'est le contenu du message
begin
       
   IF(mess1>2 && mess1!=99) // Si la partie n'a pas commencé l'ordre n'a pas d'importance (sauf pour le chat)

      // Vérifie qu'il a reçu les messages dans le bon odre

      if( mess0 > (NB_MESSAGES+1) )   
      	atf3=timer[9]+100;           
      	atf2=1;
         say("ERREUR: problème de syncronisation");
         repeat 
	         if(timer[9]>=atf3 && atf==0)                      // si au bout d'une seconde rien n'est réglé    
	          	say("ERREUR: syncronisation, delai d'attente dépassé");
	          	envoie_message(98,joueur_num,0,0);
	          	atf=1;
	         end
         frame(10); until(mess0 == (NB_MESSAGES+1)) // sinon il attend jusqu'a que c'est à son tour
         say("problème de syncronisation CORRIGE");       // avec ce système tous les joueurs executent les messages dans le même ordre
         atf2=0;    
      elseif( mess0 < (NB_MESSAGES+1) ) 
      	say("ERREUR: problème de syncronisation (retard)"); 
      	envoie_message(98,joueur_num,0,0);
      	return;
      end
      

      NB_MESSAGES++;                                   // +1 au nombre de messages reçu
      
   END
      

         // --------- DIFFERENTS TYPES DE MESSAGES -------------
         // ------ CETTE PARTIE EXECUTE L'ORDE DONNEE ----------
             
            IF ( mess1 == 99 )  // CATEGORIE JOUEUR QUI QUITTE (BUG)

            	switch(gmode)
            		case EN_LOBBY:
            			if(mess3!=1)
		            		str=" à quitté le partie (connexion perdue)";
                     	ajout_message_n(str,mess2);
                     	// --- supprime le joueur de la partie ---
                     	if(leader) 
                     		seveur_nb_joueurs--; 
                     	end
                     	nb_joueurs--;
                     	from fto=(1+mess2) to max_joueur_partie;  // decale lesa utres joueurs pour boucher le trou
                     		if(infos_JOUEURS[fto].pseudo!="")
		                  		infos_JOUEURS[fto-1].pseudo=infos_JOUEURS[fto].pseudo;
		                  		infos_JOUEURS[fto-1].pret=infos_JOUEURS[fto].pret;	  
		                  		infos_JOUEURS[fto-1].sock=infos_JOUEURS[fto].sock;     
	                  		end
                  		end
                  		if(joueur_num>mess2) joueur_num--; end
                  		// --------- redemarre le lobby ----------  
                  		signal(type affiche_lobby,s_kill);signal(type fleche,s_kill);   
                  		affiche_lobby(menu_actuel);
                  		// ---------------------------------------	
		            	else    
		            	   objet2(ECRAN_tx/2,ECRAN_ty/2-30,-310,0,write_in_map(FNT_menu,"Connection perdue avec le serveur",4),0,100,100,0,0,255,1);
		            	   objet2(ECRAN_tx/2,ECRAN_ty/2,-300,FPG_menu,8,0,150,100,0,0,255,1);      // cadre    
		            	   x=bouton(FNT_menu,ECRAN_tx/2,ECRAN_ty/2+30,3,"Retour");x.z=-310;  
		            	   repeat
			            		frame;
			            	until(!exists(x))   
			            	signal(type objet2,s_kill);
			            	signal(type affiche_lobby,s_kill_tree);
		            	end  	
            		end
            		case EN_JEU:
		            	if(mess3!=1)  // A CHANGER (PASSAGE AU SERVEUR PERL)
		            		ecran_message("Connection perdue avec "+infos_JOUEURS[mess2].pseudo+" (joueur "+mess2+")",2500);  
		            		signal(id_joueurs[mess2],s_kill_tree);
		            	else
		            	   ecran_message("Connection perdue avec le serveur",4000);
		            	end  
		            end               
		         end
               
            RETURN; END 
            
            // ----------------------------------------------------
            
            IF ( mess1 == 1 )  // CATEGORIE NUMERO DU JOUEUR

               joueur_num = mess2; // enregistre notre numéro de joueur
               
               NB_MESSAGES = mess3; // actualise son nb de message (pour pas etre décalé)    
               
               max_joueur_partie = mess4; // et enregistre le nombre de joueur max
                
               serveur_est_tu_la=1;       // le serveur nous a accepté cool
               
               if(gmode==EN_JEU)	// si on etait désyncronisé
               	say("problème de syncronisation CORRIGE"); 
               	while(fto=get_id(type decript_message))        // detruit les erreurs
               		if(fto.atf2==1) signal(fto,s_kill); end
               	end
               end
               
            RETURN; END 
                            
            IF ( mess1 == 2 )  // CATEGORIE NOMBRE DE JOUEURS

               nb_joueurs = mess2; // enregistre le nombre de joueur
               
               from x=1 to nb_joueurs;        // pseudo des joueurs temporaire (si on les a pas encore reçu)
                  if(infos_JOUEURS[x].pseudo=="") infos_JOUEURS[x].pseudo="joueur "+x; end
               end   
               infos_JOUEURS[joueur_num].pseudo=JOUEUR_PROFIL.pseudo; // sans oublier notre pseudo

               envoie_message(4,cript_string(Substr(JOUEUR_PROFIL.pseudo,0,4)),cript_string(Substr(JOUEUR_PROFIL.pseudo,4,4)),cript_string(Substr(JOUEUR_PROFIL.pseudo,8,4))); // envoie son pseudo a tou le monde 
               envoie_message(7,joueur_num,infos_JOUEURS[joueur_num].perso,0);  // envoie son persos a tout le monde         
               if(leader==1) envoie_message(8,limite_mode[1],limite_mode,0); end	// envoie la limite
               if(ARMES_CHOISIS[0]!=-1);             // envoie les armes 
               	from x=1 to 5;                     
               		envoie_message(9,x,ARMES_CHOISIS[x],0); //say(x+" : "+ARMES_CHOISIS[x]);
               	end                   
               end
               //say("nb joueurs reçu: "+nb_joueurs); 
               
               signal(type miniperso,s_kill); // nouvelles miniatures       
               
            RETURN; END

            IF ( mess1 == 3 )  // CATEGORIE MESSAGE DU CHAT

               ajout_message(0,itoa(mess2),itoa(mess3),itoa(mess4)); // ajoute le message au chat

            RETURN; END
            
            IF ( mess1 == 4 ) // CATEGORIE PSEUDO (pour enregistrer le pseudo d'un joueur)
                
                if(gmode==EN_LOBBY)
                	ajout_message(1,itoa(mess2),itoa(mess3),itoa(mess4)); // enregistre le pseudo  
                end
            
            RETURN; END
            
            IF ( mess1 == 5 ) // CATEGORIE ARENE RECU
                
                if(leader!=1)
	                charge_maps();  
	                ajout_message(2,itoa(mess2),itoa(mess3),itoa(mess4)); // enregistre l'arene  
	             end
                trouve_arme();	// recupere les armes   
                
                signal(get_id(type affiche_lobby).angle,s_kill);   // actualise la miniature
                
            RETURN; END 
            IF ( mess1 == 6 ) // CATEGORIE ARENE INEXISTANTE
                 
                str=" n'a pas l'arène choisis";
                /*ajout_message(0,mess2+cript_string(Substr(str,0,4)),mess2+cript_string(Substr(str,4,4)),mess2+cript_string(Substr(str,8,4))); 
                ajout_message(0,mess2+cript_string(Substr(str,12,4)),mess2+cript_string(Substr(str,16,4)),mess2+cript_string(Substr(str,20,4)));  */
                ajout_message_n(str,mess2);
                TOUSLEMONDEACETTEARENE=false;  
             
            RETURN; END 
            IF ( mess1 == 7 ) // CATEGORIE CHANGEMENT DE PERSOS
               
               if(gmode==EN_LOBBY)
	               if(mess3>=0 && mess3<=99 && map_exists(FPG_persos,mess3*10+1))  
		               infos_JOUEURS[mess2].perso=mess3;   // on enregistre le nouveau perso
		            	signal(type miniperso,s_kill);	// nouvelles miniatures  
		            else
		            	say("ERREUR: perso inexistant ("+mess3+")");
	            	end 
	            end
             
            RETURN; END
            IF ( mess1 == 8 ) // CATEGORIE CHANGEMENT DE LIMITE
               
               if(gmode==EN_LOBBY)
	            	limite_mode[1]=mess2;
	            	limite_mode=mess3;     
	            end
             
            RETURN; END
            IF ( mess1 == 9 ) // CATEGORIE CHANGEMENT D'ARME
               
               if(gmode==EN_LOBBY && mess2>0 && mess2<=5 && mess3>=(mess2==1) && mess3<NB_ARMES)
	            	ARMES_CHOISIS[mess2]=mess3;	    
	            end
             
            RETURN; END   
            IF ( mess1 == 10 ) // CATEGORIE ON LANCE OU FINI LA PARTIE
            
            	if(mess2==12 && mess3==12 && mess4==12)    //12=c bon (je sais c nul mais ça me faisait rire)
            		game_init();
            	elseif(mess2==42 && mess3==42 && mess4==42)    //42=c bon 
            		game_end();
            	end
            
            RETURN; END  
            IF ( mess1 == 11 ) // CATEGORIE PLACER UN PERSO    
            
            	// --- cherche un pts de respawn le plus perdu possible 
            	place_joueur2(mess2,&x,&y);
					// ------------------------------		
               
            	id_joueurs[mess2].x=x;     // place le persos
            	id_joueurs[mess2].y=y;  
            	
            	signal(id_joueurs[mess2],s_wakeup_tree);   // réaparait 
   				infos_JOUEURS[mess2].vie=100;   // lui remet la vie   
   				timer[mess2]=0;		// pour eviter le bug de l'objet pris par le cadavre
            
            RETURN; END
            IF ( mess1 == 15 ) // CATEGORIE BOUGER SON PERSOS  
            
               str=itoa(mess2);  
               
               if(str[2]=="1")     atf2=true;        // on commence a appuyer sur la touche
               elseif(str[2]=="0") atf2=false; end   // on arrette d'appuyer sur la touche
               
            	if(str[1]=="1") // a gauche  
            		id_joueurs[atoi(str[0])]._bouge_gauche = atf2;  
            	end   
            	if(str[1]=="2") // a droite
            	   id_joueurs[atoi(str[0])]._bouge_droite = atf2;
            	end     
            	if(str[1]=="3") // sauter
            	   id_joueurs[atoi(str[0])]._saute = atf2;    
            	end    
            	if(str[1]=="4") // se baisser
            	   id_joueurs[atoi(str[0])]._baisse_toi = atf2;
            	end      
            	if(str[1]=="5") // tirer
            	   id_joueurs[atoi(str[0])]._tire = atf2;
            	end 
            	
            	/*if(atf2==false)*/ id_joueurs[atoi(str[0])].x=mess3;id_joueurs[atoi(str[0])].y=mess4; /*end*/ // nouvelle coordonnées (syncronisation)
                                                                                            
            RETURN; END   
            IF ( mess1 == 16 ) // CATEGORIE ANGLE D'UN PERSO
               
               if(mess2<>joueur_num) 
               	infos_JOUEURS[mess2].coord_mouse.x=mess3;
               	infos_JOUEURS[mess2].coord_mouse.y=mess4;  
               end
               
               //say("[SERVEUR] coord mouse ("+mess3+","+mess4+") de joueur "+mess2+" RECU "+ftime("%H:%M:%S",time()));
            
            RETURN; END  
            IF ( mess1 == 17 ) // CATEGORIE 3 2 1 go !! 
            
            	switch(atoi(mess2)) 
            		case(4):
            			signal(type interface,s_sleep);
            		end 
            		case(3):                                       
            			objet2(ECRAN_tx/2,ECRAN_ty/2,-512,0,write_in_map(FNT_321go,mess2,4),0,100,100,0,0,255,1);
            			timer=0;
            		end     
            		case(2):    
            			signal(type objet2,s_kill);
            		   objet2(ECRAN_tx/2,ECRAN_ty/2,-512,0,write_in_map(FNT_321go,mess2,4),0,100,100,0,0,255,1);    
            		   say("Ping (j"+joueur_num+") = "+itoa(100-timer)+" cs");
            		end
            		case(1):     
            			signal(type objet2,s_kill);
            		   objet2(ECRAN_tx/2,ECRAN_ty/2,-512,0,write_in_map(FNT_321go,mess2,4),0,100,100,0,0,255,1);
            		end
            		case(0):                    
            			signal(type objet2,s_kill);
            			objet2(ECRAN_tx/2,ECRAN_ty/2,-512,0,write_in_map(FNT_321go,"GO !",4),0,100,100,0,0,255,1);
            			signal(type interface,s_wakeup);
            			timer=0;									// durée de la partie
            			while(timer<100) frame; end 
            			signal(type objet2,s_kill);
            		end
            	end
                
            RETURN; END 
            IF ( mess1 == 20 ) // persos touché avec securité anti triche   (operationnel)
            	                      
            	str=mess2; 
            	fto2=str[0]; // joueur qui a tiré    
            	fto =str[2]; // joueur qui s'est fait touché  
            	atf3=str[4]; // partie du corp touché
            	atf =substr(str,6); // arme qui a tiré   
            	
            	if(mess3==get_donnees_armes_degat(atf))	// sécurité anti triche
	            	switch(atf3)                    			// vérifie les degats et enleve la vie selon l'endroie du corps touché
			   			case(ZTETE):        // TETE        
		   			   	infos_JOUEURS[fto].vie-=mess3*DONNEE_degat_tete;
			   			end 
			   			case(ZCORPS):        // CORPS          
		   			   	infos_JOUEURS[fto].vie-=mess3*DONNEE_degat_corp;		   			
			   			end
			   			case(ZJAMBES):        // JAMBES              
		   			   	infos_JOUEURS[fto].vie-=mess3;
			   			end   
			   		end
	   			end 
	   			
	   			if(fto2==joueur_num)		// pour le profil
	   				JOUEUR_PROFIL.nb_touchés++;      // cela permettra de calculer la precision      
	   			end
	   			
            	if(infos_JOUEURS[fto].vie<=0)     // si le persos touché creve on fait gagner du score au vainqueur 
            	   // ----------- REGARDE SI ON EST PAS DEJA EN TRAIN DE LE TUER ^^
            	   x=0;
            	   while(atf2=get_id(type tue_ressucite_perso))
            	   	if(atf2.atf==fto) x=-1; break; end
            	   end
            	   // -------------------------------------
            	   if(x!=-1)        // si il est pas deja mort
	            		infos_JOUEURS[fto2].score+=1;
	            		infos_JOUEURS[fto].nb_de_defeate+=1;	
	            		if(fto2==joueur_num)	// si c'est nous le killer
	            		   ecran_message("Vous avez tué "+infos_JOUEURS[fto].pseudo,4000);	// indique qui on a tué (4s)   
	            		   JOUEUR_PROFIL.nb_tuer++;
	            		end   
	            		if(fto==joueur_num)	// si c'est nous le mort
	            			ecran_message(infos_JOUEURS[fto2].pseudo+" vous a tué"/*+chr(233)*/,4000);	// indique qui nous a tué (4s)
	            		   JOUEUR_PROFIL.nb_mort++;
	            		end   
	            		tue_ressucite_perso(fto,mess4,atf3,mess3);   // fto=id du joueur, mess4=sens du tir, atf3=partie du corp touché, mess3=degat dans sa gueule 
            	      //---- SI LIMITE DE KILL ATTEINTE ----
	            		if(leader==1 && limite_mode==1 && infos_JOUEURS[fto2].score>=limite.val[limite_mode][limite_mode[1]])  
								envoie_message(10,42,42,42);
							end
	            		//------------------------------------
            	   end
            	end
            	
            RETURN; END   
            IF ( mess1 == 21 ) // CATEGORIE JOUEUR APPUIE SUR E POUR RECUP UNE ARME + RAMASSER UNE ARME OU UN OBJET
                         	  
            	//envoie_message(21,1,numero_de_joueur,nct05.x-nct05.y);   
            	str=itoa(mess2);                             
      			while(atf=get_id(type objet_muniton))	// identifie l'objet
      	   		if(atf.fto==mess4) atf2=1; break; end
      	   	end
      	   	if(atf2!=1) say("ERREUR: aucun objet ne correspond au message reçu"); return; end      
	   	      if(abs(id_joueurs[mess3].x-atf.x)>DONNEE_largeur_perso*2)				// anti triche (si l'objet est pas a 15milles metres)  
	   	      	say("ERREUR: objet trop loin");
      	   		return;
      	   	end    
            	switch(atoi(str[0]))    
            	   case 0:             // 0=recup_objet
            	   	recupere_objet(atf,mess3);                    // (id arme, numero de joueur)   
            	   end            	
            	   case 1:             // 1=recup_arme
            	   	recupere_arme(atf,atoi(substr(str,1)),mess3); //(id de l'arme,enplacement,num_joueur)
            	   end
            	   case 2:             // touche E
            	      id_joueurs[mess3].fto=1; 
            	      recupere_arme(atf,infos_JOUEURS[mess3].arme_en_cour,mess3);
            	   end
            	end   
                    
            RETURN; END
            IF ( mess1 == 22 ) // CATEGORIE CHANGER ARME
               
            	if(mess3>=0 && mess3<DONNEE_nb_max_armes)                // si le joueur a l'arme demandé 
						if(infos_JOUEURS[mess2].arme_en_stock[mess3]!=0)  
		      			infos_JOUEURS[mess2].arme_en_cour=mess3;	
		      		end 
		      	end
            
            RETURN; END  

         // ----------------------------------------------------
         // ----------------------------------------------------
   
end    

process ajout_message_n(string msg,int z)
begin
  from x=0 to MAX_MSG_CHAT; // ajoute le msg a la suite des autres
    if(mess_chat[x]=="") break; end
  end
  if(mess_chat[MAX_MSG_CHAT]=="")  // si c'est pas le dernier
     mess_chat[x]=z+infos_JOUEURS[z].pseudo+": "+msg; // id_joueur + pseudo + le message
  else
     from x=0 to MAX_MSG_CHAT-1;      //sinon  décale tous
        mess_chat[x]=mess_chat[(x+1)];
     end
     mess_chat[MAX_MSG_CHAT]=z+infos_JOUEURS[z].pseudo+": "+msg; // id_joueur + pseudo + le message
  end
end

process ajout_message(ps,string m1,string m2,string m3); // ajoute un message au chat ou enregistre un pseudo
private

   string mess2;
   string msg;
   a;
   string b;

begin

  z=atoi(m1[0]); // récupère l'id du joueur qui a posté le message  (ou son pseudo)

  m1=substr(m1,1);
  m2=substr(m2,1);
  m3=substr(m3,1);
  mess2=m1+m2+m3;
  
  // ------- DECRIPTAGE ---------
  for(x=0; x<len(mess2); x+=2) // transforme le message cripté en texte
    b=mess2[x];b=b+mess2[(x+1)];//b=mess2[x]+mess2[(x+1)];
    a=atoi(b);
    msg=msg+lettres[a];
  end
  // ----------------------------
  
IF(ps==0) 						// chat message
   
  from x=0 to MAX_MSG_CHAT; // ajoute le msg a la suite des autres
    if(mess_chat[x]=="") break; end
  end
  if(mess_chat[MAX_MSG_CHAT]=="")  // si c'est pas le dernier
     mess_chat[x]=z+infos_JOUEURS[z].pseudo+": "+msg; // id_joueur + pseudo + le message
  else
     from x=0 to MAX_MSG_CHAT-1;      //sinon  décale tous
        mess_chat[x]=mess_chat[(x+1)];
     end
     mess_chat[MAX_MSG_CHAT]=z+infos_JOUEURS[z].pseudo+": "+msg; // id_joueur + pseudo + le message
  end
  
END
IF(ps==1)               	// pour les pseudo

  infos_JOUEURS[z].pseudo=msg;  // enregistre le pseudo

END    
IF(ps==2)               	// pour les Arenes
    
   atf=-1;   
   from fto=0 to NB_MAX_ARENES-1;  
   	if(ucase(substr(Arene_fichiers[fto],0,12))==ucase(msg))atf=fto;break;end	
   end
   
  	if(atf>-1/*verif_map(msg,1)!=-1*/) // si on a la map   
  		MAPCHOISIS=Arene_fichiers[atf];  // enregistre le nom de l'arene 
  	else
  		MAPCHOISIS="caca-->"+msg;    					// sinon on le signale 
  		envoie_message(6,joueur_num,0,0); 		   // au serveur aussi
   end
   
END


end  

process cript_string(string mess);   // process qui cripte les string en int
private

   string mess2;

   int mess3;

begin

from x=0 to (len(mess)-1);

  if(Find(lettres,mess[x])<>-1)
   if(Find(lettres,mess[x])<10)
      mess2+="0"+itoa(Find(lettres,mess[x]));
      else
      mess2+=Find(lettres,mess[x]);
   end
   else
   mess2+="00";
  end

end

  mess3=atoi("1"+mess2);     			// il met "1" devant (pour la transformation en int)
  return mess3;

end    

process envoie_message(mess1,mess2,mess3,mess4);  // envoie un message au serveur
private int message[4];
begin

 message[0]=0;
 message[1]=mess1;
 message[2]=mess2;
 message[3]=mess3;
 message[4]=mess4;
 
 if(mess1==3 or mess1==4)               			// si c'est un message du chat ou un pseudo a envoyer
   str=itoa(joueur_num)+substr(itoa(mess2),1); // ajoute l'id du joueur qui a écrit le message (a la place du 1)
   message[2]=atoi(str);               			// transformations en int
 end
 
 tcpsock_send(socket,&message,sizeof(message)); // envoie au serveur

end  

// ------------------------------------------------------------------------
// ------------------------ PARTIE SERVEUR --------------------------------
// ------------------------------------------------------------------------

process serveur()
private

   temp;
   //socket; 
   int message[4];

begin
      

	      timer=0;  
	      repeat    
	      	frame; 
	      until(timer>10) // attend le menu sinon il va tous supprimer et ce sera le bordel  
	      
      if(seveur_socket==0)       // si on est déja connecté	
             
	   	fsock_init(0); // Initialise la librairie tcpsock
	   
	      seveur_socket=tcpsock_open();
	      fsock_bind(seveur_socket,PORT_CONNECTION);  // Demarre la conenction
	      tcpsock_listen(seveur_socket,serveur_NB_JOUEUR_MAX);    // Définit les max de joueurs
	      
	      // --- Ensuite se connecte a lui même ---
	      ip_serveur="127.0.0.1"; 
	      connection_serveur(8); 
	      // --------------------------------------        
	   end
      
      charge_maps();           		// process qui va charger les maps 
      
      repeat      // Attente des joueurs  (lobby)

         /*write(0,160,30,0,"Attente des joueurs...");
         write(0,160,40,0,"Joueurs connectés: "+nb_joueurs_connect);   */

         if (seveur_nb_joueurs<serveur_NB_JOUEUR_MAX)                       // Si on a pas attein le nombre maximum de joueurs
         
            if ((infos_JOUEURS[(seveur_nb_joueurs+1)].sock=tcpsock_accept(seveur_socket,&temp,&atf))!=-1) // Dès qu'on recçois une tentative de connection on l'accepte et on enregistre son ip dans la variable temp

               seveur_nb_joueurs++;    // un joueur en plus
            
               // -----
               message[0]=0;message[1]=1;message[2]=seveur_nb_joueurs;message[3]=serveur_NB_MESSAGES;message[4]=serveur_NB_JOUEUR_MAX;
               tcpsock_send(infos_JOUEURS[seveur_nb_joueurs].sock,&message,sizeof(message));  // On transmet au joueur son n° de joueur et les nombre de messages et aussi le nb max de joueur sur la partie
               // -----                                                                   // On transmet la map utilisé
               envoie_message(5,cript_string(Substr(MAPCHOISIS,0,4)),cript_string(Substr(MAPCHOISIS,4,4)),cript_string(Substr(MAPCHOISIS,8,4)));
               // -----
                
              // infos_JOUEURS[nb_joueurs_connect].ip = (((temp)&0ffh)+"."+((temp>>8)&0ffh)+"."+((temp>>16)&0ffh)+"."+((temp>>24)&0ffh)); // enregistre l'ip du joueur dans une string


               mini_serveur(seveur_nb_joueurs);   // On lance le process qui va suivre ce joueur

               // -----                           On envoie a tous les joueurs le nouveau nombre de joueurs
               from temp=1 to seveur_nb_joueurs;
                  message[0]=0;message[1]=2;message[2]=seveur_nb_joueurs;
                  tcpsock_send(infos_JOUEURS[temp].sock,&message,sizeof(message));  // envoie du message
               end
               temp=atf=false;
               // -----

            end

         end

         if(seveur_nb_joueurs >= MIN_JOUEURS) // Si il y a assez de joueurs    
            get_point(FPG_menu,5,15,&x,&y);
         	//objet(10+x+250,10+y+85+20,z,0,write_in_map(FNT_menu_stat,"ASSEZ DE JOUEURS CONNECTE",4),region,size_x,size_y,angle,flags,alpha);  
            objet(10+x+250,10+y+135,z,0,write_in_map(FNT_menu_stat,"POUR LANCER LA PARTIE APPUYEZ SUR F3",4),region,size_x,size_y,angle,flags,alpha,1);
         end

         frame;
      until(seveur_nb_joueurs >= MIN_JOUEURS && TOUSLEMONDEESTPRET==true && TOUSLEMONDEACETTEARENE==true && key(_F3))   // SI ON LANCE LA PARTIE
      
      envoie_message(10,12,12,12);  	// c'est partie 
      
      envoie_message(17,4,0,0);
      timer=0; while(timer<100) frame; end
      envoie_message(17,3,0,0);
      timer=0; while(timer<100) frame; end
      envoie_message(17,2,0,0);
      timer=0; while(timer<100) frame; end
      envoie_message(17,1,0,0);
      timer=0; while(timer<100) frame; end
      envoie_message(17,0,0,0);
     
end

process mini_serveur(atf);  
private int message[4];dword con_test=0;
begin

   loop
   
      //write(0,0,15+num_joueur*30,0,"- Joueur "+num_joueur);
     // write(0,0,25+num_joueur*30,0,"  IP: "+JOUEUR[num_joueur].ip);
      
      // Reception d'un message et réenvoie
      fsock_fdzero(1);
      fsock_fdset(1,infos_JOUEURS[atf].sock);
      if(fsock_select(1,-1,-1,0)>0 && fsock_fdisset(1,infos_JOUEURS[atf].sock)) // si ya une donnée et si pas de timeout (2s)

         con_test=tcpsock_recv(infos_JOUEURS[atf].sock,&message,sizeof(message));
             
             //say(con_test); 
                      
       /*  say("--- MESSAGE n "+NB_MESSAGES+" ---");  
         say("- "+message[0]);
         say("- "+message[1]);
         say("- "+message[2]);
         say("- "+message[3]);
         say("- "+message[4]);
         say("--------------------");    */    
         
         // ----- PERTE DE LA CONNECTION -----
         if(con_test!=20) 
         	say("WARNING: connection perdue avec joueur "+atf);
         	envoie_message(99,atf,(atf==1),0);
         	return;
         end
         // ---- ERREUR DE SYNCRONISATION ----
         if(message[1]==98) 
         	message[0]=0;message[1]=1;message[2]=seveur_nb_joueurs;message[3]=serveur_NB_MESSAGES;message[4]=serveur_NB_JOUEUR_MAX;
            tcpsock_send(infos_JOUEURS[atf].sock,&message,sizeof(message));  // On transmet au joueur le nombre de messages 
         	continue;
         end
         // ----------------------------------
         
         if(message[1]<>0)
         
            message[0]=(serveur_NB_MESSAGES+1);           // On donne l'id au mesage

            from x=1 to seveur_nb_joueurs;
            	if(infos_JOUEURS[x].sock!=-5)
               	tcpsock_send(infos_JOUEURS[x].sock,&message,sizeof(message));  // On l'envoie a tous les joueurs     
               end
            end

            serveur_NB_MESSAGES++;                    // et voila un message de plus !

         end
         
      end
      // ----------------------------------   
      
      // --- resyncronisation   tous les 500 messages      
	      /*message[0]=0;message[1]=-1;message[2]=hasard;message[3]=0;message[4]=0;
	      tcpsock_send(infos_JOUEURS[num_joueur].sock,&message,sizeof(message)); */
      // --------------------------------------------
   
   
      frame(10);
   end
Onexit      
	fsock_close(infos_JOUEURS[atf].sock); 
	infos_JOUEURS[atf].sock=-5;/*  
	// ------
	atf2=0;
	from x=1 to seveur_nb_joueurs;
		if(infos_JOUEURS[x].sock==-5)atf2++;end
	end 
	if(atf2==seveur_nb_joueurs)        // si il reste plus que celui la on coupe le serveur
		tcpsock_close(seveur_socket);
	end         */
end
     /*
int an(x)  			// permet que tous le monde aille a la même vitesse malgret les fps différents
private float a;
begin
   if(fps==31) fps=30; return x; end
	a=(nb_fps)*1.0/(fps*1.0);
	return a*(x*1.0);
end     */