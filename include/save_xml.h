/*	SCCS Id: @(#)save_xml.h	3.4	2006/04/10	*/
/* Copyright (c) Kiyotomo Ide, 2006.				  */
/* NetHack may be freely redistributed.  See license for details. */

#ifndef SAVE_XML_H
#define SAVE_XML_H

#include "hack.h"

#ifdef SAVE_FILE_XML

#include "lev.h"
#include "edog.h"
#include "emin.h"
#include "epri.h"
#include "eshk.h"
#include "vault.h"

#define NUMTMPBUF 16

#define MAX_STATE_STACK 32

#define XML_FILE_MAGIC		"<SAVEDATA>"
#define XML_FILE_MAGIC_LEN	10

#define XML_FILE_BONE_MAGIC	"<BONEDATA id=\""
#define XML_FILE_BONE_MAGIC_LEN	14

#define XMLTAG_ARRAY_BGN(fd, id, num)		fd_printf(fd, "<ARRAY id=\"%s\" num=%d>\n", id, num)
#define XMLTAG_ARRAY_END(fd)			fd_printf(fd, "</ARRAY>\n")
#define XMLTAG_STRUCT_BGN(fd, typ, id)		fd_printf(fd, "<STRUCT type=\"%s\" id=\"%s\">\n", typ, id)
#define XMLTAG_STRUCT_END(fd)			fd_printf(fd, "</STRUCT>\n")

#define XMLTAG_GLYPH_BGN(fd, typ, id)		fd_printf(fd, "<GLYPH type=\"%s\" id=\"%s\">\n", typ, id)
#define XMLTAG_GLYPH_END(fd)			fd_printf(fd, "</GLYPH>\n")

#define XMLTAG_RM_TYPE(fd, id, val)		fd_printf(fd, "<RM_TYPE id=\"%s\">%s</RM_TYPE>\n", id, val)

#define XMLTAG_ROLE(fd, id, val)		fd_printf(fd, "<ROLE id=\"%s\">%s</ROLE>\n", id, val)
#define XMLTAG_RACE(fd, id, val)		fd_printf(fd, "<RACE id=\"%s\">%s</RACE>\n", id, val)
#define XMLTAG_GENDER(fd, id, val)		fd_printf(fd, "<GENDER id=\"%s\">%s</GENDER>\n", id, val)
#define XMLTAG_ALIGN(fd, id, val)		fd_printf(fd, "<ALIGN id=\"%s\">%s</ALIGN>\n", id, val)
#ifdef RANDOM_QUEST	/* quest change test [IDE]*/
#define XMLTAG_QUEST(fd, id, val)		fd_printf(fd, "<QUEST id=\"%s\">%s</QUEST>\n", id, val)
#endif /* RANDOM_QUEST */

/* for save levl data */
#define XMLTAG_RM_BACKGROUND_BGN(fd)		fd_printf(fd, "<RM_BACKGROUND>\n")
#define XMLTAG_RM_BACKGROUND_END(fd)		fd_printf(fd, "</RM_BACKGROUND>\n")
#define XMLTAG_RM_REGION_BGN(fd,x0, y0, x1, y1)	fd_printf(fd, "<RM_REGION region=%d,%d,%d,%d>\n", x0, y0, x1, y1)
#define XMLTAG_RM_REGION_END(fd)		fd_printf(fd, "</RM_REGION>\n")
#define XMLTAG_RM_POINTER(fd, id, x, y)		fd_printf(fd, "<RM_POINTER id=\"%s\">%d,%d</RM_POINTER>\n", id, x, y)

#define XMLTAG_ARTIFACT_BGN(fd, id)		fd_printf(fd, "<ARTIFACT id=\"%s\">\n", escape_string(id))
#define XMLTAG_ARTIFACT_END(fd)			fd_printf(fd, "</ARTIFACT>\n")
#define XMLTAG_ARTIFACTS_BGN(fd)		fd_printf(fd, "<ARTIFACTS>\n")
#define XMLTAG_ARTIFACTS_END(fd)		fd_printf(fd, "</ARTIFACTS>\n")
#define XMLTAG_BONEDATA_BGN(fd, id)		fd_printf(fd, "<BONEDATA id=\"%s\">\n", id)
#define XMLTAG_BONEDATA_END(fd)			fd_printf(fd, "</BONEDATA>\n")
#define XMLTAG_BRANCHES_BGN(fd, num)		fd_printf(fd, "<BRANCHES num=%d>\n", num)
#define XMLTAG_BRANCHES_END(fd)			fd_printf(fd, "</BRANCHES>\n")
#define XMLTAG_BUBBLES_BGN(fd, num)		fd_printf(fd, "<BUBBLES num=%d>\n", num)
#define XMLTAG_BUBBLES_END(fd)			fd_printf(fd, "</BUBBLES>\n")
#define XMLTAG_CONTENTS_BGN(fd)			fd_printf(fd, "<CONTENTS>\n")
#define XMLTAG_CONTENTS_END(fd)			fd_printf(fd, "</CONTENTS>\n")
#define XMLTAG_CURRENT_STAT_BGN(fd)		fd_printf(fd, "<CURRENT_STAT>\n")
#define XMLTAG_CURRENT_STAT_END(fd)		fd_printf(fd, "</CURRENT_STAT>\n")
#define XMLTAG_DAMAGES_BGN(fd, num)		fd_printf(fd, "<DAMAGES num=%d>\n", num)
#define XMLTAG_DAMAGES_END(fd)			fd_printf(fd, "</DAMAGES>\n")
#define XMLTAG_DUNGEON_BGN(fd)			fd_printf(fd, "<DUNGEON>\n")
#define XMLTAG_DUNGEON_END(fd)			fd_printf(fd, "</DUNGEON>\n")
#define XMLTAG_DUNGEON_OVERVIEW_BGN(fd, num)	fd_printf(fd, "<DUNGEON_OVERVIEW num=%d>\n", num)
#define XMLTAG_DUNGEON_OVERVIEW_END(fd)		fd_printf(fd, "</DUNGEON_OVERVIEW>\n")
#define XMLTAG_ENGRAVINGS_BGN(fd)		fd_printf(fd, "<ENGRAVINGS>\n")
#define XMLTAG_ENGRAVINGS_END(fd)		fd_printf(fd, "</ENGRAVINGS>\n")
#define XMLTAG_FLOOR_BGN(fd, x, y)		fd_printf(fd, "<FLOOR id=\"levl\" size=%d,%d>\n", x, y)
#define XMLTAG_FLOOR_END(fd)			fd_printf(fd, "</FLOOR>\n")
#define XMLTAG_FRUITS_BGN(fd)			fd_printf(fd, "<FRUITS>\n")
#define XMLTAG_FRUITS_END(fd)			fd_printf(fd, "</FRUITS>\n")
#define XMLTAG_GAMESTAT_BGN(fd)			fd_printf(fd, "<GAMESTAT>\n")
#define XMLTAG_GAMESTAT_END(fd)			fd_printf(fd, "</GAMESTAT>\n")
#define XMLTAG_LAUNCH_BGN(fd)			fd_printf(fd, "<LAUNCH>\n")
#define XMLTAG_LAUNCH_END(fd)			fd_printf(fd, "</LAUNCH>\n")
#define XMLTAG_LEVCHN_BGN(fd, num)		fd_printf(fd, "<LEVCHN num=%d>\n", num)
#define XMLTAG_LEVCHN_END(fd)			fd_printf(fd, "</LEVCHN>\n")
#define XMLTAG_LEVELDATA_BGN(fd, num)		fd_printf(fd, "<LEVELDATA id=%d>\n", num)
#define XMLTAG_LEVELDATA_END(fd)		fd_printf(fd, "</LEVELDATA>\n")
#define XMLTAG_LEVELS_BGN(fd)			fd_printf(fd, "<LEVELS>\n")
#define XMLTAG_LEVELS_END(fd)			fd_printf(fd, "</LEVELS>\n")
#define XMLTAG_LIGHT_SOURCES_BGN(fd, num)	fd_printf(fd, "<LIGHT_SOURCES num=%d>\n", num)
#define XMLTAG_LIGHT_SOURCES_END(fd)		fd_printf(fd, "</LIGHT_SOURCES>\n")
#define XMLTAG_MONSTER_BGN(fd)			fd_printf(fd, "<MONSTER>\n")
#define XMLTAG_MONSTER_END(fd)			fd_printf(fd, "</MONSTER>\n")
#define XMLTAG_MONSTERS_BGN(fd, id)		fd_printf(fd, "<MONSTERS id=\"%s\">\n", escape_string(id))
#define XMLTAG_MONSTERS_END(fd)			fd_printf(fd, "</MONSTERS>\n")
#define XMLTAG_MON_EXTRA_DATA_BGN(fd)		fd_printf(fd, "<MON_EXTRA_DATA>\n")
#define XMLTAG_MON_EXTRA_DATA_END(fd)		fd_printf(fd, "</MON_EXTRA_DATA>\n")
#define XMLTAG_OBJECT_BGN(fd)			fd_printf(fd, "<OBJECT>\n")
#define XMLTAG_OBJECT_END(fd)			fd_printf(fd, "</OBJECT>\n")
#define XMLTAG_OBJECTS_BGN(fd, id)		fd_printf(fd, "<OBJECTS id=\"%s\">\n", escape_string(id))
#define XMLTAG_OBJECTS_END(fd)			fd_printf(fd, "</OBJECTS>\n")
#define XMLTAG_OBJECT_CLASS_BGN(fd)		fd_printf(fd, "<OBJECT_CLASS>\n")
#define XMLTAG_OBJECT_CLASS_END(fd)		fd_printf(fd, "</OBJECT_CLASS>\n")
#define XMLTAG_OBJECT_CLASSES_BGN(fd)		fd_printf(fd, "<OBJECT_CLASSES>\n")
#define XMLTAG_OBJECT_CLASSES_END(fd)		fd_printf(fd, "</OBJECT_CLASSES>\n")
#define XMLTAG_OBJ_ATTACHED_BGN(fd, typ)	fd_printf(fd, "<OBJ_ATTACHED type=\"%s\">\n", typ)
#define XMLTAG_OBJ_ATTACHED_END(fd)		fd_printf(fd, "</OBJ_ATTACHED>\n")
#define XMLTAG_ORACLES_BGN(fd, num)		fd_printf(fd, "<ORACLES num=%u>\n", num)
#define XMLTAG_ORACLES_END(fd)			fd_printf(fd, "</ORACLES>\n")
#define XMLTAG_PROPERTY_BGN(fd)			fd_printf(fd, "<PROPERTY>\n")
#define XMLTAG_PROPERTY_END(fd)			fd_printf(fd, "</PROPERTY>\n")
#define XMLTAG_REGIONS_BGN(fd)			fd_printf(fd, "<REGIONS>\n")
#define XMLTAG_REGIONS_END(fd)			fd_printf(fd, "</REGIONS>\n")
#define XMLTAG_ROOM_BGN(fd)			fd_printf(fd, "<ROOM>\n")
#define XMLTAG_ROOM_END(fd)			fd_printf(fd, "</ROOM>\n")
#define XMLTAG_SUBROOM_BGN(fd, num)		fd_printf(fd, "<SUBROOM num=%d>\n", num)
#define XMLTAG_SUBROOM_END(fd)			fd_printf(fd, "</SUBROOM>\n")
#define XMLTAG_SAVEDATA_BGN(fd)			fd_printf(fd, "<SAVEDATA>\n")
#define XMLTAG_SAVEDATA_END(fd)			fd_printf(fd, "</SAVEDATA>")
#define XMLTAG_SPELL_BOOK_BGN(fd, id)		fd_printf(fd, "<SPELL_BOOK id=\"%s\">\n", id)
#define XMLTAG_SPELL_BOOK_END(fd)		fd_printf(fd, "</SPELL_BOOK>\n")
#define XMLTAG_TIMER_BGN(fd, typ)		fd_printf(fd, "<TIMER type=\"%s\">\n", typ)
#define XMLTAG_TIMER_END(fd)			fd_printf(fd, "</TIMER>\n")
#define XMLTAG_TIMERS_BGN(fd, num)		fd_printf(fd, "<TIMERS num=%d>\n", num)
#define XMLTAG_TIMERS_END(fd)			fd_printf(fd, "</TIMERS>\n")
#define XMLTAG_TRAPS_BGN(fd)			fd_printf(fd, "<TRAPS>\n")
#define XMLTAG_TRAPS_END(fd)			fd_printf(fd, "</TRAPS>\n")
#define XMLTAG_VERSION_BGN(fd)			fd_printf(fd, "<VERSION>\n")
#define XMLTAG_VERSION_END(fd)			fd_printf(fd, "</VERSION>\n")
#define XMLTAG_WATERLEBEL_BGN(fd)		fd_printf(fd, "<WATERLEBEL>\n")
#define XMLTAG_WATERLEBEL_END(fd)		fd_printf(fd, "</WATERLEBEL>\n")
#define XMLTAG_WORM_BGN(fd, id, wtime, num)	fd_printf(fd, "<WORM id=0x%x wgrowtime=%ld num=%d>\n", id, wtime, num)
#define XMLTAG_WORM_END(fd)			fd_printf(fd, "</WORM>\n")
#define XMLTAG_WORMS_BGN(fd)			fd_printf(fd, "<WORMS>\n")
#define XMLTAG_WORMS_END(fd)			fd_printf(fd, "</WORMS>\n")
#define XMLTAG_WORM_SEGMENT_BGN(fd)		fd_printf(fd, "<WORM_SEGMENT>\n")
#define XMLTAG_WORM_SEGMENT_END(fd)		fd_printf(fd, "</WORM_SEGMENT>\n")

#define XML_SAVE_STRING(fd, id, val)		fd_printf(fd, "<STRING id=\"%s\">%s</STRING>\n", id, val)
#define XML_SAVE_OBJ_NAME(fd, class, i, name)	fd_printf(fd, "<OBJ_NAME class=\"%s\" index=%d>%s</OBJ_NAME>\n", class, i, name)
#define XML_SAVE_OBJ_UNKNOWN_NAME(fd, c, otyp)	fd_printf(fd, "<OBJ_UNKNOWN_NAME class=\"%s\" index=%d>%s</OBJ_UNKNOWN_NAME>\n", c, otyp,\
								escape_string(obj_descr[objects[otyp].oc_descr_idx].oc_descr))
#define XML_SAVE_MONSTER_NAME(fd, id, c, i, mn)	fd_printf(fd, "<MONS_NAME class=\"%s\" index=%d id=\"%s\">%s</MONS_NAME>\n", c, i, id, mn)
#define XML_SAVE_CMAP_NAME(fd, cmap)		fd_printf(fd, "<CMAP>%s</CMAP>\n", cmap)

#define save_bitfields_xml(fd, id, bits, val)	fd_printf(fd, "<BITFIELDS bits=%d id=\"%s\">0x%x</BITFIELDS>\n", bits, id, val)
#define save_bool_xml(fd, id, val)		fd_printf(fd, "<BOOL id=\"%s\">%s</BOOL>\n", id, (val) ? "true" : "false")

#define save_char_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"char\" id=\"%s\">%hhd</VAL>\n", id, val)
#define save_schar_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"schar\" id=\"%s\">%hhd</VAL>\n", id, val)
#define save_uchar_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"uchar\" id=\"%s\">0x%hhx</VAL>\n", id, val)
#define save_int_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"int\" id=\"%s\">%d</VAL>\n", id, val)
#define save_uint_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"uint\" id=\"%s\">0x%x</VAL>\n", id, val)
#define save_short_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"short\" id=\"%s\">%hd</VAL>\n", id, val)
#define save_ushort_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"ushort\" id=\"%s\">0x%hx</VAL>\n", id, val)
#define save_long_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"long\" id=\"%s\">%ld</VAL>\n", id, val)
#define save_ulong_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"ulong\" id=\"%s\">0x%lx</VAL>\n", id, val)

#ifndef WIN32
# define save_time_t_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"time_t\" id=\"%s\">%lld</VAL>\n", id, (long long)(val))
#else
# define save_time_t_xml(fd, id, val)		fd_printf(fd, "<VAL type=\"time_t\" id=\"%s\">%I64d</VAL>\n", id, (__int64)(val))
#endif

#define save_objclass_name_xml(fd, otyp)	fd_printf(fd, "<OBJCLASS index=%d>%s</OBJCLASS>\n",(int)objects[otyp].oc_class,\
							escape_string(oclass_names_xml[(int)objects[otyp].oc_class]))

#define save_comment_xml(fd, val)		fd_printf(fd, "<COMMENT>%s</COMMENT>\n", val)

/* worm segment structure */
struct wseg {
	struct wseg *nseg;
	xchar  wx, wy;	/* the segment's position */
};

struct var_info_t {
	const char *name;
	genericptr_t ptr;
};

struct struct_info_t {
	const char *name;
	int num_var;
	struct var_info_t *var_info;
};

struct name_info_t {
	const char *name;
	int num;
};

struct restore_stat_t {
	int id;
	genericptr_t ptr;
	boolean skip;
	boolean ignore;
	union {
		struct {
			int var_id;
			int index;
			int size;
			int type;
		} array;
		struct version_info vers_info;
		struct {
			int otyp;
			int oclass;
			int ounknownnm;
			boolean read_prob;
		} objclass;
		struct {
			int var_id;
			boolean frozen;
		} objects;
		struct {
			int otyp;
			int oclass;
			int oartifact;
			char *oname;
			int corpsenm;
			struct obj *otmp;
		} obj;
		struct {
			int var_id;
		} monsters;
		struct {
			int mnum;
			int data;
			int mclass;
			int dclass;
			char *mname;
			struct monst *mtmp;
			struct obj *minvent;
		} mon;
		struct {
			int range;
			timer_element *timer;
		} timer;
		struct {
			long *omoves;
			int pid;
		} leveldata;
		struct {
			int id;
			int n_segs;
			xchar wx, wy;
			struct wseg *seg;
		} worm;
		struct {
			int uid;
			unsigned int *stuckid, *steedid;
		} gamestat;
#ifdef D_OVERVIEW	/*Dungeon Map Overview 3 [IDE]*/
		struct {
			int branchnum;
			mapseen *last_ms;
		} mapseen;
#endif /*D_OVERVIEW*/

		int current_level;
	} u;
	union {
		int i;
		long l;
		genericptr_t p;
		boolean b;
	} tmp;
};

#define REGIST_VAR_INFO(name, addr, type)	{name, addr}

#define E extern

/* ### save_xml.c ### */

E void VDECL(fd_printf,			(int, const char *,...)) PRINTF_F(2,3);
E void FDECL(save_octet_xml,		(int, const char *, genericptr_t, int));
E void FDECL(save_object_name_xml,	(int, int));
E void FDECL(save_monster_name_xml,	(int, const char *, int));
E void FDECL(save_string_xml,		(int, const char *, const char *));
E char * FDECL(num2str,			(int));
E char * FDECL(escape_string,		(const char *));
E char * NDECL(gettmpbuf);

E void FDECL(save_flag_xml,		(int, const char *, struct flag *));
E void FDECL(save_you_xml,		(int, const char *, struct you *));
E void FDECL(savemvitals_xml,		(int, const char *, struct mvitals *));
E void FDECL(save_q_score_xml,		(int, const char *, struct q_score *));
E void FDECL(save_spl_book_xml,		(int, const char *, struct spell *));
E void FDECL(save_rm_xml,		(int, const char *, struct rm *));
E void FDECL(save_stairway_xml,		(int, const char *, struct stairway *));
E void FDECL(save_dest_area_xml,	(int, const char *, dest_area *));
E void FDECL(save_levelflags_xml,	(int, const char *, struct levelflags *));
E void FDECL(savedoors_xml,		(int, const char *, coord *));
E void FDECL(save_timer_element_xml,	(int, const char *, timer_element *));
E void FDECL(save_dungeon_xml,		(int, const char *, dungeon *));
E void FDECL(save_dgn_topology_xml,	(int, const char *, struct dgn_topology *));
E void FDECL(save_branch_xml,		(int, const char *, branch *));
E void FDECL(save_coord_xml,		(int, const char *, coord *));
E void FDECL(save_linfo_xml,		(int, const char *, struct linfo *));
E void FDECL(save_s_level_xml,		(int, const char *, s_level *));
E void FDECL(save_fruit_xml,		(int, const char *, struct fruit *));
E void FDECL(save_objclass_xml,		(int, const char *, struct objclass *));
E void FDECL(save_mkroom_xml,		(int, const char *, struct mkroom *));
E void FDECL(save_trap_xml,		(int, const char *, struct trap *));
E void FDECL(save_engr_xml,		(int, const char *, struct engr *));
E void FDECL(save_damage_xml,		(int, const char *, struct damage *));
E void FDECL(save_NhRegion_xml,		(int, const char *, NhRegion *));
E void FDECL(save_obj_xml,		(int, const char *, struct obj *));
E void FDECL(save_monst_xml,		(int, const char *, struct monst *));
E void FDECL(save_edog_xml,		(int, const char *, struct edog *));
E void FDECL(save_emin_xml,		(int, const char *, struct emin *));
E void FDECL(save_epri_xml,		(int, const char *, struct epri *));
E void FDECL(save_eshk_xml,		(int, const char *, struct eshk *));
E void FDECL(save_egd_xml,		(int, const char *, struct egd *));
E void FDECL(save_light_source_xml,	(int, const char *, light_source *));
E void FDECL(save_bubble_xml,		(int, const char *, struct bubble *));
E void FDECL(save_version_info_xml,	(int, const char *, struct version_info *));
#ifdef D_OVERVIEW	/*Dungeon Map Overview 3 [IDE]*/
E void FDECL(save_mapseen_xml,		(int, const char *, mapseen *));
#endif /*D_OVERVIEW*/

E struct struct_info_t struct_info[]; 
E struct name_info_t rm_type_info[];
E struct name_info_t cmap_info[];

E int is_savefile_format_xml;
E const char * const oclass_names_xml[];

/* ### restore_xml_core.c ### */

E int FDECL(cheak_save_file_format,	(genericptr_t, int));
E char * FDECL(unescape_string,		(const char *, BOOLEAN_P));
E int FDECL(serach_struct_id,		(const char *));
E int FDECL(serach_variable_id,		(struct var_info_t *, int, const char *));
E int FDECL(serach_name2num,		(struct name_info_t *, int, const char *));
E void NDECL(init_restore_xml_tables);
E int FDECL(mname_to_mnum,		(const char *, int));
E int FDECL(oname_to_otyp,		(const char *, int));
E int FDECL(oclassnm_to_oclass,		(const char *));
E int FDECL(ounknname_to_idx,		(const char *, int));

E genericptr_t FDECL(restore_core,	(struct restore_stat_t *, int, const char *, const char *, int *));

E int restore_file_format_xml;
#define RESTORE_FILE_IS_BINARY		0
#define RESTORE_FILE_IS_XML		1
#define BONE_FILE_IS_XML		2

E struct restore_stat_t  *restore_state_stack;
E int restore_state_stack_index;

/* ### restore_xml_yacc.c ### */

E int FDECL(dorecover_xml,		(int));
#ifdef BONE_FILE_XML
E int FDECL(getbones_xml,		(int, const char *));
#endif

/* ### japanese/jlib.c ### */

E const char * FDECL(str2ic_xml,	(const char *));
E const char * FDECL(ic2str_xml,	(const char *));

/* ### artifact.c ### */

E int FDECL(artname2artino,		(const char *));
E void FDECL(restore_artifact_xml,	(const char *, BOOLEAN_P));

/* ### bones.c ### */

E void FDECL(resetobjs,(struct obj *,BOOLEAN_P));

/* ### mkmaze.c ### */

E boolean was_waterlevel;	/* ugh... this shouldn't be needed */
E struct bubble *bbubbles, *ebubbles;
E uchar *bubble_bmask[];
E void FDECL(mv_bubble,			(struct bubble *,int,int,BOOLEAN_P));
E void NDECL(set_wportal);

/* ### o_init.c ### */

E void FDECL(restore_disco_xml,		(int, BOOLEAN_P));
E void NDECL(shuffle_tiles_xml);

/* ### restore.c ### */

E struct fruit *oldfruit;

E void NDECL(find_lev_obj);
E int FDECL(restlevelfile,		(int,XCHAR_P));
E void FDECL(add_id_mapping,		(unsigned, unsigned));
E void NDECL(clear_id_mapping);
E void FDECL(freefruitchn,		(struct fruit *));
E void FDECL(ghostfruit,		(struct obj *));
E void FDECL(reset_oattached_mids,	(BOOLEAN_P));
E void FDECL(restlevelstate,		(unsigned int, unsigned int));

/* ### role.c ### */

#ifdef RANDOM_QUEST /* quest change test [Ide]*/
E const struct Qdata qdatas[];
#endif /* RANDOM_QUEST */

/* ### rumors.c ### */

E void FDECL(restore_oracles_xml,	(unsigned, long *));

/* ### timeout.c ### */

E void FDECL(insert_timer, (timer_element *));

/* ### version.c ### */

E void FDECL(store_version_xml, (int));

/* ### worm.c ### */

#define newseg()	(struct wseg *) alloc(sizeof(struct wseg))

E struct wseg *wheads[MAX_NUM_WORMS];
E struct wseg *wtails[MAX_NUM_WORMS];
E long wgrowtime[MAX_NUM_WORMS];


/* var_info table */

E struct var_info_t var_info_save_c[];		/* save.c	*/
E struct var_info_t var_info_dungeon_c[];	/* dungeon.c	*/
E struct var_info_t var_info_engrave_c[];	/* engrave.c	*/
E struct var_info_t var_info_timeout_c[];	/* timeout.c	*/
E struct var_info_t var_info_region_c[];	/* region.c	*/
E struct var_info_t var_info_light_c[];		/* light.c	*/
E struct var_info_t var_info_mkmaze_c[];	/* mkmaze.c	*/
E struct var_info_t var_info_restore_xml_y[];	/* restore_xml.y*/

#undef E

#endif /* SAVE_FILE_XML */

#endif /* SAVE_XML_H */

