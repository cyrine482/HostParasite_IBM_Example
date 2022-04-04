/**
* Name: projet
* Based on the internal empty template. 
* Author: Cyrine
* Tags: 
*/


model projet

/* Insert your model definition here */
global{
 int nb_init_vector<-400;
 int nb_init_Host<-500;
 float	distance_perception<- 1#m; 
 float proba_ajout<-0.5;

 list<agent> listvector;
 list<agent> listHost; 
 float maxNDVI<- 1.0; 
 float minNDVI<- 0.0;
 int nb_max_newH <- 30;
 //int nombre_S <-nb_init_Host; 
 int nombre_S<-nombre_S ;
 int nombre_I;
 int nombre_R;
 int nombre_P;
 int nombre_actif;
 int numberHosts <- nombre_S+nombre_I+nombre_R;
 
 list<Host> infecte<-[];
	
 
  init {
  	create vecteur number:nb_init_vector;
  	create Host number:nb_init_Host;
  	 //listvector <- list<agent> (vector);
	 //listHost <- list<agent> (Host);
	 
	 //demander à chaque cellule de l'nevironnement à initialiser sa valeur en NDVI
	  ask environment {		
	  	NDVI<- 1 - (((color as list) at 0) / 255);
		NDVI_prod <- NDVI / 100; 
	  }
  }
 
   reflex calculer_nb_infecte {
   		nombre_I <- Host count (each.est_infecte);
   }  
   reflex calculer_nb_porteur{
   	 nombre_P<- vecteur count(each.est_porteur);
   }
   reflex calculer_nb_actif{
   	nombre_actif<- vecteur  count(each.est_actif);
   } 
   reflex calculer_nb_s{
   	nombre_S<- Host count(each.est_susceptible);
   }  
   reflex calculer_nb_R {
   	nombre_R<- Host count(each.est_remis);
   }  
  	
}
species vecteur skills:[moving] {
	rgb color; 
	Host target;
	bool est_actif;
	environment ma_position;
	bool est_porteur;
	float rate  <- 0.0;
	int nb_hosts_infected;
	
init{ 
	ma_position <- one_of(environment); /*where (each.NDVI>0));*/
	//location <- ma_position.location;
	speed <- 2.0#m;
    //heading <- 90.0;
	    
	est_porteur<- flip(0.5)? true:false;
	if est_porteur { color<- #red ;}
		else { 
			color<-#green; 
		}
	if ma_position.NDVI <=0.2{
		 est_actif<-false; }
		else { 
			est_actif<- true;
	
	}

}
reflex mouvement when: est_actif=true {
	 do wander;
	 }
reflex when: est_actif=true and target=nil {
		ask Host at_distance(distance_perception) {
        myself.target <- self;
	
}
	//do wander;
    /*reflex search_target when: target=nil and est_actif=true {
    ask Host at_distance(distance_perception)/*parallel:true*/ /*{
        myself.target <- self;
    }*/
    }reflex se_nourrir when: target!=nil  {
    //speed <- 0.8;
    do goto target: target;
    self.speed<-target.speed; 
    self.ma_position<-target.my_cell;
    write target ;
    /*if target.est_susceptible=true{
    	if  est_porteur=true {
    	target.est_infecte<-true; 
    	target.est_susceptible<-false;
    	nb_hosts_infected <- nb_hosts_infected + 1;
    	target.color<- #yellow;
    }
    
   
    }
     else {
    if target.est_infecte and !est_porteur{
    	est_porteur<-true;
    	color<-#darkblue;
    }
    
    } */
   // self.location<-rnd(location) ;
    do wander;
    }
    
    reflex activite {

	if ma_position.NDVI <=0.2{
		 est_actif<-false; 
		 }
		else { 
			est_actif<- true;
    }

	}
	/*reflex se_nourrir {
		 // voir les cdts des combinaisons (voir tableau) pour le changement de l'état épidémio( vecteur +hôtes) 
	}*/
	// reflex die pour les vecteurs ( fin de cycle de vie ( mortalité)  
	//  ajout de nouveaux  vecteur pour la dynamique 
	aspect defau {
		draw square(0.7) color: color rotate: 90 + my heading;
	}
	
}


species Host skills:[moving] {
	rgb color ;
	float speed <- 0.3;
	float size<- 0.5;
	bool est_susceptible<-true;
	bool est_infecte<- false; 
	bool est_remis<-false;
	//int vision  min: 1 <- rnd(maxRange);
     environment my_cell <- one_of (environment);
    // environment ma_position;
     
	
	init{
		
		//location <- my_cell.location;
	
	   //my_cell <- one_of(environment where (each.NDVI>0));
		//location <- my_cell.location;
		
		if est_susceptible { color<- #black ;}
		else { 
			color<-#yellow; 
		}
	}
	reflex deplacement_Host {
	environment cellule_cible <- (my_cell.neighbors2 where(each.NDVI!= 0.0)) with_max_of(each.NDVI);
		
		do goto target: cellule_cible ;
		//cellule_cible.NDVI<- cellule_cible.NDVI-cellule_cible.NDVI_prod;
		
	//location <- cellule_cible.location;
	}
	
	/*reflex manger_host {
		//cell(self).;
	//location 		self.agent.location
	if my_cell.NDVI >= 0.1{
	my_cell.NDVI <- my_cell.NDVI-0.1;
	
	}
	
	}
	/*do deplacement_vers(one_of(environment where (each.iv>0)));
	my_cell<- one_of(environment where (each.NDVI>0));
			location <- my_cell.location;
	
	}*/
	

   reflex ajouter_Host when: (flip(proba_ajout)) {
		int nb_offsprings <- rnd(1, nb_max_newH);
		create Host number: nb_offsprings {
			my_cell <- myself.my_cell;
			location <- my_cell.location+ rnd(0.1);
			
			}
			}
	
	
	reflex mortalite_Hote when: est_infecte  {
		est_remis <- true;
		do die; 
		
		
	} 
	// reflex die qd l etat infected dépasse une durée seuil ( à préciser selon la littérature)  et  ajout de nouveaux hotes pour la dynamique 
	
	
	// reflex compteur des S et I et R( mortalité) 
	aspect base {
		draw sphere(size) color:color;
	}
}


grid environment width:20 height: 20 neighbors: 4{
	// voir la loi qui régisssent l'indice de végétation.
    float maxNDVI <- 1.0;
	float NDVI_prod <- rnd(0.5);
	list<environment> neighbors2 <- (self neighbors_at 4);
/*init {
	 NDVI <- rnd(1.0);
	 rgb color <- rgb(int(255 * (1 - NDVI)), 255, int(255 * (1 - NDVI)));
	 NDVI_prod <- rnd(0.5);
   
}*/
	
	float  NDVI <- rnd(1.0) max: maxNDVI  /*update:NDVI+NDVI_prod*/ update: flip(0.5)? NDVI+NDVI_prod:NDVI-NDVI_prod;
   rgb color <- rgb(int(255 * (1 - NDVI)), 255, int(255 * (1 - NDVI))) /*update: rgb(int(255 * (1 - NDVI)), 255, int(255 * (1 - NDVI)))*/;
			
	
	
	/*reflex miseajour {
		NDVI<-NDVI+rnd(0.8);
		color<- rgb(int(255 * (1 - NDVI)), 255, int(255 * (1 - NDVI)));
	}*/
}

experiment run_esp type:gui{
	parameter "Initial number of  vectors" var: nb_init_vector min:1 max: 3000 category: "Vector"; 
	parameter "Initial number of hosts: " var: nb_init_Host min: 1 max: 1000 category: "Host";
	output {
		display main_display {
			grid environment lines: #black;
			
			species vecteur aspect: defau;
			species Host aspect: base;
			
		}
		display chart refresh: every(100#cycles) {
			chart "etat épidémio" type: series background: #lightgray /*style: exploded*/ {
				data "susceptible" value: nombre_S color: #green;
				data "infected" value: nombre_I color: #red;
				data "remis" value: nombre_R color: #yellow; 
				data"nombre total des hôtes" value: length(Host) color: #blue;
				//data "immune" value: Host count (each.is_immune) color: #blue;
		// ajouter des graphes des états epidémio des hotes ( S, I R) 
}	
}
}
}