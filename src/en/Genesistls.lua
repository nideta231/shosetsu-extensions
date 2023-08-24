-- {"id":95555,"ver":"1.0.1","libVer":"1.0.0","author":"Confident-hate"}

local baseURL = "https://genesistls.com"

---@param v Element
local text = function(v)
    return v:text()
end


---@param url string
---@param type int
local function shrinkURL(url)
    return url:gsub("https://genesistls.com/", "")
end

---@param url string
---@param type int
local function expandURL(url)
    return baseURL .. "/" .. url
end

--- @param chapterURL string @url of the chapter
--- @return string @of chapter
local function getPassage(chapterURL)
    local htmlElement = GETDocument(chapterURL):selectFirst(".bixbox.episodedl")
    local title = htmlElement:selectFirst(".epheader h1"):text()
    local htmlElement = htmlElement:selectFirst(".epcontent.entry-content")
    htmlElement:child(0):before("<h1>" .. title .. "</h1>");
    htmlElement:select(".genesistls-watermark"):remove()
    -- htmlElement:select("style"):remove()
    htmlElement:select("br"):remove()

    local toRemove = {}
    htmlElement:traverse(NodeVisitor(function(v)
        if v:tagName() == "p" and v:text() == "" then
            toRemove[#toRemove+1] = v
        end
    end, nil, true))
    for _,v in pairs(toRemove) do
        v:remove()
    end



    return pageOfElem(htmlElement, true)
end

--- @param data table
local function search(data)
    local function getSearchResult(queryContent)
        return GETDocument(baseURL .. "/?s=" .. queryContent)
    end


    local queryContent = data[QUERY]
    local doc = getSearchResult(queryContent)

    return map(doc:select(".listupd .bs"), function(v)
        return Novel {
            title = v:selectFirst("a"):attr("title"),
            imageURL = v:selectFirst("a img"):attr("src"),
            link = v:selectFirst("a"):attr("href")
        }
    end)
end

--- @param novelURL string @URL of novel
--- @return NovelInfo
local function parseNovel(novelURL)
    local url = novelURL
    local document = RequestDocument(
            RequestBuilder()
                    :get()
                    :url(url)
                    :addHeader("Referer", "https://genesistls.com/series/")
                    :build()
    )

    return NovelInfo {
        title = document:selectFirst(".entry-title"):text(),
        description = document:select(".bixbox.synp .entry-content"):text(),
        imageURL = document:selectFirst(".thumb img"):attr("src"),
        --authors = { document:select(".spe span")[2]:text() },
        genres = map(document:select(".info-content .genxed a"), text ),
        chapters = AsList(
                map(document:select(".eplister.eplisterfull ul li"), function(v)
                    local isFree = v:selectFirst(".epl-price"):text()
                    local title = v:selectFirst(".epl-num"):text() .. " " .. v:selectFirst(".epl-title"):text()
                    if isFree == "Free" then
                        return NovelChapter {
                        order = v,
                        title = title,
                        link = v:selectFirst("a"):attr("href")
                        }
                    end
                end)
        )
    }
end


return {
    id = 95555,
    name = "Genesis Translations",
    baseURL = baseURL,
    imageURL = "https://genesistls.com/wp-content/uploads/2022/04/logo.png",
    hasSearch = true,
    listings = {
        Listing("Series Lists", false, function()
            local document = GETDocument(baseURL .. "/series/")
            return map(document:select(".listupd .bsx"), function(v)
                return Novel {
                    title = v:select("a"):attr("title"),
                    imageURL = v:select("a img"):attr("src"),
                    link = v:select("a"):attr("href")
                }
            end)
        end)
    },
    parseNovel = parseNovel,
    getPassage = getPassage,
    chapterType = ChapterType.HTML,
    search = search,
    shrinkURL = shrinkURL,
    expandURL = expandURL
}