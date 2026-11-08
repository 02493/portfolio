# Andrey Tokarev — Portfolio OS

Android-inspired personal portfolio built with Flutter Web.

## Requirements

- Flutter SDK (stable channel)
- Google Chrome or another modern browser
- Git

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

## Build for GitHub Pages

The repository is expected to be named `portfolio` under `02493`.

```bash
flutter build web --release --base-href "/portfolio/"
```

The GitHub Actions workflow in `.github/workflows/deploy.yml` builds and deploys the site automatically when you push to `main`.

After deployment, the site will be available at:

https://02493.github.io/portfolio/

## Publish

1. Create a public GitHub repository named `portfolio`.
2. Upload this project to the repository root and push to `main`.
3. Open **Settings → Pages**.
4. Set **Build and deployment → Source** to **GitHub Actions**.
5. Open the **Actions** tab and wait for `Deploy Flutter Web to GitHub Pages` to finish.

## Personalize

Edit `lib/main.dart`:
- Update the About Me description.
- Add or remove app icons in the `items` list.
- Add project cards and real repository/demo URLs.
- Update social links in `_openItem` and `_Dock`.

LinkedIn, Google Play and RuStore are placeholders until you provide your exact profile or app links.
