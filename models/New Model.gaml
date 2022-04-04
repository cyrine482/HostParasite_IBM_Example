model green_and_red_species

global{
    float distance_to_intercept <- 10.0;
    int number_of_green_species <- 50;
    int number_of_red_species <- 50;
    
    init {
    create speciesA number:number_of_green_species;
    create speciesB number:number_of_red_species;
    }
}

species speciesA skills:[moving] {
    init {
    speed <- 1.0;
    }
    reflex move {
    do wander amplitude: 90.0;
    }
    aspect default {
    draw circle(1) color:#green border: #black;
    }
}

species speciesB skills:[moving] {
    speciesA target;
    init {
    speed <- 0.0;
    heading <- 90.0;
    }
    reflex search_target when: target=nil {
    ask speciesA at_distance(distance_to_intercept) {
        myself.target <- self;
    }
    }
    reflex follow when: target!=nil {
    speed <- 0.8;
    do goto target: target;
    }
    aspect default {
    draw circle(1) color:#red border: #black;
    if (target!=nil) {
        draw polyline([self.location,target.location]) color:#black;
    }
    }
}

experiment my_experiment type: gui {
    output{
    display myDisplay {
        species speciesA aspect:default;
        species speciesB aspect:default;
    }
    }
}