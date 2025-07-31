local Map = require("p4lua.data.Map")

local pub = {}

pub.luassert = function(assert)
    local exports = {
        "are",
        "are_not_the_same",
        "equal",
        "equals",
        "error_matches",
        "has_a_error",
        "has_an_error",
        "has_error",
        "has_match",
        "has_no",
        "has_no_error",
        "has_no_match",
        "has_property",
        "is",
        "is_a_string",
        "is_false",
        "is_nil",
        "is_not",
        "is_not_false",
        "is_not_nil",
        "is_not_string",
        "is_not_a_string",
        "is_not_table",
        "is_not_true",
        "is_same",
        "is_string",
        "is_table",
        "is_true",
        "same",
    }
    return Map.filterByKeys(assert, exports)
end

return pub
