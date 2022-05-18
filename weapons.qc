float(entity e, float healamount, float ignore) T_Heal; // health function
void(entity victim, entity inflictor, entity attacker, float damage, float damage_penetr, float alwaysgib, float customflag) T_Damage;
void(entity victim, entity inflictor, entity attacker, entity ignore, float strength, float upstrength, float customflag) T_Push;
void(entity inflictor, entity attacker, float damage, entity ignore, float radius, float epicenter) T_RadiusDamage;
void(entity inflictor, entity attacker, float damage, float radius, float epicenter) T_RadiusDamageSelf;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;
void() player_run;

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/hitsound.wav");	
	precache_sound ("weapons/hitsound75.wav");	
	precache_sound ("weapons/hitsound90.wav");	
	precache_sound ("weapons/hitsound125.wav");	
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
//	precache_sound ("weapons/spike1.wav");	// super spikes
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
};

//===================================[	KNOCKBACK	]========================================

void (entity source, entity victim, float force, float forceup, float specialflag) Knockback =
{
	local float savez;
	
	if (victim.tier == 3) 
	{
		force *= 0.5;
	}
	
	// legacy of Lunaran, code of quad damage axe knockback from copper mod used here as base
	if ((victim.tier == 2 ||victim.tier == 3) &&  victim.health > 0 )
	{
		local vector toss;
		
		if (source.monstertype == P_PLAYER)
		{
			toss = v_forward;
		}
		else 
		{
			if (specialflag == 1) 
				toss = (victim.origin - source.origin);
			else 
				toss = (victim.origin - source.owner.origin);
		}

		if (specialflag == 1)
		{
			toss = normalize(toss) * force;
		}
		else
		{
			toss_z = 0;
			toss = normalize(toss) * force;
			toss_z = forceup;
		}
		
		if (victim.flags & FL_ONGROUND)
			victim.origin_z = victim.origin_z + 1;

		savez = victim.velocity_z;
		victim.velocity = toss;
		victim.velocity_z += savez;
		victim.flags = not(victim.flags, FL_ONGROUND);
	}
};

vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile;//, mpuff;
	//local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
	// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
	particle (org, vel*0.1, 73, damage*2);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};


/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;
float	multi_pelletcounter;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
	multi_pelletcounter = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;

	T_Damage (multi_ent, self, self, multi_damage, 0, 0, 8);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;

	if (multi_ent.health < multi_damage)
		ApplyMultiDamage ();
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir, float typeofshot) TraceAttack =
{
	local	vector	vel, org;
	local float calculate_falloff, calculated_damage;
	local float execution_health;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2 * trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;
	
	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*0.2, damage);
		calculated_damage = damage;
		//  **------**------**------**------**------**------**------**------**
		if ( typeofshot == 1 ) // shotgun damage calculations
		{
			T_Heal(self, 1, 0);

			if (( trace_fraction > 0.12 ) && ( trace_fraction < 0.2 )) // > 240 and < 400
			{
				calculate_falloff = (trace_fraction - 0.12) * 12.5;// 12.5 * 0.08 = 1.0 (100%)
				
				if (self.void_time  > time)	
					calculated_damage = damage + (damage * 3 * calculate_falloff); // bonus 
				else 
					calculated_damage = damage + (damage * calculate_falloff); // smoothly increase damage up to double damage
			}
			else if ((trace_fraction >= 0.2) && (trace_fraction < 0.6)) // >= 400 and < 1200
			{
				// double damage from 400 to 900; 
				if (self.void_time  > time)	
					calculated_damage = damage * 4;
				else 
					calculated_damage = damage * 2;

				if (trace_fraction > 0.45) // > 900 and < 1200
				{
					calculate_falloff = (trace_fraction - 0.475) * 8; // 8* 0.125 = 1.0 (100%)
					
					if (self.void_time  > time)	
						calculated_damage = (damage * 4) - (damage * 3 * calculate_falloff);// bonus
					else 
						calculated_damage = (damage * 2) - (damage * calculate_falloff); // return to normal on long range
				}
			}
		}
		//  **------**------**------**------**------**------**------**------**
		if ( typeofshot == 2 ) // supershotgun inner circle
		{
			if ( ( trace_fraction > 0.36 ) && ( trace_fraction < 0.52 ) ) // 720 - 1040
			{
				calculate_falloff = (trace_fraction - 0.36) * 3.125; // 5 * 0.16 = 0.8 (80%) //6.25
				calculated_damage = damage - (damage * calculate_falloff);
			}
			else if (trace_fraction >= 0.52) 
				calculated_damage = damage * 0.5; //0.2 // 1040
		}
		//  **------**------**------**------**------**------**------**------**
		if ( typeofshot == 3 ) // supershotgun outer circle
		{
			if (( trace_fraction > 0.064 ) && ( trace_fraction < 0.256 )) 
				calculated_damage = damage * 0.75; // .5
			if ( trace_fraction >= 0.256) 
				calculated_damage = damage * 0.5; // .25
		}
		//  **------**------**------**------**------**------**------**------**
		ceil(calculated_damage);
		
	//Execution damage, we make more damage when target is below 30% of it's max hp, works for ssg only
		if (typeofshot == 2 || typeofshot == 3) 
		{
			execution_health = trace_ent.max_health * 0.3;
			if (trace_ent.health < execution_health)
				calculated_damage *= 1.5;	
		}
		AddMultiDamage (trace_ent, calculated_damage );
		
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, float damage, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	//makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.84;
	
	ClearMultiDamage ();
	
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (damage, direction, 0);

		shotcount = shotcount - 1;
	}

	ApplyMultiDamage ();
};

/*
================================================================================================
																		FireMirror
================================================================================================
*/
void( float symmetry, float damage, float fdistance, float Xfactor, float Yfactor, vector src, vector dir, float typeofshot ) fireMirror =
{
	local	vector direction;
	
	if ( symmetry == 0)
	{
		// do straight shot
		direction = dir + Xfactor * v_right + Yfactor * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		return;
	}
	else if ( symmetry == 1)
	{	
		// same as firs one, but add inversions for each coordinate x/-x y/-y
		direction = dir + Xfactor * v_right + Yfactor * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		
		direction = dir + (-Xfactor) * v_right + (-Yfactor) * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		
		direction = dir + (-Xfactor) * v_right + Yfactor * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		
		direction = dir + Xfactor * v_right + (-Yfactor) * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		return;
	}
	else if ( symmetry == 2) 
	{
		// Trace on original coordinates, then do full inversion
		direction = dir + Xfactor * v_right + Yfactor * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		
		direction = dir + (-Xfactor) * v_right + (-Yfactor) * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		return;
	}
	else if ( symmetry == 3) 
	{
		// Trace on original coordinates, then do inversion of X
		direction = dir + Xfactor * v_right + Yfactor * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		
		direction = dir + (-Xfactor) * v_right + Yfactor * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		return;
	}
	else if ( symmetry == 4) 
	{
		// Trace on original coordinates, then do inversion of Y
		direction = dir + Xfactor * v_right + Yfactor * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		
		direction = dir + Xfactor * v_right + (-Yfactor) * v_up;
		traceline (src, src + direction * fdistance, FALSE, self);
		if (trace_fraction != 1.0)	
			TraceAttack (damage, direction, typeofshot);
		return;
	}
};

/*
================================================================================================
																		AXE
================================================================================================
*/

void(float axedamage) W_FireAxe =
{
	// we run out of stabs or hit someone, cancel
	if (self.axe_stabs < 1) 
		return; 
	
	local	vector	source;
	local	vector	org;

	makevectors (self.v_angle); // We need v_forward here
		
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*96, FALSE, self);
	if (trace_fraction == 1.0)
	{
		traceline (source, source + v_forward*96 + v_right * 10, FALSE, self);
		if (trace_fraction == 1.0)
		{
			traceline (source, source + v_forward*96 + v_right * -10, FALSE, self);
			if (trace_fraction == 1.0) 
				return;
		}
	}
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		self.ssgrefirebonus = 2; // tripple ssg fire triggered
		
		if ((trace_ent.tier == 2 || trace_ent.tier == 3) || self.void_time < time)
			self.axe_stabs = 0;
		
		local float forwardvelocity;
		local vector tempvelocity;
		local float newdamage;
			
		trace_ent.axhitme = 1;
		SpawnBlood (org, '0 0 0', 10);
		
		//forwardvelocity = CrossProduct(self.velocity, v_right);	
		tempvelocity = self.velocity;
		tempvelocity_z *= 0.5;
		forwardvelocity = vlen(tempvelocity);
		if (trace_ent.monstertype == MT_SHAMBLER)
			forwardvelocity *= 0.6;
		
		newdamage = (axedamage * forwardvelocity) * 0.01;
		newdamage = newdamage * 0.1;
		newdamage = ceil(newdamage);
		newdamage = newdamage * 10;
		
		//if (trace_ent.monstertype == MT_SHAMBLER && newdamage > 100)
		//	newdamage = 100;
		//else 
		if (newdamage > 245 ) 
			newdamage = 245;
		if (newdamage < axedamage) 
			newdamage = axedamage;

		Knockback(self, trace_ent, 200 + forwardvelocity*0.5, 100, 0);
		if (trace_ent.monstertype == MT_SHAMBLER)
			trace_ent.mut_stabs += 1; // damn, those stabs makes him angy af
		if (self.ring_time > time)
			newdamage += 100;
		T_Damage(trace_ent, self, self, 0, newdamage, 1, 16);

		
		if (trace_ent.health > 0) 
			self.axe_stabs = 0; // tier 1 monster stays alive, cancel
		if (trace_ent.health < 0 && self.void_time > time)
			self.axe_stabs = 1; // ok, always let one target die even if it's tier2-3
		//if (self.armorplates == 0) GivePlates(self,1); // balancing
	}
	/*else
	{	// hit wall
		if (axedamage > 20)
		{
			sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_GUNSHOT);
			WriteCoord (MSG_BROADCAST, org_x);
			WriteCoord (MSG_BROADCAST, org_y);
			WriteCoord (MSG_BROADCAST, org_z);
		}
	}*/
};

/*
================================================================================================
																		Shotgun
================================================================================================
*/
void( vector dir ) FireBulletsSG =
{
	local	vector	src;
	local float combodamage;
	local float i;

	src = self.origin + v_forward * 10;
	src_z = self.absmin_z + self.size_z * 0.84;

	ClearMultiDamage ();
	
	combodamage = 6;
	
	if (self.items & IT_RIFLE)
		combodamage = 24;
	
	for (i = 0; i < 4; i++) 
		fireMirror(0, combodamage, 2000, sgx[i], sgy[i], src, dir, 1); // last number is falloff formula
		// First float for fireMirror is: 1 = 4 shots, 2 = 2 shots, 0 = 1 shot
		// type, damage, distance, coordx, coordy ...
	
		if (multi_ent != world && multi_damage > 47) 
		{
			if (!(self.quad_time > time))
			{
				if ( (multi_damage == 48 && !(self.void_time) ) || multi_damage == 96 )
					StyleGive(self, 50, 1, 0);
				
				if (multi_damage == 192)
					StyleGive(self, 100, 1, 0);
			}
		}

	ApplyMultiDamage ();
};

void() W_FireShotgun =
{
	local vector dir;
		
	sound (self ,CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	
	self.punchangle_x = - 2;
	dir = v_forward;	//aim (self, 1000);
	FireBulletsSG ( dir );
};

/*
===================================================================================================
																		SuperShotgun
===================================================================================================
*/
void( vector dir ) FireBulletsSSG =
{
	local	vector	src;
	local float i;
	local entity refire_entity;
	local float swap;
	local vector direction;

	src = self.origin + v_forward * 10;
	src_z = self.absmin_z + self.size_z * 0.84;
	
	swap = 0.28; // x coordinate for two traces that should hit same target in order to trigger refire
	
	//refire check
	for (i = 0; i < 2; i++)
	{
		if (i) 
			swap *= -1;
		
		direction = dir + swap * v_right;
		traceline (src, src + direction * 64, FALSE, self);
		
		if ( trace_fraction == 1.0 ) 
			break; // not hiting anything
		if (!trace_ent.tier) 
			break; // hiting something that is not monster
		if (!i) 
			refire_entity = trace_ent; // saving result of the first trace to compare it with the result of second trace
		
		
		if ( i && trace_ent != refire_entity ) 
			break; // well, we hit two different entities, so it's no no
		else //success
		{
			// we need to care about double refire from blade attack, and not change it accidently
			if (!(self.ssgrefirebonus)) 
				self.ssgrefirebonus = 1; 
				
			if (self.void_time > time) 
				Knockback(self, trace_ent, 400, 100, 0);
			
			// Shambler become more agressive with each successful refire attack on it
			if (trace_ent.monstertype == MT_SHAMBLER) 
				trace_ent.mut_ssgrefire += 1;
		}
	}
	ClearMultiDamage ();
	
	// First float for FireMirror is: 1 = 4 shots, 2 = 2 shots, 0 = 1 shot
	// type, damage, distance, coordx, coordy ...
	if (self.void_time > time)	
	{
		for (i = 0; i < 14; i++) 
			fireMirror(0, 16, vtssgdistance[i], vtssgx[i] * spreadsize, vtssgy[i] * spreadsize, src, dir, vtssgfalloff[i]); //16
	}
	else
	{
		for (i = 0; i < 11; i++)
			fireMirror(0, 16, ssgdistance[i],  ssgx[i] * spreadsize,  ssgy[i] * spreadsize, src, dir, ssgfalloff[i]); //16
	}
	ApplyMultiDamage ();
};

void() W_FireSuperShotgun =
{
	local vector dir;
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = v_forward;//aim (self, 1000);
	FireBulletsSSG ( dir );	
	self.punchangle_x = -4;
};

/*
================================================================================================
																		NG/SNG PROJECTILES 
================================================================================================
*/
//SNG TOUCH
void(float damage, float spiketype) basictouch = 
{
	if (other == self.owner)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	if (other.takedamage)
	{
		spawn_touchblood (damage);
		
		if (spiketype == 1) // normal(weak)
			T_Damage (other, self, self.owner, damage, 0, 0, 4);
		else if (spiketype == 2)	//deviated (strong)
		{
			if (self.owner.void_time > time)
				StyleGive(self.owner, 15, 5, 1);
			
			T_Damage (other, self, self.owner, damage, 0, 0, 0);
		}
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}
	remove(self);
};

void() sng_touch =
{
	basictouch(self.dmg,1);
};

void() sngs_touch =
{
	basictouch(self.dmg,2);
};

/*
void() strongspike_touch =
{
	basictouch(self.dmg,2);
	remove(self);
};

void() snipespike_touch =
{
	basictouch(90,3);
	remove(self);
};
*/
/*
void() homing_think =
{
	if ( self.remove_time > time )
	{	
		self.angles = vectoangles(self.velocity);
		self.think = homing_think;
		self.nextthink = time + 0.1;
	}
	else 
	{
		// set missile duration
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() split_think =
{
	if ( self.remove_time > time )
	{	
		if (self.projtype == 1)
		{
			dprint("1 - ");
			dprint(vtos(self.velocity));
			dprint(" - ");
			dprint(vtos(self.origin));
			dprint("\n");
			makevectors(self.velocity);
			dprint3("fwd - ", vtos(v_forward),"\n");
			dprint3("right - ", vtos(v_right),"\n"); 
			dprint3("up - ", vtos(v_up), "\n");
			//self.velocity = ;
		}
		else if (self.projtype == 2)
		{

			//self.velocity =;
		}
		else if (self.projtype == 3)
		{

			//self.velocity = ;
		}
		self.angles = vectoangles(self.velocity);
		self.touch = strongspike_touch;
		self.think = homing_think;
		self.nextthink = time + 0.01;
	}
	else 
	{
		// set missile duration
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};
*/
void() homing_think =
{
	if ( self.remove_time > time )
	{	
		self.velocity_x = self.velocity_x + (random()*600 - random()*600);
		self.velocity_y = self.velocity_y + (random()*600 - random()*600);
		self.velocity_z = self.velocity_z + (random()*600 - random()*600);
		
		if (self.dmg > 60) 
			self.dmg -= 20;
		
		if (self.dmg < 60) 
			self.dmg = 60;
		
		self.angles = vectoangles(self.velocity);
		self.think = homing_think;
		self.nextthink = time + 0.1;
	}
	else 
	{
		// set missile duration
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() split_think =
{
	if ( self.remove_time > time )
	{	
		self.velocity = self.velocity * 0.5;
		self.angles = vectoangles(self.velocity);
		self.touch = sngs_touch;
		self.dmg = 100;
		self.skin = 1;
		self.think = homing_think;
		self.nextthink = time + 0.05;
	}
	else 
	{
		// set missile duration
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void (vector dir, float offsetX, float offsetY, float nvelocity, float splittime, float ntype) spawnnail =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.remove_time = time + 6;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.angles = vectoangles(dir);
	
	if (self.void_time > time) 
		newmis.dmg = 60;
	else	
		newmis.dmg = 30;
	
	newmis.touch = sng_touch;
	newmis.projtype = ntype;
	newmis.classname = "spike";
	newmis.think = split_think;
	newmis.nextthink = time + splittime;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, self.origin + '0 0 16' + v_right*offsetX + v_forward*16 + v_up*offsetY );
	newmis.velocity = dir * nvelocity;	
};

//---------------------------------------------------------------------------------------------------------------------------------
// NG TOUCH
void() NailTouch =
{
	if (other == self.owner)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage  == DAMAGE_AIM)
	{
		spawn_touchblood (self.projectiledamage);
		T_Damage (other, self, self.owner, self.projectiledamage, 0, 0, 4);
		if (self.projectiledamage > 60) 
		{
			Knockback(self.owner, other, 200, 50, 0);
			StyleGive(self.owner, 10, 0, 0);
		}
		remove(self);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
		
		self.angles = vectoangles(self.velocity);
		
		if (self.velocity == '0 0 0') 
			remove(self);
		
		self.projectiledamage -=10;
		
		if (self.projectiledamage < 10) 
			remove(self);
	}
	
	if (other.takedamage == DAMAGE_YES) //buttons etc
		T_Damage(other, self, self.owner, 40, 0, 0, 0);
};

void() deviate_think =
{
	if ( self.remove_time > time )
	{	
		self.angles = vectoangles(self.velocity);
		self.think = deviate_think;
		self.nextthink = time + 0.01;
	}
	else 
	{
		// set missile duration
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

//=====================================================================================
//									NAILGUN
//=====================================================================================


void() W_FireNailgun =
{
	//local vector dir;
	local float cyclevar;

	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	self.show_hostile = time + 1;
	
	makevectors(self.v_angle);
	cyclevar = 0;
	
	local float spreadfactor;
	local float damagefactor;
	local float prjfvel;
	
	if (self.ssgrefirebonus)
	{
		spreadfactor = -0.3;
		self.ssgrefirebonus--;
	}
	else
		spreadfactor = self.nailgun_time - time;
	
	if (spreadfactor < -0.3)
		spreadfactor = -0.3;
	
	damagefactor = 10 + (60 * (0.7 - spreadfactor));
	
	if (damagefactor > 60) 
		damagefactor = 60;
	
	if (self.void_time > time) 
		damagefactor *= 1.5;
	
	while (cyclevar < 2)
	{
		newmis = spawn ();
		newmis.owner = self;
		newmis.remove_time = time + 4;
		newmis.movetype = MOVETYPE_BOUNCE;
		newmis.solid = SOLID_BBOX;
		newmis.angles = vectoangles(v_forward);
		newmis.touch = NailTouch;
		newmis.classname = "spike";
		newmis.think = deviate_think;
		newmis.nextthink = time + 0.1;
		newmis.projectiledamage = damagefactor;
		
		setmodel (newmis, "progs/s_spike.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
		setorigin (newmis, self.origin + v_right*RLSPREADX[cyclevar]*0.03 );
		
		if (self.void_time > time) 
			prjfvel = 1950;
		else if (spreadfactor > 0)
			prjfvel = 1200;
		else 
			prjfvel = 1200 + (-spreadfactor * 2500); 
		
		if (self.v_angle_x)
			newmis.velocity = v_forward*prjfvel + v_up * 200;// + v_right * RLSPREADX[cyclevar] * spreadfactor;
		else
		{
			newmis.velocity = v_forward;//aim(self, 1000);
			newmis.velocity = newmis.velocity * prjfvel;
			newmis.velocity_z = 200;
		}
		
		cyclevar++;
	}
	
	self.punchangle_x = -2;
};

//=====================================================================================
//									SUPER NAILGUN
//=====================================================================================

void(float firetype) W_FireSuperNailgun =
{
	local	vector dir;
	//local	vector src;
	
	if (!(self.vmflags & VMF_PLAYER_INSEQUENCE) && self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}
		
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	
	makevectors(self.v_angle);	
	dir = v_forward;//aim (self, 100000);

	//makevectors(self.v_angle);
	//if (!firetype) spawnnail( v_forward, 0.0, 1800, 1 );
	//else spawnnail( v_forward, 0.0, 1200, 0.17 );
	if (self.currentammo > 2)
	{
		spawnnail( v_forward, 4, 2, 1950, 0.10, 2 );
		spawnnail( v_forward, -4, 2, 1950, 0.10, 1 );
		spawnnail( v_forward, 0.0, -4, 1950, 0.10, 3 );
		self.currentammo = self.ammo_nails = self.ammo_nails - 3;
	}
	else if (self.currentammo > 1)
	{
		spawnnail( v_forward, 4, 2, 1950, 0.10, 2 );
		spawnnail( v_forward, -4, 2, 1950, 0.10, 1 );
		self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	}
	else
	{
		spawnnail( v_forward, 0.0, -4, 1950, 0.10, 0 );
		self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	}
	
	self.punchangle_x = -3;
};

/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void()	s_cexplode1		=	[0,		s_cexplode2] {Think(self, 0.05);};
void()	s_cexplode2		=	[1,		s_cexplode3] {Think(self, 0.05);};
void()	s_cexplode3		=	[2,		s_cexplode4] {Think(self, 0.05);};
void()	s_cexplode4		=	[3,		s_cexplode5] {Think(self, 0.05);};
void()	s_cexplode5		=	[4,		s_cexplode6] {Think(self, 0.05);};
void()	s_cexplode6		=	[5,		s_cexplode7] {Think(self, 0.05);};
void()	s_cexplode7		=	[6,		s_cexplode8] {Think(self, 0.05);};
void()	s_cexplode8		=	[7,		s_cexplode9] {Think(self, 0.05);};
void()	s_cexplode9		=	[8,		s_cexplode10] {Think(self, 0.05);};
void()	s_cexplode10	=	[9,		s_cexplode11] {Think(self, 0.05);};
void()	s_cexplode11	=	[10,	s_cexplode12] {Think(self, 0.05);};
void()	s_cexplode12	=	[11,	s_cexplode13] {Think(self, 0.05);};
void()	s_cexplode13	=	[12,		SUB_Remove] {};

void(float exptype) BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	
	if (exptype) 
		setmodel (self, "progs/combo_expl.spr");
	else 
		setmodel (self, "progs/s_explod.spr");
	
	self.solid = SOLID_NOT;
	
	if (exptype) 
		s_cexplode1 ();
	else 
		s_explode1 ();
};

void() GrenadeCombo =
{
	self.grenadestate = 0;
	
	T_RadiusDamage (self, self.owner, 250, world, 320, 160);
	T_RadiusDamageSelf(self, self.owner, 80, 200, 64);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion (1);
};

void() GrenadeExplodeOnDemand =
{
	self.grenadestate = 0;
	self.owner.plgrenade = world;
	
	if (self.owner.void_time > time)
	{
		T_RadiusDamage (self, self.owner, 160, world, 320, 96);
		T_RadiusDamageSelf(self, self.owner, 80, 200, 64);
	}
	else
	{
		T_RadiusDamage (self, self.owner, 120, world, 320, 96);
		T_RadiusDamageSelf(self, self.owner, 80, 200, 64);
	}

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion (0);
};

void() GrenadeExplode =
{
	self.grenadestate = 0;
	
	if (self.owner.plgrenade == self)
		self.owner.plgrenade = world;
	
	T_RadiusDamage (self, self.owner, 100, world, 320, 192);
	T_RadiusDamageSelf(self, self.owner, 80, 200, 64);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion (0);
};


void() GrenadeTouch =
{
	local float	damg;	// direct hit damage
	local float radamg; // radius damage

	if (other == self.owner)
		return;		// don't explode on owner

	radamg = 80;
	
	if (other.takedamage == DAMAGE_AIM)
	{
		damg = 140;

		if (self.skin == 0)
		{
			radamg = 40;
			damg += 100; // extra damage for manual detonation and hit at the same time
			if (self.owner.void_time > time)
				damg += 120;
		}
		
		self.grenadestate = 0;
		self.owner.plgrenade = world;
		StyleGive(self.owner, 20, 6, 0);
		T_Damage (other, self, self.owner, damg, 0, 1, 32);

		if (self.owner.void_time > time)
			Knockback(self, other, -600, 100, 0);
		
		// don't do radius damage to the other, because all the damage was done in the impact
		
		//hardcoded value for the case when we manually detonate the grenade and it hits the 
		//enemy, so most of the damage goes in a single target, doing less damage as AOE

		if (radamg < 80) 
			T_RadiusDamage (self, self.owner, radamg, other, 160, 96);
		else
			T_RadiusDamage (self, self.owner, radamg, other, 192, 160);
		T_RadiusDamageSelf(self, self.owner, 80, 200, 64);
	
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_EXPLOSION);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
		
		BecomeExplosion (0);
		return;
	}
	
	if (other.takedamage == DAMAGE_YES) //buttons etc
	{
		T_Damage(other, self.owner, self.owner, 40, 0, 0, 0);
		particle (self.origin, self.owner.origin, 72, 50);
	}
	
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void(entity who) DetonateLiveGrenade
{
	//dprint3("pl grenade classname is ",who.plgrenade.classname,"\n");
	if (who.plgrenade )
	{
		if (who.plgrenade.grenadestate == 1)
		{
			who.plgrenade.skin = 0;
		//	who.plgrenade.touch = SUB_Null;
			who.plgrenade.think = GrenadeExplodeOnDemand;
			who.plgrenade.nextthink = time + 0.25;
			who.plgrenade.grenadestate = 0;
			who.plgrenade = world;
		}
	}
};

/*
================================================================================================
																		Grenade Launcher
================================================================================================
*/

void() W_FireGrenade =
{
	local	entity remotegrenade;//, mpuff;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	//DetonateLiveGrenade(self);
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;
	remotegrenade = spawn ();
	remotegrenade.owner = self;
	remotegrenade.movetype = MOVETYPE_BOUNCE;
	remotegrenade.solid = SOLID_BBOX;
	remotegrenade.classname = "remotegrenade";

	if (self.v_angle_x)
		remotegrenade.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		remotegrenade.velocity = v_forward;//aim(self, 1000);
		remotegrenade.velocity = remotegrenade.velocity * 600;
		remotegrenade.velocity_z = 200;
	}

	remotegrenade.avelocity = '300 300 300';
	remotegrenade.angles = vectoangles(remotegrenade.velocity);
	remotegrenade.touch = GrenadeTouch;
	remotegrenade.nextthink = time + 2.5;
	remotegrenade.think = GrenadeExplode;
	remotegrenade.remove_time = time + 1.5 ; //for damage calculations
	remotegrenade.grenadestate = 1;
	setmodel (remotegrenade, "progs/grenade.mdl");
	setsize (remotegrenade, '0 0 0', '0 0 0');		
	setorigin (remotegrenade, self.origin);
	remotegrenade.skin = 2;
	//store pointer on last grenade 
	self.plgrenade = remotegrenade;
};

/*
================================================================================================
																		Rocket Launcher
================================================================================================
*/
void() T_MissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	damg = 80;
	//Knockback(self, other, 600, 100, 0);
	T_Damage (other, self, self.owner, damg, 0, 1, 0 );

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 80, other, 160, 160 );
	T_RadiusDamageSelf(self, self.owner, 80, 160, 64);

	//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion (0);
};

void() RocketExplode =
{
	T_RadiusDamage (self, self.owner, 80, world, 256, 32 );
	T_RadiusDamageSelf(self, self.owner, 80, 160, 64);
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion (0);
};

void() RocketTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	//if (other.health > (other.max_health * 0.9)) damg = 200;
	//else 
	damg = 140;

	T_Damage (other, self, self.owner, damg, 0, 1, 128 );
	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 80, other, 160, 160 );
	T_RadiusDamageSelf(self, self.owner, 80, 160, 64);
	Knockback(self, other, 600, 100, 0);
	
	//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion (0);
};

void() W_FireRocket =
{
	local	entity plrocket;//, mpuff;
	vector dir;

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
	dir = v_forward;

	plrocket = spawn ();
	plrocket.owner = self;
	plrocket.movetype = MOVETYPE_FLYMISSILE;
	plrocket.solid = SOLID_BBOX;
	plrocket.classname = "missile";
	//plrocket.monstertype = MISC_ROCKET;
	plrocket.velocity = normalize(dir); 
	
	if (self.void_time > time)
		plrocket.velocity = plrocket.velocity * 1400;
	else 
		plrocket.velocity = plrocket.velocity * 900;
	
	plrocket.angles = vectoangles(plrocket.velocity);
	plrocket.touch = RocketTouch;
	plrocket.think = RocketExplode;
	plrocket.nextthink = time + 6;

	setmodel (plrocket, "progs/missile.mdl");
	setsize (plrocket, '0 0 0', '0 0 0');	
	setorigin (plrocket, self.origin + v_forward + '0 0 22' + v_right );
	
	self.punchangle_x = -2;
};

/*
================================================================================================
																		Railgun
================================================================================================
*/

void() rail_fade = 
{
	self.think = rail_fade;
	self.nextthink = time + 0.05;
	//	if (self.frame > 1)
	//		self.frame --;

		 if (self.cnt == 6) self.alpha = 0.8;
	else if (self.cnt == 5)	self.alpha = 0.6;
	else if (self.cnt == 4)	self.alpha = 0.4;
	else if (self.cnt == 3)	self.alpha = 0.2;
	else if (self.cnt == 2)	self.alpha = 0.10;
	else if (self.cnt == 1) 
	{
		self.alpha = 0.05;
		self.think = SUB_Remove;
		self.nextthink = time + 0.05;
		
	}	
	self.cnt = self.cnt - 1;
};

void() W_FireLightning =
{
	local float timetoend;
	local	vector	vel, org, dir, src,  destination, loopsrc;
	local entity thedude;
	//local float traillen, segments, mathvar;
	
	if (!(self.vmflags & VMF_PLAYER_INSEQUENCE) && self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}
	
	makevectors(self.v_angle);
	
	sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);

	org = self.origin + '0 0 16';

	dir = v_forward;//aim (self, 1000);
	src = self.origin + v_forward * 10;
	src_z = self.absmin_z + self.size_z * 0.84;
	destination = src + (dir * 1536);
		
	loopsrc = src;
	thedude = self;
	if (self.rail_charge > 4) self.rail_charge = 4;
	self.rail_charge -= 1;
	
	while ( !timetoend )
	{
		traceline (loopsrc, destination, FALSE, thedude);
		if (trace_fraction != 1.0)
		{
			vel = normalize(dir);
			vel = vel + 2 * trace_plane_normal;
			vel = vel * 200;

			org = trace_endpos - dir*4;

			if (trace_ent.takedamage && trace_ent.tier)
			{
				thedude = trace_ent;
				SpawnBlood (org, vel*0.2, 200);
	
				if (trace_ent.monstertype == MT_SHAMBLER) 
					T_Damage (trace_ent, self, self, raildamagemain[self.rail_charge]*0.5, 0, 1, 64);
				else 
					T_Damage (trace_ent, self, self, raildamagemain[self.rail_charge], 0, 1, 64);
				loopsrc = trace_endpos + (dir * 2);
			}
			else
			{
				if (trace_ent.takedamage) T_Damage (trace_ent, self, self, 100, 0, 0, 0); // buttons etc
				if (self.rail_charge == 0) particle (org, trace_plane_normal*1024, 72, 50);
				else if (self.rail_charge == 1) particle (org, trace_plane_normal*1024, 104, 50);
				else if (self.rail_charge == 2) particle (org, trace_plane_normal*1024, 200, 50);
				else if (self.rail_charge == 3) particle (org, trace_plane_normal*1024, 8, 50);
				timetoend = 1;
			}
		}
		else timetoend = 1;
	}
//--- ALKALINE RAIL CODE

	traceline(src, destination, TRUE, self);
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_NOCLIP;
	newmis.solid = SOLID_NOT;
	newmis.angles = vectoangles(dir);
	newmis.touch = SUB_Null;
	newmis.classname = "railtrail";
	setmodel (newmis, "progs/rail.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, self.origin);//
	newmis.frame = 20;
	newmis.velocity = v_forward*1900;
	newmis.think = rail_fade;
	newmis.nextthink = time + 0.5;
	newmis.skin = self.rail_charge;
	newmis.cnt = 6;	
	self.rail_charge = 0; // reset
	
	self.punchangle_z = crandom()*12;
	self.punchangle_x -= 2;
};

// ------------------------------------------RAILGUN PREPARING SHOTS--------------------------
void() W_FirePreLightning =
{
	local vector vel, org, dir, src,  destination;
	local float chargecount;
	local entity who;
	who = world;
	sound (self, CHAN_WEAPON, "weapons/static.wav", 1, ATTN_NORM);
	
	//org = self.origin + '0 0 16';
	makevectors(self.v_angle);
	dir = v_forward;//aim (self, 1000);
	
	//src = self.origin + v_forward * 10 ;
	src = self.origin + v_forward * 10 + '0 0 8';
	src_z = self.absmin_z + self.size_z * 0.84;
	destination = src + (dir * 640);
	//effect = src + (dir * 640);
		
	chargecount = self.rail_charge;
	if (chargecount > 3) chargecount = 3;
	traceline (src, destination, FALSE, self);
	if (trace_fraction != 1.0)
	{
		vel = normalize(dir);
		vel = vel + 2 * trace_plane_normal;
		vel = vel * 200;

		org = trace_endpos - dir*4;

		if (trace_ent.takedamage)
		{
			Knockback(self, trace_ent, -300, 100, 0);
			SpawnBlood (org, vel*0.2, 20);
			if (trace_ent.monstertype == MT_SHAMBLER) 
				T_Damage (trace_ent, self, self, raildamagepre[chargecount]*0.5, 0, 1, 512);
			else
				T_Damage (trace_ent, self, self, raildamagepre[chargecount], 0, 1, 512);
			who = trace_ent;
		}
		
	}
	src = self.origin + v_forward*10 + '0 0 8' + self.velocity * 0.05;
	
	traceline (src, destination, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, who);
	WriteCoord (MSG_BROADCAST, destination_x);
	WriteCoord (MSG_BROADCAST, destination_y);
	WriteCoord (MSG_BROADCAST, destination_z);
	WriteCoord (MSG_BROADCAST, src_x);
	WriteCoord (MSG_BROADCAST, src_y);
	WriteCoord (MSG_BROADCAST, src_z);
	
	if (self.ammo_cells > 0)
		self.currentammo = self.ammo_cells = self.ammo_cells - 1;
};

//=============================================================================

void() spike_touch;
void() trapspike_touch;
void() spike_touch =
{
//local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		if (self.classname == "wizspike")
		{
			spawn_touchblood (10);
			T_Damage (other, self, self.owner, 3, 1, 0, 0);
		}
		else if (self.classname == "knightspike")
		{
			spawn_touchblood (10);
			T_Damage (other, self, self.owner, 8, 2, 0, 0);
		}
		else
		{
			spawn_touchblood (10);
			T_Damage (other, self, self.owner, 10, 0, 0, 0);
		}
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 800;
};

void() trapspike_touch =
{
//local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (20);
		T_Damage (other, self, self.owner, 20, 0, 0, 0);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);
};

void() ShockCombo =
{
	local float grendist;
	local vector offset;
	//dprint("Edict: ");
	//dprint(self.plgrenade.classname);
	//dprint(", self: ");
	//dprint(self.classname);
	//dprint(", Coords: ");
	//dprint(vtos(self.plgrenade.origin));
	//dprint(", state: ");
	//dprint(ftos(self.plgrenade.grenadestate));
	//dprint("\n");
	offset = self.origin + '0 0 22';
	
	makevectors(self.v_angle);	
	grendist = vlen(offset - self.plgrenade.origin);
	traceline (offset, offset + v_forward*grendist, TRUE, self);
	grendist = vlen(trace_endpos - self.plgrenade.origin);

	if (grendist < 24)
	{
		self.plgrenade.think = GrenadeCombo;
		self.plgrenade.nextthink = time;
	}
	else DetonateLiveGrenade(self);
	self.plgrenade = world;
};

/*
====================================================================================================================================

																	PLAYER WEAPON USE

====================================================================================================================================
*/

void() W_SetCurrentAmmo =
{
	//player_run ();		// get out of any weapon firing states //Void: do not interupt think chains when pick up ammo or backpacks

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	
	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
		if (!self.axe_inattack)	self.weaponframe = 0;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = 1;
		//self.currentammo = self.ammo_shells;
		//self.weaponframe = 0;
		self.weaponmodel = "progs/v_shot.mdl";
		//self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		//self.weaponframe = 0;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		//self.currentammo = 1;
		self.currentammo = self.ammo_nails;
		//self.weaponframe = 0;
		self.weaponmodel = "progs/v_nail.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		//self.weaponframe = 0;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		//self.weaponframe = 0;
		self.weaponmodel = "progs/v_rock.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		//self.weaponframe = 0;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		//self.weaponframe = 0;
		self.weaponmodel = "progs/v_light.mdl";
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		//self.weaponframe = 0;
	}
};

float() W_BestWeapon =
{
	local	float	it;
	
	it = self.items;

	//self.weaponframe = 0;
	// self.waterlevel <= 1 &&
	
	if ( ( self.ammo_nails > 0 ) && ( it & IT_SUPER_NAILGUN ) )
		return IT_SUPER_NAILGUN;
	if ( ( self.ammo_shells > 0 ) && ( it & IT_SUPER_SHOTGUN ) )
		return IT_SUPER_SHOTGUN;
	//if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )

	if ((self.ammo_nails > 1) && ( it & IT_NAILGUN ))
		return IT_NAILGUN;
	//if(self.ammo_shells >= 1 && (it & IT_SHOTGUN) )
	if ( it & IT_SHOTGUN )
		return IT_SHOTGUN;
	//if ( ( self.ammo_cells >= 1 ) && ( it & IT_LIGHTNING ) )
	//	return IT_LIGHTNING;
	return IT_AXE;
};

float() W_CheckNoAmmo =
{
	//if (self.vmflags & VMF_PLAYER_INSEQUENCE)
	//	return TRUE;
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == IT_AXE || self.weapon == IT_SHOTGUN)
		return TRUE;
	
	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
	
// drop the weapon down
	return FALSE;
};

void( float NormalRPM, float BonusRPM, float WeaponChangeTime) DoWeaponDelay  =
{
	if (self.void_time  > time) self.attack_finished = time + BonusRPM;
	else self.attack_finished = time + NormalRPM;
	
	self.weaponchange_time = time + WeaponChangeTime;
};
/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
//void()	player_nail1;
//void()	player_light1;
void()	player_nailgunloop;
void()	player_railloop;
void()	player_rocket1;
void()  player_sngburstlong1;
void()  player_sngburstshort1;
void()  player_sng1;
void()	player_axeloop;
void()	player_dash;
void()	player_sngloop;
/*
====================================================================================================================================

																	ATTACK

====================================================================================================================================
*/
void() W_Attack =
{
	//local	float	r;

	if (!W_CheckNoAmmo ())
		return;

	makevectors	(self.v_angle);			// calculate forward angle for velocity
	if (!(self.weapon == IT_AXE) && !(self.weapon == IT_NAILGUN)) 
		self.show_hostile = time + 1;	// wake monsters up
//------------------------------------------------------------------------------------------------------------------------------
	if (self.weapon == IT_AXE)
	{
		//DetonateLiveGrenade(self);// explode grenade
		if (self.axe_cooldown > time ) 
			return;
		if (self.axe_inattack == 0)
		{
			//sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);

			self.axe_timer = time;
			self.axe_inattack = 1;
			self.vmflags = self.vmflags | VMF_PLAYER_INSEQUENCE;
			player_axeloop();
			DoWeaponDelay( 10.0, 10.0, 10.0 ); 
			
			//if (self.void_time  > time) self.attack_finished = time + 0.7;
			//else self.attack_finished = time + 0.3;

			//self.weaponchange_time = time + 0.3;
		}
	}
//------------------------------------------------------------------------------------------------------------------------------
	else if (self.weapon == IT_SHOTGUN)
	{
		if (self.sg_cooldown > time ) 
			return;
		
		player_shot1 ();
		W_FireShotgun ();
		//grenade manual detonation
		if (self.plgrenade) 
		{
			if (self.void_time > time)
				ShockCombo();
			else 
				DetonateLiveGrenade(self); // explode grenade
		}
		
		//rifle specific timers
		if (self.items & IT_RIFLE)
		{
			DoWeaponDelay( 0.9, 0.7, 0.3 ); // Standart RPM, Quad RPM, Weapon Switch Delay.
		
			//weapon specific timer to prevent fastswitch abuse
			if (self.void_time  > time) 
				self.sg_cooldown = time + 0.7;
			else 
				self.sg_cooldown = time + 0.9;
		}
		else
		{
			DoWeaponDelay( 0.5, 0.375, 0.3 ); // Standart RPM, Quad RPM, Weapon Switch Delay.
		
			//weapon specific timer to prevent fastswitch abuse
			if (self.void_time  > time) 
				self.sg_cooldown = time + 0.375;
			else 
				self.sg_cooldown = time + 0.5;
		}
	}
//------------------------------------------------------------------------------------------------------------------------------
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		if (self.ssg_cooldown > time ) 
			return;
		player_shot1 ();
		W_FireSuperShotgun ();

		if (!(self.flags & FL_ONGROUND)) //backwards boost in the air
		{	
			//if (self.quad_time  > time) self.velocity = self.velocity - (v_forward * 450);
			if (self.void_time  > time) 
				self.velocity = self.velocity - (v_forward * 320);
		}
		
		if (self.ssgrefirebonus)
		{	
			//weapon specific timer to prevent fastswitch abuse
			if (self.void_time  > time) 
				self.ssg_cooldown = time + 0.225;
			else 
				self.ssg_cooldown = time + 0.325;
			
			DoWeaponDelay( 0.325, 0.225, 0.25 ); 
			
			if (self.armorplates == 0) 
				GivePlates(self,1);
			self.ssgrefirebonus -= 1;
			//StyleGive(self, 100, 2, 0);
			//self.healdelay_time = time + 1;
		}
		else 
		{
			//weapon specific timer to prevent fastswitch abuse
			if (self.void_time  > time) 
				self.ssg_cooldown = time + 0.81;
			else 
				self.ssg_cooldown = time + 0.9;
			
			DoWeaponDelay( 0.9, 0.81, 0.4 ); 
		}
	}
//------------------------------------------------------------------------------------------------------------------------------
	else if (self.weapon == IT_NAILGUN)
	{
		if (!(self.vmflags & VMF_PLAYER_INSEQUENCE) && self.ammo_nails < 2)
		{
			self.weapon = W_BestWeapon ();
			W_SetCurrentAmmo ();
			return;
		}
		if (self.void_time  > time) 
			self.nailgun_time = time + 0.4;
		else 
			self.nailgun_time = time + 0.7;
	
		self.vmflags = self.vmflags | VMF_PLAYER_INSEQUENCE;
		player_nailgunloop();

		//DoWeaponDelay( 0.1, 0.1, 0.1 ); 
		DoWeaponDelay( 10.0, 10.0, 10.0 ); 
	}
//------------------------------------------------------------------------------------------------------------------------------
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		//dprint3("SNG QUEUE = ",ftos(self.sngqueue),"\n");
		//W_FireSuperNailgun();
		//player_rocket1();
		if (self.sng_cooldown > time ) 
			return;
		if (self.void_time  > time) 
			self.sng_cooldown = time + 0.4;
		else 
			self.sng_cooldown = time + 0.9;
		
		player_sngloop(); 
		W_FireSuperNailgun(2);
		DoWeaponDelay( 0.9, 0.4, 0.03 ); 
		/*
		if (self.sngqueue > 11 && self.ammo_nails > 5)
		{
			self.weaponframe = 0;
			self.vmflags = self.vmflags | VMF_PLAYER_INSEQUENCE;
			player_sngburstlong1();
			DoWeaponDelay( 0.9, 0.81, 0.7 );
			self.sngqueue -= 6;
			self.clearsngqueue = time + 1.5;
			self.currentammo = self.ammo_nails = self.ammo_nails - 6;
		}
		else if (self.sngqueue > 0 && self.ammo_nails > 2) 
		{
			self.weaponframe = 0;
			self.vmflags = self.vmflags | VMF_PLAYER_INSEQUENCE;
			player_sngburstshort1();
			DoWeaponDelay( 0.7, 0.63, 0.55 );
			self.sngqueue -= 3;
			self.clearsngqueue = time + 1.5;
			self.currentammo = self.ammo_nails = self.ammo_nails - 3;
		}
		else
		{
			self.weaponframe = 0;
			self.vmflags = self.vmflags | VMF_PLAYER_INSEQUENCE;
			player_sng1();
			DoWeaponDelay( 0.41, 0.41, 0.41 ); 
			self.clearsngqueue = time + 1.5;
			self.currentammo = self.ammo_nails = self.ammo_nails - 1;
		}		*/
	}
//------------------------------------------------------------------------------------------------------------------------------
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
		DoWeaponDelay( 0.6, 0.54, 0.3 ); 
	}
//------------------------------------------------------------------------------------------------------------------------------
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		if (self.rl_cooldown > time ) 
			return;
		
		W_FireRocket();
		player_rocket1();
		DoWeaponDelay( 0.8, 0.72, 0.4 ); 
	
		//weapon specific timer to prevent fastswitch abuse
		if (self.void_time  > time) 
			self.rl_cooldown = time + 0.72;
		else 
			self.rl_cooldown = time + 0.8;
	}
//------------------------------------------------------------------------------------------------------------------------------
	else if (self.weapon == IT_LIGHTNING)
	{
		if (self.lg_cooldown > time ) 
			return;

			//weapon specific timer to prevent fastswitch abuse

		self.vmflags = self.vmflags | VMF_PLAYER_INSEQUENCE;
		DoWeaponDelay( 6, 6, 6 ); // delay will be overwritten in player_railloop
		self.weaponframe = 0;
		self.rail_charge = 0;
		player_railloop();
		//player_rail1();
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);

		//weapon specific timer to prevent fastswitch abuse
		if (self.void_time  > time) 
			self.lg_cooldown = time + 1.35;
		else 
			self.lg_cooldown = time + 1.50;
	}
};
/*
====================================================================================================================================

																	END OF ATTACK

====================================================================================================================================
*/
/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl;
	
	it = self.items;
	am = 0;
	
	//if ( (self.attack_finished - time) > 0.5)
	self.attack_finished = time + 0.1;
	player_run ();
	if (self.gravity < 0)
	self.gravity = 1;
	
	if (self.impulse == 1)
	{
		fl = IT_AXE;
	}
	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;
		//if (self.ammo_shells < 1)
		//	am = 1;
	}
	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 1)
			am = 1;
	}		
	else if (self.impulse == 4)
	{
		fl = IT_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 8)
	{
		fl = IT_LIGHTNING;
		if (self.ammo_cells < 1)
			am = 1;
	}

	self.impulse = 0;
	self.axe_inattack = 0;
	
	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
		sprint (self, "no weapon.\n");
		return;
	}
	
	if (am)
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	self.weapon = fl;		
	W_SetCurrentAmmo ();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if (deathmatch)
		return;

	self.ammo_rockets = ROCKETS_MAX;
	self.ammo_nails = NAILS_MAX;
	self.ammo_shells = SHELLS_MAX;
	self.ammo_cells = CELLS_MAX;
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_LIGHTNING |
		IT_RIFLE;
		//| IT_KEY1 | IT_KEY2;	
	//self.items = self.items | IT_LIGHTNING;

	//self.weapon = IT_SUPER_SHOTGUN;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;
	
	self.attack_finished = time + 0.15;
	player_run ();
	
	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_SHOTGUN;
			//if (self.ammo_shells < 1)
			//	am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
		
		self.axe_inattack = 0;
		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;
	
	self.attack_finished = time + 0.15;
	player_run ();
	
	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_SHOTGUN;
			//if (self.ammo_shells < 1)
			//	am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
		
		self.axe_inattack = 0;
		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	if (deathmatch)
		return;
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat =
{
	if (deathmatch)
		return;
	self.quad_flash = 1;
	self.quad_time = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};
/*
============
DASH

DASH Revolution
============
*/
void()	player_finishdash =
{
	//dprint("player_finishdash\n");
	self.owner.gravity = 1;
	self.owner.indash = 0;
	self.owner.dashbutton = 0;
};
void() player_dodashjump =
{
	//dprint("player_dodashjump\n");
	self.owner.velocity = self.owner.velocity + '0 0 96';

	player_finishdash();
};

void() player_dodash =
{
	//dprint("player_dodash\n");
	local vector wishspeed;
	local float momentum,jheight;
	
	if (!(self.owner.flags & FL_ONGROUND)) self.owner.axe_inair = 1;
	
	if((self.owner.flags & FL_ONGROUND))
	{
		self.owner.velocity_z += 160;
		self.owner.flags -= FL_ONGROUND;
	}
	else self.owner.velocity_z += 96;
	
	if (self.owner.v_angle_x < 45)
	{
		makevectors (self.owner.angles); // we need v_forward
		
		if (self.owner.v_angle_x > 0) 
		{
			momentum = (90 - self.owner.v_angle_x) / 90; 
			jheight = 0;
		}
		else
		{
			momentum = ((90 + self.owner.v_angle_x) / 90);
		}
		jheight =  (1 - ((90 + self.owner.v_angle_x) / 90)) * 90;

		wishspeed += v_forward * (1024 * momentum);
		local vector dir;
		dir = aim (self.owner, 100);
		wishspeed = (dir * (1024 * momentum));
		self.owner.gravity = 0;
		self.owner.velocity_x = wishspeed_x;
		self.owner.velocity_y = wishspeed_y;
		
		if ( wishspeed_z < 0 )	
			wishspeed_z = wishspeed_z * -1;
		self.owner.velocity_z = wishspeed_z + jheight; 
			
		if (( self.owner.flags & FL_ONGROUND ))
		{
			self.owner.velocity_z += 160;
			self.owner.flags -= FL_ONGROUND;
		}
		else self.owner.velocity_z += 96;
	}
	else
	{
		local float vrange;
		vrange = 90 / self.owner.v_angle_x; 
		self.owner.velocity = normalize(v_forward);
		self.owner.velocity = self.owner.velocity * 500 * vrange;
	}
	self.think = player_finishdash;
	self.nextthink = time + 0.35;
};

void() player_dash =
{
	//dprint("player_dash\n");
	if ( !self.owner.dashbutton )
	{
		if (!(self.owner.flags & FL_ONGROUND) && (self.owner.v_angle_x < 45) && self.owner.axe_inair) player_dodashjump(); 
		else player_dodash();
		return;
	}
	self.think = player_dash;
	self.nextthink = 0.05;
};
/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon ();

	if (self.impulse == 9)
		CheatCommand ();
	if (self.impulse == 10)
		CycleWeaponCommand ();
	if (self.impulse == 11)
		ServerflagsCommand ();
	if (self.impulse == 12)
		CycleWeaponReverseCommand ();
	
	if (self.impulse == 109)
	{
		if (!(self.speedometer)) self.speedometer = 1;
		else self.speedometer = 0;
	}
	if (self.impulse == 110)
	{
		stuffcmd(self, "alias +crouch impulse 111\n");
		stuffcmd(self, "alias -crouch impulse 112\n");
		stuffcmd(self, "\nalias +dash impulse 121\n");
		stuffcmd(self, "alias -dash impulse 122\n");
	}
	/*if (self.impulse == 111)
	{
		self.slidebutton = 1;
	}
	if (self.impulse == 112)
	{
		self.slidebutton = 0;
	}
	if (self.impulse == 120)
	{
		stuffcmd(self, "alias +dash impulse 121\n");
		stuffcmd(self, "alias -dash impulse 122\n");
	}
	if (self.impulse == 121)
	{
		self.dashbutton = 1;
	}
	if (self.impulse == 122)
	{
		self.dashbutton = 0;
	}*/
	if (self.impulse == 36)
	{
	/*	local	vector	src;
		
		makevectors(self.v_angle);
		src = self.origin + v_forward*10;
		src_z = self.absmin_z + self.size_z * 0.84;
		traceline (src, src + v_forward*2048, FALSE, self);
		DrawDamageNumbers(self, trace_endpos, self.dmgnumber, 1);
		self.dmgnumber = 222;*/
	}
	if (self.impulse == 37) 
	{
		if (self.hitsounds) 
		{
			self.hitsounds = 0;
			sprint(self,"Hitsounds disabled\n");
		}
		else 
		{
			self.hitsounds = 1;
			sprint(self,"Hitsounds enabled\n");
		}
	}
	if (self.impulse == 38)
	{
		if (self.displaydamage == 0) 
		{
			self.displaydamage = 1;
			sprint(self,"Damage information enabled, remaining HP\n");
		}
		else if (self.displaydamage == 1) 
		{
			self.displaydamage = 2;
			sprint(self,"Damage information enabled, damage done\n");
		}
		else 
		{
			self.displaydamage = 0;
			sprint(self,"Damage information disabled\n");
		}
	}
	//if (self.impulse == 129) coredump();
	if (self.impulse == 252)
	{
		dprint4(ftos(self.armorvalue-self.armorplates),"- armor ",ftos(self.armorplates),"- plates\n"); // plates cheat
	}
	if (self.impulse == 253)
	{
		StripPlates(self);
		self.armorplates += 5;
		PutPlates(self);
		if (!(self.items & IT_ARMOR3)) self.items = self.items + IT_ARMOR3;
		dprint("5 plates added\n"); // plates cheat
	}
	if (self.impulse == 254)
	{
		sound (self, CHAN_AUTO, "items/voidforcein.wav", 1.0, ATTN_NORM);
		stuffcmd (self, "bf\n");
		self.void_time = time + 30;
		self.changevcshift = 1;
	}
	if (self.impulse == 255)
		QuadCheat ();

	self.impulse = 0;
};

void() CheckSlide =
{
	if (!(self.flags & FL_ONGROUND) && !(self.infall)) 
	{
		self.fall_time = time;
		self.infall = 1;
		self.slidebutton = 0;
		return;
	}
	if ((self.flags & FL_ONGROUND) && (self.infall)) 
	{
		local float duration;
		self.infall = 0;
		duration = time - self.fall_time;
		duration = duration * duration;
		duration += 0.4;
		//dprint(ftos(duration));
		//dprint(" = duration\n");
		if (duration > 10) duration = 10;
		self.slide_time = time + duration;
	}
	if ((self.slidebutton == 1) && (self.flags & FL_ONGROUND) && (self.slide_time > time) && (!(self.inslide)) )
	{
		stuffcmd(self, "\ncl_rollangle 8\n");
		stuffcmd(self, "cl_rollspeed 400\n");
		stuffcmd(self, "sv_friction 1.3\n");
		stuffcmd(self, "sv_maxspeed 272\n");
		stuffcmd(self, "sv_accelerate 32\n");
		//stuffcmd(self, "clear\n");
		self.inslide = 1;
		return;
	}
	if (((self.slidebutton == 0) || (self.slide_time <= time) || (!(self.flags & FL_ONGROUND)) ) && (self.inslide))
	{
		stuffcmd(self, "\ncl_rollangle 2\n");
		stuffcmd(self, "cl_rollspeed 200\n");
		stuffcmd(self, "sv_friction 4\n");
		stuffcmd(self, "sv_maxspeed 320\n");
		stuffcmd(self, "sv_accelerate 10\n");
		//stuffcmd(self, "clear\n");
		self.inslide = 0;
		self.slidebutton = 0;
	}
};
void() DrawSpeed =
{
	if (self.speedometer == 1)
	{
		local float hudspeed;
		hudspeed = vlen(self.velocity);
		centerprint (self, ftos(hudspeed));
	}
}

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_ThinkEntityFrame =
{
	if (self.impulse == 111)
	{
		self.slidebutton = 1;
		self.impulse = 0;
	}
	if (self.impulse == 112)
	{
		self.slidebutton = 0;
		self.impulse = 0;
	}

	if (self.impulse == 121)
	{
		self.dashbutton = 1;
		self.impulse = 0;
	}
	if (self.impulse == 122)
	{
		self.dashbutton = 0;
		self.impulse = 0;
	}

	//self.impulse = 0;
	
	if (self.dashbutton && (self.indash == 0))
	{
		//dprint("weaponframe\n");
		self.indash = 1;
		self.thinkent.think = player_dash;
		self.thinkent.nextthink = time;
	}
};

void() W_WeaponFrame =
{
	if (self.void_time > time) 
	{
		if (self.changevcshift)
		{
			stuffcmd(self,"\nv_cshift 200 70 200 30\n");
			//stuffcmd(self,"\nv_cshift 160 70 160 20\n");
			self.changevcshift = 0;
		}
	}
	else
	{
		if (self.changevcshift)
		{
			stuffcmd(self,"\nv_cshift 0 0 0 0\n");
			self.changevcshift = 0;
		}
	}
	
	if ( ( self.healdelay_time < time ) && (self.armorvalue - self.armorplates < 100) && (self.nextheal_time < time)) 
	{
		StripPlates(self);
		self.armorvalue = self.armorvalue + 5;
		if (self.armorvalue > 100) self.armorvalue = 100;
		self.nextheal_time = time + 0.1;
		PutPlates(self);
	}

	//if (self.clearnailcombo < time && self.nailcombocounter > 0 && self.void_time < time) self.nailcombocounter = 0; 
	// clear Nailgun combo
	if (self.clearsngqueue < time && self.sngqueue < 30 ) 
	{
		self.sngqueue += 6;	//clear SNG burst combo
		if (self.sngqueue > 30) self.sngqueue = 30; 
		self.clearsngqueue = time + 0.5;
	}
	if ((self.flags & FL_ONGROUND) && self.axe_inair) self.axe_inair = 0;
	
	if (!(coop) && !(deathmatch)) CheckSlide();
	DrawSpeed();
			
	if (time < self.weaponchange_time )
		return;
	if (self.impulse)
		ImpulseCommands ();
	   
	if (time < self.attack_finished )
		return;
	// check for attack
	if (self.button0 && !(self.stopattack))
	{
		SuperDamageSound ();
		W_Attack ();
	}
	
	if (self.stopattack) 
	{ 
		if (!(self.button0)) self.stopattack = 0;
		else if (self.stopattack_time < time) self.stopattack = 0;
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.quad_time > time)
	{
		if (self.quad_sound < time)
		{
			self.quad_sound = time + 1;
			//if (self.weapon != IT_AXE)	sound (self, CHAN_BODY, "items/damage3.wav", 0.25, ATTN_NORM);
		}
	}
	return;
};


