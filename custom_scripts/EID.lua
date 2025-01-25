local EN = "en_us"

if EID then
    EID:addCollectible(Isaac.GetItemIdByName("Isaac's last will"), "{{Warning}} SINGLE USE#Prevents death, granting 2 {{SoulHeart}} soul hearts, {{Guppy}} Guppy transformation and sets pocket active item to Guppy's Paw if character doesn't hold any other pocket active.#After triggering, each possessed item has 50% chance to get removed.#{{Warning}} This item is worthless for characters that can only have {{Heart}} red or {{EmptyBoneHeart}} bone hearts.", "Isaac's last will", EN)
    EID:addCollectible(Isaac.GetItemIdByName("Daddy Haunt"), "Not implemented yet", "Daddy Haunt", EN)
end