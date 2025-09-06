# MinimapAlert

A World of Warcraft addon that automatically scans your minimap for gathering resources and alerts you when they appear, helping you never miss a gathering opportunity!

## 📖 Overview

MinimapAlert is a gathering-focused addon that continuously monitors your minimap for specific resources (herbs, ore, etc.) while you're moving or idle. When it finds a tracked resource, it provides visual and audio alerts to help you spot gathering opportunities you might otherwise miss.

Perfect for herbalists, miners, and anyone who wants to maximize their gathering efficiency in World of Warcraft!

## ✨ Key Features

- 🔍 **Automatic Minimap Scanning** - Continuously monitors the minimap for tracked resources
- 🏃 **Smart Movement Detection** - Uses different scan speeds based on whether you're moving or stationary
- 🎮 **Multi-Version Support** - Works with Retail, Classic, Cataclysm, and Mists of Pandaria
- ⚔️ **Combat Integration** - Automatically pauses during combat and resumes afterward
- 🔔 **Customizable Alerts** - Screen flash, taskbar flash, and sound notifications
- 🗺️ **Minimap Button** - Easy access via spyglass icon on minimap
- 📦 **Self-Contained** - No external dependencies required
- 🎯 **Precise Detection** - Prevents double detection with smart cooldown system

## 🚀 Quick Start

### Installation
1. Download the addon from the releases page
2. Extract to your `WoW/Interface/AddOns/` folder
3. Restart WoW or reload UI (`/reload`)
4. The addon will appear in your AddOns list

### Basic Usage
1. Open the addon interface (click the spyglass icon on your minimap or use `/minimapalert`)
2. Add resources to track using the "Add Item" button
3. Configure your preferred settings in the options panel
4. Click "Start" to begin scanning
5. The addon will alert you when tracked resources appear on the minimap!

## 🎛️ User Interface

### Main Window
- **Start/Stop Button** - Begin or end scanning
- **Status Display** - Shows current scanning state
- **Config Button** - Opens settings panel
- **Movable Frame** - Drag to reposition anywhere on screen

### Settings Panel
Access via the Config button or `/minimapalert` command:

- ✅ **Flash screen when match found** - Full screen flash alert
- ✅ **Flash taskbar when match found** - Windows taskbar notification
- ✅ **Play sound when match found** - Audio alert sound
- ✅ **Also search while not moving** - Idle scanning (slower but more thorough)
- ✅ **Hide minimap button** - Toggle minimap button visibility
- 🎚️ **Scan Interval Slider** - Adjust scan speed (0.1s to 1.0s)

## 🌿 Supported Resources

### Herbalism
- **Legion**: Aethril, Dreamleaf, FoxFlower, Fjarnskaggl, Starlight Rose
- **Battle for Azeroth**: Akunda's Bite, Anchor Weed, Riverbud, Sea Stalk, Siren's Pollen, Star Moss, Winter's Kiss, Zin'anthid

### Mining
- **Legion**: Leystone Ore, Felslate, Empyrium

### Custom Resources
- Add any resource name manually using the "Add Item" button
- Supports partial name matching (e.g., "Anchor" will match "Anchor Weed")

## ⌨️ Commands

| Command | Description |
|---------|-------------|
| `/minimapalert` | Toggle main interface |

## ⚙️ Technical Details

- **Current Version**: 28
- **Author**: Motig
- **Compatibility**: 
  - WoW Retail (11.0+)
  - WoW Classic
  - Cataclysm Classic
  - Mists of Pandaria Classic
- **Dependencies**: None (includes bundled libraries)
- **Interface**: Modern Settings panel integration
- **Memory Usage**: Minimal impact on game performance

## 🔧 Advanced Features

### Smart Scanning
- **Fast Scan**: When moving, uses rapid frame-based scanning for quick detection
- **Slow Scan**: When idle, uses time-based scanning to allow minimap updates

### Combat Integration
- Automatically pauses scanning when entering combat
- Resumes scanning when leaving combat (if previously active)
- Preserves gathering state during combat transitions

## ⚠️ Limitations & Caveats

- **Combat Disabled**: The addon automatically stops scanning when entering combat and resumes when leaving combat
- **Mouselook Restriction**: Scanning is paused during mouselook (right mouse button camera control) to prevent interference
- **Resource Dependent**: Requires at least one tracked resource in your tracking list to function
- **Minimap Reliant**: Effectiveness depends on the minimap being visible and functional
- **Performance Impact**: Higher scan frequencies may cause more minimap flickering

## 🐛 Troubleshooting

### Common Issues

**Minimap gets stuck in resized state:**
- Use `/reload` to restore normal minimap by reloading UI
- Or manually stop and restart scanning

**Addon not detecting resources:**
- Ensure you have at least one item in your tracking list
- Check that the addon is enabled in the AddOns menu
- Try reloading UI with `/reload`

**Minimap button not appearing:**
- Check if "Hide minimap button" is unchecked in settings
- Try reloading UI with `/reload`

**Double detection alerts:**
- The addon includes a 2-second cooldown to prevent this
- If still occurring, try adjusting the scan interval slider

### Performance Tips
- Use scan interval of 0.5s or higher for better performance
- Disable idle scanning if you're always moving
- Close the main window when not actively gathering

## 📋 Version History

### Version 28 - Major Update
- ✅ Self-contained with bundled libraries
- ✅ Enhanced combat integration
- ✅ Improved scanning accuracy
- ✅ Better UI/UX with minimap button
- ✅ Fixed double detection issues
- ✅ Support for all major WoW versions

### Previous Versions
- Basic scanning functionality
- Simple UI controls
- Manual start/stop reset operation

## 🤝 Contributing

**Copyright Notice**: This addon is written and owned by Motig. All rights to the original work remain with the original author.

This repository represents fan-driven enhancements and modifications made for personal use. Any contributions are voluntary and do not claim ownership of the original work. All rights to the original MinimapAlert addon belong to Motig.

**Disclaimer**: This is not an official version of MinimapAlert. Use at your own discretion.


## 📄 License

This addon is free to use. No warranty is provided. Use at your own risk.

## 🙏 Acknowledgments

- **Author**: Motig
- **Community**: Thanks to all users who have provided feedback and bug reports
- **Libraries**: LibStub, LibDataBroker-1.1, LibDBIcon-1.0

---

**Happy Gathering!** 🌿⛏️

*Never miss another gathering node with MinimapAlert!*
