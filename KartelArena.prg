#define frame_timeu 100  

//#ifndef MODE_EMULATION        // si on emule depuis un autre prog
program Kartel_Arena;      

include "vars\consts.prg";    // constantes 
/*#else
include "..\Kartel Arena\v0.9\vars\consts.prg";    // constantes 
#endif*/

global

// COUCOUCOUCO

   // --- FONTES ---
      /*word*/ FNT_titre,
      FNT_menu,
      FNT_menu_stat,
      FNT_chat,
      FNT_321go,  
      FNT_life=-1;
   // --------------
   
   // ---- FPGs ----
      FPG_menu, 
      FPG_jeu,  
      FPG_armes,  
      FPG_persos=-1;
   // --------------
   	
   // ---- MENU ----
      word menu_actuel = 1;
      string fichier[4]; // pour les profils   
      bool gmode;    // ou on en est (lobby ou en jeu)
   // --------------
   
   // --- PROFIL ---
      profil_charge = -1;
      struct JOUEUR_PROFIL;
         string pseudo;
         dword nb_parties;// nombre de parties joué
         dword nb_tuer;   // nombre de gars tué
         dword nb_mort;   // nombre de deces
         dword nb_balle;  // nombre de balle tiré
         dword precision; // precision en pourcentage   
         dword nb_touchés; // pour calculer la precision
      end
   // --------------  
	
	// Pour le moteur du jeu (jeu.prg)
	// ===============================
		COULEUR_COLLISION = -1;			// la couleur pour la hardness map 
		bool choc_ecran;  				// pour faire un choc: choc_ecran=1;  
		word nb_ecran_message = 0;   	// pour l'affichage des messages 
		word nb_objet;						// nb d'objet à l'écran (pour identifier les objets)    
	// ===============================
	// Pour le moteur reseau (lobby_et_reso.prg)
	// =========================================
		// ----------------- 
			string Arene_fichiers[NB_MAX_ARENES-1];   //contien les arenes (serveur)
		// -----------------    
			
		word couleurs[MAX_JOUEURS];    // couleurs des joueurs
		
		string ip_serveur = "192.168.1.102"; // Ip du serveur        
		
		socket;  
				 
		bool leader; 							// si egal a 1 c'est nous le createur de la partie (serveur)    
		
		serveur_est_tu_la;         // si le serveur est plein
		
		dword NB_MESSAGES = 0;  // nombre de messages reçu (tres important) (message client<->serveur)     
		
		struct limite;			// limite d'une fin de partie
			max=2;			// nb d'entrée du table
			string txt[1]= "Limite de temps",
								"Limite de score",;
			val[1][5]=		2,5,7,10,15,20,           // le premier chiffre donne le nombre de valeur
								5,10,20,30,50,100;
		end
		 
		// ---- Infos sur la partie ----   (client)
			joueur_num; // notre numéro de joueur
			nb_joueurs; // nombre de joueurs dans la partie      
			string MAPCHOISIS;  //la map de la partie  
			mapshoisis2=0;	// pour le nb de map
			ARMES_CHOISIS[5]=-1,0,0,0,0,0;   //les armes choisis pour la partie 
			//miniature_id;       //la miniature de la map
			max_joueur_partie = MAX_JOUEURS; // nombre de joueur max dans la partie 
			limite_mode[1];      // le mode de limite de la partie
			struct infos_JOUEURS[MAX_JOUEURS];
				string pseudo;
				bool pret=false;      // si le joueur est pret
				int perso=1;          // le perso qu'il a choisi 
				sock=-5;              // le socket (pour le serveur) 
				struct coord_mouse; x;y; end    // contien les coordonnées de la souris du joueur DANS LE SROLL /!\ PAS DANS L'ECRAN /!\ 
				arme_en_cour = 0;     // l'arme que le joueur porte   
				arme_en_stock[DONNEE_nb_max_armes-1]=1,0,0;     // les armes que possede le joueur max: 3
				munition[DONNEE_nb_max_armes-1]=0,0,0;
				vie = 100;
				score=0;
				nb_de_defeate=0;
			end                                                     
			id_joueurs[MAX_JOUEURS];           // stocke les id des process des joueurs
		// ----------------------------- 
												
		// ----- CHAT ------      
			string lettres = " 0123456789abcdefghijklmnopqrstuvwxyz,?;.:!èéàç'-()=_+/\ABCDEFGHIJKLNMOPQRSTUVWXYZ"; // pour cripter les messages
			string textee_chat; // message que l'on tape au chat
			string mess_chat[MAX_MSG_CHAT];  // stocke les messages du chat
		// -----------------
		
		// --- SERVEUR ---
			seveur_socket; 
			seveur_nb_joueurs;             // nb de joueur connectée
			dword serveur_NB_MESSAGES;
			serveur_NB_JOUEUR_MAX=MAX_JOUEURS;    
			TOUSLEMONDEESTPRET=true;
			TOUSLEMONDEACETTEARENE=true;
		// ---------------   
	// =========================================

local

	// Pour le moteur du jeu (jeu.prg)
	// ===============================
	tailx; 				// taille x du graph divisé par 2
	taily; 				// taille y du graph
	float elasticite; // elasticité de l'objet
   // ----------------- moteur COLLISIONS jvc :
	x_speed;y_speed; 	//Les vitesses de mouvement
	sx;sy;				//inertie;
   // ===============================
	// Pour le moteur reseau (lobby_et_reso.prg)
	// =========================================
		// POUR FAIRE BOUGER LES PERSOS
   	bool _saute;
   	bool _baisse_toi;
   	bool _bouge_gauche;
   	bool _bouge_droite;  
   	bool _tire; 
   	bool _prend_arme;            
		// ---------------------------- 
	// =========================================
	// Pour le moteur animation (moteur_anim.prg)
	// =========================================
		angle1;
		pos_px;
		pos_py;   
		sol;  
		vitesse;     
		vari_hjambes; 
		vit_vit_dep; 
		hauteur_jambes;        
		angle_touché;               
		dist_choc;
		x1;  
		y1;    
		prX;
		prY;
		nct01;
		nct02;nct03;
		nct04;
		nct05;
		distx_cuisse; 
	// =========================================
	
	// VARIABLES A TOUT FAIRE
	fto;fto2;      // variable "compteur"
	string str;    // string "a tous faire"
	atf;atf2;atf3; // variable "a tous faire"
	// -----------------------

   
#ifndef MODE_EMULATION  
   
// ------- DLL -------- 
	//import "ttf.dll";        // Dll pour les fontes
	import "fsock.dll";    // Dll pour les fonctions réseau 
	//import "Clipboard.dll";	 // Dll pour le copier coller 
// --------------------

// --------------------                         
	include "vars\menu.prg";              // architecture du menu        
	include "vars\lobby_et_reso.prg";     // tous ce qui est réseau + lobby + chat  
	include "vars\arenes.prg";     		  // moteurs des arenes   
	include "vars\moteur_anim.prg";       // moteur d'animation   
	include "vars\jeu.prg";     			  // tous ce qui est jouable ^^
// --------------------

begin
      
   // ------------------------------  
  // dump_type = complete_dump; 
   set_title("Zigo Studio - War Guns");  
   set_fps(nb_fps,nb_fps-1);
   //graph_mode  = 16 | MODE_HARDWARE/* | MODE_DOUBLEBUFFER*/;
	/*full_screen = true;*/  //say(MODE_DOUBLEBUFFER);
	set_mode(ECRAN_tx,ECRAN_ty,16,MODE_HARDWARE /*| MODE_DOUBLEBUFFER*/);  
	// ------------------------------
   // -- debug               
   //load_arene("test dist");
   write_int(0,0,0,0,&fps);
   // --------
	
	// couleurs des joueurs -------
	couleurs[1] =  rgb(0,0,248); 	// joueur 1 - bleu     
	couleurs[2] =  rgb(0,176,0);	// joueur 2 - vert   
   couleurs[3] =  rgb(224,0,0); 	// joueur 3 - rouge
	couleurs[4] =  rgb(224,240,0);// joueur 4 - jaune
	// ----------------------------
	
   intro();     // intro zigo studio ect...

   menu();      // menu du jeu  

   // ---- AJUSTAGE DU FPS -----
   /*priority=99;
   loop
   	if(fps>nb_fps+5)
   	   frame_timeu=fps*100.0/nb_fps;
   	else frame_timeu=100;
   	end 
   	frame;
   end    */
   // --------------------------

end 
#else
// -------------------------
	//import "ttf.dll";        // Dll pour les fontes
	import "fsock.dll";    // Dll pour les fonctions réseau 
	//import "Clipboard.dll";	 // Dll pour le copier coller 
// -------------------------
	include "..\Kartel Arena\v0.9\menu.prg";              // architecture du menu        
	include "..\Kartel Arena\v0.9\lobby_et_reso.prg";     // tous ce qui est réseau 
	include "..\Kartel Arena\v0.9\arenes.prg";     		  // moteurs des arenes   
	include "..\Kartel Arena\v0.9\moteur_anim.prg";         // moteur d'animation   
	include "..\Kartel Arena\v0.9\jeu.prg";     			  // tous ce qui est jouable ^^
// -------------------------
#endif

process menu()
begin

   // ---- FPGs ---
   FPG_menu = load_fpg("fpg\menu.fpg");
   // -------------
                  
   // ---- FNTs ---
   //FNT_menu  = load_fnt("fnt\warguns01.fnt");
   FNT_titre = LOAD_TTFAA("fnt\titre.ttf",65,16,rgb(30,139,0),0);
   FNT_menu  = LOAD_TTFAA("fnt\menu.ttf" ,35,16,rgb(190,190,220),0);
   FNT_menu_stat = LOAD_TTFAA("fnt\menu_stat.ttf" ,15,16,rgb(190,190,220),0);
   //FNT_chat = LOAD_TTFAA("fnt\chat.ttf",17,16,rgb(30,139,0),0);
   //FNT_chat = load_fnt("fnt\FNT_chat.fnt");
   FNT_chat = LOAD_TTFAA("fnt\chat2.ttf",15,16,rgb(255,255,255),rgb(3,3,3));
   //write(FNT_menu_stat,512,300,4,"Test de Chat Zigo: yoo les copains");
   // -------------
   
   // -------------
   declare_tous(); // declare les variables    
   set_text_color(rgb(255,255,255));
   write(FNT_titre,ECRAN_tx/2,(Text_Height(FNT_menu,"Agj")*1.5),4,"Kartel Arena"); // Titre du jeu
   write(0,0,ECRAN_ty,6,"v "+WG_version); // infos version
   mouse.file = FPG_menu;
   mouse.graph=1;
   // -------------

  	affiche_menu();

end

process affiche_menu()
private

   dif_text; // espace entre les boutons
   nb_textes;

begin

   if(get_id(type menu)==0 && menu_actuel<>7 && menu_actuel<>8) // si c pas la premiere fois
      fade_off();   // effet de fondu
      while(fading) frame; end 
		fade_on(); 
   end     

   dif_text = Text_Height(FNT_menu,"Agj")*2.5;
   
   repeat    // compte le nombre de texte que contient le menu
     if(ARC_MENU[menu_actuel].mtexte[(nb_textes+1)][0]=="") break; end
     nb_textes++;
   until(nb_textes>9)
   
   x =  ECRAN_tx/2;   // centré horizontalement
   y = (ECRAN_ty/2)-(dif_text*(nb_textes/2));   // centré verticalement

   signal(type bouton,s_kill);   // supprime les ancien bouton
   signal(type profil_cadre,s_kill);  // et le truc des profil si yen a un
   signal(type connection_serveur,s_kill);  // et le truc de connection si yen a un
   signal(type entrer_ip,s_kill);  // et le truc pour écrire l'ip si yen a un    
   signal(type texte_input,s_kill);
   signal(type fleche,s_kill);           
               
               
   if(ARC_MENU[menu_actuel].typeu==0) // menu simple
   
      from fto=0 to nb_textes;
         atf=atoi(ARC_MENU[menu_actuel].mtexte[fto][1]);   // destination de ce bouton
         bouton(FNT_menu,x,(y+dif_text*fto),atf,ARC_MENU[menu_actuel].mtexte[fto][0]);
      end
      
   end           // menu pas simple
   
      if(menu_actuel == 1)  // selection du profil

         atf=atoi(ARC_MENU[menu_actuel].mtexte[0][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty*25/100,atf,ARC_MENU[menu_actuel].mtexte[0][0]);  // y a 25% de l'ecran

         atf=atoi(ARC_MENU[menu_actuel].mtexte[2][1]);   // destination de ce bouton
         choi_profil(x,(ECRAN_ty*25/100)+20,atf);        // truc pour choisir son profil

         atf=atoi(ARC_MENU[menu_actuel].mtexte[1][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty*75/100,atf,ARC_MENU[menu_actuel].mtexte[1][0]);  // y a 75% de l'ecran

      end       
      
      if(menu_actuel == 2)  // création du profil

         atf=atoi(ARC_MENU[menu_actuel].mtexte[0][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty*25/100,atf,ARC_MENU[menu_actuel].mtexte[0][0]);  // y a 25% de l'ecran

         atf=atoi(ARC_MENU[menu_actuel].mtexte[1][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty*45/100,atf,ARC_MENU[menu_actuel].mtexte[1][0]);  // y a 45% de l'ecran
         
         texte_input(12,&JOUEUR_PROFIL.pseudo);
         bouton(FNT_menu,x,ECRAN_ty*50/100,-12,"");  // y a 50% de l'ecran   
         
         atf=atoi(ARC_MENU[menu_actuel].mtexte[2][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty*65/100,atf,ARC_MENU[menu_actuel].mtexte[2][0]);  // y a 65% de l'ecran

      end         
      
      if(menu_actuel == 3)  // profil chargé  et STATISTIQUES DU JOUEURS
      
         bouton(FNT_menu,x,ECRAN_ty*15/100+(dif_text),-2,"Vos stastistiques");
        /* bouton(FNT_menu_stat,x-100,ECRAN_ty*15/100+(dif_text*2),-2,"Nb. de parties joués: "+JOUEUR_PROFIL.nb_parties);
         bouton(FNT_menu_stat,x+100,ECRAN_ty*15/100+(dif_text*2),-2,"Nb. de mecs tués: "+JOUEUR_PROFIL.nb_tuer);
         bouton(FNT_menu_stat,x-100,ECRAN_ty*15/100+(dif_text*2)+40,-2,"Nb. de décès: "+JOUEUR_PROFIL.nb_mort);
         bouton(FNT_menu_stat,x+100,ECRAN_ty*15/100+(dif_text*2)+40,-2,"Nb. de balles tirés: "+JOUEUR_PROFIL.nb_balle);
         bouton(FNT_menu_stat,x,ECRAN_ty*15/100+(dif_text*2)+80,-2,"Nb. sauts: "+JOUEUR_PROFIL.nb_saut);
          */
          
         bouton(FNT_menu_stat,x-150,ECRAN_ty*15/100+(dif_text*2),-2,"Nombre total de parties joués");
         bouton(FNT_menu_stat,x-150,ECRAN_ty*15/100+(dif_text*2)+15,-2,JOUEUR_PROFIL.nb_parties);
         bouton(FNT_menu_stat,x+150,ECRAN_ty*15/100+(dif_text*2),-2,"Nombre total de mecs tués");
         bouton(FNT_menu_stat,x+150,ECRAN_ty*15/100+(dif_text*2)+15,-2,JOUEUR_PROFIL.nb_tuer);
         bouton(FNT_menu_stat,x-150,ECRAN_ty*15/100+(dif_text*2)+40,-2,"Nombre total de décès");
         bouton(FNT_menu_stat,x-150,ECRAN_ty*15/100+(dif_text*2)+40+15,-2,JOUEUR_PROFIL.nb_mort);
         bouton(FNT_menu_stat,x+150,ECRAN_ty*15/100+(dif_text*2)+40,-2,"Nombre total de balles tirés");
         bouton(FNT_menu_stat,x+150,ECRAN_ty*15/100+(dif_text*2)+40+15,-2,JOUEUR_PROFIL.nb_balle);
         bouton(FNT_menu_stat,x,ECRAN_ty*15/100+(dif_text*2)+80,-2,"Precision total");
         bouton(FNT_menu_stat,x,ECRAN_ty*15/100+(dif_text*2)+80+15,-2,JOUEUR_PROFIL.precision+" %");

      
       /*nb_parties;// nombre de parties joué
         nb_tuer;   // nombre de gars tué
         nb_mort;   // nombre de deces
         nb_balle;  // nombre de balle tiré
         precision;   // precision
       */
      
      end
      
      if(menu_actuel == 5)  // nouvelle partie

         atf=atoi(ARC_MENU[menu_actuel].mtexte[0][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty/2-(dif_text*2),atf,ARC_MENU[menu_actuel].mtexte[0][0]);

         atf=atoi(ARC_MENU[menu_actuel].mtexte[1][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty/2,atf,ARC_MENU[menu_actuel].mtexte[1][0]);  // y a 50% de l'ecran
         
         fleche(x-50,ECRAN_ty/2+(dif_text),-1,1);    // fleche pour changer le nb de joueur max  
         bouton(FNT_menu,x,ECRAN_ty/2+(dif_text),-11,"");// affiche le nombre
         fleche(x+50,ECRAN_ty/2+(dif_text),1,1);     // fleche pour changer le nb de joueur max
         
         atf=atoi(ARC_MENU[menu_actuel].mtexte[2][1]);   // destination de ce bouton      
         bouton(FNT_menu,x,ECRAN_ty*70/100,atf,ARC_MENU[menu_actuel].mtexte[2][0]);  // y a 70% de l'ecran
     
      end    
      
      if(menu_actuel == 6)  // rejoindre partie

         atf=atoi(ARC_MENU[menu_actuel].mtexte[0][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty/2-(dif_text*2),atf,ARC_MENU[menu_actuel].mtexte[0][0]);
        
         atf=atoi(ARC_MENU[menu_actuel].mtexte[1][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty*45/100,atf,ARC_MENU[menu_actuel].mtexte[1][0]);       
         
         entrer_ip();                                    // truc pour entrer l'ip du serveur
         bouton(FNT_menu,x,ECRAN_ty/2+(dif_text),-10,"");// affiche l'ip     
         
         atf=atoi(ARC_MENU[menu_actuel].mtexte[3][1]);   // destination de ce bouton
         bouton(FNT_menu,x,ECRAN_ty*75/100,atf,ARC_MENU[menu_actuel].mtexte[3][0]);
        
      end   
      
      if(menu_actuel == 7)  // connection au serveur
                                     
         atf=atoi(ARC_MENU[menu_actuel].mtexte[2][1]);   // destination de ce bouton                            
      	connection_serveur(atf);
      
      end   
      
      if(menu_actuel == 8)    // lobby
              
         affiche_lobby(menu_actuel);
                                  
      end
      
      if(profil_charge <> -1)  // affichage du nom du profil (en haut) si on l'a choisi
      	if(menu_actuel <> 8)
         	bouton(FNT_menu,x,ECRAN_ty*15/100,-2,JOUEUR_PROFIL.pseudo);
         else
            //bouton(FNT_menu,ECRAN_tx*70/100,ECRAN_ty*15/100,-5,JOUEUR_PROFIL.pseudo);
         end
      end
   

   
   // Bouton retour
   if(ARC_MENU[menu_actuel].menu_precedent <> -1)     
   	if(menu_actuel <> 8)
      	bouton(FNT_menu,x,ECRAN_ty*85/100,ARC_MENU[menu_actuel].menu_precedent,"Retour");
      else   // pour le lobby on deplace le bouton retour
        // bouton(FNT_menu,ECRAN_tx*85/100,ECRAN_ty*85/100,ARC_MENU[menu_actuel].menu_precedent,"Retour");
      end
   end
   // -------------
   
end

process choi_profil(x,y,atf) // cadre pour choisir son profil
begin
   
   atf2=menu_actuel;
   
   tailx = 200;
   taily = 350;  
   
   //define_region(1,x-(tailx/2),y,tailx,taily); // region 1 200x500
   //region=1;
   
   //if(fichier[0]=="")    // si on les a deja pas chargé
	glob(""); // reset glob
      from fto=0 to 4;    // 5 profils max
         fichier[fto]=glob("profils\*.wgprof"); // trouve tous les profils
         if(fichier[fto]=="") break; end
      end
   //end
   
   from fto=0 to 4;    // affiche les boutons
      if(fichier[fto]=="") break; end
      profil_cadre(x,y+30+60*fto,z,fto,fichier[fto]);
   end

   if(fichier[0]=="")     // si il y en a pas
   
      profil_cadre(x,y+30+120,z,fto,"Aucun profil");

   end

   loop
   
      //objet(x-(tailx/2),y,z+1,FPG_menu,6,0,100,100,0,0,256); // cadre
      
      if(profil_charge<>-1) // si on a chargé un profil
         break;
      end     
      if(menu_actuel<>atf2) // si on a changé de menu
         return;
      end
   
      frame;
   end
   menu_actuel = atf;      // nouvelle destination
   load("profils\"+fichier[profil_charge],JOUEUR_PROFIL); // charge le profil
   affiche_menu();
   
end

process profil_cadre(x,y,z,atf,str)
begin

   /*graph=new_map(tailx,taily,16);   // image vide

   Map_Put(file,graph,write_in_map(FNT_menu,substr(str,0,-8),4),(tailx/2),(taily/2));  // affiche leurs noms
   str="";  */

	loop
    
  		if(str<>"Aucun profil")   // si on est un profil
 
   		objet(x,y,z-1,file,write_in_map(FNT_menu,substr(str,0,-7),4),region,size_x,size_y,angle,flags,alpha,1);
   
   		graph=2;
   
      	if(collision(type mouse))
         	graph++;
         	//objet(x,y,z-1,FPG_menu,7,0,100,100,0,0,256); // mini cadre
         	if(mouse.left)  // si on clic dessus
            	repeat frame; until(!mouse.left) // attend qu'on ai finis de cliquer
            	break;
         	end
      	end

  		else
  
    		objet(x,y,z-1,file,write_in_map(FNT_menu,str,4),region,size_x,size_y,angle,flags,alpha,1);

  		end
   
     frame;
   end
   
   //JOUEUR_PROFIL.pseudo = substr(str,0,-7);
   profil_charge = atf; // numéro du profil a charger
   
end

process objet(x,y,z,file,graph,region,size_x,size_y,angle,flags,alpha,atf)
begin
  frame;       
ONExit
	if(atf==1) unload_map(0,graph); end
end
process objet2(x,y,z,file,graph,region,size_x,size_y,angle,flags,alpha,atf)
begin
	loop frame; end  
ONExit
	if(atf==1) unload_map(0,graph); end
end         
process objet3(x,y,z,file,graph,region,size_x,size_y,angle,flags,alpha,ctype,cnumber,atf)
begin
	frame;
ONExit
	if(atf==1) unload_map(0,graph); end
end     
process objet4(x,y,z,file,graph,region,size_x,size_y,angle,flags,alpha,ctype,cnumber,atf)
begin
	loop frame; end 
ONExit
	if(atf==1) unload_map(0,graph); end
end 
/*process miniature(x,y,z,graph,region,size_x,size_y,angle,flags,alpha)
begin   
  set_center(0,graph,0,0);
  frame;   
ONExit
	unload_map(0,graph);
end     */
 
process fleche(x,y,atf,atf2)
begin
	
	file=FPG_menu;   
	graph=4;  
	z=-9;
	
	size=100*(atf2==1 or atf2==2 or atf2==3)+50*(atf2==4);   // size
	if(atf2>=10 && atf2<=14) size=75; end  // armes
	
	loop 
	   
	   alpha=255*(atf2==1 or atf2==4)+125*(atf2==2 or atf2==3);   // alpha 
	   if(atf2>=10 && atf2<=14) alpha=50; end  // armes
	   
		if(atf>0)  
			if(collision(type mouse))   
				alpha=200;
				if(mouse.left) 
					switch(atf2)     
						case 1:  // nb joueurs     
							if(serveur_NB_JOUEUR_MAX<MAX_JOUEURS) serveur_NB_JOUEUR_MAX+=atf; end   
						end
						case 2:	// map        
						   if(mapshoisis2<NB_MAX_ARENES-1 && Arene_fichiers[mapshoisis2+1]!="")
						   	MAPCHOISIS=Arene_fichiers[mapshoisis2+1];
						   	mapshoisis2++;
						   	envoie_message(5,cript_string(Substr(MAPCHOISIS,0,4)),cript_string(Substr(MAPCHOISIS,4,4)),cript_string(Substr(MAPCHOISIS,8,4))); 
						   end   
						end 
						case 3:	// changer de perso        
						   if(infos_JOUEURS[joueur_num].perso<99 && map_exists(FPG_persos,infos_JOUEURS[joueur_num].perso*10+11))
						   	infos_JOUEURS[joueur_num].perso++;
						   	envoie_message(7,joueur_num,infos_JOUEURS[joueur_num].perso,0); 
						   end   
						end
						case 4:	// changer de limite   
							if(limite_mode[1]<5)
								limite_mode[1]++; 
							end
							if(limite_mode[1]==5 && limite_mode<limite.max-1)      
								limite_mode[1]=0;
	                     limite_mode++; 
							end       
							envoie_message(8,limite_mode[1],limite_mode,0);
						end
						case 10..14:	// changer d'arme
                     if(ARMES_CHOISIS[atf2-9]<NB_ARMES)
                        ARMES_CHOISIS[atf2-9]++;
								envoie_message(9,atf2-9,ARMES_CHOISIS[atf2-9],0);  
							end
						end
					end
		   	   repeat frame; until(!mouse.left)
		   	end 
		   end   
		elseif(atf<0) 
			flags=1;  
			if(collision(type mouse))   
				alpha=200;
				if(mouse.left)
					switch(atf2)     
						case 1:  // nb joueurs
							if(serveur_NB_JOUEUR_MAX>MIN_JOUEURS) serveur_NB_JOUEUR_MAX+=atf; end   
						end
						case 2:	// map        
						   if(mapshoisis2>0)
							   MAPCHOISIS=Arene_fichiers[mapshoisis2-1];
							   mapshoisis2--;   
							   envoie_message(5,cript_string(Substr(MAPCHOISIS,0,4)),cript_string(Substr(MAPCHOISIS,4,4)),cript_string(Substr(MAPCHOISIS,8,4)));
						   end   
						end    
						case 3:	// changer de perso        
						   if(infos_JOUEURS[joueur_num].perso>0)
						   	infos_JOUEURS[joueur_num].perso--;
						   	envoie_message(7,joueur_num,infos_JOUEURS[joueur_num].perso,0); 
						   end   
						end    
						case 4:	// changer de limite 
							if(limite_mode[1]==0 && limite_mode>0)      
								limite_mode[1]=5;
	                     limite_mode--; 
							end
							if(limite_mode[1]>0)
								limite_mode[1]--; 
							end   
							envoie_message(8,limite_mode[1],limite_mode,0);
						end  
						case 10..14:	// changer d'arme
                     if(ARMES_CHOISIS[atf2-9]>(atf2==10))
                        ARMES_CHOISIS[atf2-9]--;
								envoie_message(9,atf2-9,ARMES_CHOISIS[atf2-9],0);  
							end
						end
					end
		   	   repeat frame; until(!mouse.left)
		   	end 
		   end
		end
	
		frame;
	end 
end       
 
process bouton(fnt,x,y,atf,str)       // boutons pour les menu
begin                        

   file=FPG_menu;
   z=father.z-1;
   //write(fnt,x,y,4,str);
   
   loop
   
     // if(menu_actuel <>8)
      	objet(x,y,z-1,file,write_in_map(fnt,str,4),region,size_x,size_y,angle,flags,alpha,1);
     // else   // lobby on ne centre plus les textes
        /* if(atf<>-5 && str<>"Retour")
         	objet(x,y,z-1,file,write_in_map(fnt,str,0),region,size_x,size_y,angle,flags,alpha,1);
        else      // sauf si c'est le pseudo
          	objet(x,y,z-1,file,write_in_map(fnt,str,4),region,size_x,size_y,angle,flags,alpha,1);  
         end                                                         */
      //end
      
      
      if(atf<>-2 && atf<>-10 && atf<>-11 && atf<>-5 && atf<>-12)  // cadre
         graph=2;
      end 
      
      if(atf==-10) // si c le truc pour rentrer l'ip du serveur
        str = ip_serveur; 
        // curseur "_"      
        if(atf2>=5) objet(x+text_width(fnt,str)/2,y+text_height(fnt,"L")/2,z-1,file,write_in_map(fnt," _",4),region,size_x,size_y,angle,flags,alpha,1);
           if(atf2>=10) atf2=0; end
        end atf2++;  
        // -----------
      end
      if(atf==-12) // si c le truc pour rentrer son nom
        str = JOUEUR_PROFIL.pseudo; 
        // curseur "_"      
        if(atf2>=5) objet(x+text_width(fnt,str)/2,y+text_height(fnt,"L")/2,z-1,file,write_in_map(fnt," _",4),region,size_x,size_y,angle,flags,alpha,1);
           if(atf2>=10) atf2=0; end
        end atf2++;  
        // -----------
      end  
      if(atf==-11) // si c le truc pour changer le nb de joueurs
        str = serveur_NB_JOUEUR_MAX;  // alors on affiche le nb
      end
   
      if(collision(type mouse))     // si on passe la souris dessus
         graph++;
         if(mouse.left && atf<>-2)  // si on clic dessus et que c'est clicable
            repeat objet(x,y,z-1,file,write_in_map(fnt,str,4),region,size_x,size_y,angle,flags,alpha,1);
            frame; until(!mouse.left) // attend qu'on ai finis de cliquer
            break;
         end
      end
      
      if(str=="Retour" && key(_esc))  // echap permet aussi de revenir au menu precedent
         repeat objet(x,y,z-1,file,write_in_map(fnt,str,4),region,size_x,size_y,angle,flags,alpha,1);
         frame; until(!key(_esc))
         break;
      end
   
      frame;
   end
   
   if(atf==-99)     // si on veut ne rien faire       
   	return;
   end
   if(menu_actuel>=8 && leader==0) // si on est connecté au serveur  
      // -- Se deconnecte du serveur --
   	fsock_socketset_free(0);
   	fsock_close(socket);
   	fsock_quit(); 
   	// ------------------------------
   end
   if(atf==8)              	// si on lance une nouvelle partie    
   	serveur();					// on lance le serveur
   	leader=1;               // c'est le nous qui avaons crée  
   	return;
   else                       // sinon le menu
   	menu_actuel = atf;      // nouvelle destination
   end
   
   if(atf==-1)    // si c'est un bouton qui quitte
      quitte();   // bah on quitte 
      return;
   end
   if(atf==1)     // si on veut recharger un nouveau profil
      save("profils\"+fichier[profil_charge],JOUEUR_PROFIL); // le sauvegarde
      profil_charge = -1;  // et le decharge 
   end
   if(atf==-13)     // si on veut créer un nouveau profil              
   	sauve();
   	return;
   end  
   affiche_menu();
end 
process sauve() // nouveau process car s_kill sur les boutons :/
begin
  	JOUEUR_PROFIL.nb_parties=JOUEUR_PROFIL.nb_tuer=JOUEUR_PROFIL.nb_mort=JOUEUR_PROFIL.nb_balle=JOUEUR_PROFIL.precision=0;  
	if(file_exists("profils\"+JOUEUR_PROFIL.pseudo+".wgprof"))
		existedeja(); 
		if(menu_actuel==2)
			return;
		end
	end
   save("profils\"+JOUEUR_PROFIL.pseudo+".wgprof",JOUEUR_PROFIL); // le sauvegarde   
   profil_charge=0;
   menu_actuel=3;   
   affiche_menu();
end  

process existedeja() // message si un profil existe déjà
begin

 	signal(father,s_sleep);
 	// --------------------
 	file=FPG_menu;
 	graph=8;z=father.z-3;
 	x =  ECRAN_tx/2;y =  ECRAN_ty/2;   // centré 
   bouton(FNT_menu,x,ECRAN_ty*35/100,-2,"Le profil "+JOUEUR_PROFIL.pseudo+" existe déjà !");
   bouton(FNT_menu,x,ECRAN_ty*40/100,-2,"Remplacer ?");
   bouton(FNT_menu,x,ECRAN_ty*55/100,3,"Oui");
   atf=bouton(FNT_menu,x,ECRAN_ty*65/100,2,"Non");
   repeat
   	frame;
   until(!exists(atf))
 	// --------------------
 	signal(father,s_wakeup); 
	  
end

process bouton_act(fnt,x,y,atf,pointer var)   
begin

	file=FPG_menu;
	
	str=write_int(fnt,x,y,0,var);
	
	while(menu_actuel==atf)  // quitte si on change de menu
		frame;
	end
   delete_text(str);
end   

process entrer_ip(); // pour entrer l'adresse ip  
begin
     
   texte_input(16,&ip_serveur);   //longueur max de l'ip: 16
        
	loop
      
   // objet(); // minicadre  
      
    	// texte lettre par lettre 
  		/*if(not key(_control)) // si on appuie pas sur control (pour eviter de marquer v quand on fait coller)
	 		IF(ascii==8)IF(len(ip_serveur)>1)ip_serveur=substr(ip_serveur,0,len(ip_serveur)-1);ELSE ip_serveur="";END END 
    		IF(ascii<>0 && ascii<>13)
     			if(len(ip_serveur)<=longueur_max)         //longueur max de l'ip (16)
      			IF(ascii<>8)ip_serveur+=chr(ascii);END
     			end
    		END
    		SWITCH(scan_code)     // pour les nombres
      		CASE 2..10:ip_serveur+=itoa(scan_code-1); ip_serveur=substr(ip_serveur,0,-1);END
      		CASE 11:ip_serveur+=0; ip_serveur=substr(ip_serveur,0,-1); END
      		CASE 74:ip_serveur+=chr(ascii);END
    		END 
  		end    */
    	// -----------------------   

    	// ---- Coller une ip ---- 
    	if(key(_control) && key(_v))  
    		ascii=0;    // (pour eviter de marquer v quand on fait coller)
			//ip_serveur = substr(GET_CLIPBOARD(),0,16);
    	end
    	// -----------------------
    
		//while(key(scan_code) && ascii<>8) frame; end // pour eviter que pleins de lettres s'ecrivent

   
     frame(frame_timeu);
   end
end 

process texte_input(zom_lim,string * zom_txt)     
Private
    int t,t2;
    byte last_ascii;
Begin
   loop     
   // --- code recupéré sur fenixdocs.com ----   
        if(ascii!=0&&last_ascii==ascii) // check if a key is pressed and if the same key
                                        // was pressed last frame
            if(t==0||t>fps/2) // check if the key was just pressed or it has been pressed
                              // for 0.25 seconds
                if(t==0||t2>fps/15) // check if the key was just pressed or it has been pressed
                                    // for the last 0.03 seconds
                    t2=0;
                    switch(ascii) // handle input
                        case 8: //backspace
                            *zom_txt = substr(*zom_txt,0,len(*zom_txt)-1);
                        end
                        case 13: //enter
                            //break;
                        end
                        default: //addkey
                            if(len(*zom_txt)<zom_lim)*zom_txt+=chr(ascii);end
                        end
                    end
                end
                t2++;
            end
            t++;
        else
            t = t2 = 0; // reset
        end
        last_ascii = ascii;
        frame(50);       
   // ---------------------------------------    
   End  
end

               /*
function int rande(x,y)         
begin
    
   rand_seed(get_timer());  
   return rand(x,y);  
   
end  
            */
process intro()       // Zigo Studio etc
begin

   /*signal(father,s_freeze);
   // ---------------------
   
   // ---------------------
   signal(father,s_wakeup);*/  

end

process quitte()
begin
   
   graph=get_screen();
   set_center(0,graph,0,0);x=0;y=0;z=-99999;
   let_me_alone();
   fade(0,0,150,4);
   while(fading) frame; end
   exit(); 

end
