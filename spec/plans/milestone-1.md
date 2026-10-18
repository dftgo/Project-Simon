# תוכנית Milestone 1 – הקמת הפרויקט, מעטפת האפליקציה ופריסה ראשונה

**מקורות:** `MILESTONES.md` (Milestone 1), `ARCHITECTURE.md` (סעיפים 1, 2.ב, 2.ו), `DESIGN.md` (סעיפים 1, 2), `mockups.png`, `wireframes.png`.

**מצב נוכחי:** ה-Repository המקומי מחובר ל-`https://github.com/dftgo/Project-Simon.git` (ענף `main`). בפרויקט יש רק `CLAUDE.md`, `.gitignore` ו-`spec/`. אין קוד.

**היקף:** מעטפת בלבד – שני מסכים, Header, רקע תת-ימי, ניווט ביניהם וכפתור `התחל` ללא פעולה. לוח המשחק, אזור המידע, צלילים, ניקוד ו-PWA – **לא** ב-Milestone הזה (אבל ה-Layout משאיר להם מקום).

---

## 1. קבצים ליצירה / שינוי

| קובץ | פעולה | תוכן |
|---|---|---|
| `index.html` | חדש | מעטפת RTL, Header, שני Views, SVG של הרקע, טעינת `css/style.css` ו-`js/app.js` (`type="module"`). |
| `css/style.css` | חדש | `@font-face`, משתני צבע, Layout, Header, כפתורים, מסך אודות, רקע. |
| `js/app.js` | חדש | נקודת כניסה: מאתחל את `ui.js` ומחבר את כפתורי הניווט. |
| `js/ui.js` | חדש | `showView('game' \| 'about')` – החלפת תצוגה. |
| `js/game.js` | חדש – שלד | Export ריק/קבועי התזמון בלבד (`TONE_DURATION_MS` וכו') + הערת TODO ל-Milestone 2. |
| `js/audio.js` | חדש – שלד | Exports ריקים (`init`, `toggleMute`, `stopAll`) ללא לוגיקה. |
| `js/storage.js` | חדש – שלד | Export ריק + שם המפתח `simon_game_data`. |
| `assets/fonts/*.woff2` | חדש | 12 קבצי גופן (ראו סעיף 3). |
| `serve.ps1` | חדש | שרת פיתוח מקומי (ראו סעיף 2). |
| `.claude/launch.json` | חדש | הגדרת הרצה ל-Browser pane (לבדיקות שלי בלבד): `powershell -ExecutionPolicy Bypass -File serve.ps1`, port 8080. |
| `CLAUDE.md` | עדכון | מילוי "פקודות הרצה": dev = `powershell -ExecutionPolicy Bypass -File serve.ps1` → `http://localhost:8080/`; test = אין. |
| `spec/MILESTONES.md` | עדכון | סימון 🟡 ליד כותרת Milestone 1 בסיום הבנייה. |
| `spec/ARCHITECTURE.md` | עדכון | הוספת סעיף `## החלטות מרכזיות (ADRs)` עם ADR-1 (מקור קבצי הגופנים – ראו סעיף 3). |

לא נדרשים `.env` או שינויים ב-`.gitignore` (אין build, אין סודות).
`manifest.json`, `sw.js` והאייקונים – ב-Milestone 5 בלבד.

---

## 2. שרת פיתוח – `serve.ps1`

- מבוסס `System.Net.HttpListener`, מאזין ל-`http://localhost:8080/` (לא דורש הרשאות מנהל).
- מגיש קבצים מהתיקייה שבה נמצא הסקריפט (`$PSScriptRoot`), כולל תמיכה בנתיב עם רווחים (`G:\My Drive\...`).
- `/` → `index.html`.
- טבלת MIME: `.html` → `text/html; charset=utf-8`, `.js` → `text/javascript; charset=utf-8`, `.css` → `text/css; charset=utf-8`, `.json` → `application/json`, `.svg` → `image/svg+xml`, `.png` → `image/png`, `.woff2` → `font/woff2`; אחר → `application/octet-stream`.
- הגנה מ-Path Traversal: נתיב שמחוץ לתיקיית הפרויקט מחזיר 403. קובץ שלא קיים → 404.
- כותרת `Cache-Control: no-store` (כדי שכל שינוי ייראה מיד בריענון).
- הודעה בהפעלה: `Serving on http://localhost:8080/ (Ctrl+C to stop)`. לולאה שרצה עד Ctrl+C, עם `try/finally` שסוגר את ה-Listener.

---

## 3. גופנים מקומיים

- **מקור ההורדה:** קבצי ה-`woff2` הסטטיים של Google Fonts כפי שהם מופצים בחבילות Fontsource דרך jsDelivr (למשל `https://cdn.jsdelivr.net/npm/@fontsource/rubik@5/files/rubik-hebrew-700-normal.woff2`). יתרון: קובץ נפרד ויציב לכל משקל ולכל תת-קבוצה, עם שמות קבועים. ההורדה מתבצעת **פעם אחת** בזמן הבנייה (`curl`), והקבצים נשמרים בפרויקט – האתר עצמו לא פונה לשום שרת חיצוני. מתועד כ-ADR-1.
- **הקבצים (12):**
  - Rubik 500 / 600 / 700 / 800 × `hebrew`, `latin` → `rubik-hebrew-500.woff2`, `rubik-latin-500.woff2`, ...
  - Assistant 400 / 600 × `hebrew`, `latin` → `assistant-hebrew-400.woff2`, ...
- **`@font-face`:** בלוק לכל קובץ, עם `font-display: swap`, `font-weight` מתאים ו-`unicode-range`:
  - Hebrew: `U+0307-0308, U+0590-05FF, U+200C-2010, U+20AA, U+25CC, U+FB1D-FB4F`
  - Latin: `U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD`
- נתיבים יחסיים לקובץ ה-CSS: `url('../assets/fonts/rubik-hebrew-700.woff2')`.
- אחרי ההורדה: בדיקה שכל קובץ קיים וגודלו סביר (לא דף שגיאה).

---

## 4. `index.html`

- `<!doctype html>`, `<html lang="he" dir="rtl">`.
- Meta: `charset=utf-8`, `viewport` = `width=device-width, initial-scale=1, viewport-fit=cover`, `theme-color` = `#34B6D8`, `<title>סיימון</title>`.
- `<link rel="stylesheet" href="./css/style.css">`, `<script type="module" src="./js/app.js"></script>`.
- **כל הנתיבים יחסיים (`./`).** אין שום קישור חיצוני.
- מבנה:

```html
<div class="app">
  <div class="bg" aria-hidden="true"> <!-- inline SVG: light rays, bubbles, fish --> </div>

  <main id="game-view" class="view">
    <header class="app-header">
      <h1 class="app-title">סיימון</h1>
      <div class="header-actions">
        <button id="mute-btn" class="icon-btn" aria-label="השתק"><!-- speaker SVG --></button>
        <button id="about-btn" class="btn-secondary">אודות</button>
      </div>
    </header>
    <div class="info-area"></div>      <!-- placeholder for Milestone 2 -->
    <div class="board-area"></div>     <!-- placeholder for Milestone 2 -->
    <div class="seabed" aria-hidden="true"><!-- inline SVG seabed --></div>
    <button id="start-btn" class="btn-primary">התחל <!-- ▶ icon --></button>
  </main>

  <section id="about-view" class="view" hidden>
    <header class="app-header"><h1 class="app-title">סיימון</h1></header>
    <h2 class="screen-title">אודות המשחק</h2>
    <p class="about-text">…</p>
    <div class="about-spacer"></div>   <!-- score card + history in Milestone 4 -->
    <button id="back-btn" class="btn-primary">חזרה למשחק</button>
  </section>
</div>
```

- סדר ב-DOM לפי RTL: הכותרת ראשונה (מופיעה מימין), הכפתורים אחריה (משמאל). בתוך `header-actions` – הרמקול לפני `אודות` (בתצוגת RTL `אודות` יוצא הכי שמאלי, כמו ב-Mockup).
- **טקסט פסקת ההסבר (מתוך `mockups.png`):** "צפו ברצף האורות והצלילים וחזרו עליו לפי הסדר. בכל שלב מתווסף צבע אחד לרצף – השלימו את כל 10 השלבים כדי לנצח!"
- כפתור `התחל` ב-Milestone 1 – פעיל חזותית (Primary) ללא Listener. כפתור הרמקול – ללא Listener, עם `aria-label="השתק"`.

---

## 5. `css/style.css`

**משתנים (`:root`)** – כל הצבעים מ-DESIGN.md 2.1, בשמות קבועים:
- Ocean Core: `--abyss-navy`, `--deep-ocean`, `--ocean-blue`, `--lagoon`, `--shallow-aqua`, `--sunlit-foam`.
- Game: `--color-blue` / `--color-blue-lit`, `--color-red` / `--color-red-lit`, `--color-yellow` / `--color-yellow-lit`, `--color-green` / `--color-green-lit` (מוגדרים כבר עכשיו, בשימוש מ-Milestone 2).
- Neutrals: `--ink`, `--slate`, `--mist`, `--pearl`.
- Status: `--status-listen-*`, `--status-turn-*`, `--status-win-*`, `--status-lose-*` (רקע/טקסט/מסגרת).
- Disabled: `--disabled-bg`, `--disabled-text`, `--disabled-border`.
- Background stops: חמשת צבעי ה-Gradient.
- `--font-heading: 'Rubik', sans-serif;` `--font-body: 'Assistant', sans-serif;`

**בסיס ומגע:**
- `*, *::before, *::after { box-sizing: border-box; }`, איפוס margin.
- `html, body { height: 100%; }`, `body { font-family: var(--font-body); color: var(--ink); background: <ocean gradient>; overflow: hidden; }`.
- `touch-action: manipulation; user-select: none; -webkit-user-select: none; -webkit-tap-highlight-color: transparent;` על `body` / כפתורים.
- `[hidden] { display: none !important; }`.

**Layout:**
- `.app`: עמודה אחת, `max-width: 480px`, ממורכזת (`margin-inline: auto`), `height: 100dvh` (עם fallback `100vh` לפניו), `position: relative`.
- `.view`: `display: flex; flex-direction: column; height: 100%; padding: 12px 20px` + `env(safe-area-inset-*)` בתחתית/למעלה, `gap` מסקאלת ה-4px.
- מסך הבית – סדר הגבהים: Header (64px, קבוע) → `info-area` (שומר מקום לשורת שלב + Pill: ~22+50px, קבוע) → `board-area` (`flex: 0 1 auto`, ריק כרגע; ב-M2 יקבל את הלוח) → `seabed` (`flex: 1 1 0; min-height: 0` – **הוא מתכווץ ראשון** ויכול להגיע ל-0) → כפתור `התחל` (62px, קבוע, צמוד לתחתית).
- בתוך `seabed` ה-SVG עם `preserveAspectRatio="xMidYMax slice"` כך שהחול נשאר בתחתית גם כשהגובה קטן.
- בדיקת עיקרון: ב-360×640 סכום הרכיבים הקבועים (~64+72+62+ריווחים) הוא ~260px, כך שגם בתוספת לוח ב-M2 (~2×130+14+28) המסך נכנס.
- מצב Landscape – ללא טיפול מיוחד (מותרת גלילה): `@media (orientation: landscape) { body { overflow: auto; } .app { height: auto; min-height: 100dvh; } }`.

**Header (`.app-header`):** רקע לבן 78%, `backdrop-filter: blur(8px)`, גובה 64px, רדיוס 20px, מסגרת 1px Mist, צל Soft כחלחל, `display:flex; justify-content: space-between; align-items:center; padding-inline: 16px`.
- `.app-title`: Rubik 800, 28px, טקסט Gradient `#1F8AC7` → `#0B3B5C` (`background-clip: text`).
- `.btn-secondary` (`אודות`): לבן, מסגרת 2px Ocean Blue, טקסט Deep Ocean, Rubik 600 16px, גובה 42px, רדיוס 14px, ריפוד אופקי 16px.
- `.icon-btn`: עיגול 42px, לבן, מסגרת 2px Mist, אייקון רמקול SVG בקו 2px מעוגל בצבע Deep Ocean (20px).

**כפתור ראשי (`.btn-primary`):** רוחב מלא, גובה 62px, רדיוס 18px, Gradient אנכי `#34B6D8` → `#1F8AC7` → `#135E96`, טקסט לבן Rubik 600 22px, צל כחול רך, `flex-shrink: 0`. ב-`התחל` – אייקון ▶ קטן (SVG) משמאל לטקסט. מצב `:disabled` מוגדר כבר עכשיו לפי צבעי Disabled (לשימוש ב-M2). `:active` – הקטנה קלה (`transform: scale(.98)`).

**מסך אודות:**
- `.screen-title`: Rubik 700 28/36px, Abyss Navy, מיושר לימין.
- `.about-text`: Assistant 400 16px/26px, Ink, על משטח לבן 70% עם רדיוס 20px וריפוד 16px.
- `.about-spacer`: `flex: 1` (שומר את `חזרה למשחק` בתחתית; ב-M4 יוחלף בכרטיס השיא וברשימה).

---

## 6. רקע ואיורים (Inline SVG)

ציור פשוט "בהשראת" ה-Mockups (לא העתק), עם צורות רכות וללא קווי מתאר חדים:

- **רקע כללי (`.bg`, `position: fixed` מאחורי הכול, `pointer-events: none`):**
  - Gradient המים מ-DESIGN 2.1 על ה-`body`.
  - 3–4 קרני אור אלכסוניות מלמעלה – פוליגונים לבנים בשקיפות 10–18% עם Gradient שנעלם כלפי מטה.
  - 5–7 בועות: עיגולים עם מילוי לבן 15%, מסגרת לבנה 60% והבהקה קטנה.
- **קרקעית (`.seabed`, מסך הבית בלבד):** SVG אחד עם `viewBox` רחב (~390×200):
  - חול – גל רך בצבע `#F3D9A4` → `#E8C68A`.
  - אצות ירוקות (2–3 גבעולים מעוקלים בגווני `#2E9E6E` / `#82E3B4`) בצד אחד.
  - אלמוג אדום מסתעף (`#E0533D`) ואלמוג מניפה צהוב (`#F2B63D`) בצד השני, צדף קטן וכוכב ים צהוב.
  - דגים: 2–3 דגים קטנים בגוני כחול (`#1F6FD1`, `#34B6D8`) ודג ליצן אחד (`#F28C3D` עם פסים לבנים).
- **מסך אודות:** רק דגים קטנים ובועות (בלי קרקעית) – SVG קטן ב-`position: absolute` ליד הכותרת, כמו ב-Mockup.
- כל ה-SVG עם `aria-hidden="true"`, מאחורי רכיבי הממשק (`z-index`), ולא מסתיר טקסט או כפתורים.

---

## 7. JavaScript

- **`app.js`:**
  ```js
  import { initUI, showView } from './ui.js';
  // On DOMContentLoaded: initUI(); about-btn → showView('about'); back-btn → showView('game').
  ```
  (מודולים נטענים כ-`defer` ממילא; מספיק להריץ ישירות.) רישום Service Worker – לא עכשיו (Milestone 5).
- **`ui.js`:** `initUI()` שומר הפניות לאלמנטים; `showView(name)` מחליף `hidden` בין `#game-view` ל-`#about-view` ומגלגל לראש המסך. אין טעינה מחדש ואין שינוי URL.
- **שלדים:** `game.js`, `audio.js`, `storage.js` – הערה באנגלית שמתארת את תפקיד המודול ואת ה-Milestone שבו ימומש, וה-exports הבסיסיים (ללא לוגיקה), כך שה-imports של ה-Milestones הבאים לא ישברו.
- הערות בקוד – באנגלית בלבד.

---

## 8. בדיקות שאריץ בעצמי בזמן הבנייה

הרצה דרך `serve.ps1` ב-Browser pane (ואחר כך סגירה):
1. הדף נטען ב-`http://localhost:8080/` ללא שגיאות ב-Console.
2. כל קבצי JS / CSS / woff2 נטענים בסטטוס 200 עם MIME נכון; **אין** אף בקשה לשרת חיצוני (בדיקה ב-Network).
3. `document.fonts` – Rubik ו-Assistant נטענו (`document.fonts.check('700 28px Rubik')` וכו').
4. גודל 390×845 ו-360×640: `document.documentElement.scrollHeight <= innerHeight` במסך הבית, וצילום מסך להשוואה מול `mockups.png`.
5. לחיצה על `אודות` → מסך אודות; `חזרה למשחק` → מסך הבית; בלי ריענון (בדיקה שמשתנה גלובלי שהוצב לפני הלחיצה עדיין קיים).
6. סריקה (grep) שאין נתיבים מוחלטים (`href="/`, `src="/`, `url(/`) ואין `googleapis` / `gstatic` בקוד.

---

## 9. פריסה ל-GitHub Pages (אחרי אישורך)

לפי CLAUDE.md, הבנייה **לא** כוללת commit/push. לכן שלושת תנאי ה-DoD שקשורים לאתר החי ייבדקו רק אחרי שתבקש "דחוף שינויים לגיטהאב":
1. אני מבצע commit + push ל-`main` (ה-remote כבר מחובר).
2. אני מדריך אותך צעד אחר צעד: GitHub → `Settings` → `Pages` → `Source: Deploy from a branch` → `main` / `(root)` → `Save`.
3. אחרי דקה-שתיים אני בודק את `https://dftgo.github.io/Project-Simon/` (טעינה, Console, גופנים) ומדווח.

---

## 10. Definition of Done – איך כל תנאי ייבדק

| תנאי | איך נבדק | מתי |
|---|---|---|
| Repository עם מבנה התיקיות | השוואת הקבצים מול ARCHITECTURE 2.ו (ללא קבצי M5) | בנייה + אחרי push |
| האתר נטען בכתובת החיה ללא שגיאות Console | פתיחת הכתובת החיה ובדיקת Console | אחרי push |
| כל הנתיבים יחסיים | grep בקוד | בנייה |
| RTL, עברית, גופנים מקומיים | `dir`/`lang`, `document.fonts`, Network ללא Google Fonts | בנייה + אחרי push |
| `serve.ps1` + פקודה ב-CLAUDE.md | הרצה מקומית + קריאת CLAUDE.md | בנייה |
| Header וצבעים תואמים למוקאפ | צילומי מסך מול `mockups.png` | בנייה |
| ללא גלילה ב-390×845 וב-360×640 | בדיקת `scrollHeight` בשני הגדלים | בנייה |
| ניווט אודות ↔ בית ללא טעינה מחדש | לחיצות + בדיקת משתנה גלובלי | בנייה |

---

## 11. החלטות פתוחות / הנחות

- **טקסט פסקת ההסבר** נלקח מה-Mockup (ה-PRD מגדיר רק "פסקת הסבר קצרה"). אם תרצה ניסוח אחר – אעדכן.
- **מקור קבצי הגופנים** (Fontsource דרך jsDelivr, הורדה חד-פעמית) – החלטה טכנית, תתועד כ-ADR-1. הקבצים זהים לאלה של Google Fonts.
- אזור המידע ולוח המשחק נשארים ריקים ב-Milestone הזה (כמו שהוגדר ב-MILESTONES), כך שמסך הבית ייראה "ריק" באמצע עד Milestone 2.
