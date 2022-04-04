/**
 *  chouChevLoup7
 *  Author: bgaudou
 *  Description: Les loups et les chevres se reproduisent quand ils ont une energie suffisante.
 */

model ChouChevLoupFinal

global {
	float taux_croissance <- 0.2 ;
	float capacite_max <- 10.0;
	float energie_max <- 50.0;
	float biomasse_prelevee_max <- 1.5;	
	float taux_reproduction <- 0.7;

	init {
		create chevre number: 10;
		create loup number: 3;
	}
}

species animal {
	parcelle ma_parcelle;
	float energie <- energie_max;
	
	init {
		ma_parcelle <- one_of(parcelle where (each.est_libre = true));
		location <- ma_parcelle.location;
		ma_parcelle.est_libre <- false;
	}

	reflex deplacement {
		parcelle parcelle_cible <- one_of(ma_parcelle.neighbors where(each.est_libre = true));
		do deplacement_vers(parcelle_cible);
	}	

	action deplacement_vers(parcelle nouvelle_parcelle) {
		if(nouvelle_parcelle != nil) {
			ma_parcelle.est_libre <- true;
			nouvelle_parcelle.est_libre <- false;
			ma_parcelle <- nouvelle_parcelle;
			location <- nouvelle_parcelle.location;
			
			energie <- energie - 1.0;			
		}		
	}	
	
	reflex donner_naissance when: (energie > taux_reproduction * energie_max) {
		parcelle parcelle_cible <- one_of(ma_parcelle.neighbors where(each.est_libre = true));
		
		if(parcelle_cible != nil) {
			create species(self) {
				energie <- myself.energie / 2;
				do deplacement_vers(parcelle_cible);
			}
			energie <- energie / 2;		
		}
	}	
	
	reflex test_energie when: (energie < 0.0) {
		ma_parcelle.est_libre <- true;		
		do die;
	}	
}

species loup parent: animal{

	reflex manger {
		list<chevre> proies <- [];
		proies <- ma_parcelle.neighbors accumulate(chevre inside each);
		chevre proie <- proies with_max_of(each.energie);

		if(proie != nil) {
			energie <- min([energie_max,proie.energie]);
			ask proie {
				ma_parcelle.est_libre <- true;				
				do die;
			}			
		}
	}
	
	aspect cercleRouge {
		draw circle(1) color: #red;
	}
}

species chevre parent: animal {

	reflex deplacement {
		parcelle parcelle_cible <- (ma_parcelle.neighbors where(each.est_libre = true)) with_max_of(each.biomasse);
		
		do deplacement_vers(parcelle_cible);
	}

	reflex manger {
		float energie_prelevee <- min([biomasse_prelevee_max,ma_parcelle.biomasse]);
		ma_parcelle.biomasse <- ma_parcelle.biomasse - energie_prelevee;
		energie <- min([energie + energie_prelevee,energie_max]);
	}

	aspect carreBleu {
		draw square(2) color: #blue;
	}
}

grid parcelle height: 30 width: 30 neighbors: 8 {

	float biomasse;
	float capacite_chou;
	rgb color update: rgb(0,255*biomasse/capacite_max,0);		
		
	bool est_libre <- true;
	
	init {		
		capacite_chou <- rnd(capacite_max);		
		biomasse <- rnd(capacite_chou);
		color <-  rgb(0,255*biomasse/capacite_max,0);	
	}	
	
	reflex croissance {
		if(capacite_chou != 0){
			biomasse <- biomasse * (1 + taux_croissance * (1 - biomasse/capacite_chou));	
		}
	}
}


experiment chouChevLoupExp type: gui {
	output {
		display biomass {
			grid parcelle lines: #black;
			species loup aspect: cercleRouge;
			species chevre aspect: carreBleu;
		}

		display animaux {
			chart "animaux" type: series {
				data "biomasse" value: parcelle sum_of(each.biomasse) / 10 color: #green;
				
				data "#chevres" value: length(chevre) color: #blue;
				data "#loups" value: length(loup) color: #red;
			}
		}					
	}
}
