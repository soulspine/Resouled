local x = {
    {
        Name = "soggy",
        ReturnValue = "Soggy Cat is a cat that is very soggy. He is very sad and lonely. He is always looking for a friend to play with. He is very cute and cuddly, but he is also very wet. He loves to play in the rain and splash in puddles. He is always looking for a warm place to dry off, but he never seems to find one. He is always cold and shivering, but he doesn't mind because he loves being soggy."
    },
    {
        Name = "winter_cat",
        ReturnValue = "Winter Cat"
    },
    {
        Name = "observing_cat",
        ReturnValue = "He's observing"
    },
    {
        Name = "john_resouled",
        ReturnValue = "John Resouled"
    },
    {
        Name = "i_have_a_hole_in_my_shoes",
        ReturnValue = "I have a hole in my shoes"
    }
}

local dependenciesPresent = true

for _, dependency in ipairs(x) do
    local path = "dependencies/"..dependency.Name
    if include(path) ~= dependency.ReturnValue then
        dependenciesPresent = false
    end
end

return dependenciesPresent