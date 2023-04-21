-- {"id":93278,"ver":"1.0.0","libVer":"1.0.0","author":"TechnoJo4","dep":["url>=1.0.0","dkjson>=1.0.0"]}

local baseURL = "https://kemono.party"
local apiURL = baseURL .. "/api"

local json = Require("dkjson")

local creators

local function shrinkURL(url)
    return url:gsub("^.-kemono%.party/?", "")
end

local function expandURL(url)
    return baseURL .. url
end

local function creatorURL(v)
    return "/" .. v.service .. "/user/" .. v.id
end

local function parseListing(tbl)
    return map(tbl, function(v)
        return Novel {
            title = v.name,
            link = creatorURL(v),
            imageURL = baseURL .. "/banners/" .. v.service .. "/" .. v.id
        }
    end)
end

return {
    id = 93278,
    name = "Kemono",
    baseURL = baseURL,
    imageURL = "https://kemono.party/static/klogo.png",
    hasSearch = true,
    chapterType = ChapterType.HTML,

    listings = {
        Listing("All", false, function(data)
            if not creators then
                creators = json.GET(apiURL .. "/creators")
            end
            return parseListing(creators)
        end),
        Listing("Favorites", false, function(data)
            return parseListing(json.GET(apiURL .. "/v1/account/favorites"))
        end)
    },

    getPassage = function(chapterURL)
        local content = json.GET(apiURL .. chapterURL)[1].content
        return "<!DOCTYPE html><html><head></head><body>" .. content .. "</body></html>"
    end,

    parseNovel = function(novelURL, loadChapters)
        if not creators then
            creators = json.GET(apiURL .. "/creators")
        end

        local name = novelURL
        for _,v in pairs(creators) do
            if novelURL == creatorURL(v) then
                name = v.name
            end
        end

        local info = NovelInfo {
            title = name,
            imageURL = baseURL .. "/banners" .. novelURL:gsub("user/", "")
        }

        if loadChapters then
            local o = 0
            local posts = {}
            while true do
                local page = json.GET(apiURL .. novelURL .. "?o="..tostring(o))
                if not page or #page == 0 then break end
                o = o + 50
                posts[#posts+1] = page
            end

            info:setChapters(AsList(filter(map(flatten(posts), function(v, i)
                if v.content and #v.content > #("<p><br></p>") then
                    return NovelChapter {
                        order = #posts - i,
                        title = v.title,
                        link = novelURL .. "/post/" .. v.id
                    }
                end
            end), function(v) return v end)))
        end

        return info
    end,

    search = function()
        if not creators then
            creators = json.GET(apiURL .. "/creators")
        end
        if data[QUERY]:match("/user/") then
            return parseListing(filter(creators, function(v)
                return data[QUERY] == creatorURL(v)
            end))
        end
        return parseListing(filter(creators, function(v)
            return v.name:match(data[QUERY])
        end))
    end,

    shrinkURL = shrinkURL,
    expandURL = expandURL
}
