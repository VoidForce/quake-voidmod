#define SHAMBLER_LOWHEALTH 300
#define SHAMBLER_HEALTH 1000
/*
==============================================================================

SHAMBLER

==============================================================================
*/

$cd id1/models/shams
$origin 0 0 24
$base base		
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 
$frame walk8 walk9 walk10 walk11 walk12

$frame	run1 run2 run3 run4 run5 run6

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 
$frame smash8 smash9 smash10 smash11 smash12

$frame swingr1 swingr2 swingr3 swingr4 swingr5 
$frame swingr6 swingr7 swingr8 swingr9

$frame swingl1 swingl2 swingl3 swingl4 swingl5 
$frame swingl6 swingl7 swingl8 swingl9

$frame magic1 magic2 magic3 magic4 magic5 
$frame magic6 magic7 magic8 magic9 magic10 magic11 magic12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 
$frame death7 death8 death9 death10 death11

void() sham_magic1;
/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	//local entity		e1, e2;
	local vector		f;
	//local float penflag;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	//e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		//if (damage < 16) penflag = 1;
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage, 0, 0, 0);
	}
};

void() sham_stand1	=[	$stand1,  sham_stand2  ] {ai_stand();Think(self, 0.1);};
void() sham_stand2	=[	$stand2,  sham_stand3  ] {ai_stand();Think(self, 0.1);};
void() sham_stand3	=[	$stand3,  sham_stand4  ] {ai_stand();Think(self, 0.1);};
void() sham_stand4	=[	$stand4,  sham_stand5  ] {ai_stand();Think(self, 0.1);};
void() sham_stand5	=[	$stand5,  sham_stand6  ] {ai_stand();Think(self, 0.1);};
void() sham_stand6	=[	$stand6,  sham_stand7  ] {ai_stand();Think(self, 0.1);};
void() sham_stand7	=[	$stand7,  sham_stand8  ] {ai_stand();Think(self, 0.1);};
void() sham_stand8	=[	$stand8,  sham_stand9  ] {ai_stand();Think(self, 0.1);};
void() sham_stand9	=[	$stand9,  sham_stand10 ] {ai_stand();Think(self, 0.1);};
void() sham_stand10	=[	$stand10, sham_stand11 ] {ai_stand();Think(self, 0.1);};
void() sham_stand11	=[	$stand11, sham_stand12 ] {ai_stand();Think(self, 0.1);};
void() sham_stand12	=[	$stand12, sham_stand13 ] {ai_stand();Think(self, 0.1);};
void() sham_stand13	=[	$stand13, sham_stand14 ] {ai_stand();Think(self, 0.1);};
void() sham_stand14	=[	$stand14, sham_stand15 ] {ai_stand();Think(self, 0.1);};
void() sham_stand15	=[	$stand15, sham_stand16 ] {ai_stand();Think(self, 0.1);};
void() sham_stand16	=[	$stand16, sham_stand17 ] {ai_stand();Think(self, 0.1);};
void() sham_stand17	=[	$stand17, sham_stand1  ] {ai_stand();Think(self, 0.1);};

void() sham_walk1  =[ $walk1,  sham_walk2 ] {ai_walk(10);Think(self, 0.1);};
void() sham_walk2  =[ $walk2,  sham_walk3 ] {ai_walk(9); Think(self, 0.1);};
void() sham_walk3  =[ $walk3,  sham_walk4 ] {ai_walk(9); Think(self, 0.1);};
void() sham_walk4  =[ $walk4,  sham_walk5 ] {ai_walk(5); Think(self, 0.1);};
void() sham_walk5  =[ $walk5,  sham_walk6 ] {ai_walk(6); Think(self, 0.1);};
void() sham_walk6  =[ $walk6,  sham_walk7 ] {ai_walk(12);Think(self, 0.1);};
void() sham_walk7  =[ $walk7,  sham_walk8 ] {ai_walk(8); Think(self, 0.1);};
void() sham_walk8  =[ $walk8,  sham_walk9 ] {ai_walk(3); Think(self, 0.1);};
void() sham_walk9  =[ $walk9,  sham_walk10] {ai_walk(13);Think(self, 0.1);};
void() sham_walk10 =[ $walk10, sham_walk11] {ai_walk(9); Think(self, 0.1);};
void() sham_walk11 =[ $walk11, sham_walk12] {ai_walk(7); Think(self, 0.1);};
void() sham_walk12 =[ $walk12, sham_walk1 ] {ai_walk(7); Think(self, 0.1);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);};

void() sham_run1 =[ $run1, sham_run2 ] {ai_run(20);Think(self, 0.07);};
void() sham_run2 =[ $run2, sham_run3 ] {ai_run(24);Think(self, 0.07);};
void() sham_run3 =[ $run3, sham_run4 ] {ai_run(20);Think(self, 0.07);};
void() sham_run4 =[ $run4, sham_run5 ] {ai_run(20);Think(self, 0.07);};
void() sham_run5 =[ $run5, sham_run6 ] {ai_run(24);Think(self, 0.07);};
void() sham_run6 =[ $run6, sham_run1 ] {ai_run(20);Think(self, 0.07);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);
};
/*
===========
//--------------------------------------------------------------------------------------------------
//														CHECK ATTACK
//--------------------------------------------------------------------------------------------------

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() ShamCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
//	local float		chance;
//	local float		enemy_yaw;
	
	if (time < self.attack_finished)
		return FALSE;
	
	if (!enemy_vis)
		return FALSE;

	if (enemy_range == RANGE_MELEE)	// very close
	{
		if (CanDamage (self.enemy, self))
		{
			self.mu_leap = 1;
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}	
	
	if (skill > 1)
	{
		if ((enemy_range == RANGE_MID || enemy_range == RANGE_NEAR) && self.mt_cast > time) // far and cast is not ready 
		{
			if (CanDamage (self.enemy, self))
			{
				self.mu_leap = 2;
				self.attack_state = AS_MELEE;
				return TRUE;
			}
		}	
	}

	targ = self.enemy;
	
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	if (vlen(spot1 - spot2) > 600)
		return FALSE;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	/*if (trace_ent != targ)
	{
		return FALSE;	// don't have a clear shot
	}*/
			
// missile attack
	if (enemy_range == RANGE_FAR)
		return FALSE;
	
	if (self.mt_cast > time)
		return FALSE;
	
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (3, 1.2, 0.8, 0.4);
	return TRUE;
};

//--------------------------------------------------------------------------------------------------
//														TOUCH
//--------------------------------------------------------------------------------------------------

void()	Sham_JumpTouch =
{
	if (self.health <= 0)
		return;

	if (other.takedamage && other.monstertype != P_PLAYER && other.monstertype != MT_SHAMBLER)
		T_Damage (other, self, self, 600, 0, 1, 0);	
	
	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	
			self.touch = SUB_Null;
			self.think = sham_magic1;//sham_smash1;
			Think(self, 0.1);
		}
		return;	// not on ground yet
	}
};

//--------------------------------------------------------------------------------------------------
//														MELEE ATTACK
//--------------------------------------------------------------------------------------------------
void() sham_pushback =
{
	if (skill < 2)
		return;

	local float pushforce;
	
	if (self.mut_ssgrefire > 0 )
	{
		if ( self.enemy.health > 0 )
		{
			pushforce = 400 + (self.mut_ssgrefire*100);
			if (pushforce > 800)
				pushforce = 800;
			T_Push (self.enemy, self, self, world, pushforce, pushforce/4, 0);
		}
	}
};
void(float side) ShamClaw =
{
	// melee damage
	local vector	delta;
	local float 	ldmg;


	if (!self.enemy)
		return;
	ai_charge(10);
	
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
		
	//ldmg = (random() + random() + random()) * 10;
	ldmg = 30+random()*5;
	T_Damage (self.enemy, self, self, ldmg, 5, 1, 0);
	sham_pushback();	
	
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	if (side)
	{
		makevectors (self.angles);
		SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
	}
};

//--------------------------------------------------------------------------------------------------
//														JUMP
//--------------------------------------------------------------------------------------------------
void (float value)shambler_charge =
{
	if (self.mu_leap == 1)
		ai_charge(value);
};
void(float type) Sham_DoJump =
{
//0 - smash
//1 - right
//2 - left

	local float forward,side;
	local vector jump;

	if (skill < 2) 
		return;
	
//	if (self.mt_smash > time && !(type)) 
//		return;
		
	if (self.mu_leap == 1) //close
	{
		forward = 250;
		side = 0;
		jump = '0 0 90';
	}
	else if (self.mu_leap == 2) //far
	{
		if (type == 0) //smash
		{
			forward = 350;
			side = 0;
			jump = '0 0 300';
		}
		else
		{	
			if (self.enraged == 1)
				forward = 1200;
			else if (self.enraged == 2)
				forward = 1600;
			else forward = 300;
			
			side = 50;
			if (type == 2) side *= -1;
			jump = '0 0 200';
		}
	}
	else // eh delete me?
	{
		forward = 0;
		side = 0;
		jump = '0 0 0';
	}
	
	if (!(self.flags & FL_ONGROUND))
		jump = '0 0 0';
	
	self.touch = Sham_JumpTouch;
	makevectors(self.angles);
	
//do the jump
	self.velocity = (v_forward * forward) + (v_right * side) + jump;
	
	if (self.flags & FL_ONGROUND)
	self.flags = self.flags - FL_ONGROUND;

	self.mu_leap = 0;
};

//--------------------------------------------------------------------------------------------------
//														SMASH
//--------------------------------------------------------------------------------------------------

void() sham_smash1 =[ $smash1, sham_smash2    ] 
{
	sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	shambler_charge(2);
	ThinkE(self, 0.06);
};

void() sham_smash2 =[ $smash2,  sham_smash3 ] {shambler_charge(6);ThinkE(self, 0.06);};
void() sham_smash3 =[ $smash3,  sham_smash4 ] {shambler_charge(6);ThinkE(self, 0.06);};
void() sham_smash4 =[ $smash4,  sham_smash5 ] {shambler_charge(5);ThinkE(self, 0.06);};
void() sham_smash5 =[ $smash9,  sham_smash6 ] {shambler_charge(2);ThinkE(self, 0.05);Sham_DoJump(0);};
void() sham_smash6 =[ $smash10, sham_smash7 ] 
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;
	shambler_charge(2);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;
		
	//ldmg = (random() + random() + random()) * 10;
	ldmg = 30+random()*5;
	T_Damage (self.enemy, self, self, ldmg, 10, 1, 0);
	sham_pushback();
	
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward * 16, crandom() * 100 * v_right);
	SpawnMeatSpray (self.origin + v_forward * 16, crandom() * 100 * v_right);
	ThinkE(self, 0.06);
};

void() sham_smash7 =[ $smash11, sham_smash8 ] {shambler_charge(5);ThinkE(self, 0.06); };
void() sham_smash8 =[ $smash12, sham_run1   ] {shambler_charge(4);ThinkE(self, 0.06); };

//--------------------------------------------------------------------------------------------------
//														SWING Left
//--------------------------------------------------------------------------------------------------
void() sham_swingr1; // used in swingl9
void() sham_swingl1	=[      $swingl1,      sham_swingl2   ] 
{
	sound (self, CHAN_VOICE, "shambler/melee2.wav", 1, ATTN_NORM);
	shambler_charge(5);
	ThinkE(self, 0.08);
};

void() sham_swingl2 =[ $swingl2, sham_swingl3 ] {shambler_charge(3);ThinkE(self, 0.08);};
void() sham_swingl3 =[ $swingl3, sham_swingl4 ] {shambler_charge(7);ThinkE(self, 0.08);};
void() sham_swingl4 =[ $swingl4, sham_swingl5 ] {shambler_charge(3);ThinkE(self, 0.08);Sham_DoJump(2);};
void() sham_swingl5 =[ $swingl5, sham_swingl6 ] {shambler_charge(7);ThinkE(self, 0.08);};
void() sham_swingl6 =[ $swingl6, sham_swingl7 ] {shambler_charge(9);ThinkE(self, 0.08);};
void() sham_swingl7 =[ $swingl7, sham_swingl8 ] {shambler_charge(5);ThinkE(self, 0.08);ShamClaw(250);};
void() sham_swingl8 =[ $swingl8, sham_swingl9 ] {shambler_charge(4);ThinkE(self, 0.08);};
void() sham_swingl9 =[ $swingl9, sham_run1    ]	{shambler_charge(8);ThinkE(self, 0.08);};

//--------------------------------------------------------------------------------------------------
//														SWING Right
//--------------------------------------------------------------------------------------------------

void() sham_swingr1	=[      $swingr1,      sham_swingr2   ] 
{
	sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	shambler_charge(1);
	ThinkE(self, 0.08);
};

void() sham_swingr2	=[ $swingr2, sham_swingr3 ] {shambler_charge(8); ThinkE(self, 0.08);};
void() sham_swingr3 =[ $swingr3, sham_swingr4 ] {shambler_charge(14);ThinkE(self, 0.08);};
void() sham_swingr4 =[ $swingr4, sham_swingr5 ] {shambler_charge(7); ThinkE(self, 0.06);Sham_DoJump(1);};
void() sham_swingr5 =[ $swingr5, sham_swingr6 ] {shambler_charge(3); ThinkE(self, 0.08);};
void() sham_swingr6 =[ $swingr6, sham_swingr7 ] {shambler_charge(6); ThinkE(self, 0.08);};
void() sham_swingr7 =[ $swingr7, sham_swingr8 ] {shambler_charge(6); ThinkE(self, 0.08);ShamClaw(-250);};
void() sham_swingr8 =[ $swingr8, sham_swingr9 ] {shambler_charge(3); ThinkE(self, 0.08);};
void() sham_swingr9 =[ $swingr9, sham_run1    ] {shambler_charge(10);ThinkE(self, 0.08);};

//--------------------------------------------------------------------------------------------------
//														MELEE LOGIC
//--------------------------------------------------------------------------------------------------
void() sham_melee =
{
	local float chance;

	chance = random();
	
	if (self.mu_leap == 2) // too far for smash
	{
		if (self.flags & FL_ONGROUND)
		{
			sham_smash1 ();
			return;
		}
		else
		{
			if (chance > 0.5)
				sham_swingr1 ();
			else sham_swingl1 ();
			return;
		}
	}
	
	if (chance > 0.5 )
		sham_smash1 ();
	else if (chance > 0.25)
		sham_swingr1 ();
	else sham_swingl1 ();
};

//--------------------------------------------------------------------------------------------------
//														CAST Lightning
//--------------------------------------------------------------------------------------------------

void(float attackdamage) CastLightning =
{
	local	vector	org, dir;
	
	if (self.enraged !=2 ) 
		attackdamage *= 0.5;
	self.effects = self.effects | EF_MUZZLEFLASH;

	ai_face ();

	org = self.origin + '0 0 40';

	dir = self.enemy.origin + '0 0 16' - org;
	dir = normalize (dir);

	traceline (org, self.origin + dir*900, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING1);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	
	LightningDamage (org, trace_endpos, self, attackdamage);
	
	if (self.health < 300)	
	{
		if ( self.enemy.health > 0 )
			T_Push (self.enemy, self, self, world, 400, 100, 0);
		return;
	}
	
	if (self.enraged )
	{
		if ( self.enemy.health > 0 && self.mt_push < time)
			T_Push (self.enemy, self, self, world, -400, 100, 0);
	}
	
};

//--------------------------------------------------------------------------------------------------
//														MAGIC
//--------------------------------------------------------------------------------------------------

void() sham_magic1 =[$magic1, sham_magic2] {ai_face(); sound(self, CHAN_WEAPON, "shambler/sattck1.wav", 1, ATTN_NORM); ThinkE(self, 0.08); };
void() sham_magic2 =[$magic2, sham_magic3] {ai_face(); Think(self, 0.06); };
void() sham_magic3 =[$magic3, sham_magic4] {ai_face();
	local entity o;

	self.effects = self.effects | EF_MUZZLEFLASH;
	ai_face();
	self.owner = spawn();
	o = self.owner;
	setmodel (o, "progs/s_light.mdl");
	setorigin (o, self.origin);
	o.angles = self.angles;
	o.nextthink = time + 0.7;
	o.think = SUB_Remove;
	ThinkE(self, 0.08);
};

void() sham_magic4     =[      $magic4,       sham_magic5    ]
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	self.owner.frame = 1;
	ThinkE(self, 0.08);
};

void() sham_magic5     =[      $magic5,       sham_magic6    ]
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	self.owner.frame = 2;
	ThinkE(self, 0.08);
};

void() sham_magic6     =[      $magic6,       sham_magic9    ]
{
	remove (self.owner);
	CastLightning(4);
	sound (self, CHAN_WEAPON, "shambler/sboom.wav", 1, ATTN_NORM);
	ThinkE(self, 0.08);
};

void() sham_magic9     =[      $magic9,       sham_magic10   ]
{
	CastLightning(8);
	ThinkE(self, 0.08);
};

void() sham_magic10    =[      $magic10,      sham_magic11   ]
{
	CastLightning(16);
	ThinkE(self, 0.08);
};

void() sham_magic11    =[      $magic11,      sham_magic12   ]
{
	CastLightning(32);
	if (self.mt_push < time)
		self.mt_push = time + 5;
	if (self.mt_cast < time)
		self.mt_cast = time + 2;
	ThinkE(self, 0.08);
};

void() sham_magic12    =[      $magic12,      sham_run1	   ] {ThinkE(self, 0.08);};

//--------------------------------------------------------------------------------------------------
//														PAIN
//--------------------------------------------------------------------------------------------------

void() sham_pain1 =[$pain1, sham_pain2] {ThinkE(self, 0.1);};
void() sham_pain2 =[$pain2, sham_pain3] {ThinkE(self, 0.1);};
void() sham_pain3 =[$pain3, sham_pain4] {ThinkE(self, 0.1);};
void() sham_pain4 =[$pain4, sham_pain5] {ThinkE(self, 0.1);};
void() sham_pain5 =[$pain5, sham_pain6] {ThinkE(self, 0.1);};
void() sham_pain6 =[$pain6, sham_run1 ] {ThinkE(self, 0.1);};

void(entity attacker, float damage)	sham_pain =
{
	if (self.health <= 0)
		return;		// allready dying, don't go into pain frame
	
	ai_berserk(300); // berserk mode (enraged = 2), set health at which monster is go berserk
	
	if (!(self.dopain))
		return;
	
	self.dopain = 0;
	
	if (self.pain_time > time)
		return;
	self.pain_time = time + 2;
	
	sound (self, CHAN_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);

	//sham_pain1 ();
};

//--------------------------------------------------------------------------------------------------
//														DEATH
//--------------------------------------------------------------------------------------------------

void() sham_death1  =[ $death1,  sham_death2 ] {};
void() sham_death2  =[ $death2,  sham_death3 ] {};
void() sham_death3  =[ $death3,  sham_death4 ] {};
void() sham_death4  =[ $death4,  sham_death5 ] {};
void() sham_death5  =[ $death5,  sham_death6 ] {};
void() sham_death6  =[ $death6,  sham_death7 ] {};
void() sham_death7  =[ $death7,  sham_death8 ] {};
void() sham_death8  =[ $death8,  sham_death9 ] {};
void() sham_death9  =[ $death9,  sham_death10] {};
void() sham_death10 =[ $death10, sham_death11] {};
void() sham_death11 =[ $death11, Decay    ] {Think(self, 5);};

void() sham_die =
{
	// check for gib
	if (self.health < -90 || self.gib)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_shams.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		MonsterDied(self.enemy, 10, 1, self.enraged);
		return;
	}
	// regular death
	MonsterDied(self.enemy, 10, 0, self.enraged);
	sound (self, CHAN_VOICE, "shambler/sdeath.wav", 1, ATTN_NORM);
	self.solid = SOLID_NOT;
	sham_death1 ();
};

//============================================================================


/*QUAKED monster_shambler (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/
void() spawn_monster_shambler =
{
	if (self.telefragged) 
	{
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		self.health = -500;
		sham_die(); // change this
		return;
	}

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, "progs/shambler.mdl");

	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = SHAMBLER_HEALTH;
	self.max_health = SHAMBLER_HEALTH;
	self.armorplates = 10;
	self.th_stand = sham_stand1;
	self.th_walk = sham_walk1;
	self.th_run = sham_run1;
	self.th_die = sham_die;
	self.th_melee = sham_melee;
	self.th_missile = sham_magic1;
	self.th_pain = sham_pain;
	self.touch = SUB_Null;	
	//self.monstermass = 1; // 1 means big
	//self.tier = 3;
	walkmonster_start();
};

void() monster_shambler =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	AddMonster();
	self.tier = 3;
	self.monstertype = MT_SHAMBLER;
	
	if (!(self.spawnflags & (16 | 8))) 
	{
		spawn_monster_shambler();
		return;
	}
	setsize (self, VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.use = triggerspawn;
};