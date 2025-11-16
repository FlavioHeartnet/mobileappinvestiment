
---
description: Perform a convertion of HTML design files into Flutter screen widgets and integrate them into the app's navigation.
---
## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).
## Outline

perform the following steps:
step 1: Identify the HTML design file to be converted (e.g., signup.html, checkout.html). User may specify which file to convert via input arguments. If no argument is provided, search in 'specs/001-project-retirement-returns/html/' for the most recently modified HTML file and use that.
step 2: Analyze the HTML structure and styles to understand the layout and components used.
step 3: Create a new Flutter screen widget that replicates the HTML layout using appropriate Flutter widgets (e.g., Scaffold, Container, Text, Image, Button).
step 4: Apply styles to the Flutter widgets to match the design (e.g., colors, fonts, spacing).
step 5: Place the new Flutter screen widget in the 'screens' folder of the project.
step 6: Update the main.dart file to include a route for the new screen, ensuring it can be navigated to from other parts of the app.
## Goal

have a fully functional Flutter screen that mirrors the provided HTML design, integrated into the app's navigation structure.