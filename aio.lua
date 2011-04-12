--[[#Header
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks and Credits for external functions goes to Rav3n_pl, Tlaloc and Gary Forbis
Special thanks goes also to Seagat2011
see http://www.github.com/Darkknight900/foldit/ for latest version of this script
]]

--#Game vars
Version     = "1066"
Release     = true          -- if true this script is relatively safe ;)
numsegs     = get_segment_count()
--Game vars#

--#Settings: Rebuilding Walker
--#Working                  default     description
i_maxiter       = 5         -- 5        max. iterations an action will do | use higher number for a better gain but script needs a longer time
i_start_seg     = 1         -- 1        the first segment to work with
i_end_seg       = numsegs   -- numsegs  the last segment to work with
i_start_walk    = 0         -- 0        with how many segs shall we work - Walker
i_end_walk      = 3         -- 3        starting at the current seg + i_start_walk to seg + i_end_walk
b_lws           = false     -- false    do local wiggle and rewiggle
b_rebuild       = false     -- false    rebuild | see #Rebuilding
--[[v=v=v=v=v=NO=WALKING=HERE=v=v=v=v=v=v]]--
b_pp            = false     -- false    pull hydrophobic sideshains in different modes together then fuze | see #Pull
b_fuze          = false     -- false    should we fuze | see #Fuzing
-- TEMP
b_explore       = false     -- false    Exploration Puzzle
--Working#

--#Scoring | adjust a lower value to get the lws script working on high evo- / solos, higher values are probably better rebuilding the protein
i_score_step    = 0.01     -- 0.001    an action tries to get this score, then it will repeat itself
i_score_gain    = 0.01     -- 0.002    Score will get applied after the score changed this value
--Scoring#

--#Pull
b_comp          = false     -- false    try a pull of the two segments which have the biggest distance in between
i_pp_trys       = 2         -- 2        how often should the pull start over?
i_pp_loss       = 0.05
--Pull#

--#Fuzing
b_f_deep        = false     -- false    fuze till no gain is possible
--Fuzing#

--#Rebuilding
b_worst_rebuild = false     -- false    rebuild worst scored parts of the protein
i_max_rebuilds  = 2         -- 2        max rebuilds till best rebuild will be chosen 
i_rebuild_str   = 1         -- 1        the iterations a rebuild will do at default, automatically increased if no change in score
b_r_dist        = false     -- false    start pull see #Pull after a rebuild
--Rebuilding#


--Settings#

--#Constants
saveSlots       = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
fuzing          = false
rebuilding      = false
sc_changed      = true
--Constants#

--#Securing for changes that will be made at Fold.it
assert          = nil
error           = nil
debug           = nil
math            = nil
--Securing#

--#Optimizing
p               = print
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
        for i = 1, numsegs do
            s = s + get_segment_score(i)
        end -- for
    else -- if
        s = get_score(true)
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
amino_part      = { short = 0, abbrev = 1, longname = 2, hydro = 3, scale = 4, pref = 5, mol = 6, pl = 7}
amino_table     = {
                  -- short, {abbrev,longname,           hydro,      scale,  pref,   mol,        pl      }
                    ['a'] = {'Ala', 'Alanine',          'phobic',   -1.6,   'H',    89.09404,   6.01    },
                    ['c'] = {'Cys', 'Cysteine',         'phobic',   -17,    'E',    121.15404,  5.05    },
                    ['d'] = {'Asp', 'Aspartic acid',    'philic',   6.7,    'L',    133.10384,  2.85    },
                    ['e'] = {'Glu', 'Glutamic acid',    'philic',   8.1,    'H',    147.13074,  3.15    },
                    ['f'] = {'Phe', 'Phenylalanine',    'phobic',   -6.3,   'E',    165.19184,  5.49    },
                    ['g'] = {'Gly', 'Glycine',          'phobic',   1.7,    'L',    75.06714,   6.06    },
                    ['h'] = {'His', 'Histidine',        'philic',   -5.6,   nil,    155.15634,  7.60    },
                    ['i'] = {'Ile', 'Isoleucine',       'phobic',   -2.4,   'E',    131.17464,  6.05    },
                    ['k'] = {'Lys', 'Lysine',           'philic',   6.5,    'H',    146.18934,  9.60    },
                    ['l'] = {'Leu', 'Leucine',          'phobic',   1,      'H',    131.17464,  6.01    },
                    ['m'] = {'Met', 'Methionine',       'phobic',   3.4,    'H',    149.20784,  5.74    },
                    ['n'] = {'Asn', 'Asparagine',       'philic',   8.9,    'L',    132.11904,  5.41    },
                    ['p'] = {'Pro', 'Proline',          'phobic',   -0.2,   'L',    115.13194,  6.30    },
                    ['q'] = {'Gln', 'Glutamine',        'philic',   9.7,    'H',    146.14594,  5.65    },
                    ['r'] = {'Arg', 'Arginine',         'philic',   9.8,    'H',    174.20274,  10.76   },
                    ['s'] = {'Ser', 'Serine',           'philic',   3.7,    'L',    105.09344,  5.68    },
                    ['t'] = {'Thr', 'Threonine',        'philic',   2.7,    'E',    119.12034,  5.60    },
                    ['v'] = {'Val', 'Valine',           'phobic',   -2.9,   'E',    117.14784,  6.00    },
                    ['w'] = {'Trp', 'Tryptophan',       'phobic',   -9.1,   'E',    204.22844,  5.89    },
                    ['y'] = {'Tyr', 'Tyrosine',         'phobic',   -5.1,   'E',    181.19124,  5.64    },
              --[[  ['b'] = {'Asx', 'Asparagine or Aspartic acid'},
                    ['j'] = {'Xle', 'Leucine or Isoleucine'},
                    ['o'] = {'Pyl', 'Pyrrolysine'},
                    ['u'] = {'Sec', 'Selenocysteine'},
                    ['x'] = {'Xaa', 'Unspecified or unknown amino acid'},
                    ['z'] = {'Glx', 'Glutamine or glutamic acid'}
                ]]}
--

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

amino =
{   short       = _short,
    abbrev      = _abbrev,
    longname    = _long,
    hydro       = _h,
    hydroscale  = _hscale,
    preffered   = _pref,
    size        = _mol,
    charge      = _pl
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

calc =
{   hci = _HCI,
    sci = _SCI,
    cci = _CCI
}

function calculate()
    p("Calculating Scoring Matrix")
    hci_table = {}
    cci_table = {}
    sci_table = {}
    _end = #amino_segs
    for i = 1, #amino_segs do
        percentage(i)
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
    _end = numsegs
    for i = 1, numsegs do
        percentage(i)
        strength[i] = {}
        for ii = i + 2, numsegs - 2 do
            strength[i][ii] = (hci_table[aa[i]][aa[ii]] * 2) + (cci_table[aa[i]][aa[ii]] * 1.26 * 1.065) + (sci_table[aa[i]][aa[ii]] * 2)
        end  -- for ii
    end -- for i
end -- function
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
    else
        n = 1
    end
    return value - (value % n)
end -- function

local function _randomseed(x)
    lngX = x
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
        end -- n < m
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
            distances[i][j] = get_segment_distance(i, j)
        end -- for j
    end -- for i
end

local function _sphere(seg, radius)
    sphere = {}
    for i = 1, numsegs do
        if get_segment_distance(seg, i) <= radius then
            sphere[#sphere + 1] = i
        end -- if get_
    end -- for i
    return sphere
end -- function

local function _center() -- by Rav3n_pl based on Tlaloc`s
    local minDistance = 100000.0
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

get =
{   dists   = _dists,
    sphere  = _sphere,
    center  = _center
}
--Getters#

--#Saveslot manager
local function _release(slot)
    saveSlots[#saveSlots + 1] = slot
end -- function

local function _request()
    debug.assert(#saveSlots > 0, "Out of save slots")
    local saveSlot = saveSlots[#saveSlots]
    saveSlots[#saveSlots] = nil
    return saveSlot
end -- function

sl =
{   release = _release,
    request = _request
}
--Saveslot manager#
--External functions#

--#Internal functions
--#Checks
--#Hydrocheck
local function _hydro()
    hydro = {}
    for i = 1, numsegs do
        hydro[i] = is_hydrophobic(i)
    end -- for i
end -- function
--Hydrocheck#

--#Ligand Check
local function _ligand()
    if get_ss(numsegs) == 'M' then
        numsegs = numsegs - 1
    end -- if get_ss
end -- function
--Ligand Check#

--#Structurecheck
--#Getting SS
local function _ss()
    ss = {}
    for i = 1, numsegs do
        ss[i] = get_ss(i)
    end -- for i
end -- function
--Getting SS#

--#Getting AA
local function _aa()
    aa = {}
    for i = 1, numsegs do
        aa[i] = get_aa(i)
    end -- for i
end -- function
--Getting AA#

local function _struct()
    check.ss()
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
{   sstruct = _ss,
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
    if option == 3 then
        p("Pink Fuse cl1-s-cl2-wa")
        work.step("s", 1, cl1)
        work.step("wa", 1, cl2)
    elseif option == 4 then
        p("Pink Fuse cl1-wa-cl=1-wa-cl2-wa")
        work.step("wa", 1, cl1)
        work.step("wa", 1, 1)
        work.step("wa", 1, cl2)
    elseif option == 2 then
        p("Blue Fuse cl1-s; cl2-s;")
        work.step("s", 1, cl1)
        work.gain("wa", 1)
        local bf1 = get_score()
        reset_recent_best()
        work.step("s", 1, cl2)
        work.gain("wa", 1)
        local bf2 = get_score()
        if bf2 < bf1 then
            restore_recent_best()
        end -- if
        reset_recent_best()
        bf1 = get_score()
        work.step("s", 1, cl1 - 0.02)
        work.gain("wa", 1)
        bf2 = get_score()
        if bf2 < bf1 then
            restore_recent_best()
        end -- if
    elseif option == 5 then
        p("cl1-wa[-cl2-wa]")
        work.step("wa", 1, cl1)
    elseif option == 1 then
        local qs1 = get_score()
        reset_recent_best()
        p("qStab cl1-s-cl2-wa-cl=1-s")
        work.step("s", 1, cl1)
        work.step("wa", 1, cl2)
        work.step("s", 1, 1)
        work.gain("wa", 1)
        local qs2 = get_score()
        if qs2 < qs1 then
            restore_recent_best()
        else -- if
            fuze.loss(1, cl1, cl2)
        end -- if
    end -- if option
end -- function

local function _part(option, cl1, cl2)
    local s1_f = debug.score()
    fuze.loss(option, cl1, cl2)
    if option ~= 2 or option ~= 1 then
        work.gain("wa", 1)
    end -- if
    local s2_f = debug.score()
    if s2_f > s1_f then
        quicksave(sl_f1)
        p("+", s2_f - s1_f, "+")
    end -- if
    quickload(sl_f1)
end -- function

local function _start(slot)
    fuzing = true
    select_all()
    sl_f1 = sl.request()
    c_s = get_score(true)
    quicksave(sl_f1)
    fuze.part(1, 0.1, 0.4)
    fuze.part(2, 0.05, 0.07)
    fuze.part(3, 0.1, 0.7)
    fuze.part(3, 0.3, 0.6)
    fuze.part(4, 0.5, 0.7)
    fuze.part(4, 0.7, 0.5)
    fuze.part(5, 0.3)
    quickload(sl_f1)
    s_f = debug.score()
    sl.release(sl_f1)
    fuzing = false
    if s_f > c_s then
        quicksave(slot)
        s_fg = s_f - c_s
        p("+", s_fg, "+")
        c_s = s_f
        p("++", c_s, "++")
        if b_f_deep and s_fg > i_score_gain then
            fuze.again(slot)
        end -- if deep
    else -- if s_f
        quickload(slot)
    end -- if s_f
end -- function

local function _again(slot)
    fuze.start(slot)
end -- function

fuze =
{   loss    =   _loss,
    part    =   _part,
    start   =   _start,
    again   =   _again
}
--Fuzing#

--#Universal select
local function _segs(sphered, start, _end, more)
    if not more then
        deselect_all()
    end -- if more
    if start then
        if sphered then
            if start ~= _end then
                local list1 = get.sphere(_end, 14)
                select.list(list1)
            end -- if ~= end
            local list1 = get.sphere(start, 14)
            select.list(list1)
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end -- if > end
            select_index_range(start, _end)
        elseif start ~= _end then
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end -- if > end
            select_index_range(start, _end)
        else -- if sphered
            select_index(start)
        end -- if sphered
    else -- if start
        select_all()
    end -- if start
end -- function

local function _list(list)
    if list then
        for i = 1, #list do
            select_index(list[i])
        end -- for
    end -- if list
end -- function

select =
{   segs    = _segs,
    list    = _list
}
--Universal select#

--#Freeze functions
function freeze(f)
    if not f then
        do_freeze(true, true)
    elseif f == "b" then
        do_freeze(true, false)
    elseif f == "s" then
        do_freeze(false, true)
    end -- if
end -- function
--Freeze functions#

--#Scoring
function score(g, slot)
    local more = s1 - c_s
    if more > i_score_gain then
        p("+", more, "+")
        p("++", s1, "++")
        c_s = s1
        quicksave(slot)
    else -- if
        quickload(slot)
    end -- if
end -- function
--Scoring#

--#working
local function _gain(g, cl)
    local iter
    repeat
        iter = 0
        repeat
            iter = iter + 1
            local s1_f = debug.score()
            if iter < i_maxiter then
                work.step(g, iter, cl)
            end -- if
            local s2_f = debug.score()
        until s2_f - s1_f < i_score_step
        local s3_f = debug.score()
        work.step("s")
        local s4_f = debug.score()
    until s4_f - s3_f < i_score_step
end

local function _step(_g, iter, cl)
    if cl then
        set_behavior_clash_importance(cl)
    end -- if
    if rebuilding and _g == "s" then
        select.segs(true, seg, r)
    else -- if rebuilding
        select.segs()
    end -- if rebuilding
    if _g == "wa" then
        do_global_wiggle_all(iter)
    elseif _g == "s" then
        do_shake(1)
    elseif _g == "wb" then
        do_global_wiggle_backbone(iter)
    elseif _g == "ws" then
        do_global_wiggle_sidechains(iter)
    elseif _g == "wl" then
        select.segs(false, seg, r)
        wl = sl.request()
        quicksave(wl)
        for i = iter, iter + 5 do
            local s_s1 = debug.score()
            do_local_wiggle(iter)
            local s_s2 = debug.score()
            if s_s2 > s_s1 then
                quicksave(wl)
            else -- if >
                quickload(wl)
            end -- if >
            if s_s2 == s_s1 then
                break
            end -- if ==
        end -- for
        sl.release(wl)
    end -- if _g
end -- function

local function _flow(g)
    local iter = 0
    if rebuilding then
        slot = sl_re
    else -- if
        slot = overall
    end -- if
    work_sl = sl.request()
    repeat
        iter = iter + 1
        if iter ~= 1 then
            quicksave(work_sl)
        end -- if iter
        s1 = debug.score()
        if iter < i_maxiter then
            work.step(g, iter)
        end -- <
        s2 = debug.score()
    until s2 - s1 < (i_score_step * iter)
    if s2 < s1 then
        quickload(work_sl)
    else -- if <
        s1 = s2
    end -- if <
    sl.release(work_sl)
    deselect_all()
    score(g, slot)
end -- function

function _quake()
    local s3 = get_score(true) / 100 * i_pp_loss
    local strength = 0.05
    reset_recent_best()
    select_all()
    local bands = get_band_count()
    repeat
        strength = strength * 2 - strength * 9 / 10
        p("Band strength: ", strength)
        restore_recent_best()
        local s1 = get_score(true)
        for i = 1, bands do
            band_set_strength(i, strength)
        end -- for
        do_global_wiggle_backbone(1)
        local s2 = get_score(true)
        if s2 > s1 then
            reset_recent_best()
            s1 = get_score(true)
        end -- if >
    until s1 - s2 > s3
    quicksave(pp)
end -- function

work =
{   gain    = _gain,
    step    = _step,
    flow    = _flow,
    quake   = _quake
}
--Working#

function percentage(i)
    p(i / _end * 100, "%")
end

--#Bonding
--#Center
local function _cp(locally)
    local indexCenter = get.center()
    local start
    local _end
    if locally then
        start = seg
        _end = r
    else
        start = i_start_seg
        _end = i_end_seg
    end
    for i = start, _end do
        if i ~= indexCenter then
            if hydro[i] then
                band_add_segment_segment(i, indexCenter)
            end
        end
    end
end
--Center#

--#Pull
local function _p(locally, bandsp)
    if locally then
        start = seg
        _end = r
    else
        start = i_start_seg
        _end = i_end_seg
    end
    get.dists()
    for x = start, _end - 2 do
        if hydro[x] then
            for y = x + 2, numsegs do
                math.randomseed(distances[x][y])
                if hydro[y] and math.random() < bandsp then
                    maxdistance = distances[x][y]
                    band_add_segment_segment(x, y)
                repeat
                    maxdistance = maxdistance * 3 / 4
                until maxdistance <= 20
                local band = get_band_count()
                --band_set_strength(band, maxdistance / 15)
                band_set_length(band, maxdistance)
                end
            end
        end
    end
end
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
                end
                if distances[x][y] > maxdistance then
                    maxdistance = distances[x][y]
                    maxx = i
                    maxy = j
                end
            end
        end
    end
    band_add_segment_segment(maxx, maxy)
    repeat
        maxdistance = maxdistance * 3 / 4
    until maxdistance <= 20
    --band_set_strength(get_band_count(), maxdistance / 15)
    band_set_length(get_band_count(), maxdistance)
end
--BandMaxDist#

bonding =
{   centerpull  = _cp,
    pull        = _p,
    maxdist     = _maxdist
}
--Bonding#
--Header#

--#Rebuilding
function rebuild()
    local iter = 1
    rebuilding = true
    sl_re = sl.request()
    quickload(overall)
    quicksave(sl_re)
    select.segs(false, seg, r)
    if r == seg then
        p("Rebuilding Segment ", seg)
    else
        p("Rebuilding Segment ", seg, "-", r)
    end
    cs0 = debug.score()
    for i = 1, i_max_rebuilds do
        p("Try ", i, "/", i_max_rebuilds)
        cs_0 = debug.score()
        set_behavior_clash_importance(0.01)
        while debug.score() == cs_0 do
            do_local_rebuild(iter * i_rebuild_str)
            iter = iter + 1
            if iter > i_maxiter then
                iter = i_maxiter
            end
        end
        iter = 1
        str_rs = debug.score()
        if cs_0 < str_rs then
            cs_0 = str_rs - math.abs(str_rs)/2
            quicksave(sl_re)
        end
    end
    quickload(sl_re)
    set_behavior_clash_importance(1)
    p(debug.score() - cs0)
    c_s = debug.score()
    if b_r_dist then
        dists()
    end
    fuze.start(sl_re)
    quickload(sl_re)
    p("+", c_s - cs0, "+")
    sl.release(sl_re)
    if c_s < cs0 then
        quickload(overall)
    else
        quicksave(overall)
    end
    rebuilding = false
end
--Rebuilding#

--#Pull
function dists()
    pp = sl.request()
    s_dist = get_score()
    if b_comp then
        bonding.maxdist()
        select_all()
        work.quake()
        band_delete()
        fuze.start(pp)
        if get_score() < s_dist then
            quickload(overall)
        end
    end
    bonding.pull(false, 0.02)
    select_all()
    work.quake()
    band_delete()
    fuze.start(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
    bonding.centerpull()
    select_all()
    work.quake()
    band_delete()
    fuze.start(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
end
--Pull#

function all()
    p("v", Version)
    if b_pp then
        for i = 1, i_pp_trys do
            dists()
        end
    end
    for i = i_start_seg, i_end_seg do
        seg = i
        c_s = debug.score()
        for ii = i_start_walk, i_end_walk do
            r = i + ii
            if r > numsegs then
                r = numsegs
                break
            end
            if b_rebuild then
                if b_worst_rebuild then
                    local worst = 1000
                    for iii = 1, numsegs do
                        local s = get_segment_score(iii)
                        if s < worst then
                            seg = iii
                            worst = s
                        end
                    end
                    r = seg + ii
                end
                rebuild()
            end
            if b_lws then
                p(seg, "-", r)
                work.flow("wl")
                if sc_changed then
                    work.flow("wb")
                    work.flow("ws")
                    work.flow("wa")
                    work.flow("s")
                    sc_changed = false
                end
            end
        end
    end
    if b_fuze then
        fuze.start(overall)
    end
end


s_0 = debug.score()
c_s = s_0
check.aacid()
check.ligand()
check.hydro()
p("Starting Score: ", c_s)
overall = sl.request()
quicksave(overall)
all()
quickload(overall)
sl.release(overall)
s_1 = debug.score()
p("+++ Overall gain +++")
p("+++", s_1 - s_0, "+++")