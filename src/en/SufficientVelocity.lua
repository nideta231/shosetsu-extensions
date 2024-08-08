-- {"id":1241865462,"ver":"1.0.0","libVer":"1.0.0","author":"JFronny","dep":["XenForo>=1.0.0"]}

return Require("XenForo")("https://forums.sufficientvelocity.com/", {
    id = 1241865462,
    name = "Sufficient Velocity",
    imageURL = "https://forums.sufficientvelocity.com/data/svg/20/1/1723049117/logo_icon.png",
    forums = {
        {
            title = "User Fiction",
            forum = 2
        },
        {
            title = "Alternate History",
            forum = 91
        }
    }
})
