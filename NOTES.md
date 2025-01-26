# Mod Callbacks 
## [MC_POST_ENTITY_KILL](https://moddingofisaac.com/docs/rep/enums/ModCallbacks.html#mc_post_entity_kill)
It does pass `Entity` data but method has to have 2 arguments where first is always `nil` 

The correct way to do it is:
```lua
function methodName(_, entity)
    --code
end
```