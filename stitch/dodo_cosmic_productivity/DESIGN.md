# Design System Strategy: The Radiant Lunar Interface

## 1. Overview & Creative North Star
**The Creative North Star: "The Celestial Playground"**

This design system moves away from the rigid, cold utility of traditional productivity tools. Instead, it treats the UI as a series of soft, radiant celestial bodies floating in a vast, hospitable dark-mode space. We are not building a spreadsheet; we are building a celebration of progress. 

To achieve a "High-End Editorial" feel, we reject the standard grid. We utilize **intentional asymmetry**, **overlapping glass layers**, and **extreme typographic contrast**. The interface should feel "bouncy" and alive, using the tension between deep space (backgrounds) and neon vitality (accents) to drive student engagement.

---

## 2. Colors & Tonal Depth
Our palette is a sophisticated interplay between the infinite depth of `surface` and the high-energy vibration of our `primary` and `secondary` accents.

### The "No-Line" Rule
**Explicit Instruction:** 1px solid borders are strictly prohibited for defining sections. 
Boundaries must be created through **Tonal Transitions**. Use the shift from `surface` (#0a0f14) to `surface_container_low` (#0e1419) to define different content zones. If a container needs to pop, we use color elevation, never a stroke.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of semi-transparent materials:
*   **Base Layer:** `surface` (#0a0f14) - The canvas.
*   **Section Layer:** `surface_container` (#141a20) - Used for grouping related content.
*   **Active Layer:** `surface_bright` (#252d35) - For interactive elements or cards that need to "hover" closer to the user.

### The "Glass & Gradient" Rule
To avoid a flat, "templated" look:
*   **Glassmorphism:** Use `surface_container_high` with a 60% opacity and a 20px Backdrop Blur for floating navigation or modals.
*   **Signature Textures:** Apply a 45-degree linear gradient from `primary` (#48f7cd) to `primary_container` (#04dab2) for all success-state elements. This provides a "soul" to the UI that flat hex codes cannot replicate.

---

## 3. Typography: Editorial Authority
We use a high-contrast scale to make tasks feel like headlines and progress feel like news.

*   **Display & Headlines (`Plus Jakarta Sans`):** Our "Celebratory" voice. Large, bold, and expressive. Use `display-lg` (3.5rem) for milestone achievements to create an editorial "wow" factor.
*   **Body & Labels (`Inter`):** Our "Guidance" voice. Clean, legible, and functional. 

**Typographic Hierarchy as Identity:**
By pairing a massive, bold `display-sm` headline with a tiny, all-caps `label-md` tracking (+5%), we create a sophisticated tension that feels premium and custom-designed.

---

## 4. Elevation & Depth
We eschew traditional drop shadows for **Ambient Glows** and **Tonal Stacking**.

*   **The Layering Principle:** Place a `surface_container_lowest` (#000000) card inside a `surface_container_low` (#0e1419) section. This "recessed" look creates a natural pocket for input fields without needing a single line.
*   **Ambient Shadows:** When an element must float (e.g., a "Complete Task" button), use a shadow tinted with `surface_tint` (#48f7cd) at 8% opacity. Blur radius should be 40px+ to mimic a soft neon glow rather than a harsh shadow.
*   **The "Ghost Border" Fallback:** If accessibility requires a container edge, use `outline_variant` (#43484e) at **15% opacity**. It should be felt, not seen.

---

## 5. Components & Interaction Patterns

### Buttons (The "Pill" Aesthetic)
*   **Primary:** Gradient fill (`primary` to `primary_container`). Border radius: `full` (9999px). No border.
*   **Secondary:** Glass-filled (`surface_bright` at 40% opacity) with a `primary` text label.
*   **Interaction:** On hover, apply a soft glow using the `primary_dim` token.

### Cards: The "Container" Strategy
*   **Constraint:** Forbid divider lines within cards.
*   **Execution:** Use vertical white space (32px / `xl`) or a subtle background shift to `surface_container_highest` to separate a card header from its body. All cards must use `lg` (2rem) or `xl` (3rem) corner radius to maintain the "Friendly/Warm" personality.

### Input Fields: The "Recessed" Look
*   **Base:** Fill with `surface_container_lowest` (#000000). 
*   **State:** On focus, the container does not get a border; instead, the background shifts to `surface_container_high` and a soft `primary_dim` glow emanates from beneath.

### Gamification Specifics: "The Streak Chip"
*   **Visual:** A high-vibrancy chip using `tertiary` (#ff9a5d) with a 45-degree gradient. 
*   **Animation:** When a task is completed, use a particle burst of `primary`, `secondary`, and `tertiary` tokens to reinforce the "celebratory" nature of this design system.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use extreme roundness (24px-32px). It is the hallmark of this system's friendliness.
*   **Do** allow elements to overlap. A "New Task" button floating partially over a card creates a high-end, layered editorial feel.
*   **Do** use `secondary` (#c57eff) and `tertiary` (#ff9a5d) sparingly as "rewards" rather than structural elements.

### Don’t:
*   **Don't** use pure white (#FFFFFF) for text. Always use `on_surface` (#e7ebf3) to prevent eye strain against the deep navy background.
*   **Don't** use 1px dividers. If you need to separate content, use a 24px gap or a tonal background change.
*   **Don't** use sharp corners. Anything less than 16px radius breaks the "Celestial Playground" aesthetic and makes the app feel corporate.