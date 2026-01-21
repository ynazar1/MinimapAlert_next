# Minimap Alert - Changelog

## Version 29 - WoW 12.0.0 Compatibility Update

### API Compatibility
- ✅ **WoW 12.0.0 Support**: Updated TOC files for The War Within (120000, 120001)
- ✅ **Mists TOC Update**: Updated to interface version 50503
- ✅ **Settings API Compatibility**: Added proper fallbacks for Retail vs Classic/Mists/Cata
- ✅ **FlashClientIcon Compatibility**: Added existence check for older WoW versions
- ✅ **InterfaceOptions Compatibility**: Added fallback for legacy InterfaceOptions API

### Bug Fixes
- ✅ **Settings Panel Opening**: Fixed `Settings.OpenToCategory` to use category object/ID instead of string name (WoW 12.0+ requirement)
- ✅ **Minimap Position**: Fixed minimap moving when opening/closing frame without starting scan
- ✅ **Minimap Initialization**: Store minimap position on first frame show to prevent unwanted movement
- ✅ **Syntax Errors**: Fixed method call syntax errors with GetID() checks

### Code Improvements
- ✅ **Removed Commands**: Removed `/minimapalert testbutton` and `/minimapalert reset` commands
- ✅ **Conditional Restore**: Only restore minimap if settings are initialized (prevents corruption warnings)
- ✅ **Better Error Handling**: Improved API compatibility checks with proper fallbacks

### Technical Changes
- ✅ **API Version Detection**: Proper detection and handling of different WoW API versions
- ✅ **Category ID Handling**: Proper handling of numeric category IDs in WoW 12.0+
- ✅ **State Management**: Improved state handling to prevent minimap movement on frame open/close

---

## Version 28 - Major Update

### New Features
- ✅ **Self-Contained Libraries**: Added bundled LibStub, LibDataBroker-1.1, and LibDBIcon-1.0
- ✅ **Custom Addon Icon**: Added spyglass icon to addon list (matches minimap button)
- ✅ **Minimap Button**: Added spyglass icon button with click handlers
- ✅ **Enhanced Commands**: `/minimapalert` now toggles UI instead of just opening
- ✅ **Combat Integration**: Automatic pause/resume during combat
- ✅ **Resume Button**: "Resume" button when waiting for loot

### Improvements
- ✅ **UI Layout**: Fixed text overlapping in options panel
- ✅ **Default Position**: GUI frame starts centered on screen
- ✅ **Scanning Logic**: Restored fast/slow scan distinction for better accuracy

### Bug Fixes
- ✅ **Double Detection**: 2-second loot cooldown prevents re-detection
- ✅ **Minimap State**: Fixed minimap getting stuck in resized state
- ✅ **Stop Button**: Stop button now properly restores minimap
- ✅ **Button Text**: Fixed button text not updating correctly
- ✅ **State Management**: Improved state transitions and cleanup

### Technical Changes
- ✅ **Code Cleanup**: Removed debug statements and unnecessary complexity
- ✅ **Error Handling**: Enhanced error handling for minimap button creation
- ✅ **State Machine**: Improved state machine with better transitions
- ✅ **Memory Management**: Proper cleanup of combat and gathering states
- ✅ **TOC Updates**: Updated interface versions for all WoW versions (Retail, Classic, Cata, Mists)
- ✅ **Library Integration**: Proper loading order with bundled libraries in libs folder

### Settings
- ✅ **Hide Minimap Button**: Option to hide minimap button (reversed logic)
- ✅ **Combat Description**: Added note about automatic combat disable
- ✅ **Consistent Timing**: Idle scan uses same base timing as moving scan

---

## Previous Versions

### Version 25 and Earlier
- Basic scanning functionality
- Simple UI controls
- Manual start/stop operation
- Basic minimap manipulation

---

## Current Status
- **Double Detection**: Significantly reduced with 2-second cooldown
- **UI/UX**: Enhanced with minimap button and better controls
- **Combat Integration**: Seamless pause/resume during combat
- **Code Quality**: Clean, maintainable code with proper error handling
- **Self-Contained**: No external dependencies required - works standalone
- **Multi-Version Support**: Compatible with Retail, Classic, Cata, and Mists
