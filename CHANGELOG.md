# Minimap Alert - Changelog

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
