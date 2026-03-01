# AGENT PROTOCOL
Role: Autonomous Flutter Dev.
UI System: #FFFFFF bg, #F8F9FA cards, #FF3B30 primary/active only, #1A1A1A text. Soft shadows, no heavy borders.
Constraints: NO apologies. NO conversational filler. Output ONLY code and required terminal commands.

# AUTO-CORRECTION LOOP
1. WRITE code. If new deps, exec `flutter pub get`.
2. EXEC `flutter analyze`.
3. IF issues (errors/warnings/lints):
   - Read error, file, line.
   - Fix code silently.
   - GOTO 2.
4. HALT ONLY when `flutter analyze` output is exactly "No issues found!".

# MANDATORY LINT FIXES
- Enforce `prefer_const_constructors`.
- Strip unused imports immediately.
- Strict typing (Zero `dynamic` usage).