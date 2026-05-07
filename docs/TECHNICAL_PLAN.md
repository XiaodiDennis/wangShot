# wangShot Technical Plan

This technical plan outlines the implementation of wangShot as a native macOS application using Swift, SwiftUI, AppKit, ScreenCaptureKit, Core Graphics, Vision OCR, AVFoundation, and local file storage. The development is broken into 15 small implementation phases, each focusing on a specific aspect of the application.

## Phase 1: Native macOS App Shell

**Goal:** Establish the basic native macOS application structure with Swift and SwiftUI, including the main app delegate, window management, and initial UI setup.

**Files/Modules to Create:**
- `wangShot/AppDelegate.swift` - Main app delegate
- `wangShot/ContentView.swift` - Root SwiftUI view
- `wangShot/wangShotApp.swift` - Main app struct
- `wangShot/Assets.xcassets` - App icons and assets
- `wangShot/Info.plist` - App configuration

**macOS APIs Likely Needed:**
- AppKit (NSApplication, NSAppDelegate)
- SwiftUI (App protocol, WindowGroup)

**Acceptance Criteria:**
- App launches successfully on macOS
- Basic window appears with minimal UI
- App can be quit via standard macOS methods
- No crashes on startup

**Implementation Risks:**
- SwiftUI compatibility issues with older macOS versions
- App sandbox restrictions for file access
- Initial setup complexity with Xcode project configuration

## Phase 2: Menu Bar App Structure

**Goal:** Convert the app to a menu bar application with a status item, hiding the main window and providing menu-based access to features.

**Files/Modules to Create:**
- `wangShot/MenuBarManager.swift` - Manages the status bar item
- `wangShot/AppMenu.swift` - Defines the menu structure
- `wangShot/StatusBarController.swift` - Controls status bar interactions

**macOS APIs Likely Needed:**
- AppKit (NSStatusBar, NSMenu, NSMenuItem)
- NSApplication (setActivationPolicy)

**Acceptance Criteria:**
- App appears as menu bar icon only
- Clicking menu bar icon shows dropdown menu
- Menu includes basic options (Quit, About)
- Main window is hidden by default

**Implementation Risks:**
- Menu bar app lifecycle management
- User confusion about app visibility
- Status bar item positioning and theming

## Phase 3: Global Shortcut Manager

**Goal:** Implement a system for registering and handling global keyboard shortcuts that work across all applications.

**Files/Modules to Create:**
- `wangShot/GlobalShortcutManager.swift` - Manages global shortcuts
- `wangShot/ShortcutPreferences.swift` - Stores shortcut configurations
- `wangShot/ShortcutHandler.swift` - Processes shortcut events

**macOS APIs Likely Needed:**
- Carbon framework (RegisterEventHotKey, EventHotKeyID)
- AppKit (NSEvent, NSApplication)

**Acceptance Criteria:**
- Shortcuts can be registered and unregistered
- Shortcuts trigger actions even when app is not focused
- Conflicts with system shortcuts are handled gracefully
- Shortcuts persist across app restarts

**Implementation Risks:**
- Carbon framework deprecation concerns
- System shortcut conflicts
- Accessibility permissions requirements
- Cross-application event handling

## Phase 4: Screenshot Overlay Window

**Goal:** Create a full-screen transparent overlay window that appears when screenshot mode is activated, providing the base for region selection.

**Files/Modules to Create:**
- `wangShot/ScreenshotOverlayView.swift` - SwiftUI view for overlay
- `wangShot/OverlayWindowController.swift` - Manages overlay window
- `wangShot/OverlayWindow.swift` - Custom NSWindow subclass

**macOS APIs Likely Needed:**
- AppKit (NSWindow, NSView, NSApplication)
- SwiftUI (ZStack, Color with opacity)

**Acceptance Criteria:**
- Overlay covers entire screen(s)
- Overlay is transparent with dimmed background
- Overlay appears above all other windows
- Overlay can be dismissed programmatically

**Implementation Risks:**
- Window level management (NSWindow.Level)
- Multi-monitor support
- Performance with large screen areas
- Window focus and input handling

## Phase 5: Manual Region Selection

**Goal:** Implement drag-to-select functionality for manual rectangular region selection with visual feedback and precision controls.

**Files/Modules to Create:**
- `wangShot/RegionSelectorView.swift` - Handles mouse interactions
- `wangShot/SelectionRectangle.swift` - Represents selected area
- `wangShot/SelectionToolbar.swift` - Shows dimensions and controls

**macOS APIs Likely Needed:**
- AppKit (NSEvent, NSMouse, NSCursor)
- SwiftUI (DragGesture, GeometryReader)

**Acceptance Criteria:**
- User can drag to select rectangular regions
- Selection shows live dimensions
- Arrow keys provide pixel-precise adjustments
- Shift/Option modifiers work for aspect ratio and center expansion
- Selection can be confirmed or cancelled

**Implementation Risks:**
- Mouse event coordinate system conversions
- Gesture conflicts with system behaviors
- Performance during continuous updates
- Accessibility for keyboard-only users

## Phase 6: Window Detection

**Goal:** Add automatic window boundary detection and highlighting when the mouse hovers over application windows.

**Files/Modules to Create:**
- `wangShot/WindowDetector.swift` - Detects window boundaries
- `wangShot/WindowHighlighter.swift` - Visual highlighting
- `wangShot/WindowInfo.swift` - Window metadata structure

**macOS APIs Likely Needed:**
- CoreGraphics (CGWindowListCopyWindowInfo, CGWindowID)
- AppKit (NSRunningApplication, NSWorkspace)

**Acceptance Criteria:**
- Windows are detected and highlighted on hover
- Hidden/invisible windows are ignored
- Desktop background is not selectable
- Window boundaries are accurately represented

**Implementation Risks:**
- Accessibility permission requirements
- Performance with many windows
- Window z-order and occlusion handling
- Cross-process window information access

## Phase 7: Browser Content-Area Detection

**Goal:** Implement intelligent detection of browser content areas, excluding toolbars and chrome for cleaner screenshots.

**Files/Modules to Create:**
- `wangShot/BrowserDetector.swift` - Identifies browser applications
- `wangShot/ContentAreaCalculator.swift` - Calculates content regions
- `wangShot/BrowserOffsets.swift` - Stores toolbar offset data

**macOS APIs Likely Needed:**
- Accessibility framework (AXUIElement, AXAttribute)
- AppKit (NSRunningApplication, NSBundle)

**Acceptance Criteria:**
- Chrome and Safari content areas are detected
- Toolbar exclusions work in normal cases
- User corrections are remembered per browser
- Fallback to manual selection when detection fails

**Implementation Risks:**
- Browser UI structure changes across versions
- Accessibility API reliability
- Performance impact of UI inspection
- Cross-browser compatibility

## Phase 8: Screenshot Capture Engine

**Goal:** Build the core screenshot capture functionality using ScreenCaptureKit to capture selected regions.

**Files/Modules to Create:**
- `wangShot/ScreenshotEngine.swift` - Main capture logic
- `wangShot/CaptureSession.swift` - Manages capture sessions
- `wangShot/ImageProcessor.swift` - Basic image processing

**macOS APIs Likely Needed:**
- ScreenCaptureKit (SCContentFilter, SCScreenshotManager)
- CoreGraphics (CGImage, CGContext)

**Acceptance Criteria:**
- Selected regions are captured accurately
- Capture works for all selection modes
- Images are stored in memory for processing
- Capture performance is acceptable

**Implementation Risks:**
- ScreenCaptureKit availability (macOS 12.3+)
- Permission handling for screen recording
- Memory usage for large captures
- Capture timing and synchronization

## Phase 9: PNG Export with Rounded Corners and Lower-Right Shadow

**Goal:** Implement PNG export with visual enhancements including rounded corners, drop shadows, and proper canvas padding.

**Files/Modules to Create:**
- `wangShot/ImageExporter.swift` - Handles PNG export
- `wangShot/ShadowRenderer.swift` - Applies drop shadows
- `wangShot/CornerProcessor.swift` - Adds rounded corners

**macOS APIs Likely Needed:**
- CoreGraphics (CGContext, CGImage, CGPath)
- ImageIO (CGImageDestination)

**Acceptance Criteria:**
- PNG files are exported with rounded corners
- Drop shadows appear correctly positioned
- Canvas includes proper padding to prevent clipping
- Export preserves image quality

**Implementation Risks:**
- Anti-aliasing quality for rounded corners
- Shadow rendering performance
- Color space and transparency handling
- File I/O error management

## Phase 10: Annotation Editor

**Goal:** Create an in-app annotation interface with tools for drawing shapes, text, and effects on captured screenshots.

**Files/Modules to Create:**
- `wangShot/AnnotationView.swift` - Main annotation canvas
- `wangShot/AnnotationTools.swift` - Tool definitions
- `wangShot/ShapeRenderer.swift` - Renders annotation shapes

**macOS APIs Likely Needed:**
- SwiftUI (Canvas, Path, Shape)
- AppKit (NSBezierPath, NSColor)

**Acceptance Criteria:**
- All required annotation tools are available
- Tools can be selected via keyboard shortcuts
- Annotations are rendered on the image
- Undo/redo functionality works

**Implementation Risks:**
- SwiftUI Canvas performance for complex drawings
- Coordinate system consistency
- Tool state management
- Real-time rendering updates

## Phase 11: OCR Panel

**Goal:** Integrate Vision framework for optical character recognition with a results panel for extracted text.

**Files/Modules to Create:**
- `wangShot/OCRProcessor.swift` - Handles OCR processing
- `wangShot/OCRPanelView.swift` - Displays OCR results
- `wangShot/TextRecognition.swift` - Vision integration

**macOS APIs Likely Needed:**
- Vision (VNRecognizeTextRequest, VNImageRequestHandler)
- SwiftUI (Text, ScrollView)

**Acceptance Criteria:**
- Text is extracted from images accurately
- OCR panel displays results with copy/save options
- Multiple languages are supported
- Processing is performed locally

**Implementation Risks:**
- Vision framework accuracy variations
- Language model availability
- Processing time for large images
- Memory usage during OCR

## Phase 12: Translation Panel

**Goal:** Add text translation capabilities using system translation services with a side-by-side display.

**Files/Modules to Create:**
- `wangShot/TranslationService.swift` - Translation logic
- `wangShot/TranslationPanelView.swift` - UI for translations
- `wangShot/LanguageManager.swift` - Language handling

**macOS APIs Likely Needed:**
- Translation framework (if available) or external APIs
- SwiftUI (VStack, HStack for side-by-side display)

**Acceptance Criteria:**
- Text can be translated between supported languages
- Original and translated text are displayed together
- Translation is performed locally when possible
- Fallback options are available

**Implementation Risks:**
- Translation framework availability (macOS 13+)
- Accuracy of local translation
- API rate limits for cloud services
- Language detection reliability

## Phase 13: Screen Recording with Microphone and System Audio

**Goal:** Implement screen recording functionality with audio capture from microphone and system sources.

**Files/Modules to Create:**
- `wangShot/RecordingEngine.swift` - Manages recording sessions
- `wangShot/AudioCapture.swift` - Handles audio input
- `wangShot/VideoRecorder.swift` - Screen capture recording

**macOS APIs Likely Needed:**
- ScreenCaptureKit (SCStream, SCContentFilter)
- AVFoundation (AVCaptureSession, AVCaptureDevice)
- CoreAudio (AudioDeviceID, AudioObject)

**Acceptance Criteria:**
- Screen recording captures video and audio
- Microphone and system audio can be mixed
- Recording controls (pause/resume/stop) work
- Output is saved as MP4

**Implementation Risks:**
- System audio capture complexity
- Audio synchronization issues
- Performance during recording
- Codec and format compatibility

## Phase 14: Settings Page

**Goal:** Create a settings interface for configuring shortcuts, export options, and application preferences.

**Files/Modules to Create:**
- `wangShot/SettingsView.swift` - Settings UI
- `wangShot/SettingsManager.swift` - Manages settings storage
- `wangShot/Preferences.swift` - Settings data structures

**macOS APIs Likely Needed:**
- SwiftUI (Form, Picker, Toggle)
- UserDefaults for storage

**Acceptance Criteria:**
- All configurable options are accessible
- Settings persist across app restarts
- UI is intuitive and organized
- Changes take effect immediately

**Implementation Risks:**
- Settings migration between versions
- UI complexity for many options
- Validation of user inputs
- Performance impact of frequent saves

## Phase 15: Permissions Management

**Goal:** Implement proper handling and user guidance for required macOS permissions (Screen Recording, Accessibility, Microphone).

**Files/Modules to Create:**
- `wangShot/PermissionManager.swift` - Checks and requests permissions
- `wangShot/PermissionView.swift` - Guides users through setup
- `wangShot/PermissionChecker.swift` - Validates permission status

**macOS APIs Likely Needed:**
- AppKit (NSApplication, NSWorkspace)
- CoreGraphics (CGRequestScreenCaptureAccess)
- AVFoundation (AVCaptureDevice authorization)

**Acceptance Criteria:**
- App detects missing permissions
- Clear instructions guide users to grant permissions
- App degrades gracefully when permissions are denied
- Permission status is checked on startup

**Implementation Risks:**
- Permission dialog timing and UX
- System preference pane integration
- Handling permission revocation
- Cross-version permission API changes