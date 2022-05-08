
/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

//
// system globals
//
entity		self;
entity		other;
entity		world;
float		time;
float		frametime;

float		force_retouch;		// force all entities to touch triggers
								// next frame.  this is needed because
								// non-moving things don't normally scan
								// for triggers, and when a trigger is
								// created (like a teleport trigger), it
								// needs to catch everything.
								// decremented each frame, so set to 2
								// to guarantee everything is touched
string		mapname;

float		deathmatch;
float		coop;
float		teamplay;

float		serverflags;		// propagated from level to level, used to
								// keep track of completed episodes

float		total_secrets;
float		total_monsters;

float		found_secrets;		// number of secrets found
float		killed_monsters;	// number of monsters killed


// spawnparms are used to encode information about clients across server
// level changes
float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//	
vector		v_forward, v_up, v_right;	// set by makevectors()
	
// set by traceline / tracebox
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector		trace_endpos;
vector		trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen;
float		trace_inwater;

entity		msg_entity;				// destination of single entity writes

//
// required prog functions
//
void() 		main;						// only for testing

void()		StartFrame;

void() 		PlayerPreThink;
void() 		PlayerPostThink;

void()		ClientKill;
void()		ClientConnect;
void() 		PutClientInServer;		// call after setting the parm1... parms
void()		ClientDisconnect;

void()		SetNewParms;			// called when a client first connects to
									// a server. sets parms so they can be
									// saved off for restarts

void()		SetChangeParms;			// call to set parms for self so they can
									// be saved for a level transition


//================================================
void		end_sys_globals;		// flag for structure dumping
//================================================

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float		modelindex;		// *** model index in the precached list
.vector		absmin, absmax;	// *** origin + mins / maxs

.float		ltime;			// local time for entity
.float		movetype;
.float		solid;

.vector		origin;			// ***
.vector		oldorigin;		// ***
.vector		velocity;
.vector		angles;
.vector		avelocity;

.vector		punchangle;		// temp angle adjust from damage or recoil

.string		classname;		// spawn function
.string		model;
.float		frame;
.float		skin;
.float		effects;

.vector		mins, maxs;		// bounding box extents reletive to origin
.vector		size;			// maxs - mins

.void()		touch;
.void()		use;
.void()		think;
.void()		blocked;		// for doors or plats, called when can't push other

.float		nextthink;
.entity		groundentity;

// stats
.float		health;
.float		frags;
.float		weapon;			// one of the IT_SHOTGUN, etc flags
.string		weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;

.float		items;			// bit flags

.float		takedamage;
.entity		chain;
.float		deadflag;

.vector		view_ofs;			// add to origin to get eye point


.float		button0;		// fire
.float		button1;		// use
.float		button2;		// jump

.float		impulse;		// weapon changes

.float		fixangle;
.vector		v_angle;		// view / targeting angle for players
.float		idealpitch;		// calculated pitch angle for lookup up slopes


.string		netname;

.entity 	enemy;

.float		flags;

.float		colormap;
.float		team;

.float		max_health;		// players maximum health is stored here

.float		teleport_time;	// don't back up

.float		armortype;		// save this fraction of incoming damage
.float		armorvalue;

.float		waterlevel;		// 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float		watertype;		// a contents value

.float		ideal_yaw;
.float		yaw_speed;

.entity		aiment;

.entity 	goalentity;		// a movetarget or an enemy

.float		spawnflags;

.string		target;
.string		targetname;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;

.entity		owner;		// who launched a missile
.vector		movedir;	// mostly for doors, but also used for waterjump

.string		message;		// trigger messages

.float		sounds;		// either a cd track number or sound number

.string		noise, noise1, noise2, noise3;	// contains names of wavs to play

//================================================
void		end_sys_fields;			// flag for structure dumping
//================================================

/*
==============================================================================

				VARS NOT REFERENCED BY C CODE

==============================================================================
*/


//
// constants
//

float	FALSE					= 0;
float 	TRUE					= 1;

// edict.flags
float	FL_FLY					= 1;
float	FL_SWIM					= 2;
float	FL_CLIENT				= 8;	// set for all client edicts
float	FL_INWATER				= 16;	// for enter / leave water splash
float	FL_MONSTER				= 32;
float	FL_GODMODE				= 64;	// player cheat
float	FL_NOTARGET				= 128;	// player cheat
float	FL_ITEM					= 256;	// extra wide size for bonus items
float	FL_ONGROUND				= 512;	// standing on something
float	FL_PARTIALGROUND		= 1024;	// not all corners are valid
float	FL_WATERJUMP			= 2048;	// player jumping out of water
float	FL_JUMPRELEASED			= 4096;	// for jump debouncing

// edict.movetype values
float	MOVETYPE_NONE			= 0;	// never moves
//float	MOVETYPE_ANGLENOCLIP	= 1;
//float	MOVETYPE_ANGLECLIP		= 2;
float	MOVETYPE_WALK			= 3;	// players only
float	MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;	// gravity
float	MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
float	MOVETYPE_BOUNCE			= 10;
float	MOVETYPE_BOUNCEMISSILE	= 11;	// bounce with extra size

// edict.solid values
float	SOLID_NOT				= 0;	// no interaction with other objects
float	SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
float	SOLID_BBOX				= 2;	// touch on edge, block
float	SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
float	SOLID_BSP				= 4;	// bsp clip, touch on edge, block

// range values
float	RANGE_MELEE				= 0;
float	RANGE_NEAR				= 1;
float	RANGE_MID				= 2;
float	RANGE_FAR				= 3;
float	RANGE_SNIPER			= 4;

// deadflag values

float	DEAD_NO					= 0;
float	DEAD_DYING				= 1;
float	DEAD_DEAD				= 2;
float	DEAD_RESPAWNABLE		= 3;

// takedamage values

float	DAMAGE_NO				= 0;
float	DAMAGE_YES				= 1;
float	DAMAGE_AIM				= 2;

// items
float	IT_AXE					= 4096;
float	IT_SHOTGUN				= 1;
float	IT_SUPER_SHOTGUN		= 2;
float	IT_NAILGUN				= 4;
float	IT_SUPER_NAILGUN		= 8;
float	IT_GRENADE_LAUNCHER		= 16;
float	IT_ROCKET_LAUNCHER		= 32;
float	IT_LIGHTNING			= 64;
float	IT_RIFLE				= 128;
float 	ALL_WEAPONS				= 127;

float	IT_SHELLS				= 256;
float	IT_NAILS				= 512;
float	IT_ROCKETS				= 1024;
float	IT_CELLS				= 2048;

float	IT_ARMOR1				= 8192;
float	IT_ARMOR2				= 16384;
float	IT_ARMOR3				= 32768;
float	IT_SUPERHEALTH			= 65536;

float	IT_KEY1					= 131072;
float	IT_KEY2					= 262144;

float	IT_INVISIBILITY			= 524288;
float	IT_INVULNERABILITY		= 1048576;
float	IT_SUIT					= 2097152;
float	IT_QUAD					= 4194304;

// point content values

float	CONTENT_EMPTY			= -1;
float	CONTENT_SOLID			= -2;
float	CONTENT_WATER			= -3;
float	CONTENT_SLIME			= -4;
float	CONTENT_LAVA			= -5;
float	CONTENT_SKY				= -6;

float	STATE_TOP		= 0;
float	STATE_BOTTOM	= 1;
float	STATE_UP		= 2;
float	STATE_DOWN		= 3;

vector	VEC_ORIGIN = '0 0 0';
vector	VEC_HULL_MIN = '-16 -16 -24';
vector	VEC_HULL_MAX = '16 16 32';

vector	VEC_HULL2_MIN = '-32 -32 -24';
vector	VEC_HULL2_MAX = '32 32 64';

// Constants from copper mod by Lunaran
// protocol bytes
float	SVC_UPDATESTAT		= 3;
float	SVC_SETVIEW			= 5;
float	SVC_TEMPENTITY		= 23;
float	SVC_CENTERPRINT		= 26;
float	SVC_KILLEDMONSTER	= 27;
float	SVC_FOUNDSECRET		= 28;
float	SVC_INTERMISSION	= 30;
float	SVC_FINALE			= 31;
float	SVC_CDTRACK			= 32;
float	SVC_SELLSCREEN		= 33;
float	SVC_CUTSCENE		= 34;
float	SVC_FOG				= 41;	// in fitzquake, byte byte byte byte short for density r g b lerptime

// svc updatestat byte types
float	STAT_HEALTH			= 0;
float	STAT_FRAGS			= 1;
float	STAT_WEAPON			= 2;
float	STAT_AMMO			= 3;
float	STAT_ARMOR			= 4;
float	STAT_WEAPONFRAME	= 5;
float	STAT_SHELLS			= 6;
float	STAT_NAILS			= 7;
float	STAT_ROCKETS		= 8;
float	STAT_CELLS			= 9;
float	STAT_ACTIVEWEAPON	= 10;
float	STAT_TOTALSECRETS	= 11;	// hmmm ...
float	STAT_TOTALMONSTERS	= 12;	// must send this if new monsters are spawned after the map starts
float	STAT_SECRETS		= 13;	// bumped on client side by svc_foundsecret
float	STAT_MONSTERS		= 14;	// bumped by svc_killedmonster

float	TE_SPIKE		= 0;
float	TE_SUPERSPIKE	= 1;
float	TE_GUNSHOT		= 2;
float	TE_EXPLOSION	= 3;
float	TE_TAREXPLOSION	= 4;
float	TE_LIGHTNING1	= 5;
float	TE_LIGHTNING2	= 6;
float	TE_WIZSPIKE		= 7;
float	TE_KNIGHTSPIKE	= 8;
float	TE_LIGHTNING3	= 9;
float	TE_LAVASPLASH	= 10;
float	TE_TELEPORT		= 11;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float	CHAN_AUTO		= 0;
float	CHAN_WEAPON		= 1;
float	CHAN_VOICE		= 2;
float	CHAN_ITEM		= 3;
float	CHAN_BODY		= 4;

float	ATTN_NONE		= 0;
float	ATTN_NORM		= 1;
float	ATTN_IDLE		= 2;
float	ATTN_STATIC		= 3;

// update types

float	UPDATE_GENERAL	= 0;
float	UPDATE_STATIC	= 1;
float	UPDATE_BINARY	= 2;
float	UPDATE_TEMP		= 3;

// entity effects

float	EF_BRIGHTFIELD	= 1;
float	EF_MUZZLEFLASH 	= 2;
float	EF_BRIGHTLIGHT 	= 4;
float	EF_DIMLIGHT 	= 8;


// messages
float	MSG_BROADCAST	= 0;		// unreliable to all
float	MSG_ONE			= 1;		// reliable to one (msg_entity)
float	MSG_ALL			= 2;		// reliable to all
float	MSG_INIT		= 3;		// write to the init string


// Monster types (float monstertype)
float P_PLAYER	 	   = 255;
float MT_SOLDIER 	   = 1;
float MT_DOG           = 2;
float MT_ENFORCER      = 3;
float MT_KNIGHT        = 4;
float MT_SCRAG         = 5;
float MT_OGRE          = 6;
float MT_FIEND         = 7;
float MT_HELLKNIGHT    = 8;
float MT_SHALRATH      = 9;
float MT_SHAMBLER      = 10;
float MT_SPAWN         = 11;
float MT_ROTFISH       = 12;
float MT_ZOMBIE        = 13;
float MISC_ROCKET	   = 100;
//================================================

//
// globals
//
float	movedist;
float	gameover;		// set when a rule exits

string	string_null;	// null string, nothing should be held here
//float	empty_float;

entity	newmis;			// launch_spike sets this after spawning it

entity	activator;		// the entity that activated a trigger or brush

entity	damage_attacker;	// set by T_Damage
float	framecount;

float		skill;

nosave float	gamestarted; // Lunaran's copper code of vcshift cleanup;
nosave float	cleanUpClientShit;

//================================================

//
// world fields (FIXME: make globals)
//
.string		wad;
.string 	map;
.float		worldtype;	// 0=medieval 1=metal 2=base
.float		worldgravity;
.float		entitygravity;
.float		alpha;
//================================================

//additional think layer for entities
entity searchresult;
.string hascustomthink;// "1" - use this to mark entities for customthinks
.float customthink1_time;
.void() customthink1;
//.float customthink2_time;
//.void() customthink2;
//

.string		killtarget;
.string		target2; // copper 
.string		target3;
.string		target4;
//
// quakeed fields
//
.float		light_lev;		// not used by game, but parsed by light util
.float		style;

//////////////////////////////
.float 		vmflags; // we use this for any boolean stuff we might need 

//CONSTANTS
// items
float	VMF_ITEM_FIRED = 1; // make sure that our entity fires it's targets only once
// player
float	VMF_PLAYER_INSEQUENCE = 1; // Do not interrupt me when i'm doing sequenced animation
// monsters


//
// monster ai
//
.void()		th_stand;
.void()		th_walk;
.void()		th_run;
.void()		th_missile;
.void()		th_melee;
.void(entity attacker, float damage)		th_pain;
.void()		th_die;

.entity		oldenemy;		// mad at this player before taking damage

.float		speed;

.float	lefty;

.float	search_time;
.float	attack_state;
//.float	additional_damage;

float	AS_STRAIGHT		= 1;
float	AS_SLIDING		= 2;
float	AS_MELEE		= 3;
float	AS_MISSILE		= 4;

//
// player only fields
//

.float		pentagram_flash, pentagram_sound;
.float		ring_flash, ring_sound;
.float		quad_flash, quad_sound;
.float		biosuit_flash;
.float		fly_sound;

.float		show_hostile;	// set to time+0.2 whenever a client fires a
							// weapon or takes damage.  Used to alert
							// monsters that otherwise would let the player go
.float		jump_flag;		// player jump flag
.float		swim_flag;		// player swimming sound flag
.float		air_time;	// when time > air_time, start drowning
.float		bubble_count;	// keeps track of the number of bubbles
.string		deathtype;		// keeps track of how the player died
.float		axhitme;

.float		walkframe;
.float		stopattack;
.float		stopattack_time;
.float 		attack_finished;
.float		pain_time;

//timers
.float		pentagram_time; // when bonus will end
.float		ring_time;
.float		quad_time;
.float		biosuit_time; 

.float		void_time; // void bonus
.float 		weaponchange_time; // when we can switch out from our weapon after fire
.float      remove_time; // projectiles may use think function for something, we need to count some second after shot to remove projectile.

.float		nextheal_time; // used to space chunks of autoregen
.float		healdelay_time; // sets on recieving damage

.float		changevcshift; // custom screen tint

.float		speedometer;//flag!!!

.float		slide_time; // crouchslide variables
.float		fall_time;// crouchslide
.float		infall;//flag!!! // crouchslide
.float		inslide;//flag!!!// crouchslide
.float		slidebutton;//flag!!! ?
.float		dashbutton; //flag!!!
.float		indash; //flag!!!

//style system
//constants
float 		style_reset_time[6] = {10,8,6,4,2,1}; // time at which combo degrades to previous multiplier
float 		style_multiplier[6] = {1,1,2,4,8,10}; // multiplier for each combo stage that is used to calculate style score

//player
.float		style_points; // style system
.float		style_combo; // current stage of combo
.float		style_denominator; // reduce repeating style bonuses
.float		style_last; // last style performed
.float		style_dmgdone; // Damage done by player at this tick
.float		style_dmgtaken; // Damage done to player at this tick

//combo entity
.entity		combo; // entity that calculates bonus stuff each second (used own .think for timing)

.float		armorplates;

.float 		axe_timer;
.float 		axe_inattack; //flag!!!
.float 		axe_inair; //flag!!!
.float 		axe_frames;
.float		axe_stabs;

.float		axe_cooldown;
.float		sg_cooldown;
.float		ssg_cooldown;
.float		sng_cooldown;
.float		rl_cooldown;
.float		lg_cooldown;

.float		grenadestate; //flag!!!
.float		ssgrefirebonus; //flag!!!

.float 		sngqueue;
.float		clearsngqueue;
.float 		hitsounds; // turn on/off hitsounds //flag!!!
.float		displaydamage;
.float		projtype;

//.float		nailguncharge;//delete
.float		nailgun_time;  // charge timer
.float		rail_charge;
.float		rail_prefire;

//.entity		hud;
.entity		plgrenade; // grenade detonation
.entity		entity1; //
.entity		entity2; // 
.entity		entity3; // 
.entity		thinkent; // voidmod: think entity - a special entity for parallel think layer
.entity		thinkent_two; 


//
// items
//
#define SHELLS_SMALL 10
#define SHELLS_BIG	20

#define NAILS_SMALL 10
#define NAILS_BIG	20

#define ROCKETS_SMALL 10
#define ROCKETS_BIG	20

#define CELLS_SMALL 10
#define CELLS_BIG	20

#define SHELLS_MAX	40
#define NAILS_MAX	30
#define ROCKETS_MAX	20
#define CELLS_MAX	24

//ROCKET LAUNCHER
float RLSPREADX[2] = {100, -100};
/*
float RLSPREADX[7] = {0, 101, -101, -50, -50, 50, 50};
float RLSPREADY[7] = {0, 0, 0, 88, -88, 88, -88};
float RLDAMAGE[7] = {80, 30, 30, 30, 30, 30, 30};
*/
//VoidTime SSG
float vtssgx[14] = {0.4000, 0.3200, 0.3200, 0.2400, 0.1600, 0.0800, 0.0000, 0.0000, -0.0800, -0.1600, -0.2400, -0.3200, -0.3200, -0.4000};	
float vtssgy[14] = {0.0500, -0.0500, 0.0000, 0.0500, -0.0500, 0.0500, 0.0000, -0.0500, 0.0500, -0.0500, 0.0500, 0.0000, -0.0500, 0.0500};
float vtssgdistance[14]	= {2000, 1000, 1000, 2000, 1000, 2000, 1000, 1000, 2000, 1000, 2000, 1000, 1000, 2000};
float vtssgfalloff[14] = {2, 3, 2, 2, 3, 2, 2, 3, 2, 3, 2, 2, 3, 2};
//SSG
float ssgx[11] = {0.4000, 0.3200, 0.2400, 0.1600, 0.0800, 0.0000, -0.0800, -0.1600, -0.2400, -0.3200, -0.4000};
float ssgy[11] = {0.0500, -0.0500, 0.0500, -0.0500, 0.0500, -0.0500, 0.0500, -0.0500, 0.0500, -0.0500, 0.0500};
float ssgdistance[11] = {2000, 1000, 2000, 1000, 2000, 1000, 2000, 1000, 2000, 1000, 2000};
float ssgfalloff[11] = {2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2};
float spreadsize = 0.7;
//SG
float sgx[4] = {0.0000, 0.0000, 0.011745, -0.011745};
float sgy[4] = {0.0000, 0.0135, -0.00675, -0.00675};
//RAILGUN
float raildamagemain[4] = {80,200,200,360};
float raildamagepre[4] = {80,100,100,100};

//
// object stuff
//
.string		mdl;
.vector		mangle;			// angle at start
.float		gravity;

.vector		oldorigin;		// only used by secret door

.float		t_length, t_width;
.float		projectiledamage;

//
// doors, etc
//
.vector		dest, dest1, dest2;
.float		wait;	// time from firing to restarting
.float		delay;	// time from activation to firing
.entity		trigger_field;	// door's trigger entity
.string		noise4;

//
// monsters
//
.float		dopain;
.float 		gib;
.float		tier;
.float 		pausetime;
.entity 	movetarget;
.float		enraged; // voidmod
.float		telefragged;
.float		counter;
.float		monstermass; // not used yet
.float		monstertype; // used for triggeret spawn
//.float		monsterid;
.float		monster_utility1;
.float		monster_utility2;
.vector		monster_vector1;
.float		monster_time1;
.float		monster_time2;
.float		monster_time3;
.float		monster_time4;
.float		monster_time5;
.float		monster_use1;
.float		monster_use2;
.float		monster_use3;
.float		monster_use4;
.float		monster_use5;

//fiend
#define		mu_leaptouch monster_use1
#define		mv_leapvelocity monster_vector1
#define		mt_leap monster_time1

//shambler
#define		mut_ssgrefire monster_utility1
#define		mut_stabs monster_utility2
#define		mu_leap	monster_use1
#define		mt_smash monster_time1
#define		mt_push monster_time2
#define		mt_cast monster_time3

.entity		damagesprite;

.string	include;		// for monsterjump filters
.string exclude;
.string		killtarget;

//
// doors
//
.float		aflag;
.float		dmg;			// damage done by door when hit
	
//
// misc
//
.float		cnt; 			// misc flag
	
//
// subs
//
.void()		think1;
.vector		finaldest, finalangle;

//
// triggers
//
.float		count;			// for counting triggers


//
// plats / doors / buttons
//
.float		lip;
.float		state;
.vector		pos1, pos2;		// top and bottom positions
.float		height;

//
// sounds
//
.float		waitmin, waitmax;
.float		distance;
.float		volume;

//===========================================================================
	

//
// builtin functions
//

void(vector ang)	makevectors		= #1;		// sets v_forward, etc globals
void(entity e, vector o) setorigin	= #2;
void(entity e, string m) setmodel	= #3;		// set movetype and solid first
void(entity e, vector min, vector max) setsize = #4;
// #5 was removed
void() break						= #6;
float() random						= #7;		// returns 0 - 1
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v) normalize			= #9;
void(string e) error				= #10;
void(string e) objerror				= #11;
float(vector v) vlen				= #12;
float(vector v) vectoyaw			= #13;
entity() spawn						= #14;
void(entity e) remove				= #15;

// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of world is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;	

entity() checkclient				= #17;	// returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound		= #19;
string(string s) precache_model		= #20;
void(entity client, string s)stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(string s) bprint				= #23;
void(entity client, string s) sprint = #24;
void(string s) dprint				= #25;
string(float f) ftos				= #26;
string(vector v) vtos				= #27;
void() coredump						= #28;		// prints all edicts
void() traceon						= #29;		// turns statment trace on
void() traceoff						= #30;
void(entity e) eprint				= #31;		// prints an entire edict
float(float yaw, float dist) walkmove	= #32;	// returns TRUE or FALSE
// #33 was removed
float() droptofloor= #34;	// TRUE if landed on floor
void(float style, string value) lightstyle = #35;
float(float v) rint					= #36;		// round to nearest int
float(float v) floor				= #37;		// largest integer <= v
float(float v) ceil					= #38;		// smallest integer >= v
// #39 was removed
float(entity e) checkbottom			= #40;		// true if self is on ground
float(vector v) pointcontents		= #41;		// returns a CONTENT_*
// #42 was removed
float(float f) fabs = #43;
vector(entity e, float speed) aim = #44;		// returns the shooting vector
float(string s) cvar = #45;						// return cvar.value
void(string s) localcmd = #46;					// put string into local que
entity(entity e) nextent = #47;					// for looping through all ents
void(vector o, vector d, float color, float count) particle = #48;// start a particle effect
void() ChangeYaw = #49;						// turn towards self.ideal_yaw
											// at self.yaw_speed
// #50 was removed
vector(vector v) vectoangles			= #51;

//
// direct client message generation
//
void(float to, float f) WriteByte		= #52;
void(float to, float f) WriteChar		= #53;
void(float to, float f) WriteShort		= #54;
void(float to, float f) WriteLong		= #55;
void(float to, float f) WriteCoord		= #56;
void(float to, float f) WriteAngle		= #57;
void(float to, string s) WriteString	= #58;
void(float to, entity s) WriteEntity	= #59;

//
// broadcast client message generation
//

// void(float f) bWriteByte		= #59;
// void(float f) bWriteChar		= #60;
// void(float f) bWriteShort		= #61;
// void(float f) bWriteLong		= #62;
// void(float f) bWriteCoord		= #63;
// void(float f) bWriteAngle		= #64;
// void(string s) bWriteString	= #65;
// void(entity e) bWriteEntity = #66;

void(float step) movetogoal				= #67;

string(string s) precache_file		= #68;	// no effect except for -copy
void(entity e) makestatic		= #69;
void(string s) changelevel = #70;

//#71 was removed

void(string var, string val) cvar_set = #72;	// sets cvar.value

void(entity client, string s) centerprint = #73;	// sprint, but in middle

void(vector pos, string samp, float vol, float atten) ambientsound = #74;

string(string s) precache_model2	= #75;		// registered version only
string(string s) precache_sound2	= #76;		// registered version only
string(string s) precache_file2		= #77;		// registered version only

void(entity e) setspawnparms		= #78;		// set parm1... to the
												// values at level start
												// for coop respawn

//============================================================================

//
// subs.qc
//
void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void()  SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
void() SUB_Null;
void() SUB_UseTargets;
void() SUB_Remove;

//
//	combat.qc
//
void(entity victim, entity inflictor, entity attacker, float damage, float damage_penetr, float alwaysgib, float customflag) T_Damage;


float (entity e, float healamount, float ignore) T_Heal; // health function

float(entity targ, entity inflictor) CanDamage;


