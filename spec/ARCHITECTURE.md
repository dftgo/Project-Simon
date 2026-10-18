# מסמך ארכיטקטורה טכנית (ARCHITECTURE.md) – משחק הזיכרון "סיימון" (Simon)

---

## 1. Technology Stack שנבחר

בהתאם לדרישות ה-PRD, המערכת היא אפליקציית Web קלת-משקל המבוססת על **Frontend בלבד** (ללא Backend וללא Database), מותאמת למובייל (Mobile-First, Portrait), בעברית מלאה (RTL), עם יכולות PWA ושמירת נתונים מקומית ב-`localStorage`.

לצורך כך נבחר Stack מינימליסטי, בשל ונטול תלויות חיצוניות (Zero Dependencies), המבוסס על סטנדרטים רשמיים של הדפדפן (Vanilla Web Standards).

### א. טבלת רכיבים וטכנולוגיות

| רכיב (Layer / Component) | טכנולוגיה נבחרת | תפקיד במערכת |
| :--- | :--- | :--- |
| **Core Markup & Structure** | **HTML5 (Semantic, RTL)** | מבנה האפליקציה (Single-Page Application עם שני Views: מסך המשחק ומסך אודות), הגדרת `dir="rtl"` ו-`lang="he"`, ותגיות Meta להתאמה למובייל. |
| **Styling & Layout** | **Vanilla CSS3 (CSS Grid, Flexbox, Custom Properties)** | עיצוב Mobile-First נעול לתצוגת מובייל אנכית (`100dvh`), אנימציות הארה לכפתורי הצבעים, משוב ויזואלי ללחיצות ופריסת רשת 2x2 לכפתורי המשחק. |
| **Application Logic & State** | **Vanilla JavaScript (ES6+ Modules)** | ניהול מנוע המשחק (Game Loop), הגרלת הרצפים, ניהול תורים (מערכת/שחקן), בדיקת תקינות הלחיצות, מעבר בין מסכים וניהול המצב בזיכרון. |
| **Audio Engine** | **Web Audio API (Native Browser API)** | סינתזה דינמית של 4 צלילי הצבעים וצלילי ניצחון/הפסד בזמן אמת ישירות בדפדפן, ללא צורך בטעינת קבצי אודיו חיצוניים (`mp3`/`wav`). |
| **Client-Side Storage** | **Web Storage API (`window.localStorage`)** | שמירה מקומית מתמשכת (Persistent) של השיא האישי ושל היסטוריית 10 המשחקים האחרונים בדפדפן המכשיר. |
| **PWA & Offline Support** | **Web App Manifest + Service Worker API** | אפשרות התקנת המשחק על מסך הבית בנייד (`Add to Home Screen`), הרצה בחלון עצמאי (`standalone`) ושמירת קבצי האפליקציה ב-Cache לטעינה מיידית ועבודה Offline. |
| **Source Control** | **Git & GitHub** | ניהול קוד המקור ב-Repository מרכזי ב-GitHub. |
| **Hosting & CI/CD** | **GitHub Pages (via GitHub Actions / Branch Deploy)** | אירוח חינמי, מהיר ומאובטח (HTTPS) של קבצי האתר הסטטיים עם פריסה אוטומטית בכל `push` לענף הראשי (`main`). |

---

### ב. נימוקים להחלטות הטכנולוגיות המרכזיות

1. **בחירה ב-Vanilla HTML/CSS/JS על פני Frameworks (כגון React או Vue):**
   * **התאמה להיקף המוצר:** האפליקציה כוללת שני מסכים בלבד ולוגיקת משחק ממוקדת. שימוש ב-Framework חיצוני יוסיף שכבת Build מיותרת (`npm`, `node_modules`, Bundlers) ותקורת ביצועים שאין בה צורך.
   * **קלות תפעול ותחזוקה:** הקוד רץ ישירות בכל דפדפן ללא שלב קומפילציה, לא מתיישן עקב עדכוני ספריות צד-שלישי, ומאפשר פריסה מיידית ל-GitHub Pages של הקבצים כפי שהם.
   * **התאמה לפיתוח מבוסס AI:** מודלי שפה וכלי פיתוח AI מצטיינים בכתיבת Vanilla JS/CSS תקני, קריא ומודולרי ללא שגיאות תאימות בין גרסאות ספריות.

2. **בחירה ב-Web Audio API על פני קבצי שמע חיצוניים:**
   * **אפס השהיה (Zero Latency):** במשחק "סיימון", סנכרון מיידי בין הלחיצה/הארה לבין הצליל הוא קריטי לחוויית המשתמש. הפקת גלי קול באמצעות `OscillatorNode` ו-`GainNode` מתבצעת בזמן אמת ללא תלות בטעינת רשת או פענוח קבצים.
   * **עמידות מלאה במצב Offline (PWA):** אין צורך לנהל ולשמור קבצי מדיה ב-Cache, מה שמקטין את משקל האפליקציה לקילובייטים בודדים.

3. **בחירה ב-GitHub Pages לאירוח (Hosting):**
   * האפליקציה היא Client-Side בלבד ודורשת HTTPS (תנאי הכרחי להפעלת Service Workers ב-PWA). שירות GitHub Pages מספק אירוח סטטי אמין, חינמי לחלוטין, כולל תעודת SSL מובנית ופריסה אוטומטית מתוך ה-Repository ב-GitHub.

---

### ג. סיכונים, מגבלות והסתייגויות טכנולוגיות

1. **מדיניות חסימת שמע במובייל (Mobile Browser Autoplay Policy):**
   * **המגבלה:** דפדפני Safari (iOS) ו-Chrome (Android) חוסמים יצירה או השמעה של `AudioContext` לפני אינטראקציית משתמש מפורשת (User Gesture). בנוסף, במכשירי iOS, מתג ההשתקה הפיזי במכשיר (Silent Mode) משתיק Web Audio.
   * **הפתרון הארכיטקטוני:** אתחול ופתיחת ה-`AudioContext` (`audioCtx.resume()`) יבוצעו **בתוך ה-Event Listener של כפתור `"התחל"`**. כמו כן, משוב האורות הוויזואלי יהיה חד וברור כך שהמשחק שחיק לחלוטין גם ללא קול.

2. **מגבלות `localStorage` ומחיקת נתונים:**
   * **המגבלה:** הנתונים נשמרים מקומית בדפדפן הספציפי במכשיר. ניקוי נתוני גלישה על ידי המשתמש או גלישה במצב Incognito/Private ימחקו את ההיסטוריה או יחסמו גישה ל-`localStorage`. בנוסף, ב-iOS קיימת הפרדה בין ה-`localStorage` של הדפדפן הרגיל לבין ה-PWA המותקן על מסך הבית.
   * **הפתרון הארכיטקטוני:** עטיפת כל הקריאות ל-`localStorage` בבלוק `try / catch` כדי להבטיח שהמשחק ימשיך לפעול באופן תקין (In-Memory) גם אם האחסון המקומי חסום.

3. **ניהול נתיבים יחסיים ב-GitHub Pages (Subpath Routing):**
   * **המגבלה:** אתרים ב-GitHub Pages מתארחים לרוב תחת תת-נתיב (`https://<username>.github.io/<repo-name>/`). שימוש בנתיבים מוחלטים (כגון `/sw.js`) ישבור את טעינת ה-PWA.
   * **הפתרון הארכיטקטוני:** כל הנתיבים בקוד, בקובץ ה-`manifest.json` וב-Service Worker יוגדרו כנתיבים יחסיים (`./manifest.json`, `./sw.js`, `"start_url": "./"`, `"scope": "./"`).

---

## 2. ארכיטקטורת המערכת

### א. מבנה המערכת ורכיבים מרכזיים

המערכת בנויה בארכיטקטורת **Modular Single-Page Application (SPA)** הרצה במלואה בדפדפן הלקוח. מעבר בין מסך הבית (המשחק) למסך "אודות" מתבצע באמצעות החלפת תצוגה (DOM View Toggling) ללא טעינה מחדש של הדף.

```text
+-------------------------------------------------------------------+
|                        Browser / PWA Shell                        |
|  (index.html, style.css, manifest.json, Service Worker - sw.js)   |
+-------------------------------------------------------------------+
                                  |
                                  v
+-------------------------------------------------------------------+
|                     UI Controller (ui.js)                         |
|  - DOM Manipulation & View Switching (Game View <-> About View)   |
|  - Button Illumination, Status Messages, Touch Event Listeners    |
+-------------------------------------------------------------------+
          |                               |                       |
          v                               v                       v
+-----------------------+   +---------------------------+   +-------------------+
|  Game Engine (game.js)|   | Audio Synthesizer         |   | Storage Manager   |
|  - State Machine      |   | (audio.js)                |   | (storage.js)      |
|  - Sequence Generator |   | - Web Audio API Context   |   | - High Score      |
|  - Step & Input Check |   | - Color Tones & SFX       |   | - Last 10 Games   |
|  - Timing Controller  |   | - Mute State Management   |   | - Safe Try/Catch  |
+-----------------------+   +---------------------------+   +-------------------+
```

---

### ב. חלוקה ל-Modules ושכבות לוגיות

הקוד יאורגן במבנה שטוח, נקי ומודולרי (ES Modules):

1. **`index.html` (Application Shell & Views):**
   * מכיל את מעטפת המסמך (`<html lang="he" dir="rtl">`), קישור ל-`manifest.json`, ורישום ה-Service Worker.
   * מכיל שני מיכלים ראשיים (`<main id="game-view">` ו-`<section id="about-view" hidden>`) המייצגים את שני המסכים של האפליקציה.

2. **`css/style.css` (Presentation & Mobile Layout Layer):**
   * מגדיר עיצוב Mobile-First מותאם לאחיזה אנכית (`max-width: 480px` ממורכז במסכים רחבים יותר, גובה `100dvh` עם `overflow: hidden` במסך המשחק למניעת גלילה).
   * מגדיר משתני CSS לצבעי המשחק במצב רגיל ובמצב מואר (`--color-red`, `--color-red-active` וכו') ואפקטי תאורה (`filter: brightness()`, `box-shadow`).
   * מונע התנהגויות ברירת מחדל מפריעות במובייל במהלך לחיצות מהירות (`touch-action: manipulation`, `user-select: none`, `-webkit-tap-highlight-color: transparent`).

3. **`js/app.js` (Main Entry Point & Coordinator):**
   * מאתחל את המודולים בעת טעינת הדף (`DOMContentLoaded`).
   * מחבר בין אירועי המשתמש ב-UI לבין מנוע המשחק, מערכת השמע ומנהל האחסון.
   * רושם את ה-Service Worker (`./sw.js`).

4. **`js/game.js` (Game Engine & State Machine):**
   * מנהל את מצב המשחק הנוכחי (In-Memory State בלבד – מתאפס בריפרש או במעבר למסך אודות).
   * אחראי על הגרלת הצבעים האקראית (`Math.floor(Math.random() * 4)`), ניהול מערך הרצף (עד 10 איברים), השמעת הרצף בקצב קבוע, ובדיקת הלחיצות של המשתמש אינדקס אחר אינדקס.

5. **`js/audio.js` (Web Audio Synthesizer):**
   * עוטף את ה-`AudioContext` של הדפדפן.
   * מספק פונקציות להשמעת צליל לפי צבע (`playColorTone(color, duration)`), צליל ניצחון (`playWinSound()`), צליל הפסד (`playLoseSound()`), וניהול מצב השתקה (`isMuted`).
   * **תדרים מוגדרים ל-4 הצבעים (הרמוניה קלאסית ברורה להבחנה שמיעתית):**
     * ירוק (`green`): `329.63 Hz` (תו E4)
     * אדום (`red`): `261.63 Hz` (תו C4)
     * צהוב (`yellow`): `220.00 Hz` (תו A3)
     * כחול (`blue`): `164.81 Hz` (תו E3)

6. **`js/storage.js` (Local Storage Manager):**
   * אחראי בלעדית על קריאה וכתיבה ל-`window.localStorage`.
   * שומר תוצאת משחק חדש, מעדכן את השיא האישי במידת הצורך, וחותך את רשימת ההיסטוריה ל-10 המשחקים האחרונים בלבד.

7. **`js/ui.js` (DOM & View Manager):**
   * מעדכן את אלמנטי ה-DOM: הדלקה וכיבוי של כפתורי הצבעים, עדכון טקסט השלב (`"שלב X מתוך 10"`), עדכון הודעות הסטטוס (`"הקשב לרצף..."`, `"תורך!"` וכו'), נעילה ופתיחה של כפתורי הצבעים ללחיצה, ורינדור טבלת ההיסטוריה במסך "אודות".

8. **`manifest.json` & `sw.js` (PWA Layer):**
   * `manifest.json`: מגדיר את שם האפליקציה (`"סיימון - משחק זיכרון"`), כיווניות (`"dir": "rtl"`, `"lang": "he"`), תצוגה (`"display": "standalone"`), נעילת כיוון (`"orientation": "portrait"`) ואייקונים.
   * `sw.js`: שומר ב-Cache את כל קבצי ה-App Shell (`index.html`, `style.css`, קבצי ה-JS והאייקונים) באסטרטגיית **Cache-First**, כך שהמשחק נטען מיידית ופועל גם ללא חיבור לאינטרנט.

---

### ג. Data Model ומבנה האחסון

המערכת מפרידה בין **נתונים זמניים בזיכרון (In-Memory Game State)** שנמחקים בכל רענון דף או מעבר למסך אודות, לבין **נתונים מתמשכים (Persistent Storage)** הנשמרים ב-`localStorage`.

#### 1. מודל מצב המשחק הזמני (In-Memory State ב-`game.js`)

```javascript
const gameState = {
  status: 'IDLE',          // 'IDLE' | 'PLAYING_SEQUENCE' | 'WAITING_FOR_INPUT' | 'WON' | 'GAME_OVER'
  currentLevel: 0,         // מספר השלב הנוכחי (1 עד 10 בזמן משחק)
  sequence: [],            // מערך הצבעים שהוגרלו עד כה, לדוגמה: ['red', 'blue', 'yellow']
  playerStepIndex: 0,      // האינדקס הנוכחי ברצף שעל השחקן ללחוץ עליו כעת
  isMuted: false           // האם הצלילים מושתקים
};
```

**קבועי תזמון (Timing Constants – קצב קבוע לאורך כל 10 השלבים):**
* `TONE_DURATION_MS = 500`: משך הארת הכפתור והשמעת הצליל של כל צבע ברצף.
* `SEQUENCE_GAP_MS = 250`: הפסקה שקטה בין צבע לצבע בזמן השמעת הרצף.
* `NEXT_LEVEL_DELAY_MS = 800`: השהיה מרגע שהשחקן השלים שלב בהצלחה ועד לתחילת השמעת הרצף של השלב הבא.

#### 2. מודל הנתונים ב-Local Storage (מנוהל ב-`storage.js`)

הנתונים נשמרים תחת מפתח יחיד ב-`localStorage` בשם `simon_game_data` כמחרוזת JSON:

```json
{
  "highScore": 7,
  "history": [
    {
      "score": 7,
      "timestamp": "18/10/2026 17:45"
    },
    {
      "score": 3,
      "timestamp": "18/10/2026 17:40"
    }
  ]
}
```

**חוקי עבודה עם המודל:**
* `score`: מספר שלם בין `0` ל-`10` המייצג את מספר השלבים שהושלמו במלואם (לדוגמה: כישלון בשלב 1 = ציון `0`; כישלון בשלב 5 = ציון `4`; ניצחון בשלב 10 = ציון `10`).
* `highScore`: מתעדכן באמצעות `Math.max(currentHighScore, newScore)`.
* `history`: מערך של עד 10 אובייקטים. כל משחק חדש שמסתיים (בניצחון או בהפסד) מוכנס לראש המערך (`unshift`), והמערך נחתך לאורך מקסימלי של 10 איברים (`slice(0, 10)`).

---

### ד. Data Flow וניהול מחזור חיי המשחק (State Machine)

#### 1. התחלת משחק ותור המערכת
1. המשתמש לוחץ על כפתור `"התחל"`.
2. `app.js` מפעיל את `audio.init()` (פתיחת `AudioContext` כחלק מאירוע הלחיצה).
3. `game.startNewGame()` מאפס את `sequence = []`, מגדיר `currentLevel = 1`, ומגריל צבע אקראי ראשון.
4. הסטטוס עובר ל-`PLAYING_SEQUENCE`:
   * כפתורי הצבעים נחסמים לקלט משתמש (`pointer-events: none` / בדיקת סטטוס בקוד).
   * מוצג הטקסט `"שלב 1 מתוך 10"` וסטטוס `"הקשב לרצף..."`.
   * לולאה אסינכרונית מנגנת כל צבע במערך `sequence` במשך `500ms` (הארת הכפתור ב-UI + השמעת התדר ב-Audio) עם רווח של `250ms` בין צבע לצבע.
5. בסיום ניגון הרצף, הסטטוס עובר ל-`WAITING_FOR_INPUT`, `playerStepIndex` מתאפס ל-`0`, מוצג הטקסט `"תורך!"` והכפתורים נפתחים ללחיצה.

#### 2. תור השחקן ובדיקת הלחיצות
1. השחקן לוחץ על אחד מ-4 כפתורי הצבעים.
2. אם הסטטוס אינו `WAITING_FOR_INPUT`, הלחיצה מתעלמת מיד (מונע לחיצות כפולות או לחיצות בזמן תור המערכת).
3. הכפתור מואר ומשמיע את הצליל שלו למשוב מיידי.
4. המערכת משווה את הצבע שנלחץ ל-`sequence[playerStepIndex]`:
   * **במקרה של התאמה (לחיצה נכונה):**
     * `playerStepIndex` עולה ב-1.
     * אם `playerStepIndex < sequence.length`: המערכת ממתינה ללחיצה הבאה באותו שלב.
     * אם `playerStepIndex === sequence.length` (השלב הושלם במלואו):
       * הקלט ננעל מיד.
       * **אם `currentLevel === 10`:** מעבר למצב ניצחון (`WON`).
       * **אם `currentLevel < 10`:** `currentLevel` עולה ב-1, מתווסף צבע אקראי חדש ל-`sequence`, ולאחר השהיה של `800ms` מופעל תור המערכת לשלב הבא.
   * **במקרה של אי-התאמה (טעות ראשונה):**
     * הקלט ננעל מיד והמשחק עובר למצב הפסד (`GAME_OVER`).

#### 3. סיום משחק (ניצחון או הפסד)
* **בניצחון (`WON`):**
  1. מושמע צליל ניצחון (`audio.playWinSound()`).
  2. מוצגת ההודעה: `"כל הכבוד! ניצחת את המשחק!"`.
  3. נשמר ציון `10` באמצעות `storage.saveGameResult(10)`.
  4. כפתור `"התחל"` הופך לזמין למשחק חדש.
* **בהפסד (`GAME_OVER`):**
  1. מושמע צליל כישלון (`audio.playLoseSound()`).
  2. מוצגת ההודעה: `"אופס, טעית! הגעת לשלב X"` (כאשר `X` הוא `currentLevel`).
  3. מחושב הציון בתור `completedLevels = currentLevel - 1` (מספר השלבים שהושלמו בהצלחה) ונשמר באמצעות `storage.saveGameResult(completedLevels)`.
  4. כפתור `"התחל"` הופך לזמין למשחק חדש.

#### 4. מעבר למסך "אודות" או ריפרש באמצע משחק
* אם המשתמש לוחץ על `"אודות"` בזמן שמשחק פעיל (`PLAYING_SEQUENCE` או `WAITING_FOR_INPUT`):
  1. כל הטיימרים הפעילים (`setTimeout`) של השמעת הרצף מבוטלים מיד (`clearTimeout`).
  2. מצב המשחק מתאפס ל-`IDLE` **ללא שמירת ציון ב-`localStorage`**.
  3. מסך המשחק מוסתר ומסך "אודות" מוצג עם הנתונים העדכניים מה-`localStorage`.

---

### ה. אבטחה, פרטיות ו-Authentication

* **ללא Authentication:** בהתאם ל-PRD, אין מערכת משתמשים, הרשמה או התחברות.
* **פרטיות מלאה (Privacy by Design):** האפליקציה אינה אוספת מידע אישי, אינה מבצעת קריאות רשת לשרתים חיצוניים, ואינה משתמשת ב-Cookies או בכלי מעקב. כל נתוני הניקוד נשמרים מקומית על מכשיר המשתמש בלבד.
* **אבטחת צד-לקוח (XSS Prevention):** בעת הצגת היסטוריית המשחקים במסך "אודות", הנתונים מה-`localStorage` יוזרקו ל-DOM באמצעות `textContent` בלבד (ולא `innerHTML`) ויעברו ולידציה של טיפוסים (ווידוא ש-`score` הוא מספר בין 0 ל-10) כדי למנוע תקלות או הזרקת סקריפטים.

---

### ו. מבנה תיקיות הפרויקט, GitHub ו-Deployment אוטומטי

#### 1. מבנה הקבצים ב-Repository

הפרויקט יאורגן בשורש ה-Repository (Root Directory) כך שיתאים לפריסה ישירה ב-GitHub Pages ללא צורך בתהליך Build:

```text
/
├── index.html          # מסך ראשי (משחק + אודות) והגדרות RTL/Mobile
├── manifest.json       # הגדרות PWA (שם בעברית, אייקונים, standalone, portrait)
├── sw.js               # Service Worker לשמירה ב-Cache ועבודה Offline
├── css/
│   └── style.css       # עיצוב Mobile-First, אנימציות כפתורים ורספונסיביות למובייל
├── js/
│   ├── app.js          # נקודת כניסה, חיבור אירועים ורישום Service Worker
│   ├── game.js         # לוגיקת המשחק, הגרלת רצפים ובדיקת שלבים (1-10)
│   ├── audio.js        # סינתזת צלילים באמצעות Web Audio API ומצב Mute
│   ├── storage.js      # ניהול שיא אישי ו-10 משחקים אחרונים ב-localStorage
│   └── ui.js           # עדכוני DOM, החלפת מסכים והארת כפתורים
└── assets/
    ├── icon-192.png    # אייקון אפליקציה ל-PWA (192x192)
    └── icon-512.png    # אייקון אפליקציה ל-PWA (512x512)
```

#### 2. ניהול קוד ב-GitHub ופריסה אוטומטית ל-GitHub Pages

* **אחסון הקוד:** קוד המקור מנוהל ב-Git Repository ב-GitHub תחת הענף הראשי `main`.
* **ללא שלב Build:** מאחר שהפרויקט כתוב ב-Vanilla HTML/CSS/JS תקני, אין צורך בהרצת קומפילציה או התקנת חבילות לפני הפריסה.
* **Deployment אוטומטי:**
  1. בהגדרות ה-Repository ב-GitHub (`Settings -> Pages`), מקור הפריסה (Source) מוגדר ל-**Deploy from a branch** על ענף `main` מתיקיית השורש `/ (root)` (או באמצעות GitHub Actions Workflow סטנדרטי של `deploy-pages`).
  2. בכל פעם שמתבצע `git push` לענף `main`, שירות GitHub Pages מזהה את השינוי ומפרסם אוטומטית את הגרסה החדשה לאוויר תוך שניות תחת כתובת `https://<username>.github.io/<repo-name>/`.
* **עדכון גרסת PWA בלקוח:** בקובץ `sw.js` יוגדר קבוע גרסת Cache (למשל `const CACHE_NAME = 'simon-pwa-v1'`). בעת עדכון קוד משמעותי, עדכון שם ה-Cache יגרום ל-Service Worker במכשירי המשתמשים לנקות את ה-Cache הישן ולהוריד את הקבצים המעודכנים אוטומטית.

---

## 3. מקורות ותיעוד רשמי

החלטות הארכיטקטורה במסמך זה מתבססות על התיעוד והסטנדרטים הרשמיים הבאים:
* **MDN Web Docs – Web Audio API:** תיעוד יצירת צלילים בדפדפן באמצעות `AudioContext` ו-`OscillatorNode` והתמודדות עם מדיניות Autoplay במובייל (https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API).
* **MDN Web Docs – Progressive Web Apps (PWAs):** מדריך רשמי להגדרת `manifest.json` ורישום `Service Worker` לאפליקציות מובייל (https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps).
* **MDN Web Docs – Web Storage API (`localStorage`):** תיעוד שמירת נתונים בצד הלקוח וטיפול בשגיאות הרשאה/מכסה (https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage).
* **GitHub Docs – GitHub Pages:** תיעוד רשמי לאירוח אתרים סטטיים ופריסה אוטומטית מתוך GitHub Repository (https://docs.github.com/en/pages).