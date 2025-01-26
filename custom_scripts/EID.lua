local EN = "en_us"

if EID then
    EID:addCollectible(Isaac.GetItemIdByName("Isaac's last will"), "{{Warning}} SINGLE USE#On death, revives Isaac in current room with 1 hit worth of default health type, grants {{Guppy}} Guppy transformation and sets pocket active item to Guppy's Paw if he doesn't already hold any pocket active.#Every enemy that dies in the same room after the respawn grants {{HalfSoulHeart}} half a soul heart.", "Isaac's last will", EN)
    EID:addCollectible(Isaac.GetItemIdByName("Daddy Haunt"), "Not implemented yet", "Daddy Haunt", EN)
end