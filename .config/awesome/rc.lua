-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")

local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify(
    {
      preset = naughty.config.presets.critical,
      title = "Oops, there were errors during startup!",
      text = awesome.startup_errors
    }
  )
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal(
    "debug::error",
    function(err)
      if in_error then
        return
      end
      in_error = true

      naughty.notify(
        {
          preset = naughty.config.presets.critical,
          title = "Oops, an error happened!",
          text = tostring(err)
        }
      )
      in_error = false
    end
  )
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

terminal = "kitty"

modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.spiral
}
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

local cw = calendar_widget({
  placement = 'top_right',
})
mytextclock:connect_signal("button::press",
  function(_, _, _, button)
    if button == 1 then cw.toggle() end
  end)

-- Create a wibox for each screen and add it
local taglist_buttons =
    gears.table.join(
      awful.button(
        {},
        1,
        function(t)
          t:view_only()
        end
      ),
      awful.button(
        { modkey },
        1,
        function(t)
          if client.focus then
            client.focus:move_to_tag(t)
          end
        end
      ),
      awful.button({}, 3, awful.tag.viewtoggle),
      awful.button(
        { modkey },
        3,
        function(t)
          if client.focus then
            client.focus:toggle_tag(t)
          end
        end
      ),
      awful.button(
        {},
        4,
        function(t)
          awful.tag.viewnext(t.screen)
        end
      ),
      awful.button(
        {},
        5,
        function(t)
          awful.tag.viewprev(t.screen)
        end
      )
    )

local tasklist_buttons =
    gears.table.join(
      awful.button(
        {},
        1,
        function(c)
          if c == client.focus then
            c.minimized = true
          else
            c:emit_signal("request::activate", "tasklist", { raise = true })
          end
        end
      ),
      awful.button(
        {},
        3,
        function()
          awful.menu.client_list({ theme = { width = 250 } })
        end
      ),
      awful.button(
        {},
        4,
        function()
          awful.client.focus.byidx(1)
        end
      ),
      awful.button(
        {},
        5,
        function()
          awful.client.focus.byidx(-1)
        end
      )
    )

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(
  function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(
      gears.table.join(
        awful.button(
          {},
          1,
          function()
            awful.layout.inc(1)
          end
        ),
        awful.button(
          {},
          3,
          function()
            awful.layout.inc(-1)
          end
        ),
        awful.button(
          {},
          4,
          function()
            awful.layout.inc(1)
          end
        ),
        awful.button(
          {},
          5,
          function()
            awful.layout.inc(-1)
          end
        )
      )
    )
    -- Create a taglist widget
    s.mytaglist =
        awful.widget.taglist {
          screen = s,
          filter = awful.widget.taglist.filter.all,
          buttons = taglist_buttons
        }

    -- Create a tasklist widget
    s.mytasklist =
        awful.widget.tasklist {
          screen = s,
          filter = awful.widget.tasklist.filter.currenttags,
          buttons = tasklist_buttons
        }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
      layout = wibox.layout.align.horizontal,
      {
        -- Left widgets
        layout = wibox.layout.fixed.horizontal,
        -- mylauncher,
        s.mytaglist,
        s.mypromptbox
      },
      s.mytasklist, -- Middle widget
      {
        -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.systray({
          set_reverse = true
        }),
        batteryarc_widget({
          show_current_level = true,
          show_notification_mode = "off",
          enable_battery_warning = false,
          font = "Hack Nerd Font Regular 8",
          arc_thickness = 1.4,
          size = 20
        }),
        mytextclock,
        s.mylayoutbox
      }
    }
  end
)
-- }}}

-- {{{ Key bindings
globalkeys =
    gears.table.join(
      awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
      awful.key({ modkey }, "Tab", awful.tag.history.restore, { description = "go back", group = "tag" }),
      awful.key(
        { modkey },
        "Right",
        function()
          awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
      ),
      awful.key(
        { modkey },
        "Left",
        function()
          awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
      ),
      -- Layout manipulation
      awful.key(
        { modkey, "Shift" },
        "Right",
        function()
          awful.client.swap.byidx(1)
        end,
        { description = "swap with next client by index", group = "client" }
      ),
      awful.key(
        { modkey, "Shift" },
        "Left",
        function()
          awful.client.swap.byidx(-1)
        end,
        { description = "swap with previous client by index", group = "client" }
      ),
      awful.key(
        { modkey },
        "Return",
        function()
          awful.spawn(terminal)
        end,
        { description = "open a terminal", group = "launcher" }
      ),
      awful.key(
        {},
        "Print",
        function()
          awful.spawn("flameshot gui")
        end,
        { description = "take a screenshot (flameshot)", group = "launcher" }
      ),
      awful.key(
        { modkey },
        "q",
        function()
          awful.spawn("firefox")
        end,
        { description = "open firefox", group = "launcher" }
      ),
      awful.key(
        { modkey },
        "w",
        function()
          awful.spawn("thunar")
        end,
        { description = "open thunar", group = "launcher" }
      ),
      awful.key(
        { modkey },
        "e",
        function()
          awful.spawn("kitty --class ncspot ncspot")
        end,
        { description = "open ncspot", group = "launcher" }
      ),
      awful.key(
        {},
        "XF86MonBrightnessDown",
        function()
          awful.spawn.with_shell(
            "echo $(( $(cat /sys/class/backlight/amdgpu_bl*/brightness) - 10 )) > /sys/class/backlight/amdgpu_bl*/brightness")
        end,
        { description = "decrease screen brightness", group = "launcher" }
      ),
      awful.key(
        {},
        "XF86MonBrightnessUp",
        function()
          awful.spawn.with_shell(
            "echo $(( $(cat /sys/class/backlight/amdgpu_bl*/brightness) + 10 )) > /sys/class/backlight/amdgpu_bl*/brightness")
        end,
        { description = "increase screen brightness", group = "launcher" }
      ),
      awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
      awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
      awful.key(
        { modkey, "Control" },
        "Right",
        function()
          awful.tag.incmwfact(0.05)
        end,
        { description = "increase master width factor", group = "layout" }
      ),
      awful.key(
        { modkey, "Control" },
        "Left",
        function()
          awful.tag.incmwfact(-0.05)
        end,
        { description = "decrease master width factor", group = "layout" }
      ),
      awful.key(
        { modkey },
        "space",
        function()
          awful.layout.inc(1)
        end,
        { description = "select next", group = "layout" }
      ),
      awful.key(
        { modkey, "Shift" },
        "space",
        function()
          awful.layout.inc(-1)
        end,
        { description = "select previous", group = "layout" }
      ),
      awful.key(
        { modkey, "Shift" },
        "n",
        function()
          local c = awful.client.restore()
          -- Focus restored client
          if c then
            c:emit_signal("request::activate", "key.unminimize", { raise = true })
          end
        end,
        { description = "restore minimized", group = "client" }
      ),
      awful.key(
        { modkey },
        "d",
        function()
          awful.util.spawn("rofi -show drun")
        end,
        { description = "show rofi", group = "launcher" }
      )
    )

clientkeys =
    gears.table.join(
      awful.key(
        { modkey },
        "f",
        function(c)
          c.fullscreen = not c.fullscreen
          c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }
      ),
      awful.key(
        { modkey, "Shift" },
        "c",
        function(c)
          c:kill()
        end,
        { description = "close", group = "client" }
      ),
      awful.key(
        { modkey, "Shift" },
        "a",
        function(c)
          c:swap(awful.client.getmaster())
        end,
        { description = "move to master", group = "client" }
      ),
      awful.key(
        { modkey },
        "n",
        function(c)
          -- The client currently has the input focus, so it cannot be
          -- minimized, since minimized clients can't have the focus.
          c.minimized = true
        end,
        { description = "minimize", group = "client" }
      ),
      awful.key(
        { modkey },
        "m",
        function(c)
          c.maximized = not c.maximized
          c:raise()
        end,
        { description = "(un)maximize", group = "client" }
      )
    )

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys =
      gears.table.join(
        globalkeys,
        -- View tag only.
        awful.key(
          { modkey },
          "#" .. i + 9,
          function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
              tag:view_only()
            end
          end,
          { description = "view tag #" .. i, group = "tag" }
        ),
        -- Toggle tag display.
        awful.key(
          { modkey, "Control" },
          "#" .. i + 9,
          function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
              awful.tag.viewtoggle(tag)
            end
          end,
          { description = "toggle tag #" .. i, group = "tag" }
        ),
        -- Move client to tag.
        awful.key(
          { modkey, "Shift" },
          "#" .. i + 9,
          function()
            if client.focus then
              local tag = client.focus.screen.tags[i]
              if tag then
                client.focus:move_to_tag(tag)
              end
            end
          end,
          { description = "move focused client to tag #" .. i, group = "tag" }
        ),
        -- Toggle tag on focused client.
        awful.key(
          { modkey, "Control", "Shift" },
          "#" .. i + 9,
          function()
            if client.focus then
              local tag = client.focus.screen.tags[i]
              if tag then
                client.focus:toggle_tag(tag)
              end
            end
          end,
          { description = "toggle focused client on tag #" .. i, group = "tag" }
        )
      )
end

clientbuttons =
    gears.table.join(
      awful.button(
        {},
        1,
        function(c)
          c:emit_signal("request::activate", "mouse_click", { raise = true })
        end
      ),
      awful.button(
        { modkey },
        1,
        function(c)
          c:emit_signal("request::activate", "mouse_click", { raise = true })
          awful.mouse.client.move(c)
        end
      ),
      awful.button(
        { modkey },
        3,
        function(c)
          c:emit_signal("request::activate", "mouse_click", { raise = true })
          awful.mouse.client.resize(c)
        end
      )
    )

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  },
  {
    rule = { class = "discord" },
    properties = { tag = "4" }
  },
  {
    rule = { class = "ncspot" },
    properties = { tag = "3" }
  }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
  "manage",
  function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then
      awful.client.setslave(c)
    end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
    end
  end
)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal(
  "mouse::enter",
  function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
  end
)

client.connect_signal(
  "focus",
  function(c)
    c.border_color = beautiful.border_focus
  end
)
client.connect_signal(
  "unfocus",
  function(c)
    c.border_color = beautiful.border_normal
  end
)
-- }}}

awful.spawn.with_shell("~/.config/awesome/autorun.sh")
