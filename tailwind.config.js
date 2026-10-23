/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,tpl}",
    // The documentation pages are articles stored in the database: scan the seed too.
    "./schemas/**/*.sql",
    "./vendor/wbengine/wbengine/Box/**/*.{html,tpl}"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['ui-sans-serif', 'system-ui', '-apple-system', 'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', 'sans-serif'],
        mono: ['ui-monospace', 'SFMono-Regular', 'Menlo', 'Consolas', 'Liberation Mono', 'monospace'],
      },
    },
  },
  plugins: [],
}
