-- advtrains_oop/init.lua
-- Object-oriented programming for Advanced Trains
-- Copyright (C) 2024-2025  1F616EMO
-- SPDX-License-Identifier: AGPL-3.0-or-later

advtrains_oop = {}

local MP = core.get_modpath("advtrains_oop")

dofile(MP .. "/oop_api.lua")

atlatc.register_function("get_train", function(f_id, f_atc_arrow)
    if not f_id and atc_id then
        f_id = atc_id
    end
    return advtrains_oop.get_train_object(f_id, f_atc_arrow)
end)
