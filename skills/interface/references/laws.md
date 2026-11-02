UI/UX laws

laws that change decisions | rule + code + common break
sources lawsofux.com (Jon Yablonski) | Nielsen Norman Group | Don Norman | WCAG 2.2
shared numbers live in SKILL.md | review report format lives in `review.md`, cite law in Rule column

1 Jakob's Law | users spend most time on other products, expect yours to work the same
- do: logo top-left links home | search top | cart/account top-right | settings under avatar | standard icons (trash = delete, gear = settings) | underlined or clearly colored links | native inputs (`<select>`, `<input type="date">`)
- break only when new pattern clearly better AND taught in place
- related, Paradox of the Active User: nobody reads docs first | inline help (placeholder examples, empty states showing next step), never separate manual
- common violation: custom scrollbars | hamburger menus on desktop | icon-only buttons with unique meanings

2 Hick's Law | decision time grows with number of choices
formula `RT = a + b * log2(n + 1)` | grows with log of choice count, first extra options hurt most
holds for options user must compare | sorted list user knows how to search (countries, fonts) is scanning, not Hick
- one primary button per view | secondary quieter (outline, text link)
- max 3 to 4 pricing tiers | one marked "recommended" + preselected
- progressive disclosure: 20% of options used 80% of time | rest under "More" or "Advanced"
- smart defaults: most common choice preselected (country from locale, plan most people pick)
- one big decision into few small sequential ones (wizard, one question per step on mobile)
- long lists (> ~10 items): search/typeahead | headings | "Recent" first
- highlight recommended option so user can skip comparing
```html
<!-- one primary, one quiet secondary, the rest hidden -->
<button class="btn-primary">Send invoice</button>
<button class="btn-ghost">Save draft</button>
<details><summary>More options</summary>...</details>
```
- measure: time to first click + drop-off on decision screen | many hover between options or leave = too many or too equal
- related, Choice Overload: jam study (Iyengar + Lepper 2000) 24 jams drew 60% of passers-by vs 40% for 6 | of those who stopped, ~3% bought vs ~30% | Scheibehenne 2010 meta-analysis, 50 experiments, N = 5,036: mean effect near zero, high variance | a risk to test, not a law
- common violations: toolbars with 12 equal-weight buttons | forms asking everything up front | "Choose your plan" with 6 tiers + 40-row comparison | two equally loud buttons ("Save" + "Save and continue") side by side
- do not overdo: hiding frequent actions behind menus slows experts | simplify for majority, keep shortcuts for power users

3 Fitts's Law | time to hit target depends on size + distance
- targets per SKILL.md | primary action in thumb reach on mobile (bottom) | whole row/card clickable, not only text | label clicks focus input | related actions close to what they act on
- screen edges + corners "infinitely large" on desktop | use for frequent actions
- common violation: tiny "x" close icons | destructive + primary side by side with no gap

4 Cognitive Load, Miller's Law, Chunking | working memory holds a few items
about 4 chunks in practice | "7 +/- 2" is the popular version
- chunk long data (phone `+370 612 34567`, IBAN groups of 4, card numbers) | long forms into steps or titled sections | show, do not make users remember (previous step's choice visible, password rules while typing)
- Miller's Law is about memory, not "menus must have 7 items" | not about lists users can scan
- common violation: codes copied between screens | error messages disappearing before read

5 Doherty Threshold | keep responses under ~400 ms
Nielsen limits: 0.1 s instant | 1 s flow of thought | 10 s attention
- optimistic UI for likes, toggles, saves | skeletons for content over ~300 ms | spinner over 1 s | progress bar with time or steps over ~10 s | disable + show state on submit, stops double clicks
- common violation: blank screen while fetching | submit button with no feedback

6 Gestalt grouping | Proximity, Common Region, Similarity, Uniform Connectedness
eye groups things close, enclosed, alike, connected
- space between groups larger than inside (label-to-input 4 to 8 px, field-to-field 16 to 24 px) | cards/borders only for genuinely different groups | same function = same style | links all alike, buttons all alike
- common violation: label equidistant between two inputs | clickable element styled as plain text | everything in own card ("card soup")

7 Von Restorff Effect (Isolation) | item that differs is remembered
- exactly one visually dominant primary action | color + something else (weight, icon, position), color alone fails color-blind users | highlight recommended plan
- related, Selective Attention / banner blindness: anything ad-like ignored | no important info as banner
- common violation: everything bold, everything red, three "primary" buttons

8 Tesler's Law | complexity cannot be removed, only moved
user or system deals with it | prefer system
- autodetect (card type from number, city from postcode, timezone, language) | derive values instead of asking | sensible defaults | pre-fill what is known
- no oversimplifying into lost control | keep an override
- common violation: asking country, then phone country code, then currency separately

9 Postel's Law | liberal in what you accept, strict in what you output
- accept phone with spaces/dashes/+, emails with trailing spaces, dates in several formats, decimals with comma or dot | normalize silently | validate on blur, not every keystroke | preserve input on error
- output: consistent, formatted, predictable
- common violation: "Invalid format" for phone with space | clearing whole form after one error

10 Peak-End Rule | experience judged by peak + end
- invest in success state (clear confirmation, what happens next, moment of delight) | errors least painful peak possible (human message, way out, no data loss) | good empty states + "done" screens
- common violation: payment completes on bare "OK" page | error page as dead end

11 Goal-Gradient Effect | effort increases closer to goal
- progress in multi-step flows ("Step 2 of 3") | count real completed steps toward progress (account created = first step done) | onboarding checklists with visible completion
- common violation: 6-step wizard with no indication of length

12 Zeigarnik Effect | unfinished tasks stay on mind
- incomplete profile/setup as gentle checklist | auto-save drafts, offer "continue where you left off"
- no weaponizing with fake urgency or nagging

13 Serial Position Effect | first + last items remembered best
- most important nav items first + last | key info at start + end of lists, emails, pages | mobile tab bars: most used at ends
- common violation: main action buried mid long menu

14 Aesthetic-Usability Effect | attractive looks perceived as easier to use
users forgive small usability issues in polished products | visual appeal judged within ~50 ms of first sight (Lindgaard 2006) | design look named in 46.1% of consumer credibility comments, experts far less (Fogg et al. 2002)
- cheap polish that pays
  - one spacing scale | no random 13 px gaps
  - one type scale | 3 to 4 weights | max 2 families | values per `typography.md`
  - everything aligned to grid | one left edge per column
  - limited palette: one brand/accent, neutrals, semantic red/green/amber only for status
  - consistent radius, shadow, icon set (one library, one stroke width)
  - real content + images in designs, no lorem ipsum, look survives real data
```css
:root {
  --space-1: 4px; --space-2: 8px; --space-3: 16px; --space-4: 24px; --space-5: 32px;
  --text-sm: 0.875rem; --text-base: 1rem; --text-lg: 1.125rem; --text-xl: 1.3125rem;
  --radius: 8px;
}
```
- danger: hides real usability problems in testing | pretty prototype rated "easy" even when task fails | test tasks, measure success rate + time, not opinions
- no trading function for looks: low-contrast gray text, icon-only buttons, hidden labels look clean, fail accessibility
- common violations: mixed spacing + font sizes across screens | three shades of almost same blue | default browser styles beside custom design system | beautiful hero, broken form

15 Pareto Principle | ~20% of features get ~80% of use
- find core flows (analytics, support tickets) | make them fastest + most visible | demote rest to secondary menus
- common violation: equal visual weight for rarely used export + daily main action

Nielsen's 10 heuristics
1. visibility of system status: always show what is happening (loading, saved, sent)
2. match real world: user words, not internal jargon or DB field names
3. user control + freedom: undo, cancel, back, close everywhere | undo over "are you sure?"
4. consistency + standards: same thing, same name, same look (see Jakob)
5. error prevention: constraints, defaults, confirm only destructive + irreversible
6. recognition over recall: show options, recent items, examples
7. flexibility + efficiency: shortcuts, bulk actions, remembered preferences for experts
8. aesthetic + minimalist design: every extra element competes with important ones
9. help recover from errors: what went wrong, why, how to fix, next to field
10. help + documentation: contextual, searchable, task-oriented

Norman's interaction principles
- affordance + signifier: clickable things look clickable (cursor, hover, shape, underline)
- feedback: every action gets immediate visible response
- mapping: controls placed + moving like their effect (slider right = more)
- constraints: make wrong input impossible (input masks, native types, `min`/`max`) | submit stays enabled, validates, per `components.md`

review checklist
- [ ] one clear primary action per screen (Von Restorff, Hick)
- [ ] familiar patterns + placements (Jakob)
- [ ] targets big enough, close to thumb/cursor (Fitts)
- [ ] nothing user must remember between screens (Cognitive Load)
- [ ] feedback within 100 ms, loading states, no double submit (Doherty, Heuristic 1)
- [ ] spacing groups related things, same function looks same (Gestalt)
- [ ] system does the work: defaults, autodetect, pre-fill (Tesler)
- [ ] forgiving input, errors next to fields, input preserved (Postel, Heuristic 9)
- [ ] undo/back/cancel available, confirm only destructive (Heuristic 3, 5)
- [ ] success + error states designed, not default (Peak-End)
- [ ] progress shown in multi-step flows (Goal-Gradient)
- [ ] most important items first or last (Serial Position)
- [ ] contrast, target sizes, focus states, reduced motion ok (SKILL.md numbers)
- [ ] core 20% of tasks are fastest path (Pareto)

anti-patterns to refuse
dark patterns break these laws on purpose: confirmshaming | hidden unsubscribe | pre-ticked paid add-ons | fake countdowns | roach-motel cancellation
never build, even when asked to "use psychology" | offer honest version of same law
