/**
* Name: projet
* Based on the internal empty template. This is a simple IBM of the host-parasite system
* Author: Cyrine
* Tags: 
*/


model projet

/* Insert your model definition here */
global{
 int nb_init_vector<-400;
 int nb_init_Host<-500;
 float	distance_perception<- 1#m; 
 float proba_ajout<-0.2; 
 float maxNDVI<- 1.0; 
 float minNDVI<- 0.0;
 int nb_max_newH <- 30;
 
 //int nombre_S<-nombre_S ;
 
 
 	
 
  init {
  	create vecteur number:nb_init_vector;
  	create Host number:nb_init_Host;
  	
	 
	 //demander à chaque cellule de l'nevironnement à initialiser sa valeur en NDVI
	  ask environment {		
	  	NDVI<- 1 - (((color as list) at 0) / 255);
		NDVI_prod <- NDVI / 100; 
	  }
  }
 
   
  	reflex stop_sim when: cycle=1000 #cycles {
  	do pause;
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
 action activite {

	if ma_position.NDVI <=0.2{
		 est_actif<-false; 
		 }
		else { 
			est_actif<- true;
    }

	}
reflex mouvement when: est_actif=true {
	 do wander;
	 do activite;
	 }
reflex search_targt when: est_actif=true and self.target=nil {
		ask Host at_distance(distance_perception) {
        myself.target <- self;
	
}
	
    }
    reflex se_nourrir when: target!=nil and !dead(target)   {
    //speed <- 0.8;
    do goto target:target;
    //write attributes(target);
    write dead(target);
    self.speed<-target.speed; 
    self.location<-target.location+rnd(5);
    write self.target ;
    }
    /*if target.est_susceptible=true{
    	if  est_porteur=true {
    	target.est_infecte<-true; 
    	target.est_susceptible<-false;
    	//nb_hosts_infected <- nb_hosts_infected + 1;
    	target.color<- #yellow;
    }
    if target.est_susceptible=false and target.est_infecte and !est_porteur{
    	est_porteur<-true;
    	color<-#darkblue;
    }
    
    }
    self.location<-rnd(location) ;
   do wander;
    }*/
    reflex  devenir_infecte_target when: target!=nil  and !dead(target) {
			 if target.est_susceptible{
    		if (est_porteur=true) {
    			target.est_infecte<-true; 
    	        target.est_susceptible<-false;
        	   
	            	target.color <-  #yellow;       			
			}    }				
	}
	reflex devenir_porteur_vector when:target!=nil and !dead(target)  {
		if target.est_infecte{
		if est_porteur=false {
			est_porteur<-true;
			
		}
	}}

   
	reflex  tuer_vecteur when: flip(0.5){
		do die ; 
	}
	reflex ajout_vecteur {
		create vecteur number:1 {
			//est_porteur<- false; 
			// myself.location <- ma_position.location + rnd(0.05);
			//ma_position<-ma_position.location +rnd(0.05);
			do activite;
			
		}
	}
	
	 
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
     environment my_cell <- one_of (environment);
    // environment ma_position;
    bool dois_mourir;
    bool dois_repro;
    float proba_morta <-0.5;
    float proba_repro<-0.05;
     
	
	init{
		
		//location <- my_cell.location;
	
	   //my_cell <- one_of(environment where (each.NDVI>0));
		//location <- my_cell.location;
		
		if est_susceptible { color<- #black ;}
		else { 
			color<-#yellow; 
		}
		dois_mourir<-flip(proba_morta)? true:false;
		dois_repro<-flip(proba_repro)? true:false;
	}
	reflex deplacement_Host {
	environment cellule_cible <- (my_cell.neighbors2 where(each.NDVI!= 0.0)) with_max_of(each.NDVI);
		
		do goto target: cellule_cible ;
		//cellule_cible.NDVI<- cellule_cible.NDVI-cellule_cible.NDVI_prod;
		
	//location <- cellule_cible.location;
	}
	

	
	
reflex mortalite_Hote when: est_infecte=true and dois_mourir    {
	
		do die;
		}
 
	
reflex ajouter_Host when:  dois_repro  and every(200#cycles) {
	 
	 		create  Host  number:1{
	 			location <- myself.location+ rnd(0.1);
	 			self.est_susceptible<-true;
	 			self.est_infecte<-false;
	 	
			}
			}	
	 		
		
	aspect base {
		draw sphere(size) color:color;
	}
}



grid environment width:20 height: 20 neighbors: 4{
	
    float maxNDVI <- 1.0;
	float NDVI_prod <- rnd(0.5);
	list<environment> neighbors2 <- (self neighbors_at 4);

	
	float  NDVI <- rnd(1.0) max: maxNDVI  /*update:NDVI+NDVI_prod*/ update: flip(0.3)? NDVI+NDVI_prod:NDVI-NDVI_prod;
   rgb color <- rgb(int(255 * (1 - NDVI)), 255, int(255 * (1 - NDVI))) /*update: rgb(int(255 * (1 - NDVI)), 255, int(255 * (1 - NDVI)))*/;
			
	

}

experiment run_esp type:gui{
	parameter "nombre initial des vecteurs" var: nb_init_vector min:1 max: 3000 category: "Vecteur"; 
	parameter " nombre initial des hôtes" var: nb_init_Host min: 1 max: 1000 category: "Hôte";
	output {
		monitor 'Total Hôtes' value: length(Host);
		monitor 'Total Vecteur' value: length(vecteur); 
		display main_display {
			grid environment lines: #black;
			
			species vecteur aspect: defau;
			species Host aspect: base;
			
		}
		layout #split toolbars: false;
		display Hote_epidemio refresh: every(10#cycles) {
			chart "etat épidémio" type: series background: #lightgray /*style: exploded*/ {
				data "susceptible" value: Host count(each.est_susceptible) color: #green;
				data "infected" value: Host count(each.est_infecte) color: #red; 
				data"nombre total des hôtes" value: length(Host)  color: #blue; 
		}
		}
		display Vecteur_activite refresh: every(10# cycles) {
			chart" etat d'activité vecteur" type: series background: #lightgray {
				data "actif" value:vecteur count(each.est_actif=true) color: #green; 
				data "inactif" value:vecteur count(each.est_actif=false) color: #red; 
				data"nombre total des vecteurs" value: length(vecteur) color: #blue;
			}
			}
			display Vecteur_porteur_pathogene refresh: every(10# cycles) {
			chart" etat  épidémio vecteur" type: series background: #lightgray {
				data "porteur" value:vecteur count(each.est_porteur=true) color: #red; 
				data "non_porteur" value:vecteur count(each.est_porteur=false) color: #green; 
				data"nombre total des vecteurs" value: length(vecteur) color: #blue;
		
}
}
}
}

