
#define WG_version "1.0"

#define ECRAN_tx 1024
#define ECRAN_ty 768  

#define nb_fps 30.0
          
          
          
#define MIN_JOUEURS 1 // 1:pour tester 2:normal
#define MAX_JOUEURS 4
 
#define EN_LOBBY 0 
#define EN_JEU 1           
         
           
#define NB_MAX_PERSO 5 // le nombre maximum de personnages jouable   
         
#define NB_ARMES 10	  // le nombre total d'armes         

	// ---------- PERSOS
#define DONNEE_largeur_perso 100  	// 100*160
#define DONNEE_hauteur_perso 160  
#define DONNEE_vitesse 6 				// la vitesse de déplacement du persos
#define DONNEE_hauteur_saut 15     	// la hauteur des sauts (~100px)           
#define DONNEE_nb_max_armes 3       // nb maximum d'armes par joueurs  
	// ----------
#define DONNEE_duree_rechargement 25	// 25 frames
	// ---------- 
#define DONNEE_vit_disparition_cadavre 500	// vitesse de disparition des cadavre frame(x) 
#define DONNEE_distance_zone_apparition 550	// la largeur du carré dans lequel il faut qu'il y ai le moins de joueurs pour qu'il soit considéré comme le plus sûr
	// ---------- 
	
	// ---------- ERREURS
#define CORRIGE_HAUTEUR_PERSOS -20
#define CORRIGE_PLACE_MA 10				// placement mini armes   
	// ----------	
	
	// ---------- INTERFACE
#define DONNEE_X_MESSAGE ECRAN_tx/2			// coordonées des messages d'infos (munitions etc)     
#define DONNEE_Y_MESSAGE ECRAN_ty/2
	// ----------	   
	                                
	// ---------- DEGATS       
#define DONNEE_degat_corp 1.5        // selon quelle partie du corps on touche les degats son multipliés par...
#define DONNEE_degat_tete 2
#define DONNEE_degat_petit 4         // mesure des degats
#define DONNEE_degat_moyen 7 
#define ZTETE 1
#define ZCORPS 2
#define ZJAMBES 3
	// ----------   
	
	// ---------- MORTS DES PERSOS
#define MORT_GENOU 1
#define MORT_TREBUCHE 2	 
#define MORT_TOMBE 3
#define MORT_CORPS_GICLE 4
#define MORT_TETE_GICLE 5
	// ----------         
	
	// ---------- OBJETS
#define OBJET_ARME 1 
#define OBJET_BONUS 2
#define DONNEE_ARME_VITESS 3  // vitesse des armes pour arriver jusqu'au mec (en nb de frames) 
#define TEMPS_OBJET 30			// temps (seconde) moyen pour qu'un objet reaparaisse     
   // ----------                  
#define TEMPS_INVISIBLE 15 	 // temps invisible des qu'on prend l'objet (seconde)
	// ----------
 
// ---- TIMERS ---- 
// timer[0] -> 321go et durée de la partie
// timer[1-4] -> 1timer par joueur baby   
// timer[9]   -> timer pour syncronisation serveur-joueurs
// ----------------


 
 
   
// ---------------- Réseaux  ------------------------

#define PORT_CONNECTION 2300  // Le port a utiliser pour la connection
   
   
   // ----- CHAT ------
#define MAX_MSG_CHAT 6        // 7 message max (en contant le zero) 
   // -----------------   
   
#define NB_MAX_ARENES 10  


/*CONST

   ECRAN_tx = 1024;
   ECRAN_ty = 768;
   
   MIN_JOUEURS = 1; // 1:pour tester 2:normal
   MAX_JOUEURS = 4; 
   
   NB_MAX_PERSO = 5; // le nombre maximum de personnages jouable   
   

	// ---------- PERSOS
		DONNEE_largeur_perso = 100;  // 100*160
		DONNEE_hauteur_perso = 160;  
		DONNEE_vitesse = 6; 				// la vitesse de déplacement du persos
   	DONNEE_hauteur_saut = 15;     // la hauteur des sauts
	// ----------	 
   
// ---------------- Réseaux  ------------------------

   PORT_CONNECTION = 2300;  // Le port a utiliser pour la connection
   
   
   // ----- CHAT ------
   	MAX_MSG_CHAT = 6;        // 7 message max (en contant le zero) 
   // -----------------   
   
   NB_MAX_ARENES = 10;     */