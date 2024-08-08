-- {"id":1403038472,"ver":"1.0.0","libVer":"1.0.0","author":"JFronny","dep":["XenForo>=1.0.0"]}

return Require("XenForo")("https://forums.spacebattles.com/", {
    id = 1403038472,
    name = "SpaceBattles",
    imageURL = "https://forums.spacebattles.com/data/svg/2/1/1722951957/2022_favicon_192x192.png",
    forums = {
        {
            title = "Creative Writing",
            forum = 18
        },
        {
            title = "Quests",
            forum = 240
        }
    }
})
