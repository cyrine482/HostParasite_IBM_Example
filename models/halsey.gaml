/**
* Name: halsey
* Based on the internal empty template. 
* Author: tenin
* Tags: 
*/


model halsey

/* Insert your model definition here */
global {
  int nb_init_vector<-400;
 int nb_init_Host<-500;
 float	distance_perception<- 1#m; 
 
 int meta_time; 
 float attach_rate;
 file my_file <- csv_file("../includes/output1.csv", true); //input Temperature Data 
	matrix matrice <-matrix(my_file);
	list temperature<- matrice column_at 1;
int j<-0;
float current_temp; 
 init {
  	create tick number:nb_init_vector;
  	create Host number:nb_init_Host;
}

}

grid environment width:20 height: 20 neighbors: 4{
	reflex SetEnvCdt when: every(500 #cycles) {
	       	current_temp<-temperature[j];     
	        //current_jour<- plus_days(current_jour,1);
	       // write current_jour; 
	       // add current_jour to: datess;
	       //// datess<-datess+current_jour;
	       	j<-j+1;
	      
	       }
	
	
}
species tick skills:[moving] control: fsm {
	rgb color<- #red; 
	Host target;
	bool replete; 
	environment ma_position;
	bool is_dormant; 
	//int eggnumber; 
	int time_to_replete;
	 //Boolean to determine if the agent is questing
     bool is_questing; 
     bool is_attached; 
     float grooming_rate;   
	 
	init{ 
	ma_position <- one_of(environment);
	}
		 reflex over_wintering {
	 	if current_temp<= 10 {
	 	is_dormant<- true; 
	 	} 
	 	else { if  current_temp<=15 and current_temp>10 {
	 		if state= adult {
	 			is_dormant <- false;  
	 		}
	 	else { if current_temp>15 and current_temp>=18 {
	 		if state=nymph {
	 			is_dormant<- false; 
	 		}
	 	else { if current_temp>18 {
	 		is_dormant<- false; 
	 	}}
	 	}}
	 	}
	 	}
	 }
reflex questing {
		if state!=egg and is_dormant= false { 
			is_questing<-true;
		}
	  }
reflex mouvement when: is_questing=true and state!= egg{
	 do move bounds: circle(15#m);
	 }
reflex find_target when: is_questing=true and target=nil and state!= egg {
		ask Host at_distance(distance_perception) {
        myself.target <- self;
	
}
}
reflex attach when: target!=nil and is_questing=true and flip(attach_rate) and state!= egg {
    //speed <- 0.8;
    do goto target: target;
    self.speed<-target.speed; 
    self.ma_position<-target.my_cell;
    is_attached<-true; 
    write target ;
    }
  action computetime {
	 	if state= nymph or state= larva {
	 		meta_time<- 7 #days ; 
	 	}
	 	if state=adult{
	 		meta_time<-14 #days;
	 	}
	 	
	 	}
/*reflex feeding	when: is_attached and state!= egg  and flip(grooming_rate) every (currentstep+time_to_replete) 	 {
	
	
}*/
action detach { 
    	if state= larva or state=nymph { 
    		time_to_replete<- 5 #days;  
    	}
    	else{
    		if state=adult {
    			time_to_replete<- 7 #days; 
    		}
    	}
    }
reflex detach when: target!=nil {
	//do detach;
 	environment new_location <- self.location+rnd(10 #m);
	 self.location<-new_location;
	 do goto target: new_location;
     // self.speed;
 	
 } 
	 state egg initial: true {
	 	
	 }
	 state larva {
	 	transition to: nymph  when: meta_time= 7 #days ; 
	 }
	 state nymph {
	 	
	 }
	 state adult {
	 	
	 }

	 action computetime {
	 	if state= egg or state= larva {
	 		meta_time<- 7 #days ; 
	 	}
	 	if state=adult{
	 		meta_time<-14 #days;
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
	//bool est_susceptible<-true;
	//bool est_infecte<- false; 
	//bool est_remis<-false;
	//int vision  min: 1 <- rnd(maxRange);
    environment my_cell <- one_of (environment);
    // environment ma_position;
     list<string> typeH <-["Rodent","cattle"];
     reflex deplacement_Host {
     	do wander;
     }
	
	aspect base {
		draw sphere(size) color:color;
	}

	}
	
	experiment run_esp type:gui{
	parameter "Initial number of  vectors" var: nb_init_vector min:1 max: 3000 category: "Vector"; 
	parameter "Initial number of hosts: " var: nb_init_Host min: 1 max: 1000 category: "Host";
	output {
		
		monitor"temperature" value:current_temp;
		
		display main_display {
			grid environment lines: #black;
			
			species tick aspect: defau;
			species Host aspect: base;
			
		}
		display Vecteur_activite refresh: every(10# cycles) {
			chart" etat d'activité vecteur" type: series background: #lightgray {
				data "actif" value:tick count(each.is_questing=true) color: #green; 
				data "inactif" value:tick count(each.is_questing=false) color: #red; 
				data"nombre total des vecteurs" value: length(tick) color: #blue;
			}
		}
		}}