---
name: css
description: Use when writing or editing CSS, SCSS, or Sass, styling a component, setting up a stylesheet, or reviewing styles. Covers semantic class naming, composing Tailwind through @apply, SCSS nesting with parent selectors, and file structure.
---

# CSS conventions

Component-first CSS: class names describe *what* a thing is, not how it looks.

- `kebab-case` for all class names, named for function — `hero-container`, not `blue-box`.
- Compose Tailwind utilities into semantic classes with `@apply` inside SCSS. Don't mix
  inline utilities and custom classes on the same element.
- Express context variations with the SCSS parent selector `&`, nesting from the inside out.
  Avoid deep descendant selectors; keep nesting to 3 levels.
- Nest media queries inside the selector with `@screen`.
- File structure: `base.scss`, `semantic-base.scss`, `components.scss`, `theme.scss`.
- Define custom utilities in `@layer utilities`.

```scss
.card {
  @apply bg-white p-6 rounded-lg shadow-md;

  .dashboard & {
    @apply border border-muted;
  }
}

.title {
  @apply text-xl font-bold;

  .hero-section & {
    @apply text-4xl font-medium;
  }

  @screen md {
    @apply text-2xl;
  }
}
```

## Checklist

- Class names semantic and purpose-driven?
- Tailwind integrated via `@apply`, not sprinkled inline?
- Context variations using `&` rather than descendant selectors?
- Media queries scoped inside the component?
- Nesting shallow (max 3) and semantic?
- File structure consistent with the project convention?
