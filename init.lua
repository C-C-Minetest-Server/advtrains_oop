-- advtrains_oop/init.lua
-- Object-oriented programming for Advanced Trains
-- Copyright (C) 2024-2025  1F616EMO
-- SPDX-License-Identifier: AGPL-3.0-or-later

advtrains_oop = {}

local MP = core.get_modpath("advtrains_oop")

dofile(MP .. "/oop_api.lua")

local function get_train(f_id, f_atc_arrow)
    if not f_id and atc_id then
        f_id = atc_id
    end
    return advtrains_oop.get_train_object(f_id, f_atc_arrow)
end
atlatc.register_function("get_train", get_train)


-- Intercept atlatc.active.run_in_env
local old_run_in_env = atlatc.active.run_in_env
function atlatc.active.run_in_env(pos, evtdata, customfct)
    if customfct.atc_id then
        customfct.get_trains = function(f_id, f_atc_arrow)
            if not f_id then
                f_id = customfct.atc_id
            end
            return get_train(f_id, f_atc_arrow)
        end
    end

    return old_run_in_env(pos, evtdata, customfct)
end