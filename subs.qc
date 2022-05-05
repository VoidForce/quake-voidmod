// copper mod's code for easier dprints (by Lunaran)
void(string s, string ss) dprint2 = 
	{ dprint(s); dprint(ss); }
void(string s, string ss, string sss) dprint3 = 
	{ dprint(s); dprint(ss); dprint(sss); }
void(string s, string ss, string sss, string ssss) dprint4 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); }
void(string s, string ss, string sss, string ssss, string sssss) dprint5 = 
	{ dprint(s); dprint(ss); dprint(sss); dprint(ssss); dprint(sssss); }
void(string s1, string s2, string s3, string s4, string s5, string s6) dprint6 = 
	{ dprint(s1); dprint(s2); dprint(s3); dprint(s4); dprint(s5); dprint(s6); dprint("\n"); }
void() endl =
	{ dprint("\n");}

void() SUB_Null = {};
void(entity attacker, float damage) SUB_NullPain ={};

void() SUB_Remove = {remove(self);};

//from coppermod by Lunaran
void() SUB_RemoveSoon = 
{
	// ensure no shenanigans take place in the next hundredth of a second
	// otherwise we get weirdness like items being picked up twice at high framerates
	self.model = string_null;
	self.solid = SOLID_NOT;
	self.touch = SUB_Null;
	self.use = SUB_Null;
	
	self.think = SUB_Remove;
	self.nextthink = time;
}

/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
};

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
};

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
local vector	vdestdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
		
// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
// calculate length of vector
	len = vlen (vdestdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
};

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};


/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating 

The calling function should make sure self.think is valid
===============
*/
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
local vector	destdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");
		
// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	
// calculate length of vector
	len = vlen (destdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);
	
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};


//=============================================================================

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void() SUB_UseTargets =
{
	local entity t, stemp, otemp, act;

//
// check for a delay
//
	if (self.delay)
	{
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}
	
	
//
// print the message
//
	if (activator.monstertype == P_PLAYER && self.message != "")
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

//
// kill the killtagets
//
local float exitfromloop;
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find (t, targetname, self.killtarget);
			if (!t)	exitfromloop = 1;
			else remove (t);
		} while ( !exitfromloop );
	}
	
//
// fire targets
//
	exitfromloop = 0;
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, targetname, self.target);
			if (!t)
			{
				exitfromloop = 1;
			}
			else
			{
				stemp = self;
				otemp = other;
				self = t;
				other = stemp;
				if (self.use != SUB_Null)
				{
					if (self.use)
						self.use ();
				}
				self = stemp;
				other = otemp;
				activator = act;
			}
		} while ( !exitfromloop );
	}
	

};


/*

in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically

*/

void(float easy, float normal, float hard, float nightmare) SUB_AttackFinished =
{
	local float aftime;
	
	self.cnt = 0;		// refire count for nightmare
	
		 if (skill == 3) aftime = nightmare;
	else if (skill == 2) aftime = hard;
	else if (skill == 1) aftime = normal;
	else aftime = easy;
	
	/*if (skill == 3) normal = normal - 0.8;
	if (skill == 2) normal = normal - 0.6;
	if (skill == 1) normal = normal - 0.4;*/

	self.attack_finished = time + aftime;
};

float (entity targ) visible;

void (void() thinkst) SUB_CheckRefire =
{
	//if (skill != 3)
	//	return;
	if (self.cnt == 1)
		return;
	if (!visible (self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
};

vector(entity who, entity victim) SUB_GetDirection =
{
	local vector dir;
	local vector vic_org,who_org;
	vic_org = victim.origin;
	who_org = who.origin;
	vic_org_z = 0;
	who_org_z = 0;
	dir = vic_org - who_org;
	dir = normalize(dir);
	return(dir);
};

float (entity e, float healamount, float ignore) T_Heal;

void (entity who, float thinktime) Think =
{	
	who.nextthink = time + thinktime;
};
// Special think for two stage enragement (shambler)
void (entity who, float thinktime) ThinkE =
{	
	if (who.enraged == 2) 
	{
		who.nextthink = time + thinktime * 0.5;
		return;
	}
	if (who.enraged == 1) 
	{
		who.nextthink = time + thinktime * 0.75;
		return;
	}
	who.nextthink = time + thinktime;
};

void (entity who, float thinktime, float thinktimevt) ThinkV =
{	
	if (who.void_time > time) 
		who.nextthink = time + thinktimevt;
	else who.nextthink = time + thinktime;
};

float (entity who, float bonusduration, float chance, float reset) VoidForceBonus  =
{
	//bonusduration = 30;
	if (who.monstertype == P_PLAYER) 
	{
		if (reset == 1) // pure reset
		{
			sound (who, CHAN_AUTO, "items/voidforcein.wav", 1.0, ATTN_NORM);
			stuffcmd (who, "bf\n");
			who.changevcshift = 1;
			who.void_time = time + bonusduration;
			return 1;
		}

		local float randomstore;
		randomstore = 99*random();
		
		if (randomstore < chance)
		{
			if (who.void_time < time )	//was not in bonus
			{
				sound (who, CHAN_AUTO, "items/voidforcein.wav", 1.0, ATTN_NORM);
				stuffcmd (who, "bf\n");
				who.changevcshift = 1;
				who.void_time = time + bonusduration;
				return 1;
			}
			
			if (reset == 2) // we don't want to add bonus time over wished duration, so check
			{
				local float currentduration;
			
				currentduration = who.void_time - time;

				if (currentduration < bonusduration)
				{
					stuffcmd (who, "bf\n");
					who.void_time = time + bonusduration;
					return 1;
				}
			}

			who.void_time += bonusduration; // add small amount
			stuffcmd (who, "bf\n");
			return 1;
		}
	}
	return 0;
};

void (entity who) StripPlates =
{
	if (who.armorplates > 0) who.armorvalue -= who.armorplates;
};

void (entity who) PutPlates =
{
	if (who.armorplates > 0) who.armorvalue += who.armorplates;
};

void (entity who, float amount) GivePlates =
{
	StripPlates(who);
	who.armorplates += amount;
	if (!(who.items & IT_ARMOR3)) who.items = who.items + IT_ARMOR3;
	PutPlates(who);
};
//--------------------------------- style system---------------------------------
//.float		style_points; 
//.float		style_last;
//.float		style_denominator;
/*
We want player to execute different styles
StyleTypes:
0 - nostyle
1 - SG Perfect Range
2 - SSG Refire
3 - NG loop
4 - NG fullcharge
5 - SNG nail strong touch -- goes with customflag == 1
6 - GL Direct hit
7 - RL Nails 
8 - LG perfectly accurate shot
9 - 
10 - 
// bonustime styles
11 - SSG midair backwards boost
12 - 
13 -
14 -
15 -
*/
void () ComboMath =
{
// executed from combo entity of player, so we must use self.owner to get values.
	//style_points; // style system
	//style_combo; // current stage of combo
	//style_denominator;
	//style_last;
	//style_dmgdone;
	//style_dmgtaken;
	
	self.owner.style_dmgdone = 0;
	self.owner.style_dmgtaken = 0;
	
// combo entity stuff
	self.think = ComboMath;
	self.nextthink = time + 1;
};
// StyleGive(self, 50, 1, 0);
void (entity who, float amount, float styletype, float customflag) StyleGive =
{
	if (who.void_time > time) return; // we don't add anything while bonus is active
	
	amount = amount * style_multiplier[who.style_combo];
	//dprint3("Style points amount - ",ftos(amount),"\n");
	//dprint(ftos(styletype));
	//dprint(" - styletype\n");
	if (!(styletype))
	{
		who.style_points += amount;
	}
	else 
	{
		if (who.style_last == styletype) 
		{
			if (customflag == 1) who.style_denominator += 0.25;
			else who.style_denominator += 1;
		}
		else who.style_denominator = 1;
		if (!(who.style_denominator)) who.style_denominator = 1; // doesn't suppose to happen, but still, we play safe
		who.style_points += amount / who.style_denominator;
		who.style_points = ceil(who.style_points);
		who.style_last = styletype;
	}
	// ----------------- Bonus Trigger
	if (who.style_points > 999)
	{
		if (skill == 3) VoidForceBonus(who, 20, 100, 1);
		else VoidForceBonus(who, 14, 100, 1);
		who.style_points = 0;
		who.style_denominator = 1;
		centerprint(who,"Void force amassed\n");
	}
	//dprint(ftos(who.style_points));
	//dprint(" - style_points(add) \n");
};

// Punish player for taking damage and taking healthpacks
void (entity who, float amount) StylePenalty =
{
	who.style_points -= amount;
	if (who.style_points < 1) who.style_points = 0;
	//dprint(ftos(who.style_points));
	//dprint(" - style_points(penalty) \n");
};

void (entity who, float factor) StyleMultiply =
{
	who.style_points *= factor;
	who.style_points = ceil(who.style_points);
	//dprint(ftos(who.style_points));
	//dprint(" - style_points(multiply) \n");
};

void (entity who, float amount) GiveArmor =
{
		StripPlates(who);
		who.armorvalue = who.armorvalue + amount;
		if (who.armorvalue > 100) who.armorvalue = 100;
		if (who.armorvalue < 1) who.armorvalue = 0;
		PutPlates(who);
};
/*
monstertype:
1 - soldier
2 - dog
3 - enforcer
4 - knight
5 - wizard (scrag)
6 - ogre
7 - fiend (demon)
8 - hellknight
9 - shalrath(vore )
10 - shambler
11 - spawn
12 - rotfish
13 - zombie
*/
void (entity who, float amount, float skillzero, float skillone, float skilltwo, float skillthree ) KillHeal =
{
	if (amount)	T_Heal( who, amount, 0);
	else
	{
		if (skill == 0)	T_Heal( who, skillzero, 0);
		if (skill == 1)	T_Heal( who, skillone, 0);
		if (skill == 2)	T_Heal( who, skilltwo, 0);
		if (skill == 3)	T_Heal( who, skillthree, 0);
	}
};

void() Decay = //remove corpses
{
	if (!self.cnt) self.cnt = 6;
	
	self.think = Decay;
	self.nextthink = time + 0.1;

	if (self.cnt == 6)
		self.alpha = 0.7;
	else if (self.cnt == 5)
		self.alpha = 0.4;
	else if (self.cnt == 4)
		self.alpha = 0.2;
	else if (self.cnt == 3)
		self.alpha = 0.15;
	else if (self.cnt == 2)
		self.alpha = 0.10;
	else if (self.cnt == 1) 
	{
		self.alpha = 0.05;
		self.think = SUB_Remove;
		self.nextthink = time + 0.05;
		return;
	}	
	self.cnt = self.cnt - 1;
};

// (entity who, float bonusduration, float chance, float reset) VoidForceBonus 
// (entity who, float amount, float styletype, float customflag) StyleGive
void (entity killer, float lmonstertype, float wasgibbed, float wasenraged) MonsterDied =
{
	if (self.thinkent)
	{
		self.thinkent.think = SUB_Remove;
		self.thinkent.nextthink = 0.1;
	}
	if (self.entity1)
	{
		self.entity1.think = SUB_Remove;
		self.entity1.nextthink = 0.1;
	}
	if (self.entity2)
	{
		self.entity2.think = SUB_Remove;
		self.entity2.nextthink = 0.1;
	}
	if (self.entity3)
	{
		self.entity3.think = SUB_Remove;
		self.entity3.nextthink = 0.1;
	}
	
	if (killer.monstertype == P_PLAYER)
	{ // player start
		if (wasenraged) StyleGive(killer, 50, 0, 0);
		if (lmonstertype == 1) // SOLDIER
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  5, 5, 0, 0 );
				StyleGive(killer, 10, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  2, 2, 0, 0 );
				StyleGive(killer, 5, 0, 0);
			}
			VoidForceBonus(killer, 2, 1, 0);
			return;
		}
		if (lmonstertype == 2) // DOG
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  5, 5, 5, 0 );
				StyleGive(killer, 25, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  5, 2, 0, 0 );
				StyleGive(killer, 10, 0, 0);
			}
			VoidForceBonus(killer, 2, 3, 0);
			return;
		}
		if (lmonstertype == 3) // ENFORCER
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  5, 5, 5, 0 );
				StyleGive(killer, 25, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  5, 2, 0, 0 );
				StyleGive(killer, 10, 0, 0);
			}
			VoidForceBonus(killer, 2, 3, 0);
			return;
		}
		if (lmonstertype == 4) // KNIGHT
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  5, 5, 5, 0 );
				StyleGive(killer, 25, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  5, 2, 2, 0 );
				StyleGive(killer, 10, 0, 0);
			}
			VoidForceBonus(killer, 2, 3, 0);
			return;
		}
		if (lmonstertype == 5) // SCRAG
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  10, 5, 5, 0 );
				StyleGive(killer, 25, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  5, 2, 2, 0 );
				StyleGive(killer, 10, 0, 0);
			}
			VoidForceBonus(killer, 2, 5, 0);
			return;
		}
		if (lmonstertype == 6) // OGRE
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  10, 5, 10, 5 );
				StyleGive(killer, 50, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  10, 5, 5, 0 );
				StyleGive(killer, 25, 0, 0);
			}
			VoidForceBonus(killer, 4, 10, 0);
			return;
		}
		if (lmonstertype == 7) // FIEND
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  20, 10, 10, 10 );
				StyleGive(killer, 100, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  10, 5, 5, 5 );
				StyleGive(killer, 75, 0, 0);
			}
			VoidForceBonus(killer, 4, 15, 0);
			return;
		}
		if (lmonstertype == 8) // HELLKNIGHT
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  25, 10, 10, 5 );
				StyleGive(killer, 75, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  10, 5, 2, 2 );
				StyleGive(killer, 50, 0, 0);
			}
			VoidForceBonus(killer, 4, 10, 0);
			return;
		}
		if (lmonstertype == 9) // SHALRATH
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  50, 30, 20, 10 );
				StyleGive(killer, 200, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  40, 20, 10, 0 );
				StyleGive(killer, 100, 0, 0);
			}
			if (!(VoidForceBonus(killer, 9, 10, 2))) 
				  VoidForceBonus(killer, 4, 80, 0);
			return;
		}
		if (lmonstertype == 10) // SHAMBLER
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  100, 50, 25, 25 );
				StyleGive(killer, 250, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  75, 50, 25, 15 ); 
				StyleGive(killer, 150, 0, 0);
			}
			if (!(VoidForceBonus(killer, 9, 10, 2))) 
				  VoidForceBonus(killer, 6, 100, 2);
			return;
		}
		if (lmonstertype == 11) // SPAWN
		{
			KillHeal(killer, 0,  10, 0, 0, 0 );
			StyleGive(killer, 25, 0, 0);
			VoidForceBonus(killer, 2, 5, 0);
			return;
		}
		if (lmonstertype == 12) // ROTFISH
		{
			if (wasgibbed)
			{
				KillHeal(killer, 0,  5, 0, 0, 0 );
				StyleGive(killer, 10, 0, 0);
			}
			else
			{
				KillHeal(killer, 0,  2, 0, 0, 0 );
				StyleGive(killer, 5, 0, 0);
			}
			VoidForceBonus(killer, 2, 5, 0);
			return;
		}
		if (lmonstertype == 13) // ZOMBIE
		{
			KillHeal(killer, 5,  0, 0, 0, 0 );
			StyleGive(killer, 10, 0, 0);
			VoidForceBonus(killer, 2, 5, 0);
			return;
		}
	} // player end
};

/*float (entity who) RemoveOldNumbers =
{
	local entity removeit;
	do
	{
		removeit = find (world, classname, "damagesprite");
		if (!removeit)
			return 0;
		if 
		remove (removeit);
	} while ( 1 );
};*/
void () removeDamageNumbers =
{
	self.owner.damagesprite = world;
	//dprint2(self.owner.classname, "\n");
	SUB_Remove();
};

void (entity who, vector drawpoint, float drawnumber, float redraw) drawDamageNumbers =
{
	local float frametodraw;
	local entity dmgsprite;
	//if (!(who.damagesprite.classname == "damagesprite"))
	//	who.damagesprite = world;
		
	if (redraw == 1 && who.damagesprite )
	{
		//dprint5("damagesprite is - ", who.damagesprite.classname, " owner is - ", who.classname, "\n");
		remove (who.damagesprite);
	}
	
	if (redraw == 1 && drawnumber < 1) drawnumber = -1;
	if (!(redraw) && !(drawnumber)) drawnumber = 0;
	if (drawnumber > 1000) drawnumber = 1001;
	
	local vector offsetvec;
	offsetvec_x = crandom()*150;
	//offsetvec_y = crandom()*150;
	if (redraw == 2) 
		offsetvec_z -= random()*150;
	else offsetvec_z = random()*150;
	
	dmgsprite = spawn ();
	dmgsprite.owner = who;
	dmgsprite.movetype = MOVETYPE_FLYMISSILE;
	dmgsprite.solid = SOLID_NOT;
	dmgsprite.angles = '0 0 0';
	if (redraw == 2)
		dmgsprite.classname = "armorbreaksprite";
	else dmgsprite.classname = "damagesprite";
	dmgsprite.think = removeDamageNumbers;
	dmgsprite.nextthink = time + 0.75;
	dmgsprite.alpha = 0.5;

	if (redraw != 2)
		who.damagesprite = dmgsprite;

	if (drawnumber == -1) // death
	{
		frametodraw = 0;
		setmodel (dmgsprite, "progs/icons.spr");
	}
	else if (!(drawnumber) && redraw == 2) // armor
	{
		frametodraw = 1;
		setmodel (dmgsprite, "progs/icons.spr");
	}
	else if (drawnumber < 251) 
	{
		frametodraw = drawnumber;
		setmodel (dmgsprite, "progs/hit0_250.spr");
	}
	else if (drawnumber < 301)
	{		
		frametodraw = drawnumber - 251;
		setmodel (dmgsprite, "progs/hit251_300.spr");
	}
	else
	{
		if ( drawnumber == 1001) frametodraw = 70;
		else
		{
			drawnumber *= 0.1;
			drawnumber = ceil(drawnumber);
			frametodraw = drawnumber - 31;
		}
		setmodel (dmgsprite, "progs/hit310_1000.spr");
	}
	
	setsize (dmgsprite, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (dmgsprite, drawpoint + '0 0 48');
	dmgsprite.frame = frametodraw;
	dmgsprite.velocity = offsetvec;	
};


//-------------end