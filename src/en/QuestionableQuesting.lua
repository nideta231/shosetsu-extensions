-- {"id":1915581632,"ver":"1.1.0","libVer":"1.0.0","author":"JFronny","dep":["XenForo>=1.0.3"]}

return Require("XenForo")("https://forum.questionablequesting.com/", {
    id = 1915581632,
    name = "Questionable Questing",
    imageURL = "https://forum.questionablequesting.com/styles/dark_responsive_green/xenforo/qq-blue-small.png",
    forums = {
        {
            title = "Creative Writing",
            forum = 19
        },
        {
            title = "Questing",
            forum = 20
        },
        {
            title = "NSFW Creative Writing",
            forum = 29
        },
        {
            title = "NSFW Questing",
            forum = 12
        }
    }
})
