# Navigator - a map searching and navigation Add-on for ESO #

This is an Add-on designed to make getting from place to place in ESO easier. It provides a context-sensitive tab on the World Map and a sophisticated search box where you can enter wayshrines, zones or other destinations with results appearing as you type.

## Please Note ##

This add-on is brand-new, and has only been tested by me! I would appreciate friendly feedback as to how it can be improved or how it isn't working the way you'd expect.

## Features ##

- A new **Navigator tab** on the World Map, which can be configured to be the default tab
- A **search box** (focussed by using the `Tab` key) where you can enter
  - Wayshrines
  - Zones
  - Houses
  - Dungeons, Arenas or Trials
  - @Usernames
- **Results appear as you type**, with weightings given depending on the target (more for owned houses, or bookmarked locations, less for unowned houses or wayshrines with a recall cost, for instance)
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