-- Create animated GIFs with mpv
-- Requires ffmpeg.
-- Adapted from http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
-- Usage: "g" to set start frame, "G" to set end frame, "Ctrl+g" to create.
local msg = require 'mp.msg'
local utils = require 'mp.utils'

-- Set this to the filters to pass into ffmpeg's -vf option.
-- filters="fps=24,scale=320:-1:flags=lanczos"
filters="fps=15,scale=540:-1:flags=lanczos"

start_time = -1
end_time = -1
palette="/tmp/palette.png"

function make_gif_with_subtitles()
    make_gif_internal(true)
end

function make_gif()
    make_gif_internal(false)
end

function get_path()
    -- TODO: improve detection of file paths (relative, windows, …)
    local file_path = mp.get_property("path", "")
    if not string.sub(file_path,1,1) == "/" then  -- probably relative path
        file_path = mp.get_property("working-directory", "") .. "/" .. file_path
    end

    return file_path
end

function join(sep, arr, count)
    local r = ""
    if count == nil then
        count = #arr
    end
    for i = 1, count do
        if i > 1 then
            r = r .. sep
        end
        r = r .. utils.to_string(arr[i])
    end
    return r
end

function get_gifname()
    -- then, make the gif
    local filename = mp.get_property("filename/no-ext")
    local file_path = "/tmp/" .. filename

    -- increment filename
    for i=0,999 do
        local fn = string.format('%s_%03d.gif',file_path,i)
        if not file_exists(fn) then
            gifname = fn
            break
        end
    end

    if not gifname then
        msg.warning("No available filename")
        mp.osd_message('No available filenames!')
        return nil
    end

    return gifname
end

function log_command_result(res, val, err)
    if not (res and (val == nil or val["status"] == 0)) then
        if val["stderr"] then
            if mp.get_property("options/terminal") == "no" then
                file = io.open(string.format("/tmp/mpv-gif-ffmpeg.%s.log", os.time()), "w")
                file:write(string.format("ffmpeg error %d:\n%s", val["status"], val["stderr"]))
                file:close()
            else
                msg.error(val["stderr"])
            end
        end

        msg.error("GIF generation was unsuccessful")
        mp.osd_message("error creating GIF")
        return -1
    end

    return 0
end


function make_gif_internal(burn_subtitles)
    local start_time_l = start_time
    local end_time_l = end_time
    if start_time_l == -1 or end_time_l == -1 or start_time_l >= end_time_l then
        mp.osd_message("Invalid start/end time.")
        return
    end

    msg.info("Creating GIF" .. (burn_subtitles and " (with subtitles)" or ""))
    mp.osd_message("Creating GIF" .. (burn_subtitles and " (with subtitles)" or ""))

    function ffmpeg_esc(s)
        s = string.gsub(s, ":", "\\:")
        s = string.gsub(s, "\\", "\\\\")
        s = string.gsub(s, "'", "\\'")
        return s
    end

    local pathname = get_path()
    local trim_filters_pal = filters
    local trim_filters_gif = filters

    -- add subtitles only for final rendering as it slows down significantly
    if burn_subtitles then
        -- TODO: implement usage of different subtitle formats (i.e. bitmap ones, …)
        sid = mp.get_property("sid")
        sid = (sid == "no" and 0 or sid - 1)  -- mpv starts count subtitles with one
        trim_filters_gif = trim_filters_gif .. 
            string.format(",subtitles='%s':si=%d", ffmpeg_esc(pathname), sid)
    end


    local position = start_time_l
    local duration = end_time_l - start_time_l

    local gifname = get_gifname()
    if gifname == nil then
        return
    end

    local args_palette = {
        "ffmpeg", "-v", "warning", 
        "-ss", tostring(position), "-t", tostring(duration),
        "-i", pathname, 
        "-vf", trim_filters_pal .. ",palettegen",
        "-y", palette
    }


    local args_gif = {
        "ffmpeg", "-v", "warning",
        "-ss", tostring(position), "-t", tostring(duration),  -- define which part to use
        "-copyts",  -- otherwise ss can't be reused
        "-i", pathname, "-i", palette,  -- open files
        "-ss", tostring(position),  -- required for burning subtitles
        "-lavfi", trim_filters_gif .. " [x]; [x][1:v] paletteuse",
        "-y", gifname  -- output
    }

    -- first, create the palette
    mp.command_native_async({ name="subprocess", args=args_palette, capture_stdout=true, capture_stderr=true }, 
        function(res, val, err)
            if log_command_result(res, val, err) ~= 0 then
                return
            end

            mp.command_native_async({ name="subprocess", args=args_gif, capture_stdout=true, capture_stderr=true },
                function(res, val, err)
                    if log_command_result(res, val, err) ~= 0 then
                        return
                    end

                    msg.info(string.format("GIF created - %s", gifname))
                    mp.osd_message(string.format("GIF created - %s", gifname), 2)
                end)
        end)
end

function set_gif_start()
    start_time = mp.get_property_number("time-pos", -1)
    mp.osd_message("GIF Start: " .. start_time)
end

function set_gif_end()
    end_time = mp.get_property_number("time-pos", -1)
    mp.osd_message("GIF End: " .. end_time)
end

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function get_containing_path(str,sep)
    sep=sep or package.config:sub(1,1)
    return str:match("(.*"..sep..")")
end

mp.add_key_binding("g", "set_gif_start", set_gif_start)
mp.add_key_binding("G", "set_gif_end", set_gif_end)
mp.add_key_binding("Ctrl+g", "make_gif", make_gif)
mp.add_key_binding("Ctrl+G", "make_gif_with_subtitles", make_gif_with_subtitles)
