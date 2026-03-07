# Student Life OS - Help & Support

Welcome to the **Student Life OS** Help & Support page. This application is designed as your ultimate command center, carefully tailored to gamify your daily tasks, handle your university timetable, effortlessly track your finances, and skyrocket your academic progress. 

Below you will find detailed explanations of every module in the application.

---

## 1. Dashboard (Command Center)
The Command Center is your primary overview screen. It aggregates data from all other modules to give you a bird's-eye view of your life.

* **Life OS Rank**: Displays your current gamified level and total XP. Watch your rank grow as you accomplish Quests and Tasks in the Life OS module.
* **Metrics Row**: Quick snapshots of your Net Cash Flow, Quest Success percentage, and the number of classes scheduled for today.
* **Academics Progress**: Shows your predicted SGPA (Semester Grade Point Average) and a 7-day completion timeline graph based on your syllabus progress.
* **Financial Snapshot**: A bar-chart showing inflow vs outflow over the last 6 months. It summarises your total earnings, spendings, investments, and pending debts.
* **Upcoming Classes**: A quick summary of how many classes are remaining for the current day.
* **Settings**: Change your app's visual theme (Light Mode, Dark Mode, Blue Mode) and access support links.

---

## 2. Timetable
Manage your daily schedule easily, without getting overwhelmed.

* **Weekly Flow**: Your timetable organizes automatically by the day of the week.
* **Add / Edit / Delete**: Use the `+` button to add new Classes, Exams, or Events. Tap on any existing class in your timeline to edit its details or remove it.
* **Weekly Auto-Reset**: At the start of every new week, the app will ask whether you want to "Keep Previous" (clearing just your attendance history) or "Clear Timetable" to start fully fresh.
* **Attendance Tracking**: For classes that have passed or already started, tap the checkmark to mark 'Attended' or the 'X' to mark as 'Missed'. The app will calculate your daily attendance.
* **AI Sync Import**: Tap the "AI Sync" button for instructions on how to take a screenshot of your college timetable, have ChatGPT convert it to JSON, and automatically bulk-import your entire schedule.

---

## 3. Life OS
Gamify your daily life and tasks. Use this as your intelligent bullet journal.

* **Quests**: Quests are tasks that yield XP. They are categorized into Ranks (Steel, Bronze, Silver, Gold). Completing them rewards you with XP that goes directly towards your Life OS Rank. Failing a quest might incur an XP Penalty!
* **Goals**: Long-term life goals. Check them off when completed and unlock large rewards.
* **Events**: Track important dates, birthdays, and recurring events. A countdown timer tells you how many days are left.
* **Counters**: Keep track of recurrent habits (e.g., Working Out, Drinking Water, Reading). Clicking the bolt icon adds to the count and grants a small, continuous stream of XP.
* **Notes**: A fast scratchpad for permanent text entries or temporary volatile thoughts that automatically expire.

---

## 4. Expenses
Become financially responsible by logging everything you earn or spend.

* **Income**: Log any earnings like salary or pocket money.
* **Expenses**: Log everything you buy across varying custom categories.
* **Investments**: Track wealth growth.
* **Debt / Money Owed**: Keep a record of who owes you money or who you owe money to.
* **Filters**: View transactions filtered by today, week, month, or "All Time". Swiping left on an old transaction allows you to delete it gracefully if you made a mistake.

---

## 5. Syllabus
Conquer your academics with scientific progress tracking.

* **Subjects & Credits**: Add your current semester's subjects and their respective credit weights.
* **Units & Topics**: Break down your subjects into Units, and Units into Topics. Tick them off individually.
* **Exams & Weightage**: Organize exactly how your university grades you (e.g., Mid-terms 30%, Finals 50%). Add expected or actual marks for Exams to feed into the dynamic SGPA Predictor on the Dashboard.
* **Progress Bars**: Every subject has an intuitive circular completion ring showing exactly how far along you are in completing its syllabus. 

---

### Need further assistance?
If you've encountered a bug or need custom functionality built into your Life OS, please contact the developer via GitHub Issues or support email.

---

## Prompt: Documenting & specifying a new React page

Use this template to describe a new React page you want added to the project. Fill every section thoroughly — include example JSON, expected user flows, and acceptance criteria. The development team will use this to scaffold the page, wire routes, create components, build tests, and implement the AI import/timetable features.

- **Page name (human friendly):**
- **Route path (e.g. `/timetable/import`):**
- **Purpose / Goal:** Describe the exact user problem the page solves and the expected outcome after a user finishes their task.
- **Priority / Timeline:** (Low / Medium / High) and estimated deadline.
- **Target users & permissions:** (e.g., students, admins; required auth scopes)

### Layout & Visuals

- **Top-level layout:** (Full page, modal, drawer) and relationship to Dashboard.
- **Sections & layout blocks:** Header, main column, side panel, footer — describe content in each.
- **Responsive rules:** Breakpoints and behavior on mobile/tablet/desktop.
- **Styling notes:** Colors, spacing, icons, and any design tokens to use.

### Data & Models

- **Primary data model(s):** List fields and types for main entities (example JSON below). Include unique IDs and timestamps.
- **APIs / Endpoints:** For each endpoint provide: method, path, request body, response body, auth, and error cases.
- **Local storage / cache rules:** What to persist locally vs fetch each time.

### Timetable specifics (if applicable)

- **Entity shape (example):**

```json
{
  "id": "string",
  "title": "Calculus II",
  "type": "class|exam|event",
  "day": "Monday",
  "startTime": "09:00",
  "endTime": "10:00",
  "location": "Room 101",
  "recurrence": { "rule": "weekly", "interval": 1 },
  "timezone": "Asia/Kolkata",
  "notes": "optional string"
}
```

- **Recurrence & conflicts:** How to detect and resolve schedule conflicts, preference rules, and timezone handling.
- **Editing UX:** Inline edit, drag-and-drop reschedule, and bulk actions (delete, move week).
- **Import / Export:** Accept CSV, ICS, and the AI Import (screenshot -> JSON) flow.

### AI Import Feature (detailed)

- **Inputs supported:** Screenshot image, PDF, plain text, or URL with timetable.
- **Desired output:** A validated array of timetable JSON objects (see example above).
- **Interactive flow:** 1) User uploads screenshot; 2) App sends image to AI helper with a conversion prompt; 3) Response is parsed and presented in a preview where the user can confirm & edit; 4) Bulk import applied.
- **Failure modes & recovery:** Low-confidence fields flagged for manual confirmation, rate limit messages, and offline fallback.
- **Privacy & security:** Images handled in-memory, sent only if user opts in; highlight data retention policy.

#### Example AI prompt (send to the conversational model):

"You are a timetable parser. Convert the following college timetable screenshot/text into a JSON array where each object contains: title, type, day, startTime (HH:MM 24h), endTime, location, recurrence (optional), timezone. If data is missing, leave the field null. Provide only valid JSON in the response. Input: <INSERT_EXTRACTED_TEXT_OR_IMAGE>"

Include also a technical example of the wrapper request (headers, model, instructions) and parsing rules (e.g., normalize 12h to 24h, map abbreviations like "Mon" to "Monday").

### Buttons & Interactions (describe every button type and behavior)

- **Primary button:** Main action on the page (label, enabled rules, onClick effect, confirmation modals).
- **Secondary button:** Complementary actions (undo, cancel, save draft).
- **Icon buttons:** Small actions (edit, delete, share) with accessible labels and tooltips.
- **Bulk action buttons:** Multi-select operations (delete selected, export selected) and confirmation requirements.
- **AI Sync / Import button:** Behavior: opens modal, accepts file or screenshot, runs preview, shows validation results, final import confirmation.
- **Disabled / loading states:** Visual look and accessible announcements for screen readers.

### Forms & Validation

- **Fields and validation rules:** For each form field list: type, placeholder, required, regex or numeric rules, min/max lengths.
- **Error strings:** Exact copy for each validation failure to show in UI.

### Accessibility

- **Keyboard navigation:** Tab order, shortcuts, and focus management for modals.
- **ARIA roles & labels:** For dynamic elements like lists, dialogs, and buttons.

### Analytics & Events

- **Event list:** `timetable.import.started`, `timetable.import.success`, `timetable.import.failed`, `timetable.edit`, `page.view` with sample payloads.

### Testing & Acceptance Criteria

- **Unit tests:** Components should have tests for rendering, props, and event callbacks.
- **Integration tests / E2E:** Import flow (upload -> parse -> preview -> confirm) and edge cases.
- **Manual acceptance checklist:** Visual QA, responsiveness, accessibility checks, and API contract validation.

### Dev tasks (scaffolding checklist)

1. Add route and navigation entry.
2. Create page component and subcomponents (list them).
3. Wire state management (context/Redux/provider) and API mocks.
4. Add unit tests and E2E test skeleton.
5. Add storybook stories or static mocks.

---

If you want, paste a completed version of this template below and I will scaffold the React page (routes, components, example state, and tests) automatically. If you'd like me to implement it now, tell me the page name and which parts I should scaffold first (UI only, API mock, or full wired page).
