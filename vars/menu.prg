//
// Architecture du menu
// 
// systeme avec des liens
//

GLOBAL

   struct ARC_MENU[8];
      
      string mtexte[3][1];
      typeu;
      menu_precedent;
   
   end                     

process declare_tous();
begin

   // ----- MENU 0 ------  Accueil
   
   ARC_MENU[0].typeu = 0; // menu simple (automatique)
   
   ARC_MENU[0].menu_precedent = -1;
   
   ARC_MENU[0].mtexte[0][0] = "Nouveau jeu";
   ARC_MENU[0].mtexte[0][1] = 1;
   ARC_MENU[0].mtexte[1][0] = "Options";
   ARC_MENU[0].mtexte[1][1] = 4;
   ARC_MENU[0].mtexte[2][0] = "Quitter";
   ARC_MENU[0].mtexte[2][1] = -1;

   // -------------------
   
   // ----- MENU 1 ------   Nouveau jeu
   
   ARC_MENU[1].typeu = 1; // menu non automatique
   
   ARC_MENU[1].menu_precedent = 0;

   ARC_MENU[1].mtexte[0][0] = "Choisissez votre profil :";
   ARC_MENU[1].mtexte[0][1] = -2;      // aucun effet si on clic dessus
   ARC_MENU[1].mtexte[1][0] = "Nouveau profil";
   ARC_MENU[1].mtexte[1][1] = 2;
   // cadre pour choisir son profil
   ARC_MENU[1].mtexte[2][1] = 3;

   // -------------------
   
   // ----- MENU 2 ------  Nouveau profil
   
   ARC_MENU[2].typeu = 1; // menu non automatique
   
   ARC_MENU[2].menu_precedent = 1;

   ARC_MENU[2].mtexte[0][0] = "Nouveau profil";
   ARC_MENU[2].mtexte[0][1] = -2;
   ARC_MENU[2].mtexte[1][0] = "Nom du profil :";
   ARC_MENU[2].mtexte[1][1] = -2;
   ARC_MENU[2].mtexte[2][0] = "Valider";
   ARC_MENU[2].mtexte[2][1] = -13;

   // -------------------
   
   // ----- MENU 3 ------

   ARC_MENU[3].typeu = 0; // menu automatique
   
   ARC_MENU[3].menu_precedent = 1;
   
   ARC_MENU[3].mtexte[0][0] = "Nouvelle partie";
   ARC_MENU[3].mtexte[0][1] = 5;
   ARC_MENU[3].mtexte[1][0] = "Rejoindre partie";
   ARC_MENU[3].mtexte[1][1] = 6;

   // -------------------
   
   // ----- MENU 4 ------  OPTIONS

   ARC_MENU[4].typeu = 0; // menu automatique

   ARC_MENU[4].menu_precedent = 0;

   ARC_MENU[4].mtexte[0][0] = "Volume sons et musiques";
   ARC_MENU[4].mtexte[0][1] = -2;
   ARC_MENU[4].mtexte[1][0] = "Che pas";
   ARC_MENU[4].mtexte[1][1] = -2;

   // -------------------
   
   // ----- MENU 5 ------   Nouvelle partie

   ARC_MENU[5].typeu = 1; // menu non automatique

   ARC_MENU[5].menu_precedent = 3;

   ARC_MENU[5].mtexte[0][0] = "- Nouvelle partie -";
   ARC_MENU[5].mtexte[0][1] = -2;
   ARC_MENU[5].mtexte[1][0] = "Nombres max. de joueurs :";
   ARC_MENU[5].mtexte[1][1] = -2;
   ARC_MENU[5].mtexte[2][0] = "Créer !";
   ARC_MENU[5].mtexte[2][1] = 8;

   // -------------------
   
   // ----- MENU 6 ------   Rejoindre partie
   
   ARC_MENU[6].typeu = 1; // menu non automatique

   ARC_MENU[6].menu_precedent = 3;

   ARC_MENU[6].mtexte[0][0] = "Rejoindre une partie";
   ARC_MENU[6].mtexte[0][1] = -2;
   ARC_MENU[6].mtexte[1][0] = "Veuillez entrer l'ip du serveur :";
   ARC_MENU[6].mtexte[1][1] = -2;
   // quand on a mis l'ip on va a:
   ARC_MENU[6].mtexte[2][1] = 7;
   ARC_MENU[6].mtexte[3][0] = "Se connecter";
   ARC_MENU[6].mtexte[3][1] = 7;
   // -------------------
   
   // ----- MENU 7 ------    conection (client)

   ARC_MENU[7].typeu = 1; // menu non automatique

   ARC_MENU[7].menu_precedent = 6;

   ARC_MENU[7].mtexte[0][0] = "La connection à échoué";
   ARC_MENU[7].mtexte[0][1] = -2;
   ARC_MENU[7].mtexte[1][0] = "Connection au serveur en cour";
   ARC_MENU[7].mtexte[1][1] = -2; 
   // si on a réussi a se connecter
   ARC_MENU[7].mtexte[2][1] = 8;
   ARC_MENU[7].mtexte[3][0] = "Le serveur est plein !";
   ARC_MENU[7].mtexte[3][1] = -2;
   // -------------------
   
   // ----- MENU 8 ------    Lobby (client ET serveur)

   ARC_MENU[8].typeu = 1; // menu non automatique

   ARC_MENU[8].menu_precedent = 3;

   ARC_MENU[8].mtexte[0][0] = "Nombre de joueurs connectés: ";
   ARC_MENU[8].mtexte[0][1] = "Vous êtes le joueur n ";
   ARC_MENU[8].mtexte[1][0] = "Joueurs";
   ARC_MENU[8].mtexte[1][1] = "Arène";
   ARC_MENU[8].mtexte[2][0] = "Armes";
   ARC_MENU[8].mtexte[2][1] = "Chat";
   ARC_MENU[8].mtexte[3][0] = "Infos";
   ARC_MENU[8].mtexte[3][1] = "Mode de jeu: DEATHMATCH";

   // -------------------
   

end
