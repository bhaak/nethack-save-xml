#!/usr/bin/perl

# 内部名への変換マップ
%typedef = (
	    'boolean',			'bool',
	    'int',			'int',
	    'short',			'short',
	    'long',			'long',
	    'long long',		'llong',
	    'unsigned short',		'ushort',
	    'unsigned',			'uint',
	    'unsigned int',		'uint',
	    'unsigned long',		'ulong',
	    'char',			'char',
	    'schar',			'schar',
	    'unsigned char',		'uchar',
	    'uchar',			'uchar',
	    'xchar',			'char',
	    'const char',		'char',
	    'bitfields',		'bitfields',
	    'aligntyp',			'schar',

	    'struct align',		'align',
	    'align',			'align',
	    'struct d_level',		'd_level',
	    'd_level',			'd_level',
	    'struct prop',		'prop',
	    'struct u_event',		'u_event',
	    'struct u_have',		'u_have',
	    'struct u_conduct',		'u_conduct',
	    'struct skills',		'skills',
	    'time_t',			'time_t',
	    'struct mvitals',		'mvitals',
	    'struct q_score',		'q_score',
	    'struct rm',		'rm',
	    'struct stairway',		'stairway',
	    'struct dest_area',		'dest_area',
	    'dest_area',		'dest_area',
	    'struct spell',		'spell',
	    'struct levelflags',	'levelflags',
	    'struct nhcoord',		'coord',
	    'coord',			'coord',
	    'struct fe',		'timer_element',
	    'timer_element',		'timer_element',
	    'struct ls_t',		'light_source',
	    'light_source',		'light_source',
	    'struct dungeon',		'dungeon',
	    'dungeon',			'dungeon',
	    'struct d_flags',		'd_flags',
	    'd_flags',			'd_flags',
	    'struct dgn_topology',	'dgn_topology',
	    'struct branch',		'branch',
	    'branch',			'branch',
	    'struct linfo',		'linfo',
	    'struct s_level',		's_level',
	    's_level',			's_level',
	    'struct fruit',		'fruit',
	    'struct objclass',		'objclass',
	    'struct mkroom',		'mkroom',
	    'struct bubble',		'bubble',
	    'struct trap',		'trap',
	    'struct engr',		'engr',
	    'struct damage',		'damage',
	    'struct nhrect',		'NhRect',
	    'NhRect',			'NhRect',
	    'struct NhRegion',		'NhRegion',
	    'NhRegion',			'NhRegion',
	    'struct obj',		'obj',
	    'struct monst',		'monst',
	    'struct egd',		'egd',
	    'struct fakecorridor',	'fakecorridor',
	    'struct epri',		'epri',
	    'struct eshk',		'eshk',
	    'struct emin',		'emin',
	    'struct edog',		'edog',
	    'struct bill_x',		'bill_x',
	    'struct attribs',		'attribs',
	    'struct version_info',	'version_info',

	    'genericptr_t',		'genericptr_t',
	    'struct permonst',		'permonst',
	    'union vlaunchinfo',	'vlaunchinfo',
	    'union vptrs',		'vptrs',
	    'struct flag',		'flag',
	    'struct you',		'you',
	    'struct container',		'container',
	    'struct mapseen',		'mapseen',
	    'mapseen',			'mapseen',
	    'struct mapseen_feat',	'mapseen_feat',
	    'mapseen_feat',		'mapseen_feat',
	    );

# 自動で save routine を呼ぶ際、明示的にポインタ変換が必要な場合に定義
@def_pointer = (align, d_level, coord, timer_element, light_source, dungeon,
		d_flags, branch, s_level, NhRect, NhRegion, mapseen_feat);

# save_xml.c からのみ save routine が呼ばれる場合に定義するとベター
@define_static = (u_have, u_event, u_conduct, prop, skills, align, spell, attribs,
		  d_flags, d_level, mvitals, NhRect,fakecorridor, bill_x, mapseen_feat);

# 内部で配列を保存する必要のある構造体リスト
@define_loopcounter = (flag, you, NhRegion, monst, egd, eshk, attribs, mapseen);

# typedef で定義されている構造体リスト
@is_typedef_name = (align, coord, timer_element, d_flags, d_level, s_level,
		    dest_area, dungeon, branch, light_source, NhRect, NhRegion, mapseen, mapseen_feat);

# 解析する必要のある構造体名のリスト
@perse_list = (flag, u_have, u_event, u_conduct, you, prop, q_score, skills, align,
	       spell, d_flags, d_level, s_level, stairway, fe, ls_t, nhrect,
	       dest_area, dungeon, branch, linfo, dgn_topology, mvitals, objclass,
	       fruit, mkroom, bubble, trap, engr, rm, damage, levelflags,
	       NhRegion, obj, monst, fakecorridor, egd, epri, bill_x, eshk,
	       emin, edog, nhcoord, attribs, version_info, mapseen, mapseen_feat);

%def_condition = (
	     'mapseen',			'D_OVERVIEW',
	     'mapseen_feat',		'D_OVERVIEW',
);

# 保存しなくても良い変数リスト
%dontsave = (
	     'NhRegion',		'nrects|n_monst|max_monst',
	     'branch',			'next',
	     'bubble',			'prev|next|cons',
	     'damage',			'next',
	     'engr',			'nxt_engr|engr_lth|engr_time',
	     'eshk',			'billct',
	     'flag',			'bypasses',
	     'fruit',			'nextf',
	     'light_source',		'next',
	     'mkroom',			'sbrooms|resident',
	     'monst',			'data|nmon|mnum|minvent|mnamelth|mxlth|mextra',
	     'obj',			'nobj|cobj|otyp|oclass|oartifact|oextra|v|onamelth|oxlth|corpsenm',
	     'objclass',		'oc_name_idx|oc_descr_idx|oc_uname|oc_class|oc_merge|oc_magic|oc_charged|'
					. 'oc_unique|oc_nowish|oc_big|oc_dir|oc_subtyp|oc_oprop|oc_delay|oc_weight|'
					. 'oc_cost|oc_wsdam|oc_wldam|oc_oc1|oc_oc2|oc_nutrition|oc_uses_known',
	     's_level',			'next',
	     'spell',			'sp_id',
	     'timer_element',		'next|needs_fixup',
	     'trap',			'ntrap',
	     'mapseen',			'next|br|custom_lth',
);

# キャストしてから保存する必要がある場合定義
# 第一要素の型で保存
# 第二要素の内容でキャスト実行
@{$use_cast{timer_element}{arg}}	= ('ulong',	'(unsigned long)');
@{$use_cast{light_source}{id}}		= ('ulong',	'(unsigned long)');
@{$use_cast{NhRegion}{arg}}		= ('ulong',	'(unsigned long)');
@{$use_cast{you}{ustuck}}		= ('bool',	'!!');
@{$use_cast{you}{usteed}}		= ('bool',	'!!');
@{$use_cast{monst}{mw}}			= ('bool',	'!!');

# 文字列として保存する変数リスト
$is_string{flag}{pickup_types}		= 'array';
$is_string{you}{usick_cause}		= 'array';
$is_string{dungeon}{dname}		= 'array';
$is_string{dungeon}{proto}		= 'array';
$is_string{s_level}{proto}		= 'array';
$is_string{fruit}{fname}		= 'array_fname';
$is_string{eshk}{customer}		= 'array';
$is_string{eshk}{shknam}		= 'array';
$is_string{engr}{engr_txt}		= 'pointer_engr_txt';
$is_string{NhRegion}{enter_msg}		= 'pointer';
$is_string{NhRegion}{leave_msg}		= 'pointer';
$is_string{var_info_save_c}{pl_character}='array';
$is_string{var_info_save_c}{pl_fruit}	= 'array_pl_fruit';
$is_string{var_info_dungeon_c}{tune}	= 'array';
$is_string{mapseen}{custom}		= 'pointer_mapseen';

# 保存する必要のある要素数が代入された変数を指定する場合定義
$end_variable{NhRegion}{rects}		= 'p->nrects';
$end_variable{NhRegion}{monsters}	= 'p->n_monst';
$end_variable{eshk}{bill}		= 'p->billct';

# 特別な保存方法の変数リスト
$special_type{bubble}{bm}		= 'bubble:bm';
$special_type{trap}{ttyp}		= 'trap:ttyp';
$special_type{trap}{vl}			= 'trap:vl';
$special_type{eshk}{bill_p}		= 'eshk:bill_p';
$special_type{rm}{typ}			= 'rm_type';
$special_type{rm}{glyph}		= 'glyph';
$special_type{damage}{typ}		= 'rm_type';
$special_type{you}{bglyph}		= 'glyph';
$special_type{you}{cglyph}		= 'glyph';
$special_type{NhRegion}{glyph}		= 'glyph';
$special_type{NhRegion}{rects}		= 'NhRegion:rects';
$special_type{NhRegion}{monsters}	= 'NhRegion:monsters';
$special_type{objclass}{oc_prob}	= 'objclass:oc_prob';
$special_type{monst}{mparent}		= 'monst:msteed';
$special_type{monst}{mchild}		= 'monst:msteed';
$special_type{flag}{initrole}		= 'role';
$special_type{flag}{initrace}		= 'race';
$special_type{flag}{initgend}		= 'gender';
$special_type{flag}{initalign}		= 'align';
$special_type{flag}{initquest}		= 'quest';
$special_type{flag}{pantheon}		= 'role';
$special_type{mapseen}{rooms}		= 'sparse_array';


%structure_def = (
	'ARRAY',		'NULL',
	'ARTIFACT',		'NULL',
	'BRANCHES',		'NULL',
	'BUBBLES',		'NULL',
	'DAMAGES',		'var_info_save_c',
	'DUNGEON',		'var_info_dungeon_c',
	'DUNGEON_OVERVIEW',	'NULL',
	'ENGRAVINGS',		'NULL',
	'FLOOR',		'NULL',
	'FRUITS',		'var_info_save_c',
	'GAMESTAT',		'var_info_save_c',
	'GLYPH',		'NULL',
	'LEVCHN',		'var_info_save_c',
	'LEVELDATA',		'var_info_save_c',
	'LIGHT_SOURCES',	'NULL',
	'MONSTER',		'var_info_save_c',
	'MONSTERS',		'var_info_save_c',
	'OBJECT',		'var_info_save_c',
	'OBJECTS',		'var_info_save_c',
	'OBJECT_CLASS',		'NULL',
	'ORACLES',		'NULL',
	'PROPERTY',		'var_info_restore_xml_y',
	'REGIONS',		'var_info_region_c',
	'ROOM',			'NULL',
	'SPELL_BOOK',		'var_info_save_c',
	'SUBROOM',		'NULL',
	'TIMER',		'var_info_timeout_c',
	'TRAPS',		'var_info_save_c',
	'VERSION',		'NULL',
	'WATERLEBEL',		'var_info_mkmaze_c',
	'WORM',			'NULL',
	);

@value_type = (
	'bool',
	'bitfields',
	'char',
	'schar',
	'int',
	'short',
	'long',
	'llong',
	'uchar',
	'ushort',
	'uint',
	'ulong',
	'string',
	'rm_type',
	'role',
	'race',
	'gender',
	'align',
	'quest',
);


foreach $i (@def_pointer){
    $ispointer{$i} = '&';
}
foreach $i (sort keys %typedef){
    $regexp_type = "$i|$regexp_type";

    if($i =~ /^struct /){
	$ispointer{$i} = '&';
    }
}
chop($regexp_type);

delete $ispointer{'struct monst'};
delete $ispointer{'struct obj'};



open(SAVE_XML_C, "> ../src/save_xml.c");
open(RESTORE_XML_CORE_C, "> ../src/restore_xml_core.c");
open(STRUCT_INFO_H, "> ../include/struct_info.h");


#open(SAVE_XML_C, "> /proc/self/fd/1");
#open(SAVE_XML_C, "> /dev/null");
#open(STRUCT_INFO_H, "> /proc/self/fd/1");


&write_headers;

while(<>){
    s/[ \t]+/ /g;

    if(/struct var_info_t ([a-zA-Z_][a-zA-Z_0-9]*)\[\] = {/){
	    &parse_var_info($1);
    }elsif(/(struct [a-zA-Z_][a-zA-Z_0-9]*) {/){
	$tmp = $1;
	$struct_name = $typedef{$tmp};
	$tmp =~ s/^struct //;

	if(grep(/^$tmp$/, @perse_list)){
	    &parse($struct_name);
	}
    }elsif(/^\/\* Level location types \*\//){
	&parse_rm_type;
    }elsif(/^\/\* begin dungeon characters \*\//){
	&parse_cmap;
    }
}

#######################################################################################

print STRUCT_INFO_H "/* This source file is generated by 'parse_struct.pl'.  Do not edit. */\n";
print STRUCT_INFO_H "#ifndef STRUCT_INFO_H\n#define STRUCT_INFO_H\n\n";

$strct_no = 0;
foreach $i (sort keys %struct_id){
    $i =~ tr/a-z/A-Z/;
    if(length($i) < 6) {
	print STRUCT_INFO_H "#define STRUCT_ID_$i\t\t$strct_no\n";
    }else{
	print STRUCT_INFO_H "#define STRUCT_ID_$i\t$strct_no\n";
    }
    $strct_no++;
}

$strct_no--;
print STRUCT_INFO_H "\n#define STRUCT_ID_END\t$strct_no\n\n";

foreach $i (sort keys %structure_def){
    $strct_no++;

    print STRUCT_INFO_H "#define STRUCTURE_$i\t$strct_no\n";
}

print STRUCT_INFO_H "\n#define STRUCTURE_END	$strct_no\n";
print STRUCT_INFO_H "#define STRUCTURE_INVALID	(-1)\n\n";

foreach $i (@value_type){
    $strct_no++;
    $i =~ tr/a-z/A-Z/;

    print STRUCT_INFO_H "#define VALUE_TYPE_$i	$strct_no\n";

    if($i eq 'BITFIELDS'){
	$strct_no += 31;
    }
}

print STRUCT_INFO_H "\n";

foreach $i (sort keys %struct_id){
    $variable_no{$i} = 0;
    $struct_name = $i;
    $struct_name =~ tr/a-z/A-Z/;

    print SAVE_XML_C "static struct var_info_t var_info_${i}\[\] = {\n";

    foreach $j (sort @{$struct_id{$i}}){
	print SAVE_XML_C "\t{ \"$j\",\tNULL },\n";

	$j =~ tr/a-z/A-Z/;

	$n = (8*8-(length($i)+length($j)+23))/8;
	$tabs = "\t" x $n;
	print STRUCT_INFO_H "#define VARIABLE_ID_${struct_name}__$j${tabs}${variable_no{$i}}\n";

	$variable_no{$i}++;
    }

    print SAVE_XML_C "};\n\n";

    print STRUCT_INFO_H "\n";
}

foreach $i (keys %var_info_data){
    $struct_name = $i;
    $struct_name =~ tr/a-z/A-Z/;
    $struct_name =~ s/^VAR_INFO_//;

    for($j = 0; $j < $var_info_size{$i}; $j++){
	$var_name = $var_info_data{$i}[$j];
	$var_name =~ tr/a-z/A-Z/;
	$var_name =~ tr/.\->/___/;

	print STRUCT_INFO_H "#define VARIABLE_ID_${struct_name}__$var_name\t$j\n";
    }

    print STRUCT_INFO_H "\n";
}


print SAVE_XML_C "struct struct_info_t struct_info[] = {\n";
foreach $i (sort keys %struct_id){
    $n = (8*5-(length($i)+14))/8;
    $tabs = "\t" x $n;
    print SAVE_XML_C "\t{ \"$i\",${tabs}$variable_no{$i},\tvar_info_${i} },\n";
}
print SAVE_XML_C "\n";

foreach $i (sort keys %structure_def){
    $j = $var_info_size{$structure_def{$i}} + 0;

    print SAVE_XML_C "\t{ \"$i\",\t$j,\t$structure_def{$i} },\n";
}

print SAVE_XML_C "};\n\n";


push(@rm_type_table, "INVALID_TYPE");
print SAVE_XML_C "struct name_info_t rm_type_info[MAX_TYPE + 1] = {\n";
foreach $i (sort @rm_type_table){
    print SAVE_XML_C "\t{ \"$i\",\t$i },\n";
}
print SAVE_XML_C "};\n\n";

print SAVE_XML_C "struct name_info_t cmap_info[MAXPCHARS] = {\n";
foreach $i (sort @cmap_table){
    print SAVE_XML_C "\t{ \"$i\",\t\tS_$i },\n";
}
print SAVE_XML_C "};\n\n";

print SAVE_XML_C "#endif /* SAVE_FILE_XML */\n";
print STRUCT_INFO_H "#endif /* STRUCT_INFO_H */\n";

#######################################################################################

foreach $i (keys %structure_def){
    if($structure_def{$i} ne 'NULL') {
	push(@{$structure_var_info{$structure_def{$i}}}, $i);
    }
}

foreach $i (keys %structure_var_info){
    $struct_name = $i;
    $struct_name =~ tr/a-z/A-Z/;
    $struct_name =~ s/^VAR_INFO_//;

    foreach $j (sort @{$structure_var_info{$i}}){
	print RESTORE_XML_CORE_C "\tcase STRUCTURE_$j:\n";
    }

    print RESTORE_XML_CORE_C "\t\tswitch (variable_id) {\n";

    for($j = 0; $j < $var_info_size{$i}; $j++){
	local($var_info) = $var_info_data{$i}[$j];

	$var_name = $var_info;
	$var_name =~ tr/a-z/A-Z/;
	$var_name =~ tr/.\->/___/;

	next if($var_info_addr{$i}{$var_info} eq 'NULL');

	$var_id = "VARIABLE_ID_${struct_name}__$var_name";

	$type = $var_info_type{$i}{$var_info};
	if($type =~ /([^\[\]\n]+)\[([^\[\]\n]+)\]/){
		$type = $1;
		$size = $2;
	}else{
		$size = "";
	}

	$type =~ s/[ \t]+\*+$//;
	$typename = $typedef{$type};

	if($size eq ""){
		$deref_sym = '*';
		$array_index = '';
	}else{
		$deref_sym = '';
		$array_index = '[current->u.array.index++]';
	}

	print RESTORE_XML_CORE_C "\t\tcase $var_id:\n";

	if($size ne "" && $type ne 'STRING'){
		print RESTORE_XML_CORE_C <<EOM
			if (!is_array_element)
				return (type == STRUCTURE_ARRAY) ?
					${i}[$var_id].ptr : 0;

			if (current->u.array.index >= $size || current->u.array.index >= current->u.array.size)
				return 0;

EOM
	}

	if($type eq 'STRING' && $size ne ""){
	    local($str_type) = $is_string{$i}{$var_info};

	    if($str_type eq 'array'){
		print RESTORE_XML_CORE_C <<"EOM";
			if (type == VALUE_TYPE_STRING) {
				strncpy((char *)${i}[$var_id].ptr, data, $size - 1);
				((char *)${i}[$var_id].ptr)[$size - 1] = 0;
			} else {
				((char *)${i}[$var_id].ptr)[0] = 0;
			}
EOM
	    }elsif($str_type eq 'array_pl_fruit'){
		print RESTORE_XML_CORE_C <<"EOM";
			if (type == VALUE_TYPE_STRING) {
				strncpy((char *)${i}[$var_id].ptr, str2ic_xml(data), $size - 1);
				((char *)${i}[$var_id].ptr)[$size - 1] = 0;
			} else {
				((char *)${i}[$var_id].ptr)[0] = 0;
			}
EOM
	    }elsif($str_type eq 'pointer'){
		print RESTORE_XML_CORE_C <<"EOM";
			print RESTORE_XML_CORE_C "\t\t\tif (type != VALUE_TYPE_STRING) {
				*((char **)${i}[$var_id].ptr) = 0;
				return 0;
			}
			*((char **)${i}[$var_id].ptr) = strdup(data);
EOM
	    }

	    print RESTORE_XML_CORE_C "\t\t\tbreak;\n";
	}elsif($typename eq 'bool'){
	    print RESTORE_XML_CORE_C <<"EOM";
			$deref_sym(($type *)${i}[$var_id].ptr)$array_index = (type == VALUE_TYPE_BOOL) ? str2bool(data) : FALSE;
			break;
EOM
	}elsif($typename eq 'bitfields') {
	    print RESTORE_XML_CORE_C "\t\t\t$deref_sym(($type *)${i}[$var_id].ptr)$array_index =\n";
	    print RESTORE_XML_CORE_C "\t\t\t\t(type >= VALUE_TYPE_BITFIELDS && type < VALUE_TYPE_BITFIELDS+32) ? Strtoul(data, NULL, 0) : 0;\n";
	    print RESTORE_XML_CORE_C "\t\t\tbreak;\n";
	}elsif(grep(/^$typename$/, ('char', 'schar', 'int', 'short', 'long'))) {
	    print RESTORE_XML_CORE_C "\t\t\t$deref_sym(($type *)${i}[$var_id].ptr)$array_index =\n";
	    print RESTORE_XML_CORE_C "\t\t\t\t(type >= VALUE_TYPE_CHAR && type <= VALUE_TYPE_LONG) ? Strtol(data, NULL, 0) : 0;\n";
	    print RESTORE_XML_CORE_C "\t\t\tbreak;\n";
	}elsif(grep(/^$typename$/, ('uchar', 'uint', 'ushort', 'ulong'))) {
	    print RESTORE_XML_CORE_C "\t\t\t$deref_sym(($type *)${i}[$var_id].ptr)$array_index =\n";
	    print RESTORE_XML_CORE_C "\t\t\t\t(type >= VALUE_TYPE_UCHAR && type <= VALUE_TYPE_ULONG) ? Strtoul(data, NULL, 0) : 0;\n";
	    print RESTORE_XML_CORE_C "\t\t\tbreak;\n";
	}elsif($typename eq 'time_t') {
	    print RESTORE_XML_CORE_C "\t\t\t$deref_sym((time_t *)${i}[$var_id].ptr)$array_index =\n";
	    print RESTORE_XML_CORE_C "\t\t\t\t(type == VALUE_TYPE_LLONG) ? (time_t)Strtoll(data, NULL, 0) : 0;\n";
	    print RESTORE_XML_CORE_C "\t\t\tbreak;\n";
	}else{
	    $struct_id_name = "STRUCT_ID_$typename";
	    $struct_id_name =~ tr/a-z/A-Z/;

	    if($size eq ""){
		print RESTORE_XML_CORE_C <<"EOM";
			if (type != $struct_id_name)
				return 0;
			return ${i}[$var_id].ptr;
			break;
EOM
	    }else{
		print RESTORE_XML_CORE_C <<"EOM";
			if (type != $struct_id_name)
				return 0;

			return (genericptr_t)(&((($type *)${i}[$var_id].ptr)$array_index));
			break;
EOM
	    }
	}






#----------------------------------------------------------------------------------------------------------
    }

    print RESTORE_XML_CORE_C <<'EOM'
		default:
			print_nonimplimant_error(current, variable_id);
			break;
		}
		break;
EOM
}

print RESTORE_XML_CORE_C <<'EOM';
	default:
		print_nonimplimant_error(current, -1);
		break;
	}

	return 0;
}

#endif /* SAVE_FILE_XML */
EOM

#######################################################################################

sub parse
{
    local($static, $includearray, $insert_struct, $line, $i, @sentence,
	  $def_condition_bgn, $def_condition_end);

    $struct_name = $_[0];

    $static = grep(/^$struct_name$/, @define_static) ? 'static ' : '';
    $includearray = grep(/^$struct_name$/, @define_loopcounter) ? "\n\tint i;\n" : '';
    $insert_struct = grep(/^$struct_name$/, @is_typedef_name) ? "" : "struct ";

    if($def_condition{$struct_name}){
	$def_condition_bgn = "#ifdef $def_condition{$struct_name}\n";
	$def_condition_end = "#endif /*$def_condition{$struct_name}*/\n";
    }else{
	$def_condition_bgn = '';
	$def_condition_end = '';
    }

    print SAVE_XML_C <<"EOM";
${def_condition_bgn}${static}void
save_${struct_name}_xml(fd, id, p)
int fd;
const char *id;
$insert_struct$struct_name *p;
{$includearray
	XMLTAG_STRUCT_BGN(fd, \"$struct_name\", id);

EOM

    $i = $struct_name;
    $i =~ tr/a-z/A-Z/;

    print RESTORE_XML_CORE_C <<"EOM";
${def_condition_bgn}	case STRUCT_ID_$i:
		switch (variable_id) {
EOM

    $line = "";

    while(<>){
	last if(/}/);

        chop;

	if($line eq ""){
	    $line = $_;
	}else{
	    $line = "$line $_";
	}

	if($line =~ /^#[ \t]*if/ || $line =~ /^#[ \t]*endif/ || $line =~ /^#[ \t]*else/) {
	   print SAVE_XML_C "$line\n";
	   print RESTORE_XML_CORE_C "$line\n";
	   $line = "";
	   next;
        }

	while($line =~ m|/\*.*\*/|){
	    $line =~ m|/\*([^*]*)\*(.)|;
	    $prev = $1;
	    $back = $2;

	    if($back eq '/'){
		$line =~ s|/\*[^*]*\*.||;
	    }else{
		$line =~ s|/\*[^*]*\*.|/\*$back|;
	    }
	}
	next if($line =~ m|/\*|);

	if($line =~ /^#[ \t]*define/){
	   if($line =~ s/\\[ \t]*$//){
	       next;
	   }

#	   print SAVE_XML_C "/* ########### $line */\n";

	   $line = "";
	   next;
        }

	$line =~ s/[ \t]+/ /g;
	$line =~ s/^ //;
	$line =~ s/ $//;

	next if(!($line =~ /;$/));

	@sentence = split(/;/, $line);

	foreach $i (@sentence){
	    $sentence =~ s/^ //;
	    $sentence =~ s/ $//;
	    &parse_struct($i);
	}

	$line = "";
    }

    print SAVE_XML_C <<"EOM";

	XMLTAG_STRUCT_END(fd);
}
${def_condition_end}
EOM

    print RESTORE_XML_CORE_C <<"EOM";
		default:
			print_nonimplimant_error(current, variable_id);
			break;
		} 
		break;
${def_condition_end}
EOM
}

sub parse_struct
{
    local($line) = $_[0];
    local($i, $variables, $bits, $name, $size, $name_id);

    $bits = "";

    if($line =~ /^($regexp_type)\* (.+)/){
	$type = $1;
	$variables  = "*$2";
    }elsif($line =~ /^($regexp_type) (.+)/){
	$type = $1;
	$variables  = $2;
    }elsif($line =~ /^Bitfield ?\( ?([a-zA-Z_][a-zA-Z_0-9]*), ?([0-9]+) ?\)/){
	$type = "bitfields";
	$variables  = $1;
	$bits = "$2, ";
    }else{
	print SAVE_XML_C "/* unknown --------- $line --------- */\n";
	return;
    }

    $variables =~ s/[ \t]+//g;
    foreach $i (split(/,/, $variables)){
	if($i =~ /(.*)\[(.+)\]/){
	    $name = $1;
	    $size = $2;
	}else{
	    $name = $i;
	    $size = "";
	}

	if($name =~ s/^\*//){
	    $var_is_pointer = ' *';
	}else{
	    $var_is_pointer = '';
	}

	if($dontsave{$struct_name} && $name =~ /^($dontsave{$struct_name})$/){
	    next;
	}

	push(@{$struct_id{$struct_name}}, $name);

	$i = $struct_name;
	$i=~ tr/a-z/A-Z/;
	$name_id = $name;
	$name_id =~ tr/a-z/A-Z/;
	$name_id = "VARIABLE_ID_${i}__$name_id";

	if(defined(${use_cast{$struct_name}{$name}})){
	    $typename = $use_cast{$struct_name}{$name}[0];
	}else{
	    $typename = $typedef{$type};
	}

	local($stype)    = $special_type{$struct_name}{$name};
	local($str_type) = $is_string{$struct_name}{$name};

	print RESTORE_XML_CORE_C "\t\tcase $name_id:\n" if($stype ne 'trap:vl');

        if($stype eq "bubble:bm"){
	    print SAVE_XML_C "\tsave_uchar_xml(fd, \"$name\", p->$name\[0\]);\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			{
				int n = Strtoul(data, NULL, 0) - 2;

				if (n < 0 || n > 6 || type != VALUE_TYPE_UCHAR)
					(($insert_struct$struct_name *)ptr)->$name = bubble_bmask[0];
				else
					(($insert_struct$struct_name *)ptr)->$name = bubble_bmask[n];
			}
			break;
EOM
	}elsif($stype eq 'trap:ttyp'){
	    print SAVE_XML_C "\tsave_string_xml(fd, \"$name\", defsyms[trap_to_defsym(p->$name)].explanation);\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			{
				int i;

				if (data && type == VALUE_TYPE_STRING)
					for(i = S_arrow_trap; i <= S_polymorph_trap; i++)
						if (!strcmp(defsyms[i].explanation, data))
							break;

				if (data && type == VALUE_TYPE_STRING && i <= S_polymorph_trap) {
					(($insert_struct$struct_name *)ptr)->$name = defsym_to_trap(i);
				} else {
					(($insert_struct$struct_name *)ptr)->$name = 0;
					impossible("Don't impliment trap type: %s", data);
				}
			}
			break;
EOM
	}elsif($stype eq 'trap:vl'){
	    &write_trap_launch;
	}elsif($stype eq 'eshk:bill_p'){
	    print SAVE_XML_C <<"EOM";
	if (!p->$name) {
		save_int_xml(fd, \"${name}\", 0);
	} else if (p->$name == (struct bill_x *) -1000) {
		save_int_xml(fd, \"${name}\", -1000);
	} else {
		save_int_xml(fd, \"${name}\", 1);
	}
EOM

#	must call restshk() after!
	    print RESTORE_XML_CORE_C <<"EOM";
			if (type != VALUE_TYPE_INT)
				return 0;
			(($insert_struct$struct_name *)ptr)->$name =
				 (struct bill_x *)Strtol(data, NULL, 0);
EOM
	}elsif($stype eq 'rm_type'){
	    print SAVE_XML_C "\tsave_rm_type_xml(fd, \"$name\", p->$name);\n";

	    print RESTORE_XML_CORE_C "\t\t\t(($insert_struct$struct_name *)ptr)->$name =\n";
	    print RESTORE_XML_CORE_C "\t\t\t\t(type == VALUE_TYPE_RM_TYPE) ? serach_name2num(rm_type_info, MAX_TYPE + 1, data) : INVALID_TYPE;\n";
	    print RESTORE_XML_CORE_C "\t\t\tbreak;\n";
	}elsif($stype eq 'role'){
	    print SAVE_XML_C <<"EOM";
#ifdef RANDOM_QUEST /* quest change test [IDE]*/
	XMLTAG_ROLE(fd, \"$name\", roles[p->$name].questdata->filecode);
#else
	XMLTAG_ROLE(fd, \"$name\", roles[p->$name].filecode);
#endif
EOM

	    print RESTORE_XML_CORE_C <<"EOM";
			{
				int i;

				if (type == VALUE_TYPE_ROLE) {
					i = str2role((char *)data);
				} else if (type >= VALUE_TYPE_CHAR && type <= VALUE_TYPE_LONG) {
					i = Strtol(data, NULL, 0);
				} else {
					i = ROLE_NONE;
				}

				(($insert_struct$struct_name *)ptr)->$name = (i == ROLE_NONE || i == ROLE_RANDOM) ? 0 : i;
			}
			break;
EOM
	}elsif($stype eq 'race'){
	    print SAVE_XML_C "\tXMLTAG_RACE(fd, \"$name\", races[p->$name].filecode);\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			{
				int i;

				if (type == VALUE_TYPE_RACE) {
					i = str2race((char *)data);
				} else if (type >= VALUE_TYPE_CHAR && type <= VALUE_TYPE_LONG) {
					i = Strtol(data, NULL, 0);
				} else {
					i = ROLE_NONE;
				}

				(($insert_struct$struct_name *)ptr)->$name = (i == ROLE_NONE || i == ROLE_RANDOM) ? 0 : i;
			}
			break;
EOM
	}elsif($stype eq 'gender'){
	    print SAVE_XML_C "\tXMLTAG_GENDER(fd, \"$name\", genders[p->$name].filecode);\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			{
				int i;

				if (type == VALUE_TYPE_GENDER) {
					i = str2gend((char *)data);
				} else if (type >= VALUE_TYPE_CHAR && type <= VALUE_TYPE_LONG) {
					i = Strtol(data, NULL, 0);
				} else {
					i = ROLE_NONE;
				}

				(($insert_struct$struct_name *)ptr)->$name = (i == ROLE_NONE || i == ROLE_RANDOM) ? 0 : i;
			}
			break;
EOM
	}elsif($stype eq 'align'){
	    print SAVE_XML_C "\tXMLTAG_ALIGN(fd, \"$name\", aligns[p->$name].filecode);\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			{
				int i;

				if (type == VALUE_TYPE_ALIGN) {
					i = str2align((char *)data);
				} else if (type >= VALUE_TYPE_CHAR && type <= VALUE_TYPE_LONG) {
					i = Strtol(data, NULL, 0);
				} else {
					i = ROLE_NONE;
				}

				(($insert_struct$struct_name *)ptr)->$name = (i == ROLE_NONE || i == ROLE_RANDOM) ? 0 : i;
			}
			break;
EOM
	}elsif($stype eq 'quest'){
	    print SAVE_XML_C "\tXMLTAG_QUEST(fd, \"$name\", qdatas[p->$name].filecode);\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			{
				int i;

				if (type == VALUE_TYPE_QUEST) {
					i = str2quest((char *)data);
				} else if (type >= VALUE_TYPE_CHAR && type <= VALUE_TYPE_LONG) {
					i = Strtol(data, NULL, 0);
				} else {
					i = ROLE_NONE;
				}

				(($insert_struct$struct_name *)ptr)->$name = (i == ROLE_NONE || i == ROLE_RANDOM) ? 0 : i;
			}
			break;
EOM
	}elsif($stype eq 'glyph'){
	    print SAVE_XML_C "\tsave_glyph_xml(fd, \"$name\", p->$name);\n";

	    print RESTORE_XML_CORE_C "\t\t\treturn (type == STRUCTURE_GLYPH) ? (genericptr_t)(&((($insert_struct$struct_name *)ptr)->$name)) : 0;\n";
	    print RESTORE_XML_CORE_C "\t\t\tbreak;\n";
	}elsif($stype eq 'objclass:oc_prob'){
	    print SAVE_XML_C "\tif (p->oc_class == GEM_CLASS && p->oc_name_idx <= LAST_GEM)\n";
	    print SAVE_XML_C "\t\tsave_${typename}_xml(fd, \"$name\", $bits$use_cast{$struct_name}{$name}[1]$ispointer{$type}p->$name);\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			if (!(type >= VALUE_TYPE_CHAR && type <= VALUE_TYPE_ULONG))
				return 0;
			if ((current - 1)->id == STRUCTURE_OBJECT_CLASS && (current - 1)->u.objclass.read_prob)
				((struct objclass *)ptr)->oc_prob = Strtol(data, NULL, 0);
			break;
EOM
	}elsif($stype eq 'monst:msteed'){
	    print SAVE_XML_C <<"EOM";
	if (p->$name != 0)
		save_uint_xml(fd, \"$name\", (p->$name)->m_id);
EOM

	    print RESTORE_XML_CORE_C <<"EOM";
			if (type != VALUE_TYPE_UINT)
				(($insert_struct$struct_name *)ptr)->$name = (genericptr_t)0;
			else
				(($insert_struct$struct_name *)ptr)->$name = (genericptr_t)Strtoul(data, NULL, 0);
			break;
EOM
	}elsif($str_type eq 'array'){
	    print SAVE_XML_C "\tsave_string_xml(fd, \"$name\", p->$name);\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			if (type != VALUE_TYPE_STRING) {
				((($insert_struct$struct_name *)ptr)->$name)[0] = 0;
				return 0;
			}
			strncpy((($insert_struct$struct_name *)ptr)->$name, data, $size - 1);
			((($insert_struct$struct_name *)ptr)->$name)[$size - 1] = 0;
			break;
EOM
	}elsif($str_type eq 'array_fname'){
	    print SAVE_XML_C "\tsave_string_xml(fd, \"$name\", ic2str_xml(p->$name));\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			if (type != VALUE_TYPE_STRING) {
				((($insert_struct$struct_name *)ptr)->$name)[0] = 0;
				return 0;
			}
			strncpy((($insert_struct$struct_name *)ptr)->$name, str2ic_xml(data), $size - 1);
			((($insert_struct$struct_name *)ptr)->$name)[$size - 1] = 0;
			break;
EOM
	}elsif($str_type eq 'pointer'){
	    print SAVE_XML_C "\tsave_string_xml(fd, \"$name\", p->$name);\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			if (type != VALUE_TYPE_STRING) {
				(($insert_struct$struct_name *)ptr)->$name = 0;
				return 0;
			}
			(($insert_struct$struct_name *)ptr)->$name = strdup(data);
			break;
EOM
	}elsif($str_type eq 'pointer_engr_txt'){
	    print SAVE_XML_C "\tsave_string_xml(fd, \"$name\", ic2str_xml(p->$name));\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			if (type != VALUE_TYPE_STRING) {
				return 0;
			} else {
				const char *p = str2ic_xml(data);
				int len = strlen(p);
				struct engr *ep = newengr(len + 1), *oep = (struct engr *)ptr;

				*ep = *oep;
				dealloc_engr(oep);
				current->ptr = (genericptr_t)ep;

				ep->engr_txt = (char *) (ep + 1);
				strcpy(ep->engr_txt, p);

				ep->engr_time = moves;
				ep->engr_lth = len + 1;
			} break;
EOM
	}elsif($str_type eq 'pointer_mapseen'){
	    print SAVE_XML_C "\tsave_string_xml(fd, \"$name\", ic2str_xml(p->$name));\n";

	    print RESTORE_XML_CORE_C <<"EOM";
			if (type != VALUE_TYPE_STRING) {
				(($insert_struct$struct_name *)ptr)->$name = 0;
				(($insert_struct$struct_name *)ptr)->custom_lth = 0;
				return 0;
			} else {
				const char *p = str2ic_xml(data);
				int len = strlen(p);

				(($insert_struct$struct_name *)ptr)->$name = strdup(p);
				(($insert_struct$struct_name *)ptr)->custom_lth = len + 1;
			} break;
EOM
	}elsif($size ne "" || defined($end_variable{$struct_name}{$name})){
	    if(defined($end_variable{$struct_name}{$name})){
		$endval = "$end_variable{$struct_name}{$name}";
	    }else{
		$endval = "$size";
	    }


	    $id = "num2str(i)";
	    $array_index = 'current->u.array.index++';
	    $cond = '';
	    $calc_array_index = '';

	    if($stype eq 'sparse_array'){
		$cond = "if ($use_cast{$struct_name}{$name}[1]$ispointer{$type}p->$name\[i\] != 0)\n\t\t\t";
		$calc_array_index = "\n\t\t\tcurrent->u.array.index = Strtol(id, NULL, 0);\n";
		$array_index = 'current->u.array.index';
	    }


	    print SAVE_XML_C <<"EOM";
	XMLTAG_ARRAY_BGN(fd, \"$name\", $endval);
	for(i = 0; i < $endval; i++){
		${cond}save_${typename}_xml(fd, $id, $use_cast{$struct_name}{$name}[1]$ispointer{$type}p->$name\[i\]);
	}
	XMLTAG_ARRAY_END(fd);
EOM

	    if($stype eq 'NhRegion:rects'){
		print RESTORE_XML_CORE_C <<"EOM";
			if (!is_array_element) {
				int nrects = (int)data;
				NhRegion *reg = (NhRegion *)ptr;

				if (type != STRUCTURE_ARRAY)
					return 0;

				reg->nrects = nrects;

				if (nrects > 0)
					reg->rects = (NhRect *)alloc(sizeof (NhRect) * nrects);
				else
					reg->rects = NULL;

				return (genericptr_t)(reg->rects);
			}

EOM
	    }elsif($stype eq 'NhRegion:monsters'){
		print RESTORE_XML_CORE_C <<"EOM";
			if (!is_array_element) {
				int n_monst = (int)data;
				NhRegion *reg = (NhRegion *)ptr;

				reg->n_monst = reg->max_monst = n_monst;

				if (n_monst > 0 && type == STRUCTURE_ARRAY)
					reg->monsters = (unsigned *) alloc(sizeof (unsigned) * n_monst);
				else
					reg->monsters = NULL;

				return (genericptr_t)(reg->monsters);
			}

EOM
	    }else{
		print RESTORE_XML_CORE_C <<"EOM";
			if (!is_array_element)
				return (type == STRUCTURE_ARRAY) ?
					(genericptr_t)((($insert_struct$struct_name *)ptr)->$name) : 0;
$calc_array_index
			if (current->u.array.index >= $size || current->u.array.index >= current->u.array.size)
				return 0;

EOM
	    }







	    &restore_sub("(($type *)ptr)\[$array_index\]");
	    print RESTORE_XML_CORE_C "\t\t\tbreak;\n";
	}else{
	    print SAVE_XML_C "\tsave_${typename}_xml(fd, \"$name\", $bits$use_cast{$struct_name}{$name}[1]$ispointer{$type}p->$name);\n";

	    &restore_sub("(($insert_struct$struct_name *)ptr)->$name");
	    print RESTORE_XML_CORE_C "\t\t\tbreak;\n";
	}
    }
}

sub restore_sub
{
    local($restore_cast, $lvalue);

    $lvalue = $_[0];

    if(defined($use_cast{$struct_name}{$name}[1])){
	$restore_cast = "($type$var_is_pointer)";
    }else{
	$restore_cast = "";
    }

    if($typename eq 'bool'){
	print RESTORE_XML_CORE_C <<"EOM";
			if (type != VALUE_TYPE_BOOL)
				return 0;
			$lvalue = ${restore_cast}((int)str2bool(data));
EOM
    }elsif($typename eq 'bitfields') {
	print RESTORE_XML_CORE_C "\t\t\tif (!(type >= VALUE_TYPE_BITFIELDS && type < VALUE_TYPE_BITFIELDS+32))\n";
	print RESTORE_XML_CORE_C "\t\t\t\treturn 0;\n";
	print RESTORE_XML_CORE_C "\t\t\t$lvalue = Strtoul(data, NULL, 0);\n";
    }elsif(grep(/^$typename$/, ('char', 'schar', 'int', 'short', 'long'))) {
	print RESTORE_XML_CORE_C "\t\t\tif (!(type >= VALUE_TYPE_CHAR && type <= VALUE_TYPE_LONG))\n";
	print RESTORE_XML_CORE_C "\t\t\t\treturn 0;\n";
	print RESTORE_XML_CORE_C "\t\t\t$lvalue = ${restore_cast}Strtol(data, NULL, 0);\n";
    }elsif(grep(/^$typename$/, ('uchar', 'uint', 'ushort', 'ulong'))) {
	print RESTORE_XML_CORE_C "\t\t\tif (!(type >= VALUE_TYPE_UCHAR && type <= VALUE_TYPE_ULONG))\n";
	print RESTORE_XML_CORE_C "\t\t\t\treturn 0;\n";
	print RESTORE_XML_CORE_C "\t\t\t$lvalue = ${restore_cast}Strtoul(data, NULL, 0);\n";
    }elsif($typename eq 'time_t') {
	print RESTORE_XML_CORE_C "\t\t\tif (type != VALUE_TYPE_LLONG)\n";
	print RESTORE_XML_CORE_C "\t\t\t\treturn 0;\n";
	print RESTORE_XML_CORE_C "\t\t\t$lvalue = (time_t)Strtoll(data, NULL, 0);\n";
    }else{
	$struct_id_name = "STRUCT_ID_$typename";
	$struct_id_name =~ tr/a-z/A-Z/;

	print RESTORE_XML_CORE_C "\t\t\tif (type != $struct_id_name)\n";
	print RESTORE_XML_CORE_C "\t\t\t\treturn 0;\n";
	print RESTORE_XML_CORE_C "\t\t\treturn (genericptr_t)(&($lvalue));\n";
    }
}

sub write_trap_launch
{
    print SAVE_XML_C <<"EOM";
	XMLTAG_LAUNCH_BGN(fd);
	switch (p->ttyp) {
	case ROLLING_BOULDER_TRAP:
		save_coord_xml(fd, "launch2", &(p->launch2));
		break;
#if 0
	case ARROW_TRAP:
		save_object_name_xml(fd, p->launch_otyp);
		save_objclass_name_xml(fd, p->launch_otyp);
		break;
#endif
	default:
		save_short_xml(fd, "launch_otyp", p->launch_otyp);
		break;
	}
	XMLTAG_LAUNCH_END(fd);
EOM

	pop(@{$struct_id{$struct_name}});
	push(@{$struct_id{$struct_name}}, 'launch2');
	push(@{$struct_id{$struct_name}}, 'launch_otyp');

	print RESTORE_XML_CORE_C <<"EOM";
		case VARIABLE_ID_TRAP__LAUNCH2:
			if (type != STRUCT_ID_COORD)
				return 0;
			return (genericptr_t)(&((($insert_struct$struct_name *)ptr)->launch2));
			break;
		case VARIABLE_ID_TRAP__LAUNCH_OTYP:
			if (!(type >= VALUE_TYPE_CHAR && type <= VALUE_TYPE_LONG))
				return 0;
			(($insert_struct$struct_name *)ptr)->launch_otyp = Strtol(data, NULL, 0);
			break;
EOM
}


sub parse_var_info
{
    local($var_info_name) = $_[0];
    local($var_name, $type, $addr);

    $var_info_size{$var_info_name} = 0;

    while(<>){
	last if(/};/);

        if(/^[ \t]*(\/\*)?[ \t]*REGIST_VAR_INFO\([ \t]*"(.*)"[ \t]*,([^,\n]+),[ \t]*(.*)\),/){
	    $var_name = $2;
	    $addr = $3;
	    $type = $4;

	    next if($1 eq '/*');

	    push(@{$var_info_data{$var_info_name}}, $var_name);

	    $type =~ s/^[ \t]+//;
	    $type =~ s/[ \t]+$//;
	    $var_info_type{$var_info_name}{$var_name} = $type;

	    $addr =~ s/^[ \t]+//;
	    $addr =~ s/[ \t]+$//;
	    $var_info_addr{$var_info_name}{$var_name} = $addr;

	    $var_info_size{$var_info_name}++;
	}
    }

    $n = 0;
    foreach $i (sort @{$var_info_data{$var_info_name}}){
	if($i ne $var_info_data{$var_info_name}[$n]){
	    print "Error: must sort $var_info_name elements.\n";
	    exit(1);
	}
	$n++;
    }
}


sub parse_rm_type
{
    print SAVE_XML_C "static const char *rm_type_name[MAX_TYPE] = {\n";

    while(<>){
	if(/^#define[ \t]+([a-zA-Z_][a-zA-Z0-9_]*)[ \t]+/){
	    $type = $1;

	    last if($type eq "MAX_TYPE");

	    push(@rm_type_table, $type);

	    print SAVE_XML_C "\t\"$type\",\n";
	}
    }

    print SAVE_XML_C "};\n\n";
}


sub parse_cmap
{
    print SAVE_XML_C "static const char *cmap_name[MAXPCHARS] = {\n";

    while(<>){
	last if(/\/\* end effects \*\//);

	next if(/^#define[ \t]+S_END_/);

	if(/^#define[ \t]+S_([a-zA-Z0-9_]*)[ \t]+/){
	    $type = $1;

	    push(@cmap_table, $type);

	    print SAVE_XML_C "\t\"$type\",\n";
	}
    }

    print SAVE_XML_C "};\n\n";
}


sub write_headers
{
    print SAVE_XML_C <<'EOM';
/* This source file is generated by 'parse_struct.pl'.  Do not edit. */
#define NEED_VARARGS
#include "hack.h"

#ifdef SAVE_FILE_XML

#include "save_xml.h"

int is_savefile_format_xml = 0;

STATIC_DCL void FDECL(save_d_level_xml, (int, const char *, d_level *));
STATIC_DCL void FDECL(save_prop_xml, (int, const char *, struct prop *));
STATIC_DCL void FDECL(save_u_event_xml, (int, const char *, struct u_event *));
STATIC_DCL void FDECL(save_u_have_xml, (int, const char *, struct u_have *));
STATIC_DCL void FDECL(save_u_conduct_xml, (int, const char *, struct u_conduct *));
STATIC_DCL void FDECL(save_align_xml, (int, const char *, align *));
STATIC_DCL void FDECL(save_skills_xml, (int, const char *, struct skills *));
STATIC_DCL void FDECL(save_mvitals_xml, (int, const char *, struct mvitals *));
STATIC_DCL void FDECL(save_spell_xml, (int, const char *, struct spell *));
STATIC_DCL void FDECL(save_d_flags_xml, (int, const char *, d_flags *));
STATIC_DCL void FDECL(save_rm_type_xml, (int, const char *, int));
STATIC_DCL void FDECL(save_NhRect_xml, (int, const char *, NhRect *));
STATIC_DCL void FDECL(save_fakecorridor_xml, (int, const char *, struct fakecorridor *));
STATIC_DCL void FDECL(save_bill_x_xml, (int, const char *, struct bill_x *));
STATIC_DCL void FDECL(save_attribs_xml, (int, const char *, struct attribs *));

static const char *rm_type_name[];
static const char *cmap_name[];

const char * const oclass_names_xml[] = {
/* 0*/	0,
	"illegal objects",
	"weapons",
	"armor",
	"rings",
/* 5*/	"amulets",
	"tools",
	"food",
	"potions",
	"scrolls",
/*10*/	"spellbooks",
	"wands",
	"coins",
	"gems",
	"rocks",
/*15*/	"iron balls",
	"chains",
	"venoms"
};

void
fd_printf VA_DECL2(int, fd, const char *, s)
	char buf[BUFSZ];

	VA_START(s);
	VA_INIT(s, const char *);

	Vsprintf(buf,s,VA_ARGS);
	bwrite_(fd,(genericptr_t)buf,(unsigned)(strlen(buf)));

	VA_END();
}

/* This function called by unsupported bwrite() when request xml format. */
void
save_octet_xml(fd, id, loc, num)
int fd, num;
const char *id;
genericptr_t loc;
{
	int i, len;
	char buf[BUFSZ], *ptr;

	Sprintf(buf, "%s:%d:", escape_string(id), num);
	len = strlen(buf);
	ptr = buf + len;

	for (i = 0; i < min(num, (BUFSZ - len - 1) / 2); i++) {
		Sprintf(ptr, "%02x", ((unsigned char *)loc)[i]);
		ptr += 2;
	}

	save_comment_xml(fd, buf);
}

/* manage a pool of BUFSZ buffers, so callers don't have to */
char *
gettmpbuf()
{
	static char NEARDATA bufs[NUMTMPBUF][BUFSZ];
	static int bufidx = 0;

	bufidx = (bufidx + 1) % NUMTMPBUF;
	return bufs[bufidx];
}

#define ESCAPE_CHARS "\"<>%\n\r"

char *
escape_string(str)
const char *str;
{
	char *buf, buf2[4], *p;
	const char *q;
	int count;

	if (!str) {
		buf = gettmpbuf();
		buf[0] = 0;
		return buf;
	}

	if(!(p = strpbrk(str, ESCAPE_CHARS)))
		return (char *)str;

	buf = gettmpbuf();
	buf[0] = 0;
	q = str;
	count = BUFSZ - strlen(str) - 1;

	while(p && count >= 2){
		strncat(buf, q, p-q);
		sprintf(buf2, "%%%02x", *p);
		strcat(buf, buf2);

		q = p + 1;
		p = strpbrk(q, ESCAPE_CHARS);
		count -= 2;
	}

	strcat(buf, q);

	return buf;
}

void
save_string_xml(fd, id, val)
int fd;
const char *id, *val;
{
	if(val)
		XML_SAVE_STRING(fd, id, escape_string(val));
}

void
save_object_name_xml(fd, otyp)
int fd, otyp;
{
	if(obj_descr[otyp].oc_name) {
		char *buf = gettmpbuf();

		sprintf(buf, "%c", def_oc_syms[(int)objects[otyp].oc_class]);

		XML_SAVE_OBJ_NAME(fd, escape_string(buf), otyp, escape_string(obj_descr[otyp].oc_name));
	}
}

void
save_monster_name_xml(fd, id, mnum)
int fd, mnum;
const char *id;
{
	if (mnum >= LOW_PM && mnum < NUMMONS) {
		char *buf = gettmpbuf();

		sprintf(buf, "%c", def_monsyms[(int)mons[mnum].mlet]);

		XML_SAVE_MONSTER_NAME(fd, id, buf, mnum, escape_string(mons[mnum].mname));
	} else if (mnum == NON_PM) {
		XML_SAVE_MONSTER_NAME(fd, id, "", mnum, "");
	}
}

char *
num2str(num)
int num;
{
	char *str = gettmpbuf();

	sprintf(str, "%d", num);

	return str;
}

void
savemvitals_xml(fd, id, p)
int fd;
const char *id;
struct mvitals *p;
{
	int i;

	XMLTAG_ARRAY_BGN(fd, id, NUMMONS);
	for(i = 0; i < NUMMONS; i++) {
		save_mvitals_xml(fd, escape_string(mons[i].mname), &(p[i]));
	}
	XMLTAG_ARRAY_END(fd);
}

void
save_spl_book_xml(fd, id, p)
int fd;
const char *id;
struct spell *p;
{

	int i;

	XMLTAG_SPELL_BOOK_BGN(fd, id);
	for(i = 0; i < MAXSPELL + 1; i++) {
		if (p[i].sp_id == 0)
			break;
		save_spell_xml(fd, escape_string(obj_descr[p[i].sp_id].oc_name), &(p[i]));
	}
	XMLTAG_SPELL_BOOK_END(fd);
}

void
savedoors_xml(fd, id, p)
int fd;
const char *id;
coord *p;
{
	int i;
	XMLTAG_ARRAY_BGN(fd, id, doorindex);
	for(i = 0; i < doorindex; i++) {
	    save_coord_xml(fd, num2str(i), &(p[i]));
	}
	XMLTAG_ARRAY_END(fd);
}

static void
save_rm_type_xml(fd, id, p)
int fd, p;
const char *id;
{
	if (p >=0 && p < MAX_TYPE)
	    XMLTAG_RM_TYPE(fd, id, rm_type_name[p]);
	else
	    XMLTAG_RM_TYPE(fd, id, "INVALID_TYPE");
}

static void
save_glyph_xml(fd, id, glyph)
int fd, glyph;
const char *id;
{
	int offset;

	if (glyph >= MAX_GLYPH) {			/* invalid */
		XMLTAG_GLYPH_BGN(fd, "invalid", id);
		save_int_xml(fd, "offset", glyph - MAX_GLYPH);
	} else if (glyph >= GLYPH_WARNING_OFF) {	/* a warning */
		XMLTAG_GLYPH_BGN(fd, "warning", id);
		save_int_xml(fd, "offset", glyph - GLYPH_WARNING_OFF);
	} else if (glyph >= GLYPH_SWALLOW_OFF) {	/* swallow border */
		XMLTAG_GLYPH_BGN(fd, "swallow border", id);
		offset = glyph - GLYPH_SWALLOW_OFF;
		save_int_xml(fd, "offset", offset & 0x7);
		save_monster_name_xml(fd, "monster", offset >> 3);
	} else if (glyph >= GLYPH_ZAP_OFF) {		/* zap beam */
		XMLTAG_GLYPH_BGN(fd, "zap beam", id);
		save_int_xml(fd, "offset", glyph - GLYPH_ZAP_OFF);
	} else if (glyph >= GLYPH_EXPLODE_OFF) {	/* explosion */
		XMLTAG_GLYPH_BGN(fd, "explosion", id);
		save_int_xml(fd, "offset", glyph - GLYPH_EXPLODE_OFF);
	} else if (glyph >= GLYPH_CMAP_OFF) {		/* cmap */
		XMLTAG_GLYPH_BGN(fd, "cmap", id);
		XML_SAVE_CMAP_NAME(fd, cmap_name[glyph - GLYPH_CMAP_OFF]);
	} else if (glyph >= GLYPH_OBJ_OFF) {		/* object */
		XMLTAG_GLYPH_BGN(fd, "object", id);
		save_object_name_xml(fd, glyph - GLYPH_OBJ_OFF);
	} else if (glyph >= GLYPH_RIDDEN_OFF) {		/* ridden mon */
		XMLTAG_GLYPH_BGN(fd, "ridden mon", id);
		save_monster_name_xml(fd, "monster", glyph - GLYPH_RIDDEN_OFF);
	} else if (glyph >= GLYPH_BODY_OFF) {		/* a corpse */
		XMLTAG_GLYPH_BGN(fd, "corpse", id);
		save_monster_name_xml(fd, "monster", glyph - GLYPH_BODY_OFF);
	} else if (glyph >= GLYPH_DETECT_OFF) {		/* detected mon */
		XMLTAG_GLYPH_BGN(fd, "detected mon", id);
		save_monster_name_xml(fd, "monster", glyph - GLYPH_DETECT_OFF);
	} else if (glyph >= GLYPH_INVIS_OFF) {		/* invisible mon */
		XMLTAG_GLYPH_BGN(fd, "invisible mon", id);
	} else if (glyph >= GLYPH_PET_OFF) {		/* a pet */
		XMLTAG_GLYPH_BGN(fd, "pet", id);
		save_monster_name_xml(fd, "monster", glyph - GLYPH_PET_OFF);
	} else {					/* a monster */
		XMLTAG_GLYPH_BGN(fd, "monster", id);
		save_monster_name_xml(fd, "monster", glyph);
	}

	XMLTAG_GLYPH_END(fd);
}

/* ---------------------------------------------------- */

EOM

    print RESTORE_XML_CORE_C <<'EOM';
/* This source file is generated by 'parse_struct.pl'.  Do not edit. */

#include "hack.h"

#ifdef SAVE_FILE_XML

#include "save_xml.h"
#include "struct_info.h"

int restore_file_format_xml = RESTORE_FILE_IS_BINARY;

int
cheak_save_file_format(ptr, size)
genericptr_t ptr;
int size;
{
	if (!memcmp(ptr, XML_FILE_MAGIC, size > XML_FILE_MAGIC_LEN ? XML_FILE_MAGIC_LEN : size)) {
		restore_file_format_xml = RESTORE_FILE_IS_XML;
		return RESTORE_FILE_IS_XML;
	}
#ifdef BONE_FILE_XML
	else if (!memcmp(ptr, XML_FILE_BONE_MAGIC,
			   size > XML_FILE_BONE_MAGIC_LEN ? XML_FILE_BONE_MAGIC_LEN : size)) {
		restore_file_format_xml = BONE_FILE_IS_XML;
		return BONE_FILE_IS_XML;
	}
#endif

	restore_file_format_xml = RESTORE_FILE_IS_BINARY;
	return RESTORE_FILE_IS_BINARY;
}

char *
unescape_string(str, copyf)
const char *str;
boolean copyf;
{
	char tmp[3], *buf, *p = index(str, '%');

	if (!p && !copyf)
		return (char *)str;

	/* too long sorce string! */
	if (strlen(str) > BUFSIZ - 1) {
		return "UNESCAPE ERROR!!!";
	}

	buf = gettmpbuf();

	if (!p) {
		(void) strcpy(buf, str);

		return buf;
	}

	buf[0] = 0;
	while (p) {
		strncat(buf, str, p - str);

		/* if next condition is true, broken string! */
		if ((*(p+1)) == 0 || (*(p+2)) == 0) {
			return "UNESCAPE ERROR!!!";
		}

		strncpy(tmp, p + 1, 2);
		tmp[2] = 0;
		tmp[0] = (char)strtol(tmp, NULL, 16);
		tmp[1] = 0;

		strcat(buf, tmp);

		str = p + 3;
		p = index(str, '%');
	}
	strcat(buf, str);

	return buf;
}

int
serach_struct_id(name)
const char *name;
{
	int ret, first = 0, last = STRUCT_ID_END;
	int i;

	while (last >= first) {
		ret = (first + last) / 2;
		i = strcmp(name, struct_info[ret].name);
		if (i < 0) {
			last  = ret - 1;
		} else if(i > 0) {
			first = ret + 1;
		} else
			return ret;
	}

	return -1;
}

int
serach_variable_id(var_info, num, name)
struct var_info_t *var_info;
int num;
const char *name;
{
	int ret, first = 0, last = num -1;
	int i;

	if (!var_info)
		return -1;

	while (last >= first) {
		ret = (first + last) / 2;
		i = strcmp(name, var_info[ret].name);
		if (i < 0) {
			last  = ret - 1;
		} else if(i > 0) {
			first = ret + 1;
		} else
			return ret;
	}

	return -1;
}

int
serach_name2num(name_table, num, name)
struct name_info_t *name_table;
int num;
const char *name;
{
	int ret, first = 0, last = num -1;
	int i;

	while (last >= first) {
		ret = (first + last) / 2;
		i = strcmp(name, name_table[ret].name);
		if (i < 0) {
			last  = ret - 1;
		} else if(i > 0) {
			first = ret + 1;
		} else
			return name_table[ret].num;
	}

	return -1;
}

static short monclass_start[MAXMCLASSES+1];
static short objclass_start[MAXOCLASSES+1];

void
init_restore_xml_tables()
{
	static int done = 0;
	int i, class;

	if (done)
		return;

	class = 0;
	for (i = LOW_PM; i < NUMMONS; i++) {
		if (class == mons[i].mlet)
			continue;

		class = mons[i].mlet;
		monclass_start[class] = i;
	}
	monclass_start[MAXMCLASSES] = NUMMONS;

	class = 0;
	for (i = 0; i < NUM_OBJECTS; i++) {
		if (class == objects[i].oc_class)
			continue;

		class = objects[i].oc_class;
		objclass_start[class] = i;
		bases[class] = i;
	}
	objclass_start[MAXOCLASSES] = NUM_OBJECTS;

	done = 1;
}

int
mname_to_mnum(mname, class)
const char *mname;
int class;
{
	int i;

	if (class != 0)
		for(i = monclass_start[class]; i < monclass_start[class+1]; i++)
			if (!strcmpi(mname, mons[i].mname))
				return i;

	for(i = NUMMONS - 1; i >= LOW_PM; i--)
		if (!strcmpi(mname, mons[i].mname))
			return i;

	return NON_PM;
}

/*
 * object 名がかわった場合の為の data
 * 要 sort
 */
static struct {
	const char *alias;
	const char *name;
	const char class;
} obj_name_aliases[] = {
	{"lenses",	"spectacles"	, TOOL_CLASS	},
	{"spectacles",	"lenses"	, TOOL_CLASS	},
};

static int
oname_to_otyp_(oname, class)
const char *oname;
int class;
{
	int i, start, end;

	if (class == RANDOM_CLASS) {
		start = 0;
		end   = NUM_OBJECTS;
	} else {
		start = objclass_start[class];
		end   = objclass_start[class+1];
	}

	for(i = start; i < end; i++) {
		if (!obj_descr[i].oc_name)
			continue;

		if (!strcmpi(oname, obj_descr[i].oc_name))
			return i;
	}

	return -1;
}

int
oname_to_otyp(oname, class)
const char *oname;
int class;
{
	int ret, i, j;
	int num = (sizeof(obj_name_aliases)/ sizeof(obj_name_aliases[0]));

	ret = oname_to_otyp_(oname, class);

	if (ret >= 0)
		return ret;

	for (i = 0; i < num; i++) {
		j = strcmpi(oname, obj_name_aliases[i].alias);

		if (j == 0 && (obj_name_aliases[i].class == class || class == RANDOM_CLASS)) {
			ret = oname_to_otyp_(obj_name_aliases[i].name, class);

			if (ret >= 0)
				return ret;
		} else if (j > 0)
			return -1;
	}

	return ret;
}

int
oclassnm_to_oclass(oclassnm)
const char *oclassnm;
{
	int i;

	for(i = 1; i < MAXOCLASSES; i++) {
		if (!strcmpi(oclassnm, oclass_names_xml[i]))
			return i;
	}

	return -1;
}

int
ounknname_to_idx(ounknname, class)
const char *ounknname;
int class;
{
	int i, start, end;

	if (class == RANDOM_CLASS) {
		start = 0;
		end   = NUM_OBJECTS;
	} else {
		start = objclass_start[class];
		end   = objclass_start[class+1];
	}

	for(i = start; i < end; i++) {
		if (!obj_descr[i].oc_descr)
			continue;

		if (!strcmpi(ounknname, obj_descr[i].oc_descr))
			return i;
	}

	return -1;
}

static boolean
str2bool(str)
const char *str;
{
	if (!str || !strcmpi(str, "false") || !strcmp(str, "0"))
		return FALSE;
	else
		return TRUE;
}

#ifdef RANDOM_QUEST /* quest change test [Ide]*/
static int
str2quest(str)
const char *str;
{
	int i;

	/* Is str valid? */
	if (!str || !str[0])
		return ROLE_NONE;

	for(i = 0; qdatas[i].filecode; i++) {
		if (!strcmp(str, qdatas[i].filecode))
			return i;
	}

	return ROLE_NONE;
}
#endif /* RANDOM_QUEST */

static struct monst *
realloc_mon(mon, mxlth)
struct monst *mon;
int mxlth;
{
	struct monst *mtmp;

	if (!mon)
		return 0;

	mtmp = newmonst(mxlth + mon->mnamelth);
	(void) memset((genericptr_t)(&(mtmp->mextra[0])), 0, mxlth);

	*mtmp = *mon;
	mtmp->mxlth = mxlth;
	if (mon->mnamelth) Strcpy(NAME(mtmp), NAME(mon));

	dealloc_monst(mon);

	return mtmp;
}

#if 0
#define impossible(format, args...) fprintf(stderr, format "\n", args)
#endif

static void
print_nonimplimant_error(current, variable_id)
struct restore_stat_t *current;
int variable_id;
{
	const char *struct_name;
	int struct_id = current->id;

	if (struct_id < 0 || struct_id > STRUCTURE_END) {
		impossible("Don't impliment: structure_id = %d:\tvariable_id = %d\n", struct_id, variable_id);
		return;
	}

	struct_name = struct_info[struct_id].name;

	if (variable_id < 0 || variable_id >= struct_info[struct_id].num_var) {
		impossible("Don't impliment: structure = %s:\tvariable_id = %d\n", struct_name, variable_id);
	} else {
		impossible("Don't impliment: %s->%s\n", struct_name, struct_info[struct_id].var_info[variable_id].name);

	}
}

#define Strtol(ptr, next, base)		((ptr) ? strtol((ptr), (next), (base)) : 0)
#define Strtoul(ptr, next, base)	((ptr) ? strtoul((ptr), (next), (base)) : 0)
#ifndef WIN32
# define Strtoll(ptr, next, base)	((ptr) ? strtoll((ptr), (next), (base)) : 0)
#else
# define Strtoll(ptr, next, base)	((ptr) ? _atoi64((ptr)) : 0)
#endif

/* ---------------------------------------------------- */

genericptr_t
restore_core(current, type, id, data, variable_id_p)
struct restore_stat_t *current;
int type;
const char * id;
const char *data;
int *variable_id_p;
{
	int variable_id = -1, struct_id = current->id;
	genericptr_t ptr = current->ptr;
	boolean is_array_element = FALSE;

	if (current->skip)
		return 0;

	switch (struct_id) {
	case STRUCTURE_ARRAY:
		is_array_element = TRUE;
		struct_id = current->u.array.type;
		variable_id = current->u.array.var_id;
		break;
	case STRUCTURE_ARTIFACT:
		if (type == VALUE_TYPE_BOOL && !strcmp(id, "discover"))
			current->tmp.b = str2bool(data);
		else
			current->tmp.b = FALSE;
		return 0;
		break;
	case STRUCTURE_BRANCHES:
		if (type != STRUCT_ID_BRANCH)
			return 0;
		current->tmp.p = alloc(sizeof(branch));
		(void) memset(current->tmp.p, 0, sizeof(branch));
		return current->tmp.p;
		break;
	case STRUCTURE_BUBBLES:
		if (type != STRUCT_ID_BUBBLE)
			return 0;
		current->tmp.p = alloc(sizeof(struct bubble));
		(void) memset(current->tmp.p, 0, sizeof(struct bubble));
		return current->tmp.p;
		break;
	case STRUCTURE_DAMAGES:
		if (type != STRUCT_ID_DAMAGE)
			return 0;
		current->tmp.p = alloc(sizeof(struct damage));
		(void) memset(current->tmp.p, 0, sizeof(struct damage));
		return current->tmp.p;
		break;
#ifdef D_OVERVIEW 	/*Dungeon Map Overview 3 [IDE]*/
	case STRUCTURE_DUNGEON_OVERVIEW:
		if (type != STRUCT_ID_MAPSEEN)
			return 0;
		current->tmp.p = alloc(sizeof(mapseen));
		(void) memset(current->tmp.p, 0, sizeof(mapseen));

		current->u.mapseen.branchnum = Strtol(id, NULL, 0);

		return current->tmp.p;
		break;
#endif /*D_OVERVIEW*/
	case STRUCTURE_ENGRAVINGS:
		if (variable_id_p)
                        *variable_id_p = 0;
		if (type != STRUCT_ID_ENGR)
			return 0;

		current->tmp.p = (genericptr_t)newengr(0);

		((struct engr *)current->tmp.p)->engr_txt = NULL;
		((struct engr *)current->tmp.p)->engr_lth = 0;
		((struct engr *)current->tmp.p)->engr_time = 0;

		return current->tmp.p;
		break;
	case STRUCTURE_FLOOR:
		if (type != STRUCT_ID_RM)
			return 0;

		if (!strcmp(id, "background"))
			return (genericptr_t)(&levl[0][0]);
		else {
			int x, y;

			sscanf(id, "%d,%d", &x, &y);

			if (x >= 0 &&  x < COLNO &&  y >= 0 &&  y < ROWNO)
				return (genericptr_t)(&levl[x][y]);
			else
				return 0;
		}
		break;
	case STRUCTURE_FRUITS:
		if (type != STRUCT_ID_FRUIT)
			return 0;
		current->tmp.p = (genericptr_t)newfruit();
		(void) memset(current->tmp.p, 0, sizeof(struct fruit));
		return current->tmp.p;
		break;
	case STRUCTURE_GLYPH:
		if (!!strcmp(id, "offset")) {
			if (variable_id_p)
                                *variable_id_p = -1;
			return 0;
		}

		if (type == VALUE_TYPE_INT || type == VALUE_TYPE_SHORT)
			current->tmp.i = Strtol(data, NULL, 0);
		else
			current->tmp.i = 0;

		return 0;
		break;
	case STRUCTURE_LEVCHN:
		if (type != STRUCT_ID_S_LEVEL)
			return 0;
		current->tmp.p = alloc(sizeof(s_level));
		(void) memset(current->tmp.p, 0, sizeof(s_level));
		return current->tmp.p;
		break;
	case STRUCTURE_LIGHT_SOURCES:
		if (type != STRUCT_ID_LIGHT_SOURCE)
			return 0;
		current->tmp.p = alloc(sizeof(light_source));
		(void) memset(current->tmp.p, 0, sizeof(light_source));
		return current->tmp.p;
		break;
	case STRUCTURE_OBJECT_CLASS:
		if (!strcmp(id, "discover")) {
			if (type != VALUE_TYPE_BOOL)
				current->tmp.b = FALSE;
			else
				current->tmp.b = str2bool(data);
			return 0;
		} else if (!strcmp(id, "oc_uname")) {
			if (type != VALUE_TYPE_STRING)
				current->tmp.p = NULL;
			else
				current->tmp.p = (genericptr_t)strdup(str2ic_xml(data));
			return 0;
		} else {
			if (variable_id_p)
                                *variable_id_p = 0;

			if (type != STRUCT_ID_OBJCLASS ||
			    current->u.objclass.otyp < 0 ||
			    current->u.objclass.otyp >= NUM_OBJECTS)
				return 0;

			return (genericptr_t)(&objects[current->u.objclass.otyp]);
		}
		break;
	case STRUCTURE_ORACLES:
		if (!ptr || !(type == VALUE_TYPE_LONG || type == VALUE_TYPE_ULONG || type == VALUE_TYPE_INT))
			return 0;

		((long *)ptr)[current->u.array.index++] = Strtol(data, NULL, 0);

		return 0;
		break;
	case STRUCTURE_ROOM:
		if (variable_id_p)
			*variable_id_p = 0;

		if (type != STRUCT_ID_MKROOM)
			return 0;

		return ptr;
		break;
	case STRUCTURE_SPELL_BOOK:
		if (!ptr || type != STRUCT_ID_SPELL) return 0;

		((struct spell *)ptr)[current->u.array.index].sp_id = oname_to_otyp(id, SPBOOK_CLASS);
		return (genericptr_t)(&(((struct spell *)ptr)[current->u.array.index++]));
		break;
	case STRUCTURE_TRAPS:
		if (type != STRUCT_ID_TRAP)
			return 0;

		current->tmp.p = (genericptr_t)newtrap();
		(void) memset(current->tmp.p, 0, sizeof(struct trap));
		return current->tmp.p;
		break;
	case STRUCTURE_VERSION:
		if (!strcmp(id, "version_data")) {
			if (variable_id_p)
                                *variable_id_p = 0;

			if (type != STRUCT_ID_VERSION_INFO)
				return 0;
			else
				return (genericptr_t)(&(current->u.vers_info));
		} else if (!strcmp(id, "variant")) {
			if (type != VALUE_TYPE_STRING)
				current->tmp.p = 0;
			else
				current->tmp.p = (genericptr_t)strdup(data);
			return 0;
		}
		break;
	case STRUCTURE_WORM:
		if (type == VALUE_TYPE_CHAR || type == VALUE_TYPE_SCHAR || type == VALUE_TYPE_UCHAR)
			current->tmp.i = Strtol(data, NULL, 0);
		else
			current->tmp.i = 0;

		return 0;
		break;
	default:
		if (struct_id < 0 || struct_id > STRUCTURE_END) {
			impossible("restore_xml: unknown struct: %d", struct_id);

			if (variable_id_p)
				*variable_id_p = -1;

			return 0;
		}

		variable_id = serach_variable_id(struct_info[struct_id].var_info,
						 struct_info[struct_id].num_var, id);
		break;
	}

	if (variable_id_p)
		*variable_id_p = variable_id;

	switch (struct_id) {
	case STRUCTURE_GAMESTAT:
		switch (variable_id) {
		case VARIABLE_ID_SAVE_C__UID:
			if (type == VALUE_TYPE_INT || type == VALUE_TYPE_UINT)
				current->u.gamestat.uid = Strtol(data, NULL, 0);
			else
				current->u.gamestat.uid = -1;
			return 0;
			break;
		case VARIABLE_ID_SAVE_C__USTEED_ID:
			if (type == VALUE_TYPE_INT || type == VALUE_TYPE_UINT)
				*(current->u.gamestat.steedid) = Strtoul(data, NULL, 0);
			else
				*(current->u.gamestat.steedid) = 0;
			return 0;
			break;
		case VARIABLE_ID_SAVE_C__USTUCK_ID:
			if (type == VALUE_TYPE_INT || type == VALUE_TYPE_UINT)
				*(current->u.gamestat.stuckid) = Strtoul(data, NULL, 0);
			else
				*(current->u.gamestat.stuckid) = 0;
			return 0;
			break;
		}
	case STRUCTURE_LEVELDATA:
		switch (variable_id) {
		case VARIABLE_ID_SAVE_C__HACKPID:
			if (type == VALUE_TYPE_INT || type == VALUE_TYPE_UINT)
				current->u.leveldata.pid = Strtol(data, NULL, 0);
			else
				current->u.leveldata.pid = -1;
			return 0;
			break;
		case VARIABLE_ID_SAVE_C__OMOVES:
			if (type == VALUE_TYPE_INT || type == VALUE_TYPE_UINT ||
			    type == VALUE_TYPE_LONG || type == VALUE_TYPE_ULONG)
				*(current->u.leveldata.omoves) = Strtol(data, NULL, 0);
			else
				*(current->u.leveldata.omoves) = 0;
			return 0;
			break;
		}
		break;
	case STRUCTURE_MONSTER:
		switch (variable_id) {
		case VARIABLE_ID_SAVE_C__MNAME:
			if (data && type == VALUE_TYPE_STRING)
				current->u.mon.mname = strdup(str2ic_xml(data));
			else
				current->u.mon.mname = 0;
			return 0;
			break;
		case VARIABLE_ID_SAVE_C__MON:
			if (type != STRUCT_ID_MONST)
				return 0;

			if (current->u.mon.mname) {
				int len = strlen(current->u.mon.mname);
				struct monst *mtmp = newmonst(len ? len + 1 : 0);

				(void) memset((genericptr_t)mtmp, 0, sizeof(struct monst));
				current->u.mon.mtmp = mtmp;
				mtmp->mnamelth = len ? len + 1 : 0;
				mtmp->mxlth = 0;
				mtmp->nmon = 0;
				mtmp->minvent = 0;
				if (len) strcpy(NAME(mtmp), current->u.mon.mname);

				free(current->u.mon.mname);
				current->u.mon.mname = NULL;
			} else {
				struct monst *mtmp = newmonst(0);

				(void) memset((genericptr_t)mtmp, 0, sizeof(struct monst));
				current->u.mon.mtmp = mtmp;
				mtmp->mnamelth = 0;
				mtmp->mxlth = 0;
				mtmp->nmon = 0;
				mtmp->minvent = 0;
			}

			return (genericptr_t)current->u.mon.mtmp;
			break;
		case VARIABLE_ID_SAVE_C__EDOG:
			if (type != STRUCT_ID_EDOG)
				return 0;
			current->u.mon.mtmp = realloc_mon(current->u.mon.mtmp, sizeof(struct edog));
			return (genericptr_t)EDOG(current->u.mon.mtmp);
		case VARIABLE_ID_SAVE_C__EGD:
			if (type != STRUCT_ID_EGD)
				return 0;
			current->u.mon.mtmp = realloc_mon(current->u.mon.mtmp, sizeof(struct egd));
			return (genericptr_t)EGD(current->u.mon.mtmp);
		case VARIABLE_ID_SAVE_C__EMIN:
			if (type != STRUCT_ID_EMIN)
				return 0;
			current->u.mon.mtmp = realloc_mon(current->u.mon.mtmp, sizeof(struct emin));
			return (genericptr_t)EMIN(current->u.mon.mtmp);
		case VARIABLE_ID_SAVE_C__EPRI:
			if (type != STRUCT_ID_EPRI)
				return 0;
			current->u.mon.mtmp = realloc_mon(current->u.mon.mtmp, sizeof(struct epri));
			return (genericptr_t)EPRI(current->u.mon.mtmp);
		case VARIABLE_ID_SAVE_C__ESHK:
			if (type != STRUCT_ID_ESHK)
				return 0;
			current->u.mon.mtmp = realloc_mon(current->u.mon.mtmp, sizeof(struct eshk));
			return (genericptr_t)ESHK(current->u.mon.mtmp);
		default:
			break;
		}
		return 0;
		break;
	case STRUCTURE_OBJECT:
		switch (variable_id) {
		case VARIABLE_ID_SAVE_C__ARTIFACT_NAME:
			if (data && type == VALUE_TYPE_STRING)
				current->u.obj.oartifact = artname2artino(data);
			else
				current->u.obj.oartifact = 0;
			return 0;
			break;
		case VARIABLE_ID_SAVE_C__M_ID:
			if (type != VALUE_TYPE_UINT)
				current->tmp.i = 0;
			else
				current->tmp.i = Strtoul(data, NULL, 0);
			return 0;
			break;
		case VARIABLE_ID_SAVE_C__OBJ:
			if (type != STRUCT_ID_OBJ)
				return 0;

			if (current->u.obj.oname) {
				int len = strlen(current->u.obj.oname);
				struct obj *otmp = newobj(len ? len + 1 : 0);

				(void) memset((genericptr_t)otmp, 0, sizeof(struct obj));
				current->u.obj.otmp = otmp;
				otmp->oxlth = 0;
				otmp->onamelth = len ? len + 1 : 0;
				otmp->cobj = NULL;
				if (len) strcpy(ONAME(otmp), current->u.obj.oname);

				free(current->u.obj.oname);
				current->u.obj.oname = NULL;
			} else {
				struct obj *otmp = newobj(0);

				(void) memset((genericptr_t)otmp, 0, sizeof(struct obj));
				current->u.obj.otmp = otmp;
				otmp->oxlth = 0;
				otmp->onamelth = 0;
				otmp->cobj = NULL;
			}

			return (genericptr_t)current->u.obj.otmp;
			break;
		case VARIABLE_ID_SAVE_C__ONAME:
			if (type == VALUE_TYPE_STRING)
				current->u.obj.oname = strdup(str2ic_xml(data));
			return 0;
			break;
		default:
			break;
		}
		return 0;
		break;
	case STRUCTURE_REGIONS:
		switch (variable_id) {
		case VARIABLE_ID_REGION_C__REGIONS:
			if (!is_array_element) {
				int n_regions = (int)data;
				NhRegion ***reg = (NhRegion ***)(var_info_region_c[VARIABLE_ID_REGION_C__REGIONS].ptr);

				if (type != STRUCTURE_ARRAY)
					return 0;

				if (n_regions > 0)
					*reg = (NhRegion **) alloc(sizeof (NhRegion *) * n_regions);
				else
					*reg = NULL;
				*((int *)(var_info_region_c[VARIABLE_ID_REGION_C__N_REGIONS].ptr))   = n_regions;
				*((int *)(var_info_region_c[VARIABLE_ID_REGION_C__MAX_REGIONS].ptr)) = n_regions;
				current->ptr = (genericptr_t)(*reg);

				return current->ptr;
			} else {
				if (type != STRUCT_ID_NHREGION) {
					return 0;
				} else {
					int i = current->u.array.index++;
					NhRegion ***reg = (NhRegion ***)var_info_region_c[VARIABLE_ID_REGION_C__REGIONS].ptr;

					(*reg)[i] = (NhRegion *) alloc(sizeof (NhRegion));
					return (genericptr_t)((*reg)[i]);
				}
			}
			break;
		case VARIABLE_ID_REGION_C__MOVES:
			if (type == VALUE_TYPE_LONG || type == VALUE_TYPE_ULONG)
				current->tmp.l = Strtol(data, NULL, 0);
			else
				current->tmp.l = 0;
			return 0;
			break;
		default:
			break;
		}
		break;
	case STRUCTURE_TIMER:
		switch (variable_id) {
		case VARIABLE_ID_TIMEOUT_C__TIMER_ID:
			if (current->u.timer.range != RANGE_GLOBAL ||
			    (!(type == VALUE_TYPE_ULONG || type == VALUE_TYPE_LONG))) {
				return 0;
			}

			ptr = var_info_timeout_c[VARIABLE_ID_TIMEOUT_C__TIMER_ID].ptr;
			break;
		case VARIABLE_ID_TIMEOUT_C__TIMER:
			if (variable_id_p)
				*variable_id_p = 0;

			if (type != STRUCT_ID_TIMER_ELEMENT)
				return 0;

			current->u.timer.timer = (timer_element *) alloc(sizeof(timer_element));

			return (genericptr_t)current->u.timer.timer;
			break;
		}
		break;
	}

	if (variable_id < 0) {
		impossible("restore_xml: unknown variable: %s->%s", struct_info[struct_id].name, id);
		return 0;
	}

	if (struct_id <= STRUCT_ID_END && !ptr) {
		impossible("restore_xml: null pointer error: %s->%s",
				struct_info[struct_id].name,
				struct_info[struct_id].var_info[variable_id].name);
		return 0;
	}

	switch (struct_id) {
EOM
}
