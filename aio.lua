--[[#Header
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions and ideas goes to Rav3n_pl, Tlaloc and Gary Forbis
Special thanks goes to Seagat2011
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
Version     = "1120"
Release     = false         -- if true this script is probably safe ;)
numsegs     = get_segment_count()
--Game vars#

--#Settings: default
--#Working                  default     description
i_maxiter       = 5         -- 5        max. iterations an action will do | use higher number for a better gain but script needs a longer time
i_start_seg     = 1         -- 1        the first segment to work with
i_end_seg       = numsegs   -- numsegs  the last segment to work with
i_start_walk    = 0         -- 0        with how many segs shall we work - Walker
i_end_walk      = 3         -- 3        starting at the current seg + i_start_walk to seg + i_end_walk
b_lws           = false     -- false    do local wiggle and rewiggle
b_rebuild       = false     -- false    rebuild | see #Rebuilding
--
b_pp            = true     -- false    pull hydrophobic amino acids in different modes then fuze | see #Pull
b_fuze          = false     -- false    should we fuze | see #Fuzing
b_snap          = false     -- false    should we snap every sidechain to different positions
b_predict       = false     -- false    reset and predict then the secondary structure based on the amino acids of the protein
b_str_re        = false     -- false    rebuild the protein based on the secondary structures | see #Structed rebuilding
b_sphered       = false     -- false    work with a sphere always, can be used on lws and rebuilding walker
b_explore       = false     -- false    if true then the overall score will be taken if a exploration puzzle, if false then just the stability score is used for the methods
--Working#

--#Scoring | adjust a lower value to get the lws script working on high evo- / solos, higher values are probably better rebuilding the protein
i_score_step    = 0.01     -- 0.01    an action tries to get this score, then it will repeat itself
i_score_gain    = 0.01     -- 0.01    Score will get applied after the score changed this value
--Scoring#

--#Pull
b_comp          = false     -- false    try a pull of the two segments which have the biggest distance in between
i_pp_trys       = 1         -- 1        how often should the pull start over?
i_pp_loss       = 1         -- 1        the score / 100 * i_pp_loss is the general formula for calculating the points we must lose till we fuze
b_pp_pre_strong = true      -- true     bands are created which pull segs together based on the size, charge and isoelectric point of the amino acids
b_pp_pre_local  = false
b_pp_pull       = true      -- true     hydrophobic segs are pulled together
b_pp_push       = true
i_pp_bandperc   = 0.04
b_pp_fixed      = false      -- false
i_pp_fix_start  = 38
i_pp_fix_end    = 46
b_pp_centerpull = true      -- true     hydrophobic segs are pulled to the center segment
b_pp_centerpush = true
--Pull

--#Fuzing
b_fast_fuze     = false     -- false    not qstab is used here, a part of the Pink fuze which just loosen up the prot a bit and then wiggle it (faster than qstab, recommend for evo work where the protein is a bit stiff)
--Fuzing#

--#Snapping
b_snap_fast     = true
--Snapping#

--#Rebuilding
--b_worst_rebuild = false     -- false    rebuild worst scored parts of the protein | NOT READY YET
i_max_rebuilds  = 2         -- 2        max rebuilds till best rebuild will be chosen 
i_rebuild_str   = 1         -- 1        the iterations a rebuild will do at default, automatically increased if no change in score
--Rebuilding#

--#Predicting
b_predict_full  = false     -- try to detect the secondary structure between every segment, there can be less loops but the protein become impossible to rebuild
--Predicting#

--#Structed rebuilding      default     description
i_str_re_max_re = 2         -- 2        same as i_max_rebuilds at #Rebuilding
i_str_re_re_str = 1         -- 1        same as i_rebuild_str at #Rebuilding
b_re_he         = true      -- true     should we rebuild helices
b_re_sh         = true      -- true     should we rebuild sheets
b_str_re_fuze   = false      -- true     should we fuze after one rebuild
--Structed rebuilding#
--Settings#

--#Constants | Game vars
sls         = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
rebuilding  = false
snapping    = false
sc_changed  = true
--Constants | Game vars#

--#Securing for changes that will be made at Fold.it
assert          = nil
error           = nil
debug           = nil
math            = nil
--Securing#

--#Optimizing
p               = print

reset =
{   best    = restore_abs_best,
    score   = reset_recent_best,
    recent  = restore_recent_best,
    puzzle  = reset_puzzle
}

band =
{   add         = band_add_segment_segment,
    length      = band_set_length,
    strength    = band_set_strength,
    disable     = band_disable,
    enable      = band_enable,
    delete      = band_delete
}

wiggle =
{   _local      = do_local_wiggle,
    all         = do_global_wiggle_all,
    sidechains  = do_global_wiggle_sidechains,
    backbone    = do_global_wiggle_backbone
}

deselect =
{   index   = deselect_index,
    all     = deselect_all
}

local function _freeze(f)
    if f == "b" then
        do_freeze(true, false)
    elseif f == "s" then
        do_freeze(false, true)
    else -- if
        do_freeze(true, true)
    end -- if
end -- function

do_ =
{   shake       = do_shake,
    rebuild     = do_local_rebuild,
    mutate      = do_mutate,
    snap        = do_sidechain_snap,
    freeze      = _freeze,
    unfreeze    = do_unfreeze_all
}

set =
{   cl          = set_behavior_clash_importance,
    ss          = replace_ss,
    aa          = replace_aa
}
--Optimizing#

--#Debug
local function _assert(b, m)
    if not b then
        p(m)
        error()
    end -- if
end -- function

local function _score()
    local s = 0
    if b_explore then
        s = get.ranked(true)
    else -- if
        s = get.score(true)
    end -- if
    return s
end -- function

debug =
{   assert  = _assert,
    score   = _score
}
--Debug#

--#Amino
amino_segs      = {'a', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'y'}
amino_part      = { short = 0, abbrev = 1, longname = 2, hydro = 3, scale = 4, pref = 5, mol = 6, pl = 7, vdw_vol = 8}
amino_table     = {
  -- short, {abbrev,longname,           hydrophobic,scale,  pref,   mol,        pl,     vdw vol }
    ['a'] = {'Ala', 'Alanine',          true,       -1.6,   'H',    89.09404,   6.01,   67      },
    ['c'] = {'Cys', 'Cysteine',         true,       -17,    'E',    121.15404,  5.05,   86      },
    ['d'] = {'Asp', 'Aspartic acid',    false,      6.7,    'L',    133.10384,  2.85,   91      },
    ['e'] = {'Glu', 'Glutamic acid',    false,      8.1,    'H',    147.13074,  3.15,   109     },
    ['f'] = {'Phe', 'Phenylalanine',    true,       -6.3,   'E',    165.19184,  5.49,   135     },
    ['g'] = {'Gly', 'Glycine',          true,       1.7,    'L',    75.06714,   6.06,   48      },
    ['h'] = {'His', 'Histidine',        false,      -5.6,   nil,    155.15634,  7.60,   118     },
    ['i'] = {'Ile', 'Isoleucine',       true,       -2.4,   'E',    131.17464,  6.05,   124     },
    ['k'] = {'Lys', 'Lysine',           false,      6.5,    'H',    146.18934,  9.60,   135     },
    ['l'] = {'Leu', 'Leucine',          true,       1,      'H',    131.17464,  6.01,   124     },
    ['m'] = {'Met', 'Methionine',       true,       3.4,    'H',    149.20784,  5.74,   124     },
    ['n'] = {'Asn', 'Asparagine',       false,      8.9,    'L',    132.11904,  5.41,   96      },
    ['p'] = {'Pro', 'Proline',          true,       -0.2,   'L',    115.13194,  6.30,   90      },
    ['q'] = {'Gln', 'Glutamine',        false,      9.7,    'H',    146.14594,  5.65,   114     },
    ['r'] = {'Arg', 'Arginine',         false,      9.8,    'H',    174.20274,  10.76,  148     },
    ['s'] = {'Ser', 'Serine',           false,      3.7,    'L',    105.09344,  5.68,   73      },
    ['t'] = {'Thr', 'Threonine',        false,      2.7,    'E',    119.12034,  5.60,   93      },
    ['v'] = {'Val', 'Valine',           true,       -2.9,   'E',    117.14784,  6.00,   105     },
    ['w'] = {'Trp', 'Tryptophan',       true,       -9.1,   'E',    204.22844,  5.89,   163     },
    ['y'] = {'Tyr', 'Tyrosine',         true,       -5.1,   'E',    181.19124,  5.64,   141     }
}

local function _short(seg)
    return amino_table[aa[seg]][amino_part.short]
end

local function _abbrev(seg)
    return amino_table[aa[seg]][amino_part.abbrev]
end

local function _long(seg)
    return amino_table[aa[seg]][amino_part.longname]
end

local function _h(seg)
    return amino_table[aa[seg]][amino_part.hydro]
end

local function _hscale(seg)
    return amino_table[aa[seg]][amino_part.scale]
end

local function _pref(seg)
    return amino_table[aa[seg]][amino_part.pref]
end

local function _mol(seg)
    return amino_table[aa[seg]][amino_part.mol]
end

local function _pl(seg)
    return amino_table[aa[seg]][amino_part.pl]
end

local function _vdw_radius(seg)
    return ((amino_table[aa[seg]][amino_part.vdw_vol] * 3 / 4) / 3.14159) ^ (1 / 3)
end

amino =
{   short       = _short,
    abbrev      = _abbrev,
    longname    = _long,
    hydro       = _h,
    hydroscale  = _hscale,
    preffered   = _pref,
    size        = _mol,
    charge      = _pl,
    vdw_radius  = _vdw_radius
}

--#Calculations
local function _HCI(seg_a, seg_b) -- hydropathy
    return 20 - math.abs((amino.hydroscale(seg_a) - amino.hydroscale(seg_b)) * 19/10.6)
end

local function _SCI(seg_a, seg_b) -- size
    return 20 - math.abs((amino.size(seg_a) + amino.size(seg_b) - 123) * 19/135)
end

local function _CCI(seg_a, seg_b) -- charge
    return 11 - (amino.charge(seg_a) - 7) * (amino.charge(seg_b) - 7) * 19/33.8
end

local function _calc()
    p("Calculating Scoring Matrix")
    local hci_table = {}
    local cci_table = {}
    local sci_table = {}
    for i = 1, #amino_segs do
        hci_table[amino_segs[i]] = {}
        cci_table[amino_segs[i]] = {}
        sci_table[amino_segs[i]] = {}
        for ii = 1, #amino_segs do
            hci_table[amino_segs[i]][amino_segs[ii]] = calc.hci(i, ii)
            cci_table[amino_segs[i]][amino_segs[ii]] = calc.cci(i, ii)
            sci_table[amino_segs[i]][amino_segs[ii]] = calc.sci(i, ii)
        end -- for ii
    end -- for i
    p("Getting Segment Score out of the Matrix")
    strength = {}
    for i = 1, numsegs do
        strength[i] = {}
        for ii = i + 2, numsegs - 2 do
            strength[i][ii] = (hci_table[aa[i]][aa[ii]] * 2) + (cci_table[aa[i]][aa[ii]] * 1.26 * 1.065) + (sci_table[aa[i]][aa[ii]] * 2)
        end  -- for ii
    end -- for i
end -- function

calc =
{   hci = _HCI,
    sci = _SCI,
    cci = _CCI,
    run = _calc
}
--Calculations#
--Amino#

--#External functions
--#Math library
--[[
The original random script this was ported from has the following notices:
Copyright (c) 2007 Richard L. Mueller
Hilltop Lab web site - http://www.rlmueller.net
Version 1.0 - January 2, 2007
You have a royalty-free right to use, modify, reproduce, and distribute this script file in any
way you find useful, provided that you agree that the copyright owner above has no warranty,
obligations, or liability for such use.
This function is not covered by the Creative Commons license given at the start of the script,
and is instead covered by the comment given here.
]]
lngX = 1000
lngC = 48313
local function _MWC()
    local A_Hi = 63551
    local A_Lo = 25354
    local M = 4294967296
    local H = 65536
    local S_Hi = math.floor(lngX / H)
    local S_Lo = lngX - (S_Hi * H)
    local C_Hi = math.floor(lngC / H)
    local C_Lo = lngC - (C_Hi * H)
    local F1 = A_Hi * S_Hi
    local F2 = (A_Hi * S_Lo) + (A_Lo * S_Hi) + C_Hi
    local F3 = (A_Lo * S_Lo) + C_Lo
    local T1 = math.floor(F2 / H)
    local T2 = F2 - (T1 * H)
    lngX = (T2 * H) + F3
    local T3 = math.floor(lngX / M)
    lngX = lngX - (T3 * M)
    lngC = math.floor((F2 / H) + F1)
    return lngX
end -- function

local function _floor(value, _n)
    local n
    if _n then
        n = 1 * 10 ^ (-_n)
    else -- if
        n = 1
    end -- if
    return value - (value % n)
end -- function

local function _randomseed(x)
    if x then
        lngX = x
    end
end -- function

local function _random(m,n)
    if not n and m then
        n = m
        m = 1
    end -- if n
    if not m and not n then
        return _MWC() / 4294967296
    else -- if m
        if n < m then
            return nil
        end -- if n < m
        return math.floor((_MWC() / 4294967296) * (n - m + 1)) + m
    end -- if m
end -- function

local function _abs(x)
    if x < 0 then
        return -x
    else -- if
        return x
    end -- if
end -- function

math =
{   floor       = _floor,
    random      = _random,
    randomseed  = _randomseed,
    abs         = _abs
}
--Math library#

--#Getters
local function _dists()
    distances = {}
    for i = 1, numsegs - 1 do
        distances[i] = {}
        for j = i + 1, numsegs do
            distances[i][j] = get.distance(i, j)
        end -- for j
    end -- for i
end -- function

local function _sphere(seg, radius)
    local sphere = {}
    for i = 1, numsegs do
        if get.distance(seg, i) <= radius then
            sphere[#sphere + 1] = i
        end -- if get_
    end -- for i
    return sphere
end -- function

local function _center()
    local minDistance = 10000
    local distance
    local indexCenter
    get.dists()
    for i = 1, numsegs do
        distance = 0
        for j = 1, numsegs do
        if i ~= j then
            local x = i
            local y = j
            if x > y then x, y = y, x end
                distance = distance + distances[x][y]
            end -- if i ~= j
        end -- for j
        if distance < minDistance then
            minDistance = distance
            indexCenter =  i
        end -- if distance
    end -- for i
    return indexCenter
end -- function

local function _segs(_local)
    if _local then
        start = seg
        _end = r
    else -- if
        start = i_start_seg
        _end = i_end_seg
    end -- if
end -- function

local function _increase(sc1, sc2, slot, step)
    if step then
        if sc2 - sc1 < step then
            sl.load(slot)
            return
        end
    end
    if sc2 > sc1 then
        sl.save(slot)
        p("+", sc2 - sc1, "+")
        local sc = debug.score()
        p("==", sc, "==")
    else -- if
        sl.load(slot)
    end -- if
end

get =
{   dists       = _dists,
    sphere      = _sphere,
    center      = _center,
    distance    = get_segment_distance,
    score       = get_score,
    ranked      = get_ranked_score,
    expscore    = get_exploration_score,
    seg_score   = get_segment_score,
    seg_part    = get_segment_score_part,
    ss          = get_ss,
    aa          = get_aa,
    seg_count   = get_segment_count,
    band_count  = get_band_count,
    hydrophobic = is_hydrophobic,
    snapcount   = get_sidechain_snap_count,
    segs        = _segs,
    increase    = _increase
}
--Getters#

--#Saveslot manager
local function _release(slot)
    sls[#sls + 1] = slot
end -- function

local function _request()
    debug.assert(#sls > 0, "Out of save slots")
    local slot = sls[#sls]
    sls[#sls] = nil
    return slot
end -- function

sl =
{   release = _release,
    request = _request,
    save    = quicksave,
    load    = quickload
}
--Saveslot manager#
--External functions#

--#Internal functions
--#Checks
--#Hydrocheck
local function _hydro()
    hydro = {}
    for i = 1, numsegs do
        hydro[i] = get.hydrophobic(i)
    end -- for i
end -- function
--Hydrocheck#

--#Ligand Check
local function _ligand()
    if get.ss(numsegs) == 'M' then
        numsegs = numsegs - 1
    end -- if get.ss
end -- function
--Ligand Check#

--#Structurecheck
local function _ss()
    ss = {}
    for i = 1, numsegs do
        ss[i] = get.ss(i)
    end -- for i
end -- function

local function _aa()
    aa = {}
    for i = 1, numsegs do
        aa[i] = get.aa(i)
    end -- for i
end -- function

local function _struct()
    check.secstr()
    p("Detecting structures of the protein")
    local helix
    local sheet
    local loop
    he = {}
    sh = {}
    lo = {}
    for i = 1, numsegs do
        if ss[i] == "H" and not helix then
            helix = true
            sheet = false
            loop = false
            he[#he + 1] = {}
        elseif ss[i] == "E" and not sheet then
            sheet = true
            loop = false
            helix = false
            sh[#sh + 1] = {}
        elseif ss[i] == "L" and not loop then
            loop = true
            helix = false
            sheet = false
            lo[#lo + 1] = {}
        end -- if ss
        if helix then
            if ss[i] == "H" then
                he[#he][#he[#he]+1] = i
            else -- if ss
                helix = false
            end -- if ss
        end -- if helix
        if sheet then
            if ss[i] == "E" then
                sh[#sh][#sh[#sh]+1] = i
            else -- if ss
                sheet = false
            end -- if ss
        end -- if sheet
        if loop then
            if ss[i] == "L" then
                lo[#lo][#lo[#lo]+1] = i
            else -- if ss
                loop = false
            end -- if ss
        end -- if loop
    end -- for
end -- function
--Structurecheck#

check =
{   secstr = _ss,
    aacid   = _aa,
    ligand  = _ligand,
    hydro   = _hydro,
    struct  = _struct
}
--Checks#

--#Fuzing
local function _loss(option, cl1, cl2)
    p("Fuzing Method ", option)
    p("cl1 ", cl1, ", cl2 ", cl2)
    reset.score()
    if option == 1 then
        local qs1 = debug.score()
        p("qStab cl1-s-cl2-wa-cl=1-s")
        work.step(false, "s", 1, cl1)
        work.step(false, "wa", 1, cl2)
        work.step(false, "s", 1, 1)
        work.gain("wa", 1)
        reset.recent()
        local qs2 = debug.score()
        if qs2 > qs1 then
            fuze.loss(1, cl1, cl2)
        end -- if
    elseif option == 2 then
        p("Blue Fuse cl1-s; cl2-s;")
        work.step(false, "s", 1, cl1)
        work.gain("wa", 1)
        reset.score()
        work.step(false, "s", 1, cl2)
        work.gain("wa", 1)
        reset.recent()
        work.step(false, "s", 1, cl1 - 0.02)
        work.gain("wa", 1)
    elseif option == 3 then
        p("Pink Fuse cl1-s-cl2-wa")
        work.step(false, "s", 1, cl1)
        work.step(false, "wa", 1, cl2)
        work.gain("wa", 1)
    elseif option == 4 then
        p("Pink Fuse cl1-wa-cl=1-wa-cl2-wa")
        work.step(false, "wa", 1, cl1)
        work.step(false, "wa", 1, 1)
        work.step(false, "wa", 1, cl2)
        work.gain("wa", 1)
    end -- if option
    reset.recent()
end -- function

local function _part(option, cl1, cl2)
    local s_f1 = debug.score()
    fuze.loss(option, cl1, cl2)
    local s_f2 = debug.score()
    get.increase(s_f1, s_f2, sl_f)
end -- function

local function _start(slot)
    p("Started Fuzing")
    sl_f = sl.request()
    local s_f1 = debug.score()
    sl.save(sl_f)
    if not b_fast_fuze then
        fuze.part(1, 0.1, 0.4)
        fuze.part(2, 0.05, 0.07)
    end -- if 
    fuze.part(3, 0.1, 0.7)
    if not b_fast_fuze then
        fuze.part(4, 0.6, 0.7)
    end
    sl.load(sl_f)
    local s_f2 = debug.score()
    sl.release(sl_f)
    get.increase(s_f1, s_f2, slot)
    p("++ Fuzing gained ", s_f2 - s_f1, "++")
    p("==", s_f2, "==")
    p("Fuzing ended")
end -- function

fuze =
{   loss    =   _loss,
    part    =   _part,
    start   =   _start
}
--Fuzing#

--#Universal select
local function _segs(sphered, start, _end, more)
    local list1
    if not more then
        deselect.all()
    end -- if more
    if start then
        if sphered then
            if _end then
                if start ~= _end then
                    list1 = get.sphere(_end, 10)
                    select.list(list1)
                end -- if ~= end
                if  start > _end then
                    local _start = _end
                    _end = start
                    start = _start
                end -- if > end
                select.range(start, _end)
            end
            list1 = get.sphere(start, 10)
            select.list(list1)
        elseif _end and start ~= _end then
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end -- if > end
            select.range(start, _end)
        else -- if sphered
            select.index(start)
        end -- if sphered
    else -- if start
        select.all()
    end -- if start
end -- function

local function _list(list)
    if list then
        for i = 1, #list do
            select.index(list[i])
        end -- for
    end -- if list
end -- function

select =
{   segs    = _segs,
    list    = _list,
    index   = select_index,
    range   = select_index_range,
    all     = select_all
}
--Universal select#

--#working
local function _gain(g, cl)
    local iter
    repeat
        iter = 0
        repeat
            iter = iter + 1
            local s1_f = debug.score()
            if iter <= i_maxiter then
                work.step(false, g, iter, cl)
            end -- if
            local s2_f = debug.score()
        until s2_f - s1_f < i_score_step
        local s3_f = debug.score()
        work.step(false, "s")
        local s4_f = debug.score()
    until s4_f - s3_f < i_score_step
end

local function _step(sphered, _g, iter, cl)
    if cl then
        set.cl(cl)
    end -- if
    if rebuilding and _g == "s" or snapping and _g == "s" or sphered then
        select.segs(true, seg, r)
    else -- if rebuiling
        select.segs()
    end -- if rebuilding
    if _g == "wa" then
        wiggle.all(iter)
    elseif _g == "s" then
        do_.shake(1)
    elseif _g == "wb" then
        wiggle.backbone(iter)
    elseif _g == "ws" then
        wiggle.sidechains(iter)
    elseif _g == "wl" then
        select.segs(false, seg, r)
        reset.score()
        for i = iter, iter + 5 do
            local s_s1 = debug.score()
            wiggle._local(i)
            reset.recent()
            local s_s2 = debug.score()
            if s_s2 > s_s1 then
                reset.score()
            else -- if >
                break
            end -- if >
        end -- for
    end -- if _g
end -- function

local function _flow(g)
    local ws_1 = debug.score()
    local iter = 0
    if rebuilding then
        slot = sl_re
    elseif snapping then -- if
        slot = snapwork
    else -- if
        slot = overall
    end -- if
    work_sl = sl.request()
    repeat
        iter = iter + 1
        if iter ~= 1 then
            sl.save(work_sl)
        end -- if iter
        s1 = debug.score()
        if iter < i_maxiter then
            if b_sphered then
                work.step(true, g, iter)
            else -- if b_sphered
                work.step(false, g, iter)
            end -- if b_sphered
        end -- <
        s2 = debug.score()
    until s2 - s1 < (i_score_step * iter)
    if s2 < s1 then
        sl.load(work_sl)
    else -- if <
        s1 = s2
    end -- if <
    sl.release(work_sl)
    get.increase(ws_1, s1, slot, i_score_gain)
    if s1 - ws_1 > i_score_gain then
        sc_changed = true
    end -- if
end -- function

function _quake()
    local s1
    local s2
    local s3 = debug.score()
    s3 = math.floor(math.abs(s3 / 100 * i_pp_loss), 4)
    local strength = 0.01 + 0.08 * i_pp_loss
    local bands = get.band_count()
    local quake = sl.request()
    local quake2 = sl.request()
    select.segs()
    if b_pp_pre_local then
        s3 = math.floor(s3 / bands , 4)
        strength = math.floor(strength * bands / 8, 4)
    end -- if
    p("Pulling until a loss of more than ", s3, " points")
    sl.save(quake2)
    repeat
        sl.load(quake2)
        p("Band strength: ", strength)
        s1 = debug.score()
        for i = 1, bands do
            band.strength(i, strength)
        end -- for
        reset.score()
        set.cl(0.9)
        wiggle.backbone(1)
        sl.save(quake)
        reset.recent()
        s2 = debug.score()
        if s2 > s1 then
            reset.recent()
            sl.save(quake2)
        end -- if >
        sl.load(quake)
        s2 = debug.score()
        strength = math.floor(strength * 2 - strength * 9 / 10, 4)
        if b_pp_pre_local then
            strength = math.floor(strength * 2 - strength * 6 / 7, 4)
        end -- if b_solo
        if strength > 10 then
            break
        end -- if strength
    until s1 - s2 > s3
    sl.release(quake)
    sl.release(quake2)
end -- function

local function _dist()
    p("Quaker")
    select.segs()
    local ps_1 = debug.score()
    sl.save(overall)
    dist = sl.request()
    sl.save(dist)
    work.quake()
    band.delete()
    fuze.start(dist)
    ps_2 = debug.score()
    get.increase(ps_1, ps_2, overall)
    sl.release(dist)
end -- function

local function _rebuild(trys, str)
    local re1
    local re2
    local iter = 1
    for i = 1, trys do
        p("Try ", i, "/", trys)
        re1 = debug.score()
        re2 = re1
        while re1 == re2 do
            do_.rebuild(iter * str)
            iter = iter + 1
            if iter > i_maxiter then
                iter = i_maxiter
            end -- if iter
            re2 = debug.score()
        end -- while
        iter = 1
    end -- for i
end -- function

work =
{   gain    = _gain,
    step    = _step,
    flow    = _flow,
    quake   = _quake,
    dist    = _dist,
    rebuild = _rebuild
}
--Working#

--#Bonding
--#Center
local function _cpl(_local)
    local indexCenter = get.center()
    get.segs(_local)
    for i = start, _end do
        if i ~= indexCenter then
            local x = i
            local y = indexCenter
            if x > y then x, y = y, x end
            if hydro[i] then
                band.add(x, y)
            end -- if hydro
        end -- if ~=
    end -- for
end -- function

local function _cps(_local, expand)
    local indexCenter = get.center()
    get.segs(_local)
    for i = start, _end do
        if i ~= indexCenter then
            local x = i
            local y = indexCenter
            if x > y then x, y = y, x end
            if not hydro[i] then
                if distances[x][y] <= (20 - expand) then
                    band.add(x, y)
                    local cband = get.band_count()
                    band.length(cband, distances[x][y] + expand)
                end
            end -- if hydro
        end -- if ~=
    end -- for
end -- function

local function _ps(_local, bandsp, expand)
    get.segs(_local)
    for x = start, _end - 2 do
        if not hydro[x] then
            for y = x + 2, _end do
                math.randomseed(distances[x][y])
                if not hydro[y] and math.random() <= bandsp then
                    if distances[x][y] <= (20 - expand) then
                        band.add(x, y)
                        local cband = get.band_count()
                        band.length(cband, distances[x][y] + expand)
                    end
                end
            end
        end
    end
end
--Center#

--#Pull
local function _pl(_local, bandsp)
    get.segs(_local)
    get.dists()
    if b_pp_fixed then
        for x = start, _end do
            if hydro[x] then
                for y = i_pp_fix_start, i_pp_fix_end do
                    math.randomseed(distances[x][y])
                    if hydro[y] and math.random() < bandsp * 4 then
                        band.add(x, y)
                    end
                end
            end
        end
    end -- if b_pp_fixed
    for x = start, _end - 2 do
        if hydro[x] then
            for y = x + 2, numsegs do
                math.randomseed(distances[x][y])
                if hydro[y] and math.random() < bandsp then
                    band.add(x, y)
                end -- hydro y
            end -- for y
        end -- if hydro x
    end -- for x
end -- function
--Pull#

--#BandMaxDist
local function _maxdist()
    get.dists()
    local maxdistance = 0
    for i = i_start_seg, i_end_seg do
        for j = i_start_seg, i_end_seg do
            if i ~= j then
                local x = i
                local y = j
                if x > y then
                    x, y = y, x
                end -- >
                if distances[x][y] > maxdistance then
                    maxdistance = distances[x][y]
                    maxx = i
                    maxy = j
                end -- if distances
            end -- if ~=
        end -- for j
    end -- for i
    band.add(maxx, maxy)
end -- function
--BandMaxDist#

local function _strong()
    get.dists()
    for i = 1, numsegs do
        local max_str = 0
        local min_dist = 999
        for ii = i + 2, numsegs - 2 do
            if max_str <= strength[i][ii] then
                if max_str ~= strength[i][ii] then
                    min_dist = 999
                end -- if max_str ~=
                max_str = strength[i][ii]
                if min_dist > distances[i][ii] then
                    min_dist = distances[i][ii]
                end -- if min_dist
            end -- if max_str <=
        end -- for ii
        for ii = i + 2, numsegs - 2 do
            if strength[i][ii] == max_str and min_dist == distances[i][ii] then
                band.add(i , ii)
            end -- if strength
        end -- for ii
    end -- for i
end -- function

local function _one(_seg)
    get.dists()
    for i = 1, numsegs do
        if _seg == i then
        local max_str = 0
        for ii = i + 2, numsegs - 2 do
            if max_str <= strength[i][ii] then
                max_str = strength[i][ii]
            end -- if max_str <=
        end -- for ii
        for ii = i + 2, numsegs - 2 do
            if strength[i][ii] == max_str then
                band.add(i , ii)
            end -- if strength
        end -- for ii
        end
    end -- for i
end -- function

local function _helix()
    for i = 1, #he do
        for ii = he[i][1], he[i][#he[i]] - 4 do
            band.add(ii, ii + 4)
        end -- for ii
    end -- for i
end -- function

local function _sheet()
    for i = 1, #sh do
        for ii = 1, #sh[i] - 2 do
            band.add(sh[i][ii], sh[i][ii] + 2)
            local bands = get.band_count()
            band.strength(bands, 2)
            band.length(bands, 15)
        end -- for ii
    end -- for i
end -- function

local function _comp_sheets()
    for i = 1, #sh - 1 do
        band.add(sh[i][1], sh[i + 1][1])
        band.add(sh[i][#sh[i]], sh[i + 1][#sh[i + 1]])
    end -- for i
end -- function

bonding =
{   centerpull  = _cpl,
    centerpush  = _cps,
    push        = _ps,
    pull        = _pl,
    maxdist     = _maxdist,
    helix       = _helix,
    sheet       = _sheet,
    comp_sheet  = _comp_sheet,
    matrix      =
    {   strong  = _strong,
        one     = _one
    }
}
--Bonding#
--Header#

--#Snapping
function snap()
    snapping = true
    snaps = sl.request()
    cs = debug.score()
    c_snap = debug.score()
    local s_1
    local s_2
    local c_s
    local c_s2
    sl.save(snaps)
    iii = get.snapcount(seg)
    p("Snapcount: ", iii, " - Segment ", seg)
    if iii > 1 then
        snapwork = sl.request()
        ii = 0
        while ii < iii do
            sl.load(snaps)
            c_s = debug.score()
            c_s2 = debug.score()
            while c_s2 == c_s do
                ii = ii + 1
                p("Snap ", ii, "/ ", iii)
                do_.snap(seg, ii)
                c_s2 = debug.score()
                p(c_s2 - c_s)
                if ii > iii then
                    break
                end
            end
            if ii > iii then
                break
            end
            if c_s - c_s2 > 1 then
            sl.save(snapwork)
            select.segs(false, seg)
            do_.freeze("s")
            fuze.start(snapwork)
            do_.unfreeze()
            work.flow("wa")
            sl.save(snapwork)
            if c_snap < debug.score() then
                c_snap = debug.score()
            end
            end
        end
        sl.load(snapwork)
        sl.release(snapwork)
        if cs < c_snap then
            sl.save(snaps)
            c_snap = debug.score()
        else
            sl.load(snaps)
        end
    else
        p("Skipping...")
    end
    snapping = false
    sl.release(snaps)
    if mutated then
        s_snap = debug.score()
        if s_mut < s_snap then
            sl.save(overall)
        else
            sl.load(sl_mut)
        end
    else
        sl.save(overall)
    end
end
--Snapping#

--#Rebuilding
function rebuild()
    local iter = 1
    rebuilding = true
    sl_re = sl.request()
    sl.load(overall)
    select.segs()
    replace_ss("L")
    sl.save(overall)
    sl.save(sl_re)
    select.segs(false, seg, r)
    if r == seg then
        p("Rebuilding Segment ", seg)
    else -- if r
        p("Rebuilding Segment ", seg, "-", r)
    end -- if r
    rs_0 = debug.score()
    work.rebuild(i_max_rebuilds, i_rebuild_str)
    set.cl(1)
    rs_1 = debug.score()
    p(rs_1 - rs_0)
    fuze.start(sl_re)
    rs_2 = debug.score()
    sl.release(sl_re)
    get.increase(rs_0, rs_2, overall)
    rebuilding = false
end -- function
--Rebuilding#

--#Pull
function dists()
    sl.save(overall)
    dist_score = debug.score()
    if b_comp then
        band.delete()
        bonding.maxdist()
        work.dist()
    end -- if b_comp
    band.delete()
    if b_pp_pre_strong then
        bonding.matrix.strong()
        work.dist()
        band.delete()
    end -- if b_pp_predicted
    if b_pp_pre_local then
        for i = 1, numsegs do
            bonding.matrix.one(i)
            work.dist()
            band.delete()
        end
    end -- if b_pp_predicted
    if b_pp_pull then
        bonding.pull(false, i_pp_bandperc)
        work.dist()
        band.delete()
    end -- if b_pp_pull
    if b_pp_push then
        bonding.push(false, i_pp_bandperc * 2, 2)
        work.dist()
        band.delete()
    end -- if b_pp_push
    if b_pp_centerpull then
        bonding.centerpull(false)
        work.dist()
        band.delete()
    end -- if b_pp_centerpull
    if b_pp_centerpush then
        bonding.centerpush(false, 2)
        work.dist()
        band.delete()
    end -- if b_pp_centerpull
end -- function
--Pull#

--#Predict ss
local function _getdata()
    local p_he = {}
    local p_sh = {}
    local p_lo = {}
    local helix
    local sheet
    local loop
    local i = 1
    local ui
    while i < numsegs do
        ui = i
        loop = false
        if hydro[i] then
            if hydro[i + 1] and not hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                if not helix and aa[i] ~= "p" then
                    helix = true
                    p_he[#p_he + 1] = {}
                end -- if helix
            elseif not hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] then
                if not sheet then
                    sheet = true
                    p_sh[#p_sh + 1] = {}
                end -- if sheet
            else -- hydro i +
                loop = true
            end -- hydro i +
        elseif not hydro[i] then
            if hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and hydro[i + 2] and hydro[i + 3] then
                if not helix and aa[i] ~= "p" then
                    helix = true
                    p_he[#p_he + 1] = {}
                end -- if helix
            elseif hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                if not sheet then
                    sheet = true
                    p_sh[#p_sh + 1] = {}
                end -- if sheet
            else -- if hydro +
                loop = true
            end -- if hydro +
        end -- hydro[i]
        if helix then
            p_he[#p_he][#p_he[#p_he] + 1] = i
            if loop or sheet then
                helix = false
                if i + 1 < numsegs then
                    if aa[i + 1] ~= "p" then
                        p_he[#p_he][#p_he[#p_he] + 1] = i + 1
                        if i + 2 < numsegs then
                            if aa[i + 2] then
                                p_he[#p_he][#p_he[#p_he] + 1] = i + 2
                            end -- if aa i + 2
                        end -- if i + 2
                        i = i + 1
                    end -- if aa i + 1
                end -- if i + 1
                ui = i
                i = i + 1
            end -- if loop | sheet
        elseif sheet then
            p_sh[#p_sh][#p_sh[#p_sh] + 1] = i
            if loop then
                sheet = false
                if i + 1 < numsegs then
                    p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 1
                end -- if i + 1
                if i + 2 < numsegs then
                    p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 2
                end -- if i + 2
                ui = i + 2
                i = i + 3
            end -- if loop
        end -- if sheet
        if b_predict_full then
            i = ui + 1
        else -- if b_predict_full
            i = i + 1
        end -- if b_predict_full    
    end -- while
    p("Found ", #p_he, " Helix and ", #p_sh, " Sheet parts... Combining...")
    select.segs()
    set.ss("L")
    deselect.all()
    for i = 1, #p_he do
        select.list(p_he[i])
    end -- for
    set.ss("H")
    deselect.all()
    for i = 1, #p_sh do
        select.list(p_sh[i])
    end -- for
    set.ss("E")
    for i = 1, 3 do
        predict.combine()
    end -- for
    sl.save(overall)
end

local function _combine()
    check.struct()
    for i = 1, numsegs do
        if ss[i] == "L" then
            if aa[i] ~= "p" then
                for ii = 1, #he - 1 do
                    for iii = he[ii][1], he[ii][#he[ii]] do
                        if iii + 1 == i and he[ii + 1][1] == i + 1 then
                            deselect.all()
                            select.index(i)
                            set.ss("H")
                        end -- if iii
                    end -- for iii
                end -- for ii
            end -- if aa
            for ii = 1, #sh - 1 do
                for iii = sh[ii][1], sh[ii][#sh[ii]] do
                    if iii + 1 == i and sh[ii + 1][1] == i + 1 then
                        deselect.all()
                        select.index(i)
                        set.ss("E")
                    end -- if iii
                end -- for iii
            end -- for ii
        end -- if ss
    end -- for i
end

predict =
{   getdata = _getdata,
    combine = _combine
}
--predictss#

function struct_rebuild()
    local str_rs
    local str_rs2
    str_re_best = sl.request()
    check.struct()
    p("Found ", #he, " Helixes ", #sh, " Sheets and ", #lo, " Loops")
    local iter = 1
    if b_re_he then
        for i = 1, #sh do
            deselect.all()
            select.list(sh[i])
            set.ss("L")
        end -- for i
        for i = 1, #he do
            p("Working on Helix ", i)
            deselect.all()
            seg = he[i][1] - 2
            if seg < 1 then
                seg = 1
            end -- if seg
            r = he[i][#he[i]] + 2
            if r > numsegs then
                r = numsegs
            end -- if r
            bonding.helix()
            deselect.all()
            select.range(seg, r)
            set.cl(0.4)
            wiggle.backbone(1)
            set.cl(0)
            work.rebuild(i_str_re_max_re, i_str_re_re_str)
            set.cl(1)
            work.rebuild(i_str_re_max_re, i_str_re_re_str)
            seg = he[i][1] - 2
            if seg < 1 then
                seg = 1
            end -- if seg
            r = he[i][#he[i]] + 2
            if r > numsegs then
                r = numsegs
            end -- if r
            band.delete()
            if b_str_re_fuze then
                rebuilding = true
                fuze.start(str_re_best)
                sl.load(str_re_best)
                rebuilding = false
            end -- if b_str_re_fuze
            str_sc = nil
            str_rs = nil
        end -- for i
        for i = 1, #sh do
            deselect.all()
            select.list(sh[i])
            set.ss("E")
        end -- for i
    end -- if b_re_he
    if b_re_sh then
        for i = 1, #he do
            deselect.all()
            select.list(he[i])
            set.ss("L")
        end -- for i
        for i = 1, #sh do
            p("Working on Sheet ", i)
            seg = sh[i][1] - 2
            if seg < 1 then
                seg = 1
            end -- if seg
            r = sh[i][#sh[i]] + 2
            if r > numsegs then
                r = numsegs
            end -- if r
            bonding.sheet()
            deselect.all()
            select.range(seg, r)
            set.cl(0.4)
            wiggle.backbone(1)
            set.cl(0)
            work.rebuild(i_str_re_max_re, i_str_re_re_str)
            set.cl(1)
            work.rebuild(i_str_re_max_re, i_str_re_re_str)
            band.delete()
            if b_str_re_fuze then
                rebuilding = true
                fuze.start(str_re_best)
                sl.load(str_re_best)
                rebuilding = false
            end -- if b_str_re_fuze
        end -- for i
        for i = 1, #he do
            deselect.all()
            select.list(he[i])
            set.ss("H")
        end -- for i
    end -- if b_re_sh
    sl.save(overall)
end

s_0 = debug.score()
p("v", Version)
p("Starting Score: ", s_0)
overall = sl.request()
sl.save(overall)
check.aacid()
check.ligand()
check.hydro()
if b_predict then
    predict.getdata()
end -- if b_predict
if b_str_re then
    struct_rebuild()
end -- if b_str_re
if b_pp then
    for i = 1, i_pp_trys do
        if b_pp_pre_strong or b_pp_pre_local then
            calc.run()
        end
        dists()
    end -- for i
end -- if b_pp
for i = i_start_seg, i_end_seg do
    seg = i
    if b_snap then
        snap()
    end
    for ii = i_start_walk, i_end_walk do
        r = i + ii
        if r > numsegs then
            r = numsegs
            break
        end -- if r
        if b_rebuild then
            --[[if b_worst_rebuild then         NEW FUNCTION FOR WORST SEGMENT DETECT
                local worst = 1000
                for iii = 1, numsegs do
                    local s = get.seg_score(iii)
                    if s < worst then
                        seg = iii
                        worst = s
                    end -- if s
                end
                r = seg + ii
            end]]
            rebuild()
        end -- if b_rebuild
        if b_lws then
            p(seg, "-", r)
            work.flow("wl")
            if sc_changed then
                work.flow("wb")
                work.flow("ws")
                work.flow("wa")
                work.flow("s")
                sc_changed = false
            end -- if sc_changed
        end -- if b_lws
    end -- for ii
end -- for i
if b_fuze then
    fuze.start(overall)
end -- if b_fuze
sl.load(overall)
sl.release(overall)
s_1 = debug.score()
p("+++ Overall gain +++")
p("+++", s_1 - s_0, "+++")