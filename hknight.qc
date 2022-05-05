/*
==============================================================================

KNIGHT

==============================================================================
*/

$cd id1/models/knight2
$origin 0 0 24
$base base
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
$frame walk10 walk11 walk12 walk13 walk14 walk15 walk16 walk17
$frame walk18 walk19 walk20

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame pain1 pain2 pain3 pain4 pain5

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame char_a1 char_a2 char_a3 char_a4 char_a5 char_a6 char_a7 char_a8
$frame char_a9 char_a10 char_a11 char_a12 char_a13 char_a14 char_a15 char_a16

$frame magica1 magica2 magica3 magica4 magica5 magica6 magica7 magica8
$frame magica9 magica10 magica11 magica12 magica13 magica14

$frame magicb1 magicb2 magicb3 magicb4 magicb5 magicb6 magicb7 magicb8
$frame magicb9 magicb10 magicb11 magicb12 magicb13

$frame char_b1 char_b2 char_b3 char_b4 char_b5 char_b6

$frame slice1 slice2 slice3 slice4 slice5 slice6 slice7 slice8 slice9 slice10

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 smash8 smash9 smash10
$frame smash11

$frame w_attack1 w_attack2 w_attack3 w_attack4 w_attack5 w_attack6 w_attack7 
$frame w_attack8 w_attack9 w_attack10 w_attack11 w_attack12 w_attack13 w_attack14
$frame w_attack15 w_attack16 w_attack17 w_attack18 w_attack19 w_attack20 
$frame w_attack21 w_attack22 

$frame magicc1 magicc2 magicc3 magicc4 magicc5 magicc6 magicc7 magicc8
$frame magicc9 magicc10 magicc11


void() hknight_char_a1;
void() hknight_run1;
void() hk_idle_sound;

void() hknight_suck =
{
	local	vector	dir;
	local	float hkdistance;
	dir = self.enemy.origin - self.origin;
	hkdistance = vlen(dir);
	dir = normalize (dir);
	self.enemy.velocity = (self.enemy.velocity * 0) - dir * (hkdistance * 4);
	self.enemy.velocity_z = self.enemy.velocity_z + 20;
};

void() hknight_leap =
{
	if (skill == 3) 
	{
		if (self.flags & FL_ONGROUND)
		{
			makevectors (self.angles);
			//self.origin_z = self.origin_z + 1;
			if (self.enraged == 2) self.velocity = v_forward * 600 + '0 0 200';
			else self.velocity = v_forward * 320 + '0 0 270';
			if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
		}
	}
};

void(float offset) hknight_shot =
{
	//local	vector	offang;
	local	vector	org, vec, dir;
	//--
	//--
	
	//dir = (self.enemy.origin + '0 0 8') + enemvel;
	//newmis.velocity = normalize (dir - self.origin);
	
	/*offset = offset/10;
	enemvel = self.enemy.velocity * offset;
	enemvel_z = enemvel_z * 0;	
	offang = vectoangles ((self.enemy.origin + enemvel) - self.origin);*/
	
	//offang_y = offang_y + offset * 3; // def 6
	
	makevectors (self.angles);

	org = self.origin + '0 0 8' + self.mins + self.size*0.5 + v_forward * 20;

	dir = (self.enemy.origin + '0 0 -8');
	vec = normalize (dir - self.origin);
	
	launch_spike (org, vec);
	newmis.classname = "knightspike";
	setmodel (newmis, "progs/k_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	if (self.enraged) newmis.velocity = vec*1400;
	else newmis.velocity = vec*900;
	newmis.avelocity = '0 0 100';
	newmis.nextthink = time + 6;
	sound (self, CHAN_WEAPON, "hknight/attack1.wav", 1, ATTN_NORM);
};

void() CheckForCharge =
{
// check for mad charge
if (!enemy_vis)
	return;
if (time < self.attack_finished)
	return;	
if ( fabs(self.origin_z - self.enemy.origin_z) > 20)
	return;		// too much height change
if ( vlen (self.origin - self.enemy.origin) < 80)
	return;		// use regular attack

// charge		
	SUB_AttackFinished (1, 0.6, 0.4, 0.2);
	hknight_char_a1 ();

};

void() CheckContinueCharge =
{
	if (time > self.attack_finished)
	{
		SUB_AttackFinished (1, 0.6, 0.4, 0.2);
		hknight_run1 ();
		return;		// done charging
	}
	if (random() > 0.5)
		sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
};

//===========================================================================

void()	hknight_stand1	=[	$stand1,	hknight_stand2	] {ai_stand();};
void()	hknight_stand2	=[	$stand2,	hknight_stand3	] {ai_stand();};
void()	hknight_stand3	=[	$stand3,	hknight_stand4	] {ai_stand();};
void()	hknight_stand4	=[	$stand4,	hknight_stand5	] {ai_stand();};
void()	hknight_stand5	=[	$stand5,	hknight_stand6	] {ai_stand();};
void()	hknight_stand6	=[	$stand6,	hknight_stand7	] {ai_stand();};
void()	hknight_stand7	=[	$stand7,	hknight_stand8	] {ai_stand();};
void()	hknight_stand8	=[	$stand8,	hknight_stand9	] {ai_stand();};
void()	hknight_stand9	=[	$stand9,	hknight_stand1	] {ai_stand();};

//===========================================================================

void()	hknight_walk1	=[	$walk1,		hknight_walk2	] {ai_walk(2);hk_idle_sound();}; 
void()	hknight_walk2	=[	$walk2,		hknight_walk3	] {ai_walk(5);};
void()	hknight_walk3	=[	$walk3,		hknight_walk4	] {ai_walk(5);};
void()	hknight_walk4	=[	$walk4,		hknight_walk5	] {ai_walk(4);};
void()	hknight_walk5	=[	$walk5,		hknight_walk6	] {ai_walk(4);};
void()	hknight_walk6	=[	$walk6,		hknight_walk7	] {ai_walk(2);};
void()	hknight_walk7	=[	$walk7,		hknight_walk8	] {ai_walk(2);};
void()	hknight_walk8	=[	$walk8,		hknight_walk9	] {ai_walk(3);};
void()	hknight_walk9	=[	$walk9,		hknight_walk10	] {ai_walk(3);};
void()	hknight_walk10	=[	$walk10,	hknight_walk11	] {ai_walk(4);};
void()	hknight_walk11	=[	$walk11,	hknight_walk12	] {ai_walk(3);};
void()	hknight_walk12	=[	$walk12,	hknight_walk13	] {ai_walk(4);};
void()	hknight_walk13	=[	$walk13,	hknight_walk14	] {ai_walk(6);};
void()	hknight_walk14	=[	$walk14,	hknight_walk15	] {ai_walk(2);};
void()	hknight_walk15	=[	$walk15,	hknight_walk16	] {ai_walk(2);};
void()	hknight_walk16	=[	$walk16,	hknight_walk17	] {ai_walk(4);};
void()	hknight_walk17	=[	$walk17,	hknight_walk18	] {ai_walk(3);};
void()	hknight_walk18	=[	$walk18,	hknight_walk19	] {ai_walk(3);};
void()	hknight_walk19	=[	$walk19,	hknight_walk20	] {ai_walk(3);};
void()	hknight_walk20	=[	$walk20,	hknight_walk1	] {ai_walk(2);};

//===========================================================================

void()	hknight_run1	=[	$run1,		hknight_run2	] {Think(self, 0.095);ai_run (20); CheckForCharge (); hk_idle_sound();};
void()	hknight_run2	=[	$run2,		hknight_run3	] {Think(self, 0.095);ai_run(25);};
void()	hknight_run3	=[	$run3,		hknight_run4	] {Think(self, 0.095);ai_run(18);};
void()	hknight_run4	=[	$run4,		hknight_run5	] {Think(self, 0.095);ai_run(16);};
void()	hknight_run5	=[	$run5,		hknight_run6	] {Think(self, 0.095);ai_run(14);};
void()	hknight_run6	=[	$run6,		hknight_run7	] {Think(self, 0.095);ai_run(25);};
void()	hknight_run7	=[	$run7,		hknight_run8	] {Think(self, 0.095);ai_run(21);};
void()	hknight_run8	=[	$run8,		hknight_run1	] {Think(self, 0.095);ai_run(13);};

//============================================================================

void()	hknight_pain1	=[	$pain1,		hknight_pain2	] {sound (self, CHAN_VOICE, "hknight/pain1.wav", 1, ATTN_NORM);};
void()	hknight_pain2	=[	$pain2,		hknight_pain3	] {};
void()	hknight_pain3	=[	$pain3,		hknight_pain4	] {};
void()	hknight_pain4	=[	$pain4,		hknight_pain5	] {};
void()	hknight_pain5	=[	$pain5,		hknight_run1	] {};

//============================================================================

void()	hknight_die1	=[	$death1,	hknight_die2	] {ai_forward(10);};
void()	hknight_die2	=[	$death2,	hknight_die3	] {ai_forward(8);};
void()	hknight_die3	=[	$death3,	hknight_die4	] {ai_forward(7);};//self.solid = SOLID_NOT;
void()	hknight_die4	=[	$death4,	hknight_die5	] {};
void()	hknight_die5	=[	$death5,	hknight_die6	] {};
void()	hknight_die6	=[	$death6,	hknight_die7	] {};
void()	hknight_die7	=[	$death7,	hknight_die8	] {};
void()	hknight_die8	=[	$death8,	hknight_die9	] {ai_forward(10);};
void()	hknight_die9	=[	$death9,	hknight_die10	] {ai_forward(11);};
void()	hknight_die10	=[	$death10,	hknight_die11	] {};
void()	hknight_die11	=[	$death11,	hknight_die12	] {};
void()	hknight_die12	=[	$death12,	Decay	] {Think(self, 5);};

void()	hknight_dieb1	=[	$deathb1,	hknight_dieb2	] {};
void()	hknight_dieb2	=[	$deathb2,	hknight_dieb3	] {};
void()	hknight_dieb3	=[	$deathb3,	hknight_dieb4	] {};//self.solid = SOLID_NOT;
void()	hknight_dieb4	=[	$deathb4,	hknight_dieb5	] {};
void()	hknight_dieb5	=[	$deathb5,	hknight_dieb6	] {};
void()	hknight_dieb6	=[	$deathb6,	hknight_dieb7	] {};
void()	hknight_dieb7	=[	$deathb7,	hknight_dieb8	] {};
void()	hknight_dieb8	=[	$deathb8,	hknight_dieb9	] {};
void()	hknight_dieb9	=[	$deathb9,	Decay	] {Think(self, 5);};

void() hknight_die =
{
	// check for gib
	if (self.health < -80 || self.gib)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_hellkn.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		MonsterDied(self.enemy, 8, 1, self.enraged);
		return;
	}
	MonsterDied(self.enemy, 8, 0, self.enraged);
	// regular death
	sound (self, CHAN_VOICE, "hknight/death1.wav", 1, ATTN_NORM);
	self.solid = SOLID_NOT;
	if (random() > 0.5)
		hknight_die1 ();
	else
		hknight_dieb1 ();
};


//=============================== MAGIC A =============================================

void()	hknight_magica1 =[	$magica1,	hknight_magica2	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magica2 =[	$magica2,	hknight_magica3	] {ThinkE(self, 0.075); ai_face();hknight_leap();};
void()	hknight_magica3 =[	$magica3,	hknight_magica4	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magica4 =[	$magica4,	hknight_magica5	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magica5 =[	$magica5,	hknight_magica6	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magica6 =[	$magica6,	hknight_magica7	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magica7 =[	$magica7,	hknight_magica8	] {ThinkE(self, 0.075); hknight_shot(0);};
void()	hknight_magica8 =[	$magica8,	hknight_magica9	] {ThinkE(self, 0.075); };
void()	hknight_magica9 =[	$magica9,	hknight_magica10] {ThinkE(self, 0.075); hknight_shot(2);};
void()	hknight_magica10 =[	$magica10,	hknight_magica11] {ThinkE(self, 0.075); };
void()	hknight_magica11 =[	$magica11,	hknight_magica12] {ThinkE(self, 0.075); hknight_shot(4);};
void()	hknight_magica12 =[	$magica12,	hknight_magica13] {ThinkE(self, 0.075); };
void()	hknight_magica13 =[	$magica13,	hknight_magica14] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magica14 =[	$magica14,	hknight_run1	] {ThinkE(self, 0.075); ai_face();};

//================================ MAGIC B ============================================

void()	hknight_magicb1 =[	$magicb1,	hknight_magicb2	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicb2 =[	$magicb2,	hknight_magicb3	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicb3 =[	$magicb3,	hknight_magicb4	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicb4 =[	$magicb4,	hknight_magicb5	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicb5 =[	$magicb5,	hknight_magicb6	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicb6 =[	$magicb6,	hknight_magicb7	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicb7 =[	$magicb7,	hknight_magicb8	] {ThinkE(self, 0.075); hknight_shot(0);};
void()	hknight_magicb8 =[	$magicb8,	hknight_magicb9	] {ThinkE(self, 0.075); };
void()	hknight_magicb9 =[	$magicb9,	hknight_magicb10] {ThinkE(self, 0.075); hknight_shot(2);};
void()	hknight_magicb10 =[	$magicb10,	hknight_magicb11] {ThinkE(self, 0.075); };
void()	hknight_magicb11 =[	$magicb11,	hknight_magicb12] {ThinkE(self, 0.075); hknight_shot(4);};
void()	hknight_magicb12 =[	$magicb12,	hknight_magicb13] {ThinkE(self, 0.075); };
void()	hknight_magicb13 =[	$magicb13,	hknight_run1]     {ThinkE(self, 0.075); ai_face();};

//================================= MAGIC C ===========================================

void()	hknight_magicc1 =[	$magicc1,	hknight_magicc2	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicc2 =[	$magicc2,	hknight_magicc3	] {ThinkE(self, 0.075); ai_face();hknight_leap();};
void()	hknight_magicc3 =[	$magicc3,	hknight_magicc4	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicc4 =[	$magicc4,	hknight_magicc5	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicc5 =[	$magicc5,	hknight_magicc6	] {ThinkE(self, 0.075); ai_face();};
void()	hknight_magicc6 =[	$magicc6,	hknight_magicc7	] {ThinkE(self, 0.075); hknight_shot(0);};
void()	hknight_magicc7 =[	$magicc7,	hknight_magicc8	] {ThinkE(self, 0.075); };
void()	hknight_magicc8 =[	$magicc8,	hknight_magicc9	] {ThinkE(self, 0.075); hknight_shot(2);};
void()	hknight_magicc9 =[	$magicc9,	hknight_magicc10] {ThinkE(self, 0.075); };
void()	hknight_magicc10 =[	$magicc10,	hknight_magicc11] {ThinkE(self, 0.075); hknight_shot(4);};
void()	hknight_magicc11 =[	$magicc11,	hknight_run1]     {ThinkE(self, 0.075); };

//================================== CHARGE A =========================================

void()	hknight_char_a1	=[	$char_a1,	hknight_char_a2	]  {ThinkE(self, 0.075); ai_charge(20); };
void()	hknight_char_a2	=[	$char_a2,	hknight_char_a3	]  {ThinkE(self, 0.08); ai_charge(25); };
void()	hknight_char_a3	=[	$char_a3,	hknight_char_a4	]  {ThinkE(self, 0.075); ai_charge(18); };
void()	hknight_char_a4	=[	$char_a4,	hknight_char_a5	]  {ThinkE(self, 0.08); ai_charge(16); };
void()	hknight_char_a5	=[	$char_a5,	hknight_char_a6	]  {ThinkE(self, 0.075); ai_charge(14); };
void()	hknight_char_a6	=[	$char_a6,	hknight_char_a7	]  {ThinkE(self, 0.07); ai_charge(20); ai_melee(); hknight_shot(2);};
void()	hknight_char_a7	=[	$char_a7,	hknight_char_a8	]  {ThinkE(self, 0.07); ai_charge(21); ai_melee();};
void()	hknight_char_a8	=[	$char_a8,	hknight_char_a9	]  {ThinkE(self, 0.07); ai_charge(13); ai_melee();};
void()	hknight_char_a9	=[	$char_a9,	hknight_char_a10 ] {ThinkE(self, 0.07); ai_charge(20); ai_melee(); hknight_shot(2);};
void()	hknight_char_a10=[	$char_a10,	hknight_char_a11 ] {ThinkE(self, 0.07); ai_charge(20); ai_melee();};
void()	hknight_char_a11=[	$char_a11,	hknight_char_a12 ] {ThinkE(self, 0.07); ai_charge(18); ai_melee();};
void()	hknight_char_a12=[	$char_a12,	hknight_char_a13 ] {ThinkE(self, 0.075); ai_charge(16); };
void()	hknight_char_a13=[	$char_a13,	hknight_char_a14 ] {ThinkE(self, 0.08); ai_charge(14); };
void()	hknight_char_a14=[	$char_a14,	hknight_char_a15 ] {ThinkE(self, 0.075); ai_charge(25); };
void()	hknight_char_a15=[	$char_a15,	hknight_char_a16 ] {ThinkE(self, 0.08); ai_charge(21); };
void()	hknight_char_a16=[	$char_a16,	hknight_run1	]  {							 ai_charge(13);};

//=================================== CHARGE B ========================================

void()	hknight_char_b1	=[	$char_b1,	hknight_char_b2	] {ThinkE(self, 0.1);CheckContinueCharge (); ai_charge(23); ai_melee();dprint("char_b\n");};
void()	hknight_char_b2	=[	$char_b2,	hknight_char_b3	] {ThinkE(self, 0.1);ai_charge(17); ai_melee();hknight_shot(0);};
void()	hknight_char_b3	=[	$char_b3,	hknight_char_b4	] {ThinkE(self, 0.1);ai_charge(12); ai_melee();};
void()	hknight_char_b4	=[	$char_b4,	hknight_char_b5	] {ThinkE(self, 0.1);ai_charge(22); ai_melee();};
void()	hknight_char_b5	=[	$char_b5,	hknight_char_b6	] {ThinkE(self, 0.1);ai_charge(18); ai_melee();};
void()	hknight_char_b6	=[	$char_b6,	hknight_char_b1	] {ThinkE(self, 0.1);ai_charge(8);  ai_melee();};

//==================================== SLICE =======================================

void()	hknight_slice1	=[	$slice1,	hknight_slice2	] {ThinkE(self, 0.08); ai_charge(12);};
void()	hknight_slice2	=[	$slice2,	hknight_slice3	] {ThinkE(self, 0.08); ai_charge(9);};
void()	hknight_slice3	=[	$slice3,	hknight_slice4	] {ThinkE(self, 0.08); ai_charge(15);};
void()	hknight_slice4	=[	$slice4,	hknight_slice5	] {ThinkE(self, 0.08); ai_charge(8); hknight_shot(2);};
void()	hknight_slice5	=[	$slice5,	hknight_slice6	] {ThinkE(self, 0.08); ai_charge(10); ai_melee();};
void()	hknight_slice6	=[	$slice6,	hknight_slice7	] {ThinkE(self, 0.08); ai_charge(18);ai_melee();hknight_shot(2);};
void()	hknight_slice7	=[	$slice7,	hknight_slice8	] {ThinkE(self, 0.08); ai_charge(10); ai_melee();};
void()	hknight_slice8	=[	$slice8,	hknight_slice9	] {ThinkE(self, 0.08); ai_charge(6); ai_melee();hknight_shot(2);};
void()	hknight_slice9	=[	$slice9,	hknight_slice10	] {ThinkE(self, 0.08); ai_armorbreak();};
void()	hknight_slice10	=[	$slice10,	hknight_run1	] {ThinkE(self, 0.08); ai_charge(4);};

//===================================== SMASH ======================================

void()	hknight_smash1	=[	$smash1,	hknight_smash2	] {ThinkE(self, 0.075); ai_charge(1);};
void()	hknight_smash2	=[	$smash2,	hknight_smash3	] {ThinkE(self, 0.075); ai_charge(13);};
void()	hknight_smash3	=[	$smash3,	hknight_smash4	] {ThinkE(self, 0.075); ai_charge(9);};
void()	hknight_smash4	=[	$smash4,	hknight_smash5	] {ThinkE(self, 0.075); ai_charge(11);};
void()	hknight_smash5	=[	$smash5,	hknight_smash6	] {ThinkE(self, 0.075); ai_charge(10); ai_melee();};
void()	hknight_smash6	=[	$smash6,	hknight_smash7	] {ThinkE(self, 0.075); ai_charge(7);  ai_melee();};
void()	hknight_smash7	=[	$smash7,	hknight_smash8	] {ThinkE(self, 0.075); ai_charge(12); ai_melee(); hknight_shot(2);};
void()	hknight_smash8	=[	$smash8,	hknight_smash9	] {ThinkE(self, 0.075); ai_charge(2);  ai_melee();};
void()	hknight_smash9	=[	$smash9,	hknight_smash10	] {ThinkE(self, 0.075); ai_charge(3);  ai_armorbreak();};
void()	hknight_smash10	=[	$smash10,	hknight_smash11	] {ThinkE(self, 0.075); ai_charge(0);};
void()	hknight_smash11	=[	$smash11,	hknight_run1	] {ThinkE(self, 0.075); ai_charge(0);};

//===================================== ATTACK RUN =======================================

void()	hknight_watk1	=[	$w_attack1,	 hknight_watk2	] {ThinkE(self, 0.06); ai_charge(2);};
void()	hknight_watk2	=[	$w_attack2,	 hknight_watk3	] {ThinkE(self, 0.06); ai_charge(0);};
void()	hknight_watk3	=[	$w_attack3,	 hknight_watk4	] {ThinkE(self, 0.06); ai_charge(0);};
void()	hknight_watk4	=[	$w_attack4,	 hknight_watk5	] {ThinkE(self, 0.06); ai_melee();};
void()	hknight_watk5	=[	$w_attack5,	 hknight_watk6	] {ThinkE(self, 0.06); ai_melee();};
void()	hknight_watk6	=[	$w_attack6,	 hknight_watk7	] {ThinkE(self, 0.06); ai_melee(); hknight_shot(2);};
void()	hknight_watk7	=[	$w_attack7,	 hknight_watk8	] {ThinkE(self, 0.06); ai_charge(1);};
void()	hknight_watk8	=[	$w_attack8,	 hknight_watk9	] {ThinkE(self, 0.06); ai_charge(4);};
void()	hknight_watk9	=[	$w_attack9,	 hknight_watk10	] {ThinkE(self, 0.06); ai_charge(5);};
void()	hknight_watk10	=[	$w_attack10, hknight_watk11	] {ThinkE(self, 0.06); ai_charge(3); ai_melee();};
void()	hknight_watk11	=[	$w_attack11, hknight_watk12	] {ThinkE(self, 0.06); ai_charge(2); ai_melee();};
void()	hknight_watk12	=[	$w_attack12, hknight_watk13	] {ThinkE(self, 0.06); ai_charge(2); ai_melee(); hknight_shot(2);};
void()	hknight_watk13	=[	$w_attack13, hknight_watk14	] {ThinkE(self, 0.06); ai_charge(0);};
void()	hknight_watk14	=[	$w_attack14, hknight_watk15	] {ThinkE(self, 0.06); ai_charge(0);};
void()	hknight_watk15	=[	$w_attack15, hknight_watk16	] {ThinkE(self, 0.06); ai_charge(0);};
void()	hknight_watk16	=[	$w_attack16, hknight_watk17	] {ThinkE(self, 0.06); ai_charge(1);};
void()	hknight_watk17	=[	$w_attack17, hknight_watk18	] {ThinkE(self, 0.06); ai_charge(1);};
void()	hknight_watk18	=[	$w_attack18, hknight_watk19	] {ThinkE(self, 0.06); ai_charge(3); ai_melee();};
void()	hknight_watk19	=[	$w_attack19, hknight_watk20	] {ThinkE(self, 0.06); ai_charge(4); ai_melee(); hknight_shot(2);};
void()	hknight_watk20	=[	$w_attack20, hknight_watk21	] {ThinkE(self, 0.06); ai_charge(6);};
void()	hknight_watk21	=[	$w_attack21, hknight_watk22	] {ThinkE(self, 0.06); ai_charge(7);};
void()	hknight_watk22	=[	$w_attack22, hknight_run1	] {ThinkE(self, 0.06); ai_charge(3);};

//============================================================================

void() hk_idle_sound =
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "hknight/idle.wav", 1, ATTN_NORM);
};

void(entity attacker, float damage)	hknight_pain =
{
	ai_berserk(80); // berserk mode (enraged = 2), set health at which monster is go berserk
	
	if (!(self.dopain))
		return;
	
	self.dopain = 0;
	
	if (self.pain_time > time)
		return;

	sound (self, CHAN_VOICE, "hknight/pain1.wav", 1, ATTN_NORM);

	if (time - self.pain_time > 5)
	{	// allways go into pain frame if it has been a while
		hknight_pain1 ();
		self.pain_time = time + 1;
		return;
	}
	
	if ((random()*30 > damage) )
		return;		// didn't flinch

	self.pain_time = time + 1;
	hknight_pain1 ();
};

float	hknight_type;

void() hknight_melee =
{
	hknight_type = hknight_type + 1;

	sound (self, CHAN_WEAPON, "hknight/slash1.wav", 1, ATTN_NORM);
	if (hknight_type == 1)
		hknight_slice1 ();
	else if (hknight_type == 2)
		hknight_smash1 ();
	else if (hknight_type == 3)
	{
		hknight_watk1 ();
		hknight_type = 0;
	}
};

/*QUAKED monster_hell_knight (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() spawn_monster_hell_knight =
{
	if (self.telefragged) 
	{
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		self.health = -500;
		hknight_die(); // change this
		return;
	}
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/hknight.mdl");

	setsize (self, '-16 -16 -24', '16 16 36'); //40
	self.health = 250;
	self.max_health = 250;
	self.armorplates = 3;

	self.th_stand = hknight_stand1;
	self.th_walk = hknight_walk1;
	self.th_run = hknight_run1;
	self.th_melee = hknight_melee;
	
	self.th_missile = hknight_magicc1;

	self.th_pain = hknight_pain;
	self.th_die = hknight_die;
	self.touch = SUB_Null;	
	//self.tier = 2;
	
	walkmonster_start ();
};

void() monster_hell_knight =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	AddMonster();
	self.tier = 2;
	self.monstertype = MT_HELLKNIGHT;
	
	if (!(self.spawnflags & (16 | 8))) 
	{
		spawn_monster_hell_knight();
		return;
	}
	setsize (self, '-16 -16 -24', '16 16 36'); //40
	self.use = triggerspawn;
};
/*
	hknight_type = hknight_type + 1;
	if 		(hknight_type == 1)	self.th_missile = hknight_magicc1;
	else if (hknight_type == 2)	self.th_missile = hknight_magicb1;
	else if (hknight_type == 3)
	{
		self.th_missile = hknight_magica1;
		hknight_type = 0;
	}*/