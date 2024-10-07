-- {"id":78,"ver":"1.0.0","libVer":"1.0.0","author":"JFronny"}

local settings = {}

-- concatenate two lists
---@param list1 table
---@param list2 table
local function concatLists(list1, list2)
    for i = 1, #list2 do
        table.insert(list1, list2[i])
    end
    return list1
end

local function lift(xtable)
    local t = {}
    for k, v in next, xtable do
        table.insert(t, { k, v })
    end
    return t
end

local auxiliary = {
    ["https://parahumans.wordpress.com/"] = {
        name = "Worm",
        image = "https://parahumans.wordpress.com/wp-content/uploads/2011/06/cityscape2.jpg",
        description = {5, 9},
        arcs = ".widget_categories .cat-item .cat-item:not(.cat-item .cat-item .cat-item)",
        arc = "a",
        chapters = ".cat-item .cat-item a"
    },
    ["https://pactwebserial.wordpress.com/"] = {
        name = "Pact",
        image = "https://pactwebserial.wordpress.com/wp-content/uploads/2014/01/pact-banner2.jpg",
        description = {2, 5},
        arcs = ".widget_categories .cat-item .cat-item:not(.cat-item .cat-item .cat-item)",
        arc = "a",
        chapters = ".cat-item .cat-item a"
    },
    -- We ignore Twig since that uses a different (and significantly harder to parse) ToC.
    -- If you want to read it, feel free to set it up yourself.
    --["https://twigserial.wordpress.com/"] = {
    --    name = "Twig",
    --    image = "https://twigserial.wordpress.com/wp-content/uploads/2016/06/cropped-twigheader5.png",
    --    description = "#content .entry-content p:nth-child(n+2):nth-child(-n+3)",
    --},
    ["https://www.parahumans.net/"] = {
        name = "Ward",
        image = "https://i2.wp.com/www.parahumans.net/wp-content/uploads/2017/10/cropped-Ward-Banner-Proper-1.jpg",
        description = {4, 5},
        arcs = "#secondary .widget_nav_menu:not(#nav_menu-2) .menu-item:not(.menu-item .menu-item)",
        arc = "a",
        chapters = ".menu-item .menu-item a"
    },
    ["https://palewebserial.wordpress.com/"] = {
        name = "Pale",
        image = "",
        description = {1, 7},
        arcs = "#nav_menu-2 .menu-item:not(.menu-item .menu-item)",
        arc = "a",
        chapters = ".sub-menu a"
    }
}

local function parseNovel(novelURL, loadChapters)
    local document = GETDocument(novelURL)
    local aux = auxiliary[novelURL]

    local novel = NovelInfo {
        title = aux.name,
        imageURL = aux.image,
        description = table.concat(map(document:select("#content .entry-content p"), function(v)
            return v:text()
        end), "\n\n", aux.description[1], aux.description[2]),
        authors = { "Wildbow" },
        status = NovelStatus.COMPLETED
    }

    if loadChapters then
        local chaps = {}
        local i = 0
        map(document:select(aux.arcs), function(element)
            local arcPrefix = element:selectFirst(aux.arc):text()
                    :gsub("^[ ]*", "")
                    :gsub("[ ]*$", "")
                    :gsub("^Arc [0-9]* ", "")
                    :gsub("– ", "")
                    :gsub("^%(", "")
                    :gsub("%)$", "")
                    .. " - "
            chaps = concatLists(chaps, mapNotNil(element:select(aux.chapters), function(v)
                i = i + 1
                return NovelChapter {
                    order = i,
                    title = arcPrefix .. v:text(),
                    link = v:attr("href")
                }
            end))
        end)

        novel:setChapters(AsList(chaps))
    end

    return novel
end

local function getPassage(chapterURL)
    local document = GETDocument(chapterURL)
    map(document:select(".entry-content > :not(p, h1, hr)"), function(v) v:remove() end)
    return pageOfElem(document:selectFirst(".entry-content"), true)
end

return {
    id = 78,
    name = "Wildbow (Parahumans)",
    baseURL = "https://www.parahumans.net/",
    listings = {
        Listing("Novels", false, function(data)
            return map(lift(auxiliary), function(a)
                return Novel {
                    link = a[1],
                    title = a[2].name,
                    imageURL = a[2].image
                }
            end)
        end)
    },
    getPassage = getPassage,
    parseNovel = parseNovel,
    shrinkURL = function(url) return url end,
    expandURL = function(url) return url end,

    imageURL = "https://parahumans.wordpress.com/wp-content/uploads/2011/06/cityscape2.jpg",
    hasCloudFlare = false,
    hasSearch = false,
    chapterType = ChapterType.HTML,
    startIndex = 1,

    updateSetting = function(id, value)
        settings[id] = value
    end,
}
