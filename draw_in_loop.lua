-- added to aseprite menu
function init(plugin)
    plugin:newCommand{
        id="draw_in_loop",
        title="Draw In Loop",
        group="cel_properties",
        onclick=function() run() end
    }
end

function run()
    local dlg = Dialog("Draw In Loop")

    local delay_ms = 200
    local playing = false
    local timer = nil
    local cell_count = 1

    -- function to switch frames
    local function nextFrame()
        local sprite = app.activeSprite
        if not sprite then return end

        local frame = app.activeFrame.frameNumber
        local total_frames = #sprite.frames

        -- if in last frame, go back to the first frame
        if frame >= total_frames then
            app.activeFrame = sprite.frames[1]
        else
            app.activeFrame = sprite.frames[frame + 1]
        end
    end

    -- function to add cell
    local function addEmptyCell(count)
        local sprite = app.activeSprite
        if not sprite then return end

        local startFrameNumber = app.activeFrame.frameNumber

        for c = 1, count do
            local frameNumber = startFrameNumber + c
            -- add new frame if not exist
            if frameNumber > #sprite.frames then
                sprite:newFrame()
            end
            -- add empty cell to all frame
            for _, layer in ipairs(sprite.layers) do
                if layer.isVisible and not layer.isGroup then
                    sprite:newCel(layer, sprite.frames[frameNumber], nil)
                end
            end
        end
    end


    dlg:slider{
        id="speed",
        label="Speed (ms)",
        min=50,
        max=1000,
        value=delay_ms,
        onchange=function()
            delay_ms = dlg.data.speed
            if timer then
                timer.interval = delay_ms / 1000.0
            end
        end
    }

    dlg:button{
        id="start",
        text="Start Loop",
        onclick=function()
            if not playing then
                playing = true
                timer = Timer{
                    interval = delay_ms / 1000.0,
                    ontick = function()
                        if playing then
                            nextFrame()
                        end
                    end
                }
                timer:start()
            end
        end
    }

    dlg:button{
        id="stop",
        text="Stop Loop",
        onclick=function()
            playing = false
            if timer then timer:stop() end
        end
    }

    dlg:number{
        id="cellcount",
        label="Cells",
        text=tostring(cell_count),
        onchange=function()
            cell_count = math.max(1, tonumber(dlg.data.cellcount) or 1)
        end
    }

    dlg:button{
        id="addcell",
        text="Add Empty Cell",
        onclick=function()
            addEmptyCell(cell_count)
        end
    }

    dlg:button{
        id="close",
        text="Close",
        onclick=function()
            playing = false
            if timer then timer:stop() end
            dlg:close()
        end
    }

    dlg:show{wait=false}
end
