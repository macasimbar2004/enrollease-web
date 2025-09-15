# EnrollEase Web

A modern Flutter web application for enrollment management.

## UI Components

The application has been modernized with the following UI improvements:

### CustomAppBar

A responsive app bar that adapts to different screen sizes and includes:
- Logo display
- Page title
- User account settings
- Notification badge
- Menu toggle button for responsive views

Usage:
```dart
PreferredSize(
  preferredSize: const Size.fromHeight(80),
  child: CustomAppBar(
    title: 'Dashboard',
    notificationCount: 5,
    onNotificationTap: () {
      // Handle notification tap
    },
  ),
)
```

### CustomAppDrawer

A responsive drawer/side menu that shows:
- Application logo
- Navigation menu items
- Collapsible view for small screens

Usage:
```dart
// For mobile (drawer)
Scaffold(
  drawer: ResponsiveWidget.isSmallScreen(context) 
    ? const CustomAppDrawer() 
    : null,
  // ...
)

// For desktop/tablet (side menu)
Row(
  children: [
    if (!ResponsiveWidget.isSmallScreen(context))
      const SizedBox(
        width: 250,
        child: CustomAppDrawer(),
      ),
    // ...
  ]
)
```

### Other Modernized Components

- **Custom Form Fields**: Enhanced text fields with consistent styling
- **Custom Buttons**: Responsive buttons with overflow handling
- **Custom Cards**: Cards with proper elevation and smooth corners
- **Profile Picture**: Modern circular avatar display with proper sizing

## Responsive Design

The UI has been optimized to adapt to different screen sizes:
- **Mobile**: Uses a drawer for navigation and single column layout
- **Tablet**: Side menu with collapsible options and adaptive content
- **Desktop**: Full side menu with spacious content layout

## Example Usage

See `lib/examples/custom_appbar_example.dart` for a complete demonstration of how to use the new components together.

## Running the App

```
flutter pub get
flutter run -d chrome
```

## App Icon Generation

To generate app icons from the logo:

1. Ensure the logo is placed at the path specified in `flutter_launcher_icons.yaml`
2. Run:
```
flutter pub run flutter_launcher_icons
```
