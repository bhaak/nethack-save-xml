%{
#include "hack.h"
#include "struct_info.h"
#include "save_xml.h"


#define INITIAL_STATE_STACK 32



extern int yylex(void);
extern FILE *yyin;
extern int n_dgns;

void yyerror(const char *);

static boolean cheak_uid(int);

static genericptr_t pre_rest_objects (struct restore_stat_t *, int, int, boolean *);
static genericptr_t pre_rest_monsters(struct restore_stat_t *, int, int);
static void pre_rest_objects_classes(void);

static boolean post_struct_data(int);
static int post_rest_savedata(void);
static int pre_bonedata(const char *);
static int post_bonedata(void);
static void post_rest_array(void);
static void post_rest_array_rooms(void);
static void post_rest_game_stat(void);
static void post_rest_object1(struct obj *);
static void post_rest_object2(struct obj *);
static void post_rest_object3(struct obj *);
static void post_rest_obj_attach_data_mon(void);
static void post_rest_obj_attach_data_val(int);
static void post_rest_monster1(struct monst *);
static void post_rest_monster2(struct monst *);
static void post_rest_monster3(struct monst *);
static void pre_rest_branches(void);
static void post_rest_branches(void);
static void pre_rest_levchn(void);
static void post_rest_levchn(void);
static void pre_rest_spell_book(void);
static void post_rest_spell_book(void);
static genericptr_t pre_rest_oracles(int);
static void pre_rest_fruits(void);
static void post_rest_fruits(void);
static void post_rest_objects_classes(void);
static void post_obj_class_data(char *);
static void pre_rest_water_level(void);
static void pre_rest_bubble(void);
static void post_rest_bubble(void);
static void post_rest_water_level(void);
static void post_rest_floor(void);
static void post_rest_rm_background(void);
static void post_rest_rm_region(int, int, int, int);
static void post_rest_rm_pointer(char *, char *);
static void pre_rest_worms(void);
static void pre_rest_worm(int, long);
static void post_rest_worm(void);
static void post_rest_worm_segment(void);
static void pre_rest_traps(void);
static void post_rest_trap(void);
static void post_rest_engraving(void);
static void post_rest_damage(void);
static void pre_rest_regions(void);
static void post_rest_room_parent(void);
static genericptr_t pre_rest_room(void);
static void post_rest_room(void);
static genericptr_t pre_rest_subroom(void);
static void post_rest_glyph(int);
static void post_current_stat();
static void pre_rest_level_data(void);
static void post_rest_level_data(int);
static void post_rest_timer_data(void);
static void post_rest_light_data(void);
static void post_rest_objects(struct obj **, int);
static void post_rest_monsters(struct monst **, int);

static void prepare_index(void);

static void pre_struct_mapseen(void);
static void post_struct_mapseen(void);

static void shuffle_non_fixed_unknown_name(int, int, boolean);

struct restore_stat_t *restore_state_stack = NULL;
int restore_state_stack_index = 0;
int restore_state_stack_size = 0;

static int max_obj;
static int max_mon;
static int max_objclass;
static short *obj_name_index = NULL;
static short *obj_unknown_index = NULL;
static short *mon_name_index = NULL;
static short *objclass_index = NULL;

static boolean ghostly = FALSE;
static long omoves = 0;
static long tmstamp;
static boolean remember_discover;
static unsigned int stuckid, steedid;
#ifdef BONE_FILE_XML
static const char *reading_bonesid;
#endif

static struct objclass_backup {
	Bitfield(oc_tough,1);	/* hard gems/rings */
	Bitfield(oc_material,5);
	uchar	oc_color;	/* color of the object */
} *orignal_objclass_prop;

static int push_state(int, genericptr_t);

#define pop_state(id) do { restore_state_stack_index--; } while (0)
#define current_stat	(restore_state_stack[restore_state_stack_index])

#define Is_IceBox(o) ((o)->otyp == ICE_BOX ? TRUE : FALSE)

#if defined(UNIX) || defined(VMS) || defined(__EMX__) || defined(WIN32)
#define HUP	if (!program_state.done_hup)
#else
#define HUP
#endif



%}


%token '<' '>' '/' '=' ','
%token ARRAY STRUCT COMMENT

%token BIT_FIELD BOOL VAL STRING
%token OBJECT_NAME OBJ_UNKNOWN_NAME OBJCLASS MONS_NAME

%token ID NUM TYPE WGROWTIME CLASS BITS F_SIZE INDEX
%token CHAR SCHAR UCHAR INT UINT SHORT USHORT LONG ULONG TIME_T UNKNOWN

%token GLYPH_INVALID GLYPH_WARNING GLYPH_SWALLOW GLYPH_ZAP
%token GLYPH_EXPLOSION GLYPH_CMAP GLYPH_OBJECT GLYPH_RIDDEN
%token GLYPH_CORPSE GLYPH_DETECTED GLYPH_INVIS_MON GLYPH_PET GLYPH_MONST

%token RM_TYPE

%token ROLE RACE GENDER ALIGN QUEST

%token RM_BACKGROUND RM_REGION RM_POINTER REGION_PARM

%token <string> STRING_DATA DATA
%token <i> NUMBER_DATA STRUCT_ID

%token ARTIFACT ARTIFACTS BONEDATA BRANCHES BUBBLES CMAP CONTENTS CURRENT_STAT
%token DAMAGES DUNGEON DUNGEON_OVERVIEW ENGRAVINGS FLOOR FRUITS GAMESTAT GLYPH
%token LAUNCH LEVCHN LEVELDATA LEVELS LIGHT_SOURCES
%token MONSTER MONSTERS MON_EXTRA_DATA
%token OBJECT OBJECTS OBJECT_CLASS OBJECT_CLASSES OBJ_ATTACHED ORACLES
%token PROPERTY REGIONS ROOM_DATA SUBROOM SAVEDATA SPELL_BOOK TIMER TIMERS TRAPS
%token VERSION WATERLEBEL WORM WORMS WORM_SEGMENT
%token UNKNOWN_TAG UNKNOWN_DATA

%type  <i>	type_stat struct_head glyph_type glyph_head
%type  <i>	cmap array_option value_stat
%type  <i>	level_data level_data_head
%type  <string>	id_data
%type  <region>	rm_region_head rm_region_sub
%type  <obj>	obj_name objclass obj_unknown_nam obj_class_name obj_identifier
%type  <mon>	mons_name
%type  <array>	array_head
%type  <worm>	worm_option

%union
{
	int i;
	char *string;
	struct {
		int ox, oy, lx, ly;
	} region;
	struct {
		int otyp;
		int oclass;
		int ounknown;
		int index;
	} obj;
	struct {
		int mnum;
		int mclass;
		int index;
	} mon;
	struct {
		int type;
		int size;
	} array;
	struct {
		int id;
		long wgrowtime;
		int n_segs;
	} worm;
}

%start restore_data

%%
restore_data	: {
			  if (restore_state_stack)
				  free(restore_state_stack);

			  restore_state_stack_size = INITIAL_STATE_STACK;
			  restore_state_stack =
				  (struct restore_stat_t *)alloc(restore_state_stack_size * sizeof(struct restore_stat_t));
			  restore_state_stack_index = 0;

			  restore_state_stack[0].id = STRUCTURE_INVALID;
			  restore_state_stack[0].ptr = NULL;
			  restore_state_stack[0].skip = FALSE;
			  restore_state_stack[0].ignore = FALSE;
			  restore_state_stack[0].u.current_level = -1;

			  max_obj = NUM_OBJECTS;
			  max_mon = NUMMONS;
			  max_objclass = MAXOCLASSES;
		  } target
		  {
			  free(restore_state_stack);
			  restore_state_stack = NULL;
			  restore_state_stack_size = 0;

			  free(obj_name_index);
			  free(obj_unknown_index);
			  free(mon_name_index);
			  free(objclass_index);
			  obj_name_index = obj_unknown_index = NULL;
			  mon_name_index = objclass_index = NULL;
		  }
		;

target		: savedata
		| bonedata
		| error
		  {
			  if (restore_state_stack)
				  free(restore_state_stack);
			  restore_state_stack = NULL;
			  restore_state_stack_size = 0;

			  YYABORT;
		  }
		;

savedata	: savedata_head version save_data savedata_tail
		| savedata_head version property save_data savedata_tail
		;

savedata_head	: '<' SAVEDATA '>'
		  {
			  if (!(restore_file_format_xml & RESTORE_FILE_IS_XML)) {
				  impossible("restore_xml: unexpected format");

				  YYERROR;
			  }
		  }
		;

savedata_tail	: '<' '/' SAVEDATA '>'
		  {
			  if (post_rest_savedata() < 0)
				  YYERROR;

			  if (restore_state_stack_index) {
				  impossible("restore_xml: unexpected EOF (insufficiency end tag: %d)",
					     restore_state_stack_index);

				  YYERROR;
			  }
		  }
		;

bonedata	: bonedata_head version fruits level_data bonedata_tail
		| bonedata_head version property fruits level_data bonedata_tail
		;

bonedata_head	: '<' BONEDATA ID '=' id_data '>'
		  {
			  if (!(restore_file_format_xml & BONE_FILE_IS_XML)) {
				  impossible("restore_xml: unexpected format");

				  YYERROR;
			  }

			  if (!pre_bonedata($5))
				  YYERROR;
		  }
		;

bonedata_tail	: '<' '/' BONEDATA '>'
		  {
			  if (post_bonedata() < 0)
				  YYERROR;

			  if (restore_state_stack_index) {
				  impossible("restore_xml: unexpected EOF (insufficiency end tag: %d)",
					     restore_state_stack_index);

				  YYERROR;
			  }
		  }
		;

property	: property_head '<' '/' PROPERTY '>'
		  {
			  pop_state(STRUCTURE_PROPERTY);
		  }
		;

property_head	: '<' PROPERTY '>'
		  {
			  push_state(STRUCTURE_PROPERTY, NULL);
		  }
		| property_head immediate
		;

version		: version_head '<' '/' VERSION '>'
		  {
			  pop_state(STRUCTURE_VERSION);
		  }
		;

version_head	: '<' VERSION '>'
		  {
			  push_state(STRUCTURE_VERSION, NULL);
			  current_stat.tmp.p = NULL;
		  } struct_data
		| version_head immediate
		  {
			  if (current_stat.tmp.p) {
			      free(current_stat.tmp.p);
			      current_stat.tmp.p = NULL;
			  }
		  }
		;

comment		: '<' COMMENT '>' DATA '<' '/' COMMENT '>'
		;

id_data		: STRING_DATA
		  {
			  int len = strlen($1);
			  $1[len-1] = 0;
			  $$ = $1+1;
		  }
		;

immediate	: value_stat | bitfields_stat | bool_stat | string_stat
		;

value_stat	: '<' VAL TYPE '=' type_stat ID '=' id_data '>' DATA '<' '/' VAL '>'
		  {
			  int var_id;

			  restore_core(&current_stat, $5, $8, $10, &var_id);
			  $$ = var_id;
		  }
		;

type_stat	: CHAR		{ $$ = VALUE_TYPE_CHAR;		}
		| SCHAR		{ $$ = VALUE_TYPE_SCHAR;	}
		| UCHAR		{ $$ = VALUE_TYPE_UCHAR;	}
		| INT		{ $$ = VALUE_TYPE_INT;		}
		| UINT		{ $$ = VALUE_TYPE_UINT;		}
		| SHORT		{ $$ = VALUE_TYPE_SHORT;	}
		| USHORT	{ $$ = VALUE_TYPE_USHORT;	}
		| LONG		{ $$ = VALUE_TYPE_LONG;		}
		| ULONG		{ $$ = VALUE_TYPE_ULONG;	}
		| TIME_T	{ $$ = VALUE_TYPE_LLONG;	}
		| UNKNOWN	{ $$ = -1;			}
		;

bitfields_stat	:'<' BIT_FIELD BITS '=' NUMBER_DATA ID '=' id_data '>' DATA '<' '/' BIT_FIELD '>'
		  {
			  if ($5 > 32) $5 = 32;
			  restore_core(&current_stat, VALUE_TYPE_BITFIELDS + $5, $8, $10, NULL);
		  }
		;

bool_stat	: '<' BOOL ID '=' id_data '>' DATA '<' '/' BOOL '>'
		  {
			  restore_core(&current_stat, VALUE_TYPE_BOOL, $5, $7, NULL);
		  }
		;

string_stat	: '<' STRING ID '=' id_data '>' DATA '<' '/' STRING '>'
		  {
			  restore_core(&current_stat, VALUE_TYPE_STRING, $5, $7, NULL);
		  }
		| '<' STRING ID '=' id_data '>' '<' '/' STRING '>'
		  {
			  restore_core(&current_stat, VALUE_TYPE_STRING, $5, "", NULL);
		  }
		;

obj_name	: '<' OBJECT_NAME CLASS '=' STRING_DATA '>' DATA '<' '/' OBJECT_NAME '>'
		  {
			  $$.oclass = def_char_to_objclass(*($5+1));
			  $$.otyp = oname_to_otyp($7, $$.oclass);
			  $$.ounknown = -1;
			  $$.index = -1;
		  }
		| '<' OBJECT_NAME CLASS '=' STRING_DATA INDEX '=' NUMBER_DATA '>' DATA '<' '/' OBJECT_NAME '>'
		  {
			  $$.oclass = def_char_to_objclass(*($5+1));

			  if ($8 >= 0 && $8 < max_obj && obj_name_index[$8] >= 0) {
				  $$.otyp = obj_name_index[$8];
			  } else {
				  $$.otyp = oname_to_otyp($10, $$.oclass);
				  if ($8 >= 0 && $8 < max_obj)
					  obj_name_index[$8] = $$.otyp;
			  }

			  $$.ounknown = -1;
			  $$.index = $8;
		  }
		;

objclass	: '<' OBJCLASS '>' DATA '<' '/' OBJCLASS '>'
		  {
			  $$.oclass = oclassnm_to_oclass($4);
			  $$.otyp = -1;
			  $$.ounknown = -1;
			  $$.index = -1;
		  }
		| '<' OBJCLASS INDEX '=' NUMBER_DATA '>' DATA '<' '/' OBJCLASS '>'
		  {
			  if ($5 >= 0 && $5 < max_objclass && objclass_index[$5] >= 0) {
				  $$.oclass = objclass_index[$5];
			  } else {
				  $$.oclass = oclassnm_to_oclass($7);
				  if ($5 >= 0 && $5 < max_objclass)
					  objclass_index[$5] = $$.oclass;
			  }
			  $$.otyp = -1;
			  $$.ounknown = -1;
			  $$.index = $5;
		  }
		;

obj_unknown_nam	: '<' OBJ_UNKNOWN_NAME CLASS '=' STRING_DATA '>' DATA '<' '/' OBJ_UNKNOWN_NAME '>'
		  {
			  $$.oclass = def_char_to_objclass(*($5+1));
			  $$.otyp = -1;
			  $$.ounknown = ounknname_to_idx($7, $$.oclass);
			  $$.index = -1;
		  }
		| '<' OBJ_UNKNOWN_NAME CLASS '=' STRING_DATA INDEX '=' NUMBER_DATA '>' DATA '<' '/' OBJ_UNKNOWN_NAME '>'
		  {
			  $$.oclass = def_char_to_objclass(*($5+1));

			  if ($8 >= 0 && $8 < max_obj && obj_unknown_index[$8] >= 0) {
				  $$.ounknown = obj_unknown_index[$8];
			  } else {
				  $$.ounknown = ounknname_to_idx($10, $$.oclass);
				  if ($8 >= 0 && $8 < max_obj)
					  obj_unknown_index[$8] = $$.ounknown;
			  }

			  $$.otyp = -1;
			  $$.index = $8;
		  }
		;

mons_name	: '<' MONS_NAME CLASS '=' STRING_DATA ID '=' id_data '>' DATA '<' '/' MONS_NAME '>'
		  {
			  int mclass = def_char_to_monclass(*($5+1));

			  $$.mnum = mname_to_mnum($10, mclass);
			  $$.mclass = mclass;
			  $$.index = -1;
		  }
		| '<' MONS_NAME CLASS '=' STRING_DATA INDEX '=' NUMBER_DATA ID '=' id_data '>' DATA '<' '/' MONS_NAME '>'
		  {
			  int mclass = def_char_to_monclass(*($5+1));

			  if ($8 >= 0 && $8 < max_mon && mon_name_index[$8] >= 0) {
				  $$.mnum = mon_name_index[$8];
			  } else {
				  $$.mnum = mname_to_mnum($13, mclass);
				  if ($8 >= 0 && $8 < max_mon)
					  mon_name_index[$8] = $$.mnum;
			  }
			  $$.mclass = mclass;
			  $$.index = $8;
		  }
		| '<' MONS_NAME CLASS '=' STRING_DATA ID '=' id_data '>' '<' '/' MONS_NAME '>'
		  {
			  $$.mnum = NON_PM;
			  $$.mclass = 0;
			  $$.index = -1;
		  }
		| '<' MONS_NAME CLASS '=' STRING_DATA INDEX '=' NUMBER_DATA ID '=' id_data '>' '<' '/' MONS_NAME '>'
		  {
			  if ($8 >= 0 && $8 < max_mon && mon_name_index[$8] >= 0) {
				  $$.mnum = mon_name_index[$8];
			  } else
				  $$.mnum = NON_PM;
			  $$.mclass = def_char_to_monclass(*($5+1));
			  $$.index = $8;
		  }
		;

content		: immediate | array | struct_data | glyph | rm_type
		| role | race | gender | align | quest | comment
		;

contents	: content
		| contents content
		;

array		: array_head contents array_tail	{ pop_state($1.type); }
		| array_head rooms array_tail
		  {
			  post_rest_array_rooms();

			  pop_state($1.type);
		  }
		| array_head array_tail			{ pop_state($1.type); }
		;

array_head	: '<' ARRAY ID '=' id_data array_option '>'
		  {
			  int var_id, struct_id = current_stat.id;
			  genericptr_t ptr = restore_core(&current_stat, STRUCTURE_ARRAY, $5,
							  (const char *)$6, &var_id);

			  if (!ptr) {
			      current_stat.skip = TRUE;
			      if (!current_stat.ignore) impossible("null pointer error: array %s", $5);
			  }

			  $$.type = push_state(STRUCTURE_ARRAY, ptr);
			  $$.size = $6;
			  current_stat.u.array.type = struct_id;
			  current_stat.u.array.var_id = var_id;
			  current_stat.u.array.index = 0;
			  current_stat.u.array.size = $6;
		  }
		;

array_tail	: '<' '/' ARRAY '>'
		  {
			  post_rest_array();
		  }
		;

array_option	: /* nothing */ { $$ = 0; }
		| NUM '=' NUMBER_DATA { $$ = $3; }
		;

struct_data	: struct_head contents struct_end
		  {
			  if (!post_struct_data($1))
				YYERROR;
			  pop_state($1);
		  }
		| struct_head contents launch struct_end
		  {
			  if (!post_struct_data($1))
				YYERROR;
			  pop_state($1);
		  }
		;

struct_head	: '<' STRUCT TYPE '=' STRUCT_ID ID '=' id_data '>'
		  {
			genericptr_t ptr = NULL;

			if ($5 < 0 ||  $5 > STRUCT_ID_END) {
			    if (!current_stat.ignore) impossible("format error!: unknwon struct: %d", $5);
			} else {
			    if (!(ptr = restore_core(&current_stat, $5, $8, NULL, NULL)))
				if (!current_stat.ignore) impossible("null pointer error: %s->%s", struct_info[$5].name, $8);
			}
			$$ = push_state($5, ptr);

			if (!ptr)
			    current_stat.skip = TRUE;
		  }
		;

struct_end	: '<' '/' STRUCT '>'
		;

save_data	: current_stat levels
		;

current_stat	: '<' CURRENT_STAT '>' level_data game_stat '<' '/' CURRENT_STAT '>'
		  {
			  restore_state_stack[0].u.current_level = $4;
			  post_current_stat();
		  }
		;

levels		: '<' LEVELS '>' levels_data '<' '/' LEVELS '>'
		;

levels_data	: /* nothing */
		| levels_data level_data
		  {
			  restlevelfile(-1, $2);
		  }
		;

level_data	: level_data_head '<' '/' LEVELDATA '>'
		  {
			  $$ = $1;
			  post_rest_level_data($1);
			  pop_state(STRUCTURE_LEVELDATA);
		  }
		;

level_data_head	: '<' LEVELDATA ID '=' NUMBER_DATA '>'
		  {
			  push_state(STRUCTURE_LEVELDATA, NULL);
			  $$ = $5;

			  prepare_index();
			  pre_rest_level_data();
		  }
		| level_data_head content
		| level_data_head floor
		| level_data_head timer
		| level_data_head light_sources
		| level_data_head monsters
		| level_data_head worms
		| level_data_head traps
		| level_data_head objects
		| level_data_head engravings
		| level_data_head damages
		| level_data_head regions
		;

game_stat	: game_stat_head '<' '/' GAMESTAT '>'
		  {
			  if (!cheak_uid(current_stat.u.gamestat.uid))
				  YYERROR;

			  pop_state(STRUCTURE_GAMESTAT);

			  post_rest_game_stat();
		  }
		;

game_stat_head	: '<' GAMESTAT '>'
		  {
			  push_state(STRUCTURE_GAMESTAT, NULL);

			  stuckid = 0;
			  steedid = 0;

			  current_stat.u.gamestat.uid = -1;
			  current_stat.u.gamestat.stuckid = &stuckid;
			  current_stat.u.gamestat.steedid = &steedid;

			  remember_discover = discover;
		  }
		| game_stat_head content
		| game_stat_head timer
		| game_stat_head light_sources
		| game_stat_head objects
		| game_stat_head monsters
		| game_stat_head dungeon
		| game_stat_head dungeon_overview
		| game_stat_head levchn
		| game_stat_head spell_book
		| game_stat_head artifacts
		| game_stat_head oracles
		| game_stat_head fruits
		| game_stat_head objects_classes
		| game_stat_head water_level
		;

timer		: timer_head value_stat timers timer_tail
		| timer_head timers timer_tail
		;

timer_head	: '<' TIMER TYPE '=' STRING_DATA '>'
		  {
			  push_state(STRUCTURE_TIMER, NULL);

			  if (!strcmp($5, "\"gloval\""))
				  current_stat.u.timer.range = RANGE_GLOBAL;
			  else
				  current_stat.u.timer.range = RANGE_LEVEL;

			  current_stat.u.timer.timer = NULL;
		  }
		;

timer_tail	: '<' '/' TIMER '>' { pop_state(STRUCTURE_TIMER); }
		;

timers		: '<' TIMERS NUM '=' NUMBER_DATA '>' timer_data '<' '/' TIMERS '>'
		;

timer_data	: /* nothing */
		| timer_data struct_data
		  {
			  post_rest_timer_data();

			  current_stat.u.timer.timer = NULL;
		  }
		;

light_sources	: '<' LIGHT_SOURCES NUM '=' NUMBER_DATA '>' { push_state(STRUCTURE_LIGHT_SOURCES, NULL); }
		  light_data '<' '/' LIGHT_SOURCES '>'
		  { pop_state(STRUCTURE_LIGHT_SOURCES); }
		;

light_data	: /* nothing */
		| light_data struct_data
		  {
			  post_rest_light_data();
		  }
		;

objects		: '<' OBJECTS ID '=' id_data '>'
		  {
			  genericptr_t ptr;
			  boolean frozen = FALSE;
			  int var_id = serach_variable_id(struct_info[STRUCTURE_OBJECTS].var_info,
							  struct_info[STRUCTURE_OBJECTS].num_var, $5);

			  ptr = pre_rest_objects(&current_stat, current_stat.id, var_id, &frozen);

			  push_state(STRUCTURE_OBJECTS, ptr);

			  if (ptr) {
				  *((struct obj **)ptr) = NULL;
			  } else
				  current_stat.skip = TRUE;

			  current_stat.u.objects.var_id = var_id;
			  current_stat.u.objects.frozen = frozen;
		  }
		  object_data '<' '/' OBJECTS '>'
		{
			post_rest_objects((struct obj **)current_stat.ptr, current_stat.u.objects.var_id);
			pop_state(STRUCTURE_OBJECTS);
		}
		;

object_data	: /* nothing */
		| object_data object_head contents object_tail
		| object_data object_head contents obj_extra_data object_tail
		;

object_head	: '<' OBJECT '>' obj_identifier
		  {
			  push_state(STRUCTURE_OBJECT, NULL);
			  current_stat.u.obj.otyp = $4.otyp;
			  current_stat.u.obj.oclass = $4.oclass;
			  current_stat.u.obj.oartifact = 0;
			  current_stat.u.obj.oname = 0;
			  current_stat.u.obj.corpsenm = INVALID_PM;
			  current_stat.u.obj.otmp = 0;
		  }
		;

object_tail	: '<' '/' OBJECT '>'
		  {
			  struct obj *otmp = current_stat.u.obj.otmp;

			  post_rest_object1(otmp);

			  if (otmp) {
				  post_rest_object2(otmp);

				  pop_state(STRUCTURE_OBJECT);

				  post_rest_object3(otmp);
			  } else {
				  if (!current_stat.skip)
					  impossible("restore_xml: don't restore object!");
				  pop_state(STRUCTURE_OBJECT);
			  }
		  }
		;

obj_identifier	: objclass
		  {
			  $$.otyp = -1;
			  $$.oclass = $1.oclass;
			  $$.ounknown = -1;
		  }
		| obj_name objclass
		  {
			  if ($1.oclass != $2.oclass)
				  impossible("restore_xml: inconsistent object class: %d, %d",
					     $1.oclass, $2.oclass);

			  $$.otyp = $1.otyp;
			  $$.oclass = $2.oclass;
			  $$.ounknown = -1;
		  }
		;

obj_extra_data	: obj_contents
		| obj_attached
		| mons_name { current_stat.u.obj.corpsenm = $1.mnum; }
		| obj_extra_data obj_contents
		| obj_extra_data obj_attached
		| obj_extra_data mons_name { current_stat.u.obj.corpsenm = $2.mnum; }
		;

obj_attached	: '<' OBJ_ATTACHED TYPE '=' STRING_DATA '>' obj_attach_data '<' '/' OBJ_ATTACHED '>'
		;

obj_attach_data	: monsters
		  {
			  post_rest_obj_attach_data_mon();
		  }
		| value_stat
		  {
			  post_rest_obj_attach_data_val($1);
		  }
		;

obj_contents	: '<' CONTENTS '>' objects '<' '/' CONTENTS '>'
		;

monsters	: monsters_head monster monsters_tail
		{

		}
		| monsters_head monsters_tail
		{

		}
		;

monsters_head	: '<' MONSTERS ID '=' id_data '>'
		  {
			  genericptr_t ptr = NULL;
			  int var_id = serach_variable_id(struct_info[STRUCTURE_MONSTERS].var_info,
							  struct_info[STRUCTURE_MONSTERS].num_var, $5);

			  ptr = pre_rest_monsters(&current_stat, current_stat.id, var_id);

			  push_state(STRUCTURE_MONSTERS, ptr);
			  if (ptr) {
				  *((struct monst **)ptr) = NULL;
			  } else
				  current_stat.skip = TRUE;
			  current_stat.u.monsters.var_id = var_id;
		  }
		;

monsters_tail	: '<' '/' MONSTERS '>'
		  {
			  post_rest_monsters((struct monst **)current_stat.ptr, current_stat.u.monsters.var_id);
			  pop_state(STRUCTURE_MONSTERS);
		  }
		;

monster		: monster_data
		| monster monster_data
		;

monster_data	: monster_body monster_tail
		| monster_body mon_extra_data monster_tail
		| monster_body objects monster_tail
		| monster_body mon_extra_data objects monster_tail
		;

monster_head	: '<' MONSTER '>' mons_name
		  {
			  push_state(STRUCTURE_MONSTER, NULL);

			  current_stat.u.mon.mnum = $4.mnum;
			  current_stat.u.mon.data = $4.mnum;
			  current_stat.u.mon.mclass = $4.mclass;
			  current_stat.u.mon.dclass = $4.mclass;
			  current_stat.u.mon.mname = 0;
			  current_stat.u.mon.mtmp = 0;
			  current_stat.u.mon.minvent = 0;
		  }
		;

monster_body	: monster_head
		| monster_body mons_name
		  {
			  current_stat.u.mon.data = $2.mnum;
			  current_stat.u.mon.dclass = $2.mclass;
		  }
		| monster_body string_stat
		| monster_body struct_data
		;

monster_tail	: '<' '/' MONSTER '>'
		  {
			  struct monst *mtmp = current_stat.u.mon.mtmp;

			  post_rest_monster1(mtmp);

			  if (mtmp) {
				  post_rest_monster2(mtmp);

				  pop_state(STRUCTURE_MONSTER);

				  post_rest_monster3(mtmp);
			  } else {
				  if (!current_stat.skip)
					  impossible("restore_xml: don't restore monster!");
				  pop_state(STRUCTURE_MONSTER);
			  }
		  }
		;

mon_extra_data	: '<' MON_EXTRA_DATA '>' struct_data '<' '/' MON_EXTRA_DATA '>'
		| '<' MON_EXTRA_DATA '>' '<' '/' MON_EXTRA_DATA '>'
		;

dungeon		: dungeon_head '<' '/' DUNGEON '>'
		  { pop_state(STRUCTURE_DUNGEON); }
		;

dungeon_head	: '<' DUNGEON '>' { push_state(STRUCTURE_DUNGEON, NULL); }
		| dungeon_head content
		| dungeon_head branches
		;

branches	: branches_head branche_data  '<' '/' BRANCHES '>'
		  { pop_state(STRUCTURE_BRANCHES); }
		;

branches_head	: '<' BRANCHES NUM '=' NUMBER_DATA '>'
		  {
			  push_state(STRUCTURE_BRANCHES, NULL);
			  pre_rest_branches();
			  current_stat.ptr = 0;
		  }
		;

branche_data	: /* nothing */
		| branche_data struct_data
		  {
			  post_rest_branches();
		  }
		;

levchn		: levchn_head levchn_data  '<' '/' LEVCHN '>'
		  { pop_state(STRUCTURE_LEVCHN); }
		;

levchn_head	: '<' LEVCHN NUM '=' NUMBER_DATA '>'
		  {
			  push_state(STRUCTURE_LEVCHN, NULL);
			  pre_rest_levchn();
			  current_stat.ptr = 0;
			  current_stat.tmp.p = NULL;
		  }
		;

levchn_data	: /* nothing */
		| levchn_data struct_data
		  {
			  post_rest_levchn();
			  current_stat.tmp.p = NULL;
		  }
		;

spell_book	: spell_book_head spell_books  spell_book_tail
		| spell_book_head spell_book_tail
		;

spell_book_head	: '<' SPELL_BOOK ID '=' STRING_DATA '>'
		  {
			  push_state(STRUCTURE_SPELL_BOOK, var_info_save_c[VARIABLE_ID_SAVE_C__SPL_BOOK].ptr);
			  current_stat.u.array.index = 0;
			  pre_rest_spell_book();
		  }
		;

spell_book_tail	:'<' '/' SPELL_BOOK '>'
		  {
			  post_rest_spell_book();
			  pop_state(STRUCTURE_SPELL_BOOK);
		  }
		;

spell_books	: struct_data
		| spell_books struct_data
		;

artifacts	: artifacts_head artifact artifacts_tail
		| artifacts_head artifacts_tail
		;

artifacts_head	: '<' ARTIFACTS '>'
		  {
			  init_artifacts();
			  push_state(STRUCTURE_ARTIFACT, NULL);
		  }
		;

artifacts_tail	: '<' '/' ARTIFACTS '>'
		  {
			pop_state(STRUCTURE_ARTIFACT);
		  }
		;

artifact	: artifact_data
		| artifact artifact_data
		;

artifact_data	: '<' ARTIFACT ID '=' id_data '>' bool_stat  '<' '/' ARTIFACT '>'
		  {
			  restore_artifact_xml($5, current_stat.tmp.b);
		  }
		;

oracles		: oracles_head oracle_data  oracles_tail
		| oracles_head oracles_tail
		;

oracles_head	: '<' ORACLES NUM '=' NUMBER_DATA '>'
		  {
			  genericptr_t ptr;

			  ptr = pre_rest_oracles($5);

			  push_state(STRUCTURE_ORACLES, ptr);

			  current_stat.u.array.type = STRUCTURE_ORACLES;
			  current_stat.u.array.index = 0;
			  current_stat.u.array.size = $5;
		  }
		;

oracles_tail	: '<' '/' ORACLES '>'
		  {
			restore_oracles_xml(current_stat.u.array.size, (long *)current_stat.ptr);

			pop_state(STRUCTURE_ORACLES);
		  }
		;

oracle_data	: value_stat
		| oracle_data value_stat
		;

fruits		: '<' FRUITS '>'
		  {
			  push_state(STRUCTURE_FRUITS, NULL);

			  pre_rest_fruits();
		  } fruits_data  '<' '/' FRUITS '>'
		  { pop_state(STRUCTURE_FRUITS); }
		;

fruits_data	: /* nothing */
		| fruits_data struct_data
		  {
			  post_rest_fruits();
			  current_stat.tmp.p = NULL;
		  }
		;

objects_classes	: '<' OBJECT_CLASSES '>'
		  {
			  pre_rest_objects_classes();
		  } obj_class '<' '/' OBJECT_CLASSES '>'
		  {
			  post_rest_objects_classes();
		  }
		;

obj_class	: obj_class_data
		| obj_class obj_class_data
		;

obj_class_data	: obj_class_sub obj_class_tail
		  {
			  post_obj_class_data(NULL);
			  pop_state(STRUCTURE_OBJECT_CLASS);
		  }
		| obj_class_sub string_stat
		  {
			  post_obj_class_data(current_stat.tmp.p);
			  pop_state(STRUCTURE_OBJECT_CLASS);
		  } obj_class_tail
		;

obj_class_sub	: obj_class_head obj_class_name
		  {
			  current_stat.u.objclass.otyp		= $2.otyp;
			  current_stat.u.objclass.oclass	= $2.oclass;
			  current_stat.u.objclass.ounknownnm	= $2.ounknown;
			  current_stat.u.objclass.read_prob = ($2.oclass == GEM_CLASS && $2.otyp <= LAST_GEM);

			  if ($2.otyp < 0)
				  current_stat.skip = TRUE;

		  } struct_data bool_stat
		  {
			  restore_disco_xml(current_stat.u.objclass.otyp, current_stat.tmp.b);
		  }
		;

obj_class_head	: '<' OBJECT_CLASS '>'
		  {
			  push_state(STRUCTURE_OBJECT_CLASS, NULL);
			  current_stat.u.objclass.otyp = -1;
			  current_stat.u.objclass.oclass = -1;
			  current_stat.u.objclass.ounknownnm = -1;
			  current_stat.tmp.p = NULL;
		  }
		;

obj_class_tail	: '<' '/' OBJECT_CLASS '>'
		;

obj_class_name	: obj_name objclass
		  {
			  if ($1.oclass != $2.oclass)
				  impossible("restore_xml: inconsistent object class: %d, %d",
						$1.oclass, $2.oclass);

			  $$.oclass = $1.oclass;
			  $$.otyp = $1.otyp;
			  $$.ounknown = -1;
		  }
		| obj_name obj_unknown_nam objclass
		  {
			  if ($1.oclass != $2.oclass || $1.oclass != $3.oclass)
				  impossible("restore_xml: inconsistent object class: %d, %d, %d",
						$1.oclass, $2.oclass, $3.oclass);

			  $$.oclass = $3.oclass;
			  $$.otyp = $1.otyp;
			  $$.ounknown = $2.ounknown;
		  }
		| objclass
		  {
			  $$.oclass = $1.oclass;
			  $$.otyp = -1;
			  $$.ounknown = -1;
		  }
		| obj_unknown_nam objclass
		  {
			  if ($1.oclass != $2.oclass)
				  impossible("restore_xml: inconsistent object class: %d, %d",
						$1.oclass, $2.oclass);

			  $$.oclass = $2.oclass;
			  $$.otyp = -1;
			  $$.ounknown = $1.ounknown;
		  }
		;

water_level	: water_level_head '<' '/' WATERLEBEL '>'
		  {
			  post_rest_water_level();
			  pop_state(STRUCTURE_WATERLEBEL);
		  }
		;

water_level_head: '<' WATERLEBEL '>'
		  {
			  push_state(STRUCTURE_WATERLEBEL, NULL);
			  pre_rest_water_level();
		  }
		| water_level_head content
		| water_level_head bubbles
		;

bubbles		: '<' BUBBLES NUM '=' NUMBER_DATA '>'
		  {
			  push_state(STRUCTURE_BUBBLES, NULL);

			  current_stat.tmp.p = NULL;

			  pre_rest_bubble();
		  }
		  bubble_data  '<' '/' BUBBLES '>'
		  { pop_state(STRUCTURE_BUBBLES); }
		;

bubble_data	: /* nothing */
		| bubble_data struct_data
		  {
			  post_rest_bubble();
			  current_stat.tmp.p = NULL;
		  }
		;

floor		: '<' FLOOR ID '=' STRING_DATA F_SIZE '=' NUMBER_DATA ',' NUMBER_DATA '>'
		  { push_state(STRUCTURE_FLOOR, NULL); }
		  floor_data '<' '/' FLOOR '>'
		  {
			  post_rest_floor();
			  pop_state(STRUCTURE_FLOOR);
		  }
		;

floor_data	: rm_background
		| comment
		| floor_data struct_data
		| floor_data rm_region
		| floor_data rm_pointer
		| floor_data comment
		;

rm_background	: '<' RM_BACKGROUND '>'
		  { (void) memset((genericptr_t) &levl[0][0], 0, sizeof(struct rm)); }
		  struct_data '<' '/' RM_BACKGROUND '>'
		  {
			  post_rest_rm_background();
		  }
		;

rm_region	: rm_region_sub
		  {
			  post_rest_rm_region($1.ox, $1.oy, $1.lx, $1.ly);
		  }
		;

rm_region_sub	: rm_region_head struct_data rm_region_tail
		  { $$ = $1; }
		| rm_region_head rm_pointer rm_region_tail
		  { $$ = $1; }
		;

rm_region_head	: '<' RM_REGION REGION_PARM '=' NUMBER_DATA ',' NUMBER_DATA ',' NUMBER_DATA ',' NUMBER_DATA '>'
		  {
			  $$.ox = $5;
			  $$.oy = $7;
			  $$.lx = $9;
			  $$.ly = $11;

			  if ($$.ox < 0) $$.ox = 0;
			  if ($$.lx < 0) $$.lx = 0;
			  if ($$.oy < 0) $$.oy = 0;
			  if ($$.ly < 0) $$.ly = 0;

			  if ($$.ox >= COLNO) $$.ox = COLNO - 1;
			  if ($$.lx >= COLNO) $$.lx = COLNO - 1;
			  if ($$.oy >= ROWNO) $$.oy = ROWNO - 1;
			  if ($$.ly >= ROWNO) $$.ly = ROWNO - 1;
		  }
		;

rm_region_tail	: '<' '/' RM_REGION '>'
		;

rm_pointer	: '<' RM_POINTER ID '=' STRING_DATA '>' DATA '<' '/' RM_POINTER '>'
		  {
			  post_rest_rm_pointer($5, $7);
		  }
		;

worms		: '<' WORMS '>'
		  {
			  pre_rest_worms();
		  } worm '<' '/' WORMS '>'
		;

worm		: /* nothing */
		| worm '<' WORM worm_option '>'
		  {
			  push_state(STRUCTURE_WORM, NULL);

			  current_stat.u.worm.id	= $4.id;
			  current_stat.u.worm.n_segs	= $4.n_segs;
			  current_stat.u.worm.seg = NULL;

			  if ($4.id >= 0)
				  pre_rest_worm($4.id, $4.wgrowtime);
		  } worm_data '<' '/' WORM '>'
		  {
			  if (current_stat.u.worm.id >= 0)
				  post_rest_worm();
			  else
				  current_stat.skip = TRUE;

			  pop_state(STRUCTURE_WORM);
		  }
		;

worm_option	: ID '=' NUMBER_DATA WGROWTIME '=' NUMBER_DATA NUM '=' NUMBER_DATA
		  {
			  $$.id = ($3 >=0 && $3 < MAX_NUM_WORMS ? $3 : -1);
			  $$.wgrowtime = $6;
			  $$.n_segs = $9;
		  }
		;

worm_data	: worm_segment
		| worm_data worm_segment
		;

worm_segment	: '<' WORM_SEGMENT '>'	value_stat { current_stat.u.worm.wx = current_stat.tmp.i; }
					value_stat { current_stat.u.worm.wy = current_stat.tmp.i; }
		  '<' '/' WORM_SEGMENT '>'
		  {
			  post_rest_worm_segment();
		  }
		;

traps		: '<' TRAPS '>'
		  {
			  push_state(STRUCTURE_TRAPS, NULL);

			  current_stat.tmp.p = NULL;
			  pre_rest_traps();
		  } trap_data '<' '/' TRAPS '>'
		  { pop_state(STRUCTURE_TRAPS); }
		;

trap_data	: /* nothing */
		| trap_data struct_data
		  {
			  post_rest_trap();
			  current_stat.tmp.p = NULL;
		  }
		;

launch		: '<' LAUNCH '>' struct_data '<' '/' LAUNCH '>'
		| '<' LAUNCH '>' obj_identifier '<' '/' LAUNCH '>'
		| '<' LAUNCH '>' value_stat '<' '/' LAUNCH '>'
		;

engravings	: '<' ENGRAVINGS '>'
		  {
			  push_state(STRUCTURE_ENGRAVINGS, NULL);
			  current_stat.tmp.p = NULL;		  
		  } engraving_data '<' '/' ENGRAVINGS '>'
		  { pop_state(STRUCTURE_ENGRAVINGS); }
		;

engraving_data	: /* nothing */
		| engraving_data struct_data
		  {
			  post_rest_engraving();
			  current_stat.tmp.p = NULL;
		  }
		;

damages		: '<' DAMAGES NUM '=' NUMBER_DATA '>'
		  {
			  push_state(STRUCTURE_DAMAGES, NULL);

			  current_stat.tmp.p = NULL;
		  }
		  damage_data  '<' '/' DAMAGES '>'
		  { pop_state(STRUCTURE_DAMAGES); }
		;

damage_data	: /* nothing */
		| damage_data struct_data
		  {
			  post_rest_damage();
			  current_stat.tmp.p = NULL;
		  }
		;

regions		: regions_head regions_tail
		| regions_head array regions_tail
		;

regions_head	: '<' REGIONS '>' { push_state(STRUCTURE_REGIONS, NULL); } value_stat
		  {
			  pre_rest_regions();
		  }
		;

regions_tail	: '<' '/' REGIONS '>'
		{
			pop_state(STRUCTURE_REGIONS);
		}
		;

rooms		: room
		| rooms room
		;

room		: room_parent room_tail
		| room_parent subroom room_tail
		;

room_parent	: room_head struct_data
		  {
			  post_rest_room_parent();
		  }
		;

room_head	: '<' ROOM_DATA '>'
		  {
			  push_state(STRUCTURE_ROOM, pre_rest_room());
		  }
		;

room_tail	: '<' '/' ROOM_DATA '>'
		  {
			  post_rest_room();
			  pop_state(STRUCTURE_ROOM);
		  }
		;

subroom		: subroom_head rooms '<' '/' SUBROOM '>'
		  {
			  pop_state(STRUCTURE_SUBROOM);
		  }
		;

subroom_head	: '<' SUBROOM NUM '=' NUMBER_DATA '>'
		  {
			  push_state(STRUCTURE_SUBROOM, pre_rest_subroom()) ;
		  }
		;

glyph		: glyph_head immediate glyph_tail
		  {
			  int glyph = 0;

			  switch ($1) {
			  case GLYPH_INVALID:
				  glyph = current_stat.tmp.i + MAX_GLYPH;
				  break;
			  case GLYPH_WARNING:
				  glyph = warning_to_glyph(current_stat.tmp.i);
				  break;
			  case GLYPH_ZAP:
				  glyph = current_stat.tmp.i + GLYPH_ZAP_OFF;
				  break;
			  case GLYPH_EXPLOSION:
				  glyph = current_stat.tmp.i + GLYPH_EXPLODE_OFF;
				  break;
			  }

			  post_rest_glyph(glyph);
			  pop_state(STRUCTURE_GLYPH);
		  }
		| glyph_head immediate mons_name glyph_tail
		  {
			  int glyph = 0;

			  switch ($1) {
			  case GLYPH_SWALLOW_OFF:
				  glyph = ($3.mnum << 3) + current_stat.tmp.i + GLYPH_SWALLOW_OFF;
				  break;
			  }

			  post_rest_glyph(glyph);
			  pop_state(STRUCTURE_GLYPH);
		  }
		| glyph_head cmap glyph_tail
		  {
			  post_rest_glyph(cmap_to_glyph($2));
			  pop_state(STRUCTURE_GLYPH); }
		| glyph_head obj_name glyph_tail
		  {
			  int glyph = 0;

			  if ($1 == GLYPH_OBJECT) {
				  glyph = objnum_to_glyph($2.otyp);
			  }

			  post_rest_glyph(glyph);
			  pop_state(STRUCTURE_GLYPH);
		  }
		| glyph_head mons_name glyph_tail
		  {
			  int glyph = 0;

			  switch ($1) {
			  case GLYPH_RIDDEN:
				  glyph = ridden_monnum_to_glyph($2.mnum);
				  break;
			  case GLYPH_CORPSE:
				  glyph = $2.mnum + GLYPH_BODY_OFF;
				  break;
			  case GLYPH_DETECTED:
				  glyph = detected_monnum_to_glyph($2.mnum);
				  break;
			  case GLYPH_PET:
				  glyph = petnum_to_glyph($2.mnum);
				  break;
			  case GLYPH_MONST:
				  glyph = $2.mnum;
				  break;
			  }

			  post_rest_glyph(glyph);
			  pop_state(STRUCTURE_GLYPH);
		  }
		| glyph_head glyph_tail
		  {
			  post_rest_glyph(($1 == GLYPH_INVIS_MON) ? GLYPH_INVISIBLE : 0);
			  pop_state(STRUCTURE_GLYPH);
		  }
		;

glyph_head	: '<' GLYPH TYPE '=' glyph_type ID '=' id_data '>'
		  {
			  genericptr_t ptr = restore_core(&current_stat, STRUCTURE_GLYPH, $8, NULL, NULL);
			  push_state(STRUCTURE_GLYPH, ptr);
			  if (!ptr) {
			      current_stat.skip = TRUE;
			      impossible("null pointer error: glyph %s", $8);
			  }
			  $$ = $5;
		  }
		;

glyph_tail	: '<' '/' GLYPH '>'
		;

glyph_type	: GLYPH_INVALID		{ $$ = GLYPH_INVALID;	}
		| GLYPH_WARNING		{ $$ = GLYPH_WARNING;	}
		| GLYPH_SWALLOW		{ $$ = GLYPH_SWALLOW;	}
		| GLYPH_ZAP		{ $$ = GLYPH_ZAP;	}
		| GLYPH_EXPLOSION	{ $$ = GLYPH_EXPLOSION;	}
		| GLYPH_CMAP		{ $$ = GLYPH_CMAP;	}
		| GLYPH_OBJECT		{ $$ = GLYPH_OBJECT;	}
		| GLYPH_RIDDEN		{ $$ = GLYPH_RIDDEN;	}
		| GLYPH_CORPSE		{ $$ = GLYPH_CORPSE;	}
		| GLYPH_DETECTED	{ $$ = GLYPH_DETECTED;	}
		| GLYPH_INVIS_MON	{ $$ = GLYPH_INVIS_MON;	}
		| GLYPH_PET		{ $$ = GLYPH_PET;	}
		| GLYPH_MONST		{ $$ = GLYPH_MONST;	}
		| UNKNOWN		{ $$ = UNKNOWN;		}
		;

cmap		: '<' CMAP '>' DATA '<' '/' CMAP '>'
		  {
			  $$ = serach_name2num(cmap_info, MAXPCHARS, $4);
		  }
		;

rm_type		: '<' RM_TYPE ID '=' id_data '>' DATA '<' '/' RM_TYPE '>'
		  { restore_core(&current_stat, VALUE_TYPE_RM_TYPE, $5, $7, NULL); }
		;

role		: '<' ROLE ID '=' id_data '>' DATA '<' '/' ROLE '>'
		  { restore_core(&current_stat, VALUE_TYPE_ROLE, $5, $7, NULL); }
		;

race		: '<' RACE ID '=' id_data '>' DATA '<' '/' RACE '>'
		  { restore_core(&current_stat, VALUE_TYPE_RACE, $5, $7, NULL); }
		;

gender		: '<' GENDER ID '=' id_data '>' DATA '<' '/' GENDER '>'
		  { restore_core(&current_stat, VALUE_TYPE_GENDER, $5, $7, NULL); }
		;

align		: '<' ALIGN ID '=' id_data '>' DATA '<' '/' ALIGN '>'
		  { restore_core(&current_stat, VALUE_TYPE_ALIGN, $5, $7, NULL); }
		;

quest		: '<' QUEST ID '=' id_data '>' DATA '<' '/' QUEST '>'
		  { restore_core(&current_stat, VALUE_TYPE_QUEST, $5, $7, NULL); }
		;

dungeon_overview: '<' DUNGEON_OVERVIEW NUM '=' NUMBER_DATA '>'
		  {
			  push_state(STRUCTURE_DUNGEON_OVERVIEW, NULL);

			  pre_struct_mapseen();
			  current_stat.tmp.p = NULL;
		  }
		  dungeon_overview_data '<' '/' DUNGEON_OVERVIEW '>'
		  { pop_state(STRUCTURE_DUNGEON_OVERVIEW); }
		;

dungeon_overview_data:/* nothing */
		| dungeon_overview_data struct_data
		  {
			  if (current_stat.tmp.p)
				post_struct_mapseen();

			  current_stat.tmp.p = NULL;
		  }
		;

%%

static int
push_state(id, data)
int id;
genericptr_t data;
{
	boolean skip = restore_state_stack[restore_state_stack_index].skip;
	boolean ignore = restore_state_stack[restore_state_stack_index].ignore;

	restore_state_stack_index++;

	if (restore_state_stack_index >= restore_state_stack_size) {
		restore_state_stack_size += INITIAL_STATE_STACK;
		restore_state_stack =
			(struct restore_stat_t *)realloc(restore_state_stack, restore_state_stack_size);
	}

	restore_state_stack[restore_state_stack_index].id = id;
	restore_state_stack[restore_state_stack_index].ptr = data;
	restore_state_stack[restore_state_stack_index].u.array.index = 0;
	restore_state_stack[restore_state_stack_index].skip = skip;
	restore_state_stack[restore_state_stack_index].ignore = ignore;

	return id;
}

void
yyerror(s)
const char *s;
{
	pline("perse error of %s file: %s", ghostly ? "bone" : "save", s);
}

int
dorecover_xml(fd)
int fd;
{
	int ret;
	struct obj *otmp;

	yyin = fdopen(fd, "r");
	init_restore_xml_tables();

	stuckid = 0;
	steedid = 0;

	ghostly = FALSE;
	restoring = TRUE;
	ret = yyparse();
	fclose(yyin);

	restore_file_format_xml = RESTORE_FILE_IS_BINARY;

	if (ret) {
		pline("Saved game restoration error!.");
		display_nhwindow(WIN_MESSAGE, TRUE);

		savelev(-1, 0, FREE_SAVE);	/* discard current level */
		(void) delete_savefile();
		restoring = FALSE;

		return(0);
	}

	if (!wizard && !discover)
		(void) delete_savefile();
#ifdef REINCARNATION
	if (Is_rogue_level(&u.uz)) assign_rogue_graphics(TRUE);
#endif
#ifdef USE_TILES
	substitute_tiles(&u.uz);
#endif

	restlevelstate(stuckid, steedid);

	max_rank_sz();	/* to recompute mrank_sz (botl.c) */
	/* take care of iron ball & chain */
	for(otmp = fobj; otmp; otmp = otmp->nobj)
		if(otmp->owornmask)
			setworn(otmp, otmp->owornmask);

	/* in_use processing must be after:
	 *    + The inventory has been read so that freeinv() works.
	 *    + The current level has been restored so billing information
	 *      is available.
	 */
	inven_inuse(FALSE);

	load_qtlist();  /* re-load the quest text info */
        reset_attribute_clock();

	/* Set up the vision internals, after levl[] data is loaded	*/
	/* but before docrt().						*/
	vision_reset();
        vision_full_recalc = 1; /* recompute vision (not saved) */

        run_timers();   /* expire all timers that have gone off while away */
        docrt();
        restoring = FALSE;
        clear_nhwindow(WIN_MESSAGE);
        program_state.something_worth_saving++; /* useful data now exists */

        /* Success! */
        welcome(FALSE);

	return 1;
}

#ifdef BONE_FILE_XML
int
getbones_xml(fd, bonesid)
int fd;
const char *bonesid;
{
	int ret;

	yyin = fdopen(fd, "r");
	init_restore_xml_tables();

	ghostly = TRUE;
	reading_bonesid = bonesid;
	ret = yyparse();
	fclose(yyin);

	restore_file_format_xml = RESTORE_FILE_IS_BINARY;

	if (ret)
		return(0);
	else
		return 1;
}
#endif /* BONE_FILE_XML */

static void
prepare_index()
{
	int i;

	if (max_obj <= 0) {
		max_obj = NUM_OBJECTS;
		if (obj_name_index)
			free(obj_name_index);
		if (obj_unknown_index)
			free(obj_unknown_index);
		obj_name_index    = NULL;
		obj_unknown_index = NULL;
	}
	if (max_mon <= 0) {
		max_obj = NUMMONS;
		if (mon_name_index)
			free(mon_name_index);
		mon_name_index = NULL;
	}
	if (max_objclass <= 0) {
		max_objclass = MAXOCLASSES;
		if (objclass_index)
			free(objclass_index);
		objclass_index = NULL;
	}

	if (!obj_name_index || !obj_unknown_index) {
		obj_name_index    = (short *)alloc(max_obj * sizeof(short));
		obj_unknown_index = (short *)alloc(max_obj * sizeof(short));

		for (i = 0; i < max_obj; i++) {
			obj_name_index[i] = -1;
			obj_unknown_index[i] = -1;
		}
	}

	if (!mon_name_index) {
		mon_name_index = (short *)alloc(max_mon * sizeof(short));

		for (i = 0; i < max_mon; i++)
			mon_name_index[i] = -1;
	}

	if (!objclass_index) {
		objclass_index = (short *)alloc(max_objclass * sizeof(short));

		for (i = 0; i < max_objclass; i++)
			objclass_index[i] = -1;
	}
}

static void
post_rest_array()
{
	if (current_stat.u.array.type == STRUCTURE_DUNGEON &&
	    current_stat.u.array.var_id == VARIABLE_ID_DUNGEON_C__DUNGEONS) {
		n_dgns = current_stat.u.array.size;
	}
}

static void
post_rest_array_rooms()
{
	nroom = current_stat.u.array.size;
	if (nroom)
		doorindex = rooms[nroom - 1].fdoor + rooms[nroom - 1].doorct;
	else
		doorindex = 0;
}

static boolean
post_struct_data(id)
int id;
{
	switch(id) {
	case STRUCT_ID_FLAG:
		flags.bypasses = 0;
		if (remember_discover) discover = remember_discover;

		role_init();	/* Reset the initial role, race, gender, and alignment */;
#ifdef AMII_GRAPHICS
		amii_setpens(amii_numcolors);   /* use colors from save file */
#endif
		break;
	case STRUCT_ID_YOU:
		set_uasmon();
#ifdef CLIPPING
		cliparound(u.ux, u.uy);
#endif
		if(u.uhp <= 0 && (!Upolyd || u.mh <= 0)) {
			u.ux = u.uy = 0;	/* affects pline() [hence You()] */
#if 0 /*JP*/
			You("were not healthy enough to survive restoration.");
#else
			You("再開できるほど健康ではなかった．");
#endif
			/* wiz1_level.dlevel is used by mklev.c to see if lots of stuff is
			 * uninitialized, so we only have to set it and not the other stuff.
			 */
			wiz1_level.dlevel = 0;
			u.uz.dnum = 0;
			u.uz.dlevel = 1;
			return(FALSE);
		}
		break;
	case STRUCT_ID_ENGR:
		if (restore_state_stack[restore_state_stack_index-1].id != STRUCTURE_ENGRAVINGS ||
		    !var_info_engrave_c[VARIABLE_ID_ENGRAVE_C__HEAD_ENGR].ptr) {
			if (current_stat.ptr)
				dealloc_engr((struct engr *)current_stat.ptr);
			restore_state_stack[restore_state_stack_index-1].tmp.p = NULL;
		} else {
			restore_state_stack[restore_state_stack_index-1].tmp.p = current_stat.ptr;
		}
		break;
	case STRUCT_ID_NHREGION:
		{
			NhRegion *reg = ((NhRegion *)(current_stat.ptr));

			if (reg)
				reg->ttl = (reg->ttl > tmstamp) ? reg->ttl - tmstamp : 0;
		}
		break;
	}

	return TRUE;
}

static void
post_obj_class_data(oc_uname)
char *oc_uname;
{
	int oc_name_idx  = current_stat.u.objclass.otyp;
	int oc_descr_idx = current_stat.u.objclass.ounknownnm;

	if (current_stat.u.objclass.otyp < 0)
		return;

	objects[current_stat.u.objclass.otyp].oc_uname = oc_uname;

	objects[oc_name_idx].oc_name_idx = oc_name_idx;
	objects[oc_name_idx].oc_descr_idx = oc_descr_idx;

	objects[current_stat.u.objclass.otyp].oc_class = current_stat.u.objclass.oclass;
}

static void
pre_rest_water_level()
{
	if (!Is_waterlevel(&u.uz))
		current_stat.skip = TRUE;
	else
		set_wportal(); 
}

static void
post_rest_water_level()
{
	if (!current_stat.skip)
		was_waterlevel = TRUE;
}

static void
pre_rest_bubble()
{
	bbubbles = NULL;
	ebubbles = NULL;
}

static void
post_rest_bubble()
{
	if (current_stat.tmp.p) {
		struct bubble *b = (struct bubble *)current_stat.tmp.p;

		if (bbubbles) {
			ebubbles->next = b;
			b->prev = ebubbles;
		} else {
			bbubbles = b;
			b->prev = (struct bubble *)0;
		}
		mv_bubble(b,0,0,TRUE);

		ebubbles = b;
		b->next = (struct bubble *)0;
	}
}

static void
post_rest_floor()
{
	int x, y;

	for (x = 0; x < COLNO; x++)
		for (y = 0; y < ROWNO; y++)
			level.monsters[x][y] = (struct monst *) 0;
}

static void
post_rest_rm_background()
{
	int x, y;

	for (y = 0; y < ROWNO; y++) {
		for (x = 0; x < COLNO; x++) {
			levl[x][y] = levl[0][0];
		}
	}
}

static void
post_rest_rm_region(ox, oy, lx, ly)
int ox, oy, lx, ly;
{
	int x, y;

	for (y = oy; y <= ly; y++) {
		for (x = ox; x <= lx; x++) {
			levl[x][y] = levl[ox][oy];
		}
	}
}

static void
post_rest_rm_pointer(targ, src)
char *targ;
char *src;
{
	int x, y, ox, oy;

	sscanf(targ, "\"%d,%d\"", &x, &y);
	sscanf(src,  "%d,%d",     &ox, &oy);

	if ( x >= 0 &&  x < COLNO &&  y >= 0 &&  y < ROWNO &&
	     ox >= 0 && ox < COLNO && oy >= 0 && oy < ROWNO)
		levl[x][y] = levl[ox][oy];
}

static void
pre_rest_worms()
{
	int i;

	for (i = 1; i < MAX_NUM_WORMS; i++) {
		wheads[i] = NULL;
		wtails[i] = NULL;
		wgrowtime[i] = 0;
	}
}

static void
pre_rest_worm(id, growtime)
int id;
long growtime;
{
	wgrowtime[id] = growtime;
}

static void
post_rest_worm()
{
	wheads[current_stat.u.worm.id] = current_stat.u.worm.seg;
}

static void
post_rest_worm_segment()
{
	if (current_stat.u.worm.id >= 0) {
		struct wseg *temp = newseg();

		temp->nseg = (struct wseg *) 0;
		temp->wx = current_stat.u.worm.wx;
		temp->wy = current_stat.u.worm.wy;

		if (current_stat.u.worm.seg)
			current_stat.u.worm.seg->nseg = temp;
		else
			wtails[current_stat.u.worm.id] = temp;
		current_stat.u.worm.seg = temp;
	}
}

static void
pre_rest_traps()
{
	ftrap = 0;
}

static void
post_rest_trap()
{
	if (current_stat.tmp.p) {
		struct trap *trap = (struct trap *)current_stat.tmp.p;

		trap->ntrap = ftrap;
		ftrap = trap;
	}
}

static void
post_rest_engraving()
{
	struct engr **head_engr =
		(struct engr **)var_info_engrave_c[VARIABLE_ID_ENGRAVE_C__HEAD_ENGR].ptr;
	struct engr *ep = (struct engr *)current_stat.tmp.p;

	if (ep && head_engr) {
		ep->nxt_engr = *head_engr;
		*head_engr = ep;
	}
}

static void
post_rest_damage()
{
	if (current_stat.tmp.p) {
		char damaged_shops[5], *shp = (char *)0;
		struct damage *tmp_dam = (struct damage *)current_stat.tmp.p;

		if (ghostly)
			tmp_dam->when += (monstermoves - omoves);
		Strcpy(damaged_shops,
		       in_rooms(tmp_dam->place.x, tmp_dam->place.y, SHOPBASE));
		if (u.uz.dlevel) {
			/* when restoring, there are two passes over the current
			 * level.  the first time, u.uz isn't set, so neither is
			 * shop_keeper().  just wait and process the damage on
			 * the second pass.
			 */
			for (shp = damaged_shops; *shp; shp++) {
				struct monst *shkp = shop_keeper(*shp);

				if (shkp && inhishop(shkp) &&
				    repair_damage(shkp, tmp_dam, TRUE))
					break;
			}
		}
		if (!shp || !*shp) {
			tmp_dam->next = level.damagelist;
			level.damagelist = tmp_dam;
			tmp_dam = (struct damage *)alloc(sizeof(*tmp_dam));
		}
	}
}

static void
pre_rest_regions()
{
	if (ghostly)
		tmstamp = 0;
	else {
		tmstamp = moves - current_stat.tmp.l;
	}
}

static void
post_rest_room_parent()
{
	int i;
	struct mkroom *r = (struct mkroom *)current_stat.ptr;

	for(i = 0; i < r->nsubrooms; i++) {
		r->sbrooms[i] = &subrooms[nsubroom];
		nsubroom++;
	}
}

static genericptr_t
pre_rest_room()
{
	struct mkroom *r = (struct mkroom *)current_stat.ptr;

	if (!current_stat.ptr) {
		r = NULL;
		current_stat.skip = TRUE;
	} else if (current_stat.id == STRUCTURE_ARRAY &&
		   current_stat.u.array.index < (MAXNROFROOMS+1)*2) {
		r = &(r[current_stat.u.array.index++]);
	} else if (current_stat.id == STRUCTURE_SUBROOM &&
		   current_stat.u.array.index < MAXNROFROOMS+1) {
		r = ((struct mkroom **)current_stat.ptr)[current_stat.u.array.index++];
	} else {
		r = NULL;
		current_stat.skip = TRUE;
	}

	return (genericptr_t)r;
}

static void
post_rest_room()
{
	if (current_stat.ptr)
		((struct mkroom *)current_stat.ptr)->resident = (struct monst *)0;
}

static genericptr_t
pre_rest_subroom()
{
	return current_stat.ptr ?
		(genericptr_t)(((struct mkroom *)current_stat.ptr)->sbrooms) : NULL;
}

static void post_rest_glyph(glyph)
int glyph;
{
	if (!current_stat.skip) *((int *)current_stat.ptr) = glyph;
}

static void
post_current_stat()
{
#ifdef INSURANCE
	savestateinlock();
#endif
	restlevelfile(-1, ledger_no(&u.uz));

	/* these pointers won't be valid while we're processing the
	 * other levels, but they'll be reset again by restlevelstate()
	 * afterwards, and in the meantime at least u.usteed may mislead
	 * place_monster() on other levels
	 */
	u.ustuck = (struct monst *)0;
#ifdef STEED
	u.usteed = (struct monst *)0;
#endif

#ifdef MICRO
# ifdef AMII_GRAPHICS
	{
		extern struct window_procs amii_procs;
		if(windowprocs.win_init_nhwindows== amii_procs.win_init_nhwindows){
			extern winid WIN_BASE;
			clear_nhwindow(WIN_BASE);   /* hack until there's a hook for this */
		}
	}
# else
        clear_nhwindow(WIN_MAP);
# endif
        clear_nhwindow(WIN_MESSAGE);
#if 0 /*JP*/
	You("return to level %d in %s%s.",
	    depth(&u.uz), dungeons[u.uz.dnum].dname,
	    flags.debug ? " while in debug mode" :
	    flags.explore ? " while in explore mode" : "");
#else
	You("%s%sの地下%d階に戻ってきた．",
	    flags.debug ? "ウィザードモード中の" :
	    flags.explore ? "探検モード中の" : "",
	    jtrns_obj('d',dungeons[u.uz.dnum].dname), depth(&u.uz));
#endif
	curs(WIN_MAP, 1, 1);
	dotcnt = 0;
	dotrow = 2;
	if (strncmpi("X11", windowprocs.name, 3))
		putstr(WIN_MAP, 0, "Restoring:");
#endif
}

static boolean
cheak_uid(uid)
int uid;
{
	if (uid != getuid()) {	/* strange ... */
		/* for wizard mode, issue a reminder; for others, treat it
		   as an attempt to cheat and refuse to restore this file */
#if 0 /*JP*/
		pline("Saved game was not yours.");
#else
		pline("セーブされたゲームはあなたのものではない．");
#endif
#ifdef WIZARD
		if (!wizard)
#endif
			return FALSE;
	}

	return TRUE;
}

static void
shuffle_non_fixed_unknown_name(first, last, domaterial)
int first, last;
boolean domaterial;
{
	int i, n, *work = (int *)alloc((last - first + 1) * sizeof(int));

	/* 未識別名の無いエントリを除外 */
	for (i = first, n = 0; i <= last; i++, n++) {
		if (objects[i].oc_name_known || !(obj_descr[i].oc_descr)) {
			work[n] = -1;
		} else
			work[n] = i;
	}

	/* 使用済の未識別名も除外 */
	for (i = first; i <= last; i++) {
		if (objects[i].oc_descr_idx >= 0 && !!(obj_descr[i].oc_name)) {
			work[objects[i].oc_descr_idx - first] = -1;
		}
	}

	/* 未使用の未識別名のカウント & work[] の packing */
	for (i = 0, n = 0; i < last - first + 1; i++) {
		if (work[i] >= 0)
			work[n++] = work[i];
	}

	if (n == 0) {
		free(work);
		return;
	}

	for (i = first; i <= last; i++) {
		int j, r = 0;

		if (!!(obj_descr[i].oc_name) && objects[i].oc_descr_idx >= 0)
			continue;

		if (n != 0)
			r = rn2(n);
		j = work[r];

		objects[i].oc_descr_idx = j;

		objects[i].oc_tough = orignal_objclass_prop[j].oc_tough;
		objects[i].oc_color = orignal_objclass_prop[j].oc_color;

		/* shuffle material */
		if (domaterial) {
			objects[i].oc_material = orignal_objclass_prop[j].oc_material;
		}

		n--;
		work[r] = work[n];
	}

	free(work);
}

static void
pre_rest_level_data()
{
	nroom = 0;
	nsubroom = 0;
	doorindex = 0;

	current_stat.u.leveldata.omoves = &omoves;

	if (ghostly)
		clear_id_mapping();
}

static void
post_rest_level_data(lev)
int lev;
{
	struct monst *mtmp;

	rooms[nroom].hx = -1;		/* restore ending flags */
	subrooms[nsubroom].hx = -1;

	/* reset level.monsters for new level */
	for (mtmp = level.monlist; mtmp; mtmp = mtmp->nmon) {
		if (mtmp->isshk)
			set_residency(mtmp, FALSE);
		place_monster(mtmp, mtmp->mx, mtmp->my);
		if (mtmp->wormno) place_wsegs(mtmp);
	}

	if (ghostly) {
		branch *br;

		/* Now get rid of all the temp fruits... */
		freefruitchn(oldfruit),  oldfruit = 0;

		if (lev > ledger_no(&medusa_level) &&
		    lev < ledger_no(&stronghold_level) && xdnstair == 0) {
			coord cc;

			mazexy(&cc);
			xdnstair = cc.x;
			ydnstair = cc.y;
			levl[cc.x][cc.y].typ = STAIRS;
		}

		br = Is_branchlev(&u.uz);
		if (br && u.uz.dlevel == 1) {
			d_level ltmp;

			if (on_level(&u.uz, &br->end1))
				assign_level(&ltmp, &br->end2);
			else
				assign_level(&ltmp, &br->end1);

			switch(br->type) {
			case BR_STAIR:
			case BR_NO_END1:
			case BR_NO_END2:	/* OK to assign to sstairs if it's not used */
				assign_level(&sstairs.tolev, &ltmp);
				break;              
			case BR_PORTAL: /* max of 1 portal per level */
			{
				register struct trap *ttmp;
				for(ttmp = ftrap; ttmp; ttmp = ttmp->ntrap)
					if (ttmp->ttyp == MAGIC_PORTAL)
						break;
				if (!ttmp) panic("getlev: need portal but none found");
				assign_level(&ttmp->dst, &ltmp);
			}
			break;
			}
		} else if (!br) {
			/* Remove any dangling portals. */
			register struct trap *ttmp;
			for (ttmp = ftrap; ttmp; ttmp = ttmp->ntrap)
				if (ttmp->ttyp == MAGIC_PORTAL) {
					deltrap(ttmp);
					break; /* max of 1 portal/level */
				}
		}
	}

	/* must come after all mons & objs are restored */
	relink_timers(ghostly);
	relink_light_sources(ghostly);
	reset_oattached_mids(ghostly);

	if (ghostly)
		clear_id_mapping();
}

static void
post_rest_timer_data()
{
	timer_element *curr = current_stat.u.timer.timer;

	if (curr) {
		if (ghostly)
			curr->timeout += (monstermoves - omoves);

		curr->needs_fixup = TRUE;
		insert_timer(curr);
	}
}

static void
post_rest_light_data()
{
	light_source *ls = (light_source *)(current_stat.tmp.p);
	light_source **base = (light_source **)(var_info_light_c[VARIABLE_ID_LIGHT_C__LIGHT_BASE].ptr);

	if (ls && base) {
		ls->next = *base;
		*base = ls;
	}
}

static genericptr_t
pre_rest_objects(current, id, var_id, frozen)
struct restore_stat_t *current;
int id;
int var_id;
boolean *frozen;
{
	genericptr_t ptr = NULL;

	switch(var_id) {
	case VARIABLE_ID_SAVE_C__BILLOBJS:
	case VARIABLE_ID_SAVE_C__FOBJ:
	case VARIABLE_ID_SAVE_C__INVENT:
	case VARIABLE_ID_SAVE_C__LEVEL_BURIEDOBJLIST:
	case VARIABLE_ID_SAVE_C__LEVEL_OBJLIST:
	case VARIABLE_ID_SAVE_C__MIGRATING_OBJS:
		ptr = struct_info[STRUCTURE_OBJECTS].var_info[var_id].ptr;
		break;
	case VARIABLE_ID_SAVE_C__CONTENTS:
		if (id == STRUCTURE_OBJECT && current->u.obj.otmp) {
			ptr = (genericptr_t)(&(((struct obj *)current->u.obj.otmp)->cobj));
			*frozen = Is_IceBox((struct obj *)current->u.obj.otmp);
		}
		break;
	case VARIABLE_ID_SAVE_C__MTMP__MINVENT:
		if (id == STRUCTURE_MONSTER)
			ptr = (genericptr_t)(&(current->u.mon.minvent));
		break;
	default:
		ptr = NULL;
		break;
	}

	return ptr;
}

static void
post_rest_objects(olist, var_id)
struct obj **olist;
int var_id;
{
	struct obj *otmp;

	if (!olist)
		return;

	switch(var_id) {
	case VARIABLE_ID_SAVE_C__FOBJ:
	case VARIABLE_ID_SAVE_C__LEVEL_OBJLIST:
		find_lev_obj();
		break;
	case VARIABLE_ID_SAVE_C__INVENT:
		/* this comes after inventory has been loaded */
		for(otmp = invent; otmp; otmp = otmp->nobj)
			if(otmp->owornmask)
				setworn(otmp, otmp->owornmask);
			/* reset weapon so that player will get a reminder about "bashing"
			   during next fight when bare-handed or wielding an unconventional
			   item; for pick-axe, we aren't able to distinguish between having
			   applied or wielded it, so be conservative and assume the former */
		otmp = uwep;	/* `uwep' usually init'd by setworn() in loop above */
		uwep = 0;	/* clear it and have setuwep() reinit */
		setuwep(otmp);	/* (don't need any null check here) */
		if (!uwep || uwep->otyp == PICK_AXE || uwep->otyp == GRAPPLING_HOOK)
			unweapon = TRUE;
		break;
	}
}

static genericptr_t
pre_rest_monsters(current, id, var_id)
struct restore_stat_t *current;
int id;
int var_id;
{
	genericptr_t ptr = NULL;

	switch(var_id) {
	case VARIABLE_ID_SAVE_C__FMON:
	case VARIABLE_ID_SAVE_C__LEVEL_MONLIST:
	case VARIABLE_ID_SAVE_C__MIGRATING_MONS:
		ptr = struct_info[STRUCTURE_MONSTERS].var_info[var_id].ptr;
		break;
	case VARIABLE_ID_SAVE_C__OEXTRA:
		if (id == STRUCTURE_OBJECT) {
			ptr = (genericptr_t)(&(current->tmp.p));
			current->tmp.p = 0;
		}
		break;
	default:
		ptr = NULL;
		break;
	}

	return ptr;
}

static void
post_rest_monsters(mlist, var_id)
struct monst **mlist;
int var_id;
{
	struct monst *mtmp, *mtmp2;

	if (!mlist)
		return;

	switch(var_id) {
	case VARIABLE_ID_SAVE_C__FMON:
	case VARIABLE_ID_SAVE_C__LEVEL_MONLIST:
		if (!u.uz.dlevel)
			break;
		for (mtmp = fmon; mtmp; mtmp = mtmp2) {
			mtmp2 = mtmp->nmon;
			if (ghostly) {
				/* reset peaceful/malign relative to new character */
				if(!mtmp->isshk)
					/* shopkeepers will reset based on name */
					mtmp->mpeaceful = peace_minded(mtmp->data);
				set_malign(mtmp);
			} else if (monstermoves > omoves)
				mon_catchup_elapsed_time(mtmp, monstermoves - omoves);

			/* update shape-changers in case protection against
			   them is different now than when the level was saved */
			restore_cham(mtmp);
		}
		break;
	}
}

static int
post_rest_savedata()
{
	char whynot[BUFSZ];
	int rfd = open_levelfile(ledger_no(&u.uz), whynot);

	if (rfd < 0) {
		HUP pline("%s", whynot);
		(void) close(rfd);
		(void) delete_savefile();
		HUP killer = whynot;
		HUP done(TRICKED);

		return rfd;
	}

	getlev(rfd, hackpid, ledger_no(&u.uz), FALSE);

	close(rfd);

	return rfd;
}

static int
pre_bonedata(oldbonesid)
const char *oldbonesid;
{
#ifdef BONE_FILE_XML
	if (strcmp(reading_bonesid, oldbonesid) != 0) {
		char errbuf[BUFSZ];

		Sprintf(errbuf, "This is bones level '%s', not '%s'!",
			oldbonesid, reading_bonesid);
#ifdef WIZARD
		if (wizard) {
			pline("%s", errbuf);
		}
#endif
		trickery(errbuf);

		return 0;
	} else {
		return 1;
	}
#else
	impossible("restore_xml: unsupported format");
	return 0;
#endif
}

static int
post_bonedata()
{
#ifdef BONE_FILE_XML
	struct monst *mtmp;

	/* Note that getlev() now keeps tabs on unique
	 * monsters such as demon lords, and tracks the
	 * birth counts of all species just as makemon()
	 * does.  If a bones monster is extinct or has been
	 * subject to genocide, their mhpmax will be
	 * set to the magic DEFUNCT_MONSTER cookie value.
	 */
	for(mtmp = fmon; mtmp; mtmp = mtmp->nmon) {
	    if (mtmp->mhpmax == DEFUNCT_MONSTER) {
#if defined(DEBUG) && defined(WIZARD)
		if (wizard)
		    pline("Removing defunct monster %s from bones.",
			mtmp->data->mname);
#endif
		mongone(mtmp);
	    } else
		/* to correctly reset named artifacts on the level */
		resetobjs(mtmp->minvent,TRUE);
	}
	resetobjs(fobj,TRUE);
	resetobjs(level.buriedobjlist,TRUE);

	return 1;
#else
	return -1;
#endif /* BONE_FILE_XML */
}

static void
post_rest_game_stat()
{
	/* must come after all mons & objs are restored */
	relink_timers(FALSE);
	relink_light_sources(FALSE);

	restlevelstate(stuckid, steedid);
}

static void
post_rest_object1(otmp)
struct obj *otmp;
{
	if (current_stat.u.obj.oname) {
		free(current_stat.u.obj.oname);
		if (otmp)
			impossible("restore_xml: don't restore object name!");
	}
}

static void
post_rest_object2(otmp)
struct obj *otmp;
{
	otmp->oartifact = current_stat.u.obj.oartifact;
	otmp->corpsenm = current_stat.u.obj.corpsenm;
	otmp->otyp = current_stat.u.obj.otyp;
	otmp->oclass = current_stat.u.obj.oclass;
}

static void
post_rest_object3(otmp)
struct obj *otmp;
{
	struct obj **targ;
	boolean frozen = current_stat.u.objects.frozen;

	if (!otmp)
		return;

	if (!!(targ = (struct obj **)current_stat.ptr)) {
		otmp->nobj = *targ;
		*targ = otmp;
	}

	if (ghostly) {
		unsigned nid = flags.ident++;
		add_id_mapping(otmp->o_id, nid);
		otmp->o_id = nid;
	}
	if (ghostly && otmp->otyp == SLIME_MOLD) ghostfruit(otmp);
	/* Ghost levels get object age shifted from old player's clock
	 * to new player's clock.  Assumption: new player arrived
	 * immediately after old player died.
	 */
	if (ghostly && !frozen && !age_is_relative(otmp))
		otmp->age = monstermoves - omoves + otmp->age;

	/* get contents of a container or statue */
	if (Has_contents(otmp)) {
		struct obj *otmp3;

		/* restore container back pointers */
		for (otmp3 = otmp->cobj; otmp3; otmp3 = otmp3->nobj)
			otmp3->ocontainer = otmp;
	}
	otmp->bypass = 0;
}

static void
post_rest_obj_attach_data_mon()
{
	struct monst *mtmp = (struct monst *)current_stat.tmp.p;
	struct obj *otmp = current_stat.u.obj.otmp;

	if (mtmp && otmp) {
		struct monst *mtmp2;
		int lth = sizeof(struct monst) + mtmp->mxlth + mtmp->mnamelth;
		int namelth = otmp->onamelth ? strlen(ONAME(otmp)) + 1 : 0;

		otmp = newobj(namelth + lth);
		*otmp = *current_stat.u.obj.otmp;

		(void) memcpy((genericptr_t)otmp->oextra, (genericptr_t)mtmp, lth);
		otmp->oxlth = lth;

		if (namelth)
			Strcpy(ONAME(otmp), ONAME(current_stat.u.obj.otmp));
		otmp->onamelth = namelth;


		mtmp2 = (struct monst *)otmp->oextra;
		if (mtmp->data) mtmp2->mnum = monsndx(mtmp->data);
		mtmp2->nmon     = (struct monst *)0;
		mtmp2->data     = (struct permonst *)0;
		mtmp2->minvent  = (struct obj *)0;
		otmp->oattached = OATTACHED_MONST;	/* mark it */

		free((genericptr_t)current_stat.u.obj.otmp);
		current_stat.u.obj.otmp = otmp;
	}

	if (mtmp) dealloc_monst(mtmp);
}

static void
post_rest_obj_attach_data_val(val_id)
int val_id;
{
	int mid = current_stat.tmp.i;

	if (val_id == VARIABLE_ID_SAVE_C__M_ID && current_stat.u.obj.otmp && !!mid) {
		current_stat.u.obj.otmp = (genericptr_t)obj_attach_mid(current_stat.u.obj.otmp, mid);
	}
}

static void
post_rest_monster1(mtmp)
struct monst *mtmp;
{
	if (current_stat.u.mon.mname) {
		free(current_stat.u.mon.mname);
		if (mtmp)
			impossible("restore_xml: don't restore monster name!");
	}
}

static void
post_rest_monster2(mtmp)
struct monst *mtmp;
{
	struct obj *minvent = current_stat.u.mon.minvent;
	int mdata = current_stat.u.mon.data;

	if (!mtmp)
		return;

	mtmp->mnum = current_stat.u.mon.mnum;
	mtmp->data = mdata >= 0 ? &(mons[mdata]) : 0;

	if (mtmp->isgd) {
		if (mtmp->mxlth < sizeof(struct egd)) {
			mtmp->isgd = FALSE;
			impossible("restore_xml: don't restore egd!");
		}
	} else if (mtmp->ispriest) {
		if (mtmp->mxlth < sizeof(struct epri)) {
			mtmp->ispriest = FALSE;
			impossible("restore_xml: don't restore epri!");
		}
	} else if (mtmp->isshk) {
		if (mtmp->mxlth < sizeof(struct eshk)) {
			mtmp->isshk = FALSE;
			impossible("restore_xml: don't restore eshk!");
		}
	} else if (mtmp->isminion) {
		if (mtmp->mxlth < sizeof(struct emin)) {
			mtmp->isminion = FALSE;
			impossible("restore_xml: don't restore emin!");
		}
	} else if (mtmp->mtame) {
		if (mtmp->mxlth < sizeof(struct edog)) {
			mtmp->mtame = 0;
			impossible("restore_xml: don't restore edog!");
		}
	}

	if(!!(mtmp->minvent = minvent)) {
		struct obj *obj;

		/* restore monster back pointer */
		for (obj = mtmp->minvent; obj; obj = obj->nobj)
			obj->ocarry = mtmp;
	}
	if (ghostly) {
		unsigned nid = flags.ident++;
		int mndx = monsndx(mtmp->data);

		add_id_mapping(mtmp->m_id, nid);
		mtmp->m_id = nid;

		if (propagate(mndx, TRUE, ghostly) == 0) {
			/* cookie to trigger purge in getbones() */
			mtmp->mhpmax = DEFUNCT_MONSTER; 
		}
	}
	if (mtmp->mw) {
		struct obj *obj;

		for(obj = mtmp->minvent; obj; obj = obj->nobj)
			if (obj->owornmask & W_WEP) break;
		if (obj) mtmp->mw = obj;
		else {
			MON_NOWEP(mtmp);
			impossible("bad monster weapon restore");
		}
	}

	if (mtmp->isshk) restshk(mtmp, ghostly);
	if (mtmp->ispriest) restpriest(mtmp, ghostly);
}

static void
post_rest_monster3(mtmp)
struct monst *mtmp;
{
	struct monst **targ;

	if (!mtmp)
		return;

	if (!!(targ = (struct monst **)current_stat.ptr)) {
		mtmp->nmon = *targ;
		*targ = mtmp;
	}
}

static void
pre_rest_branches()
{
	*((branch **)(var_info_dungeon_c[VARIABLE_ID_DUNGEON_C__BRANCHES].ptr)) = (branch *) 0;
}

static void
post_rest_branches()
{
	branch *curr = (branch *)(current_stat.tmp.p);

	if (curr) {
		curr->next = (branch *) 0;
		if (current_stat.ptr)
			((branch *)current_stat.ptr)->next = curr;
		else
			*((branch **)(var_info_dungeon_c[VARIABLE_ID_DUNGEON_C__BRANCHES].ptr)) = curr;
		current_stat.ptr = (genericptr_t)curr;
	}
}

static void
pre_rest_levchn()
{
	sp_levchn = (s_level *) 0;
}

static void
post_rest_levchn()
{
	s_level *tmplev = (s_level *)(current_stat.tmp.p);

	if (tmplev) {
		tmplev->next = (s_level *)0;
		if (current_stat.ptr)
			((s_level *)current_stat.ptr)->next = tmplev;
		else
			sp_levchn = tmplev;
		current_stat.ptr =(genericptr_t)tmplev;
	}
}

static void
pre_rest_spell_book()
{
	current_stat.u.array.size = MAXSPELL;
}

static void
post_rest_spell_book()
{
	int index = current_stat.u.array.index < MAXSPELL ? current_stat.u.array.index : MAXSPELL;

	((struct spell *)current_stat.ptr)[index].sp_id = 0;
}

static genericptr_t
pre_rest_oracles(n)
int n;
{
	genericptr_t ptr = NULL;

	if (n > 0) {
		size_t size = n * sizeof (long);
		ptr = alloc(size);

		(void) memset(ptr, 0, size);
	}

	return ptr;
}

static void
pre_rest_fruits()
{
	current_stat.tmp.p = NULL;
	if (!ghostly) {
		freefruitchn(ffruit);		/* clean up fruit(s) made by initoptions() */
		ffruit = NULL;
	}
}

static void
post_rest_fruits()
{
	if (current_stat.tmp.p) {
		struct fruit *fnext = (struct fruit *)current_stat.tmp.p;

		if (!ghostly) {
			fnext->nextf = ffruit;
			ffruit = fnext;
		} else {
			fnext->nextf = oldfruit;
			oldfruit = fnext;
		}
	}
}

static void
pre_rest_objects_classes()
{
	int i;

	orignal_objclass_prop = (struct objclass_backup *)alloc(NUM_OBJECTS * sizeof(struct objclass_backup));

	for (i = 0; i < NUM_OBJECTS; i++) {
		objects[i].oc_name_idx = objects[i].oc_descr_idx = -1;

		orignal_objclass_prop[i].oc_tough	= objects[i].oc_tough;
		orignal_objclass_prop[i].oc_material	= objects[i].oc_material;
		orignal_objclass_prop[i].oc_color	= objects[i].oc_color;
	}
}

static void
post_rest_objects_classes()
{
	int oclass, i;

	for (oclass = 1; oclass < MAXOCLASSES; oclass++) {
		int first = bases[oclass],
			next = oclass < MAXOCLASSES - 1 ? bases[oclass + 1] : NUM_OBJECTS,
			sum;

		/* adjust unknown names */
		switch(oclass) {
		case TOOL_CLASS:
		case WEAPON_CLASS:
		case GEM_CLASS:
			/* No shuffle */
			break;

		case ARMOR_CLASS:
			/* shuffle the helmets */
			shuffle_non_fixed_unknown_name(HELMET, HELM_OF_TELEPATHY, FALSE);

			/* shuffle the gloves */
			shuffle_non_fixed_unknown_name(LEATHER_GLOVES, GAUNTLETS_OF_DEXTERITY, FALSE);

			/* shuffle the cloaks */
			shuffle_non_fixed_unknown_name(CLOAK_OF_PROTECTION, CLOAK_OF_DISPLACEMENT, FALSE);

			/* shuffle the boots [if they change, update find_skates() below] */
			shuffle_non_fixed_unknown_name(SPEED_BOOTS, LEVITATION_BOOTS, FALSE);
			break;

		case POTION_CLASS:
			/* only water has a fixed description */
			shuffle_non_fixed_unknown_name(first, next - 2, TRUE);
			break;

		case AMULET_CLASS:
		case SCROLL_CLASS:
		case SPBOOK_CLASS:
			{
				int j = next - 1;

				while (!objects[j].oc_magic || objects[j].oc_unique)
					j--;

				shuffle_non_fixed_unknown_name(first, j, TRUE);
			}
			break;

		default:
			if (!!(obj_descr[first].oc_descr))
				shuffle_non_fixed_unknown_name(first, next - 1, TRUE);
			break;
		}

		for (i = first; i < next; i++) {
			if (objects[i].oc_name_idx < 0)
				objects[i].oc_name_idx = i;

			if (objects[i].oc_descr_idx < 0)
				objects[i].oc_descr_idx = objects[i].oc_name_idx;
		}

	check:
		/* generation probability cheak */
		sum = 0;
		for(i = first; i < next; i++) sum += objects[i].oc_prob;
		if(sum == 0) {
			for(i = first; i < next; i++)
				objects[i].oc_prob = (1000+i-first)/(next-first);
			goto check;
		}
		if(sum != 1000)
			error("init-prob error for class %d (%d%%)", oclass, sum);
	}

	free(orignal_objclass_prop);

#ifdef USE_TILES
	shuffle_tiles_xml();
#endif
}

static void
pre_struct_mapseen()
{
	current_stat.skip = TRUE;
	current_stat.ignore = TRUE;
}

static void
post_struct_mapseen()
{
}

struct var_info_t var_info_restore_xml_y[] = {
	REGIST_VAR_INFO( "max_mon",		&max_mon,	int),
	REGIST_VAR_INFO( "max_obj",		&max_obj,	int),
	REGIST_VAR_INFO( "max_objclass",	&max_objclass,	int),
};
