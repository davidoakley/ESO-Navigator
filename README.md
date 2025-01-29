# Navigator - a map searching and navigation Add-on for ESO #

This is an Add-on designed to make getting from place to place in ESO easier. It provides a context-sensitive tab on the World Map and a sophisticated search box where you can enter wayshrines, zones or other destinations with results appearing as you type.

## Please Note ##

This add-on is brand-new, and has only been tested by me! I would appreciate friendly feedback as to how it can be improved or how it isn't working the way you'd expect.

Navigator currently works in **English** and is partially localised and tested in **French**; other languages may have varying levels of functionality or brokenness... Please get in touch if you'd like to help!

## Features ##

- A new **Navigator tab** on the World Map, which can be configured to be the default tab
- A **search box** (focussed by using the `Tab` key) where you can enter
  - Wayshrines
  - Zones
  - Houses
  - Dungeons, Arenas or Trials
  - @Usernames
- **Results appear as you type**, with weightings given depending on the target (higher for owned houses, or bookmarked locations, lower for unowned houses or wayshrines with a recall cost, for instance)
- **Keyboard navigation** - focus the edit box with `Tab`, type your search, choose result using the up and down cursor keys and then select by pressing `Enter`
- **`/nav` chat command** to jump to a destination (configurable to be `/tp` instead)
- **Bookmarks** (right-click a result to add or remove)

## Required Libraries ##

- **LibAddonMenu-2.0** - required to provide a Settings panel

## Optional Libraries ##

- **LibSlashCommander** - used to enable the 'slash' command
- **LibWorldMapInfoTab** - automatically scaled World Map tab icons if you have multiple AddOns

## Search Tips

Search results use the [`fzy`](https://github.com/jhawthorn/fzy) algorithm. It attempts to present the best matches first. The following considerations are weighted when sorting:
- It prefers consecutive characters: `dag` matches `Daggerfall` over `Dragonstar`.
- It prefers matching the beginning of words: `cc` matches `Clockwork City` over `Cradlecrush`
- It prefers shorter matches: `fortr` matches `Brass Fortress` over `Fort Redmane`.
- It prefers shorter candidates: `Wayr` matches `Wayrest` over `Wayrest Sewers`.

You can start a search by typing a prefix, which can filter your search:

- `p:` or `@` - List and filter by **players** by username
- `h:` - List and filter by **houses**
- `z:` - Jump to the Tamriel map to list all **zone** names

When filtering, press `Backspace` to delete the filter and return to normal search mode

## Licence ##

This Add-on is not created by, affiliated with, or sponsored by, ZeniMax
Media Inc. or its affiliates. The Elder Scrolls® and related logos are
registered trademarks or trademarks of ZeniMax Media Inc. in the United
States and/or other countries. All rights reserved.

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms

fzy, by [John Hawthorn](https://github.com/jhawthorn), with a Lua port by
[swarn](https://github.com/swarn) is covered by the MIT License:

The MIT License (MIT)

Copyright (c) 2014 John Hawthorn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.