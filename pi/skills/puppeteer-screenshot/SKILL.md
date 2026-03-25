---
name: puppeteer-screenshot
description: Take screenshots of a locally running web app using Puppeteer. Use when you need to visually inspect a page, verify UI changes, or debug layout issues.
---

# Puppeteer Screenshot

Takes screenshots of a running local web app and displays them for visual inspection.

## Prerequisites

- The dev server must be running (e.g. `localhost:3000`). Check with `curl -s -o /dev/null -w '%{http_code}' <url>` first.
- Puppeteer must be available. If not installed in the project, install it as a dev dependency:
  ```bash
  cd <project-dir> && npm install --save-dev puppeteer
  ```
- Chrome must be available. Install if needed:
  ```bash
  npx puppeteer browsers install chrome
  ```

## Workflow

1. **Determine parameters** from the user's request:
   - `url` — the page to screenshot (default: `http://localhost:3000`)
   - `viewport` — width x height (default: 1440x900)
   - `fullPage` — whether to capture the full scrollable page (default: false)
   - `sections` — how many viewport-height chunks to capture when `fullPage` is false (default: auto-calculate based on page height)

2. **Write a temporary script** inside the project directory (so it can resolve the `puppeteer` dependency):

   ```js
   // <project-dir>/_pi-screenshot.mjs
   import puppeteer from 'puppeteer';

   const url = '<url>';
   const width = <width>;
   const height = <height>;

   const browser = await puppeteer.launch({ headless: true });
   const page = await browser.newPage();
   await page.setViewport({ width, height });
   await page.goto(url, { waitUntil: 'networkidle2', timeout: 15000 });

   // Get full page height
   const fullHeight = await page.evaluate(() => document.body.scrollHeight);
   const sections = Math.ceil(fullHeight / height);

   for (let i = 0; i < sections; i++) {
     await page.screenshot({
       path: `/tmp/pi-screenshot-${i}.png`,
       clip: { x: 0, y: i * height, width, height: Math.min(height, fullHeight - i * height) }
     });
   }

   await browser.close();
   console.log(JSON.stringify({ sections, fullHeight }));
   ```

3. **Run the script** from the project directory:
   ```bash
   cd <project-dir> && node _pi-screenshot.mjs
   ```

4. **Read each screenshot** using the `read` tool to display them:
   ```
   /tmp/pi-screenshot-0.png
   /tmp/pi-screenshot-1.png
   ...
   ```

5. **Clean up** the temporary files:
   ```bash
   rm <project-dir>/_pi-screenshot.mjs /tmp/pi-screenshot-*.png
   ```

## Notes

- Always run the script from inside the project directory so `import puppeteer` resolves correctly.
- If the page requires authentication or specific cookies, add setup steps before `page.goto`.
- For single-section screenshots (e.g. just the hero), use a `clip` parameter instead of full-page sectioning.
- The `waitUntil: 'networkidle2'` ensures async content has loaded. For SPAs with lazy loading, consider adding `await page.waitForSelector('<selector>')` before capturing.
- If the user asks to screenshot a specific section, scroll to it first with `await page.evaluate(() => document.querySelector('<selector>').scrollIntoView())`.
