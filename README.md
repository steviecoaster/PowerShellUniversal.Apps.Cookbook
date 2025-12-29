# PowerShell Universal Cookbook App

A lightweight, single-repository cookbook application built for PowerShell Universal (PSU).
This app provides a simple recipe manager you can run inside PowerShell Universal Dashboards or as a reusable module. It includes features for adding and editing recipes, marking favorites, organizing recipes with tags (categories), and browsing/printing recipes.

## Key features

- Add, edit and save recipes (title, ingredients, steps, images, tags)
- Mark recipes as favorites and toggle favorites
- Browse recipes by tags (categories) or recent/favorite lists
- Print-friendly recipe view
- SQLite-based storage with schema and migration support (in `App/data/Schema.sql`)

## Quick start

Requirements

- PowerShell 7+ (pwsh)
- PowerShell Universal (PSU) with Dashboards enabled
- SQLite3 for recipe database

Install and run inside PowerShell Universal

1. From within PowerShell Universal navigate to Platform -> Gallery
2. Search for PowerShellUniversal.Apps.Cookbook
3. Click the `Install` button.
4. Navigate to Apps -> Apps, and you'll see 'Recipe Manager'
5. Click the Browse (globe) button to open the cookbook app.

Usage

- Open the dashboard URL provided by PSU. The app contains pages for Home, Browse, Recipe, and Print.
- Use the UI to add a new recipe, add ingredients and steps, and attach an image.
- Tag recipes with one or more tags to enable category browsing.
- Toggle favorites using the star/favorite controls; favorites are stored in the recipe DB.

## Developer notes

- The app uses a single-file SQLite database stored in the cookbook data folder. Schema and migrations live in `App/data`.
- When adding features, prefer small scripts in `App/public` for discoverability and reuse by the dashboard pages.
- The dashboards are implemented using the PowerShell Universal Dashboards idioms; inspect `App/dashboards/Cookbook/Cookbook.ps1` to see how routes and pages are wired up.
- For image storage, images are saved to a dedicated image folder returned by `Get-RecipeImageFolder.ps1` and served via `Invoke-RecipeImageEndpoint.ps1`.
- Conversion helpers (ingredient/step/tag text) live in `App/public` and are intended to make copy/paste import easier.

## Tests and validation

There aren't automated tests included in this repository. To validate changes manually:

1. Start PowerShell Universal with the app loaded.
2. Use the dashboard UI to add/edit recipes and verify persistence in the SQLite DB.
3. Inspect image handling by adding a recipe image and verifying the served image endpoint.

You can use `testproject.ps1` from the App folder to load the project into PSU locally for testing.

## Contributing

Pull requests welcome. When contributing:

- Add small, focused changes with unit-friendly functions where possible.
- Update or add migration SQL in `App/data` when the DB schema changes.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Contact / Support

Open an issue in the repository for bugs, feature requests, or questions about running the app with PowerShell Universal.
