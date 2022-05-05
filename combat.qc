
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;
float (entity e, float healamount, float ignore) T_Heal; // health function
void() monster_death_use;
void (entity kbsource, entity kbtarget, float kbforce, float kbheight, float specialflag) Knockback;
void(entity victim, entity inflictor, entity attacker, float damage, float damage_penetr, float alwaysgib, float customflag) T_Damage;
void(entity victim, entity inflictor, entity attacker, entity ignore, float strength, float upstrength, float customflag) T_Push;
//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity victim, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (victim.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (victim.absmin + victim.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == victim)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, victim.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, victim.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, victim.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, victim.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, victim.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/
void(entity victim, entity attacker) Killed =
{
	local entity oself;

	oself = self;
	self = victim;
	
	if (self.health < -99)
		self.health = -99;		// don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = attacker;

// bump the monster counter
	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}

	ClientObituary(self, attacker);
	
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

	monster_death_use();
	self.th_die ();
	
	self = oself;
};


/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore, float radius, float epicenter) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;
	local 	float	distancetotarget, distoutepicenter,fall,fallfraction;

	head = findradius(inflictor.origin, radius);
	
	while (head)
	{
		if ((head != ignore) && (head != attacker))
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				distancetotarget = vlen (inflictor.origin - org);
				if ( distancetotarget <= epicenter ) points = damage;
				else
				{
					fall = radius - epicenter;
					distoutepicenter = distancetotarget - epicenter;
					fallfraction = 1 - ( distoutepicenter / fall);
					if (fallfraction < 0) 
						fallfraction = 0; // fixed that stupid bug that heals monster for 1000 hp
					points = damage * fallfraction;
				}
				
				if (CanDamage (head, inflictor))
				{	// shambler takes half damage from all explosions
					if (head.monstertype == MT_SHAMBLER)						
						T_Damage (head, inflictor, attacker, points*0.5, 0, 0, 256);
					else 
					{
						if (head.monstertype == MT_ZOMBIE && attacker.monstertype == P_PLAYER)
						{
							if (points < 100 ) points = 100;
							T_Damage (head, inflictor, attacker, points, 0, 1, 256);
						}
						else T_Damage (head, inflictor, attacker, points, 0, 0, 256);
					}
				
				}
				
			}
		}
		head = head.chain;
	}
};

/*
============
T_RadiusDamage for selfdamage, so keep grenade boosts 
============
*/
void(entity inflictor, entity attacker, float damage, float radius, float epicenter) T_RadiusDamageSelf =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;
	local 	float	distancetotarget, distoutepicenter,fall,fallfraction;

	head = findradius(inflictor.origin, radius);
	
	while (head)
	{
		if (head == attacker)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				distancetotarget = vlen (inflictor.origin - org);
				if ( distancetotarget <= epicenter ) points = damage;
				else
				{
					fall = radius - epicenter;
					distoutepicenter = distancetotarget - epicenter;
					fallfraction = 1 - ( distoutepicenter / fall);
					if (fallfraction < 0) 
						fallfraction = 0;
					points = damage * fallfraction;
				}
				
				if (CanDamage (head, inflictor)) 
				{
					if (attacker.void_time > time)
						T_Damage (head, inflictor, attacker, points*0.2, 0, 0, 0);
					else T_Damage (head, inflictor, attacker, points, 0, 0, 0);
					if (attacker.quad_time > time)
						T_Push (head, inflictor, attacker, world, points*20, 0, 0);
					else T_Push (head, inflictor, attacker, world, points*5, 0, 0);
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_BeamDamage
============
*/
void(entity attacker, float damage) T_BeamDamage =
{
	local	float 	points;
	local	entity	head;
	
	head = findradius(attacker.origin, damage+40);
	
	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
				{
					if (head.monstertype == MT_SHAMBLER)						
						T_Damage (head, attacker, attacker, points*0.5, 0, 0, 0);
					else
						T_Damage (head, attacker, attacker, points, 0, 0, 0);
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
TO DO:
Damage sources(sourcetype):
player
  0 : no special effect
  1 : axe
  2 : shotgun
  3 : super shotgun
  4 : nailgun
  5 : super nailgun
  6 : grenade direct
 16 : grenade radius damage
  7 : rocket direct
 17 : rocket radius damage
  8 : railgun direct
 18 : railgun radius damage
etc

monsters
  0 : no special effect
  1 : soldier
 11 : soldier reserved
  2 : dog
 12 : dog reserved
  3 : enforcer
 13 : enforcer reserved
  4 : knight
 14 : knight reserved
  5 : scrag
 15 : scrag2
  6 : ogre nade direct
 16 : ogre nade radius damage
 26 : ogre melee
  7 : hknight projectile
 17 : hknight melee
 27 : hknight reserved
  8 : fiend leap
 18 : fiend melee
  9 : shalrath ball direct
 19 : shalrath ball radius
101 : shambler lightning
111 : shambler melee
102 : spawn explosion
112 : spawn leap touch
etc
*/
// T_PDPlayer Pre-Damage function

// T_PDMonster Pre-Damage function//float sourcetype, float specialflag

void(entity victim, entity inflictor, entity attacker, entity ignore, float strength, float upstrength, float customflag) T_Push =
{
	local	vector	dir;
	
	if ( victim.movetype == MOVETYPE_WALK )
	{
		if (victim.tier == 3)
			strength *= 0.5;
		dir = victim.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);

		victim.velocity = victim.velocity + dir * strength;
		victim.velocity_z = victim.velocity_z + upstrength;
		if (victim.flags & FL_ONGROUND)
			victim.flags = victim.flags - FL_ONGROUND;
	}
	// figure momentum add
	/*
	if ( (inflictor != world) && (victim.movetype == MOVETYPE_WALK) )
	{
		
		dir = victim.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		if ( inflictor.monstertype == MT_OGRE 	|| ( inflictor.owner.monstertype == MT_OGRE && customflag == 6)) 
		{
			// OGRE MELEE, OGRE GRENADE DIRECT HIT
			if (modified_damage > 4) victim.velocity = victim.velocity + dir * 320;
			//victim.velocity_z = victim.velocity_z + 60;
		}
		else if ( inflictor.monstertype == MT_SHAMBLER && customflag == 2 ) 
		{
			// SHAMBLER MELEE WILL PUSH PLAYER BACK
			victim.velocity = victim.velocity + dir * 900;
		}
		else
		{
			if ( attacker == victim )	victim.velocity = victim.velocity + dir*initial_damage*5;
			else victim.velocity = victim.velocity + dir*modified_damage * 8;//dir*modified_damage*8;
		}
		
	}
	*/
};

/*
	CUSTOMFLAGS
	1 - PIERCING ATTACKS THAT WILL IGNOR ARMOR OF TARGET;
	2 - SHAMBLER DOES EXTRA DAMAGE TO OTHER MONSTERS, MELEE ATTACKS WILL PUSH TARGET BACK
	4 - NAILGUN
	8 - SG / SSG
	16 - AXE
	32 - GRENADE
	64 - RAIL
	128 - ROCKET
	256 - Explosion
	512 - PRE RAIL 
*/

void(entity victim, entity inflictor, entity attacker, float damage, float damage_penetr, float alwaysgib, float customflag) T_Damage =
{
	//local	vector	dir;
	local	entity	oldself;
	local	float	save;
	local	float	reduced_damage;
	//local 	float 	healvalue;
	local	float	quadgib;
	local   float   initial_damage;
	local   float   modified_damage;
	local 	float 	platedestroyed;
	local 	float	armorfactor;

	if (!victim.takedamage)
		return;

	initial_damage = damage;
	modified_damage = damage;
// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

// Additional damage for hiting enemies on the fly
	if (!(victim.flags & FL_ONGROUND))
	{
		if (victim.monstertype != MT_SCRAG && victim.monstertype != MT_SHAMBLER)
		{
			if (customflag == 16) // AXE
			{
				//modified_damage += 100;
			}
			else if (customflag == 32) // GRENADE
			{
				if (victim.monstertype == MT_FIEND)
					modified_damage += 20;
				else modified_damage += 100;
			}
			else if (customflag == 64) // RAIL
			{
				modified_damage += 100;
			}
			else if (customflag == 128) // ROCKET
			{
				if (victim.monstertype == MT_FIEND)
					modified_damage += 20;
				else modified_damage += 100;
			}
		}
	}
	
// check for quad damage powerup on the attacker
	if (attacker.quad_time > time)
	{
// round damage numbers if initial damage was more than 75x4=300, so all damage above 300 will match hitnumbers
		if (modified_damage > 75) 
		{
			modified_damage *= 4;
			modified_damage *= 0.1;
			modified_damage = ceil(modified_damage);
			modified_damage *= 10; 
		}
		else modified_damage = modified_damage * 4;
		
		if (damage_penetr > 75) 
		{
			damage_penetr *= 4;
			damage_penetr *= 0.1;
			damage_penetr = ceil(damage_penetr);
			damage_penetr *= 10; 
		}
		else damage_penetr = damage_penetr * 4;
		quadgib = 1;
	}
	
	if (attacker.void_time > time)
		quadgib = 1;
	
//------------------------------------ NOT IMPORTANT -----------------------------------------
	// add to the damage total for clients, which will be sent as a single
	// message at the end of the frame
	// FIXME: remove after combining shotgun blasts?
	if (victim.flags & FL_CLIENT)
	{
		victim.dmg_take = victim.dmg_take + reduced_damage;
		victim.dmg_save = victim.dmg_save + save;
		victim.dmg_inflictor = inflictor;
	}
	
// separated to T_Push

	if (victim.pentagram_time >= time)
	{
		if (self.pentagram_sound < time)
		{
			sound (victim, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.pentagram_sound = time + 2;
		}
		return;
	}

// team play damage avoidance
//	if ( (teamplay == 1) && (victim.team > 0)&&(victim.team == attacker.team) )
	if ( (teamplay == 1) && (victim.team > 0) && (victim.team == attacker.team)
	&& (victim != attacker) 			
	&& (attacker.monstertype == P_PLAYER)
	&& (inflictor.classname != "door") )	// because squishing a teammate is still possible
		return;
//------------------------------------ NOT IMPORTANT -----------------------------------------

//--------------------------------------------------------------		
// 						ARMOR PLATES
//--------------------------------------------------------------

	modified_damage = ceil(modified_damage);
	StripPlates(victim);
	
	if (victim.armorplates > 0 && (customflag != 256 && customflag != 512)) // ignore armor flag
	{
		if (modified_damage > 29 || customflag == 16)
		{
			if (victim.monstertype == P_PLAYER)
				sound (victim, CHAN_AUTO, "items/abreak.wav", 1, ATTN_NORM); // moved to hitsounds// still need it for player
			
				victim.armorplates -=1;
				platedestroyed = 1;

			if (victim.monstertype == P_PLAYER)	
				armorfactor = 50;
			else
			{
				if (customflag == 4) //nailgun
					armorfactor = 0;
				else if (customflag == 8) // sg/ssg
				{
					armorfactor = 100;
					if (victim.monstertype == MT_SHAMBLER)
						armorfactor += victim.mut_ssgrefire * 25;
				}
				else if (customflag == 16) armorfactor = 0; //knife
				else if (customflag == 32 ) //gl direct //|| customflag == 128
				{
					armorfactor = 50;
					if (victim.armorplates > 0)
					{
						victim.armorplates -= 1;
						platedestroyed = 2;
					}
				}
				else if (customflag == 64) // rail
				{
					armorfactor = 0;
					if (victim.armorplates > 0)
					{
						victim.armorplates -= 1;
						platedestroyed = 2;
					}
				}
				else armorfactor = 50;
			}
			modified_damage -= armorfactor;
			
			if (modified_damage < 0) modified_damage = 0;
		}
		if (victim.armorplates < 1) victim.items = victim.items - (victim.items & IT_ARMOR3) ;
	}
//--------------------------------------------------------------		
// damage reduction based on skill level + autoheal delay
//--------------------------------------------------------------
	if ((victim.monstertype == P_PLAYER) && (victim != attacker))
	{
		if (skill == 0)	
		{
			modified_damage = modified_damage * 0.6;
			victim.healdelay_time = time + 2;
		}
		else if (skill == 1) 
		{
			modified_damage = modified_damage * 0.8;
			victim.healdelay_time = time + 3;
		}
		else if (skill == 2)
		{
			//modified_damage = modified_damage * 1.0;
			victim.healdelay_time = time + 2;
		}
		else if (skill == 3) victim.healdelay_time = time + 3;
	}
	else if (victim.monstertype == P_PLAYER) //rocketjumping
		victim.healdelay_time = time + 1;
	
	if ( ((alwaysgib == 1) || (quadgib == 1)) && (((victim.health + victim.armorvalue) - modified_damage - damage_penetr) <= 0)) 
	{
		victim.gib = 1;
	}

//--------------------------------------------------------------		
// do the damage
//--------------------------------------------------------------
	
	modified_damage = ceil(modified_damage);
//-----------------------ARMOR-----------------------
	if (victim.armorvalue > 0) 
		{
			save = modified_damage;
			
			if	(save >= victim.armorvalue)
				save = victim.armorvalue;

			victim.armorvalue = victim.armorvalue - save;
			
			reduced_damage = modified_damage - save;	
		}
	else reduced_damage = modified_damage;
	PutPlates(victim);
//-----------------------ARMOR-END-------------------
	
	reduced_damage += damage_penetr; // DAMAGE THAT PENETRATES ARMOR
									 // only monsters are doing penetrative damage, so there is no reason to round it, etc
	reduced_damage = ceil(reduced_damage);
	
	if ( attacker.hitsounds && victim != attacker && victim.tier)
	{
		if (platedestroyed)
		{
			if (victim.armorplates == 0)
				sound (attacker, CHAN_AUTO, "items/abreak_mon_last.wav", 1, ATTN_NONE);
			else sound (attacker, CHAN_BODY, "items/abreak_mon.wav", 1, ATTN_NONE);
			if (platedestroyed == 2) 
				sound (attacker, CHAN_AUTO, "items/abreak_mon.wav", 1, ATTN_NONE);
		}
		else if (reduced_damage > 39)
		{
			if (reduced_damage > 350) sound (attacker, CHAN_BODY, "weapons/hitsound75.wav", 1.0, ATTN_NONE);
			else if (reduced_damage > 99) sound (attacker, CHAN_BODY, "weapons/hitsound90.wav", 1.0, ATTN_NONE);
			else if (reduced_damage > 60) sound (attacker, CHAN_BODY, "weapons/hitsound125.wav", 1.0, ATTN_NONE);
			else sound (attacker, CHAN_BODY, "weapons/hitsound.wav", 1.0, ATTN_NONE);		
		}
	}
	if (reduced_damage < 0)
	{
		dprint("DEBUG: DAMAGE LESS THAN 0!!! \n");
		reduced_damage = 0;
	}
	if (victim.health)
	{
		if (victim.flags & FL_GODMODE)
		{
			local float godcheck;
			godcheck = victim.health - reduced_damage;
			if ( godcheck <= 0) victim.health = 1;
			else victim.health = victim.health - reduced_damage;
		}
		else victim.health -= reduced_damage;
	}
	
	/*if (attacker.monstertype == P_PLAYER)
	{
		dprint6("Damage, modified:",ftos(modified_damage), " (mod+pen)reduced: ", ftos(reduced_damage), " penetr: ", ftos(damage_penetr));
		dprint3(" initial: ", ftos(damage), " \n");
	}*/
// 	--------------------   DAMAGE SPRITES START
	if (attacker.displaydamage)
	{	
		if (attacker.monstertype == P_PLAYER && attacker != victim && victim.tier)
		{
			local float targethealth;
			if (attacker.displaydamage == 1)
			{
				targethealth = victim.health;
				drawDamageNumbers(victim, victim.origin, targethealth, 1);
			}
			else 
			{
				reduced_damage = ceil (reduced_damage);
				drawDamageNumbers(victim, victim.origin, reduced_damage, 0);
			}

			if (attacker.displaydamage && platedestroyed)
			{
				drawDamageNumbers(victim, victim.origin, 0, 2); //plate destroyed
				if (platedestroyed == 2)
					drawDamageNumbers(victim, victim.origin, 0, 2); //plate destroyed
			}
		}
	}
// 	--------------------   DAMAGE SPRITES END
	
// style combo handler
	if (victim != attacker) 
	{
		if (victim.monstertype == P_PLAYER)
			victim.style_dmgtaken += reduced_damage;
		else if (attacker.monstertype == P_PLAYER)
			attacker.style_dmgdone += reduced_damage;
	}
	
	if (victim.health <= 0)
	{
		Killed (victim, attacker);
		return;
	}

// react to the damage
	oldself = self;
	self = victim;

	if ( (self.flags & FL_MONSTER) && attacker != world )
	{
		// get mad unless of the same class (except for soldiers) (actually never get mad, unless it's a player)
		if ((self != attacker) && (attacker != self.enemy) && (attacker.monstertype == P_PLAYER) && !(attacker.flags & FL_NOTARGET) )
		{
			if ( (self.monstertype != attacker.monstertype) || (self.monstertype == MT_SOLDIER ) )
			{
				if (self.enemy.monstertype == P_PLAYER) self.oldenemy = self.enemy;
				self.enemy = attacker;
				FoundTarget ();
			}
		}
	}
	
	// so, we do pain frames only on skill 0 and 1, and when player uses blade with ring of invisibility
	if (self.th_pain)
	{
		
		if (skill < 2 || self.monstertype == P_PLAYER)
			self.dopain = 1;
		else if ((customflag == 16 && attacker.ring_time > time ) || customflag == 512)
		{
			self.dopain = 1;
			self.pain_time = 0;
		}
		
		self.th_pain (attacker, reduced_damage);
	}

	self = oldself;
};