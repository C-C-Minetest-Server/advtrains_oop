-- oop_api.lua
-- Handles the train class used in LuaATC codes

-- TODO: Properly invalidate train references when a train vanishes,
--       i.e. do not let it point to a new train coincidentally reusing the same ID.

local train_ref_class = {}

-- Properties

function train_ref_class:is_valid()
    return advtrains.trains[self.atc_id] and true or false
end

function train_ref_class:get_id()
    local train = advtrains.trains[self.atc_id]
    return train and train.id or false
end

function train_ref_class:get_index()
    local train = advtrains.trains[self.atc_id]
    return train and train.index or false
end

function train_ref_class:train_length()
    local train = advtrains.trains[self.atc_id]
    return train and #train.trainparts or false
end

function train_ref_class:train_length_meters()
    local train = advtrains.trains[self.atc_id]
    return train and train.trainlen or false
end

-- ATC

function train_ref_class:atc_send(command)
    assertt(command, "string")
    local train = advtrains.trains[self.atc_id]
    if train then
        advtrains.atc.train_set_command(train, command, self.atc_arrow)
        return true
    end
    return false
end

function train_ref_class:atc_reset()
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    advtrains.atc.train_reset_command(train)
    return true
end

-- Split

function train_ref_class:split_at_index(index, cmd)
    assertt(cmd, "string")
    if type(index) ~= "number" or index < 2 then
        return false
    end
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    local new_id = advtrains.split_train_at_index(train, index)
    if new_id then
        core.after(0.1, advtrains.atc.train_set_command, advtrains.trains[new_id], cmd, self.atc_arrow)
        return true
    end
    return false
end

function train_ref_class:split_at_fc(cmd, length_limit)
    assertt(cmd, "string")
    local train = advtrains.trains[self.atc_id]
    local new_id, fc = advtrains.split_train_at_fc(train, false, length_limit)
    if new_id then
        core.after(0.1, advtrains.atc.train_set_command, advtrains.trains[new_id], cmd, atc_arrow)
    end
    return fc or ""
end

function train_ref_class:split_off_locomotive(cmd, len)
    assertt(cmd, "string")
    local train = advtrains.trains[self.atc_id]
    local new_id, fc = advtrains.split_train_at_fc(train, true, len)
    if new_id then
        core.after(0.1, advtrains.atc.train_set_command, advtrains.trains[new_id], cmd, atc_arrow)
    end
end

-- Freight code

function train_ref_class:step_fc()
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    advtrains.train_step_fc(train)
end

function train_ref_class:get_fc()
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    local fc_list = {}
    for index, wagon_id in ipairs(train.trainparts) do
        fc_list[index] = table.concat(advtrains.wagons[wagon_id].fc, "!") or ""
    end
    return fc_list
end

function train_ref_class:set_fc(fc_list)
    assertt(fc_list, "table")
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    -- safety type-check for entered values
    for _, v in ipairs(fc_list) do
        if v and type(v) ~= "string" then
            error("FC entries must be a string")
            return
        end
    end
    for index, wagon_id in ipairs(train.trainparts) do
        if fc_list[index] then                                 -- has FC to enter to this wagon
            local data = advtrains.wagons[wagon_id]
            if data then                                       -- wagon actually exists
                for _, wagon in pairs(core.luaentities) do -- find wagon entity
                    if wagon.is_wagon and wagon.initialized and wagon.id == wagon_id then
                        wagon.set_fc(data, fc_list[index])     -- overwrite to new FC
                        break                                  -- found, no point cycling through every other entity
                    end
                end
            end
        end
    end
end

-- Shunt and Autocouple

function train_ref_class:set_shunt()
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    train.is_shunt = true
end

function train_ref_class:unset_shunt()
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    train.is_shunt = false
end

function train_ref_class:set_autocouple()
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    train.autocouple = true
end

function train_ref_class:unset_autocouple()
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    train.autocouple = false
end

-- Line and RC

function train_ref_class:get_line()
    local train = advtrains.trains[self.atc_id]
    return train and train.line or false
end

function train_ref_class:set_line(line)
    if type(line) == "number" then
        line = tostring()
    elseif type(line) ~= "string" then
        return false
    end

    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    train.line = line
	core.after(0, advtrains.invalidate_path, train.id)
    return true
end

function train_ref_class:get_rc()
    local train = advtrains.trains[self.atc_id]
    return train and train.routingcode or false
end

function train_ref_class:set_rc(rc)
    if type(rc) ~= "string" then
        return false
    end

    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    train.routingcode = rc
	core.after(0, advtrains.invalidate_path, train.id)
    return true
end

function train_ref_class:has_rc(query)
    local rc_list = self:get_rc()
    if not rc_list then return false end

    for word in rc_list:gmatch("[^%s]+") do
        if word == query then return true end
    end
    return false
end

-- Speed

function train_ref_class:get_speed()
    local train = advtrains.trains[self.atc_id]
    return train and train.velocity or false
end

function train_ref_class:get_max_speed()
    local train = advtrains.trains[self.atc_id]
    return train and train.max_speed or false
end

-- Display text

function train_ref_class:get_text_outside()
    local train = advtrains.trains[self.atc_id]
    return train and train.text_outside or false
end

function train_ref_class:set_text_outside(text)
    if text ~= nil then
        assertt(text, "string")
    end
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    train.text_outside = text
    return true
end

function train_ref_class:get_text_inside()
    local train = advtrains.trains[self.atc_id]
    return train and train.text_inside or false
end

function train_ref_class:set_text_inside(text)
    if text ~= nil then
        assertt(text, "string")
    end
    local train = advtrains.trains[self.atc_id]
    if not train then return false end
    train.text_inside = text
    return true
end

-- Interlocking and ARS

if advtrains.interlocking then
    function train_ref_class:get_ars_disable(value)
        local train = advtrains.trains[self.atc_id]
        if not train then return false end
        return train.ars_disable
    end

    function train_ref_class:set_ars_disable(value)
        local train = advtrains.trains[self.atc_id]
        if not train then return false end
        advtrains.interlocking.ars_set_disable(train, value)
    end

    function train_ref_class:ars_check_rule_match(ars)
        local type_ars = type(ars)
        if type_ars == "string" then
            ars = advtrains.interlocking.text_to_ars(ars)
        elseif type_ars ~= "table" and type_ars ~= "nil" then
            error("ars_check_rule_match expect valid ARS representation")
        end

        local train = advtrains.trains[self.atc_id]
        if not train then return false end

        return advtrains.interlocking.ars_check_rule_match(ars, train)
    end
end

-- atc_set_lzb_tsr is purposly not adopted here because it doesn't make sense

local train_ref_metatable = {
    __index = train_ref_class,
    __newindex = function()
        error("Attempt to set new index on train_ref class")
    end,
}

-- Exposing train reference class methods so other mods can add their own
-- e.g. livery tool
advtrains_oop.train_ref_class = train_ref_class

advtrains_oop.get_train_object = function(atc_id, atc_arrow)
    if not advtrains.trains[atc_id] then return false end
    if atc_arrow == nil then
        atc_arrow = true
    end
    return setmetatable({
        atc_id = atc_id,
        atc_arrow = atc_arrow,
    }, train_ref_metatable)
end
