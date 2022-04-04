/**
* Name: Model1
* Based on the internal empty template. 
* Author: Cyrine
* Tags: 
*/


model Model1

/* Insert your model definition here */
global{
	float taux_similaire_souhaite<-0.6; 
	float distance_voisins<-5.0; 
	int nb_habitant_heureux<-0 update: habitant count(each.est_heureux);
	int nb_habitant<-2000;
	
	init{
		create habitant number: 1000;
	}
	reflex fin_similation when: nb_habitant_heureux=nb_habitant{
		 do pause;
	}
	
}
species habitant{
	rgb couleur<-flip(0.5)? #red:#yellow; 
	float taux_similaire<-0.0; 
	bool est_heureux<-false; 
	
	list<habitant> voisins update: habitant at_distance distance_voisins;
	
	reflex  definir_si_heureux{
		
		if(empty(voisins)){
			taux_similaire <-1.0;
			 		
		}else {
			int nb_voisins<-length(voisins);
			int nb_voisins_sim<- voisins count (each.couleur=couleur);
			taux_similaire<- nb_voisins_sim/nb_voisins; 
		}
		est_heureux <-taux_similaire >=taux_similaire_souhaite;
	}
	
	reflex se_deplacer when:not est_heureux{
		location <-any_location_in(world);
	}
	aspect afficherCercle{
		draw circle(1) color:couleur border: #black;
	}
	
}
experiment My_experiment type: gui{
	parameter "nb habitants" var: nb_habitant;
	parameter "taux similaire souhaité" var: taux_similaire_souhaite;
	parameter "distance voisins" var: distance_voisins;	
	output{
		display mesAgentsHabitants  /*type: java2D*/{
			species habitant aspect: afficherCercle;
			}
		display graphique {
			chart "evolution heureux " type: series{
			data"nb voisisns heureux"  value:  nb_habitant_heureux color: #green;
		}
		}
		
	}
}
