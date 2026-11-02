components, states, UX copy

control states
`default, hover, focus-visible, active/pressed, disabled, loading, error, success` (+ `selected` where it applies)
half shipped = most common reason UI feels unfinished
- focus: visible ring 2px+, 3:1 contrast, offset 2px, `:focus-visible` keeps mouse clicks clean | never remove outlines without replacement
- hover: only `(hover: hover)` devices | never only way to reveal an action
- active: `transform: scale(0.97)` or 1px translate, 100 to 160ms
- disabled: looks disabled (reduced contrast, `cursor: not-allowed`) | real `disabled` attribute | explains why when not obvious (tooltip or helper text) | prefer enabling + validating over disabling submit with no explanation
- loading: control keeps size | label swaps to spinner or "Saving…" | double submission blocked

accessibility structure
- skip link first in tab order | landmarks (`header`, `nav`, `main`, `footer`) | one `h1`, no skipped heading levels
- `aria-current="page"` on active nav item
- `inert` on content behind open overlays
- sticky bars never cover focused element (WCAG 2.4.11) | `scroll-padding-top`
- drag actions (reorder, slider, dismiss) have single-pointer alternative: buttons, menu, input (WCAG 2.5.7)

buttons
- hierarchy: one primary per view | secondary outline or tonal | tertiary text | destructive distinct, away from primary
- labels verb + object, 1 to 3 words: "Create invoice", "Send", "Delete project" | never "Submit", "OK", "Yes/No" in dialogs
- one label per intent across page | no "Get started" + "Sign up" + "Try free" for same action
- height 40 to 48px web, 36px allowed in dense tools with hit area extended on touch | icon buttons square + `aria-label`
- whole visible button clickable | links look like links, buttons like buttons

forms
- visible label above every input | placeholder shows example format, never replaces label
- single column | related fields under heading | mark optional ("optional") rather than every required, or vice versa, consistently
- correct `type`, `inputmode`, `autocomplete`, `name` for browsers + password managers | never block paste
- format requirements before typing (password rules visible while typing)
- validate on blur + submit, not every keystroke | clear error as soon as fixed
- error next to field: text + icon + color | linked `aria-describedby` | announced `aria-live` | what is wrong + how to fix: "Enter a date after 1 Jan 2026", not "Invalid input"
- submit failure: keep everything typed | focus first invalid field | long forms add error summary with links
- accept liberal input + normalize (Postel): spaces in phone numbers + IBANs | comma or dot decimals | trailing whitespace in emails
- long forms: steps + progress indicator | autosave drafts | warn before discarding unsaved changes
- mobile input height 44px+, font 16px+

navigation
- current location always visible: active nav state, page title, breadcrumbs from 3 levels deep
- desktop top nav 5 to 7 items, one line, 56 to 72px tall | mobile bottom nav 3 to 5 items with labels
- same place every page | back restores scroll position + filters
- hamburger only on mobile | desktop shows navigation
- no tabs + sidebar + bottom nav at same hierarchy level

overlays
- prefer inline or progressive disclosure | modal only when task must interrupt or needs protected focus
- modal: `<dialog>` or accessible primitive | focus trapped | Escape closes | focus returns to trigger | background scroll locked | visible close button | backdrop 40 to 60% black
- destructive confirm names object + consequence ("Delete 'Q3 report'? This cannot be undone.") | button repeats verb ("Delete report") | undoable action: skip confirm, Undo in toast
- popovers + dropdowns: open from trigger (`transform-origin` at trigger) | close on outside click + Escape | keyboard navigable
- tooltips: supplementary only | never only place for essential info | appear on focus too | 300 to 500ms delay first, instant next in group
- toasts: transient outcomes only | 4 to 6s visible | pause on hover/focus | `aria-live="polite"` | Undo where possible | errors needing action stay until dismissed
- bottom sheets on mobile instead of centered modals for menus + short forms

tables and lists
- left-align text | right-align numbers (tabular numerals) | headers align with data
- sticky header | sortable columns `aria-sort` | row hover | clear selection state | bulk actions bar when rows selected
- row height 40 to 48px, 32px in density mode | zebra stripes or 1px dividers, not both
- long tables: pagination or virtualization (thousands of rows) | filters show what is active + how to clear
- mobile: rows to cards, key column first
- proven table library (TanStack Table, AG Grid) for sorting, filtering, virtualization | no hand-rolling

empty, loading, error, success
- empty (first use): what appears here | why useful | one primary action | optional example or template | distinguish first use, cleared, no search results ("No results for 'xyz'. Clear filters"), no permission, failed to load
- loading: skeleton in final layout's shape for content over ~300ms | spinner only inside small controls | progress with steps or time over ~10s | never fake progress
- error: what failed | why if known | way out (Retry, Go back, Contact) | keep user's data | no raw error codes as main message
- success: outcome + next step ("Invoice sent to Ona. View invoice") | routine stays quiet (inline check, toast) | milestone may celebrate briefly
- offline + slow: say so | queue actions if possible | retry automatically with feedback

cards
- repeated, self-contained objects | not default wrapper for every section
- whole card clickable with one destination (real link inside for accessibility) | separate actions get visible buttons
- padding 16 to 24px | radius from system | border or shadow, rarely both

charts
- by question: trend = line | comparison = bar | part of whole = stacked bar (pie/donut only 2 to 5 parts) | distribution = histogram | relationship = scatter
- title states insight ("Revenue up 12% since June") | axis labels with units | direct labels over legends | tooltips on hover + focus | accessible table alternative
- empty + error states too | aggregate or sample above ~1,000 points

UX copy
- user's side: name what people control, not how system works ("Notifications", not "Webhook config")
- same word for same thing | small glossary
- active voice | plain verbs | sentence case | no filler | cut first draft in half
- button predicts result | toast echoes it ("Publish" leads to "Published")
- errors: no blame | no jokes on serious moments (money, deletion, privacy) | no vague apologies
- loading text names real operation ("Importing 248 contacts…")
- links make sense out of context ("Download the 2026 annual report", not "Click here")
- numbers, dates, currency via `Intl` APIs + user's locale | plurals through i18n library, not `count + "s"`
- 30 to 40% extra room for translations | never concatenate translated fragments
- alt text describes image information | decorative images `alt=""`
