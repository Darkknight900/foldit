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

--#Snapping
function snap(mutated)         -- TODO: need complete rewrite
    snapping = true
    snaps = RequestSaveSlot()
    c_snap = PuzzleScore(b_explore)
    cs = PuzzleScore(b_explore)
    quicksave(snaps)
    iii = get_sidechain_snap_count(seg)
    p("Snapcount: ", iii, " - Segment ", seg)
    if iii ~= 1 then
    snapwork = RequestSaveSlot()
        for ii = 1, iii do
            quickload(snaps)
            p("Snap ", ii, "/ ", iii)
            c_s = PuzzleScore(b_explore)
            select()
            do_sidechain_snap(seg, ii)
            p(PuzzleScore(b_explore) - c_s)
            c_s = PuzzleScore(b_explore)
            quicksave(snapwork)
            gd("s")
            gd("wa")
            gd("ws")
            gd("wb")
            gd("wl")
            if c_snap < PuzzleScore(b_explore) then
            c_snap = PuzzleScore(b_explore)
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
        s_snap = PuzzleScore(b_explore)
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
                        local mut_1 = PuzzleScore(b_explore)
                        do_mutate(1)
                    until PuzzleScore(b_explore) - mut_1 < 0.01
                    mut_1 = PuzzleScore(b_explore)
                    fgain("wa")
                until PuzzleScore(b_explore) - mut_1 < 0.01
                if PuzzleScore(b_explore) > c_s then
                    c_s = PuzzleScore(b_explore)
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
                    s_mut = PuzzleScore(b_explore)
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
                    s_mut2 = PuzzleScore(b_explore)
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
                    s_mut2 = PuzzleScore(b_explore)
                end
            end
            ReleaseSaveSlot(sl_mut)
            quickload(overall)
        end
    end
    mutating = false
end
--Mutate#