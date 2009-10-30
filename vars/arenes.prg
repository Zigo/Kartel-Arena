// ---------------------------------------------
//   FICHIER QUI GERE LES ARENES ET LES ARMES
// ---------------------------------------------
type _co; x;y; end
type _coc; x;y;arm; end
global

   // ----
   dword hasard;       // sauvegarde le dernier resultat
   // ----
  
  
	MAP_COLLISION; 				// contiend la hardness map   
	MW;MH;						// taille de la map
	FPG_COL;							// fpg de la hardness map
	word MAP_SCROLL_BACKGROUND[3]; 	// max: 4 background de scroll  
	
	_co * MAP_RESPAWNS;		// les coordonnees des points de respawns	
	_coc * MAP_OBJETS;		// les coordonnees des spots d'objets
	_coc * MAP_ARMES;		   // les coordonnees des spots d'armes
	
	word NB_RESPAWNS,NB_RESP_OBJ,NB_RESP_ARM;               // nombre de respawns
	word NB_SCROLL;						// nombre de scroll   
	
	FPG_MAP;							// contien les images du terrain chargé     

     
process load_arene(str)    			// charge et prépare l'arene en utilisant son config.txt
private
	string contenu_config;        
	string categorie;
	string resultat[29]; 				
	fond_repeat[7];
begin   
 
      	/*Regex("!([a-z_0-9]*)=([\.*_a-z_0-9_,]*)!",contenu_config); 
   	resultat[0]=REGEX_REG[1];//nom de variable
   	WHILE(trim(REGEX_REG[2])!="")
     		IF(Regex("([a-z_0-9]*),([a-z_0-9_\._a-z_0-9_,]*)",REGEX_REG[2])>-1)
       		resultat[numero_case]=REGEX_REG[1];
     		ELSE resultat[numero_case]=REGEX_REG[2];REGEX_REG[2]="";END
     		numero_case++;
  		END  */     
  	
  	FPG_MAP = new_fpg(); 
  	fpg_add(FPG_MAP,1,0,super_load_png("Maps\"+str+"\map.png"));   // on y ajoute la map  
  	MW=graphic_info(FPG_MAP,1,G_WIDTH);
	MH=graphic_info(FPG_MAP,1,G_HEIGHT);
   //fpg_add(FPG_MAP,100,0,new_map(1,1,8));									// map vide pour les backgrounds
  		       
   contenu_config=file("Maps\"+str+"\config.txt");	// charge la config  

	contenu_config=regex_replace(chr(13) + chr(10),"",contenu_config);				// supprime les sauts de lignes    
	contenu_config=regex_replace(" ","",contenu_config);      						   // supprime les espaces
   contenu_config=regex_replace("	","",contenu_config);
    
   repeat        
      fto++;
   	atf2=Regex("!([A-Z_a-z_0-9]*)=([A-Z_a-z_0-9_,]*)!",contenu_config);  // recupere les categories et les parametres
   	categorie=REGEX_REG[1];                                 
   	atf=split(",",REGEX_REG[2],&resultat,30);  // separe les parametres et enregistre dans atf le nb de param
   	//say(categorie);  
   	switch(categorie);
   		case "version":
   			if(join(".",&resultat,atf)!=WG_version)
   				return -1;    
   			end
   		end
   		case "couleur":
				/*if(resultat[0]!="" && resultat[1]!="" && resultat[2]!="") 
					COULEUR_COLLISION = rgb(resultat[0],resultat[1],resultat[2]);
					//say(resultat[0]+","+resultat[1]+","+resultat[2]);
					//say(COULEUR_COLLISION);
				end*/
				if(resultat[0]!="" && resultat[1]!="")    
					if(file_exists("Maps\"+MAPCHOISIS+"\hmap.png"))      // si une hardness map on l'utilise
					   MAP_COLLISION = super_load_png("Maps\"+MAPCHOISIS+"\hmap.png"); 
					   FPG_COL=0; 
					else     
						MAP_COLLISION = 1;FPG_COL=FPG_MAP;  
					end       
					COULEUR_COLLISION = map_get_pixel(FPG_COL,MAP_COLLISION,atoi(resultat[0]),atoi(resultat[1]));
					//say(resultat[0]+","+resultat[1]+","+resultat[2]);
					//say("couleur collision: "+COULEUR_COLLISION);
				end
   		end 
   		case "fonds":  //say(resultat[0]);say(resultat[1]);
         	if(atf%2==0 or atf==1)       // si le nb de background est bien multiple de 2 
         		//say("atf: "+atf);say(resultat[0]);
	         	from x=0 to atf; 
	         		if(resultat[x]=="" or !file_exists("Maps\"+str+"\"+resultat[x]+".png")) break; end
						fpg_add(FPG_MAP,10+x,0,super_load_png("Maps\"+str+"\"+resultat[x]+".png")); 
						//say("map: "+resultat[x]+" ajoute a: "+(10+x));
						NB_SCROLL++; 
	         	end    
         	end
   		end           
    		case "fraport": 
    			if(NB_SCROLL>1)
         		from x=0 to NB_SCROLL-1 step 2; 
         			if(resultat[x]=="") break; end
         			scroll[x+1].ratio=abs(atoi(resultat[x+1])*100/atoi(resultat[x]));
         		end       
         	elseif(NB_SCROLL==1)
         		scroll[0].ratio=resultat[0];	
         	end
   		end
   		case "frepeat": 
    			if(NB_SCROLL!=0)
         		from x=0 to NB_SCROLL-1; 
         			if(resultat[x]=="") break; end
         			fond_repeat[x]=resultat[x];
         		end   
         	end
   		end  
   		case "fflags": 
    			if(NB_SCROLL>1)
         		from x=0 to NB_SCROLL-1 step 2; 
         			if(resultat[x]=="") break; end    
         			scroll[x+1].flags1=atoi(resultat[x]);
         			scroll[x+2].flags2=atoi(resultat[x+1]);
         		end   
         	elseif(NB_SCROLL==1)
         		scroll[0].flags2=atoi(resultat[0]);	
         	end
   		end 
   		case "respawns": //say(atf); 
   			MAP_RESPAWNS = alloc(atf*sizeof(_co));   // lui donne la mémoire necessaire 
         	from x=1 to 20 step 2;   
         		if(resultat[x-1]=="" or resultat[x]=="" ) break; end
         		MAP_RESPAWNS[NB_RESPAWNS+1].x=resultat[x-1];
         		MAP_RESPAWNS[NB_RESPAWNS+1].y=resultat[x]; 
         		NB_RESPAWNS++;
         	end   
   		end
   		case "objets":    
         	MAP_OBJETS = alloc(atf*sizeof(_coc));  
         	from x=0 to 27 step 3;   
         		if(resultat[x]=="" or resultat[x+1]=="" or resultat[x+2]=="" ) break; end
         		MAP_OBJETS[NB_RESP_OBJ+1].x=resultat[x];
         		MAP_OBJETS[NB_RESP_OBJ+1].y=resultat[x+1];
         		MAP_OBJETS[NB_RESP_OBJ+1].arm=resultat[x+2]; 
         		NB_RESP_OBJ++;
         	end      
   		end    
   		/*case "armes":    
         	from x=0 to 4;   
					ARMES_CHOISIS[x+1]=atoi(resultat[x]);
         	end  
   		end    */
   		case "armes":    
         	MAP_ARMES = alloc(atf*sizeof(_coc));  
         	from x=0 to 27 step 3;   
         		if(resultat[x]=="" or resultat[x+1]=="" or resultat[x+2]=="" ) break; end
         		MAP_ARMES[NB_RESP_ARM+1].x=resultat[x];
         		MAP_ARMES[NB_RESP_ARM+1].y=resultat[x+1];
         		if(atoi(resultat[x+2])<=5 && atoi(resultat[x+2])>0)MAP_ARMES[NB_RESP_ARM+1].arm=resultat[x+2];end 
         		NB_RESP_ARM++;  
         	end  
   		end      
   	end      
   	contenu_config=substr(contenu_config,atf2+len("!"+categorie+"="+REGEX_REG[2]+"!"));	// on continue l'exploration du fichier
   	
   until(contenu_config=="" or Regex("!([A-Z_a-z_0-9]*)=([A-Z_a-z_0-9_,]*)!",contenu_config)==-1)  
     
   if(NB_SCROLL==1) atf=10; else atf=0; end   // si qu'un seul background
   start_scroll(0,FPG_MAP,1,atf,0,(NB_SCROLL==1)*fond_repeat[0]*4);   // scroll principale   
   
   if(NB_SCROLL>1)         				// backgrounds de la map (si 2 ou plus)
   	fto=0;
   	from x=0 to (NB_SCROLL-1) step 2;      
   		fto++;
      	if(Map_Exists(FPG_MAP,10+x)!=1 && Map_Exists(FPG_MAP,10+x+1)!=1) break; end 
      	scroll[fto].follow=0;
      	scroll[fto].z=512+1+fto;           
      	start_scroll(fto,FPG_MAP,10+x,10+x+1,0,(fond_repeat[x] | (fond_repeat[x+1]*4))); 
      	//say("scroll: "+(fto)+" - graph1:"+(10+x)+" - graph2:"+(10+x+1)+" - repeat: "+(fond_repeat[x] | (fond_repeat[x+1]*4)));
      end  
   end  
   
end 

function trouve_arme() 
private string temp[5];
begin                

	str="0"+chr(13)+chr(10)+file("Maps\"+MAPCHOISIS+"\armes.txt");
	split(chr(13)+chr(10),str,&temp,6);
	from fto=0 to 5; ARMES_CHOISIS[fto]=atoi(temp[fto]); end 
	
end

function int super_load_png(str)      	// load_png sécurisé
begin

	if(file_exists(str))
		return load_png(str);
	end
	return load_png("vars\notfound.png");

end    

// ----------------------------------------------------------------------------------------
// --------------------------------------- ARMES ------------------------------------------
// ----------------------------------------------------------------------------------------
global
 
	struct donnees_armes[NB_ARMES];
		graph_balle,
		graph_viseur;viseur_tourne;viseur_size;
		nb2trou,precision,             					 // precision (=angle de dispertion (en degres))
		munition_depart,munition_par_chargeur,        // munition chargeur (-1=pas de chargeur)
		type_tir,delai_tir;vit_tir,degat_tir;         // type_tir (0=normal , 1=plasma , 2=lazer1)
		puissance;
		string nom;
	end = (0,0,0,0,0,0,0,0,0,0,0,0,0,""),
	/*1*/	(2 ,3 ,0   ,115,1,0 ,30,15,0,10,-1,5,2,"Fusil de merde"),
	/*2*/	(2 ,3 ,0   ,115,1,5 ,60,25,0,4 ,-1,4,3,"Mitrailleuse"),
	/*3*/	(22,23,1500,100,1,16,70,15,1,3 ,50,2,4,"Fusil-Plasma"),
	/*4*/	(2 ,3 ,0   ,115,2,10,50,15,0,3 ,-1,2,3,"Uzi"),
	/*5*/	(22,23,1500,100,2,0 ,50,20,1,3 ,50,2,4,"Auto-canon Plasma"),
	/*6*/	(2 ,52,0   ,100,6,5 ,70,-1,0,1 ,-1,1,5,"Minigun"),
	/*7*/	(2 ,3 ,0   ,115,1,2 ,55,20,0,5 ,-1,4,3,"AK-47"),
	/*8*/	(72,23,0   ,100,1,3 ,60,20,2,5 ,65,5,3,"Blaster-lazer");

// ---------- GENERATEUR DE FAUX HASARD pour les tirs des armes -------------- 
function int rand_tous_pareil(x,y)
begin 
	rand_seed(NB_MESSAGES+hasard*10);
	hasard++;  
	return rand(x,y);	
end      
// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------