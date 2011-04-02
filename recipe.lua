--[[
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
Thanks goes to Rav3n_pl, Tlaloc
Special Thanks goes to Gary Forbis for the great description of his Cookbookwork ;)
]]

--#Game vars
Version     = "2.9.1.1045"
numsegs     = get_segment_count()
--Game vars#

--#Settings: default
--#Working                  default     description
maxiter         = 20         -- 5        max. iterations an action will do
start_seg       = 1         -- 1        the first segment to work with
end_seg         = numsegs   -- numsegs  the last segment to work with
start_walk      = 0         -- 0        with how many segs shall we work - Walker
end_walk        = 6         -- 3        starting at the current seg + start_walk to seg + end_walk
b_lws           = true      -- true     do local wiggle and rewiggle
b_fast_lws      = false     -- false    an faster alternative which just local wiggle without trying different wiggles
b_pp            = false     -- false    push and pull of hydrophilic / -phobic in different modes then fuze see #Pull
b_rebuild       = false     -- false    rebuild see #Rebuilding
b_predict_ss    = false     -- false    predicting a new structure with some easy methods
b_str_re        = false     -- false    working based on structure (Implemented Helix only for now)
b_mutate        = false     -- false    it's a mutating puzzle so we should mutate to get the best out of every single option see #Mutating
b_snap          = false     -- false    should we snap every sidechain to different positions
b_fuze          = true      -- true     should we fuze
--Working#

--#Pull
b_comp          = false     -- false
i_pp_trys       = 2         -- 2
--Pull#

--#Scoring
step            = 0.0001      -- 0.01     an action tries to get this score, then it will repeat itself
gain            = 0.0001      -- 0.02     Score will get applied after the score changed this value
--Scoring#

--#Fuzing
b_f_deep        = false     -- false
--Fuzing#

--#Mutating
b_m_new         = false     -- false    Will change _ALL_ mutatable, then wiggles out and then mutate again, could get some points for solo, at high evos it's not recommend
b_m_fuze        = true      -- true     fuze a change or just wiggling out (could get some more points but recipe needs longer)
--Mutating#

--#Snapping
--Snapping#

--#Rebuilding
max_rebuilds    = 2         -- 2
rebuild_str     = 1         -- 1
b_r_dist        = false     -- false
--Rebuilding#

--#Structed rebuilding
i_str_re_max_re = 2         -- 2
i_str_re_re_str = 2         -- 2
b_str_re_dist   = false     -- false
--Structed rebuilding#
--Settings#

--#Constants
saveSlots       = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
amino           = {
                 -- {seg, short, longname,          hydro,      -scale, pref,   mol,        pl      }
                    {'a', 'Ala', 'Alanine',         "phobic",   -1.6,   "H",    89.09404,   6.01    },
                    {'c', 'Cys', 'Cysteine',        "phobic",   -17,    "E",    121.15404,  5.05    },
                    {'d', 'Asp', 'Aspartic acid',   "philic",   6.7,    "L",    133.10384,  2.85    },
                    {'e', 'Glu', 'Glutamic acid',   "philic",   8.1,    "H",    147.13074,  3.15    },
                    {'f', 'Phe', 'Phenylalanine',   "phobic",   -6.3,   "E",    165.19184,  5.49    },
                    {'g', 'Gly', 'Glycine',         "phobic",   1.7,    "L",    75.06714,   6.06    },
                    {'h', 'His', 'Histidine',       "philic",   -5.6,   "L",    155.15634,  7.60    },
                    {'i', 'Ile', 'Isoleucine',      "phobic",   -2.4,   "E",    131.17464,  6.05    },
                    {'k', 'Lys', 'Lysine',          "philic",   6.5,    "H",    146.18934,  9.60    },
                    {'l', 'Leu', 'Leucine',         "phobic",   1,      "H",    131.17464,  6.01    },
                    {'m', 'Met', 'Methionine',      "phobic",   3.4,    "H",    149.20784,  5.74    },
                    {'n', 'Asn', 'Asparagine',      "philic",   8.9,    "L",    132.11904,  5.41    },
                    {'p', 'Pro', 'Proline',         "phobic",   -0.2,   "L",    115.13194,  6.30    },
                    {'q', 'Gln', 'Glutamine',       "philic",   9.7,    "H",    146.14594,  5.65    },
                    {'r', 'Arg', 'Arginine',        "philic",   9.8,    "H",    174.20274,  10.76   },
                    {'s', 'Ser', 'Serine',          "philic",   3.7,    "L",    105.09344,  5.68    },
                    {'t', 'Thr', 'Threonine',       "philic",   2.7,    "E",    119.12034,  5.60    },
                    {'v', 'Val', 'Valine',          "phobic",   -2.9,   "E",    117.14784,  6.00    },
                    {'w', 'Trp', 'Tryptophan',      "phobic",   -9.1,   "E",    204.22844,  5.89    },
                    {'y', 'Tyr', 'Tyrosine',        "phobic",   -5.1,   "E",    181.19124,  5.64    },
              --[[  {'b', 'Asx', 'Asparagine or Aspartic acid'},
                    {'j', 'Xle', 'Leucine or Isoleucine'},
                    {'o', 'Pyl', 'Pyrrolysine'},
                    {'u', 'Sec', 'Selenocysteine'},
                    {'x', 'Xaa', 'Unspecified or unknown amino acid'},
                    {'z', 'Glx', 'Glutamine or glutamic acid'}
                ]]}
snapping        = false
mutating        = false
rebuilding      = false
fuzing          = false
sc_changed      = true
--Constants#

--#Securing for changes that will be made at Fold.it
assert          = nil
error           = nil
--Securing#

--#Optimizing
p               = print
--Optimizing#

--#Debug
function assert(b, m)
    if not b then
        p(m)
        error()
    end
end
--Debug#

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
end

local function _floor(value)
    return value - (value % 1)
end

local function _randomseed(x)
    lngX = x
end

local function _random(m,n)
    if not n and m then
        n = m
        m = 1
    end
    if not m and not n then
        return _MWC() / 4294967296
    else
        if n < m then
            return nil
        end
        return math.floor((_MWC() / 4294967296) * (n - m + 1)) + m
    end
end

math=
{   floor       = _floor,
    random      = _random,
    randomseed  = _randomseed
}
--Math library#

function GetDistances()
    distances = {}
    for i = 1, numsegs - 1 do
        distances[i] = {}
        for j = i + 1, numsegs do
            distances[i][j] = get_segment_distance(i, j)
        end
    end
end

function GetSphere(seg, radius)
    sphere = {}
    for i = 1, numsegs do
        if get_segment_distance(seg, i) <= radius then
            sphere[#sphere + 1] = i
        end
    end
    return sphere
end

--#Saveslot manager
function ReleaseSaveSlot(slot)
    saveSlots[#saveSlots + 1] = slot
end

function RequestSaveSlot()
    assert(#saveSlots > 0, "Out of save slots")
    local saveSlot = saveSlots[#saveSlots]
    saveSlots[#saveSlots] = nil
    return saveSlot
end
--Saveslot manager#

function FindMutable()
    p("Finding mutable segments -- programm will get stuck a bit")
    local mut = RequestSaveSlot()
    quicksave(mut)
    local mutable = {}
    local isG = {}
    local i
    select_all()
    replace_aa("g")                 -- all mutable segments are set to "g"
    for i = 1, numsegs do
        if get_aa(i) == "g" then    -- find the "g" segments
            isG[#isG + 1] = i
        end
    end
    replace_aa("q")                 -- all mutable segments are set to "q"
    for j = 1, #isG do
        i = isG[j]
        if get_aa(i) == "q" then    -- this segment is mutable
            mutable[#mutable + 1] = i
        end
    end
    p(#mutable, " mutables found")
    quickload(mut)
    ReleaseSaveSlot(mut)
    deselect_all()
    return mutable
end

function FastCenter() --by Rav3n_pl based on Tlaloc`s
    local minDistance = 100000.0
    local distance
    local indexCenter
    GetDistances()
    for i = 1, numsegs do
        distance = 0
        for j = 1, numsegs do
            if i ~= j then
                local x = i
                local y = j
                if x > y then x, y = y, x end
                distance = distance + distances[x][y]
            end
        end
        if(distance < minDistance) then
             minDistance = distance
             indexCenter =  i
        end
    end
    return indexCenter
end
--External functions#

--#Internal functions
--#Hydrocheck
hydro = {}
for i = 1, numsegs do
hydro[i] = is_hydrophobic(i)
end
--Hydrocheck#

--#Ligand Check
if get_ss(numsegs) == 'M' then
    numsegs = numsegs - 1
end
--Ligand Check#

--#Fuzing
function fgain(g, cl)
    local iter
    repeat
        iter = 0
        repeat
            iter = iter + 1
            local s1_f = get_score(true)
            if iter < maxiter then
                work(g, iter, cl)
            end
            local s2_f = get_score(true)
        until s2_f - s1_f < step
        local s3_f = get_score(true)
        work("s")
        local s4_f = get_score(true)
    until s4_f - s3_f < step
end

function floss(option, cl1, cl2)
    p("Fuzing Method ", option)
    p("cl1 ", cl1, ", cl2 ", cl2)
    if option == 3 then
        p("Pink Fuse cl1-s-cl2-wa")
        work("s", 1, cl1)
        work("wa", 1, cl2)
    elseif option == 4 then
        p("Pink Fuse cl1-wa-cl=1-wa-cl2-wa")
        work("wa", 1, cl1)
        work("wa", 1, 1)
        work("wa", 1, cl2)
    elseif option == 2 then
        p("Blue Fuse cl1-s; cl2-s;")
        work("s", 1, cl1)
        fgain("wa", 1)
        local bf1 = get_score()
        reset_recent_best()
        work("s", 1, cl2)
        fgain("wa", 1)
        local bf2 = get_score()
        if bf2 < bf1 then
            restore_recent_best()
        end
        reset_recent_best()
        bf1 = get_score()
        work("s", 1, cl1 - 0.02)
        fgain("wa", 1)
        bf2 = get_score()
        if bf2 < bf1 then
            restore_recent_best()
        end
    elseif option == 5 then
        p("cl1-wa[-cl2-wa]")
        work("wa", 1, cl1)
    elseif option == 1 then
        p("qStab cl1-s-cl2-wa-cl=1-s")
        work("s", 1, cl1)
        work("wa", 1, cl2)
        work("s", 1, 1)
    end
end

function s_fuze(option, cl1, cl2)
    local s1_f = get_score(true)
    floss(option, cl1, cl2)
    if option ~= 2 then
        fgain("wa", 1)
    end
    local s2_f = get_score(true)
    if s2_f > s1_f then
        quicksave(sl_f1)
        p("+", s2_f - s1_f, "+")
    end
    quickload(sl_f1)
end

function fuze(sl)
    fuzing = true
    select_all()
    sl_f1 = RequestSaveSlot()
    quicksave(sl_f1)
    s_fuze(1, 0.1, 0.4)
    s_fuze(2, 0.05, 0.07)
    s_fuze(3, 0.1, 0.7)
    s_fuze(3, 0.3, 0.6)
    s_fuze(4, 0.5, 0.7)
    s_fuze(4, 0.7, 0.5)
    s_fuze(5, 0.3)
    quickload(sl_f1)
    s_f = get_score(true)
    ReleaseSaveSlot(sl_f1)
    if s_f > c_s then
        quicksave(sl)
        s_fg = s_f - c_s
        p("+", s_fg, "+")
        c_s = s_f
        p("++", c_s, "++")
        if b_f_deep and s_fg > gain then
            r_fuze(sl)
        end
    else
        quickload(sl)
    end
    fuzing = false
end

function r_fuze(sl)
    fuze(sl)
end
--Fuzing#

--#CenterBands
function CenterPull(locally)
    local indexCenter = FastCenter()
    local start
    local _end
    if locally then
        start = seg
        _end = r
    else
        start = start_seg
        _end = end_seg
    end
    for i = start, _end do
        if i ~= indexCenter then
            if hydro[i] then
                band_add_segment_segment(i, indexCenter)
            end
        end
    end
end
--CenterBands#

--#Pull
function Pull(locally, bandsp)
    if locally then
        start = seg
        _end = r
    else
        start = start_seg
        _end = end_seg
    end
    GetDistances()
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
                band_set_strength(band, maxdistance / 15)
                band_set_length(band, maxdistance)
                end
            end
        end
    end
end
--Pull#

--#BandMaxDist
function BandMaxDist()
    GetDistances()
    local maxdistance = 0
    for i = start_seg, end_seg do
        for j = start_seg, end_seg do
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
    band_set_strength(get_band_count(), maxdistance / 15)
    band_set_length(get_band_count(), maxdistance)
end
--BandMaxDist#

--#Universal select
function select_segs(sphered, start, _end, more)
    if not more then
        deselect_all()
    end
    if start then
        if sphered then
            if start ~= _end then
                local list1 = GetSphere(_end, 10)
                select_list(list1)
            end
            local list1 = GetSphere(start, 10)
            select_list(list1)
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end
            select_index_range(start, _end)
        elseif start ~= _end then
            if start > _end then
                local _start = _end
                _end = start
                start = _start
            end
            select_index_range(start, _end)
        else
            select_index(start)
        end
    else
        select_all()
    end
end

function select_list(list)
    if list then
        for i = 1, #list do
            select_index(list[i])
        end
    end
end
--Universal select#

--#Freezing functions
function freeze(f) -- f not used yet
    if not f then
        do_freeze(true, true)
    elseif f == "b" then
        do_freeze(true, false)
    elseif f == "s" then
        do_freeze(false, true)
    end
end
--Freezing functions#

--#Scoring
--#Universal scoring
function score(g, sl)
    local more = s1 - c_s
    if more > gain then
        sc_changed = true
        p("+", more, "+")
        p("++", s1, "++")
        c_s = s1
        quicksave(sl)
        if g == "wb" then
            p("Rework after backbone wiggle gain.")
            gd("s")
            gd("ws")
            gd("wa")
            p("Rework after backbone wiggle gain ended.")
        elseif g == "ws" then
            p("Rework after sidechain wiggle gain.")
            gd("s")
            gd("wb")
            gd("wa")
            p("Rework after sidechain wiggle gain ended.")
        elseif g == "wl" then
            p("Rework after local wiggle gain.")
            gd("s")
            gd("wb")
            gd("ws")
            gd("wa")
            gd("wl")
            p("Rework after local wiggle gain ended.")
        end
    else
        quickload(sl)
    end
end
--Universal scoring#
--Scoring#

--#Universal working
function work(_g, iter, cl)
    if cl then
        set_behavior_clash_importance(cl)
    end
    if rebuilding and _g == "s" then
        select_segs(true, seg, r)
    else
        select_segs()
    end
    if _g == "wa" then
        do_global_wiggle_all(iter)
    elseif _g == "s" then
        do_shake(1)
    elseif _g == "wb" then
        do_global_wiggle_backbone(iter)
    elseif _g == "ws" then
        do_global_wiggle_sidechains(iter)
    elseif _g == "wl" then
        select_segs(false, seg, r)
        wl = RequestSaveSlot()
        quicksave(wl)
        if b_fast_lws then
            repeat
                local s_s1 = get_score(true)
                do_local_wiggle(iter)
                local s_s2 = get_score(true)
            until s_s1 > s_s2
        else
            for i = iter, iter + 5 do
                local s_s1 = get_score(true)
                do_local_wiggle(iter)
                local s_s2 = get_score(true)
                if s_s2 - s_s1 > step / 2 * i then
                    quicksave(wl)
                end
                quickload(wl)
                if s_s2 == s_s1 then
                    break
                end
            end
        end
        ReleaseSaveSlot(wl)
    end
end

function gd(g)
    local iter = 0
    if rebuilding then
        sl = sl_re
    elseif snapping then
        sl = snapwork
    else
        sl = overall
    end
    gsl = RequestSaveSlot()
    repeat
        iter = iter + 1
        if iter ~= 1 then
            quicksave(gsl)
        end
        s1 = get_score(true)
        if iter < maxiter then
            work(g, iter)
        end
        s2 = get_score(true)
    until s2 - s1 < (step * iter)
    if s2 < s1 then
        quickload(gsl)
    else
        s1 = s2
    end
    ReleaseSaveSlot(gsl)
    deselect_all()
    score(g, sl)
end
--Working#

--#Snapping
function snap(mutated)         -- TODO: need complete rewrite
    snapping = true
    snaps = RequestSaveSlot()
    c_snap = get_score(true)
    cs = get_score(true)
    quicksave(snaps)
    iii = get_sidechain_snap_count(seg)
    p("Snapcount: ", iii, " - Segment ", seg)
    if iii ~= 1 then
    snapwork = RequestSaveSlot()
        for ii = 1, iii do
            quickload(snaps)
            p("Snap ", ii, "/ ", iii)
            c_s = get_score(true)
            select()
            do_sidechain_snap(seg, ii)
            p(get_score(true) - c_s)
            c_s = get_score(true)
            quicksave(snapwork)
            gd("s")
            gd("wa")
            gd("ws")
            gd("wb")
            gd("wl")
            if c_snap < get_score(true) then
            c_snap = get_score(true)
            end
        end
        quickload(snaps)
        quickload(snapwork)
        ReleaseSaveSlot(snapwork)
        if cs < c_snap then
            quicksave(snaps)
        else
            quickload(snaps)
        end
    else
        p("Skipping...")
    end
    snapping = false
    ReleaseSaveSlot(snaps)
    if mutated then
        s_snap = get_score(true)
        if s_mut < s_snap then
            quicksave(overall)
        else
            quickload(sl_mut)
        end
    else
        quicksave(overall)
    end
end
--Snapping#

--#Rebuilding
function rebuild()
    rebuilding = true
    sl_re = RequestSaveSlot()
    sl_best = RequestSaveSlot()
    quickload(overall)
    quicksave(sl_re)
    select_segs(false, seg, r)
    if r == seg then
        p("Rebuilding Segment ", seg)
    else
        p("Rebuilding Segment ", seg, "-", r)
    end
    for i = 1, max_rebuilds do
        p("Try ", i, "/", max_rebuilds)
        cs_0 = get_score(true)
        set_behavior_clash_importance(0.01)
        do_local_rebuild(rebuild_str * i)
        while get_score(true) == cs_0 do
            do_local_rebuild(rebuild_str * i * iter)
            iter = iter + i
        end
        if re_sc or re_sc < str_rs then
            re_sc = str_rs
            quicksave(sl_re)
        end
    end
    set_behavior_clash_importance(1)
    p(get_score(true) - cs_0)
    c_s = get_score(true)
    quicksave(sl_re)
    if b_mutate then
        mutate()
    end
    if b_r_dist then
        dists()
    end
    if b_r_fuze then
        fuze(sl_re)
    end
    quickload(sl_re)
    if csr and csr < get_score(true) then
        local csr = get_score(true)
        quicksave(sl_best)
    end
    if csr then
        c_s = csr
    end
    quickload(sl_best)
    ReleaseSaveSlot(sl_best)
    p("+", c_s - cs_0, "+")
    ReleaseSaveSlot(sl_re)
    if c_s < cs_0 then
        quickload(overall)
    else
        quicksave(overall)
    end
    rebuilding = false
end
--Rebuilding#

--#Mutate function
function mutate()          -- TODO: Test assert Saveslots
    mutating = true
    if b_mutate then
        if b_m_new then
            select(mutable)
            for i = 1, #amino do
                p("Mutating segment ", seg)
                sl_mut = RequestSaveSlot()
                quicksave(sl_mut)
                replace_aa(amino[i][1])
                fgain("wa")
                repeat
                    repeat
                        local mut_1 = get_score(true)
                        do_mutate(1)
                    until get_score(true) - mut_1 < 0.01
                    mut_1 = get_score(true)
                    fgain("wa")
                until get_score(true) - mut_1 < 0.01
                if get_score(true) > c_s then
                    c_s = get_score(true)
                    quicksave(overall)
                end
                quickload(sl_mut)
                ReleaseSaveSlot(sl_mut)
            end
        end
        b_mutating = false
        for l = 1, #mutable do
            if seg == mutable[l] then
                b_mutating = true
            end
        end
        if b_mutating then
            p("Mutating segment ", seg)
            sl_mut = RequestSaveSlot()
            quicksave(sl_mut)
            for j = 1, #amino do
                if get_aa(seg) ~= amino[j][1] then
                    select()
                    replace_aa(amino[j][1])
                    s_mut = get_score(true)
                    p("Mutated: ", seg, " to ", amino[j][2], " - " , amino[j][3])
                    p(#amino - j, " mutations left...")
                    p(s_mut - c_s)
                    if b_m_fuze then
                        fuze(sl_mut)
                    else
                        set_behavior_clash_importance(0.1)
                        do_shake(1)
                        fgain("wa")
                    end
                    s_mut2 = get_score(true)
                    if s_mut2 > s_mut then
                        p("+", s_mut2 - s_mut, "+")
                    else
                        p(s_mut2 - s_mut)
                    end
                    p("~~~~~~~~~~~~~~~~")
                    if s_mut2 > c_s then
                        c_s = s_mut2
                        quicksave(overall)
                    end
                    quickload(sl_mut)
                    s_mut2 = get_score(true)
                end
            end
            ReleaseSaveSlot(sl_mut)
            quickload(overall)
        end
    end
    mutating = false
end
--Mutate#

--#Pull
function dists()
    pp = RequestSaveSlot()
    quicksave(pp)
    s_dist = get_score()
    if b_comp then
        BandMaxDist()
        select_all()
        set_behavior_clash_importance(0.7)
        do_global_wiggle_backbone(1)
        band_delete()
        fuze(pp)
        if get_score() < s_dist then
            quickload(overall)
        end
    end
    Pull(false, 0.03)
    select_all()
    set_behavior_clash_importance(0.9)
    do_global_wiggle_backbone(1)
    band_delete()
    fuze(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
    Pull(false, 0.02)
    select_all()
    set_behavior_clash_importance(0.9)
    do_global_wiggle_backbone(1)
    band_delete()
    fuze(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
    CenterPull()
    select_all()
    set_behavior_clash_importance(0.8)
    do_global_wiggle_backbone(1)
    band_delete()
    fuze(pp)
    if get_score() < s_dist then
        quickload(overall)
    end
end
--Pull#

--#fast ss
function fast_ss()
    ss = {}
    for i = 1, numsegs do
        ss[i] = get_ss(i)
    end
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
        end
        if helix then
            if ss[i] == "H" then
                he[#he][#he[#he]+1] = i
            else
                helix = false
            end
        end
        if sheet then
            if ss[i] == "E" then
                sh[#sh][#sh[#sh]+1] = i
            else
                sheet = false
            end
        end
        if loop then
            if ss[i] == "L" then
                lo[#lo][#lo[#lo]+1] = i
            else
                loop = false
            end
        end
    end
end
--fastss#

--#predictss
function predict_ss()
    local p_he = {}
    p_sh = {}
    local p_lo = {}
    local helix
    local sheet
    local loop
    local i = 1
    while i < numsegs - 2 do
        loop = false
        if hydro[i] then
            if hydro[i + 1] and not hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                if not helix then
                    helix = true
                    p_he[#p_he + 1] = {}
                end
            elseif not hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] then
                if not sheet then
                    sheet = true
                    p_sh[#p_sh + 1] = {}
                end
            else
                p_lo[#p_lo + 1] = {}
                loop = true
            end
        elseif not hydro[i] then
            if hydro[i + 1] and hydro[i + 2] and not hydro[i + 3] or not hydro[i + 1] and hydro[i + 2] and hydro[i + 3] then
                if not helix then
                    helix = true
                    p_he[#p_he + 1] = {}
                end
            elseif hydro[i + 1] and not hydro[i + 2] and hydro[i + 3] then
                if not sheet then
                    sheet = true
                    p_sh[#p_sh + 1] = {}
                end
            else
                if not sheet and not helix then
                    p_lo[#p_lo + 1] = {}
                end
                loop = true
            end
        end
        if helix then
            p_he[#p_he][#p_he[#p_he] + 1] = i
            if loop or sheet then
                helix = false
                p_he[#p_he][#p_he[#p_he] + 1] = i + 1
                p_he[#p_he][#p_he[#p_he] + 1] = i + 2
                i = i + 2
            end
        elseif sheet then
            p_sh[#p_sh][#p_sh[#p_sh] + 1] = i
            if loop then
                sheet = false
                p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 1
                p_sh[#p_sh][#p_sh[#p_sh] + 1] = i + 2
                i = i + 2
            end
        else
            p_lo[#p_lo][#p_lo[#p_lo] + 1] = i
        end
        i = i + 1
    end
    p("Found ", #p_he, " Helix ", #p_sh, " Sheet and ", #p_lo, " Loop parts... Combining...")
    select_all()
    replace_ss("L")
    deselect_all()
    for i = 1, #p_he do
        for ii = p_he[i][1], p_he[i][#p_he[i]] do
            select_index(ii)
        end
    end
    replace_ss("H")
    quicksave(overall)
end
--predictss#

--#struct rebuild
function struct_rebuild()
    fast_ss()
    p("Found ", #he, " Helixes ", #sh, " Sheets and ", #lo, " Loops")
    local iter = 1
    for i = 1, #he do
        deselect_all()
        str_rs = get_score(true)
        seg = he[i][1] - 3
        if seg - 1 <= 0 then
            seg = he[i][1]
        end
        r = he[i][#he[i]] + 3
        if r > numsegs then
            r = numsegs
        end
        --Save structures and replace with loop for better rebuilding
        local tempss = {}
        for ii = seg, he[i][1] - 1 do
            tempss[#tempss + 1] = get_ss(ii)
        end
        select_index_range(seg, he[i][1] - 1)
        for ii = he[i][#he[i]] + 1, r do
            tempss[#tempss + 1] = get_ss(ii)
        end
        select_index_range(he[i][#he[i]] + 1, r)
        replace_ss("L")
        deselect_all()
        --Saved structures
        for ii = he[i][1], he[i][#he[i]], 4 do
            band_add_segment_segment(ii, ii + 4)
        end
        band_delete(get_band_count())
        for ii = he[i][1] + 1, he[i][#he[i]], 4 do
            band_add_segment_segment(ii, ii + 4)
        end
        band_delete(get_band_count())
        for ii = he[i][1] + 2, he[i][#he[i]], 4 do
            band_add_segment_segment(ii, ii + 4)
        end
        band_delete(get_band_count())
        for ii = he[i][1] + 3, he[i][#he[i]], 4 do
            band_add_segment_segment(ii, ii + 4)
        end
        band_delete(get_band_count())
        if get_band_count() < 3 then
        for ii = he[i][1], he[i][#he[i]], 3 do
            band_add_segment_segment(ii, ii + 3)
        end
        band_delete(get_band_count())
        for ii = he[i][1] + 1, he[i][#he[i]], 3 do
            band_add_segment_segment(ii, ii + 3)
        end
        band_delete(get_band_count())
        for ii = he[i][1] + 2, he[i][#he[i]], 3 do
            band_add_segment_segment(ii, ii + 3)
        end
        band_delete(get_band_count())
        for ii = he[i][1] + 3, he[i][#he[i]], 3 do
            band_add_segment_segment(ii, ii + 3)
        end
        band_delete(get_band_count())
        end
        deselect_all()
        select_index_range(seg, r)
        set_behavior_clash_importance(0.05)
        best = RequestSaveSlot()
        quicksave(best)
        for i = 1, i_str_re_max_re do
            while get_score(true) == str_rs do
                do_local_rebuild(iter)
                iter = iter + i
            end
            str_rs = get_score(true)
            if not str_sc or str_sc < str_rs then
                str_sc = str_rs
                quicksave(best)
            end
        end
        str_sc = nil
        quickload(best)
        band_delete()
        seg = he[i][1] - 1
        if seg <= 0 then
            seg = 1
        end
        r = he[i][#he[i]] + 1
        if r > numsegs then
            r = numsegs
        end
        deselect_all()
        select_index_range(seg, r)
        for i = 1, i_str_re_max_re do
            while get_score(true) == str_rs do
                do_local_rebuild(iter * i_str_re_re_str)
                iter = iter + i
            end
            str_rs = get_score(true)
            if not str_sc or str_sc < str_rs then
                str_sc = str_rs - ((str_rs ^ 2)^(1/2))/2
                quicksave(best)
            end
        end
        quickload(best)
        seg = he[i][1] - 3
        if seg <= 0 then
            seg = 1
        end
        r = he[i][1] - 1
        if r > numsegs then
            r = numsegs
        end
        deselect_all()
        select_index_range(seg, r)
        seg = he[i][#he[i]] + 1
        if seg <= 0 then
            seg = 1
        end
        r = he[i][#he[i]] + 3
        if r > numsegs then
            r = numsegs
        end
        select_index_range(seg, r)
        for i = 1, i_str_re_max_re do
            while get_score(true) == str_rs do
                do_local_rebuild(iter * i_str_re_re_str)
                iter = iter + i
            end
            str_rs = get_score(true)
            if not str_sc or str_sc < str_rs then
                str_sc = str_rs - ((str_rs ^ 2)^(1/2))/2
                quicksave(best)
            end
        end
        quickload(best)
        seg = he[i][1] - 2
        if seg <= 0 then
            seg = 1
        end
        r = he[i][#he[i]] + 2
        if r > numsegs then
            r = numsegs
        end
        set_behavior_clash_importance(1)
        -- Restore structures saved before
        for ii = r, he[i][#he[i]] + 1, -1 do
            select_index(ii)
            replace_ss(tempss[#tempss])
            tempss[#tempss] = nil
        end
        for ii = he[i][1] - 1, seg, -1 do
            select_index(ii)
            replace_ss(tempss[#tempss])
            tempss[#tempss] = nil
        end
        -- Restored structures
        if b_str_re_dist then
            dists()
        else
            rebuilding = true
            fuze(best)
        end
        str_sc = nil
        str_rs = nil
        ReleaseSaveSlot(best)
    end
    rebuilding = false
    if b_predict_ss then
        deselect_all()
        for i = 1, #p_sh do
            for ii = p_sh[i][1], p_sh[i][#p_sh[i]] do
                select_index(ii)
            end
        end
        replace_ss("E")
    end
end
--struct rebuild#

--#Compressor
function compress()
    p("Compressing Segment ", seg)
    sphere = {}
    range = 0
    repeat
        count = 0
        range = range + 2
        sphere = GetSphere(seg, range)
        for n = 1, #sphere - 1 do
            if sphere[n] > seg + range / 4 and sphere[n] + 1 ~= sphere[n + 1] or sphere[n] < seg - range / 4 and sphere[n] + 1 ~= sphere[n + 1] then
                count = count + 1
            end
        end
    until count > 4
    for n = 1, #sphere - 1 do
        if sphere[n] > seg + range / 4 and sphere[n] + 1 ~= sphere[n + 1] or sphere[n] < seg - range / 4 and sphere[n] + 1 ~= sphere[n + 1] then
            band_add_segment_segment(seg, sphere[n])
            local length = get_segment_distance(seg, sphere[n])
            repeat
                length = length * 7 / 8
            until length <= 5
            band_set_length(get_band_count(), length)
            band_set_strength(get_band_count(), length / 5)
        end
    end
    do_global_wiggle_backbone(1)
    band_delete()
    p("Compressing Segment ", seg, "-", r)
    sphere1 = {}
    sphere2 = {}
    range = 0
end
--Compressor#

--#Bands
function bands()
    _numsegs = get_segment_count()
    p(_numsegs)
    i = 1
    numsegs = math.floor(_numsegs / 2)
    p(numsegs)
    while i < numsegs do
        band_add_segment_segment(numsegs - i, numsegs + i)
        band_set_strength(i, 10)
        band_set_length(i, 0)
        i = i + 1
    end
    band_add_segment_segment(numsegs, _numsegs)
    band_add_segment_segment(numsegs, 1)
    bands=get_band_count()
    for i = bands - 1, bands do
        band_set_strength(i, 10)
        band_set_length(i, 0)
    end
    band_add_segment_segment(numsegs / 2, _numsegs)
    band_add_segment_segment(numsegs + numsegs / 2, _numsegs)
    band_add_segment_segment(numsegs / 2, 1)
    band_add_segment_segment(numsegs + numsegs / 2, 1)
    band_add_segment_segment(numsegs / 4,numsegs + numsegs / 4)
    band_add_segment_segment(numsegs / 4,numsegs - numsegs / 4)
    band_add_segment_segment(numsegs + numsegs * 3 / 4,numsegs + numsegs / 4)
    band_add_segment_segment(numsegs + numsegs * 3 / 4,numsegs - numsegs / 4)
    for i = bands + 1, bands + 8 do
        band_set_strength(i, 0.01)
        band_set_length(i, 20)
    end
    bands = get_band_count()
    select_all()
    do_global_wiggle_all(1)
    do_shake(1)
    for i = 1, bands do
        band_set_strength(i, 5)
        band_set_length(i, 5)
    end
    do_global_wiggle_backbone(1)
    do_shake(1)
    do_global_wiggle_sidechains(1)
    for i = 1, bands do
        band_set_strength(i, 2)
        band_set_length(i, 5)
    end
    do_global_wiggle_backbone(1)
    do_shake(1)
    do_global_wiggle_sidechains(1)
    for i = 1, bands do
        band_set_strength(i, 1)
        band_set_length(i, 4)
    end
    do_global_wiggle_backbone(1)
    do_shake(1)
    do_global_wiggle_sidechains(1)
    for i = 1, bands do
        band_set_strength(i, 0.01)
    end
    do_global_wiggle_backbone(1)
    do_shake(1)
    do_global_wiggle_sidechains(1)
    band_delete()
    do_global_wiggle_backbone(1)
    do_shake(1)
    do_global_wiggle_sidechains(1)
end
--Bands#

function all()
    p(Version)
    if b_pp then
        for i = 1, i_pp_trys do
            dists()
        end
    end
    if b_predict_ss then
        predict_ss()
    end
    if b_str_re then
        struct_rebuild()
    end
    if b_mutate then
        mutable = FindMutable()
    end
    for i = start_seg, end_seg do
        seg = i
        c_s = get_score(true)
        if b_mutate then
            mutate()
        end
        if b_snap then
            snap()
        end
        for ii = start_walk, end_walk do
            r = i + ii
            if r > numsegs then
                r = numsegs
                break
            end
            if b_rebuild then
                rebuild()
            end
            if b_lws then
                p(seg, "-", r)
                gd("wl")
                if sc_changed then
                    gd("wb")
                    gd("ws")
                    gd("wa")
                    sc_changed = false
                end
            end
        end
    end
    if b_fuze then
        fuze(overall)
    end
end

s_0 = get_score(true)
c_s = s_0
p("Starting Score: ", c_s)
overall = RequestSaveSlot()
quicksave(overall)
all()
quickload(overall)
s_1 = get_score(true)
p("+++ Overall Gain +++")
p("+++", s_1 - s_0, "+++")