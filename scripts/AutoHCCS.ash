script "Automatic 2-day Hardcore Community Service";
notify aabattery;
since r16363;
//courtesy of yojimboS_LAW's 2-day HC guide
//shoutouts to Cheesecookie, Ezandora, and Cannonfire40 for contributing a bit of code/advice
//additional contributions from RESPRiT and Croft
import "zlib.ash";

// ---------------------------------------------------------------------------
// Configuration

boolean alwaysG9 = get_property("acs_alwaysG9").to_boolean();
familiar alwaysFam;
if(have_familiar(get_property("acs_100familiar").to_familiar())) {
	alwaysFam = get_property("acs_100familiar").to_familiar();
}
boolean doSoftcore = get_property("acs_doSoftcore").to_boolean();
boolean buyPulls = get_property("acs_buyPulls").to_boolean();
int pullBudget = get_property("acs_pullBudget").to_int();
boolean doCheckpoints = get_property("acs_doCheckpoints").to_boolean();
boolean smashHippyStone = get_property("acs_smashHippyStone").to_boolean();
boolean actuallyrun;
if(get_property("acs_actuallyRun") == "") {
	actuallyrun = true;
} else {
	actuallyrun = get_property("acs_actuallyRun").to_boolean();
}

// ---------------------------------------------------------------------------

//woulda liked a #define or const here but hey I'll take what I can get
int HPTEST = 1;
int MUSTEST = 2;
int MYSTTEST = 3;
int MOXTEST = 4;
int FAMTEST = 5;
int WPNTEST = 6;
int SPELLTEST = 7;
int COMTEST = 8;
int ITEMTEST = 9;
int HOTTEST = 10;
int COILTEST = 11;

boolean lockFamiliar = false; // internal familiar locking (not for 100% runs)

// ---------------------------------------------------------------------------
// statemap functions

int [string] statemap;

void loadSave() {
	file_to_map("AutoHCCSvars.txt", statemap);
}

void newSave() {
	statemap["questStage"] = 0;
	statemap["skippingIsland"] = 0;
	statemap["run"] = get_property("knownAscensions").to_int();
	map_to_file(statemap, "AutoHCCSvars.txt");
}

void saveProgress(int questStage) {
	statemap["questStage"] = questStage;
	map_to_file(statemap, "AutoHCCSvars.txt");
}

void saveChateau(int chateau) {
	statemap["chateau"] = chateau;
	map_to_file(statemap, "AutoHCCSvars.txt");
}

void skipIsland() {
	statemap["skippingIsland"] = 1;
	map_to_file(statemap, "AutoHCCSvars.txt");
}

boolean islandSkipped() {
	if (statemap["skippingIsland"] == 1) {
		return true;
	} else {
		return false;
	}
}

boolean gr8psAvailable() {
	if (statemap["chateau"] == 2) {
		return true;
	} else {
		return false;
	}
}

// ---------------------------------------------------------------------------
// General utility functions

boolean get_property_boolean(string property) {
	return get_property(property).to_boolean();
}

int get_property_int(string property) {
	return get_property(property).to_int();
}

// ---------------------------------------------------------------------------
// Familiar functions

void decorateShrub() {
	familiar current = my_familiar();
	if(have_familiar($familiar[Crimbo Shrub]) && !get_property_boolean("_shrubDecorated")) {
		use_familiar($familiar[Crimbo Shrub]);
		visit_url("inv_use.php?pwd=&which=3&whichitem=7958");
		visit_url("choice.php?pwd=&whichchoice=999&option=1&topper=2&lights=1&garland=1&gift=1");
	}
	use_familiar(current);
}

familiar getSpleenFamiliar() {
	foreach spleener in $familiars[Golden Monkey, Grim Brother, Unconscious Collective] {
		if (have_familiar(spleener) && (alwaysFam == spleener || alwaysFam == $familiar[none]))
			return spleener;
	}
	return $familiar[none];
}

void setItemFamiliar() {
	if(alwaysFam != $familiar[none]) {
		use_familiar(alwaysFam);
	} else {
		foreach itemer in $familiars[Steam-Powered Cheerleader, Jumpsuited Hound Dog, Adventurous Spelunker, Grimstone Golem, Angry Jung Man, Baby Gravy Fairy] {
			if (have_familiar(itemer)) {
				use_familiar(itemer);
				if ($item[astral pet sweater].available_amount() > 0) {
					equip($item[astral pet sweater]);
				}
				return;
			}
		}
	}
}

void setFamiliar() { //idk about this but something's better than nothing...I'd throw puck-man here but then I'd have to unlock the woods so meh
	if(alwaysFam != $familiar[none]) {
		use_familiar(alwaysFam);
	} else if (!lockFamiliar) {
		familiar spleener = getSpleenFamiliar();
		int desiredSpleenDrops = 3;
		if (my_daycount() == 2)
			desiredSpleenDrops = 1;
		if (my_daycount() == 1 && have_familiar($familiar[Fist Turkey]) && $familiar[Fist Turkey].drops_today < 1) {
			use_familiar($familiar[Fist Turkey]);
		} else if (spleener != $familiar[none] && spleener.drops_today < desiredSpleenDrops) {
			use_familiar(spleener);
		} else if (have_familiar($familiar[Galloping Grill])) {
			use_familiar($familiar[Galloping Grill]);
		} else if (have_familiar($familiar[Crimbo Shrub])) {
			use_familiar($familiar[Crimbo Shrub]);
		} else if (have_familiar($familiar[Smiling Rat])) {
			use_familiar($familiar[Smiling Rat]);
		}
		if ($item[astral pet sweater].available_amount() > 0) {
			equip($item[astral pet sweater]);
		}		
	}
}

//---------------------------------------------------------------------------
// Use functions

boolean useIfHave(int howmany, item what) {
	if(what.available_amount() >= howmany) {
		use(howmany, what);
		return true;
	} else if(what.available_amount() > 0) {
		use(what.available_amount(), what);
		return true;
	} else {
		return false;
	}
}

void useTaffies(item taffy) {
	if (taffy.available_amount() >= 5) {
		use(5, taffy);
	} else {
		useIfHave(taffy.available_amount(), taffy);
	}
}

//---------------------------------------------------------------------------
// Softcore functions

boolean pullDaily() {
	if (in_hardcore()) {
		return false;
	}
	int [item] pullList;
	// Determine pull list
	for i from 1 to 5 {
		pullList [get_property("acs_day"+ my_daycount() +"Pull"+ i).to_item()] += 1;
	}
	foreach pull in pullList {
		if (pulls_remaining() > 0) {
			if (storage_amount(pull) == 0) {
				if (buyPulls) {
					if (mall_price(pull) > pullBudget) {
						print("Failed to buy " + pull + " because it exceeded the pull budget.", "red");
						continue;
					} else if (!buy_using_storage(pullList[pull], pull)) {
						print("Failed to buy " + pull + "!", "red");
						continue;
					} else {
						print("Purchased " + pull, "blue");
					}
				} else {
					print("We are not pulling " + pull + " because it is not in storage and we are not buying items.", "red");
				}
			}
			// Finally pulls item
			if (!take_storage(1, pull)) {
				print("Failed to pull " + pull + "!", "red");
			} else {
				print("Pulled " + pull, "blue");
			}
		}
	}
	return true;
}

// A bit janky but it works!
boolean useForTest(string test) {
	if (in_hardcore() || !doSoftcore) {
		return false;
	}
	boolean useFound = false;
	for i from 1 to 5 {
		for j from 1 to 2 {
			if(get_property("acs_day" + j + "Pull" + i + "_test") == test) {
				print("Using " + get_property("acs_day" + j + "Pull" + i) + " for test " + test, "blue");
				useIfHave(1, get_property("acs_day" + j + "Pull" + i).to_item());
				useFound = true;
			}
		}
	}
	if(!useFound) {
		print("I didn't find any items to use for test " + test, "orange");
	}
	return useFound;
}

//---------------------------------------------------------------------------
// Cast functions

int free_rests_left() {
	return total_free_rests() - get_property_int("timesRested");
}

boolean free_rest() {
	if (free_rests_left() > 0) {
		visit_url("place.php?whichplace=chateau&action=chateau_restlabelfree");
		return true;
	} else {
		return false;
	}
}

void cast(skill which) { //just casts it if you have it.
	if (have_skill(which)) {
		use_skill(which);
	}
}

void chateauCast(skill which) { //casts the skill as normal (if you have it), unless you don't have the MP, in which case it will use a free rest at the chateau first
	if (have_skill(which)) {
		if (my_mp() >= mp_cost(which)) {
			use_skill(which);
		} else if (free_rest()) {
			if (my_mp() >= mp_cost(which)) {
				use_skill(which);
			} else {
				abort("Failed to cast " + to_string(which) + " even after a Chateau rest...");
			}
		} else {
			while ((my_soulsauce() >=5) && (my_mp() < mp_cost(which))) {
				use_skill(1, $skill[Soul Food]);
			}
			if (my_mp() >= mp_cost(which)) {
				use_skill(which);
				return;
			}
			restore_mp(mp_cost(which));
			print("Ran out of MP and free rests; had to restort to meat-MP instead", "red");
			if (my_mp() >= mp_cost(which)) {
				use_skill(which);
			} else {
				abort("Failed to cast " + to_string(which) + " even after restoring MP...");
			}
		}
	}
}

void summonDailyStuff() {
	use_skill(3, $skill[Summon Smithsness]);
	chateauCast($skill[Summon Confiscated Things]);
	chateauCast($skill[Advanced Saucecrafting]);
	chateauCast($skill[Advanced Cocktailcrafting]);
	chateauCast($skill[Pastamastery]);
	chateauCast($skill[Grab a Cold One]);
	//chateauCast($skill[Spaghetti Breakfast]);
	visit_url("campground.php?action=garden");
	visit_url("campground.php?action=workshed");
	visit_url("place.php?whichplace=chateau&action=chateau_desk2");
	if(!in_hardcore() && doSoftcore) {
		pullDaily();
    }
	if (have_skill($skill[Summon Taffy])) {
		while (mp_cost($skill[Summon Taffy]) < 30) {
			chateauCast($skill[Summon Taffy]);
		}
	}
}

void basicItemDropBuffs() {
	if (have_effect($effect[Leash of Linguini]) == 0) {
		chateauCast($skill[Leash of Linguini]);
	}
	if (have_effect($effect[Empathy]) == 0) {
		chateauCast($skill[Empathy of the Newt]);
	}
	if (have_effect($effect[Fat Leon's Phat Loot Lyric]) == 0) {
		chateauCast($skill[Fat Leon's Phat Loot Lyric]);
	}
	if (have_effect($effect[Singer's Faithful Ocelot]) == 0) {
		chateauCast($skill[Singer's Faithful Ocelot]);
	}
}

void allStatBuffs() {
	if (have_effect($effect[Song of Bravado]) == 0) {
		chateauCast($skill[Song of Bravado]);
	}
	if (have_effect($effect[Tomato Power]) == 0) {
		useIfHave(1, $item[tomato juice of powerful power]);
	}
	if (have_effect($effect[Gr8tness]) == 0) {
		useIfHave(1, $item[potion of temporary gr8tness]);
	}
	if (have_effect($effect[Experimental Effect G-9]) == 0) {
		useIfHave(1, $item[experimental serum G-9]);
	}
	if (have_effect($effect[Stevedave's Shanty of Superiority]) == 0) {
		chateauCast($skill[Stevedave's Shanty of Superiority]);
	} 
	if (have_effect($effect[Smithsness Presence]) == 0 && $item[handful of Smithereens].available_amount() > 0) {
		chew(1, $item[handful of Smithereens]);
	}
	if (have_effect($effect[Human-Humanoid Hybrid]) == 0 && $item[Gene Tonic: Humanoid].available_amount() > 0) {
		use(1, $item[Gene Tonic: Humanoid]);
	}
}

//---------------------------------------------------------------------------
// Consumption functions

void chewSpleen() {
	if (spleen_limit() - my_spleen_use() >= 4) {
		if ($item[grim fairy tale].available_amount() > 0) {
			chew(1, $item[grim fairy tale]);
		} else if ($item[powdered gold].available_amount() > 0) {
			chew(1, $item[powdered gold]);
		} else if ($item[Unconscious Collective Dream Jar].available_amount() > 0) {
			chew(1, $item[Unconscious Collective Dream Jar]);
		}
	} else if (spleen_limit() - my_spleen_use() >= 1) {
		if ($item[nasty snuff].available_amount() > 0) {
			chew(1, $item[nasty snuff]);
		} else if ($item[handful of Smithereens].available_amount() > 0) {
			chew(1, $item[handful of Smithereens]);
		}
	}
}

void generateEmergencyAdventures() {
	if (my_adventures() > 0) {
		return;
	}
	chewSpleen();
 	if (my_adventures() > 0) {
		return;
	}

	if (($item[astral pilsner].available_amount() > 2) && (my_inebriety() <= 13)) { // consume only 5 max for D1
		if (have_effect($effect[Ode to Booze]) < 1) {
			chateauCast($skill[The Ode to Booze]);
		}
		drink(1, $item[astral pilsner]);
	}
 	if (my_adventures() > 0) {
		return;
	}
	abort("Ran out of adventures.");
}

int hotdogStock(int which) { //returns how many of the item to 'unlock' a dog is currently stocked
	buffer page = visit_url("clan_viplounge.php?action=hotdogstand");
	string dogstr = substring(page, page.index_of(which.to_string()), page.index_of(which.to_string())+550);
	string stockstr = substring(dogstr, dogstr.index_of("in stock")-6, dogstr.index_of("in stock"));
	return substring(stockstr, stockstr.index_of("(")+1, stockstr.index_of(" ")).to_int();
}


boolean hotdogAvailable(int which) { //returns true if you don't have to restock to eat the specified hotdog
	buffer page = visit_url("clan_viplounge.php?action=hotdogstand");
	string dogstr = substring(page, page.index_of(which.to_string()), page.index_of(which.to_string())+10);
	if (contains_text(dogstr, "_food")) { //if _food is the first match, the hotdog is disabled.
		return false;
	} else {
		return true;
	}
}

void restockHotdog(int which) {
	int target;
	item restockitem;
	switch(which) {
		case -101: //sleeping dog
			target = 10;
			restockitem = $item[gauze hammock];
			break;
		case -100: //wet dog
			target = 25;
			restockitem = $item[sleaze wad];
			break;
		case -99: //junkyard dog
			target = 25;
			restockitem = $item[stench wad];
			break;
		default:
			abort("Unsupported hotdog");
			break;
	}
	int amtneeded = target - hotdogStock(which);
	if (amtneeded < 1) {
		abort("Got confused while trying to restock hotdog.");
	} else if (storage_amount(restockitem) < amtneeded) {
		buy_using_storage(amtneeded - storage_amount(restockitem), restockitem, -1);
	}
	visit_url("clan_viplounge.php?preaction=hotdogsupply&hagnks=1&whichdog="+which+"&quantity="+amtneeded);
}

void eatHotdog(int which) {
	if (!hotdogAvailable(which)) {
		restockHotdog(which);
	}
	visit_url("clan_viplounge.php?preaction=eathotdog&whichdog="+which);
}

void earlyEats() {
	useIfHave(1, $item[milk of magnesium]); //whatever we get 3 milks might was well turngen here to make sure
	eatHotdog(-101); //sleeping dog
	if ($item[This Charming Flan].available_amount() > 0) {
		eat(1, $item[This Charming Flan]);
	}
}

void eatHotFood() {
	useIfHave(1, $item[milk of magnesium]);
	eat(1, $item[sausage without a cause]);
	if (hotdogAvailable(-99)) { //junkyard dog
		visit_url("clan_viplounge.php?preaction=eathotdog&whichdog=-99");
	} else if (hotdogAvailable(-100)) { //wet dog
		visit_url("clan_viplounge.php?preaction=eathotdog&whichdog=-100");
	} else {
		if (hotdogStock(-99) >= hotdogStock(-100)) {
			eatHotdog(-99);
		} else {
			eatHotdog(-100);
		}
	}
	if (my_fullness() < 14) {
		if ($item[limp broccoli].available_amount() > 0) {
			eat(1, $item[limp broccoli]);
		} else if ($item[gooey lava globs].available_amount() > 0) {
			eat(1, $item[gooey lava globs]);
		} 
	}
	if (my_fullness() < 15) {
		if ($item[ice harvest].available_amount() > 0) {
			eat(1, $item[ice harvest]);
		}
	}
	if (my_fullness() < 15) {
		if ($item[snow crab].available_amount() > 0) {
			eat(1, $item[snow crab]);
		} else if ($item[snow berries].available_amount() >= 2) {
			create(1, $item[snow crab]);
			eat(1, $item[snow crab]);
		}
	}
	while (my_fullness() < 15) {
		if ($item[Knob pasty].available_amount() > 0) {
			eat(1, $item[Knob pasty]);
		} else if ($item[tasty tart].available_amount() > 0) {
			eat(1, $item[tasty tart]);
		} else {
			print("Resorting to eating a fortune cookie for remaining fullness.", "red");
			buy(1, $item[fortune cookie]);
			eat(1, $item[fortune cookie]);
		}
	}
}

void drinkBestSize1() { //I prolly should have had this take a "how many" argument but eh whatever
	if ($item[astral pilsner].available_amount() > 0) {
		drink(1, $item[astral pilsner]);
	} else if ($item[Ambitious Turkey].available_amount() > 0) {
		drink(1, $item[Ambitious Turkey]);
	} else if ($item[Agitated Turkey].available_amount() > 0) {
		drink(1, $item[Agitated Turkey]);
	} else if ($item[thermos full of Knob coffee].available_amount() > 0) {
		drink(1, $item[thermos full of Knob coffee]);
	} else if ($item[Cold One].available_amount() > 0) {
		drink(1, $item[Cold One]);
	} else if (get_property_int("_speakeasyDrinksDrunk") < 3) {
		visit_url("clan_viplounge.php?preaction=speakeasydrink&drink=4&pwd="+my_hash()); //lucky lindy
		cli_execute("counters clear"); //otherwise it aborts
	} else {
		print("Failed to fill liver (no size-1 booze left).", "red");
	}
}

boolean fill2liver() { //returns false if it can't fill 2 liver
	int size1s = $item[astral pilsner].available_amount() + $item[Ambitious Turkey].available_amount() + $item[Agitated Turkey].available_amount() + $item[thermos full of Knob coffee].available_amount() + $item[Cold One].available_amount();
	if (size1s > 1) { //size 1 booze always preferred over size 2 booze; a level 8 Cold One is slightly worse than Whinskey, but it either doesn't compete with it or is accompanied by another better 1-size booze
		drinkBestSize1();
		drinkBestSize1();
		return true;
	} else if ($item[Dinsey Whinskey].available_amount() > 0) {
		drink(1, $item[Dinsey Whinskey]);
		return true;
	} else if (get_property_int("_speakeasyDrinksDrunk") < 3) {
		visit_url("clan_viplounge.php?preaction=speakeasydrink&drink=6&pwd="+my_hash()); //sockdollager; saves 2 turns on spell dmg test but is still the worst for daycount overall
		return true;
	} else { //drink what you can
		drinkBestSize1();
		return false;
	}
}

void nightcap() {
	if (my_inebriety() < 14) { //ideally I would use some algorithm to solve for the knapsack problem but meh whatever this'll do
		while (14 - my_inebriety() > 1 && fill2liver()) {} //fills 2 liver until you have 1 or 0 left to fill or it fails to fill it
		if (my_inebriety() == 13) {
			drinkBestSize1();
		}
	} 
	drink(1, $item[emergency margarita]);
}

//---------------------------------------------------------------------------
// Combat and Adventure functions

void powerlevelMood() {
	cli_execute("mood PowerLevelMood");
	cli_execute("mood clear");
	cli_execute("mood execute");
}

void calderaMood() {
	cli_execute("mood CalderaMood");
	cli_execute("mood clear");
	if (have_skill($skill[Elemental Saucesphere])) {
		cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
	}
	if (have_skill($skill[Astral Shell])) {
		cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");
	}
	if (have_skill($skill[Reptilian Fortitude])) {
		cli_execute("trigger lose_effect, Reptilian Fortitude, cast 1 Reptilian Fortitude");
	}
	if (have_skill($skill[Springy Fusilli])) {
		cli_execute("trigger lose_effect, Springy Fusilli, cast 1 Springy Fusilli");
	} 
	if (have_skill($skill[The Power Ballad of the Arrowsmith])) {
		cli_execute("trigger lose_effect, Power Ballad of the Arrowsmith, cast 1 The Power Ballad of the Arrowsmith");
	} 
	if (have_skill($skill[Suspicious Gaze])) {
		cli_execute("trigger lose_effect, Suspicious Gaze, cast 1 Suspicious Gaze");
	} 
	if (have_skill($skill[Cletus's Canticle of Celerity])) {
		cli_execute("trigger lose_effect, Cletus's Canticle of Celerity, cast 1 Cletus's Canticle of Celerity");
	}
	if (have_skill($skill[Sauce Contemplation])) {
		cli_execute("trigger lose_effect, Saucemastery, cast 1 Sauce Contemplation");
	}
	if (have_skill($skill[Patience of the Tortoise])) {
		cli_execute("trigger lose_effect, Patience of the Tortoise, cast 1 Patience of the Tortoise");
	} 
	if (have_skill($skill[Moxie of the Mariachi])) {
		cli_execute("trigger lose_effect, Mariachi Mood, cast 1 Moxie of the Mariachi");
	}
	cli_execute("mood execute");
}

boolean YRsourceAvailable() {
	if((have_familiar($familiar[Crimbo Shrub]) && (alwaysFam == $familiar[none]) || alwaysFam == $familiar[Crimbo Shrub]) || $item[Golden Light].available_amount() > 0) {
		return true;
	} else {
		return false;
	}
}

string customCombat(int round) {
	if (round < 0) {
		round = 0;
	}
	if (round == 0 && (have_skill($skill[Curse of Weaksauce]) && my_mp() >= (mp_cost($skill[Curse of Weaksauce]) + mp_cost($skill[Saucegeyser])))) {
		return "skill Curse of Weaksauce";
	} else if (have_skill($skill[Saucegeyser]) && my_mp() >= mp_cost($skill[Saucegeyser])) {
		return "skill Saucegeyser";
	} else {
		print("Resorting to CCS", "red");
		return get_ccs_action(round);
	}
}

string combatYR() {
	if (have_skill($skill[Open a Big Yellow Present])) {
		return "skill Open a Big Yellow Present";
	} else if ($item[Golden Light].available_amount() > 0) {
		return "item Golden Light";
	} else {
		abort("No yellow ray available when trying to use one");
		return "I really shouldn't have to specify a return value after an abort";
	}
}

string combatGG(int round, string opp, string text) {
	if (round == 0) {
		return "skill Giant Growth";
	} else {
		return "item Louder Than Bomb";
	}
}

string combat(int round, string opp, string text) { //always uses this script's custom combat after first doing whatever you're supposed to
	if ((opp == $monster[lavatory].to_string() || opp == $monster[garbage tourist].to_string()) && $item[DNA extraction syringe].available_amount() > 0) { //DNA
		if ($item[Gene Tonic: Elemental].available_amount() == 0) {
			if(round == 0) {
				return "item DNA extraction syringe";
			} else {
				return customCombat(round - 1);
			}
		} else {
			return customCombat(round);
		}
	} else if (opp == $monster[lava lamprey].to_string() && $item[DNA extraction syringe].available_amount() > 0) { //DNA
		if (have_effect($effect[Human-Fish Hybrid]) == 0) {
			if(round == 0) {
				return "item DNA extraction syringe";
			} else {
				return customCombat(round - 1);
			}
		} else {
			return customCombat(round);
		}
	} else if (opp == $monster[C<i>bzzt</i>er the Grisly Bear].to_string() || opp == $monster[Gurgle the Turgle].to_string() || opp == $monster[Skeezy the Jug Rat].to_string() && $item[DNA extraction syringe].available_amount() > 0) { //DNA
		if ($item[Gene Tonic: Construct].available_amount() == 0) {
			if(round == 0) {
				return "item DNA extraction syringe";
			} else {
				return customCombat(round);
			}
		} else {
			return customCombat(round);
		}
	} else if (opp.contains_text("pirate") && $item[DNA extraction syringe].available_amount() > 0) { //DNA
		if(round == 0) {
			return "item DNA extraction syringe";
		} else {
			return customCombat(round - 1);
		}
	} else if (opp == $monster[dairy goat].to_string()) { //beast DNA and milk of magnesium
		if(round == 0 && $item[DNA extraction syringe].available_amount() > 0 && $item[Gene Tonic: Beast].available_amount() == 0) {
			return "item DNA extraction syringe";
		} else if (YRsourceAvailable()) {
			return combatYR();
		} else {
			return customCombat(round - 1);
		}
	} else if (opp == $monster[sk8 gnome].to_string()) { //humanoid DNA and gr8tness
		if(round == 0 && $item[DNA extraction syringe].available_amount() > 0 && $item[Gene Tonic: Humanoid].available_amount() == 0) {
			return "item DNA extraction syringe";
		} else if (YRsourceAvailable() && !gr8psAvailable()) {
			return combatYR();
		} else {
			return customCombat(round - 1);
		}
	} else if (opp == $monster[frog].to_string() || opp == $monster[newt].to_string() || opp == $monster[salamander].to_string()) {
		return customCombat(round - 1);
	} else if (opp == $monster[super-sized Cola Wars soldier].to_string() || opp == $monster[creepy little girl].to_string()) {
		if (have_skill($skill[CLEESH])) {
			return "skill CLEESH";
		} else {
			return "run away";
		}
	} else if (opp == $monster[lab monkey].to_string()) {
		if ($item[limp broccoli].available_amount() >= 1) {
			if (have_skill($skill[CLEESH])) {
				return "skill CLEESH";
			} else {
				return "run away";
			}
		} else if ($item[experimental serum G-9].available_amount() >= 1) {
			if (have_effect($effect[On the Trail]) == 0) {
				return "skill Transcendent Olfaction";
			} else if (have_effect($effect[On the Trail]) == 40) { //used it this combat
				return customCombat(round - 1);
			} else {
				return customCombat(round);
			}
		} else {
			return customCombat(round);
		}
	} else if (opp == $monster[government scientist].to_string()) {
		if ($item[experimental serum G-9].available_amount() >= 1) {
			if (have_skill($skill[CLEESH])) {
				return "skill CLEESH";
			} else {
				return "run away";
			}
		} else if ($item[limp broccoli].available_amount() >= 1) {
			if (have_effect($effect[On the Trail]) == 0) {
				return "skill Transcendent Olfaction";
			} else if (have_effect($effect[On the Trail]) == 40) { //used it this combat
				return customCombat(round - 1);
			} else {
				return customCombat(round);
			}
		} else {
			return customCombat(round);
		}
	} else if (opp.contains_text("hippy") || opp.contains_text("Frat Boy") || opp == $monster[novelty tropical skeleton].to_string()) {
		return combatYR();
	} else if (opp == $monster[factory worker (female)].to_string() || opp == $monster[factory overseer (female)].to_string()) {
		if(my_daycount() == 2 && round == 0 && $item[DNA extraction syringe].available_amount() > 0 && $item[Gene Tonic: Dude].available_amount() == 0) {
			return "item DNA extraction syringe";
		}
		if ($item[lava-proof pants].available_amount() == 0) {
			return combatYR();
		} else {
			return customCombat(round);
		}
	} else if (opp == $monster[factory worker (male)].to_string() || opp == $monster[factory overseer (male)].to_string()) {
		if(my_daycount() == 2 && round == 0 && $item[DNA extraction syringe].available_amount() > 0 && $item[Gene Tonic: Dude].available_amount() == 0) {
			return "item DNA extraction syringe";
		}
		if ($item[heat-resistant necktie].available_amount() == 0) {
			return combatYR();
		} else {
			return customCombat(round);
		}
	} else if (opp == $monster[fluffy bunny].to_string()) {
		if (round == 0) {
			return "skill Giant Growth";
		} else {
			return "item Louder Than Bomb";
		}
	} else { //no special case, just use the CCS
		return customCombat(round);
	}
}

void combatAdv(location where, boolean fighting) {
	if (my_adventures() < 1) {
		generateEmergencyAdventures();
	}
	setFamiliar();
	if (have_effect($effect[Springy Fusilli]) == 0) {
		chateauCast($skill[Springy Fusilli]);
	}
	if (have_effect($effect[Reptilian Fortitude]) == 0) {
		chateauCast($skill[Reptilian Fortitude]);
	}
	if (fighting && have_skill($skill[Curse of Weaksauce]) && have_skill($skill[Saucegeyser]) && my_mp() < (mp_cost($skill[Curse of Weaksauce]) + mp_cost($skill[Saucegeyser]))) {
		if (!free_rest()) {
			restore_mp(mp_cost($skill[Curse of Weaksauce]) + mp_cost($skill[Saucegeyser]));
		}
	}
	if (my_hp() < my_maxhp()) {
		restore_hp(my_maxhp());
	}
	adv1(where, -1, "combat");
	while ((my_soulsauce() > 92) && (my_mp() < my_maxmp() - 15)) {
		use_skill(1, $skill[Soul Food]);
	}
	while (have_skill($skill[Summon Taffy]) && my_mp() > (mp_cost($skill[Summon Taffy]) + 100)) {
		cast($skill[Summon Taffy]);
	}
}

void YRAdv(location where) { //sets crimbo shrub as active familiar first, then switches back...looks dumb if it takes multiple adv to get the YR target but whatever
	if(have_effect($effect[Everything Looks Yellow]) > 0) {
		abort("Yellow ray time, but you still have Everything Looks Yellow.");
	}
	if (my_adventures() < 1) {
		generateEmergencyAdventures();
	}
	familiar prevfam = my_familiar();
	boolean light = true;
	if(alwaysFam != $familiar[none]) {
		use_familiar(alwaysFam);
	} else if($item[Golden Light].available_amount() == 0 && have_familiar($familiar[Crimbo Shrub])) {
		use_familiar($familiar[Crimbo Shrub]);
		lockFamiliar = true;
		light = false;
	}
	combatAdv(where, false);
	if (light == false && prevfam != $familiar[Crimbo Shrub]) {
		use_familiar(prevfam);
		lockFamiliar = false;
	}
}

int advToSemirare() {
	for i from 0 to 30 { //this is ridiculous.
		if (get_counters("Fortune Cookie", i, i) != "") {
			return i; //if 0 then semirare is imminent
		}
	}
	return 99999;
}

// The next three functions aren't actually combat or adventuring but...
boolean teaTreeAvailable() {
	buffer page = visit_url("campground.php");
	return contains_text(page, "Tea Tree");
}


boolean doghouseAvailable() {
	buffer page = visit_url("campground.php?action=doghouse");
	visit_url("choice.php?pwd&whichchoice=1110&option=6");
	if (contains_text(page, "Spoopy")) {
		return true;
	} else {
		return false;
	}
}


string checkGarden() {
	buffer page = visit_url("campground.php");
	if (contains_text(page, "A Winter Garden")) {
		return "winter";
	} else if (contains_text(page, "A Beer Garden")) {
		return "beer";
	} else if (contains_text(page, "A Pumpkin Patch")) {
		return "pumpkin";
	} else if (contains_text(page, "A Peppermint Patch")) {
		return "peppermint";
	} else if (contains_text(page, "A Bone Garden")) {
		return "bone";
	} else {
		return "none";
	}
}

boolean getSRifCan() { //returns true if got it
	if (advToSemirare() == 0) {
		cli_execute("counters clear"); //otherwise it aborts
		if (checkGarden() == "winter") {
			adventure(1, $location[The Limerick Dungeon], "combat");
		} else { 
			adventure(1, $location[The Outskirts of Cobb's Knob], "combat");
			use(1, $item[Knob Goblin lunchbox]);
		}
		cli_execute("counters clear"); //otherwise it aborts
		return true;
	} else {
		return false;
	}
}

boolean giantGrowth() {
	location growthzone;
	
	if(!have_skill($skill[Giant Growth]) || $item[green mana].available_amount() == 0) {
		return false;
	} else {
		restore_hp(my_maxhp());
		familiar curfam = my_familiar();
		if(alwaysFam == $familiar[none]) {
			use_familiar($familiar[none]);
			lockFamiliar = true;
			adv1($location[The Dire Warren], -1, "combat");
			lockFamiliar = false;
			use_familiar(curfam);
		} else {
			if (get_property_boolean("stenchAirportAlways")) {
				growthzone = $location[Uncle Gator's Country Fun-Time Liquid Waste Sluice];
				calderaMood(); //same deal here
				if ($item[barrel lid].available_amount() > 0) {
					equip($item[barrel lid]);
				}
			} else if (get_property_boolean("spookyAirportAlways")) {
				growthzone = $location[The Deep Dark Jungle];
			} else if (get_property_boolean("sleazyAirportAlways")) {
				growthzone = $location[Sloppy Seconds Diner];
			} else if (get_property_boolean("hotAirportAlways")) {
				growthzone = $location[The SMOOCH Army HQ];
			} else {
				growthzone = $location[Video Game Level 1];
			}
			adv1(growthzone, -1, "combatGG");
		}
		if(have_effect($effect[Giant Growth]) > 0) {
			return true;
		} else {
			return false;
		}
	}
}

//---------------------------------------------------------------------------
// Misc Functions

void unlockSkeletonStore() {
	visit_url("shop.php?whichshop=meatsmith&action=talk");
	visit_url("choice.php?pwd&whichchoice=1059&option=1&choiceform1=Sure%2C+I%27ll+go+check+it+out.");
	visit_url("choice.php?pwd&whichchoice=1059&option=3&choiceform1=Not+yet.+I%27ll+keep+looking.");
}

void chateaumantegna_buyStuff(item toBuy) //thanks Cheesecookie
{
	if(!get_property_boolean("chateauAvailable"))
	{
		return;
	}

	if((toBuy == $item[Electric Muscle Stimulator]) && (my_meat() >= 500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=411&quantity=1", true);
	}
	if((toBuy == $item[Foreign Language Tapes]) && (my_meat() >= 500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=412&quantity=1", true);
	}
	if((toBuy == $item[Bowl of Potpourri]) && (my_meat() >= 500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=413&quantity=1", true);
	}

	if((toBuy == $item[Antler Chandelier]) && (my_meat() >= 1500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=415&quantity=1", true);
	}
	if((toBuy == $item[Artificial Skylight]) && (my_meat() >= 1500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=416&quantity=1", true);
	}
	if((toBuy == $item[Ceiling Fan]) && (my_meat() >= 1500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=414&quantity=1", true);
	}

	if((toBuy == $item[Continental Juice Bar]) && (my_meat() >= 2500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=418&quantity=1", true);
	}
	if((toBuy == $item[Fancy Calligraphy Pen]) && (my_meat() >= 2500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=419&quantity=1", true);
	}
	if((toBuy == $item[Swiss Piggy Bank]) && (my_meat() >= 2500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=417&quantity=1", true);
	}

	if((toBuy == $item[Alpine Watercolor Set]) && (my_meat() >= 5000))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=420&quantity=1", true);
	}
}

void sellJewels() {
	print("Selling jewels...");	
	foreach stone in $items[hamethyst, baconstone, porquoise]
	autosell(item_amount(stone), stone);
}

int advCost(int whichtest) {
	buffer page = visit_url("council.php");
	string teststr = "name=option value="+ whichtest +">";
	if (contains_text(page, teststr)) {
		int chars = 140; //chars to look ahead
		string pagestr = substring(page, page.index_of(teststr)+length(teststr), page.index_of(teststr)+length(teststr)+chars);
		string advstr = substring(pagestr, pagestr.index_of("(")+1, pagestr.index_of("(")+3);
		advstr = replace_string(advstr, " ", ""); //removes whitespace, if the test is < 10 adv
		return to_int(advstr);
	} else {
		print("Didn't find specified test on the council page. Already done?");
		return 99999;
	}
}

boolean doTest(int which) {
	if (my_adventures() >= advCost(which)) {
		print("Undertaking community service task at a cost of " + advCost(which) + " adventures", "blue");
		visit_url("choice.php?whichchoice=1089&option="+which+"&pwd="+my_hash());
		return true;
	} else {
		abort("Failed to generate enough adventures to complete test " + which);
		return false;
	}
}

int g9val() { //useless in hindsight; we get g9 on day 1 and use it on day 2 so its values are irrelevant. maybe I'll move g9 farming to day 2 if you got the SR between shore trips
	buffer page = visit_url("desc_effect.php?whicheffect=af64d06351a3097af52def8ec6a83d9b");
	return substring(page, page.index_of("+")+1, page.index_of("%")).to_int();
}

boolean pulverize(item which) {
	if (!have_skill($skill[Pulverize]) || which.available_amount() == 0) {
		return false;
	} else {
		cli_execute("pulverize " + which);
		return true;
	}
}

boolean hasScalingZone() {
	if (get_property_boolean("hotAirportAlways") ||
		get_property_boolean("spookyAirportAlways") ||
		get_property_boolean("sleazyAirportAlways") ||
		get_property_boolean("stenchAirportAlways") ||
		$item[GameInformPowerDailyPro walkthru].available_amount() > 0 ||
		$item[GameInformPowerDailyPro magazine].available_amount() > 0) {
		return true;
	} else {
		return false;
	}
}

boolean level2unlocked() {
	buffer page = visit_url("place.php?whichplace=faqdungeon");
	if (contains_text(page, "snarfblat=320")) {
		return true;
	}
	return false;
}

void getTurtleTotem() {
	if (have_skill($skill[Empathy of the Newt]) || have_skill($skill[Astral Shell])) {
		while($item[turtle totem].available_amount() < 1) {
			buy(1, $item[chewing gum on a string]);
			use(1, $item[chewing gum on a string]);
		}
	}
	while($item[saucepan].available_amount() < 1) {
		buy(1, $item[chewing gum on a string]);
		use(1, $item[chewing gum on a string]);
	}
}

void setProperties() {
	set_property("autoSatisfyWithNPCs", "true");
	set_property("choiceAdventure1106", "2");
	set_property("choiceAdventure1107", "1");
	buffer page = visit_url("place.php?whichplace=airport");
	if (contains_text(page, "airport_sleaze")) {
		set_property("sleazyAirportAlways", "true");
	}
	if (contains_text(page, "airport_hot")) {
		set_property("hotAirportAlways", "true");
	}
	if (contains_text(page, "airport_stench")) {
		set_property("stenchAirportAlways", "true");
	}
	if (contains_text(page, "airport_spooky")) {
		set_property("spookyAirportAlways", "true");
	}
}

void checkGameInform() {
	if($item[GameInformPowerDailyPro magazine].available_amount() > 0) {
		visit_url("inv_use.php?pwd&whichitem=6174&confirm=Yep.");
		cli_execute("inv refresh");
		visit_url("place.php?whichplace=faqdungeon");
		visit_url("adventure.php?snarfblat=319");
		if ($item[dungeoneering kit].available_amount() > 0) {
			use(1, $item[dungeoneering kit]);
		} else {
			print("Failed to get dungeoneering kit for some reason", "red");
		}
		
	}
}

void free_barrels() {
	if(get_property("barrelShrineUnlocked") == "true") {
		print("Collecting free barrel drops");
		matcher barrel = create_matcher('<div class="ex"><a class="spot" href="([^"]+)"><img title="A barrel"', visit_url("barrel.php"));
		while(barrel.find()) {
			visit_url(barrel.group(1));
		}
	    if (getSpleenFamiliar() == $familiar[none]) {
			chew($item[magicalness-in-a-can].available_amount(), $item[magicalness-in-a-can]);
			chew($item[moxie weed].available_amount(), $item[moxie weed]); 
		}
	}
}

// ###########################################################################
// Day 1 functions

void day1setup() {
	if(alwaysFam != $familiar[none]) {
		use_familiar(alwaysFam);
	}
	if(statemap["questStage"] >= 10) {
		return;
	}
	visit_url("council.php");
	
	if (get_property("chateauMonster") == "sk8 gnome") {
		saveChateau(2);
	} else if (get_property("chateauMonster") == "dairy goat") {
		saveChateau(1);
	}
	setProperties();
	setFamiliar();
	decorateShrub();
	free_barrels();

	if (doghouseAvailable()) {
		set_property("choiceAdventure1106","3"); // Ghost Dog Chow
	}
	// Free pulls
	if(be_good($item[brick]))
		retrieve_item(available_amount($item[brick]), $item[brick]);
	if(be_good($item[roll of toilet paper]))
		retrieve_item(available_amount($item[roll of toilet paper]), $item[roll of toilet paper]);

	if (smashHippyStone) {
		visit_url("campground.php?smashstone=Yep.&confirm=on&shatter=Smash+that+Hippy+Crap%21");
	}

	visit_url("tutorial.php?action=toot"); //get letter
	if ($item[Letter from King Ralph XI].available_amount() > 0) {
		use(1, $item[Letter from King Ralph XI]); //get sack of jewels
		use(1, $item[pork elf goodies sack]); //get jewels
	} else if ($item[pork elf goodies sack].available_amount() > 0) {
		use(1, $item[pork elf goodies sack]); //get jewels
	}
	sellJewels();
	if ($item[astral six-pack].available_amount() == 1) {
		use(1, $item[astral six-pack]);
	}
	if ($item[bitchin' meatcar].available_amount() == 0) {
		create(1, $item[bitchin' meatcar]);
	}
	if (have_skill($skill[Pulverize]) && $item[tenderizing hammer].available_amount() == 0) {
		buy(1, $item[tenderizing hammer]);
	}
	unlockSkeletonStore();
	if (get_property_int("_deckCardsDrawn") == 0) {
		cli_execute("cheat mickey");
		autosell(1, $item[1952 Mickey Mantle card]);
		cli_execute("cheat giant growth");
		cli_execute("cheat empress");
	} else {
		print("Skipping deck draws...");
	}
	if ($item[Dramatic&trade; range].available_amount() == 0) {
		buffer page = visit_url("campground.php?action=inspectkitchen");
		if (!contains_text(page, "Dramatic")) {
			buy(1, $item[Dramatic&trade; range]);
			use(1, $item[Dramatic&trade; range]);
		}
	}
	if (have_skill($skill[The Magical Mojomuscular Melody])) {
		use_skill($skill[The Magical Mojomuscular Melody]);
	}
	use_skill(3, $skill[Summon Smithsness]);
	if ($item[Hairpiece on Fire].available_amount() == 0) {
		create(1, $item[Hairpiece on Fire]);
		equip($item[Hairpiece on Fire]);
	}
	if ($item[Saucepanic].available_amount() == 0) {
		create(1, $item[Saucepanic]);
		equip($item[Saucepanic]);
	}
	if ($item[A Light That Never Goes Out].available_amount() == 0) {
		create(1, $item[A Light That Never Goes Out]);
		equip($item[A Light That Never Goes Out]);
	}
	if ($item[Flaskfull of Hollow].available_amount() == 3) {
		use(3, $item[Flaskfull of Hollow]);
	}
	summonDailyStuff();
	if ((!have_familiar($familiar[Crimbo Shrub]) && $item[Golden Light].available_amount() == 0) || (alwaysFam != $familiar[none] && alwaysFam != $familiar[Crimbo Shrub])) {
		create(2, $item[Golden Light]);
	}
	if ($item[This Charming Flan].available_amount() == 0) {
		create(1, $item[This Charming Flan]);
	}
	buy(1, $item[frilly skirt]);
	if (equipped_item($slot[pants]) == $item[none]) {
		if (my_basestat($stat[moxie]) > 1) {
			equip($item[frilly skirt]);
		} else {
			equip($item[old sweatpants]);
		}
	}
	cli_execute("breakfast"); 
	hermit(99, $item[ten-leaf clover]);
	use($item[ten-leaf clover].available_amount(), $item[ten-leaf clover]);
	getTurtleTotem();
	if ($item[detuned radio].available_amount() == 0) {
		buy(1, $item[detuned radio]);
		change_mcd(10);
	}
	if ($item[transmission from planet Xi].available_amount() > 0) {
		use(1, $item[transmission from planet Xi]);
		cli_execute("eudora game"); // switch to GameInform
	}
	if ($item[Xiblaxian holo-wrist-puter simcode].available_amount() > 0) {
		use(1, $item[Xiblaxian holo-wrist-puter simcode]);
		equip($item[Xiblaxian holo-wrist-puter]);
	}
	if (teaTreeAvailable() && get_property_boolean("_pottedTeaTreeUsed") == false) {
		cli_execute("teatree cuppa frost tea");
	}
	checkGameInform();
	saveProgress(10);
}

void initialDrinks() { //drinking after day 1 setup but before coiling wire
	if(statemap["questStage"] >= 20) {
		return;
	}
	chateauCast($skill[The Ode to Booze]);
	if (checkGarden() == "winter") {
		create(1, $item[Ice Island Long Tea]);
		drink(1, $item[Ice Island Long Tea]);
		create(1, $item[snow crab]);
	} else if (checkGarden() == "beer") {
		create(3, $item[Can of Drooling Monk]);
		drink(3, $item[Can of Drooling Monk]);
		create(1, $item[tin cup]);
	}
	visit_url("clan_viplounge.php?preaction=speakeasydrink&drink=4&pwd="+my_hash()); //lucky lindy
	cli_execute("shrug ode");
	saveProgress(20);
}

void doChateauPainting() {
	if(statemap["questStage"] >= 30) {
		return;
	}
	saveProgress(30);
	chateauCast($skill[Springy Fusilli]);
	chateauCast($skill[Reptilian Fortitude]);
	chateauCast($skill[Astral Shell]);
	chateauCast($skill[Cletus's Canticle of Celerity]);
	chateauCast($skill[Sauce Contemplation]);
	restore_hp(my_maxhp());
	if ((get_property("chateauMonster") != "sk8 gnome") && (get_property("chateauMonster") != "dairy goat")) {
		abort("Chateau is neither sk8 gnome nor dairy goat.");
	}

	if (alwaysFam != $familiar[none]) {
		use_familiar(alwaysFam);
	} else if (gr8psAvailable() || !have_familiar($familiar[Crimbo Shrub])) {
		setItemFamiliar();
	} else {
		use_familiar($familiar[Crimbo Shrub]);
	}
	if (my_mp() < (mp_cost($skill[Curse of Weaksauce]) + mp_cost($skill[Saucegeyser]))) {
		if (!free_rest()) {
			restore_mp(mp_cost($skill[Curse of Weaksauce]) + mp_cost($skill[Saucegeyser]));
		}
	}
	visit_url("place.php?whichplace=chateau&action=chateau_painting");
	adventure(1, $location[Noob Cave], "combat"); //I'm told this works. 
	if ($item[DNA extraction syringe].available_amount() > 0) {
		visit_url("campground.php?action=dnapotion");
	}
	if (gr8psAvailable()) {
		if($item[gr8ps].available_amount() == 0) {
			abort("Failed to retrieve gr8ps.");
		}
	} else {
		if($item[glass of goat's milk].available_amount() == 0) {
			abort("Failed to retrieve glass of goat's milk.");
		}
		create(1, $item[milk of magnesium]);
	}
}

void maybeYRHotResistGear() {
	if(statemap["questStage"] >= 35) {
		return;
	}
	if ((have_effect($effect[Everything Looks Yellow]) > 0) || !get_property_boolean("hotAirportAlways")) {
		saveProgress(35);
		return;
	}
	while ($item[lava-proof pants].available_amount() == 0 && $item[heat-resistant necktie].available_amount() == 0) {
		YRAdv($location[LavaCo&trade; Lamp Factory]);
	}
	saveProgress(35);
}

void coilTest() {
	if(statemap["questStage"] >= 40) {
		return;
	}
	earlyEats();
	if (my_adventures() >= 60) {
		doTest(COILTEST);
		use(1, $item[a ten-percent bonus]);
	} else {
		abort("Failed to generate enough adventures to coil wire.");
	}
	saveProgress(40);
}

void openGuild() {
	if(statemap["questStage"] >= 45) {
		return;
	}
	if (gr8psAvailable()) {
		setFamiliar();
		basicItemDropBuffs();
		chateauCast($skill[Musk of the Moose]);
		chateauCast($skill[Carlweather's Cantata of Confrontation]);
		maximize("item drop", false);
		adventure(1, $location[The Haunted Pantry], "combat");
		cli_execute("guild");
		visit_url("guild.php?place=paco");
		visit_url("guild.php?place=paco");
		visit_url("choice.php?pwd&whichchoice=930&option=1");
		visit_url("place.php?whichplace=woods");
		visit_url("place.php?whichplace=forestvillage");
		visit_url("place.php?whichplace=forestvillage&action=fv_friar");
		cli_execute("refresh all");
		if (doghouseAvailable()) {
			while($item[Ghost Dog Chow].available_amount() == 0) {
				getSRifCan();
				adv1($location[The Haunted Pantry], -1, "combat");
			}
		}
	}
	saveProgress(45);
}

void getPirateDNA() {
	if(statemap["questStage"] >= 50) {
		return;
	}
	if (get_property_boolean("stenchAirportAlways") && $item[DNA extraction syringe].available_amount() > 0) { 
		while ($item[Gene Tonic: Pirate].available_amount() == 0) {
			getSRifCan();
			combatAdv($location[Pirates of the Garbage Barges], true);
			buffer page = visit_url("campground.php?action=workshed");
			if (contains_text(page, "Human-Pirate Hybrid")) {
				visit_url("campground.php?action=dnapotion");
			}
		}
	}
	saveProgress(50);
}

void getCalderaDNA() {
	if(statemap["questStage"] >= 60) {
		return;
	}
	if (get_property_boolean("hotAirportAlways") && $item[DNA extraction syringe].available_amount() > 0) {
		if (have_effect($effect[Song of Sauce]) == 0) {
			chateauCast($skill[Song of Sauce]); //hot-aligned monsters effectively take half damage from Saucegeyser so this compensates for it, allowing a 1-shot
		}
		calderaMood();
		int turns = 0;
		// TODO
		while(($item[Volcoino].available_amount() == 0 && doghouseAvailable()) || have_effect($effect[Human-Fish Hybrid]) == 0 || ($item[Gene Tonic: Elemental].available_amount() == 0 && !get_property_boolean("stenchAirportAlways"))) { //if got fish DNA and either elemental DNA or have Dinsey open
			if (my_adventures() == 0) {
				generateEmergencyAdventures();
			}
			if (!getSRifCan()) {
				combatAdv($location[The Bubblin' Caldera], true);
				turns=turns+1;
				if (have_effect($effect[Beaten Up]) > 0) {
					print("You got whupped...", "red");
					visit_url("clan_viplounge.php?action=hottub");
				}
				buffer page = visit_url("campground.php?action=workshed");
				if (contains_text(page, "Human-Elemental Hybrid") && $item[Gene Tonic: Elemental].available_amount() == 0) {
					visit_url("campground.php?action=dnapotion");
				} else if (contains_text(page, "Human-Fish Hybrid") && have_effect($effect[Human-Fish Hybrid]) != 2147483547) {
					visit_url("campground.php?action=dnainject"); 
				}
			}
		}
		cli_execute("mood clear");
		cli_execute("hottub");
		while ($item[Gene Tonic: Elemental].available_amount() == 0 && get_property_boolean("stenchAirportAlways")) {
			if (my_adventures() == 0) {
				generateEmergencyAdventures();
			}
			if (!getSRifCan()) {
			    combatAdv($location[Barf Mountain], true);
			    buffer page = visit_url("campground.php?action=workshed");
			    if (contains_text(page, "Human-Elemental Hybrid") && $item[Gene Tonic: Elemental].available_amount() == 0) {
				    visit_url("campground.php?action=dnapotion");
			    }
			}
		}
		if ($item[bag of park garbage].available_amount() > 0) {
			visit_url("place.php?whichplace=airport_stench&action=airport3_tunnels");
			visit_url("choice.php?pwd&whichchoice=1067&option=6&choiceform6=Waste+Disposal");
			visit_url("choice.php?pwd&whichchoice=1067&option=7&choiceform7=Exit");
		}
		if ($item[FunFunds&trade;].available_amount() >= 2) {
			buy($coinmaster[The Dinsey Company Store], 1, $item[Dinsey Whinskey]);
		}
	}
	saveProgress(60);
}

void maybeUnlockIsland() { //either unlocks island or decides to just do skeleton store instead later
	if(statemap["questStage"] >= 70) {
		return;
	}
	if (gr8psAvailable()) {
		skipIsland();
	} else {
		getSRifCan();
		if ((advToSemirare() % 3 == 0 && advToSemirare() < 10) || (get_property_boolean("spookyAirportAlways") && advToSemirare() > 9)) { //if the SR is perfectly between shore trips OR it'll come up during G9 farming
			while ($item[Shore Inc. Ship Trip Scrip].available_amount() < 3) {
				visit_url("adventure.php?snarfblat=355");
				visit_url("choice.php?"+my_hash()+"&whichchoice=793&option=2&choiceform2=Tropical+Paradise+Island+Getaway");
				getSRifCan();
			}
			buy($coinmaster[The Shore, Inc. Gift Shop], 1, $item[dinghy plans]);
			buy(1, $item[dingy planks]);
			use(1, $item[dinghy plans]);
		} else { //1, 2, 4, 5, 7, or 8 adv to semirare or no CI; skeleton store instead...loses tomato/olive but saves initial turns so whatever. Tomato can be found in the pantry anyway
			skipIsland();
		}
	}
	saveProgress(70);
}

void getG9Serum() { //like 0-7 turns prolly
	if(statemap["questStage"] >= 80) {
		return;
	}
	if (!get_property_boolean("spookyAirportAlways") || (!have_skill($skill[Transcendent Olfaction]) && !alwaysG9)) {
		saveProgress(80);
		return;
	}
	if(statemap["questStage"] == 70) {
		if (my_mp() < (mp_cost($skill[Transcendent Olfaction]) + mp_cost($skill[Curse of Weaksauce]) + mp_cost($skill[Saucegeyser]))) {
			if (!free_rest()) {
				restore_mp(mp_cost($skill[Transcendent Olfaction])+ mp_cost($skill[Curse of Weaksauce]) + mp_cost($skill[Saucegeyser]));
				print("Had to restort to meat-MP instead of chateau rest", "red");
			}
		}
		getSRifCan();
		if ($item[Personal Ventilation Unit].available_amount() < 1) {
			adv1($location[The Secret Government Laboratory], -1, "combat");
		}
		if ($item[Personal Ventilation Unit].available_amount() > 0) {
			equip($item[Personal Ventilation Unit]);
		} else {
			abort("Failed to get Personal Ventilation Unit somehow");
		}
		setItemFamiliar();
		basicItemDropBuffs();
		maximize("item drop +equip personal ventilation unit", false);
		saveProgress(71);
		if (doCheckpoints) {
			abort("Checkpoint: Before G-9 collecting.");
		}
	}
	if(statemap["questStage"] == 71) {
		lockFamiliar = true;
		boolean florist = false;
		while(($item[experimental serum G-9].available_amount() < 1) || ($item[limp broccoli].available_amount() < 1)) {
			if (!getSRifCan()) {
				basicItemDropBuffs();
				combatAdv($location[The Secret Government Laboratory], true);
				if (florist == false) {
					cli_execute("florist plant Stealing Magnolia"); # indoor +25 item%
					cli_execute("florist plant Impatiens"); # indoor +25% init
					cli_execute("florist plant Pitcher Plant"); # indoor restores MP
					florist = true;
				}
			}
		}
		lockFamiliar = false;
		cli_execute("shrug Fat Leon's Phat Loot Lyric");
	}
	saveProgress(80);
}

void weaponTest() {
	if(statemap["questStage"] >= 110) {
		return;
	}
	if(statemap["questStage"] == 80) {
		//chataeau rest while buffing dmg
		chateauCast($skill[The Ode to Booze]);
		visit_url("clan_viplounge.php?preaction=speakeasydrink&drink=6&pwd="+my_hash()); //sockdollager
		chateauCast($skill[Rage of the Reindeer]);
		chateauCast($skill[Jackasses' Symphony of Destruction]);
		chateauCast($skill[Tenacity of the Snapper]);
		chateauCast($skill[Song of the North]);
		chateauCast($skill[Scowl of the Auk]);
		chateauCast($skill[The Magical Mojomuscular Melody]);
		useIfHave(1, $item[Gene Tonic: Beast]);
		useForTest("WeaponDmg");
		//useIfHave(1, $item[cuppa Twen tea]);
		while (my_level() < 8 && free_rest()) { //expends free rests until level 8 or running out
			while (have_skill($skill[Summon Taffy]) && my_mp() > (mp_cost($skill[Summon Taffy]) + 100)) {
				cast($skill[Summon Taffy]);
			}
		}
		if (my_level() < 8) {
			print("Failed to reach level 8.", "red");
		} else {
			if (free_rests_left() > 0) {
				print("Reached level 8 with "+ free_rests_left() +" free rests left", "green");
			} else {
				print("Reached level 8, but ran out of free rests", "blue");
			}
		}
		saveProgress(90);
	}
	
	if(statemap["questStage"] == 90) {
		//consume astrals
		if ($item[astral energy drink].available_amount() > 0) {
			chew(1, $item[astral energy drink]);
		} else if ($item[astral pilsner].available_amount() > 0) {
			if (my_inebriety() < 10 && my_adventures() < advCost(WPNTEST)) {
				if (have_effect($effect[Ode to Booze]) < 5) {
					chateauCast($skill[The Ode to Booze]);
				}
				drink($item[astral pilsner].available_amount()-1, $item[astral pilsner]);
				cli_execute("shrug ode");
			}
		}
		saveProgress(100);
	}
	
	if(statemap["questStage"] == 100) {
		maximize("weapon dmg", false);
		saveProgress(101);
		if (doCheckpoints) {
			abort("Checkpoint: Before Weapon Damage Test: "+advCost(WPNTEST)+" turns.");
		}
	}
	if(statemap["questStage"] >= 110) {
		return;
	}
	doTest(WPNTEST);
	saveProgress(110);
}

void eatMoreFoodD1() {
	if(statemap["questStage"] >= 120) {
		return;
	}
	//eat food
	useIfHave(1, $item[milk of magnesium]);
	eat(1, $item[weird gazelle steak]);
	if (my_fullness() < 15) {
		if ($item[snow crab].available_amount() > 0) {
			eat(1, $item[snow crab]);
		} else if ($item[Knob pasty].available_amount() > 0) {
			eat(1, $item[Knob pasty]);
		} else {
			print("Resorting to eating a fortune cookie for last point of fullness.", "red");
			buy(1, $item[fortune cookie]);
			eat(1, $item[fortune cookie]);
		}
	}
	saveProgress(120);
}

void itemTest() {       
	if(statemap["questStage"] >= 140) {
		return;
	}
	if(statemap["questStage"] == 120) {
		//buff item drop
		useIfHave(1, $item[Gene Tonic: Pirate]);
		useIfHave(1, $item[tin cup]);
		useIfHave(1, $item[cyclops eyedrops]);
		useIfHave(1, $item[cuppa Serendipi tea]);
		useForTest("Item");
		useTaffies($item[pulled yellow taffy]);
		if (have_effect($effect[Smithsness Presence]) == 0 && $item[handful of Smithereens].available_amount() > 0) {
			chew(1, $item[handful of Smithereens]);
		}
		if ($item[Dinsey Whinskey].available_amount() > 0 && my_inebriety() < 13) {
			if (have_effect($effect[Ode to Booze]) < 2) {
				chateauCast($skill[The Ode to Booze]);
			}
			drink(1, $item[Dinsey Whinskey]);
		}
		if ($item[Agitated Turkey].available_amount() > 0 && my_inebriety() < 14) {
			if (have_effect($effect[Ode to Booze]) == 0) {
				chateauCast($skill[The Ode to Booze]);
			}
			drink(1, $item[Agitated Turkey]);
		}
		cli_execute("shrug ode");
		basicItemDropBuffs();
		saveProgress(130);
	}
	if(statemap["questStage"] == 130) {
		maximize("item drop", false);
		saveProgress(131);
		if (doCheckpoints) {
			abort("Checkpoint: Before Item Test: "+advCost(ITEMTEST)+" turns.");
		}
	}
	if(statemap["questStage"] >= 140) {
		return;
	}
	doTest(ITEMTEST);
	saveProgress(140);
}

void getPotionIngredients() {
	if(statemap["questStage"] >= 150) {
		return;
	}
	if(statemap["questStage"] == 140) {
		if ($item[handful of Smithereens].available_amount() > 0 && $item[Golden Light].available_amount() < 1) {
			create(1, $item[Golden Light]);
		} 
		setFamiliar();
		saveProgress(141);
		if (doCheckpoints) {
			abort("Checkpoint: Before getting fruits. cherry: "+$item[cherry].available_amount()+", grapefruit: "+$item[grapefruit].available_amount()+", lemon: "+$item[lemon].available_amount());
		}
	}
	if (islandSkipped()) {
		while ($item[cherry].available_amount() == 0 || $item[grapefruit].available_amount() == 0 || $item[lemon].available_amount() == 0) {
			YRAdv($location[The Skeleton Store]);
		}
	} else {
		while ($item[filthy knitted dread sack].available_amount() == 0 || $item[filthy corduroys].available_amount() == 0) {
			YRAdv($location[Hippy Camp]);
		}
		item prevhat = equipped_item($slot[hat]);
		item prevpants = equipped_item($slot[pants]);
		equip($item[filthy knitted dread sack]);
		equip($item[filthy corduroys]);
		while ($item[cherry].available_amount() == 0) {
			if ($item[disassembled clover].available_amount() > 0) {
				use(1, $item[disassembled clover]);
				visit_url("adventure.php?snarfblat=26&confirm=on");
				use(1, $item[fruit basket]);
			} else {
				abort("Failed to get cherry from fruit baskets before running out of clovers.");
			}
		}
		if ($item[lemon].available_amount() == 0) {
			buy(1, $item[lemon]);
		}
		if ($item[olive].available_amount() == 0) {
			buy(1, $item[olive]);
		}
		if ($item[grapefruit].available_amount() == 0) {
			buy(1, $item[grapefruit]);
		}
		if ($item[tomato].available_amount() < 2) {
			buy(2-$item[tomato].available_amount(), $item[tomato]);
		}
		equip(prevhat);
		if (prevpants != $item[none]) {
			equip(prevpants);
		}
	}
	saveProgress(150);
}

void makePotionsDay1() {
	if(statemap["questStage"] >= 160) {
		return;
	}

	// milk has been created earlier if a dairy goat was the painting
	if ($item[gr8ps].available_amount() > 0 && $item[potion of temporary gr8tness].available_amount() == 0) {
		create(1, $item[potion of temporary gr8tness]); # guild must be open for this
	}

	if ($item[cherry].available_amount() > 0) {
		create(1, $item[oil of expertise]);
	}
	if ($item[grapefruit].available_amount() > 0) {
		create(1, $item[ointment of the occult]);
	}
	if ($item[lemon].available_amount() > 0 && $item[scrumptious reagent].available_amount() > 0) { //you've run out of reagants by now without way of sauce
		create(1, $item[philter of phorce]);
	}
	if ($item[tomato].available_amount() > 0 && $item[scrumptious reagent].available_amount() > 0) { //not available in skeleton store
		create(1, $item[tomato juice of powerful power]);
	}
	if ($item[olive].available_amount() > 0 && $item[scrumptious reagent].available_amount() > 0 && get_property_int("_rapidPrototypingUsed") < 5) { //also not in skeleton store; if you had everything so far you've also run out of free crafts
		create(1, $item[serum of sarcasm]);
	}
	saveProgress(160);
}

void endDay1() { //final actions of day 1; spell test buffing goes here
	if(statemap["questStage"] >= 170) {
		return;
	}
	if(statemap["questStage"] == 160) {
		if ((have_effect($effect[Smithsness Presence]) == 0 && $item[handful of Smithereens].available_amount() > 0) || (my_adventures() < 1)) {
			chew(1, $item[handful of Smithereens]);
		}
		cast($skill[Simmer]);
		chateauCast($skill[The Ode to Booze]);
		chateauCast($skill[The Ode to Booze]);
		if (my_inebriety() < 14) {
			chateauCast($skill[The Ode to Booze]);
		}
		chateauCast($skill[Arched Eyebrow of the Archmage]);
		chateauCast($skill[Spirit of Garlic]);
		chateauCast($skill[Song of Sauce]);
		if(get_property_boolean("barrelShrineUnlocked")) {
			visit_url("da.php?barrelshrine=1");
			visit_url("choice.php?whichchoice=1100&option=4&pwd="+my_hash());
		}
		if (have_familiar($familiar[Grim Brother])) {
			cli_execute("grim damage");
		}
		chewSpleen();
		chewSpleen();
		chewSpleen();
		while (free_rest()) { //expends all free rests
			while (have_skill($skill[Summon Taffy]) && my_mp() > (mp_cost($skill[Summon Taffy]) + 100)) {
				cast($skill[Summon Taffy]);
			}
		}
		maximize("adv", false);
		if (smashHippyStone) {
			chateaumantegna_buyStuff($item[antler chandelier]);
		} else {
			chateaumantegna_buyStuff($item[Artificial Skylight]);
		}
		if ($item[Newbiesport&trade; tent].available_amount() > 0) {
			use(1, $item[Newbiesport&trade; tent]);
		}
		visit_url("campground.php?action=telescopehigh");
		visit_url("clan_viplounge.php?action=hottub");

		saveProgress(165);
		if (doCheckpoints) {
			abort("Checkpoint: Before Nightcap.");
		}
	}
	if(statemap["questStage"] >= 170) {
		return;
	}
	nightcap();
	cli_execute("shrug ode");
	saveProgress(170);
}

// ###########################################################################
// Day 2 functions

void day2setup() {
	if(statemap["questStage"] >= 180) {
		return;
	}
	//chateaumantegna_buyStuff($item[Ceiling Fan]);
	summonDailyStuff();
	cli_execute("breakfast"); 
	hermit(99, $item[ten-leaf clover]);
	use($item[ten-leaf clover].available_amount(), $item[ten-leaf clover]);
	if (get_property_int("_deckCardsDrawn") == 0) {
		cli_execute("cheat forest");
		cli_execute("cheat giant growth");
		// strength is summoned later
	} else {
		print("Skipping deck draws...");
	}
	use_skill(3, $skill[Summon Smithsness]);
	use(1, $item[Flaskfull of Hollow]);
	create(3, $item[Louder Than Bomb]);
	create(1, $item[Saucepanic]);
	if (!have_skill($skill[Double-Fisted Skull Smashing])) {
		pulverize($item[Saucepanic]);
	} 
	create(1, $item[Vicar's Tutu]);
	equip($item[Vicar's Tutu]);
	create(1, $item[Staff of the Headmaster's Victuals]);
	if (!have_skill($skill[Spirit of Rigatoni])) {
		pulverize($item[Staff of the Headmaster's Victuals]);
	}
	if(get_property_boolean("barrelShrineUnlocked")) {
		visit_url("da.php?barrelshrine=1");
		visit_url("choice.php?whichchoice=1100&option=1&pwd="+my_hash());
	}
	if (teaTreeAvailable() && get_property_boolean("_pottedTeaTreeUsed") == false) {
		cli_execute("teatree cuppa obscuri tea");
	}
	checkGameInform();
	cli_execute("eudora xi"); // switch back to Xi
	saveProgress(180);
}

void spellTest() { //buffing for this test is actually handled at the end of day 1 so there's not much here.
	if(statemap["questStage"] >= 190) {
		return;
	}
	if(statemap["questStage"] == 180) {
		float spell_damage_percent = numeric_modifier("Spell Damage Percent");
		int current_saved_turns = floor(spell_damage_percent / 50);
		int saved_turns = floor((spell_damage_percent + 10) / 50);
		if (saved_turns > current_saved_turns) {
			if ($item[scrumptious reagent].available_amount() > 0 && $item[cordial of concentration].available_amount() == 0 && get_property_int("_rapidPrototypingUsed") < 5)  {
				buy(1, $item[soda water]);
				create(1, $item[cordial of concentration]);
			}
			if ($item[cordial of concentration].available_amount() > 0) {
				use(1, $item[cordial of concentration]);
			}
		}
		//useIfHave(1, $item[cuppa Twen tea]);
		chateauCast($skill[Jackasses' Symphony of Destruction]);
		maximize("spell damage", false);

		saveProgress(181);
		if (doCheckpoints) {
			abort("Checkpoint: Before Spell Damage Test: "+advCost(SPELLTEST)+" turns.");
		}
	}

	if(statemap["questStage"] >= 190) {
		return;
	}
	doTest(SPELLTEST);
	saveProgress(190);
}

void getHotResistGear() {
	if(statemap["questStage"] >= 200) {
		return;
	}
	if ($item[Saucepanic].available_amount() > 0) {
		equip($slot[weapon], $item[Saucepanic]);
	}
	cli_execute("shrug Jackasses' Symphony of Destruction");
	if ($item[Staff of the Headmaster's Victuals].available_amount() > 0) {
		pulverize($item[Staff of the Headmaster's Victuals]);
	}
	if ($item[handful of Smithereens].available_amount() > 0 && $item[Golden Light].available_amount() < 1) {
		create(1, $item[Golden Light]);
	} 
	setFamiliar();
	if (get_property_boolean("hotAirportAlways")) {
		if ($item[lava-proof pants].available_amount() > 0) {
			while($item[heat-resistant necktie].available_amount() == 0) {
				YRAdv($location[LavaCo&trade; Lamp Factory]);
			}
		} else {
			while($item[lava-proof pants].available_amount() == 0) {
				YRAdv($location[LavaCo&trade; Lamp Factory]);
			}
		}
		if ($item[Gene Tonic: Dude].available_amount() == 0 && $item[DNA extraction syringe].available_amount() > 0) {
			visit_url("campground.php?action=dnapotion");
			if (get_property_int("_dnaPotionsMade") < 2) {
				visit_url("campground.php?action=dnapotion");
			}
		}
	}
	saveProgress(200);
}

void makePotionsDay2() {
	if(statemap["questStage"] >= 210) {
		return;
	}
	if ($item[olive].available_amount() > 0 && $item[serum of sarcasm].available_amount() == 0) { 
		create(1, $item[serum of sarcasm]);
	}
	// maybe lotion of stench later
	// maybe lotion of sleaziness later
	// maybe cordial of concentration later
	// perfume of prejudice later
	// cleesh potions?
	saveProgress(210);
}

void hotTest() {
	if(statemap["questStage"] == 210) {
		pulverize($item[dirty rigging rope]);
		pulverize($item[sewage-clogged pistol]);
		pulverize($item[dirty hobo gloves]);
		pulverize($item[plastic nunchaku]);
		pulverize($item[asparagus knife]);
		if ($item[stench powder].available_amount() > 0 && $item[scrumptious reagent].available_amount() > 0) {
			create(1, $item[lotion of stench]);
			use(1, $item[lotion of stench]);
		}
		if ($item[sleaze powder].available_amount() > 0 && $item[scrumptious reagent].available_amount() > 0) { //not that I have any idea what I could pulverize for this.
			create(1, $item[lotion of sleaziness]);
			use(1, $item[lotion of sleaziness]);
		}
		if (my_basestat($stat[moxie]) < 35 && ($item[lava-proof pants].available_amount() > 0 || $item[heat-resistant gloves].available_amount() > 0)) {
			chateaumantegna_buyStuff($item[bowl of potpourri]);
			while(my_basestat($stat[moxie]) < 35 && free_rest()) {
				while (have_skill($skill[Summon Taffy]) && my_mp() > (mp_cost($skill[Summon Taffy]) + 100)) {
					cast($skill[Summon Taffy]);
				}
			}
			chateaumantegna_buyStuff($item[foreign language tapes]);
		}
		if ($item[lava-proof pants].available_amount() > 0) {
			equip($item[lava-proof pants]);
		}
		if ($item[perfume-soaked bandana].available_amount() > 0) {
			equip($slot[acc1], $item[perfume-soaked bandana]);
		}
		if ($item[heat-resistant necktie].available_amount() > 0) {
			equip($slot[acc2], $item[heat-resistant necktie]);
		}
		if ($item[heat-resistant gloves].available_amount() > 0) {
			equip($slot[acc3], $item[heat-resistant gloves]);
		}
		useIfHave(1, $item[scroll of Protection from Bad Stuff]);
		useIfHave(1, $item[Gene Tonic: Elemental]);
		useIfHave(1, $item[cuppa Frost tea]);
		useIfHave(1, $item[hot powder]);
		useForTest("HotRes");
		if (alwaysFam == $familiar[Exotic Parrot] || (have_familiar($familiar[Exotic Parrot]) && alwaysFam == $familiar[none])) {
			use_familiar($familiar[Exotic Parrot]);
			chateauCast($skill[Leash of Linguini]);
			chateauCast($skill[Empathy of the Newt]);
			if ($item[astral pet sweater].available_amount() > 0) {
				equip($item[astral pet sweater]);
			}
		}
		saveProgress(220);
	} 
	
	if(statemap["questStage"] == 220) {
		eatHotFood();
		chateauCast($skill[Elemental Saucesphere]);
		chateauCast($skill[Astral Shell]);
		if (!hasScalingZone() ||
		   (g9val() > 300 && ($item[potion of temporary gr8tness].available_amount() > 0 || $item[gr8ps].available_amount() > 0) &&
			   (($item[power pill].available_amount() > 0) || $item[yellow pixel].available_amount() >= 15))) {
		      if (have_effect($effect[Ode to Booze]) < 2) {
			      chateauCast($skill[The Ode to Booze]);
		      }
		      visit_url("clan_viplounge.php?preaction=speakeasydrink&drink=7&pwd="+my_hash()); //ish kabibble
		}
		cli_execute("shrug ode");
		saveProgress(230);
	}

	if(statemap["questStage"] == 230) {
		maximize("hot res", false);
		saveProgress(231);
		if (doCheckpoints) {
			abort("Checkpoint: Before Hot Resistance Test: "+advCost(HOTTEST)+" turns.");
		}
	}

	if(statemap["questStage"] >= 240) {
		return;
	}
	doTest(HOTTEST);
	saveProgress(240);
}

void powerlevel() {
	if(statemap["questStage"] >= 260) {
		return;
	}
	if (!hasScalingZone()) {
		print("No scaling zone found...skipping powerleveling.", "red");
		saveProgress(260);
		return;
	}

	if(statemap["questStage"] == 240) {
		// --------------------------------------------------
		// ML
		if ((have_effect($effect[The Dinsey Look]) == 0) && ($item[FunFunds&trade;].available_amount() > 0)) { 
			buy($coinmaster[The Dinsey Company Store], 1, $item[Dinsey face paint]);
			use(1, $item[Dinsey face paint]); // +40 ML @ 20 adv
		}
		if ((g9val() > 300 && $item[yellow pixel].available_amount() >= 10) ||
		     (($item[yellow pixel].available_amount() >= 10) && ($item[yellow pixel].available_amount() < 15))) {
			create(1, $item[yellow pixel potion]);
			use(1, $item[yellow pixel potion]); // +25 ML @ 20 adv
		}
		chateauCast($skill[Ur-Kel's Aria of Annoyance]); // +18/+20 ML @ 5 adv
		chateauCast($skill[Ur-Kel's Aria of Annoyance]);
		chateauCast($skill[Ur-Kel's Aria of Annoyance]);
		chateauCast($skill[Ur-Kel's Aria of Annoyance]);
		chateauCast($skill[Ur-Kel's Aria of Annoyance]);
		if (($item[hot ashes].available_amount() > 0) && (have_effect($effect[Ashen Burps]) == 0)) {
			create(1, $item[ash soda]);
			use(1, $item[ash soda]); // +15 ML @ 15 adv
		}
		chateauCast($skill[Pride of the Puffin]); // +10 ML @ 10 adv
		chateauCast($skill[Pride of the Puffin]);
		chateauCast($skill[Pride of the Puffin]);
		chateauCast($skill[Drescher's Annoying Noise]); // +10 ML @ 20 adv
		chateauCast($skill[Drescher's Annoying Noise]);
		if ($item[perfume of prejudice].available_amount() == 0 && get_property_int("_rapidPrototypingUsed") < 5) {
			create(1, $item[perfume of prejudice]);
		}
		useifhave(2, $item[perfume of prejudice]); // +5 ML @ 15 adv
		useIfHave(1, $item[cuppa Mediocri tea]); // only in case
		// plus +50 ML barrel lid (later equipped)
		// plus +30 ML friars set after turn 1
		// plus +10 ML MCD

		// --------------------------------------------------
		// +all%
		useIfHave(1, $item[experimental serum G-9]); // +???% all @ 40 adv
		chateauCast($skill[The Ode to Booze]);
		visit_url("clan_viplounge.php?preaction=speakeasydrink&drink=5&pwd="+my_hash()); //bee's knees +100% all @ 25 adv
		cli_execute("shrug ode");
		if ($item[power pill].available_amount() > 0) {
			useIfHave(1, $item[power pill]); // +100% all @ 30 adv
		} else {
			if ($item[yellow pixel].available_amount() >= 15) {
				create(1, $item[miniature power pill]);
				use(1, $item[miniature power pill]);
			}
		}
		useIfHave(2, $item[potion of temporary gr8tness]); // +100% all @ 15 adv
		useIfHave(2, $item[tomato juice of powerful power]); // +50% all @ 15 adv
		if (doghouseAvailable()) {
			set_property("choiceAdventure1106","2"); // Adventurer's Best Friendship +50% all @ 30 adv
		}
		pulverize($item[A Light That Never Goes Out]);
		if (have_effect($effect[Smithsness Presence]) == 0 && $item[handful of Smithereens].available_amount() > 0) {
			chew(1, $item[handful of Smithereens]);
		}
		useIfHave(1, $item[Gene Tonic: Humanoid]); // +10% all @ 30 adv
		chateauCast($skill[Stevedave's Shanty of Superiority]); // +10% all @ 5 adv
		chateauCast($skill[Stevedave's Shanty of Superiority]);
		chateauCast($skill[Stevedave's Shanty of Superiority]);
		chateauCast($skill[Stevedave's Shanty of Superiority]);
		chateauCast($skill[Stevedave's Shanty of Superiority]);

		// --------------------------------------------------
		// +myst%
		useIfHave(1, $item[ointment of the occult]); // +100% myst @ 15 adv
		buy(10, $item[glittery mascara]); // +15% myst @ 3adv
		use(10, $item[glittery mascara]);

		// --------------------------------------------------
		// +myst
		chateauCast($skill[The Magical Mojomuscular Melody]);
		chateauCast($skill[The Magical Mojomuscular Melody]);
		chateauCast($skill[The Magical Mojomuscular Melody]);
		chateauCast($skill[The Magical Mojomuscular Melody]);
		chateauCast($skill[The Magical Mojomuscular Melody]);
		chateauCast($skill[Sauce Contemplation]);
		chateauCast($skill[Sauce Contemplation]);
		chateauCast($skill[Sauce Contemplation]);
		chateauCast($skill[Sauce Contemplation]);
		chateauCast($skill[Sauce Contemplation]);
		chateauCast($skill[Manicotti Meditation]);
		chateauCast($skill[Manicotti Meditation]);
		chateauCast($skill[Manicotti Meditation]);
		chateauCast($skill[Manicotti Meditation]);
		chateauCast($skill[Manicotti Meditation]);

		// --------------------------------------------------
		// +exp
		chateauCast($skill[Aloysius' Antiphon of Aptitude]); // +1 exp @ 5 adv
		chateauCast($skill[Aloysius' Antiphon of Aptitude]);
		chateauCast($skill[Aloysius' Antiphon of Aptitude]);
		chateauCast($skill[Aloysius' Antiphon of Aptitude]);
		chateauCast($skill[Aloysius' Antiphon of Aptitude]);
		chateauCast($skill[Wry Smile]); // +1 exp @ 10 adv
		chateauCast($skill[Wry Smile]);
		chateauCast($skill[Wry Smile]);

		// --------------------------------------------------
		// +all
		useIfHave(1, $item[Gene Tonic: Dude]);

		// --------------------------------------------------
		// +hp
		buy(10, $item[Ben-Gal&trade; Balm]);
		use(10, $item[Ben-Gal&trade; Balm]);
		chateauCast($skill[Reptilian Fortitude]);
		chateauCast($skill[Reptilian Fortitude]);
		chateauCast($skill[Reptilian Fortitude]);
		chateauCast($skill[Reptilian Fortitude]);
		chateauCast($skill[Reptilian Fortitude]);

		// --------------------------------------------------
		// +spell dmg%
		chateauCast($skill[Song of Sauce]);
		chateauCast($skill[Song of Sauce]);
		chateauCast($skill[Song of Sauce]);

		// --------------------------------------------------
		// familiar
		if (alwaysFam != $familiar[none]) {
			use_familiar(alwaysFam);
		} else if (have_familiar($familiar[Galloping Grill])) {
		  use_familiar($familiar[Galloping Grill]);
		} else if (have_familiar($familiar[Hovering Sombrero])) {
			use_familiar($familiar[Hovering Sombrero]);
		} else if (have_familiar($familiar[Golden Monkey])) {
			use_familiar($familiar[Golden Monkey]);
		} else if (have_familiar($familiar[Grim Brother])) {
			use_familiar($familiar[Grim Brother]);
		} else if (have_familiar($familiar[Unconscious Collective])) {
			use_familiar($familiar[Unconscious Collective]);
		} else if (have_familiar($familiar[Smiling Rat])) {
			use_familiar($familiar[Smiling Rat]);
		}
		while ($item[Ghost Dog Chow].available_amount() > 0) {
			use(1, $item[Ghost Dog Chow]); // +20 fam exp
		}
		if ($item[astral pet sweater].available_amount() > 0) {
			equip($item[astral pet sweater]); // +10 lb
		}
		chateauCast($skill[Leash of Linguini]); // +5 lb @ 10 adv
		chateauCast($skill[Leash of Linguini]);
		chateauCast($skill[Leash of Linguini]);
		chateauCast($skill[Empathy of the Newt]); // +5 lb @ 5 adv
		chateauCast($skill[Empathy of the Newt]);
		chateauCast($skill[Empathy of the Newt]);
		chateauCast($skill[Empathy of the Newt]);
		chateauCast($skill[Empathy of the Newt]);

		// --------------------------------------------------
		// wrap up
		while (free_rest()) {
			while (have_skill($skill[Summon Taffy]) && my_mp() > (mp_cost($skill[Summon Taffy]) + 100)) {
				cast($skill[Summon Taffy]);
			}
		}
		useIfHave(7, $item[pulled violet taffy]);
		useIfHave(7, $item[pulled blue taffy]); // up to +5lb & + 10 fam exp @ 50 adv

		maximize("myst", false);
		equip($item[barrel lid]); // +50 ML
		saveProgress(250);
		if (doCheckpoints) {
			abort("Checkpoint: Before Powerleveling.  G-9: "+g9val());
		}
	}
	if(statemap["questStage"] == 250) {
		lockFamiliar = true;
		location farmzone;
		if (get_property_boolean("stenchAirportAlways")) {
			farmzone = $location[Uncle Gator's Country Fun-Time Liquid Waste Sluice];
		} else if (get_property_boolean("spookyAirportAlways")) {
			farmzone = $location[The Deep Dark Jungle];
		} else if (get_property_boolean("sleazyAirportAlways")) {
			farmzone = $location[Sloppy Seconds Diner];
		} else if (get_property_boolean("hotAirportAlways")) {
			farmzone = $location[The SMOOCH Army HQ];
		} else {
			farmzone = $location[Video Game Level 1];
		}
		powerlevelMood();
		int pl_started = total_turns_played();
		boolean friars = false;
		while (total_turns_played() - pl_started < 18) {
			if (my_adventures() == 0) {
				abort("Ran out of adventures.");
			}
			if (farmzone == $location[Video Game Level 1] && level2unlocked()) {
				farmzone = $location[Video Game Level 2];
			}
			if (($item[hot ashes].available_amount() > 0) && (have_effect($effect[Ashen Burps]) == 0)) {
				create(1, $item[ash soda]);
				use(1, $item[ash soda]);
			}
			if (($item[FunFunds&trade;].available_amount() > 0) && (have_effect($effect[The Dinsey Look]) == 0)) { 
				buy($coinmaster[The Dinsey Company Store], 1, $item[Dinsey face paint]);
				use(1, $item[Dinsey face paint]);
			}
			combatAdv(farmzone, true);
			if (friars == false) {
				cli_execute("florist plant War Lily"); # indoor +30 ML
				cli_execute("florist plant Impatiens"); # indoor +25% init
				cli_execute("florist plant Pitcher Plant"); # indoor restores MP
				friars = true;
			}
			if (have_effect($effect[beaten up]) > 0) {
				abort("Getting beaten up when trying to powerlevel. Consider changing custom combat script?");
			}
			restore_hp(my_maxhp());
			buffer page = visit_url("campground.php?action=workshed");
			if (contains_text(page, "Human-Machine Hybrid") && $item[Gene Tonic: Construct].available_amount() == 0) {
				visit_url("campground.php?action=dnapotion");
			}
		}
		cli_execute("mood clear");
		lockFamiliar = false;
		saveProgress(255);
		if (doCheckpoints) {
			abort("Checkpoint: After Powerleveling.");
		}
	}
	if(statemap["questStage"] >= 260) {
		return;
	}
	cli_execute("shrug antiphon");
	cli_execute("shrug ur-kel");
	cli_execute("shrug mojomuscula");
	saveProgress(260);
}

void hpTest() {
	if(statemap["questStage"] >= 280) {
		return;
	}
	if(statemap["questStage"] == 260) {
		use(1, $item[oil of expertise]);
		use(1, $item[jar of &quot;Creole Lady&quot; marrrmalade]);
		useIfHave(1, $item[scroll of Puddingskin]);
		useIfHave(1, $item[philter of phorce]);
		useIfHave(1, $item[cuppa Feroci tea]);
		useIfHave(1, $item[cuppa Twen tea]);
		if (have_effect($effect[Tomato Power]) == 0) {
			useIfHave(1, $item[tomato juice of powerful power]);
		}
		if (have_effect($effect[Experimental Effect G-9]) == 0) {
			useIfHave(1, $item[experimental serum G-9]);
		}
		cli_execute("cheat strength");
		//buy(2, $item[Ben-Gal&trade; Balm]);
		//use(1, $item[Ben-Gal&trade; Balm]);
		chateauCast($skill[Song of Starch]);
		chateauCast($skill[Seal Clubbing Frenzy]);
		chateauCast($skill[Stevedave's Shanty of Superiority]);
		chateauCast($skill[Reptilian Fortitude]);
		chateauCast($skill[The Power Ballad of the Arrowsmith]);
		chateauCast($skill[Sauce Contemplation]);
		chateauCast($skill[Patience of the Tortoise]);
		chateauCast($skill[Moxie of the Mariachi]);
		chateauCast($skill[Rage of the Reindeer]);
		if (have_familiar($familiar[Grim Brother])) {
			cli_execute("grim hpmp");
		}
		useIfHave(1, $item[dollop of barbecue sauce]);
		useIfHave(1, $item[confiscated comic book]);
		useIfHave(1, $item[really thick spine]);
		useForTest("HP");
		if (have_effect($effect[Smithsness Presence]) == 0 && $item[handful of Smithereens].available_amount() > 0) {
			chew(1, $item[handful of Smithereens]);
		}
		useTaffies($item[pulled orange taffy]);
		visit_url("campground.php?action=telescopehigh");
		saveProgress(270);
	}
	
	if(statemap["questStage"] == 270) {
		maximize("hp", false);
		if(advCost(HPTEST) > 4) {
			chateauCast($skill[The Ode to Booze]);
			chateauCast($skill[The Ode to Booze]);
			drink(1, $item[vintage smart drink]);
		}
		saveProgress(271);
		if (doCheckpoints) {
			abort("Checkpoint: Before HP Test: "+advCost(HPTEST)+" turns.");
		}
	}
	if(statemap["questStage"] >= 280) {
		return;
	}
	if(doTest(HPTEST)) {
		chew(1, $item[blood-drive sticker]);
	}
	saveProgress(280);
}

void muscleTest() {
	if(statemap["questStage"] >= 300) {
		return;
	}
	if(statemap["questStage"] == 280) {
		if (have_effect($effect[Power Ballad of the Arrowsmith]) == 0) {
			chateauCast($skill[The Power Ballad of the Arrowsmith]);
		} 
		if (have_effect($effect[Rage of the Reindeer]) == 0) {
			chateauCast($skill[Rage of the Reindeer]);
		} 
		chateauCast($skill[Seal Clubbing Frenzy]);
		chateauCast($skill[Patience of the Tortoise]);
		useIfHave(1, $item[jar of &quot;Creole Lady&quot; marrrmalade]);
		useIfHave(1, $item[dollop of barbecue sauce]);
		useIfHave(1, $item[cuppa Feroci tea]);
		useForTest("Muscle");
		buy(1, $item[Ben-Gal&trade; Balm]);
		use(1, $item[Ben-Gal&trade; Balm]);
		if (($item[squashed frog].available_amount() > 0) && (get_property_int("_rapidPrototypingUsed") < 5)) {
			create(1, $item[Frogade]);
			use(1, $item[Frogade]);
		}
		useTaffies($item[pulled orange taffy]);
		if (have_effect($effect[Phorcefullness]) == 0) {
			useIfHave(1, $item[philter of phorce]);
		}
		if (have_effect($effect[Expert Oiliness]) == 0) {
			useIfHave(1, $item[oil of expertise]);
		}
		
		allStatBuffs();
		giantGrowth();
		saveProgress(290);
	}
	if(statemap["questStage"] == 290) {
		maximize("muscle", false);
		saveProgress(291);
		if (doCheckpoints) {
			abort("Checkpoint: Before Muscle Test: "+advCost(MUSTEST)+" turns.");
		}
	}
	if(statemap["questStage"] >= 300) {
		return;
	}
	doTest(MUSTEST);
	saveProgress(300);
}

void mystTest() {
	if(statemap["questStage"] >= 320) {
		return;
	}
	if(statemap["questStage"] == 300) {
		chateauCast($skill[The Magical Mojomuscular Melody]);
		chateauCast($skill[Sauce Contemplation]);
		chateauCast($skill[Manicotti Meditation]);
		useIfHave(1, $item[ointment of the occult]);
		useForTest("Myst");
		useTaffies($item[pulled violet taffy]);
		buy(1, $item[glittery mascara]);
		use(1, $item[glittery mascara]);
		if (($item[salamander spleen].available_amount() > 0) && (get_property_int("_rapidPrototypingUsed") < 5)) {
			create(1, $item[salamander slurry]);
			use(1, $item[salamander slurry]);
		}
		useIfHave(1, $item[confiscated cell phone]);
		if (get_property_int("_speakeasyDrinksDrunk") < 2 && have_effect($effect[On the Trolley]) == 0 && my_inebriety() <= 12) {
			if (have_effect($effect[Ode to Booze]) < 2) {
				chateauCast($skill[The Ode to Booze]);
			}
			visit_url("clan_viplounge.php?preaction=speakeasydrink&drink=5&pwd="+my_hash()); //bee's knees
			cli_execute("shrug ode");
		}
		if (have_effect($effect[Pill Power]) == 0 && $item[yellow pixel].available_amount() >= 15) {
			create(1, $item[miniature power pill]);
			use(1, $item[miniature power pill]);
		}
		allStatBuffs();
		giantGrowth();
		useIfHave(1, $item[bag of grain]);
		useIfHave(1, $item[cuppa Wit tea]);
		useIfHave(1, $item[Gene Tonic: Dude]);
		saveProgress(310);
	}
	if(statemap["questStage"] == 310) {
		maximize("myst", false);
		saveProgress(311);
		if (doCheckpoints) {
			abort("Checkpoint: Before Myst Test: "+advCost(MYSTTEST)+" turns.");
		}
	}
	if(statemap["questStage"] >= 320) {
		return;
	}
	doTest(MYSTTEST);
	saveProgress(320);
}

void moxieTest() {
	if(statemap["questStage"] >= 340) {
		return;
	}
	if(statemap["questStage"] == 320) {
		chateauCast($skill[The Moxious Madrigal]);
		chateauCast($skill[Disco Fever]);
		chateauCast($skill[Moxie of the Mariachi]);
		chateauCast($skill[Disco Aerobics]);
		chateauCast($skill[Blubber Up]);
		chateauCast($skill[Disco Smirk]);
		useIfHave(1, $item[dollop of barbecue sauce]);
		useIfHave(1, $item[pressurized potion of pulchritude]);
		useIfHave(1, $item[serum of sarcasm]);
		useIfHave(1, $item[cuppa Dexteri tea]);
		useIfHave(1, $item[confiscated love note]);
		useForTest("Moxie");
		useTaffies($item[pulled red taffy]);
		buy(1, $item[hair spray]);
		use(1, $item[hair spray]);
		if (($item[eye of newt].available_amount() > 0) && (get_property_int("_rapidPrototypingUsed") < 5)) {
			create(1, $item[eyedrops of newt]);
			use(1, $item[eyedrops of newt]);
		}
		if (get_property_int("_speakeasyDrinksDrunk") < 2 && have_effect($effect[On the Trolley]) == 0 && my_inebriety() <= 12) {
			if (have_effect($effect[Ode to Booze]) < 2) {
				chateauCast($skill[The Ode to Booze]);
			}
			visit_url("clan_viplounge.php?preaction=speakeasydrink&drink=5&pwd="+my_hash()); //bee's knees
			cli_execute("shrug ode");
		}
		if (have_effect($effect[Pill Power]) == 0 && $item[yellow pixel].available_amount() >= 15) {
			create(1, $item[miniature power pill]);
			use(1, $item[miniature power pill]);
		}
		if (have_effect($effect[Expert Oiliness]) == 0) {
			useIfHave(1, $item[oil of expertise]);
		}
		if ($item[Volcoino].available_amount() >= 1) {
			buy($coinmaster[Disco GiftCo], 1, $item[liquid rhinestones]);
			use(1, $item[liquid rhinestones]);
		}
		allStatBuffs();
		giantGrowth();
		useIfHave(1, $item[pocket maze]);
		saveProgress(330);
	}
	if(statemap["questStage"] == 330) {
		maximize("moxie", false);
		saveProgress(331);
		if (doCheckpoints) {
			abort("Checkpoint: Before Moxie Test: "+advCost(MOXTEST)+" turns.");
		}
	}
	if(statemap["questStage"] >= 340) {
		return;
	}
	doTest(MOXTEST);
	saveProgress(340);
}

void famTest() {
	if(statemap["questStage"] >= 360) {
		return;
	}
	if(statemap["questStage"] == 340) {
		chateauCast($skill[Empathy of the Newt]);
		chateauCast($skill[Leash of Linguini]);
		useIfHave(1, $item[cuppa Loyal tea]);
		useIfHave(1, $item[Gene Tonic: Construct]);
		useForTest("Weight");
		useTaffies($item[pulled blue taffy]);
		if ($item[astral pet sweater].available_amount() > 0) {
			equip($item[astral pet sweater]);
		}
		if($item[vintage smart drink].available_amount() > 0) {
			chateauCast($skill[The Ode to Booze]);
			chateauCast($skill[The Ode to Booze]);
			drink(1, $item[vintage smart drink]);
		}
		saveProgress(350);
	}
	if(statemap["questStage"] == 350) {
		maximize("familiar weight", false);
		saveProgress(351);
		if (doCheckpoints) {
			abort("Checkpoint: Before Familiar Weight Test: "+advCost(FAMTEST)+" turns.");
		}
	}
	if(statemap["questStage"] >= 360) {
		return;
	}
	doTest(FAMTEST);
	saveProgress(360);
}

void maybeGetDeodorant() {
	if(statemap["questStage"] >= 370) {
		return;
	}
	if(!islandSkipped() && YRsourceAvailable() && have_effect($effect[Everything Looks Yellow]) == 0) {
		chateauCast($skill[Musk of the Moose]);
		chateauCast($skill[Carlweather's Cantata of Confrontation]);
		useIfHave(1, $item[reodorant]);
		while($item[deodorant].available_amount() > 0) {
			YRAdv($location[Frat House]);
		}
		if(have_effect($effect[Carlweather's Cantata of Confrontation]) > 0) {
			cli_execute("uneffect " + $effect[Carlweather's Cantata of Confrontation].to_string());
		}
	}
	saveProgress(370);
}

void noncombatTest() {
	if(statemap["questStage"] >= 390) {
		return;
	}
	if(statemap["questStage"] == 370) {
		chateauCast($skill[The Sonata of Sneakiness]);
		chateauCast($skill[Smooth Movement]);
		if ($item[snow berries].available_amount() > 0) {
			create(1, $item[snow cleats]);
			use(1, $item[snow cleats]);
		}
		useIfHave(1, $item[deodorant]);
		useIfHave(1, $item[shady shades]);
		useIfHave(1, $item[squeaky toy rose]);
		useIfHave(1, $item[cuppa Obscuri tea]);
		useForTest("NonCombat");
		saveProgress(380);
	}
	if(statemap["questStage"] == 380) {
		maximize("-combat -tie", false);
		saveProgress(381);
		if (doCheckpoints) {
			abort("Checkpoint: Before Non Combat Test: "+advCost(COMTEST)+" turns.");
		}
	}
	if(statemap["questStage"] >= 390) {
		return;
	}
	doTest(COMTEST); 
	saveProgress(390);
}

// ###########################################################################
// Main functions

void checkPrereq() {
	if (!have_skill($skill[The Ode to Booze])) {
		abort("You need Ode to Booze first.");
	} else if (!have_skill($skill[Summon Smithsness])) {
		abort("You need Summon Smithsness first.");
	} else if (!have_skill($skill[Advanced Saucecrafting])) {
		abort("You need Advanced Saucecrafting first.");
	} else if (!get_property_boolean("chateauAvailable")) {
		abort("You need access to Chateau Mantegna first.");
	} else if ($item[Clan VIP Lounge key].available_amount() == 0) {
		abort("You need access to your clan's VIP lounge first.");
	} else if ($item[Deck of Every Card].available_amount() == 0) {
		abort("You need the Deck of Every Card first.");
	} else if (my_class() != $class[sauceror]) {
		abort("You're supposed to be a sauceror.");
	} else if (!knoll_available()) {
		abort("You're supposed to have access to the (friendly) Degrassi Knoll. You know, muscle sign.");
	} else if (my_path() != "Community Service") {
		abort("You need to actually be in a Community Service run.");
	} else if (!in_hardcore() && !doSoftcore) {
		abort("I see that you are in softcore; if you would like to enable softcore handling, please set acs_doSoftcore to true in the relay settings.");
    }
}

void doRun() { //main function
	if (my_daycount() == 1 && actuallyrun) {
		print("Running HCCS Day 1...");
		if(get_property("knownAscensions").to_int() != statemap["run"]) {
			newSave();
		}
		day1setup(); // Progress #10
		initialDrinks(); // Progress #20
		doChateauPainting();  // Progress #30, 0 adv, 1 adv used, itemfam or shrub
		maybeYRHotResistGear(); // Progress #35, 1 adv, 1 adv used if not YRed yet, shrub
		coilTest(); // Progess #40, 2 adv, 60 adv used
		openGuild(); // Progress #45, 62 adv, 5+1 adv used, puck man
		getPirateDNA(); // Progress #50, 67 adv, 1 adv used, puck man
		getCalderaDNA(); //elemental DNA tonic and fish hybrid // progress #60, 68 adv, 2-5 adv used, puck man (4)
		maybeUnlockIsland(); // Progress #70
		getG9Serum(); // Progress #80, 71 adv, 2-7 advs used, cheerleader (4)
		weaponTest(); // Progress #90-110, 75 adv, 56 adv used
		eatMoreFoodD1(); // Progress #120, 131 adv
		itemTest(); // Progess #130-140, 131 adv, 44-48 adv used
		getPotionIngredients(); // Progress #105, 179 adv, 1-4 advs used, shrub 
		if (gr8psAvailable() && ($item[yellow pixel].available_amount() < 10) && ($item[power pill].available_amount() < 1)) {
			abort("Missing "+(10-$item[yellow pixel].available_amount())+" yellow pixel or "+(1-$item[power pill].available_amount())+" power pill");
		}
		makePotionsDay1(); // Progress #160, 182 adv
		endDay1(); // Progress #170, 182 adv, 1 adv used
		print("Day 1 complete!!", "green");
	} else if (my_daycount() == 2 && actuallyrun) {
		print("Running HCCS Day 2...");
		day2setup(); // Progress #180
		spellTest(); // Progress #190, 183 adv, 45 adv used
		getHotResistGear(); // YR, Progress #200
		makePotionsDay2(); // Progress #210
		hotTest(); // Progress #220-240
		powerlevel(); // Grill, Progress #250-260
		hpTest(); // Progress #270-280
		muscleTest(); // Progress #290-300
		mystTest(); // Progress #310-320
		moxieTest(); // Progress #330-340
		famTest(); // Progress #350-360
		maybeGetDeodorant(); // YR available & island open? Progress #370
		noncombatTest(); // Progress #380-390
		print("Run complete!!!", "green");
		newSave();
	} else if (!actuallyrun) {
		print("The \"actuallyrun\" variable is set to false. Turn it on.", "red");
	} else {
		print("You're too slow!");
	}
}

// ---------------------------------------------------------------------------

checkPrereq();
loadSave();
doRun();