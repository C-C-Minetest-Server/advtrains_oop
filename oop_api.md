# Advtrains LuaATC OOP API Documentation

The LuaATC OOP API is designed for operators to interact with trains without messing up with their IDs so many times. It also enables operators to have more control over trains not above a LuaATC track. This API is also expandable via the exposed `atlatc.train_ref_class` index table.

For all object methods, if the train is not valid, `false` is returned.

TODO: Properly invalidate train references when a train vanishes, i.e. do not let it point to a new train coincidentally reusing the same ID.

## Create an instance

* `get_train(atc_id, atc_arrow)`: Returns a train reference
  * `atc_id`: The ID of the train
  * `atc_arrow`: Whether this train is (or should be seen as) passing a LuaATC Track in its arrow's direction.
    * This affects conditional codes in ATC commands, i.e. the `I+/-` codes.
  * On LuaATC Tracks, if `atc_id` is omitted, this returns the train reference of the current train with `atc_arrow` set to its direction.

## Basic Properties

* `:is_valid()` -> `boolean`: Whether the train reference is still valid, i.e. pointing to an existing train.
* `:get_id()` -> `number`: Return the train ID of the train
* `:train_length()` -> `number`: Return the number of wagons in this train
* `:train_length_meters()` -> `number`: Return the length of this train in meters

## Automated Train Control (ATC) commands

* `:atc_send(command)` -> `boolean`: Run the given ATC command on the train. Returns boolean indicating success.
* `:atc_reset()`: Clears all running ATC command.

## Splitting trains

* `:split_at_index(index, cmd)` -> `boolean`: Split the train at the given index. Run `cmd` on the newly created train. Returns boolean indicating success.
* `:split_at_fc(cmd, length_limit)`: Split the train at first different current FC. Optional `length_limit` limits the length of the first train. Run `cmd` on the newly created train.
* `:split_off_locomotive`: Split off the locomotive of a train. Optional `length_limit` limits the length of the first train. Run `cmd` on the newly created train.

## Freight codes

* `:step_fc()`:
* `:get_fc()`:
* `:set_fc(fc_list)`:

## Shunting and Autocoupling

* `:set_shunt()`, `:unset_shunt()`: Set and unset shunting mode respectively.
* `:set_autocouple()`, `:unset_autocouple()`: Set and unset autocouple mode respectively.

## Line and RC

* `:get_line()`, `:get_rc()`: Get the line and routing code respectively.
* `:set_line(line)`, `:set_rc(rc)`: Set the line and routing code repectively.
  * For `set_line`, numerical `line` is allowed. Otherwise, a string is needed.
* `:has_rc(query)`: Check whether the given RC is part of the train's RC.

## Speed (in m/s)

* `:get_speed()`: Get the current speed of the train
* `:get_max_speed()`: Get the maximum speed of the train

## Display text

* `:get_text_outside()`, `:get_text_inside()`: Get the text displayed outside and inside of the train respectively.
* `:set_text_outside(text)`, `:set_text_inside(text)`: Set the text displayed outside and inside of the train respectively.
  * If `text` is `nil`, the string is emptied.

## LZB Checkpoint

* `:get_lzb_checkpoints()`: Get all LZB checkpoints in front of that train, from the nearest to the most far away.
  * Returns `false` if failed to query checkpoint (i.e. LZB not yet initialized and you should wait), otherwise a table.
  * Only `pos`, `index` and `speed` are kept in the returned table. The table may be empty.

## Interlocking and ARS

*(only avaliable if `advtrains_interlocking` is loaded)*

* `:set_ars_disable(value)`: If `true`, ARS will be disabled on the train
  * This can also be done via `:atc_send("A<value>")`, where `<value>` is 1 or 0 depending on what you want to do.
* `:ars_check_rule_match(ars)`: Check the train against the given ARS ruleset
  * `ars` can either be an ARS string or an ARS table.

## Developers guide

This section is mainly for Advtrains developers and modders wanting to work on the API.

The `atc_id` field stores the ID of the train this reference is pointing to. The following snippet is recommended to check whether it is still valid:

```lua
local train = advtrains.trains[self.atc_id]
if not train then return false end
-- Use the train table here
```

If you code simply fetches a value, use this format instead:

```lua
local train = advtrains.trains[self.atc_id]
return train and your_code(train, ...) or false
```
