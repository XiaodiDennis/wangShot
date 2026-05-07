# wangShot PRD

## 1. Product Overview

**Product name:** wangShot  
**Platform:** macOS  
**Primary user:** Personal use on Dennis's MacBook  
**Distribution plan:** Private/local use only. No public release, no App Store listing, no account system, no payment system.  
**Product type:** Native macOS menu-bar utility for screenshots, annotation, screen recording, OCR, and image-to-text translation.

wangShot is a personal macOS productivity tool designed to capture clean, visually polished screenshots and screen recordings with minimal friction. The first priority is a high-quality screenshot workflow: smart selection, browser content-area snapping, rounded-corner PNG export, lower-right shadow, and an in-place annotation editor.

The product should feel closer to a native macOS tool than a web app. It should be fast, keyboard-driven, visually clean, and reliable enough for daily use in coding, university reports, GitHub READMEs, consulting documents, WeChat articles, and client explanations.

---

## 2. Product Goals

The main goal is to build a private utility that improves daily workflow on macOS.

wangShot should allow the user to:

1. Capture screenshots quickly with global shortcuts.
2. Automatically align screenshot selection with windows, browser content areas, full screen, or manually selected regions.
3. Capture browser webpage content below the address bar and toolbar instead of the whole browser window.
4. Export screenshots as PNG with rounded corners and a soft shadow.
5. Stay inside an annotation interface after selection.
6. Add arrows, rectangles, underlines, text, mosaics, numbered markers, and focus highlights.
7. Copy, save, cancel, pin, or continue editing without extra steps.
8. Record the screen with microphone audio and system/computer audio where possible.
9. Run multilingual OCR on selected screenshot regions.
10. Translate text extracted from screenshots.

The product should prioritize **speed, local control, visual quality, and predictable behavior** over feature quantity.

---

## 3. Non-Goals

The initial product should not include:

1. User accounts.
2. Cloud sync.
3. Team collaboration.
4. Public sharing links.
5. Payment or licensing.
6. App Store distribution.
7. Cross-platform Windows/Linux support.
8. Complex video editing.
9. AI image generation or AI retouching.
10. Full screenshot-history database in the first version.

Because this is for personal use, some manual setup is acceptable, including granting macOS permissions for Screen Recording, Accessibility, Microphone, and file access.

---

## 4. Target User

The target user is a MacBook user who frequently needs screenshots and screen recordings for:

- Coding and debugging.
- GitHub READMEs.
- University assignments and reports.
- Software demonstrations.
- Browser research.
- Client communication.
- WeChat articles.
- Xiaohongshu or social media explanation posts.
- OCR and translation of multilingual material.

Primary device assumption:

- macOS laptop.
- Apple Silicon or Intel Mac support.
- Chrome and Safari are the most important browsers.
- VS Code, Xcode, browser, PDF reader, and terminal are common target apps.

---

## 5. Core Product Modules

wangShot has four core modules:

1. Screenshot and annotation.
2. Screen recording with audio.
3. Multilingual OCR.
4. Image-to-text translation.

Priority order:

1. Screenshot capture.
2. Beautified PNG export.
3. Annotation editor.
4. Browser content-area detection.
5. OCR.
6. Translation.
7. Screen recording.

---

## 6. Screenshot Module

### 6.1 Screenshot Modes

#### 6.1.1 Manual Region Screenshot

The user presses a global shortcut and drags to select any rectangular region.

Requirements:

- Show a full-screen transparent overlay.
- Dim areas outside the selection.
- Show a crosshair cursor.
- Show live width and height near the selected region.
- Allow drag-to-select.
- Allow resizing from corners and edges.
- Press `Esc` to cancel.
- Press `Enter` to confirm.
- Press `Command + C` to copy.
- Press `S` or click save icon to save.

Detailed behavior:

- While dragging, the selection rectangle should be clear and the outside area should be dimmed.
- The selection should display blue handles at the corners.
- The toolbar should appear near the selected area.
- If the selection is near the bottom of the screen, the toolbar should appear above the selection.
- If the selection is near the top of the screen, the toolbar should appear below the selection.

Precision controls:

- Arrow keys move the selection by 1 px.
- `Shift + Arrow` moves the selection by 10 px.
- Holding `Shift` while resizing locks aspect ratio.
- Holding `Option` while resizing expands from the center.
- `Esc` cancels the capture.

---

#### 6.1.2 Full Screen Screenshot

The user captures the current screen or all screens.

Requirements:

- Capture current display by default.
- Support multiple displays later.
- Save as PNG.
- Rounded corners disabled by default.
- Shadow disabled by default.
- Optional beautified export mode available.

---

#### 6.1.3 Window Screenshot

The app detects the window under the pointer and automatically highlights it.

Requirements:

- As the pointer moves, the selected window boundary updates.
- The window under the pointer is highlighted.
- The user clicks or presses `Enter` to capture.
- The output should include the selected window only.
- The output can include rounded corners and shadow.

Expected behavior:

- VS Code, browser windows, terminal, Finder, and Xcode windows should be selectable.
- Hidden/invisible windows should be ignored.
- Desktop wallpaper should not be selected unless full-screen mode is chosen.

Technical direction:

- Use native macOS APIs where possible.
- Use ScreenCaptureKit, CoreGraphics window APIs, and Accessibility APIs.
- Accessibility permission is likely required for more accurate window and UI element detection.

---

#### 6.1.4 Browser Content Area Screenshot

This is a major differentiating feature.

The app should automatically detect the webpage content area below the browser title bar, tab bar, address bar, bookmarks bar, and toolbar. The goal is to capture the useful webpage content, not browser chrome.

Target browsers:

1. Chrome: highest priority.
2. Safari: second priority.
3. Microsoft Edge: optional.
4. Firefox: optional.

Behavior:

- User presses screenshot shortcut.
- Pointer moves into browser window.
- wangShot detects that the pointer is inside a browser.
- Instead of highlighting the full browser window, wangShot highlights the webpage content area below the browser toolbar.
- User clicks or presses `Enter`.
- wangShot captures only the content area.
- PNG export applies rounded corners and lower-right shadow by default.

Detection strategy:

1. Try Accessibility API to inspect browser UI structure.
2. Detect known browser window and content region.
3. Estimate content area using calibrated toolbar offsets.
4. Remember user-adjusted offsets per browser and screen scale.
5. Fall back to manual region selection if detection fails.

User correction:

- If the detected browser content area is wrong, the user can manually adjust the region.
- wangShot should remember the correction for that browser on the same display configuration.

Acceptance criteria:

- Chrome browser content-area capture works correctly in at least 90% of normal cases on the user's MacBook.
- If bookmark bar is visible or hidden, wangShot should either detect the difference or let the user correct and remember the offset.
- The selected region should not include address bar, tabs, toolbar, or browser sidebar unless manually included.

---

#### 6.1.5 Previous Area Screenshot

The app captures the same rectangle used in the previous screenshot.

Use cases:

- Repeatedly capture the same part of a webpage.
- Capture before/after UI states.
- Capture coding output changes.
- Capture a fixed region during debugging.

Requirements:

- Store the last confirmed screenshot rectangle.
- Provide global shortcut.
- Capture immediately or show the previous region for confirmation.
- User can choose behavior in settings.

---

#### 6.1.6 Preset Area Screenshot

The app supports fixed-size capture regions.

Default presets:

- 188 × 188
- 800 × 450
- 1200 × 675
- 1280 × 720
- 1920 × 1080
- WeChat article cover ratio
- Xiaohongshu vertical ratio
- Custom preset

Behavior:

- User selects a preset size.
- The region follows the pointer.
- Click confirms the location.
- Export applies current screenshot style.

---

#### 6.1.7 Scroll Screenshot

Scroll screenshot is lower priority than normal screenshots.

Phase 1:

- Support browser scroll screenshot only.
- Chrome first.
- Safari second.

Phase 2:

- Try to support scrollable areas in other apps.

Risks:

- General scroll screenshots are fragile on macOS because apps implement scrollable views differently.
- Browser scroll capture is more realistic than universal app scroll capture.

---

## 7. Screenshot Export Style

### 7.1 Format

Default format:

- PNG.

Optional formats:

- JPG.
- HEIC.
- WebP later.

PNG remains default because it preserves sharp UI text, code, and interface lines better than lossy formats.

---

### 7.2 Rounded Corners

Default corner radius:

- 20 px.

Important terminology:

- This should be called **20 px corner radius**, not “20 degrees.” Image corner radius is measured in pixels, not degrees.

Default behavior:

- Browser content screenshot: rounded corners enabled.
- Window screenshot: rounded corners enabled.
- Manual region screenshot: rounded corners enabled by default.
- Full-screen screenshot: rounded corners disabled by default.

User setting:

- 0–40 px corner radius.
- 0 means no rounded corners.

---

### 7.3 Shadow

Default shadow:

- Soft shadow falling to lower-right.

Recommended default values:

- Blur radius: 22 px.
- Offset X: 8 px.
- Offset Y: 10 px.
- Opacity: 25%.
- Color: black.
- Spread: 0–2 px.

Requirements:

- Shadow should not be clipped.
- Export should add transparent padding around the image.
- Shadow should look smooth, not harsh or pixelated.
- User can disable shadow.

---

### 7.4 Export Canvas

To prevent the shadow from being clipped, the final PNG should include padding around the screenshot.

Default padding:

- 24 px.

Canvas modes:

- Transparent background.
- White background.
- Light gray background.
- Custom color.

Default:

- Transparent PNG.

---

### 7.5 Filename Rules

Default screenshot filename:

```text
wangShot_YYYY-MM-DD_HH-mm-ss.png
```

Default save directory:

```text
~/Pictures/wangShot/Screenshots
```

If the folder does not exist, wangShot should create it automatically.

---

## 8. Screenshot Selection UI

### 8.1 Overlay

When screenshot mode starts:

- Display a full-screen transparent overlay above all windows.
- Dim the background.
- Show the pointer as a crosshair.
- Allow drag selection.
- Highlight snapped windows or detected browser content area.
- Show width and height.

The overlay should be lightweight and fast.

---

### 8.2 Selection Indicator

Display:

```text
WIDTH × HEIGHT
```

Example:

```text
1280 × 720
```

The indicator should move with the selection but avoid covering the selected content too much.

---

### 8.3 Toolbar

Toolbar actions:

- Rectangle.
- Ellipse.
- Line.
- Arrow.
- Pencil.
- Mosaic.
- Text.
- Numbered marker.
- Highlight.
- OCR.
- Cancel.
- Save.
- Copy to clipboard.
- Confirm.

Toolbar requirements:

- Should appear after region selection.
- Should not block the selected area if avoidable.
- Should support keyboard shortcuts.
- Should use clear icons and visible hover states.

---

## 9. Annotation Editor

After capture, wangShot should not immediately save and exit. It should stay in an annotation/editor interface.

### 9.1 Required Tools

Required annotation tools:

1. Rectangle.
2. Ellipse.
3. Line.
4. Arrow.
5. Pencil/freehand.
6. Underline.
7. Text.
8. Numbered marker.
9. Mosaic/blur.
10. Highlight box.
11. Focus shadow.
12. Crop.
13. Undo.
14. Redo.
15. Save.
16. Save as.
17. Copy.
18. Cancel.

---

### 9.2 Arrow Tool

Requirements:

- Straight arrow.
- Optional curved arrow later.
- Adjustable color.
- Adjustable thickness.
- Adjustable arrowhead size.
- Anti-aliased rendering.
- Hold `Shift` to lock to common angles.

Default shortcut:

```text
4
```

---

### 9.3 Rectangle and Ellipse Tools

Requirements:

- Adjustable stroke color.
- Adjustable stroke width.
- Optional fill color.
- Optional transparent fill.
- Hold `Shift` to create square/circle.
- Support rounded rectangle later.

Default shortcuts:

```text
1 = rectangle
2 = ellipse
```

---

### 9.4 Line and Underline Tools

Requirements:

- Adjustable color.
- Adjustable thickness.
- Hold `Shift` for horizontal/vertical/45-degree lock.
- Underline mode should be optimized for marking text.

Default shortcut:

```text
3 = line
```

---

### 9.5 Text Tool

Requirements:

- Click to add text.
- Double-click to edit existing text.
- Drag to move text.
- Support font size.
- Support text color.
- Support background color.
- Support text border.
- Support optional text shadow.
- Use macOS system font by default.

Default text size:

```text
18 px
```

Default shortcut:

```text
7
```

---

### 9.6 Mosaic Tool

The mosaic tool is used to hide sensitive information.

Requirements:

- Rectangle mosaic mode.
- Brush mosaic mode later.
- Pixelate mode.
- Gaussian blur mode.
- Adjustable strength.
- Smooth edge transition.
- Sensitive information must become unreadable.

Default shortcut:

```text
6
```

Default behavior:

- Pixelated rectangle mosaic.
- Medium strength.

---

### 9.7 Highlight and Focus Shadow

The highlight tool should work like the screenshot example: the selected focus area remains clear, while the outside area becomes darkened.

Requirements:

- User draws a rectangle over the area to emphasize.
- Inside rectangle remains normal.
- Outside rectangle receives semi-transparent dark overlay.
- Border color can be adjusted.
- Overlay opacity can be adjusted.
- Corner radius can be adjusted.
- Highlight can be moved or resized after creation.

Default opacity:

```text
45%
```

Default shortcut:

```text
9
```

---

### 9.8 Numbered Markers

Requirements:

- Add circular numbered markers.
- Auto-increment from 1.
- Allow manual number editing.
- Allow color adjustment.
- Allow marker size adjustment.

Default shortcut:

```text
8
```

Use case:

- Step-by-step operation screenshots.
- Tutorial images.
- Report screenshots.

---

### 9.9 Undo and Redo

Requirements:

- Every annotation action should be undoable.
- Undo shortcut: `Command + Z`.
- Redo shortcut: `Shift + Command + Z`.
- Undo should include move, resize, color change, delete, and text edit operations.

---

### 9.10 Copy and Save

Actions:

- Copy final edited image to clipboard.
- Save final edited image to local path.
- Save as custom path.
- Cancel editing.
- Return to selection mode optional.

Copy shortcut:

```text
Command + C
```

Save shortcut:

```text
Command + S
```

Cancel shortcut:

```text
Esc
```

---

## 10. Pin to Screen

The user can pin a screenshot as a floating always-on-top window.

Requirements:

- Pin after capture.
- Resize pinned image.
- Move pinned image.
- Adjust opacity.
- Close pinned image.
- Copy pinned image.
- Save pinned image.

Use cases:

- Keep task instructions visible while coding.
- Keep an OCR result or screenshot reference visible.
- Compare UI states.

---

## 11. Screen Recording Module

### 11.1 Recording Modes

Required modes:

1. Full screen recording.
2. Selected area recording.
3. Window recording.
4. Browser content-area recording later.

Default format:

```text
mp4
```

Alternative format:

```text
mov
```

---

### 11.2 Audio Sources

The recording system should support:

1. No audio.
2. Microphone only.
3. System/computer audio only.
4. Microphone + system/computer audio.

Priority:

- Microphone recording must work.
- System audio should be attempted through native macOS capture APIs.
- If native system audio capture is unstable, allow fallback to a virtual audio device workflow.

Implementation note:

- System audio capture on macOS can be version-dependent.
- For personal use, a setup requiring a tool such as BlackHole can be acceptable as fallback, but it should not be the first implementation path.

---

### 11.3 Recording Controls

During recording, show a small floating controller.

Controls:

- Pause.
- Resume.
- Stop.
- Cancel.
- Mute microphone.
- Mute system audio.
- Timer.
- Optional file size estimate.

Default shortcuts:

```text
Start/stop recording: Control + W
Pause/resume: Control + P
Cancel: Esc
```

---

### 11.4 Recording Output

Default save path:

```text
~/Movies/wangShot/Recordings
```

Default filename:

```text
wangShot_recording_YYYY-MM-DD_HH-mm-ss.mp4
```

Post-recording actions:

- Save only.
- Reveal in Finder.
- Open file.
- Copy file path.

---

## 12. OCR Module

### 12.1 OCR Trigger Methods

OCR can be triggered by:

1. Global OCR shortcut.
2. Screenshot toolbar OCR button.
3. Annotation editor OCR button.
4. Opening an existing image and running OCR later.

Default shortcut:

```text
Control + O
```

---

### 12.2 OCR Workflow

Workflow:

1. User triggers OCR.
2. User selects screen region.
3. wangShot captures that region internally.
4. OCR engine extracts text.
5. OCR result panel appears.
6. User can copy, save, edit, or translate text.

---

### 12.3 OCR Output Panel

Panel actions:

- Copy text.
- Save as `.txt`.
- Translate.
- Edit manually.
- Clear.
- Close.

Display:

- Extracted text.
- Detected language if available.
- OCR confidence indicator optional.

---

### 12.4 OCR Languages

Target languages:

- English.
- Simplified Chinese.
- Traditional Chinese.
- Ukrainian.
- Russian.
- German.
- French.
- Spanish.
- Japanese.
- Korean.

Implementation priority:

1. English.
2. Chinese.
3. Ukrainian/Russian.
4. Other languages.

---

### 12.5 OCR Requirements

Acceptance criteria:

- English UI screenshots should be highly accurate.
- Chinese screenshots should be usable.
- Mixed-language screenshots should preserve reading order as much as possible.
- Code screenshots should preserve indentation where possible, but perfect code OCR is not required.
- OCR should run locally by default.

---

## 13. Image-to-Text Translation Module

### 13.1 Translation Workflow

Workflow:

1. User triggers Translate Screenshot.
2. User selects a screen region.
3. wangShot captures the region.
4. OCR extracts the original text.
5. Translation engine translates the text.
6. Original and translated text are shown together.
7. User can copy either original text or translation.

Default shortcut:

```text
Control + T
```

---

### 13.2 Translation Panel

The translation panel should show:

- Original text.
- Translated text.
- Source language.
- Target language.
- Copy original button.
- Copy translation button.
- Retry button.
- Change target language dropdown.
- Open in external translation website fallback.

---

### 13.3 Target Languages

Default target languages:

- English.
- Simplified Chinese.
- Ukrainian.
- Russian.

User should be able to set the default target language in settings.

---

### 13.4 Translation Engine Strategy

Preferred order:

1. Local/system translation engine if available.
2. External API only if manually configured.
3. Open translation website fallback.

Default:

- Local or system-level translation only.
- No automatic cloud translation unless user enables it.

Reason:

- The product is for personal use.
- Some screenshots may contain private information.
- Local-first behavior is safer.

---

## 14. Global Shortcuts

Global shortcuts should be customizable.

Recommended defaults:

```text
Screenshot: Control + A
Window screenshot: Control + Z
Previous area screenshot: Control + X
Delayed full screenshot: Control + D
Browser/content screenshot: Control + R
OCR: Control + O
Translate screenshot: Control + T
Start/stop screen recording: Control + W
Start audio recording: Control + E
Open pin library: Control + F
```

Annotation editor shortcuts:

```text
Rectangle: 1
Ellipse: 2
Line: 3
Arrow: 4
Pencil: 5
Mosaic: 6
Text: 7
Numbered marker: 8
Highlight: 9
OCR: O
Save: Command + S
Copy: Command + C
Undo: Command + Z
Redo: Shift + Command + Z
Cancel: Esc
Confirm: Enter
```

Shortcut conflict handling:

- If a shortcut conflicts with macOS or another app, wangShot should warn the user.
- User can reset shortcuts to defaults.

---

## 15. Settings

### 15.1 Screenshot Settings

Settings:

- Default save format.
- Default save path.
- Default image quality.
- Enable rounded corners.
- Corner radius.
- Enable shadow.
- Shadow blur.
- Shadow opacity.
- Shadow offset X.
- Shadow offset Y.
- Export canvas padding.
- Copy to clipboard after capture.
- Save after capture.
- Play sound after screenshot.
- Show crosshair.
- Show size indicator.
- Remember previous selection area.

---

### 15.2 Annotation Settings

Settings:

- Default arrow color.
- Default arrow thickness.
- Default text size.
- Default text color.
- Default mosaic strength.
- Default highlight opacity.
- Toolbar position.
- Toolbar response time.
- Auto-open editor after screenshot.
- Copy directly after confirmation.

---

### 15.3 Recording Settings

Settings:

- Default recording save path.
- Default video format.
- Frame rate: 30 fps or 60 fps.
- Audio source: none, mic, system, both.
- Show cursor.
- Show mouse clicks.
- Countdown before recording.
- Stop recording shortcut.
- Show floating controller.

---

### 15.4 OCR Settings

Settings:

- Default OCR language mode.
- Auto-detect language.
- Preserve line breaks.
- Cancel line breaks.
- Always save OCR result to clipboard.
- OCR result panel position.

---

### 15.5 Translation Settings

Settings:

- Default target language.
- Preferred translation engine.
- Local-only mode.
- Allow external translation API.
- Translation website fallback.

---

## 16. macOS Permissions

wangShot will require several permissions.

Required permissions:

1. Screen Recording permission.
2. Accessibility permission.
3. Microphone permission.
4. File/folder access permission.

Possible optional permission:

1. Input Monitoring permission, depending on shortcut implementation.

First-run permission checklist:

- Show status of each permission.
- Explain why each permission is needed.
- Provide button to open macOS System Settings.
- Detect when permission has been granted.
- Warn user when core functions cannot work without permission.

Permission explanations:

- Screen Recording: required for screenshot and recording.
- Accessibility: required for accurate window/browser content detection.
- Microphone: required for microphone audio recording.
- File access: required for saving screenshots, recordings, and OCR text.

---

## 17. Technical Architecture

### 17.1 Recommended Technology Stack

Language:

- Swift.

UI:

- SwiftUI for settings and simple panels.
- AppKit for overlay windows, menu-bar behavior, floating windows, and advanced macOS interaction.

Screen capture:

- ScreenCaptureKit.
- CoreGraphics.
- Quartz Window Services where needed.

Window/UI detection:

- Accessibility APIs.
- CoreGraphics window list APIs.

Image processing:

- CoreGraphics.
- Core Image.
- Metal optional later.

Recording:

- ScreenCaptureKit.
- AVFoundation.

OCR:

- Vision framework first.
- Tesseract optional fallback later.

Translation:

- Apple/system translation if available.
- External API optional only after manual configuration.

Settings storage:

- UserDefaults for simple settings.
- JSON config under Application Support if settings become more complex.

Local storage:

- File system.

Database:

- Not required for MVP.
- SQLite optional later for screenshot history.

---

### 17.2 App Components

Main components:

1. MenuBarController.
2. PermissionManager.
3. ShortcutManager.
4. ScreenshotOverlayWindow.
5. SelectionManager.
6. WindowDetectionService.
7. BrowserContentDetectionService.
8. CaptureService.
9. ImageExportService.
10. AnnotationEditor.
11. AnnotationObjectModel.
12. ClipboardService.
13. RecordingService.
14. AudioCaptureService.
15. OCRService.
16. TranslationService.
17. SettingsService.
18. FileStorageService.

---

### 17.3 Local File Structure

Default local folders:

```text
~/Pictures/wangShot/Screenshots
~/Movies/wangShot/Recordings
~/Documents/wangShot/OCR
~/Library/Application Support/wangShot
~/Library/Application Support/wangShot/Temp
```

Settings file optional:

```text
~/Library/Application Support/wangShot/settings.json
```

---

## 18. MVP Scope

### 18.1 MVP 1.0 Must Have

MVP must include:

1. Native macOS menu-bar app.
2. Global screenshot shortcut.
3. Manual region screenshot.
4. Full-screen overlay.
5. Region drag selection.
6. PNG export.
7. Save to local folder.
8. Copy to clipboard.
9. 20 px rounded-corner export.
10. Lower-right soft shadow.
11. Basic annotation editor.
12. Arrow annotation.
13. Rectangle annotation.
14. Text annotation.
15. Mosaic annotation.
16. Highlight/focus shadow annotation.
17. Undo/redo.
18. OCR on selected area.
19. Basic settings for save path and screenshot style.

---

### 18.2 MVP 1.0 Should Have

Should include if time allows:

1. Window screenshot.
2. Previous area screenshot.
3. Chrome browser content-area screenshot.
4. Pin to screen.
5. Translate OCR result.
6. Selected-area screen recording with microphone audio.

---

### 18.3 MVP 1.0 Could Have

Optional:

1. System audio recording.
2. Scroll screenshot.
3. Safari browser content detection.
4. Numbered markers.
5. Advanced mosaic brush.
6. Screenshot history.

---

## 19. Roadmap

### Phase 1: Project Foundation

Goals:

- Create native macOS app.
- Add menu-bar app shell.
- Add settings window skeleton.
- Add permission checklist.
- Add global shortcut manager.

Deliverable:

- User can open wangShot from the menu bar and trigger placeholder actions.

---

### Phase 2: Screenshot Overlay

Goals:

- Full-screen overlay.
- Manual region selection.
- Live size display.
- Cancel and confirm behavior.
- Store selected rectangle.

Deliverable:

- User can select a region and confirm it.
- App logs selected rectangle.

---

### Phase 3: Capture and Export

Goals:

- Capture selected screen region.
- Save PNG.
- Copy PNG to clipboard.
- Add save path.
- Add filename format.

Deliverable:

- User can capture and save a manual screenshot.

---

### Phase 4: Beautified Screenshot Rendering

Goals:

- Add rounded corners.
- Add transparent canvas padding.
- Add soft lower-right shadow.
- Add settings for radius and shadow.

Deliverable:

- User can export polished PNG screenshots similar to the reference screenshot style.

---

### Phase 5: Annotation Editor

Goals:

- Add annotation interface.
- Add rectangle, arrow, text, mosaic, and highlight.
- Add undo/redo.
- Add save/copy/cancel.

Deliverable:

- User can capture, annotate, copy, and save final image.

---

### Phase 6: Smart Selection

Goals:

- Add window detection.
- Add Chrome content-area detection.
- Add previous area screenshot.
- Add preset screenshot sizes.

Deliverable:

- User can quickly snap to windows and browser content areas.

---

### Phase 7: OCR

Goals:

- Add OCR selection mode.
- Add OCR result panel.
- Add copy/save text.
- Add language auto-detection if feasible.

Deliverable:

- User can select an image region and extract text.

---

### Phase 8: Translation

Goals:

- Add translation action after OCR.
- Add translation panel.
- Add default target language.
- Add local/system translation first.
- Add external website fallback.

Deliverable:

- User can translate screenshot text.

---

### Phase 9: Recording

Goals:

- Add selected-area recording.
- Add full-screen recording.
- Add microphone audio.
- Add system audio attempt.
- Add floating recording controller.
- Save MP4.

Deliverable:

- User can record screen demonstrations.

---

### Phase 10: Polish

Goals:

- Improve UI smoothness.
- Add pin to screen.
- Add scroll screenshot.
- Add screenshot history.
- Improve browser detection.
- Improve settings.

Deliverable:

- wangShot becomes reliable for daily personal use.

---

## 20. Risks and Constraints

### 20.1 Browser Content-Area Detection Risk

There is no universal macOS API that directly returns “browser webpage content area below toolbar” for every browser.

Mitigation:

- Start with Chrome.
- Use Accessibility APIs first.
- Add browser-specific heuristics.
- Add remembered user correction.
- Fall back to manual region selection.

---

### 20.2 System Audio Recording Risk

System audio recording on macOS can be difficult depending on macOS version, app permissions, and capture APIs.

Mitigation:

- Implement microphone recording first.
- Try native system audio capture through ScreenCaptureKit.
- Add fallback instructions for virtual audio device only if necessary.
- Keep this feature lower priority than screenshots.

---

### 20.3 Scroll Screenshot Risk

Universal scroll screenshot across all macOS apps is technically fragile.

Mitigation:

- Start with browser-only scroll capture.
- Do not block MVP on scroll screenshot.
- Add general app scroll capture only later.

---

### 20.4 OCR Accuracy Risk

OCR accuracy can vary by language, font size, screenshot quality, and text layout.

Mitigation:

- Use high-resolution internal captures.
- Allow manual editing of OCR result.
- Preserve original image for retry.
- Use local Vision OCR first.

---

### 20.5 Shortcut Conflict Risk

Global shortcuts may conflict with macOS or other apps.

Mitigation:

- Make all shortcuts customizable.
- Detect registration failures.
- Show warning if shortcut cannot be registered.

---

## 21. Acceptance Criteria

wangShot MVP is acceptable when:

1. Pressing a global shortcut opens screenshot selection mode.
2. User can drag a screenshot region.
3. User can confirm, cancel, save, or copy.
4. Saved output is PNG.
5. PNG export supports 20 px rounded corners.
6. PNG export supports soft lower-right shadow.
7. Shadow is not clipped.
8. User can annotate with arrows, rectangles, text, mosaic, and highlight.
9. User can undo and redo annotation changes.
10. User can copy final annotated image to clipboard.
11. User can save final annotated image locally.
12. User can run OCR on a selected area.
13. User can copy OCR result.
14. User can translate OCR result or open fallback translation.
15. App runs locally on the user's MacBook.
16. No account or cloud dependency is required for screenshots.

---

## 22. Suggested Development Workflow with Codex

Use GitHub and Codex in small tasks.

Recommended repository:

```text
github.com/XiaodiDennis/wangShot
```

Recommended folder:

```text
~/Developer/wangShot
```

Suggested first task for Codex:

```text
Read docs/PRD.md.

Do not implement the full app yet.

Create docs/TECHNICAL_PLAN.md for a native macOS Swift app.

Break the work into phases:
1. Menu-bar app shell
2. Screenshot overlay
3. Manual region selection
4. PNG export
5. Rounded corners and shadow
6. Annotation editor
7. OCR
8. Translation
9. Screen recording

Do not modify source code yet.
```

Implementation rule:

- One Codex task should modify one logical feature only.
- Commit after every working feature.
- Do not ask Codex to build the whole app in one prompt.
- Test in Xcode after each major change.
- Use branches for risky tasks.

---

## 23. Recommended Build Order

The best implementation order is:

1. Create native macOS app shell.
2. Add menu-bar icon.
3. Add screenshot shortcut.
4. Add full-screen overlay.
5. Add drag selection.
6. Add PNG capture.
7. Add save/copy.
8. Add rounded corners and shadow.
9. Add basic annotation editor.
10. Add OCR.
11. Add translation.
12. Add recording.
13. Add smart window/browser detection.

Do not start with recording or OCR. The screenshot overlay and image export pipeline are the foundation.

---

## 24. Final Product Principle

wangShot should not try to become a large commercial screenshot platform. It should be a private, fast, native, local-first macOS utility with excellent screenshot quality and enough automation to reduce daily friction.

The most important user experience is:

```text
Shortcut → smart selection → beautiful PNG → quick annotation → copy/save
```

Everything else should support that workflow.
