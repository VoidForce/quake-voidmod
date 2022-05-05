/*
==============================================================================

SHAL-RATH

==============================================================================
*/
$cd id1/models/shalrath
$origin 0 0 24
$base base
$skin skin
$scale 0.7

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11

$frame pain1 pain2 pain3 pain4 pain5 

$frame death1 death2 death3 death4 death5 death6 death7

$frame	walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame	walk11 walk12

void(entity attacker, float damage) shalrath_pain;
void() ShalMissile;
void() ShalGrenade;
void() shal_stand     =[      $walk1,       shal_stand    ] {ai_stand();};

void() shal_walk1     =[      $walk2,       shal_walk2    ] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
ai_walk(6);};
void() shal_walk2     =[      $walk3,       shal_walk3    ] {ai_walk(4);};
void() shal_walk3     =[      $walk4,       shal_walk4    ] {ai_walk(0);};
void() shal_walk4     =[      $walk5,       shal_walk5    ] {ai_walk(0);};
void() shal_walk5     =[      $walk6,       shal_walk6    ] {ai_walk(0);};
void() shal_walk6     =[      $walk7,       shal_walk7    ] {ai_walk(0);};
void() shal_walk7     =[      $walk8,       shal_walk8    ] {ai_walk(5);};
void() shal_walk8     =[      $walk9,       shal_walk9    ] {ai_walk(6);};
void() shal_walk9     =[      $walk10,      shal_walk10   ] {ai_walk(5);};
void() shal_walk10    =[      $walk11,      shal_walk11   ] {ai_walk(0);};
void() shal_walk11    =[      $walk12,      shal_walk12   ] {ai_walk(4);};
void() shal_walk12    =[      $walk1,       shal_walk1    ] {ai_walk(5);};

void() shal_run1     =[      $walk2,       shal_run2    ] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
ai_run(6);};
void() shal_run2     =[      $walk3,       shal_run3    ] {ai_run(4);};
void() shal_run3     =[      $walk4,       shal_run4    ] {ai_run(0);};
void() shal_run4     =[      $walk5,       shal_run5    ] {ai_run(0);};
void() shal_run5     =[      $walk6,       shal_run6    ] {ai_run(0);};
void() shal_run6     =[      $walk7,       shal_run7    ] {ai_run(0);};
void() shal_run7     =[      $walk8,       shal_run8    ] {ai_run(5);};
void() shal_run8     =[      $walk9,       shal_run9    ] {ai_run(6);};
void() shal_run9     =[      $walk10,      shal_run10   ] {ai_run(5);};
void() shal_run10    =[      $walk11,      shal_run11   ] {ai_run(0);};
void() shal_run11    =[      $walk12,      shal_run12   ] {ai_run(4);};
void() shal_run12    =[      $walk1,       shal_run1    ] {ai_run(5);};

void() shal_attack1     =[      $attack1,       shal_attack2    ] {
sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
ai_face();
};
void() shal_attack2     =[      $attack2,       shal_attack3    ] {ai_face();};
void() shal_attack3     =[      $attack3,       shal_attack4    ] {ai_face();};
void() shal_attack4     =[      $attack4,       shal_attack5    ] {ai_face();};
void() shal_attack5     =[      $attack5,       shal_attack6    ] {if (self.enraged) ShalGrenade();ai_face();};
void() shal_attack6     =[      $attack6,       shal_attack7    ] {ai_face();};
void() shal_attack7     =[      $attack7,       shal_attack8    ] {if (self.enraged) ShalGrenade();ai_face();};
void() shal_attack8     =[      $attack8,       shal_attack9    ] {ai_face();};
void() shal_attack9     =[      $attack9,       shal_attack10   ] {ai_face();ShalMissile();};
void() shal_attack10    =[      $attack10,      shal_attack11   ] {ai_face();};
void() shal_attack11    =[      $attack11,      shal_run1       ] {};

void() shal_pain1       =[      $pain1, shal_pain2      ] {};
void() shal_pain2       =[      $pain2, shal_pain3      ] {};
void() shal_pain3       =[      $pain3, shal_pain4      ] {};
void() shal_pain4       =[      $pain4, shal_pain5      ] {};
void() shal_pain5       =[      $pain5, shal_run1       ] {};

void() shal_death1      =[      $death1,        shal_death2     ] {};
void() shal_death2      =[      $death2,        shal_death3     ] {};
void() shal_death3      =[      $death3,        shal_death4     ] {};
void() shal_death4      =[      $death4,        shal_death5     ] {};
void() shal_death5      =[      $death5,        shal_death6     ] {};
void() shal_death6      =[      $death6,        shal_death7     ] {};
void() shal_death7      =[      $death7,        Decay    ] {Think(self, 5);};


void(entity attacker, float damage) shalrath_pain =
{
	ai_berserk(150); // berserk mode (enraged = 2), set health at which monster is go berserk
	
	if (!(self.dopain))
		return;
	
	self.dopain = 0;
	
	if (self.pain_time > time)
		return;
	
	sound (self, CHAN_VOICE, "shalrath/pain.wav", 1, ATTN_NORM);
	shal_pain1();
	
	self.pain_time = time + 3;
};

void() shalrath_die =
{
	// check for gib
	if (self.health < -90 || self.gib)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_shal.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		MonsterDied(self.enemy, 9, 1, self.enraged);
		return;
	}
	MonsterDied(self.enemy, 9, 0, self.enraged);
	sound (self, CHAN_VOICE, "shalrath/death.wav", 1, ATTN_NORM);
	self.solid = SOLID_NOT;
	shal_death1();
	// insert death sounds here
};

/*
================
ShalMissile
================
*/
void() ShalMissileTouch;
void() ShalHome;

void() ShalGrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 25, world, 200, 64 );
	
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() ShalGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	
	//if (other.health)
	if (other.takedamage == DAMAGE_AIM)
	{
		if (other.monstertype == MT_ZOMBIE)
			T_Damage (other, self, self.owner, 110, 0, 1, 0);	
		else T_Damage (other, self, self.owner, 25, 25, 1, 0);	
		T_RadiusDamage (self, self.owner, 50, other, 160, 64);
		T_Push (other, self, self.owner, world, 320, 0, 0);
		
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_EXPLOSION);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
				
		BecomeExplosion (0);
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
	self.avelocity = '0 0 0';
};

void() ShalGrenade =
{
	local	entity missile;//, mpuff;
	local	vector	dir;
	local 	float	dist3d;
	local	float 	savedz;
	local	vector enemyvelprediction;
	local	float	timetotarget;
	local 	float	grenadevelocity;
	
	grenadevelocity = 900;

	dist3d = vlen (self.enemy.origin - self.origin);
	timetotarget =  dist3d / grenadevelocity;
	enemyvelprediction = self.enemy.velocity;
	if (dist3d < 384)
	{
		if (enemyvelprediction_z > 0) enemyvelprediction_z -= (world.worldgravity * timetotarget);
		enemyvelprediction = self.enemy.origin + (enemyvelprediction * timetotarget*0.5);
	}

	self.effects = self.effects | EF_MUZZLEFLASH;

	sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
		
	// set missile speed	
	makevectors (self.angles);
	dir = self.enemy.origin + self.enemy.velocity * (0.175 + random()*0.05);

	missile.velocity = normalize (dir - self.origin);
	missile.velocity = missile.velocity * grenadevelocity;
	savedz = missile.velocity_z;
	missile.velocity_z = missile.velocity_z + 0.45 * vlen(dir - self.origin);
	if (world.worldgravity != 800) missile.velocity_z = savedz + 0.05 * vlen(dir - self.origin);

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = ShalGrenadeTouch;
	
	// set missile duration
	missile.nextthink = time + 0.5 + timetotarget ;
	//missile.nextthink = time + 2.5;
	missile.think = ShalGrenadeExplode;

	setmodel (missile, "progs/v_spike.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward * 16);
	missile.skin = 1;
};

void() ShalMissile =
{
	if (self.counter > 1) 
	{
		ShalGrenade();
		return;
	}
	local	entity 	missile;
	local	vector	dir;
	local	float	dist, flytime;
	//local	float	misvelocity;

	dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	dist = vlen (self.enemy.origin - self.origin);
	flytime = (dist - 160) / 1200;//0.5;//dist * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);
	
	self.counter += 1;
	//dprint3("SHAL MISSILES - ",ftos(self.counter),"\n");
	missile = spawn ();
	missile.owner = self;
	
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setmodel (missile, "progs/v_spike.mdl");

	setsize (missile, '0 0 0', '0 0 0');		

	missile.origin = self.origin + '0 0 10';
	missile.velocity = dir * 1200;
	missile.avelocity = '300 300 300';
	missile.nextthink = time + flytime;
	missile.think = ShalHome;

	missile.enemy = self.enemy;
	missile.touch = ShalMissileTouch;
};

void() ShalHome =
{
	if (self.owner.health < 1 || self.enemy.health < 1)
	{
		self.movetype = MOVETYPE_BOUNCE;
		self.solid = SOLID_BBOX;
		self.avelocity = '300 300 300';
		self.angles = vectoangles(self.velocity);
		self.touch = ShalGrenadeTouch;
		self.nextthink = time + 0.5 + random()*0.5;
		self.think = ShalGrenadeExplode;
		self.skin = 1;
		return;
	}

	self.velocity = normalize ((self.enemy.origin + '0 0 16') - self.origin);

	if (skill == 3)
		self.velocity = self.velocity * 350;
	else self.velocity = self.velocity * 250;
	self.nextthink = time + 0.3;
	self.think = ShalHome;	
};

void() ShalMissileTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.monstertype == MT_ZOMBIE)
		T_Damage (other, self, self.owner, 110, 0, 1, 0);	
	else T_Damage (other, self, self.owner, 0, 50, 1, 0);	

	T_RadiusDamage (self, self.owner, 50, other, 160, 64);
	T_Push (other, self, self.owner, world, 320, 0, 0);

	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	
	if (self.owner.counter > 0) self.owner.counter -= 1;
	s_explode1 ();
};

//=================================================================

/*QUAKED monster_shalrath (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/
void() spawn_monster_shalrath =
{
	if (self.telefragged) 
	{
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		self.health = -500;
		shalrath_die(); // change this
		return;
	}
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	
	setmodel (self, "progs/shalrath.mdl");
	setsize (self, '-32 -32 -24', '32 32 36');
	self.health = 700;
	self.max_health = 700;
	//self.monstermass = 1; // 1 means big
	//self.tier = 3;

	self.th_stand = shal_stand;
	self.th_walk = shal_walk1;
	self.th_run = shal_run1;
	self.th_die = shalrath_die;
	self.th_pain = shalrath_pain;
	self.th_missile = shal_attack1;
	self.touch = SUB_Null;	
	self.think = walkmonster_start;
	self.nextthink = time + 0.1 + random ()*0.1;	

};

void() monster_shalrath =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	AddMonster();
	self.tier = 3;
	self.monstertype = MT_SHALRATH;
	
	if (!(self.spawnflags & (16 | 8))) 
	{
		spawn_monster_shalrath();
		return;
	}
	setsize (self, '-32 -32 -24', '32 32 36');
	self.use = triggerspawn;
};