local ssp <const> = playdate.sound.sampleplayer

soundSwipes = {
    ssp.new("audios/Swipe1"),
    ssp.new("audios/Swipe2"),
    ssp.new("audios/Swipe3"),
}

soundMainTheme  = ssp.new("audios/MainTheme")
soundMenuSelect = ssp.new("audios/MenuSelect")
soundMenuGoBack = ssp.new("audios/MenuGoBack")

function PlayAudioTable(soundTable, loop)
    if loop == nil then loop = 1 end

    for i, sound in ipairs(soundTable) do
        if not sound:isPlaying() then
            PlayAudio(sound, loop)
            return
        end
    end
end
function PlayAudio(sound, loop, volume)
    if loop == nil then loop = 1 end

    if sound then
        if volume then sound:setVolume(volume) end
        sound:play(loop)
    end
end
function StopAudio(sound)
    if sound then sound:stop() end
end

function PlayAudioTableSpacialized(soundTable, loop, pos, murphPos)
    for i, sound in ipairs(soundTable) do
        if not sound:isPlaying() then
            PlayAudioSpacialized(sound, loop, pos, murphPos)
            return
        end
    end
end
function PlayAudioSpacialized(sound, loop, pos, murphPos)
    local dist = Distance(pos.x, pos.y, murphPos.x, murphPos.y)

    if sound and dist < 8 then
        local volume = 1 / Clamp(dist, 1, 8)

        sound:setVolume(volume)
        PlayAudio(sound, loop)
    end
end